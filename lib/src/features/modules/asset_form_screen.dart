import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/api/api.dart';
import '../../core/auth/shipkia_auth_scope.dart';
import '../../core/forms/forms.dart';
import '../../core/router/web_module_catalog.dart';
import '../../design_system/design_system.dart';
import 'module_records.dart';
import 'asset_form_overrides.dart';

abstract final class AssetFormAccess {
  static bool canWrite(
    BuildContext context,
    String? type, {
    required bool create,
  }) {
    final supported = create
        ? {'products', 'bank_accounts', 'tax_rate', 'box', 'pickup_address'}
        : {'products', 'bank_accounts', 'tax_rate', 'company_info'};
    if (!supported.contains(type)) return false;
    final profile = context
        .dependOnInheritedWidgetOfExactType<ShipKiaAuthScope>()
        ?.notifier
        ?.profile;
    final roles =
        profile?.roles
            .map((r) => r.toLowerCase().replaceAll(RegExp(r'\s+'), ''))
            .toSet() ??
        {};
    return roles.contains('ordermanager') || roles.contains('buopsoadmin');
  }
}

class AssetFormScreen extends StatefulWidget {
  const AssetFormScreen({
    required this.route,
    this.recordId,
    this.readOnly = false,
    super.key,
  });
  final WebModuleRoute route;
  final String? recordId;
  final bool readOnly;
  @override
  State<AssetFormScreen> createState() => _AssetFormScreenState();
}

class _AssetFormScreenState extends State<AssetFormScreen> {
  final token = CancelToken();
  final builderKey = GlobalKey<DynamicFormBuilderState>();
  DynamicFormController? controller;
  ModuleRepository? repository;
  Object? error;
  bool loading = true, saving = false;
  bool get readOnly =>
      widget.readOnly ||
      !AssetFormAccess.canWrite(
        context,
        widget.route.objectType,
        create: widget.recordId == null,
      );
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (repository == null) {
      final api = ShipKiaApiScope.maybeOf(context);
      if (api != null) {
        repository = ModuleRepository(api, widget.route);
        load();
      } else {
        loading = false;
        error = StateError('Connection unavailable');
      }
    }
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });
    final viewOnly = readOnly;
    try {
      final results = await Future.wait<Object?>([
        repository!.fields(token),
        if (widget.recordId != null)
          repository!.detail(widget.recordId!, token),
      ]);
      if (!mounted) return;
      final values = results.length > 1
          ? (results[1]! as ModuleRecord).values
          : <String, dynamic>{};
      final schema = const ApiFormAdapter().parse(
        AssetFormOverrides.fields(widget.route.objectType, results[0]),
        id: widget.route.objectType!,
        values: values,
        readOnly: viewOnly,
      );
      if (schema.fields.isEmpty) {
        throw const FormatException('No form fields were returned.');
      }
      controller?.dispose();
      controller = DynamicFormController(schema: schema);
    } catch (e) {
      if (mounted) error = e;
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> save() async {
    if (readOnly ||
        saving ||
        !builderKey.currentState!.validateAndFocusFirstError()) {
      return;
    }
    final form = controller!;
    // Pickup's web form validates operating times before sending the record.
    if (widget.route.objectType == 'pickup_address') {
      final open = form.values['opening_time'],
          close = form.values['closing_time'];
      if (open is TimeOfDay &&
          close is TimeOfDay &&
          open.hour * 60 + open.minute > close.hour * 60 + close.minute) {
        form.setFieldError(
          'closing_time',
          'Closing time cannot be before opening time.',
        );
        return;
      }
    }
    setState(() {
      saving = true;
      error = null;
    });
    try {
      final data = const ApiFormAdapter().serialize(form.schema, form.values);
      if (widget.route.objectType == 'bank_accounts' &&
          form.values['bank'] != 'Other' &&
          form.schema.fields.any((f) => f.id == 'bank_name')) {
        data['bank_name'] = '';
      }
      if (widget.route.objectType == 'pickup_address' &&
          form.values['rto_is_same_as_pickup'] == true) {
        data['rto_address'] = null;
      }
      await repository!.save(data, token, id: widget.recordId);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Record saved')));
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => error = e);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  void dispose() {
    token.cancel();
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    title:
        '${readOnly
            ? 'View'
            : widget.recordId == null
            ? 'New'
            : 'Edit'} ${widget.route.label}',
    body: loading
        ? const Center(child: CircularProgressIndicator())
        : controller == null
        ? AppErrorState(
            message: ApiExceptionMapper.unknown(
              error ?? StateError('Form unavailable'),
            ).message,
            onRetry: load,
          )
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AbsorbPointer(
                absorbing: saving,
                child: DynamicFormBuilder(
                  key: builderKey,
                  schema: controller!.schema,
                  controller: controller!,
                  maxColumns: 1,
                ),
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(ApiExceptionMapper.unknown(error!).message),
                ),
              if (!readOnly)
                AppButton(
                  label: widget.route.objectType == 'tax_rate'
                      ? 'Save'
                      : widget.recordId == null
                      ? 'Create'
                      : 'Update',
                  loading: saving,
                  onPressed: saving ? null : save,
                ),
              const SizedBox(height: 24),
            ],
          ),
  );
}
