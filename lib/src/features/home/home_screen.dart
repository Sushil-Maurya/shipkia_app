import 'package:flutter/material.dart';

import '../../data/shipkia_mock_data.dart';
import '../../design_system/design_system.dart';
import '../../theme/shipkia_colors.dart';
import '../../widgets/shipkia_shell_widgets.dart';
import '../../widgets/shipkia_widgets.dart';
import '../orders/order_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async =>
          Future<void>.delayed(const Duration(milliseconds: 450)),
      child: ListView(
        children: [
          ShipKiaCommandBar(
            hint: 'Search orders, AWB, customers',
            trailing: AppIconButton(
              icon: Icons.tune,
              onPressed: () {},
              tooltip: 'Filters',
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Dispatch Console',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                const SkSetupChip(),
              ],
            ),
          ),
          SizedBox(
            height: 112,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) => SizedBox(
                width: 152,
                child: SkMetricTile(metric: metrics[index]),
              ),
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemCount: metrics.length,
            ),
          ),
          SkSectionHeader(
            title: 'Priority Orders',
            action: Text(
              'View all',
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(color: ShipKiaColors.shipkiaBlue),
            ),
          ),
          for (final order in orders.take(3))
            SkOrderRow(
              order: order,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => OrderDetailScreen(order: order),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
