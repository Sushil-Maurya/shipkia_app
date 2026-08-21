import 'package:flutter/material.dart';

import '../data/shipkia_mock_data.dart';
import '../design_system/design_system.dart';
import '../theme/shipkia_colors.dart';

class SkSectionHeader extends StatelessWidget {
  const SkSectionHeader({required this.title, this.action, super.key});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          ?action,
        ],
      ),
    );
  }
}

class SkSetupChip extends StatelessWidget {
  const SkSetupChip({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ShipKiaColors.shipkiaBlue.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: ShipKiaColors.shipkiaBlue.withValues(alpha: 0.18),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.verified_outlined,
              size: 14,
              color: ShipKiaColors.shipkiaBlue,
            ),
            const SizedBox(width: 5),
            Text(
              'SETUP 78%',
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(color: ShipKiaColors.shipkiaBlue),
            ),
          ],
        ),
      ),
    );
  }
}

class SkStatusBadge extends StatelessWidget {
  const SkStatusBadge({required this.status, super.key});

  final ShipmentStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      ShipmentStatus.readyToShip => ShipKiaColors.shipkiaBlue,
      ShipmentStatus.inTransit => ShipKiaColors.warning,
      ShipmentStatus.delivered => ShipKiaColors.success,
      ShipmentStatus.ndr => ShipKiaColors.destructive,
      ShipmentStatus.cancelled => ShipKiaColors.mutedInk,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        child: Text(
          statusLabel(status).toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
        ),
      ),
    );
  }
}

class SkMetricTile extends StatelessWidget {
  const SkMetricTile({required this.metric, super.key});

  final MetricSummary metric;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ShipKiaColors.paper,
        border: Border.all(color: ShipKiaColors.neutralBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(metric.icon, size: 18, color: ShipKiaColors.shipkiaBlue),
                const Spacer(),
                Text(
                  metric.delta,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
            const Spacer(),
            Text(
              metric.value,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontSize: 17),
            ),
            const SizedBox(height: 2),
            Text(
              metric.label,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: ShipKiaColors.mutedInk),
            ),
          ],
        ),
      ),
    );
  }
}

class SkOrderRow extends StatelessWidget {
  const SkOrderRow({required this.order, required this.onTap, super.key});

  final OrderSummary order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: ShipKiaColors.paper,
          border: Border.all(color: ShipKiaColors.neutralBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 9, 8, 9),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: ShipKiaColors.neutralMuted,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: ShipKiaColors.neutralBorder),
                      ),
                      child: const Icon(
                        Icons.inventory_2_outlined,
                        color: ShipKiaColors.shipkiaBlue,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  order.id,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                              ),
                              SkStatusBadge(status: order.status),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${order.customer} - ${order.city}',
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: ShipKiaColors.mutedInk),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                const Divider(),
                const SizedBox(height: 7),
                Row(
                  children: [
                    _Meta(label: 'AWB', value: order.awb),
                    _Meta(label: 'Courier', value: order.courier),
                    _Meta(
                      label: order.paymentMode,
                      value: 'Rs ${order.amount.toStringAsFixed(0)}',
                    ),
                    AppIconButton(
                      icon: Icons.more_vert,
                      onPressed: () {},
                      tooltip: 'Row actions',
                      size: 28,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: ShipKiaColors.mutedInk),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
