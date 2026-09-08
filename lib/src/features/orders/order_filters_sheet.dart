import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../design_system/design_system.dart';
import 'domain/order_list_filters.dart';
import 'domain/order_stages.dart';
export 'domain/order_list_filters.dart';

Future<OrderListFilters?> showOrderFiltersSheet({
  required BuildContext context,
  required OrderListFilters filters,
}) => showAppBottomSheet<OrderListFilters>(
  context: context,
  builder: (_) => OrderFiltersSheet(filters: filters),
);

class OrderFiltersSheet extends StatefulWidget {
  const OrderFiltersSheet({required this.filters, super.key});
  final OrderListFilters filters;
  @override
  State<OrderFiltersSheet> createState() => _OrderFiltersSheetState();
}

class _OrderFiltersSheetState extends State<OrderFiltersSheet> {
  late OrderListFilters _filters = widget.filters;
  late final _city = TextEditingController(text: widget.filters.city);
  late final _pincode = TextEditingController(text: widget.filters.pincode);
  late final _value = TextEditingController(text: widget.filters.advancedValue);

  @override
  void dispose() {
    _city.dispose();
    _pincode.dispose();
    _value.dispose();
    super.dispose();
  }

  void _toggleQuick(String value) {
    final selected = {..._filters.quickPicks};
    if (!selected.remove(value)) {
      if (value == 'today' || value == 'last_7_days') {
        selected.removeAll(['today', 'last_7_days']);
      }
      selected.add(value);
    }
    setState(() => _filters = _filters.copyWith(quickPicks: selected));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .82,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Filter orders',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  AppIconButton(
                    icon: Icons.close,
                    tooltip: 'Close filters',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _Section(
                    title: 'Quick picks',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final entry in const {
                          'today': 'Today',
                          'last_7_days': 'Last 7 days',
                          'missing_awb': 'Missing AWB',
                          'no_courier': 'No courier assigned',
                        }.entries)
                          AppChip(
                            label: entry.value,
                            selected: _filters.quickPicks.contains(entry.key),
                            onSelected: (_) => _toggleQuick(entry.key),
                          ),
                      ],
                    ),
                  ),
                  _Section(
                    title: 'Payment',
                    child: Wrap(
                      spacing: 8,
                      children: [
                        for (final payment in const ['COD', 'Prepaid'])
                          AppChip(
                            label: payment,
                            selected: _filters.deliveryDetails.contains(
                              payment,
                            ),
                            onSelected: (selected) {
                              setState(
                                () => _filters = _filters.copyWith(
                                  deliveryDetails: selected ? {payment} : {},
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                  _Section(
                    title: 'Shipment status',
                    child: DropdownButtonFormField<String>(
                      key: ValueKey(_filters.status),
                      initialValue: _filters.status ?? '',
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem(
                          value: '',
                          child: Text('Any status'),
                        ),
                        for (final status in OrderStages.statuses)
                          DropdownMenuItem(value: status, child: Text(status)),
                      ],
                      onChanged: (value) => setState(
                        () => _filters = _filters.copyWith(
                          status: value == '' ? null : value,
                        ),
                      ),
                    ),
                  ),
                  _Section(
                    title: 'Destination',
                    child: Column(
                      children: [
                        AppTextField(
                          controller: _city,
                          label: 'City',
                          hintText: 'Enter destination city',
                          height: 48,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _pincode,
                          label: 'Pincode',
                          hintText: 'Enter all or part of a pincode',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          maxLength: 6,
                          height: 48,
                        ),
                      ],
                    ),
                  ),
                  _Section(
                    title: 'Advanced filter',
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          key: ValueKey('field-${_filters.advancedField}'),
                          initialValue: _filters.advancedField,
                          isExpanded: true,
                          decoration: const InputDecoration(labelText: 'Field'),
                          items: [
                            for (final entry in const {
                              'id': 'Order ID',
                              'awb': 'AWB',
                              'delivery_phone': 'Delivery phone',
                              'customer_id': 'Customer ID',
                            }.entries)
                              DropdownMenuItem(
                                value: entry.key,
                                child: Text(entry.value),
                              ),
                          ],
                          onChanged: (value) => setState(
                            () => _filters = _filters.copyWith(
                              advancedField: value,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          key: ValueKey(
                            'operator-${_filters.advancedOperator}',
                          ),
                          initialValue: _filters.advancedOperator,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Condition',
                          ),
                          items: [
                            for (final entry in const {
                              'contains': 'Contains',
                              '=': 'Equals',
                              '!=': 'Does not equal',
                            }.entries)
                              DropdownMenuItem(
                                value: entry.key,
                                child: Text(entry.value),
                              ),
                          ],
                          onChanged: (value) => setState(
                            () => _filters = _filters.copyWith(
                              advancedOperator: value,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _value,
                          label: 'Value',
                          hintText: 'Enter a value',
                          height: 48,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Reset',
                      variant: AppButtonVariant.secondary,
                      height: 48,
                      onPressed: () {
                        setState(() {
                          _filters = const OrderListFilters();
                          _city.clear();
                          _pincode.clear();
                          _value.clear();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: 'Apply filters',
                      height: 48,
                      onPressed: () => Navigator.pop(
                        context,
                        _filters.copyWith(
                          city: _city.text.trim(),
                          pincode: _pincode.text.trim(),
                          advancedValue: _value.text.trim(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}
