import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api.dart';
import '../../core/feedback/feedback_messages.dart';
import '../../core/feedback/shipkia_feedback.dart';
import '../../core/router/app_route_paths.dart';
import '../../data/shipkia_mock_data.dart';
import '../../design_system/design_system.dart';
import '../../theme/shipkia_colors.dart';
import '../../widgets/shipkia_widgets.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({required this.orderId, this.order, super.key});

  final String orderId;
  final OrderSummary? order;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _requested = false;
  bool _loading = false;
  OrderSummary? _liveOrder;
  Map<String, dynamic>? _record;

  OrderSummary? get _order => _liveOrder ?? widget.order ?? _findOrder();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requested) return;
    final apiClient = ShipKiaApiScope.maybeOf(context);
    if (apiClient == null) return;
    _requested = true;
    _loading = true;
    unawaited(_loadOrder(apiClient));
  }

  Future<void> _loadOrder(ApiClient apiClient) async {
    try {
      final data = await apiClient.request<Object?>(
        ApiRequestConfig(
          method: HttpMethod.get,
          path: '/oms/orders/records/${Uri.encodeComponent(widget.orderId)}',
          showSuccessMessage: false,
          showErrorMessage: false,
        ),
      );
      final record = _recordFrom(data);
      if (!mounted) return;
      if (record == null) {
        setState(() => _loading = false);
        return;
      }
      setState(() {
        _record = record;
        _liveOrder = OrderSummary.fromJson(record);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;
    if (order == null) {
      return AppScaffold(
        title: widget.orderId,
        body: AppEmptyState(
          title: 'Order not found',
          message:
              'This order route is valid, but the order could not be found.',
          actionLabel: 'Back to orders',
          onAction: () => context.go(AppRoutePaths.orders),
        ),
      );
    }

    return AppScaffold(
      title: order.id,
      bottomNavigationBar: _DetailBottomBar(order: order),
      body: RefreshIndicator(
        onRefresh: () async {
          final apiClient = ShipKiaApiScope.maybeOf(context);
          if (apiClient == null) return;
          await _loadOrder(apiClient);
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            if (_loading) const LinearProgressIndicator(minHeight: 2),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(
                'Order Details',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
            _OrderHero(order: order, record: _record),
            _ManifestStrip(order: order, record: _record),
            _InfoSection(
              title: 'Order Summary',
              icon: Icons.receipt_long_outlined,
              fields: [
                _DetailFieldData(label: 'Customer', value: order.customer),
                _DetailFieldData(label: 'Payment', value: order.paymentMode),
                _DetailFieldData(
                  label: 'Order Value',
                  value: 'Rs ${order.amount.toStringAsFixed(0)}',
                ),
                _DetailFieldData(
                  label: 'Created',
                  value: _formatCreatedAt(order.createdAt),
                ),
              ],
            ),
            _InfoSection(
              title: 'Delivery',
              icon: Icons.location_on_outlined,
              fields: [
                _DetailFieldData(label: 'Destination', value: order.city),
                _DetailFieldData(
                  label: 'Pincode',
                  value: _field(_record, const [
                    'delivery_postal_code',
                    'delivery_pincode',
                    'postal_code',
                  ]),
                ),
                _DetailFieldData(
                  label: 'Phone',
                  value: _field(_record, const [
                    'delivery_phone',
                    'phone',
                    'customer_phone',
                  ]),
                ),
                _DetailFieldData(
                  label: 'Pickup',
                  value: _field(_record, const [
                    'pickup_address',
                    'warehouse_address',
                  ]),
                ),
              ],
            ),
            _InfoSection(
              title: 'Charges',
              icon: Icons.currency_rupee,
              fields: [
                _DetailFieldData(
                  label: 'Freight',
                  value: _money(_record, const ['freight_charge', 'freight']),
                ),
                _DetailFieldData(
                  label: 'COD',
                  value: _money(_record, const ['cod_charge', 'cod_charges']),
                ),
                _DetailFieldData(
                  label: 'RTO',
                  value: _money(_record, const ['rto_charge', 'rto_charges']),
                ),
                _DetailFieldData(label: 'Partner', value: order.courier),
              ],
            ),
            const SkSectionHeader(title: 'Actions'),
            _ActionTile(
              icon: Icons.print_outlined,
              label: 'Download Label',
              onTap: () => ShipKiaFeedback.success(
                'Shipping label downloaded.',
                eventKey: 'shipping-label-downloaded',
              ),
            ),
            _ActionTile(
              icon: Icons.description_outlined,
              label: 'Download Invoice',
              onTap: () => ShipKiaFeedback.success(
                'Invoice downloaded.',
                eventKey: 'invoice-downloaded',
              ),
            ),
            _ActionTile(
              icon: Icons.sync,
              label: 'Sync Order Status',
              onTap: () {
                ShipKiaFeedback.syncStarted();
                Future<void>.delayed(ShipKiaMotion.refresh, () {
                  ShipKiaFeedback.syncCompleted();
                });
              },
            ),
            _ActionTile(
              icon: Icons.cancel_outlined,
              label: 'Cancel Order',
              danger: true,
              onTap: () => ShipKiaFeedback.warning(
                'Cancel order requires confirmation.',
                eventKey: 'cancel-order-warning',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic>? _recordFrom(Object? data) {
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }

  OrderSummary? _findOrder() {
    for (final order in orders) {
      if (order.id == widget.orderId) return order;
    }
    return null;
  }
}

class _OrderHero extends StatelessWidget {
  const _OrderHero({required this.order, required this.record});

  final OrderSummary order;
  final Map<String, dynamic>? record;

  @override
  Widget build(BuildContext context) {
    final reference = _field(record, const ['reference_id', 'referenceId']);
    final pickup = _field(record, const [
      'pickup_address',
      'warehouse_address',
    ]);

    return AppCard(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Hero(
                            tag: 'order-title-${order.id}',
                            child: Material(
                              color: Colors.transparent,
                              child: Text(
                                order.id,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                          ),
                        ),
                        AppIconButton(
                          icon: Icons.copy,
                          tooltip: 'Copy Order ID',
                          size: 26,
                          onPressed: () => _copy(order.id),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            order.awb == '-'
                                ? 'AWB not generated'
                                : 'AWB ${order.awb}',
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: ShipKiaColors.textSecondary(context),
                                ),
                          ),
                        ),
                        if (order.awb != '-')
                          AppIconButton(
                            icon: Icons.copy,
                            tooltip: 'Copy AWB',
                            size: 24,
                            onPressed: () => _copy(order.awb),
                          ),
                      ],
                    ),
                    if (reference != '-') ...[
                      const SizedBox(height: 2),
                      Text(
                        'Ref $reference',
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: ShipKiaColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SkStatusBadge(status: order.status),
            ],
          ),
          if (order.awb != '-') ...[
            const SizedBox(height: 12),
            AppButton(
              label: 'Track Shipment',
              icon: Icons.location_on_outlined,
              height: 34,
              fullWidth: true,
              onPressed: () => ShipKiaFeedback.info(
                'Tracking view opened.',
                eventKey: 'tracking-opened',
              ),
            ),
          ],
          const SizedBox(height: 12),
          _RouteLane(
            pickup: pickup,
            destination: order.city,
            pincode: _field(record, const [
              'delivery_postal_code',
              'delivery_pincode',
              'postal_code',
            ]),
          ),
        ],
      ),
    );
  }
}

class _RouteLane extends StatelessWidget {
  const _RouteLane({
    required this.pickup,
    required this.destination,
    required this.pincode,
  });

  final String pickup;
  final String destination;
  final String pincode;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RouteStop(
          icon: Icons.storefront_outlined,
          label: 'Pickup',
          value: pickup,
        ),
        Expanded(
          child: Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            color: ShipKiaColors.border(context),
          ),
        ),
        _RouteStop(
          icon: Icons.location_on_outlined,
          label: 'Destination',
          value: pincode == '-' ? destination : '$destination $pincode',
          alignEnd: true,
        ),
      ],
    );
  }
}

