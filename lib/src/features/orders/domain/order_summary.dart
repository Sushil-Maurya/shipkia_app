enum ShipmentStatus {
  unknown,
  newOrder,
  readyToShip,
  readyToPickup,
  inTransit,
  delivered,
  ndr,
  rto,
  cancelled,
}

class OrderSummary {
  const OrderSummary({
    required this.id,
    required this.awb,
    required this.customer,
    required this.city,
    required this.courier,
    required this.paymentMode,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.recordId,
    this.stage,
    this.hasCreatedAt = true,
  });

  final String? recordId;
  final String? stage;
  final bool hasCreatedAt;
  String get key => recordId ?? id;
  String get stageLabel => stage ?? statusLabel(status);

  final String id;
  final String awb;
  final String customer;
  final String city;
  final String courier;
  final String paymentMode;
  final double amount;
  final ShipmentStatus status;
  final DateTime createdAt;

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    return OrderSummary(
      recordId: _firstString(json, const ['name', 'id', 'row_id']),
      stage: _firstString(json, const ['stage', 'status']) ?? 'Unknown',
      hasCreatedAt:
          _firstDate(json, const [
            'created_at',
            'createdAt',
            'order_date',
            'orderDate',
            'date',
          ]) !=
          null,
      id: _firstString(json, const [
        'id',
        'order_id',
        'orderId',
        'reference_id',
        'referenceId',
        'name',
        'row_id',
      ], fallback: 'Order')!,
      awb: _firstString(json, const [
        'awb',
        'awb_number',
        'awbNumber',
        'waybill',
        'tracking_number',
        'trackingNumber',
      ], fallback: '-')!,
      customer: _firstString(json, const [
        'delivery_full_name',
        'customer',
        'customer_name',
        'customerName',
        'buyer_name',
        'buyerName',
        'consignee',
        'consignee_name',
        'recipient_name',
        'recipientName',
      ], fallback: 'Customer')!,
      city:
          _firstString(json, const [
            'delivery_city',
            'city',
            'destination_city',
            'destinationCity',
            'shipping_city',
            'shippingCity',
          ]) ??
          _firstNestedString(
            json,
            const [
              'shipping_address',
              'shippingAddress',
              'delivery_address',
              'deliveryAddress',
              'customer',
            ],
            const ['city', 'name'],
          ) ??
          '-',
      courier: _firstString(json, const [
        'courier',
        'courier_name',
        'courierName',
        'courier_partner',
        'courierPartner',
        'shipping_partner',
        'shippingPartner',
      ], fallback: '-')!,
      paymentMode: _paymentMode(json),
      amount: _firstDouble(json, const [
        'total_order_value',
        'amount',
        'total',
        'total_amount',
        'totalAmount',
        'order_amount',
        'orderAmount',
        'invoice_value',
        'invoiceValue',
      ]),
      status: _shipmentStatus(
        _firstString(json, const [
          'stage',
          'status',
          'order_status',
          'orderStatus',
          'shipment_status',
          'shipmentStatus',
          'delivery_status',
          'deliveryStatus',
        ]),
      ),
      createdAt:
          _firstDate(json, const [
            'created_at',
            'createdAt',
            'order_date',
            'orderDate',
            'date',
          ]) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

String statusLabel(ShipmentStatus status) {
  switch (status) {
    case ShipmentStatus.unknown:
      return 'Unknown';
    case ShipmentStatus.newOrder:
      return 'New';
    case ShipmentStatus.readyToShip:
      return 'Ready to Ship';
    case ShipmentStatus.readyToPickup:
      return 'Ready to Pickup';
    case ShipmentStatus.inTransit:
      return 'In Transit';
    case ShipmentStatus.delivered:
      return 'Delivered';
    case ShipmentStatus.ndr:
      return 'NDR';
    case ShipmentStatus.rto:
      return 'RTO';
    case ShipmentStatus.cancelled:
      return 'Cancelled';
  }
}

String? _firstString(
  Map<String, dynamic> json,
  List<String> keys, {
  String? fallback,
}) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return fallback;
}

String? _firstNestedString(
  Map<String, dynamic> json,
  List<String> parentKeys,
  List<String> childKeys,
) {
  for (final parentKey in parentKeys) {
    final value = json[parentKey];
    if (value is! Map) continue;
    final text = _firstString(Map<String, dynamic>.from(value), childKeys);
    if (text != null && text.trim().isNotEmpty) return text;
  }
  return null;
}

double _firstDouble(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value.replaceAll(',', '').trim());
      if (parsed != null) return parsed;
    }
  }
  return 0;
}

DateTime? _firstDate(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is DateTime) return value;
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
    }
  }
  return null;
}

String _paymentMode(Map<String, dynamic> json) {
  final direct = _firstString(json, const [
    'payment_method',
    'payment_mode',
    'paymentMode',
    'payment_type',
    'paymentType',
    'mode',
  ]);
  if (direct != null) {
    return switch (direct.toLowerCase()) {
      'cod' => 'COD',
      'prepaid' => 'Prepaid',
      _ => direct,
    };
  }
  final cod = json['cod'] ?? json['is_cod'] ?? json['isCod'];
  if (cod == true || cod?.toString().toLowerCase() == 'true') return 'COD';
  return '-';
}

ShipmentStatus _shipmentStatus(String? value) {
  final normalized = (value ?? '').toLowerCase().replaceAll(
    RegExp(r'[^a-z]'),
    '',
  );
  if (normalized.contains('rto')) return ShipmentStatus.rto;
  if (normalized.contains('ndr') ||
      normalized.contains('attempt') ||
      normalized.contains('undelivered')) {
    return ShipmentStatus.ndr;
  }
  if (normalized == 'new') return ShipmentStatus.newOrder;
  if (normalized.contains('readytopickup')) {
    return ShipmentStatus.readyToPickup;
  }
  if (normalized.contains('readytoship')) {
    return ShipmentStatus.readyToShip;
  }
  if (normalized.contains('transit') ||
      normalized.contains('shipped') ||
      normalized.contains('pickup')) {
    return ShipmentStatus.inTransit;
  }
  if (normalized == 'delivered') return ShipmentStatus.delivered;
  if (normalized.contains('cancel')) return ShipmentStatus.cancelled;
  return ShipmentStatus.unknown;
}
