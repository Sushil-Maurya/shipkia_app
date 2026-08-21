import 'package:flutter/material.dart';

import '../../data/shipkia_mock_data.dart';
import '../../theme/shipkia_colors.dart';
import '../../widgets/shipkia_widgets.dart';

class NdrScreen extends StatelessWidget {
  const NdrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ndrOrders = orders
        .where((order) => order.status == ShipmentStatus.ndr)
        .toList();

    return ListView(
      children: [
        const SkSectionHeader(title: 'Delivery Attempts'),
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
          child: FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.restart_alt, size: 18),
            label: const Text('Schedule reattempt'),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Material(
        color: ShipKiaColors.paper,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: ShipKiaColors.neutralBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          dense: true,
          leading: const Icon(
            Icons.chat_bubble_outline,
            color: ShipKiaColors.shipkiaBlue,
          ),
          title: Text(title, style: Theme.of(context).textTheme.titleMedium),
          subtitle: Text('$body\n$time'),
          isThreeLine: true,
        ),
      ),
    );
  }
}
