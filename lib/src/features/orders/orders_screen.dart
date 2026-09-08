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
import 'order_filters_sheet.dart';

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
  OrderListFilters _filters = const OrderListFilters();

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
    final key =
        '${widget.query.stage}|${widget.query.search}|${_filters.cacheKey}';
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
          data: _filters.toPayload(stage: stage),
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
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                label: 'Add',
                icon: Icons.add,
                height: 28,
                onPressed: () {},
              ),
              const SizedBox(width: 3),
              AppIconButton(
                icon: Icons.more_vert,
                onPressed: _openActions,
                tooltip: 'Order actions',
                size: 28,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 30,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(10, 3, 10, 0),
            scrollDirection: Axis.horizontal,
            children: [
              for (final stage in _stageTabs)
                _StageChip(
                  label: stage,
                  selected: selectedStage == stage,
                  onSelected: (_) => context.toOrders(stage: stage),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 1, 12, 3),
          child: Row(
            children: [
              Text(
                '$totalRecords records',
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(color: ShipKiaColors.mutedInk),
              ),
              const Spacer(),
              if (!_filters.isEmpty)
                Text(
                  '${_filters.activeCount} filters',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: ShipKiaColors.shipkiaBlue,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
        ),
        if (_loading && _liveOrders != null)
          const LinearProgressIndicator(minHeight: 2),
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
                  padding: EdgeInsets.zero,
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

  void _openActions() {
    showAppActionSheet(
      context: context,
      title: 'Order Actions',
      items: [
        AppActionSheetItem(
          label: 'Reload',
          icon: Icons.refresh,
          onSelected: _reload,
        ),
        AppActionSheetItem(
          label: 'Export',
          icon: Icons.file_download_outlined,
          onSelected: () {},
        ),
        AppActionSheetItem(
          label: 'Filters',
          icon: Icons.filter_list,
          onSelected: _openFilters,
        ),
      ],
    );
  }

  void _reload() {
    setState(() => _lastRequestKey = null);
    _loadIfNeeded();
  }

  Future<void> _openFilters() async {
    final next = await showOrderFiltersSheet(
      context: context,
      filters: _filters,
    );
    if (next == null || !mounted) return;
    setState(() {
      _filters = next;
      _lastRequestKey = null;
    });
    _loadIfNeeded();
  }

  List<OrderSummary> _filteredOrders(List<OrderSummary> source) {
    final stage = widget.query.stage;
    if (stage == null || stage.isEmpty || stage == 'All') return source;
    return source.where((order) => _stageLabel(order.status) == stage).toList();
  }

  String _stageLabel(ShipmentStatus status) {
    return switch (status) {
      ShipmentStatus.newOrder => 'New',
      ShipmentStatus.readyToShip => 'Ready to Ship',
      ShipmentStatus.readyToPickup => 'Ready to Pickup',
      ShipmentStatus.inTransit => 'In-Transit',
      ShipmentStatus.delivered => 'Delivered',
      ShipmentStatus.ndr => 'RTO',
      ShipmentStatus.rto => 'RTO',
      ShipmentStatus.cancelled => 'Cancelled',
    };
  }
}

class _StageChip extends StatelessWidget {
  const _StageChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final foreground = selected
        ? ShipKiaColors.paper
        : ShipKiaColors.textPrimary(context);
    final background = selected
        ? ShipKiaColors.shipkiaBlue
        : ShipKiaColors.surface(context);

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: ShipKiaRadius.smBorder,
          onTap: () => onSelected(!selected),
          child: AnimatedContainer(
            duration: ShipKiaMotion.duration(context, ShipKiaMotion.fast),
            curve: ShipKiaMotion.standard,
            height: 24,
            constraints: const BoxConstraints(minWidth: 36),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: background,
              borderRadius: ShipKiaRadius.smBorder,
              border: Border.all(
                color: selected
                    ? ShipKiaColors.shipkiaBlue
                    : ShipKiaColors.border(context),
              ),
            ),
            child: AnimatedDefaultTextStyle(
              duration: ShipKiaMotion.duration(context, ShipKiaMotion.fast),
              curve: ShipKiaMotion.standard,
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                color: foreground,
                fontWeight: FontWeight.w800,
                height: 1,
                fontSize: 9,
              ),
              child: Text(label, textAlign: TextAlign.center),
            ),
          ),
        ),
      ),
    );
  }
}
