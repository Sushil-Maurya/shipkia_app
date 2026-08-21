import 'package:flutter/material.dart';

import '../../data/shipkia_mock_data.dart';
import '../../theme/shipkia_colors.dart';
import '../../widgets/shipkia_widgets.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({required this.order, super.key});

  final OrderSummary order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(order.id)),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.support_agent, size: 18),
                  label: const Text('Raise ticket'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.local_shipping_outlined, size: 18),
                  label: const Text('Ship now'),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ShipKiaColors.paper,
              border: Border.all(color: ShipKiaColors.neutralBorder),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        order.customer,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    SkStatusBadge(status: order.status),
                  ],
                ),
                const SizedBox(height: 12),
                _DetailLine(label: 'AWB', value: order.awb),
                _DetailLine(label: 'Courier', value: order.courier),
                _DetailLine(label: 'Destination', value: order.city),
                _DetailLine(
                  label: 'Payment',
                  value:
                      '${order.paymentMode} - Rs ${order.amount.toStringAsFixed(0)}',
                ),
              ],
            ),
          ),
          const SkSectionHeader(title: 'Shipment Journey'),
          const _TimelineItem(
            title: 'Order created',
            meta: '17 Aug, 10:15 AM',
            done: true,
          ),
          const _TimelineItem(
            title: 'Courier allocation pending',
            meta: 'Ready to ship',
            done: false,
          ),
          const _TimelineItem(
            title: 'Pickup scheduled',
            meta: 'Awaiting action',
            done: false,
          ),
          const SkSectionHeader(title: 'Actions'),
          _ActionTile(
            icon: Icons.print_outlined,
            label: 'Download label',
            onTap: () {},
          ),
          _ActionTile(
            icon: Icons.sync,
            label: 'Sync order status',
            onTap: () {},
          ),
          _ActionTile(
            icon: Icons.cancel_outlined,
            label: 'Cancel order',
            danger: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(color: ShipKiaColors.mutedInk),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.title,
    required this.meta,
    required this.done,
  });

  final String title;
  final String meta;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(
        done ? Icons.check_circle : Icons.radio_button_unchecked,
        color: done ? ShipKiaColors.success : ShipKiaColors.mutedInk,
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(meta),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? ShipKiaColors.destructive : ShipKiaColors.ink;
    return ListTile(
      dense: true,
      onTap: onTap,
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
      trailing: const Icon(Icons.chevron_right, size: 18),
    );
  }
}
