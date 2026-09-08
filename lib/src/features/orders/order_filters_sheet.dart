import 'package:flutter/material.dart';

import '../../design_system/design_system.dart';
import '../../theme/shipkia_colors.dart';

class OrderListFilters {
  const OrderListFilters({
    this.quickPicks = const <String>{},
    this.status,
    this.deliveryDetails = const <String>{},
    this.ecommercePlatform,
    this.orderChannel,
    this.pickupAddress,
    this.city,
    this.pincode,
    this.advancedField = 'id',
    this.advancedOperator = 'contains',
    this.advancedValue,
  });

  final Set<String> quickPicks;
  final String? status;
  final Set<String> deliveryDetails;
  final String? ecommercePlatform;
  final String? orderChannel;
  final String? pickupAddress;
  final String? city;
  final String? pincode;
  final String advancedField;
  final String advancedOperator;
  final String? advancedValue;

  bool get isEmpty => activeCount == 0;

  int get activeCount {
    return quickPicks.length +
        (status == null ? 0 : 1) +
        deliveryDetails.length +
        (ecommercePlatform == null ? 0 : 1) +
        (_hasText(orderChannel) ? 1 : 0) +
        (_hasText(pickupAddress) ? 1 : 0) +
        (_hasText(city) ? 1 : 0) +
        (_hasText(pincode) ? 1 : 0) +
        (_hasText(advancedValue) ? 1 : 0);
  }

  OrderListFilters copyWith({
    Set<String>? quickPicks,
    Object? status = _sentinel,
    Set<String>? deliveryDetails,
    Object? ecommercePlatform = _sentinel,
    String? orderChannel,
    String? pickupAddress,
    String? city,
    String? pincode,
    String? advancedField,
    String? advancedOperator,
    String? advancedValue,
  }) {
    return OrderListFilters(
      quickPicks: quickPicks ?? this.quickPicks,
      status: status == _sentinel ? this.status : status as String?,
      deliveryDetails: deliveryDetails ?? this.deliveryDetails,
      ecommercePlatform: ecommercePlatform == _sentinel
          ? this.ecommercePlatform
          : ecommercePlatform as String?,
      orderChannel: orderChannel ?? this.orderChannel,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      advancedField: advancedField ?? this.advancedField,
      advancedOperator: advancedOperator ?? this.advancedOperator,
      advancedValue: advancedValue ?? this.advancedValue,
    );
  }

  Object? toPayload({String? stage}) {
    final filterSet = <Map<String, dynamic>>[];
    if (_hasText(stage) && stage != 'All') {
      filterSet.add({'id': 'stage', 'opr': '=', 'value': stage});
    }

    for (final quickPick in quickPicks) {
      final filter = _quickPickFilter(quickPick);
      if (filter != null) filterSet.add(filter);
    }

    if (_hasText(status)) {
      filterSet.add({'id': 'status', 'opr': '=', 'value': status});
    }
    for (final value in deliveryDetails) {
      final filter = _deliveryFilter(value);
      if (filter != null) filterSet.add(filter);
    }
    if (_hasText(ecommercePlatform)) {
      filterSet.add({
        'id': 'ecommerce_platform',
        'opr': '=',
        'value': ecommercePlatform,
      });
    }
    if (_hasText(orderChannel)) {
      filterSet.add({'id': 'order_channel', 'opr': '=', 'value': orderChannel});
    }
    if (_hasText(pickupAddress)) {
      filterSet.add({
        'id': 'pickup_address',
        'opr': 'contains',
        'value': pickupAddress,
      });
    }
    if (_hasText(city)) {
      filterSet.add({'id': 'delivery_city', 'opr': 'contains', 'value': city});
    }
    if (_hasText(pincode)) {
      filterSet.add({'id': 'delivery_pincode', 'opr': '=', 'value': pincode});
    }
    if (_hasText(advancedValue)) {
      filterSet.add({
        'id': advancedField,
        'opr': advancedOperator,
        'value': advancedValue,
      });
    }

    if (filterSet.isEmpty) return null;
    return {
      'filters': {
        'id': 'flt_mobile_orders',
        'type': 'nested',
        'connector': 'and',
        'filterSet': filterSet,
      },
    };
  }

  String get cacheKey {
    return [
      quickPicks.toList()..sort(),
      status ?? '',
      deliveryDetails.toList()..sort(),
      ecommercePlatform ?? '',
      orderChannel ?? '',
      pickupAddress ?? '',
      city ?? '',
      pincode ?? '',
      advancedField,
      advancedOperator,
      advancedValue ?? '',
    ].join('|');
  }

  static bool _hasText(String? value) =>
      value != null && value.trim().isNotEmpty;

