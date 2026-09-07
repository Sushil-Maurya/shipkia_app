import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/api/api.dart';
import '../../core/api/api_record_parser.dart';
import '../../core/router/navigation_service.dart';
import '../../core/router/route_state_reader.dart';
import '../../core/router/web_module_catalog.dart';
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
  List<OrderSummary>? _liveOrders;
  int? _liveTotal;
  bool _loading = false;

  static const _stageTabs = <String>[
    'New',
    'Ready to Ship',
    'Ready to Pickup',
    'In-Transit',
    'Delivered',
    'Cancelled',
    'RTO',
    'All',
  ];

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
    final key = '${widget.query.stage}|${widget.query.search}';
    if (_lastRequestKey == key) return;
    _lastRequestKey = key;
    setState(() => _loading = true);
    unawaited(_loadLiveOrders(apiClient));
  }

  Future<void> _loadLiveOrders(ApiClient apiClient) async {
    final stage = widget.query.stage;
    final params = <String, dynamic>{
      'page': '1',
      'rows': '20',
      if (widget.query.search?.isNotEmpty == true)
        'search': widget.query.search,
    };

    try {
      final data = await apiClient.request<Object?>(
        ApiRequestConfig(
          method: HttpMethod.post,
          path: WebModuleCatalog.listEndpointFor('orders'),
          data: _stageFilterPayload(stage),
          params: params,
          showSuccessMessage: false,
          showErrorMessage: false,
        ),
      );
      final rows = extractApiRecords(data);
      if (!mounted) return;
      setState(() {
        _liveOrders = rows.map(OrderSummary.fromJson).toList();
        _liveTotal = extractApiRecordTotal(data) ?? _liveOrders?.length;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedStage = widget.query.stage ?? 'All';
    final visibleOrders = _filteredOrders(_liveOrders ?? orders);
    final totalRecords = _liveTotal ?? visibleOrders.length;

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
              for (final stage in _stageTabs)
                AppChip(
                  label: stage,
                  selected: selectedStage == stage,
                  onSelected: (_) => context.toOrders(stage: stage),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Text(
                '$totalRecords records',
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
          child: _loading && _liveOrders == null
              ? const Center(child: CircularProgressIndicator())
              : visibleOrders.isEmpty
              ? const AppEmptyState(
                  title: 'No orders yet',
                  message: 'Create or import orders and they will appear here with shipment status.',
                  actionLabel: 'Create order',
                )
              : AppStaggeredList(
                  children: [
                    for (final order in visibleOrders)
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

  List<OrderSummary> _filteredOrders(List<OrderSummary> source) {
    final stage = widget.query.stage;
    if (stage == null || stage.isEmpty || stage == 'All') return source;
    return source.where((order) => _stageLabel(order.status) == stage).toList();
  }

  Object? _stageFilterPayload(String? stage) {
    if (stage == null || stage.isEmpty || stage == 'All') return null;
    return {
      'filters': {
        'id': 'flt_stage',
        'type': 'nested',
        'connector': 'and',
        'filterSet': [
          {'id': 'stage', 'opr': '=', 'value': stage},
        ],
      },
    };
  }

  String _stageLabel(ShipmentStatus status) {
    return switch (status) {
      ShipmentStatus.readyToShip => 'Ready to Ship',
      ShipmentStatus.inTransit => 'In-Transit',
      ShipmentStatus.delivered => 'Delivered',
      ShipmentStatus.ndr => 'RTO',
      ShipmentStatus.cancelled => 'Cancelled',
    };
  }
}
