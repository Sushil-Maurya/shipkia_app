import 'package:flutter/material.dart';

import '../../core/router/navigation_service.dart';
import '../../core/router/route_state_reader.dart';
import '../../data/shipkia_mock_data.dart';
import '../../design_system/design_system.dart';
import '../../theme/shipkia_colors.dart';
import '../../widgets/shipkia_shell_widgets.dart';
import '../../widgets/shipkia_widgets.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({this.query = const OrdersRouteQuery(), super.key});

  final OrdersRouteQuery query;

  @override
  Widget build(BuildContext context) {
    final selectedStatus = query.status;

    return Column(
      children: [
        ShipKiaCommandBar(
          hint: query.search?.isNotEmpty == true
              ? query.search!
              : 'Search by order, AWB, customer',
          trailing: AppButton(label: 'Add', icon: Icons.add, onPressed: () {}),
        ),
        SizedBox(
          height: 42,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            scrollDirection: Axis.horizontal,
            children: [
              AppChip(
                label: 'All',
                selected: selectedStatus == null,
                onSelected: (_) => context.toOrders(),
              ),
              AppChip(
                label: 'Ready',
                selected: selectedStatus == 'ready',
                onSelected: (_) => context.toOrders(status: 'ready'),
              ),
              AppChip(
                label: 'In Transit',
                selected: selectedStatus == 'in-transit',
                onSelected: (_) => context.toOrders(status: 'in-transit'),
              ),
              AppChip(
                label: 'NDR',
                selected: selectedStatus == 'ndr',
                onSelected: (_) => context.toOrders(status: 'ndr'),
              ),
              AppChip(
                label: 'Delivered',
                selected: selectedStatus == 'delivered',
                onSelected: (_) => context.toOrders(status: 'delivered'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Text(
                '${orders.length} records - ${query.sort}',
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
                        onTap: () =>
                            context.toOrderDetails(order.id, order: order),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}
