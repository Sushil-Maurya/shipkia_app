import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/api/api.dart';
import '../../core/router/navigation_service.dart';
import '../../core/router/route_state_reader.dart';
import '../../core/state/paginated_controller.dart';
import '../../design_system/app_paginated_list.dart';
import '../../design_system/design_system.dart';
import '../../theme/shipkia_colors.dart';
import '../../widgets/shipkia_widgets.dart';
import 'data/orders_repository.dart';
import 'domain/order_stages.dart';
import 'domain/order_summary.dart';
import 'order_filters_sheet.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({this.query = const OrdersRouteQuery(), super.key});
  final OrdersRouteQuery query;
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _list = PaginatedController<OrderSummary>(
    recordKey: (order) => order.key,
  );
  late final _search = TextEditingController(text: widget.query.search);
  ApiClient? _api;
  OrdersRepository? _repository;
  Timer? _debounce;
  OrderListFilters _filters = const OrderListFilters();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final api = ShipKiaApiScope.maybeOf(context);
    if (identical(_api, api)) return;
    _api = api;
    _repository = api == null ? null : OrdersRepository(api);
    _loadQuery();
  }

  @override
  void didUpdateWidget(OrdersScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query.stage == widget.query.stage &&
        oldWidget.query.search == widget.query.search) {
      return;
    }
    _debounce?.cancel();
    final search = widget.query.search ?? '';
    if (_search.text != search) _search.text = search;
    _loadQuery();
  }

  void _loadQuery() {
    final repository = _repository;
    if (repository == null) return;
    final stage = widget.query.stage;
    final search = widget.query.search;
    final filters = _filters;
    unawaited(
      _list.setQuery(
        (page, pageSize, token) => repository.list(
          page: page,
          pageSize: pageSize,
          cancelToken: token,
          stage: stage,
          search: search,
          filters: filters,
        ),
      ),
    );
  }

  void _searchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 350),
      () => _submitSearch(value),
    );
  }

  void _submitSearch(String value) {
    _debounce?.cancel();
    if (!mounted || value.trim() == (widget.query.search ?? '')) return;
    context.toOrders(stage: widget.query.stage, search: value.trim());
  }

  void _clearFilters() {
    _debounce?.cancel();
    _search.clear();
    setState(() => _filters = const OrderListFilters());
    if (widget.query.stage != null || widget.query.search != null) {
      context.toOrders();
    } else {
      _loadQuery();
    }
  }

  Future<void> _createOrder() async {
    final api = _api;
    if (api == null) return;
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ShipKiaApiScope(
          apiClient: api,
          child: const OrderDetailScreen(orderId: 'new'),
        ),
      ),
    );
    if (created == true && mounted) await _list.refresh();
  }

  Future<void> _openFilters() async {
    final next = await showOrderFiltersSheet(
      context: context,
      filters: _filters,
    );
    if (!mounted || next == null || next.cacheKey == _filters.cacheKey) return;
    setState(() => _filters = next);
    _loadQuery();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    _list.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stage = widget.query.stage ?? 'All';
    final filtered =
        !_filters.isEmpty ||
        stage != 'All' ||
        (widget.query.search?.isNotEmpty ?? false);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Orders',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AppIconButton(
                          icon: Icons.refresh,
                          tooltip: 'Refresh orders',
                          size: 30,
                          onPressed: _repository == null ? null : _list.refresh,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: AppButton(
                            label: 'Create Order',
                            icon: Icons.add,
                            height: 30,
                            onPressed: _api == null ? null : _createOrder,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Your shipping queue, at a glance',
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: ShipKiaColors.textSecondary(context)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _search,
                  hintText: 'Search AWB or delivery phone',
                  prefixIcon: Icons.search,
                  height: 36,
                  textInputAction: TextInputAction.search,
                  onChanged: _searchChanged,
                  onSubmitted: _submitSearch,
                  suffix: ValueListenableBuilder(
                    valueListenable: _search,
                    builder: (context, value, _) => value.text.isEmpty
                        ? const SizedBox.shrink()
                        : AppIconButton(
                            icon: Icons.close,
                            tooltip: 'Clear search',
                            onPressed: () {
                              _search.clear();
                              _submitSearch('');
                            },
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Badge(
                isLabelVisible: !_filters.isEmpty,
                label: Text('${_filters.activeCount}'),
                child: AppIconButton(
                  icon: Icons.tune,
                  tooltip: 'Filter orders',
                  size: 36,
                  onPressed: _openFilters,
                ),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              for (final value in OrderStages.tabs)
                AppChip(
                  label: OrderStages.label(value),
                  selected: stage == value,
                  onSelected: (_) {
                    _debounce?.cancel();
                    context.toOrders(stage: value, search: _search.text.trim());
                  },
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: ListenableBuilder(
                  listenable: _list,
                  builder: (context, _) => Text(
                    _list.totalRecords != null
                        ? '${_list.totalRecords} orders / ${_list.records.length} shown'
                        : '${_list.records.length} orders loaded',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
              if (filtered)
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text('Clear all'),
                ),
            ],
          ),
        ),
        Expanded(
          child: _repository == null
              ? const AppStateView(
                  icon: Icons.cloud_off_outlined,
                  title: 'Orders unavailable',
                  message: 'Connect to your workspace to load orders.',
                )
              : AppPaginatedList<OrderSummary>(
                  controller: _list,
                  emptyTitle: filtered ? 'No matching orders' : 'No orders yet',
                  emptyMessage: filtered
                      ? 'Try another search or clear your filters.'
                      : 'Orders from your workspace will appear here.',
                  emptyActionLabel: filtered ? 'Clear filters' : null,
                  onEmptyAction: filtered ? _clearFilters : null,
                  itemBuilder: (context, order) => SkOrderRow(
                    key: ValueKey(order.key),
                    order: order,
                    onTap: () =>
                        context.toOrderDetails(order.key, order: order),
                  ),
                ),
        ),
      ],
    );
  }
}