  Map<String, dynamic>? _quickPickFilter(String value) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return switch (value) {
      'today' => {
        'id': 'created_at',
        'opr': '>=',
        'value': today.toIso8601String(),
      },
      'last_7_days' => {
        'id': 'created_at',
        'opr': '>=',
        'value': today.subtract(const Duration(days: 7)).toIso8601String(),
      },
      'missing_awb' => {'id': 'awb', 'opr': 'is', 'value': false},
      'no_courier' => {'id': 'courier_partner', 'opr': 'is', 'value': false},
      _ => null,
    };
  }

  Map<String, dynamic>? _deliveryFilter(String value) {
    return switch (value) {
      'COD' || 'Prepaid' => {'id': 'payment_mode', 'opr': '=', 'value': value},
      'Delhivery' ||
      'Shadowfax' ||
      'Ekart' => {'id': 'courier_partner', 'opr': '=', 'value': value},
      _ => null,
    };
  }
}

const Object _sentinel = Object();

Future<OrderListFilters?> showOrderFiltersSheet({
  required BuildContext context,
  required OrderListFilters filters,
}) {
  return showAppBottomSheet<OrderListFilters>(
    context: context,
    builder: (context) => OrderFiltersSheet(filters: filters),
  );
}

class OrderFiltersSheet extends StatefulWidget {
  const OrderFiltersSheet({required this.filters, super.key});

  final OrderListFilters filters;

  @override
  State<OrderFiltersSheet> createState() => _OrderFiltersSheetState();
}

class _OrderFiltersSheetState extends State<OrderFiltersSheet> {
  late OrderListFilters _filters = widget.filters;
  late final TextEditingController _channelController;
  late final TextEditingController _pickupController;
  late final TextEditingController _cityController;
  late final TextEditingController _pincodeController;
  late final TextEditingController _advancedController;

  @override
  void initState() {
    super.initState();
    _channelController = TextEditingController(text: _filters.orderChannel);
    _pickupController = TextEditingController(text: _filters.pickupAddress);
    _cityController = TextEditingController(text: _filters.city);
    _pincodeController = TextEditingController(text: _filters.pincode);
    _advancedController = TextEditingController(text: _filters.advancedValue);
  }