class _RouteStop extends StatelessWidget {
  const _RouteStop({
    required this.icon,
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: alignEnd
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Icon(icon, color: ShipKiaColors.shipkiaBlue, size: 18),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: ShipKiaColors.textSecondary(context)),
          ),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: alignEnd ? TextAlign.end : TextAlign.start,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _ManifestStrip extends StatelessWidget {
  const _ManifestStrip({required this.order, required this.record});

  final OrderSummary order;
  final Map<String, dynamic>? record;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: _ManifestItem(
              icon: Icons.local_shipping_outlined,
              label: 'AWB',
              value: order.awb,
              copyable: order.awb != '-',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ManifestItem(
              icon: Icons.pin_drop_outlined,
              label: 'Partner',
              value: order.courier,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ManifestItem(
              icon: Icons.sticky_note_2_outlined,
              label: 'Reference',
              value: _field(record, const ['reference_id', 'referenceId']),
            ),
          ),
        ],
      ),
    );
  }
}

class _ManifestItem extends StatelessWidget {
  const _ManifestItem({
    required this.icon,
    required this.label,
    required this.value,
    this.copyable = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool copyable;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ShipKiaColors.surface(context),
        border: Border.all(color: ShipKiaColors.border(context)),
        borderRadius: ShipKiaRadius.mdBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: ShipKiaColors.shipkiaBlue),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(color: ShipKiaColors.textSecondary(context)),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                ),
                if (copyable)
                  AppIconButton(
                    icon: Icons.copy,
                    tooltip: 'Copy $label',
                    size: 24,
                    onPressed: () => _copy(value),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.title,
    required this.icon,
    required this.fields,
  });

  final String title;
  final IconData icon;
  final List<_DetailFieldData> fields;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: ShipKiaColors.shipkiaBlue),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          for (final field in fields) _DetailLine(field: field),
        ],
      ),
    );
  }
}

