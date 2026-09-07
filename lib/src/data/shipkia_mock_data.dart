import 'package:flutter/material.dart';

enum ShipmentStatus { readyToShip, inTransit, delivered, ndr, cancelled }

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
  });

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
      id: _firstString(json, const [
        'id',
        'order_id',
        'orderId',
        'reference_id',
        'referenceId',
        'name',
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
          DateTime.now(),
    );
  }
}

class MetricSummary {
  const MetricSummary({
    required this.label,
    required this.value,
    required this.delta,
    required this.icon,
  });

  final String label;
  final String value;
  final String delta;
  final IconData icon;
}

const primaryModules = [
  'Returns',
  'Pickup and Manifest',
  'Invoices',
  'Support',
  'Tools',
  'Channels',
  'Remittance',
  'Settings',
  'Help',
];

final metrics = [
  const MetricSummary(
    label: 'Orders Today',
    value: '142',
    delta: '+18%',
    icon: Icons.inventory_2_outlined,
  ),
  const MetricSummary(
    label: 'Ready to Ship',
    value: '37',
    delta: '12 urgent',
    icon: Icons.local_shipping_outlined,
  ),
  const MetricSummary(
    label: 'NDR Open',
    value: '19',
    delta: '-6%',
    icon: Icons.report_problem_outlined,
  ),
  const MetricSummary(
    label: 'Wallet',
    value: 'Rs 82.4k',
    delta: 'healthy',
    icon: Icons.account_balance_wallet_outlined,
  ),
];

final orders = [
  OrderSummary(
    id: 'ORD-10491',
    awb: 'SKA784950213',
    customer: 'Aarav Textiles',
    city: 'Delhi',
    courier: 'Blue Dart',
    paymentMode: 'COD',
    amount: 2499,
    status: ShipmentStatus.readyToShip,
    createdAt: DateTime(2026, 8, 17, 10, 15),
  ),
  OrderSummary(
    id: 'ORD-10490',
    awb: 'SKA784950112',
    customer: 'Meera Home Store',
    city: 'Pune',
    courier: 'Delhivery',
    paymentMode: 'Prepaid',
    amount: 1199,
    status: ShipmentStatus.inTransit,
    createdAt: DateTime(2026, 8, 17, 9, 40),
  ),
  OrderSummary(
    id: 'ORD-10489',
    awb: 'SKA784949902',
    customer: 'Kia Fashion Co.',
    city: 'Bengaluru',
    courier: 'Ecom Express',
    paymentMode: 'COD',
    amount: 3499,
    status: ShipmentStatus.ndr,
    createdAt: DateTime(2026, 8, 16, 18, 20),
  ),
  OrderSummary(
    id: 'ORD-10488',
    awb: 'SKA784949600',
    customer: 'North Star Retail',
    city: 'Mumbai',
    courier: 'Xpressbees',
    paymentMode: 'Prepaid',
    amount: 899,
    status: ShipmentStatus.delivered,
    createdAt: DateTime(2026, 8, 16, 15, 05),
  ),
];

String statusLabel(ShipmentStatus status) {
  switch (status) {
    case ShipmentStatus.readyToShip:
      return 'Ready to Ship';
    case ShipmentStatus.inTransit:
      return 'In Transit';
    case ShipmentStatus.delivered:
      return 'Delivered';
    case ShipmentStatus.ndr:
      return 'NDR';
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
    'payment_mode',
    'paymentMode',
    'payment_type',
    'paymentType',
    'mode',
  ]);
  if (direct != null) return direct;
  final cod = json['cod'] ?? json['is_cod'] ?? json['isCod'];
  if (cod == true || cod?.toString().toLowerCase() == 'true') return 'COD';
  return '-';
}

ShipmentStatus _shipmentStatus(String? value) {
  final normalized = (value ?? '').toLowerCase().replaceAll(
    RegExp(r'[^a-z]'),
    '',
  );
  if (normalized.contains('ndr') ||
      normalized.contains('attempt') ||
      normalized.contains('rto') ||
      normalized.contains('undelivered')) {
    return ShipmentStatus.ndr;
  }
  if (normalized == 'new' || normalized.contains('readytoship')) {
    return ShipmentStatus.readyToShip;
  }
  if (normalized.contains('transit') ||
      normalized.contains('shipped') ||
      normalized.contains('pickup')) {
    return ShipmentStatus.inTransit;
  }
  if (normalized.contains('deliver')) return ShipmentStatus.delivered;
  if (normalized.contains('cancel')) return ShipmentStatus.cancelled;
  return ShipmentStatus.readyToShip;
}