  @override
  void dispose() {
    _channelController.dispose();
    _pickupController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _advancedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.86,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Filters',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  AppIconButton(
                    icon: Icons.close,
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  _FilterSection(
                    icon: Icons.auto_awesome_outlined,
                    title: 'Quick picks',
                    child: _ChipWrap(
                      values: const {
                        'today': 'Today',
                        'last_7_days': 'Last 7 days',
                        'missing_awb': 'Missing AWB',
                        'no_courier': 'No courier assigned',
                      },
                      selected: _filters.quickPicks,
                      onChanged: (values) {
                        setState(() {
                          _filters = _filters.copyWith(quickPicks: values);
                        });
                      },
                    ),
                  ),
                  _FilterSection(
                    title: 'Status',
                    child: _SelectBox(
                      hint: 'Select status',
                      value: _filters.status,
                      values: const [
                        'New',
                        'Ready to Ship',
                        'Ready to Pickup',
                        'In-Transit',
                        'Delivered',
                        'Cancelled',
                        'RTO',
                      ],
                      onChanged: (value) {
                        setState(() {
                          _filters = _filters.copyWith(status: value);
                        });
                      },
                    ),
                  ),
                  _FilterSection(
                    icon: Icons.local_shipping_outlined,
                    title: 'Delivery details',
                    child: _ChipWrap(
                      values: const {
                        'COD': 'COD',
                        'Prepaid': 'Prepaid',
                        'Delhivery': 'Delhivery',
                        'Shadowfax': 'Shadowfax',
                        'Ekart': 'Ekart',
                      },
                      selected: _filters.deliveryDetails,
                      onChanged: (values) {
                        setState(() {
                          _filters = _filters.copyWith(deliveryDetails: values);
                        });
                      },
                    ),
                  ),
                  _FilterSection(
                    icon: Icons.storefront_outlined,
                    title: 'Ecommerce platform',
                    child: _ChipWrap(
                      values: const {'Shopify': 'Shopify'},
                      icons: const {'Shopify': Icons.shopping_bag_outlined},
                      selected: {
                        if (_filters.ecommercePlatform != null)
                          _filters.ecommercePlatform!,
                      },
                      singleSelect: true,
                      onChanged: (values) {
                        setState(() {
                          _filters = _filters.copyWith(
                            ecommercePlatform: values.isEmpty
                                ? null
                                : values.first,
                          );
                        });
                      },
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _FilterSection(
                          title: 'Order Channel',
                          child: AppTextField(
                            controller: _channelController,
                            hintText: 'Select channels',
                            prefixIcon: Icons.storefront_outlined,
                            height: 34,
                            onChanged: (value) => _filters = _filters.copyWith(
                              orderChannel: value,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: ShipKiaSpacing.sm),
                      Expanded(
                        child: _FilterSection(
                          title: 'Pickup Address',
                          child: AppTextField(
                            controller: _pickupController,
                            hintText: 'Select pickup addresses',
                            prefixIcon: Icons.warehouse_outlined,
                            height: 34,
                            onChanged: (value) => _filters = _filters.copyWith(
                              pickupAddress: value,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  _FilterSection(
                    icon: Icons.location_on_outlined,
                    title: 'Destination',
                    child: Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _cityController,
                            hintText: 'City',
                            height: 36,
                            onChanged: (value) =>
                                _filters = _filters.copyWith(city: value),
                          ),
                        ),
                        const SizedBox(width: ShipKiaSpacing.sm),
                        Expanded(
                          child: AppTextField(
                            controller: _pincodeController,
                            hintText: 'Pincode',
                            keyboardType: TextInputType.number,
                            height: 36,
                            onChanged: (value) =>
                                _filters = _filters.copyWith(pincode: value),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 28),
                  _FilterSection(
                    title: 'Advanced',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 9,
                              child: _SelectBox(
                                value: _filters.advancedField,
                                values: const [
                                  'id',
                                  'awb',
                                  'delivery_phone',
                                  'customer_id',
                                ],
                                onChanged: (value) {
                                  if (value == null) return;
                                  setState(() {
                                    _filters = _filters.copyWith(
                                      advancedField: value,
                                    );
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: ShipKiaSpacing.xs),
                            Expanded(
                              flex: 7,
                              child: _SelectBox(
                                value: _filters.advancedOperator,
                                values: const ['contains', '=', '!='],
                                onChanged: (value) {
                                  if (value == null) return;
                                  setState(() {
                                    _filters = _filters.copyWith(
                                      advancedOperator: value,
                                    );
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: ShipKiaSpacing.xs),
                            Expanded(
                              flex: 8,
                              child: AppTextField(
                                controller: _advancedController,
                                hintText: 'Value',
                                height: 34,
                                onChanged: (value) => _filters = _filters
                                    .copyWith(advancedValue: value),
                              ),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            minimumSize: const Size(0, 32),
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            visualDensity: VisualDensity.compact,
                          ),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add a Filter'),
                          onPressed: () {
                            FocusScope.of(context).nextFocus();
                            setState(() {
                              _filters = _filters.copyWith(
                                advancedValue: _advancedController.text,
                              );
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Reset',
                      icon: Icons.restart_alt,
                      variant: AppButtonVariant.secondary,
                      onPressed: () {
                        setState(() {
                          _filters = const OrderListFilters();
                          _channelController.clear();
                          _pickupController.clear();
                          _cityController.clear();
                          _pincodeController.clear();
                          _advancedController.clear();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: ShipKiaSpacing.sm),
                  Expanded(
                    child: AppButton(
                      label: 'Apply',
                      icon: Icons.check,
                      onPressed: () => Navigator.of(context).pop(_filters),
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

class _FilterSection extends StatelessWidget {
  const _FilterSection({required this.title, required this.child, this.icon});

  final String title;
  final Widget child;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ShipKiaSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 15, color: ShipKiaColors.shipkiaBlue),
                const SizedBox(width: 5),
              ],
              Text(
                title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: ShipKiaColors.textSecondary(context),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          child,
        ],
      ),
    );
  }
}

class _ChipWrap extends StatelessWidget {
  const _ChipWrap({
    required this.values,
    required this.selected,
    required this.onChanged,
    this.icons = const {},
    this.singleSelect = false,
  });

  final Map<String, String> values;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;
  final Map<String, IconData> icons;
  final bool singleSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: ShipKiaSpacing.xs,
      runSpacing: ShipKiaSpacing.sm,
      children: [
        for (final entry in values.entries)
          _FilterChip(
            label: entry.value,
            icon: icons[entry.key],
            selected: selected.contains(entry.key),
            onTap: () {
              final next = singleSelect
                  ? <String>{}
                  : Set<String>.from(selected);
              if (!next.add(entry.key)) next.remove(entry.key);
              onChanged(next);
            },
          ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final foreground = selected
        ? ShipKiaColors.shipkiaBlue
        : ShipKiaColors.textPrimary(context);
    return Material(
      color: selected
          ? ShipKiaColors.shipkiaBlue.withValues(alpha: 0.09)
          : ShipKiaColors.surface(context),
      borderRadius: ShipKiaRadius.smBorder,
      child: InkWell(
        onTap: onTap,
        borderRadius: ShipKiaRadius.smBorder,
        child: Container(
          constraints: const BoxConstraints(minHeight: 30),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: ShipKiaRadius.smBorder,
            border: Border.all(
              color: selected
                  ? ShipKiaColors.shipkiaBlue
                  : ShipKiaColors.border(context),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: foreground),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(color: foreground, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectBox extends StatelessWidget {
  const _SelectBox({
    required this.values,
    required this.onChanged,
    this.value,
    this.hint,
  });

  final String? value;
  final String? hint;
  final List<String> values;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      items: [
        for (final value in values)
          DropdownMenuItem<String>(value: value, child: Text(value)),
      ],
      onChanged: onChanged,
      style: Theme.of(context).textTheme.bodySmall,
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        filled: true,
        fillColor: ShipKiaColors.surface(context),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      ),
    );
  }
}