class _DetailFieldData {
  const _DetailFieldData({required this.label, required this.value});

  final String label;
  final String value;
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.field});

  final _DetailFieldData field;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              field.label,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: ShipKiaColors.textSecondary(context)),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              field.value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailBottomBar extends StatelessWidget {
  const _DetailBottomBar({required this.order});

  final OrderSummary order;

  @override
  Widget build(BuildContext context) {
    final canShip = order.status == ShipmentStatus.readyToShip;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Support Tickets',
                icon: Icons.support_agent,
                height: 38,
                onPressed: () => ShipKiaFeedback.info(
                  'Support ticket draft opened.',
                  eventKey: 'ticket-draft-opened',
                ),
                variant: AppButtonVariant.secondary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppButton(
                label: canShip ? 'Ship Now' : 'Schedule Pickup',
                icon: canShip
                    ? Icons.local_shipping_outlined
                    : Icons.calendar_month_outlined,
                height: 38,
                onPressed: () => ShipKiaFeedback.success(
                  canShip
                      ? ShipKiaFeedbackMessages.shipmentCreated
                      : 'Pickup scheduled successfully.',
                  eventKey: canShip ? 'shipment-created' : 'pickup-scheduled',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger
        ? ShipKiaColors.destructive
        : ShipKiaColors.textPrimary(context);
    return AppListTile(
      onTap: onTap,
      leading: Icon(icon, color: color),
      title: label,
      destructive: danger,
      trailing: const Icon(Icons.chevron_right, size: 18),
    );
  }
}

void _copy(String value) {
  Clipboard.setData(ClipboardData(text: value));
  ShipKiaFeedback.copiedTrackingNumber();
}

String _formatCreatedAt(DateTime value) {
  final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  final minute = value.minute.toString().padLeft(2, '0');
  final period = value.hour >= 12 ? 'PM' : 'AM';
  return '${value.day}/${value.month}/${value.year}, $hour:$minute $period';
}

String _field(Map<String, dynamic>? record, List<String> keys) {
  if (record == null) return '-';
  for (final key in keys) {
    final value = record[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return '-';
}

String _money(Map<String, dynamic>? record, List<String> keys) {
  final value = _field(record, keys);
  if (value == '-') return value;
  final number = num.tryParse(value.replaceAll(',', ''));
  if (number == null) return value;
  return 'Rs ${number.toStringAsFixed(0)}';
}
