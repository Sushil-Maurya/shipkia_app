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
      onRefresh: () async => Future<void>.delayed(ShipKiaMotion.refresh),
      child: ListView(
        children: [
          ShipKiaCommandBar(
            hint: 'Search orders, AWB, customers',
            trailing: AppIconButton(
              icon: Icons.tune,
              onPressed: () => showAppBottomSheet<void>(
                context: context,
                builder: (_) => const _HomeFiltersSheet(),
              ),
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
                shipKiaRoute<void>(
                  builder: (_) => OrderDetailScreen(order: order),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HomeFiltersSheet extends StatelessWidget {
  const _HomeFiltersSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ShipKiaSpacing.lg,
        0,
        ShipKiaSpacing.lg,
        ShipKiaSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Filters (3)',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              AppIconButton(
                icon: Icons.close,
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Close filters',
              ),
            ],
          ),
          const SizedBox(height: ShipKiaSpacing.md),
          Text(
            'Shipment Status',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: ShipKiaSpacing.sm),
          Wrap(
            children: [
              AppChip(label: 'Ready', selected: true, onSelected: (_) {}),
              AppChip(label: 'In Transit', selected: true, onSelected: (_) {}),
              AppChip(label: 'NDR', onSelected: (_) {}),
              AppChip(label: 'Delivered', onSelected: (_) {}),
            ],
          ),
          const SizedBox(height: ShipKiaSpacing.lg),
          Text('Courier', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: ShipKiaSpacing.sm),
          Wrap(
            children: [
              AppChip(label: 'Delhivery', selected: true, onSelected: (_) {}),
              AppChip(label: 'Blue Dart', onSelected: (_) {}),
              AppChip(label: 'Xpressbees', onSelected: (_) {}),
            ],
          ),
          const SizedBox(height: ShipKiaSpacing.xl),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Clear',
                  onPressed: () {},
                  variant: AppButtonVariant.secondary,
                ),
              ),
              const SizedBox(width: ShipKiaSpacing.sm),
              Expanded(
                child: AppButton(
                  label: 'Apply filters',
                  icon: Icons.check,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
