import 'package:flutter/material.dart';

import '../../data/shipkia_mock_data.dart';
import '../../design_system/design_system.dart';
import '../../theme/shipkia_colors.dart';
import '../../widgets/shipkia_widgets.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({required this.order, super.key});

  final OrderSummary order;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: order.id,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Raise ticket',
                  icon: Icons.support_agent,
                  onPressed: () {},
                  variant: AppButtonVariant.secondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  label: 'Ship now',
                  icon: Icons.local_shipping_outlined,
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          AppCard(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Order Details',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    SkStatusBadge(status: order.status),
                  ],
                ),
                const SizedBox(height: 12),
                _DetailFieldGrid(
                  fields: [
                    _DetailFieldData(label: 'Customer', value: order.customer),
                    _DetailFieldData(label: 'Order ID', value: order.id),
                    _DetailFieldData(label: 'AWB', value: order.awb),
                    _DetailFieldData(label: 'Courier', value: order.courier),
                    _DetailFieldData(label: 'Destination', value: order.city),
                    _DetailFieldData(
                      label: 'Payment Mode',
                      value: order.paymentMode,
                    ),
                    _DetailFieldData(
                      label: 'Amount',
                      value: 'Rs ${order.amount.toStringAsFixed(0)}',
                    ),
                    _DetailFieldData(
                      label: 'Created At',
                      value: _formatCreatedAt(order.createdAt),
                    ),
                  ],
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

  String _formatCreatedAt(DateTime value) {
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.hour >= 12 ? 'PM' : 'AM';
    return '${value.day} Aug ${value.year}, $hour:$minute $period';
  }
}

class _DetailFieldData {
  const _DetailFieldData({required this.label, required this.value});

  final String label;
  final String value;
}

class _DetailFieldGrid extends StatelessWidget {
  const _DetailFieldGrid({required this.fields});

  final List<_DetailFieldData> fields;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 560;
        final fieldWidth = isWide
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: fields
              .map(
                (field) => SizedBox(
                  width: fieldWidth,
                  child: AppTextField(
                    label: field.label,
                    initialValue: field.value,
                    readOnly: true,
                  ),
                ),
              )
              .toList(),
        );
      },
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
    return AppListTile(
      leading: Icon(
        done ? Icons.check_circle : Icons.radio_button_unchecked,
        color: done ? ShipKiaColors.success : ShipKiaColors.mutedInk,
      ),
      title: title,
      subtitle: meta,
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
    return AppListTile(
      onTap: onTap,
      leading: Icon(icon, color: color),
      title: label,
      destructive: danger,
      trailing: const Icon(Icons.chevron_right, size: 18),
    );
  }
}
