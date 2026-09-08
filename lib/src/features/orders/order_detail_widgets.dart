import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/api/api.dart';
import '../../core/api/record_page.dart';
import '../../core/state/paginated_controller.dart';
import '../../design_system/design_system.dart';
import '../../design_system/app_paginated_list.dart';

class OrderDetailHeader extends StatelessWidget {
  const OrderDetailHeader({required this.record, super.key});
  final Map<String, dynamic> record;
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final stage = '${record['stage'] ?? ''}';
    final progress = switch (stage) {
      'Delivered' => 4,
      'In-Transit' || 'In Transit' => 3,
      'Ready to Pickup' => 2,
      'Ready to Ship' => 1,
      _ => 0,
    };
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: .045),
            Theme.of(context).colorScheme.surface,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            children: [
              Text(
                '${record['id'] ?? ''}',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              AppIconButton(
                icon: Icons.copy_outlined,
                tooltip: 'Copy order ID',
                size: 24,
                onPressed: () =>
                    Clipboard.setData(ClipboardData(text: '${record['id']}')),
              ),
              if (record['ecom_order_name'] != null)
                Text(
                  '${record['ecom_order_name']}',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            record['awb'] == null
                ? 'AWB not generated'
                : 'AWB ${record['awb']}',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.warehouse_outlined, size: 18, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${record['pickup_address'] ?? 'Not set'}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'PICKUP',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${record['delivery_city'] ?? ''}',
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'PIN ${record['delivery_postal_code'] ?? ''}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.location_on_outlined, size: 18, color: color),
            ],
          ),
          const SizedBox(height: 12),
          Semantics(
            label: 'Shipment stage: $stage',
            child: Row(
              children: [
                for (var i = 0; i < 5; i++) ...[
                  if (i != 0)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: i <= progress
                            ? color
                            : Theme.of(context).dividerColor,
                      ),
                    ),
                  Container(
                    width: i == progress ? 20 : 10,
                    height: i == progress ? 20 : 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i <= progress
                          ? color
                          : Theme.of(context).colorScheme.surface,
                      border: Border.all(
                        color: i <= progress
                            ? color
                            : Theme.of(context).dividerColor,
                        width: 2,
                      ),
                    ),
                    child: i == progress
                        ? Icon(
                            Icons.local_shipping_outlined,
                            size: 12,
                            color: Theme.of(context).colorScheme.onPrimary,
                          )
                        : null,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OrderDetailNavigation extends StatelessWidget {
  const OrderDetailNavigation({
    required this.selected,
    required this.onSelected,
    super.key,
  });
  final int selected;
  final ValueChanged<int> onSelected;
  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        elevation: 5,
        color: Theme.of(context).colorScheme.surface,
        shape: StadiumBorder(
          side: BorderSide(color: Theme.of(context).dividerColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (i, item) in const [
                (Icons.description_outlined, 'Form'),
                (Icons.local_shipping_outlined, 'Order summary'),
                (Icons.monitor_heart_outlined, 'Activity'),
              ].indexed)
                Semantics(
                  selected: selected == i,
                  child: IconButton(
                    tooltip: item.$2,
                    onPressed: () => onSelected(i),
                    icon: Icon(item.$1, size: 20),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(38, 38),
                      maximumSize: const Size(38, 38),
                      backgroundColor: selected == i
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      foregroundColor: selected == i
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

class OrderActivity extends StatefulWidget {
  const OrderActivity({required this.api, required this.orderId, super.key});
  final ApiClient api;
  final String orderId;
  @override
  State<OrderActivity> createState() => _OrderActivityState();
}

class _OrderActivityState extends State<OrderActivity> {
  final list = PaginatedController<Map<String, dynamic>>(
    recordKey: (r) => '${r['id']}',
    pageSize: 15,
  );
  @override
  void initState() {
    super.initState();
    list.setQuery((page, rows, token) async {
      final data = await widget.api.request<Object?>(
        ApiRequestConfig(
          method: HttpMethod.get,
          path: '/oms/orders/records/activity',
          params: {'id': widget.orderId, 'page': page, 'rows': rows},
          cancelToken: token,
          showErrorMessage: false,
        ),
      );
      return RecordPage.fromJson(data, (r) => r);
    });
  }

  @override
  void dispose() {
    list.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 72),
    child: AppPaginatedList<Map<String, dynamic>>(
      controller: list,
      emptyTitle: 'No activity yet',
      emptyMessage: 'Order updates will appear here.',
      itemBuilder: (context, event) {
        final before = event['old_data'] is Map
            ? event['old_data'] as Map
            : const {};
        final after = event['new_data'] is Map
            ? event['new_data'] as Map
            : const {};
        final changed = after.keys
            .where((k) => jsonEncode(after[k]) != jsonEncode(before[k]))
            .map((k) => '$k'.replaceAll('_', ' '));
        final time = DateTime.tryParse(
          '${event['updated_at'] ?? event['created_at']}',
        )?.toLocal();
        return ListTile(
          leading: const Icon(Icons.history),
          title: Text(before.isEmpty ? 'Order created' : 'Order updated'),
          subtitle: Text(
            [
              if (time != null) '$time',
              if (changed.isNotEmpty) 'Changed: ${changed.join(', ')}',
            ].join('\n'),
          ),
        );
      },
    ),
  );
}
