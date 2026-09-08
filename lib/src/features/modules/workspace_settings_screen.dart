import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../app/shipkia_theme_controller.dart';
import '../../core/api/api.dart';
import '../../design_system/design_system.dart';
import '../../core/router/web_module_catalog.dart';
import 'module_records.dart';
import 'web_module_screen.dart';

class WorkspaceSettingsScreen extends StatefulWidget {
  const WorkspaceSettingsScreen({required this.route, super.key});
  final WebModuleRoute route;
  @override
  State<WorkspaceSettingsScreen> createState() =>
      _WorkspaceSettingsScreenState();
}

class _WorkspaceSettingsScreenState extends State<WorkspaceSettingsScreen> {
  static const types = {
    'shipment-automation': 'automated_shipment',
    'ndr-flow': 'ndr_flow',
    'order-notification': 'whatsapp',
    'order-confirmation': 'order_confirmation',
    'default-dimension': 'default_dimension',
  };
  String? get type => types[widget.route.path.split('/').last];
  Map<String, dynamic>? values;
  Object? error;
  bool saving = false;
  bool dirty = false;
  CancelToken token = CancelToken();
  final dimensions = <String, TextEditingController>{};
  bool initialized = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!initialized) {
      initialized = true;
      if (type != null) load();
    }
  }

  Map<String, dynamic> decode(Object? data) {
    if (data is! Map) {
      throw const FormatException('Expected workspace settings.');
    }
    final body = data[type] ?? data;
    if (body is! Map) throw const FormatException('Expected settings values.');
    return Map<String, dynamic>.from(body);
  }

  Future<void> load() async {
    try {
      final api = ShipKiaApiScope.maybeOf(context);
      if (api == null) throw StateError('Connection unavailable');
      final data = decode(
        await api.request<Object?>(
          ApiRequestConfig(
            method: HttpMethod.get,
            path: '/oms/customer-settings',
            params: {'type': type},
            cancelToken: token,
            showErrorMessage: false,
          ),
        ),
      );
      if (!mounted) return;
      for (final key in ['length', 'breadth', 'height', 'dead_weight']) {
        dimensions.putIfAbsent(key, () => TextEditingController()).text =
            ((num.tryParse('${data[key]}') ??
                        (key == 'dead_weight' ? 0 : 100)) /
                    (key == 'dead_weight' ? 1000 : 10))
                .toString();
      }
      setState(() {
        values = data;
        error = null;
        dirty = false;
      });
    } catch (e) {
      if (mounted && !token.isCancelled) setState(() => error = e);
    }
  }

  void change(String key, Object value) => setState(() {
    values![key] = value;
    dirty = true;
  });
  Future<void> save() async {
    final payload = Map<String, dynamic>.from(values!);
    if (type == 'default_dimension') {
      for (final entry in dimensions.entries) {
        final number = double.tryParse(entry.value.text);
        if (number == null || !number.isFinite || number <= 0) {
          setState(
            () => error = const FormatException(
              'Enter a positive number for each dimension and weight.',
            ),
          );
          return;
        }
        payload[entry.key] = (number * (entry.key == 'dead_weight' ? 1000 : 10))
            .round();
      }
      payload['volumetric_weight'] =
          (payload['length'] as num) *
          (payload['breadth'] as num) *
          (payload['height'] as num) /
          5000;
    }
    if (type == 'ndr_flow' || type == 'order_confirmation') {
      payload['type'] ??= 'none';
      if (payload['type'] != 'advanced') {
        payload.remove('lang');
      } else {
        payload['lang'] ??= 'english';
      }
    }
    if (type == 'order_confirmation') {
      payload['cod'] ??= true;
      payload['prepaid'] ??= true;
      payload['shipment_automation_after_confirmation'] ??= false;
      if (payload['type'] == 'none' ||
          (payload['cod'] == false && payload['prepaid'] == false)) {
        payload['shipment_automation_after_confirmation'] = false;
      }
    }
    if (type == 'whatsapp') {
      for (final key in notificationEvents) {
        payload[key] ??= false;
      }
    }
    setState(() {
      saving = true;
      error = null;
    });
    try {
      final api = ShipKiaApiScope.maybeOf(context)!;
      await api.request<Object?>(
        ApiRequestConfig(
          method: HttpMethod.put,
          path: '/oms/customer-settings',
          params: {'type': type},
          data: {type!: payload},
          cancelToken: token,
          showErrorMessage: false,
        ),
      );
      if (!mounted) return;
      await load();
      if (mounted && error == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Settings saved')));
      }
    } catch (e) {
      if (mounted && !token.isCancelled) setState(() => error = e);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  static const notificationEvents = [
    'new',
    'shipped',
    'cancelled',
    'delivered',
    'delivery_delayed',
    'out_for_delivery',
  ];
  Widget toggle(
    String key, {
    bool fallback = false,
    String? title,
    bool enabled = true,
  }) => SwitchListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(title ?? fieldLabel(key)),
    value: values![key] is bool ? values![key] as bool : fallback,
    onChanged: saving || !enabled ? null : (v) => change(key, v),
  );
  Widget choices(
    String key,
    List<String> options, {
    String fallback = 'none',
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: DropdownButtonFormField<String>(
      initialValue: options.contains(values![key])
          ? values![key] as String
          : fallback,
      decoration: InputDecoration(labelText: fieldLabel(key)),
      items: options
          .map((v) => DropdownMenuItem(value: v, child: Text(fieldLabel(v))))
          .toList(),
      onChanged: saving
          ? null
          : (v) {
              if (v != null) change(key, v);
            },
    ),
  );
  @override
  void dispose() {
    token.cancel();
    for (final c in dimensions.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.route.path.endsWith('/appearance')) {
      return AppScaffold(
        title: 'Appearance',
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Make ShipKia yours',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            const Text('Choose how the app looks on this device.'),
            const SizedBox(height: 20),
            for (final mode in ThemeMode.values)
              ListTile(
                leading: Icon(
                  mode == ThemeMode.dark
                      ? Icons.dark_mode_outlined
                      : mode == ThemeMode.light
                      ? Icons.light_mode_outlined
                      : Icons.brightness_auto_outlined,
                ),
                title: Text(fieldLabel(mode.name)),
                trailing: ShipKiaThemeController.modeOf(context) == mode
                    ? const Icon(Icons.check_circle)
                    : null,
                onTap: () => ShipKiaThemeController.setMode(context, mode),
              ),
          ],
        ),
      );
    }
    if (type == null) {
      return AppScaffold(
        title: widget.route.label,
        body: const AppEmptyState(
          title: 'Available in the web workspace',
          message: 'This workflow has not been migrated to mobile yet.',
        ),
      );
    }
    if (values == null) {
      return AppScaffold(
        title: widget.route.label,
        body: error == null
            ? const Center(child: CircularProgressIndicator())
            : AppErrorState(
                message: ApiExceptionMapper.unknown(error!).message,
                onRetry: () {
                  setState(() => error = null);
                  load();
                },
              ),
      );
    }
    final viewOnly = type == 'automated_shipment';
    return AppScaffold(
      title: widget.route.label,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            widget.route.label,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(widget.route.description),
          const SizedBox(height: 20),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (type == 'whatsapp') ...[
                  Text(
                    'WhatsApp events',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  for (final key in notificationEvents)
                    toggle(key, title: key == 'new' ? 'New order' : null),
                ],
                if (type == 'ndr_flow' || type == 'order_confirmation') ...[
                  choices('type', ['none', 'basic', 'advanced']),
                  if (values!['type'] == 'advanced')
                    choices('lang', ['english', 'hindi'], fallback: 'english'),
                  if (type == 'order_confirmation') ...[
                    toggle('cod', fallback: true, title: 'Cash on delivery'),
                    toggle('prepaid', fallback: true, title: 'Prepaid orders'),
                    toggle(
                      'shipment_automation_after_confirmation',
                      title: 'Ship after confirmation',
                      enabled:
                          values!['type'] != null &&
                          values!['type'] != 'none' &&
                          (values!['cod'] != false ||
                              values!['prepaid'] != false),
                    ),
                  ],
                ],
                if (type == 'default_dimension') ...[
                  for (final entry in dimensions.entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: TextField(
                        controller: entry.value,
                        enabled: !saving,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: fieldLabel(entry.key),
                          suffixText: entry.key == 'dead_weight' ? 'kg' : 'cm',
                        ),
                        onChanged: (_) => setState(() => dirty = true),
                      ),
                    ),
                  const Text(
                    'Volumetric weight is calculated from your package dimensions.',
                  ),
                ],
                if (viewOnly) ...[
                  RecordFieldsView(
                    record: ModuleRecord({
                      'type': 'none',
                      ...values!,
                    }, const []),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Courier priority and scheduling can be edited in the web workspace.',
                  ),
                ],
              ],
            ),
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(ApiExceptionMapper.unknown(error!).message),
            ),
          const SizedBox(height: 20),
          if (!viewOnly)
            AppButton(
              label: 'Save changes',
              loading: saving,
              onPressed: dirty && !saving ? save : null,
            ),
          if (viewOnly) AppButton(label: 'Refresh settings', onPressed: load),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
