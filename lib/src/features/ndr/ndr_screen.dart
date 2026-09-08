import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/api/api.dart';
import '../../core/api/api_record_parser.dart';
import '../../core/router/web_module_catalog.dart';
import '../../data/shipkia_mock_data.dart';
import '../../design_system/design_system.dart';
import '../../theme/shipkia_colors.dart';
import '../../widgets/shipkia_widgets.dart';

class NdrScreen extends StatefulWidget {
  const NdrScreen({super.key});

  @override
  State<NdrScreen> createState() => _NdrScreenState();
}

class _NdrScreenState extends State<NdrScreen> {
  bool _requestedLiveData = false;
  bool _loading = false;
  List<OrderSummary>? _liveNdrOrders;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requestedLiveData) return;
    final apiClient = ShipKiaApiScope.maybeOf(context);
    if (apiClient == null) return;
    _requestedLiveData = true;
    _loading = true;
    unawaited(_loadLiveNdr(apiClient));
  }

  Future<void> _loadLiveNdr(ApiClient apiClient) async {
    try {
      final data = await apiClient.request<Object?>(
        ApiRequestConfig(
          method: HttpMethod.post,
          path: WebModuleCatalog.listEndpointFor('delivery_attempt'),
          data: const [],
          params: const {'page': '1', 'rows': '20'},
          showSuccessMessage: false,
          showErrorMessage: false,
        ),
      );
      final rows = extractApiRecords(data);
      if (!mounted) return;
      setState(() {
        _liveNdrOrders = rows.map(OrderSummary.fromJson).toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ndrOrders =
        _liveNdrOrders ??
        orders.where((order) => order.status == ShipmentStatus.ndr).toList();

    return ListView(
      children: [
        const SkSectionHeader(title: 'Delivery Attempts'),
        if (_loading && _liveNdrOrders == null)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
        for (final order in ndrOrders) SkOrderRow(order: order, onTap: () {}),
        const SkSectionHeader(title: 'Buyer Communication'),
        const _MessageTile(
          title: 'WhatsApp sent',
          body: 'Address confirmation requested from buyer.',
          time: 'Today, 10:32 AM',
        ),
        const _MessageTile(
          title: 'Courier remark',
          body: 'Consignee unavailable. Reattempt window suggested.',
          time: 'Today, 9:48 AM',
        ),
        const SkSectionHeader(title: 'NDR Actions'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AppButton(
            label: 'Schedule reattempt',
            icon: Icons.restart_alt,
            onPressed: () {},
            fullWidth: false,
          ),
        ),
      ],
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({
    required this.title,
    required this.body,
    required this.time,
  });

  final String title;
  final String body;
  final String time;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      padding: EdgeInsets.zero,
      child: AppListTile(
        leading: const Icon(
          Icons.chat_bubble_outline,
          color: ShipKiaColors.shipkiaBlue,
        ),
        title: title,
        subtitle: '$body\n$time',
      ),
    );
  }
}
