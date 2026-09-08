import 'order_detail_widgets.dart';

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/api/api.dart';
import '../../core/forms/forms.dart';
import '../../design_system/design_system.dart';
import 'data/orders_repository.dart';
import 'domain/order_form.dart';
import 'domain/order_summary.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({required this.orderId, this.order, super.key});
  final String orderId;
  final OrderSummary? order;
  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  int _tab = 0;
  bool _activityOpened = false;
  ApiClient? _api;
  CancelToken? _token;
  int _generation = 0;
  bool _loading = true, _saving = false, _canUpdate = false;
  Object? _error;
  Map<String, dynamic>? _record;
  Map<String, Object?> _original = {};
  DynamicFormController? _form;
  GlobalKey<DynamicFormBuilderState> _builderKey = GlobalKey();
  bool get _readOnly => !_canUpdate || _record?['stage'] != 'New';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final api = ShipKiaApiScope.maybeOf(context);
    if (identical(api, _api)) {
      if (api == null) _loading = false;
      return;
    }
    _api = api;
    if (api != null) unawaited(_load());
  }

  @override
  void didUpdateWidget(OrderDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orderId != widget.orderId) {
      _tab = 0;
      _activityOpened = false;
      _form?.dispose();
      _form = null;
      _record = null;
      unawaited(_load());
    }
  }

  Future<void> _load() async {
    if (_api == null) return;
    final generation = ++_generation;
    _token?.cancel();
    final token = _token = CancelToken();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repository = OrdersRepository(_api!);
      final results = await Future.wait<Object?>([
        repository.formRecord(widget.orderId, token),
        repository.canUpdate(token),
      ]);
      final data = results[0] as Map<String, dynamic>;
      final values = data['value'] as Map<String, dynamic>;
      final fields =
          data['fields'] is List && (data['fields'] as List).isNotEmpty
          ? data['fields']
          : await repository.fields(token);
      final canUpdate = results[1] == true;
      final schema = const ApiFormAdapter().parse(
        OrderForm.fields(fields),
        id: 'order-detail',
        values: values,
        readOnly: !canUpdate || values['stage'] != 'New',
      );
      if (schema.fields.isEmpty) {
        throw const FormatException('No order form fields were returned.');
      }
      if (!mounted || generation != _generation) return;
      _form?.dispose();
      _form = DynamicFormController(schema: schema);
      _original = OrderForm.stored(_form!);
      _builderKey = GlobalKey();
      setState(() {
        _record = values;
        _canUpdate = canUpdate;
      });
    } catch (error) {
      if (mounted && generation == _generation && !token.isCancelled) {
        setState(() => _error = error);
      }
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _refresh() async {
    if (_saving || _loading) return;
    if (_form?.isDirty == true) {
      final discard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard unsaved changes?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep editing'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
      if (discard != true || !mounted) return;
    }
    await _load();
  }

  OrderFormTotals _totals() {
    final stored = OrderForm.stored(_form!, forPreview: true);
    const dependencies = {
      'product_details',
      'shipping_charge',
      'transaction_charge',
      'gift_wrap_charge',
      'additional_discount',
      'total_discount',
    };
    final changed = dependencies.any((id) => _form!.fieldState(id).dirty);
    return OrderFormTotals(
      stored,
      savedTotal: !changed && _record?['total_order_value'] != null
          ? OrderForm.number(_record!['total_order_value'])
          : null,
    );
  }

  Future<void> _save() async {
    if (_readOnly || _saving || _loading || _form == null) return;
    if (!_builderKey.currentState!.validateAndFocusFirstError()) return;
    final error = _totals().error;
    if (error != null) {
      setState(() => _error = FormatException(error));
      return;
    }
    final changes = OrderForm.changes(_form!, _original);
    if (changes.isEmpty) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await OrdersRepository(_api!).update(widget.orderId, changes, _token!);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Order updated')));
      await _load();
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _summary() => ListenableBuilder(
    listenable: _form!,
    builder: (context, _) {
      final totals = _totals();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 12),
          Text('Order summary', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final line in [
            ('Product total', totals.subtotal),
            ('Other charges', totals.otherCharges),
            ('Discount', totals.discount),
            ('Order value', totals.total),
            if (totals.cod) ('Prepaid amount', totals.prepaid),
            if (totals.cod) ('Remaining COD', totals.remaining),
          ])
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Expanded(child: Text(line.$1)),
                  Text('INR ${(line.$2 / 100).toStringAsFixed(2)}'),
                ],
              ),
            ),
          if (totals.error != null)
            Text(
              totals.error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          const SizedBox(height: 12),
          Text(
            'Volumetric weight: ${(OrderForm.number(_form!.values['length']) * OrderForm.number(_form!.values['breadth']) * OrderForm.number(_form!.values['height']) / 5000).toStringAsFixed(3)} KG',
          ),
        ],
      );
    },
  );

  @override
  void dispose() {
    _generation++;
    _token?.cancel();
    _form?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    title: widget.orderId,
    body: _form == null
        ? _loading
              ? const Center(child: CircularProgressIndicator())
              : AppErrorState(
                  title: 'Unable to load order',
                  message: _error == null
                      ? 'Connect to your workspace to load this order.'
                      : ApiExceptionMapper.unknown(_error!).message,
                  onRetry: _load,
                )
        : Stack(
            children: [
              Positioned.fill(
                child: ColoredBox(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                ),
              ),
              Positioned.fill(
                child: IndexedStack(
                  index: _tab,
                  children: [
                    RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 92),
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          if (_loading)
                            const LinearProgressIndicator(minHeight: 2),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Order Details',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                              ),
                              Flexible(
                                child: AppChip(
                                  label: '${_record?['stage'] ?? ''}',
                                  selected: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              AppButton(
                                label: 'Refresh order',
                                icon: Icons.refresh,
                                variant: AppButtonVariant.secondary,
                                onPressed: _saving || _loading
                                    ? null
                                    : _refresh,
                              ),
                              if (!_readOnly)
                                AppButton(
                                  label: 'Update',
                                  loading: _saving,
                                  onPressed: _loading ? null : _save,
                                ),
                              AppButton(
                                label: 'Copy ID',
                                icon: Icons.copy,
                                variant: AppButtonVariant.ghost,
                                onPressed: () => Clipboard.setData(
                                  ClipboardData(text: widget.orderId),
                                ),
                              ),
                            ],
                          ),
                          if (_error != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                ApiExceptionMapper.unknown(_error!).message,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                          if (_readOnly)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text('Read-only order'),
                            ),
                          const SizedBox(height: 12),
                          OrderDetailHeader(record: _record!),
                          const SizedBox(height: 12),
                          AbsorbPointer(
                            absorbing: _saving || _loading,
                            child: DynamicFormBuilder(
                              key: _builderKey,
                              schema: _form!.schema,
                              controller: _form!,
                              maxColumns: 1,
                              sectionCards: true,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (!_readOnly)
                            AppButton(
                              label: 'Update',
                              loading: _saving,
                              onPressed: _loading ? null : _save,
                            ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                    ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      children: [_summary()],
                    ),
                    if (_activityOpened)
                      OrderActivity(
                        key: ValueKey(widget.orderId),
                        api: _api!,
                        orderId: widget.orderId,
                      )
                    else
                      const SizedBox.shrink(),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: OrderDetailNavigation(
                  selected: _tab,
                  onSelected: (tab) {
                    FocusScope.of(context).unfocus();
                    setState(() {
                      _tab = tab;
                      if (tab == 2) _activityOpened = true;
                    });
                  },
                ),
              ),
            ],
          ),
  );
}
