import 'package:flutter/material.dart';

import '../features/orders/domain/order_summary.dart';
export '../features/orders/domain/order_summary.dart';

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
