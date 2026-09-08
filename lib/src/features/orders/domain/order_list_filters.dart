class OrderListFilters {
  const OrderListFilters({
    this.quickPicks = const <String>{},
    this.status,
    this.deliveryDetails = const <String>{},
    this.city,
    this.pincode,
    this.advancedField = 'id',
    this.advancedOperator = 'contains',
    this.advancedValue,
  });

  final Set<String> quickPicks;
  final String? status;
  final Set<String> deliveryDetails;
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
        (_hasText(city) ? 1 : 0) +
        (_hasText(pincode) ? 1 : 0) +
        (_hasText(advancedValue) ? 1 : 0);
  }

  OrderListFilters copyWith({
    Set<String>? quickPicks,
    Object? status = _sentinel,
    Set<String>? deliveryDetails,
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
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      advancedField: advancedField ?? this.advancedField,
      advancedOperator: advancedOperator ?? this.advancedOperator,
      advancedValue: advancedValue ?? this.advancedValue,
    );
  }

  Object? toPayload({String? stage, String? search, DateTime? now}) {
    final filterSet = <Map<String, dynamic>>[];
    if (_hasText(stage) && stage != 'All') {
      filterSet.add({'id': 'stage', 'opr': '=', 'value': stage});
    }

    for (final quickPick in quickPicks) {
      final filter = _quickPickFilter(quickPick, now ?? DateTime.now());
      if (filter != null) filterSet.add(filter);
    }

    if (_hasText(status)) {
      filterSet.add({
        'id': 'stage',
        'opr': 'in',
        'value': [status],
      });
    }
    for (final value in deliveryDetails) {
      final filter = _deliveryFilter(value);
      if (filter != null) filterSet.add(filter);
    }
    if (_hasText(city)) {
      filterSet.add({
        'id': 'delivery_city',
        'opr': 'contains',
        'value': city!.trim(),
      });
    }
    if (_hasText(pincode)) {
      filterSet.add({
        'id': 'delivery_postal_code',
        'opr': 'contains',
        'value': pincode!.trim(),
      });
    }
    if (_hasText(advancedValue)) {
      filterSet.add({
        'id': advancedField,
        'opr': advancedOperator,
        'value': advancedValue,
      });
    }

    if (_hasText(search)) {
      filterSet.add({
        'id': 'flt_order_search',
        'type': 'nested',
        'connector': 'or',
        'filterSet': [
          for (final field in const ['awb', 'delivery_phone'])
            {'id': field, 'opr': 'contains', 'value': search!.trim()},
        ],
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
      city ?? '',
      pincode ?? '',
      advancedField,
      advancedOperator,
      advancedValue ?? '',
    ].join('|');
  }

  static bool _hasText(String? value) =>
      value != null && value.trim().isNotEmpty;

  Map<String, dynamic>? _quickPickFilter(String value, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    return switch (value) {
      'today' => {
        'id': 'created_at',
        'opr': '>=',
        'value': today.toUtc().toIso8601String(),
      },
      'last_7_days' => {
        'id': 'created_at',
        'opr': '>=',
        'value': DateTime(
          now.year,
          now.month,
          now.day - 6,
        ).toUtc().toIso8601String(),
      },
      'missing_awb' => {'id': 'awb', 'opr': 'is', 'value': false},
      'no_courier' => {'id': 'courier_partner', 'opr': 'is', 'value': false},
      _ => null,
    };
  }

  Map<String, dynamic>? _deliveryFilter(String value) {
    return switch (value) {
      'COD' || 'Prepaid' => {
        'id': 'payment_method',
        'opr': '=',
        'value': value.toLowerCase(),
      },
      _ => null,
    };
  }
}

const Object _sentinel = Object();
