import 'package:flutter/material.dart';

import '../../data/shipkia_mock_data.dart';
import '../../design_system/design_system.dart';
import '../../theme/shipkia_colors.dart';
import '../../widgets/shipkia_shell_widgets.dart';
import '../../widgets/shipkia_widgets.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShipKiaCommandBar(
          hint: 'Search by order, AWB, customer',
          trailing: AppButton(label: 'Add', icon: Icons.add, onPressed: () {}),
        ),
        SizedBox(
          height: 42,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            scrollDirection: Axis.horizontal,
            children: [
              AppChip(label: 'All', selected: true, onSelected: (_) {}),
              AppChip(label: 'Ready', onSelected: (_) {}),
              AppChip(label: 'In Transit', onSelected: (_) {}),
              AppChip(label: 'NDR', onSelected: (_) {}),
              AppChip(label: 'Delivered', onSelected: (_) {}),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Text(
                '${orders.length} records',
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(color: ShipKiaColors.mutedInk),
              ),
              const Spacer(),
              AppButton(
                label: 'Export',
                icon: Icons.file_download_outlined,
                onPressed: () {},
                variant: AppButtonVariant.secondary,
              ),
            ],
          ),
        ),
        Expanded(
          child: orders.isEmpty
              ? const AppEmptyState(
                  title: 'No orders yet',
                  message: 'Create or import orders and they will appear here with shipment status.',
                  actionLabel: 'Create order',
                )
              : AppStaggeredList(
                  children: [
                    for (final order in orders)
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
        ),
      ],
    );
  }
}
