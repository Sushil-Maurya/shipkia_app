import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/api/api.dart';
import '../../core/router/navigation_service.dart';
import '../../core/router/route_state_reader.dart';
import '../../data/shipkia_mock_data.dart';
import '../../design_system/design_system.dart';
import '../../theme/shipkia_colors.dart';
import '../../widgets/shipkia_shell_widgets.dart';
import '../../widgets/shipkia_widgets.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({this.query = const OrdersRouteQuery(), super.key});

  final OrdersRouteQuery query;

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String? _lastRequestKey;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadIfNeeded();
  }

  @override
  void didUpdateWidget(OrdersScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadIfNeeded();
  }

  void _loadIfNeeded() {
    final apiClient = ShipKiaApiScope.maybeOf(context);
    if (apiClient == null) return;
    final key =
        '${widget.query.status}|${widget.query.search}|${widget.query.sort}';
    if (_lastRequestKey == key) return;
    _lastRequestKey = key;
    unawaited(_loadLiveOrders(apiClient));
  }

  Future<void> _loadLiveOrders(ApiClient apiClient) async {
    final params = <String, dynamic>{
      if (widget.query.status != null) 'status': widget.query.status,
      if (widget.query.search?.isNotEmpty == true)
        'search': widget.query.search,
      'sort': widget.query.sort,
    };

    try {
      await apiClient.request<Object?>(
        ApiRequestConfig(
          method: HttpMethod.get,
          path: ApiEndpoints.orders.list,
          params: params,
          showSuccessMessage: false,
          showErrorMessage: false,
        ),
      );
    } catch (_) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedStatus = widget.query.status;

    return Column(
      children: [
        ShipKiaCommandBar(
          hint: widget.query.search?.isNotEmpty == true
              ? widget.query.search!
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
                '${orders.length} records - ${widget.query.sort}',
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
