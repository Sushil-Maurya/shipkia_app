import 'package:flutter/material.dart';

import '../../data/shipkia_mock_data.dart';
import '../../design_system/design_system.dart';
import '../../theme/shipkia_colors.dart';
import '../../widgets/shipkia_widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: GridView.builder(
            itemCount: metrics.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.48,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (_, index) => SkMetricTile(metric: metrics[index]),
          ),
        ),
        const SkSectionHeader(title: 'Operational Alerts'),
        const _AlertRow(
          icon: Icons.inventory_outlined,
          title: '37 orders are ready for courier allocation',
          meta: 'Ship now or bulk schedule pickup',
        ),
        const _AlertRow(
          icon: Icons.report_problem_outlined,
          title: '8 NDR records need buyer response',
          meta: 'Oldest pending since 16 Aug',
        ),
        const _AlertRow(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Wallet threshold is healthy',
          meta: 'Estimated 4.2 days of shipping balance',
        ),
        const SkSectionHeader(title: 'Overview Tabs'),
        const _TabPreview(
          label: 'Orders Overview',
          value: '142 orders, 37 pending shipment',
        ),
        const _TabPreview(
          label: 'NDR Overview',
          value: '19 open, 5 reattempt scheduled',
        ),
        const _TabPreview(
          label: 'Shipment Overview',
          value: '82 in transit, 61 delivered',
        ),
        const _TabPreview(
          label: 'Confirmation Overview',
          value: '14 COD orders awaiting confirmation',
        ),
      ],
    );
  }
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({
    required this.icon,
    required this.title,
    required this.meta,
  });

  final IconData icon;
  final String title;
  final String meta;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      padding: EdgeInsets.zero,
      child: AppListTile(
        leading: Icon(icon, color: ShipKiaColors.shipkiaBlue),
        title: title,
        subtitle: meta,
        trailing: const Icon(Icons.chevron_right, size: 18),
      ),
    );
  }
}

class _TabPreview extends StatelessWidget {
  const _TabPreview({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      title: label,
      subtitle: value,
      trailing: const Icon(Icons.chevron_right, size: 18),
    );
  }
}
