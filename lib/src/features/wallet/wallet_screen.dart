import 'package:flutter/material.dart';

import '../../theme/shipkia_colors.dart';
import '../../widgets/shipkia_widgets.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: ShipKiaColors.shipkiaBlue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Available Balance',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Rs 82,420',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              FilledButton.tonalIcon(
                onPressed: () {},
                icon: const Icon(Icons.add_card, size: 18),
                label: const Text('Recharge wallet'),
              ),
            ],
          ),
        ),
        const SkSectionHeader(title: 'Summary'),
        const _WalletRow(label: 'Freight Charges', value: 'Rs 14,820'),
        const _WalletRow(label: 'COD Charges', value: 'Rs 2,130'),
        const _WalletRow(label: 'RTO Charges', value: 'Rs 1,920'),
        const SkSectionHeader(title: 'Recent Transactions'),
        const _WalletRow(
          label: 'Recharge verified',
          value: '+Rs 50,000',
          positive: true,
        ),
        const _WalletRow(label: 'Shipment debit - ORD-10491', value: '-Rs 142'),
        const _WalletRow(
          label: 'COD adjustment',
          value: '+Rs 830',
          positive: true,
        ),
      ],
    );
  }
}

class _WalletRow extends StatelessWidget {
  const _WalletRow({
    required this.label,
    required this.value,
    this.positive = false,
  });

  final String label;
  final String value;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(label, style: Theme.of(context).textTheme.titleMedium),
      trailing: Text(
        value,
        style: TextStyle(
          color: positive ? ShipKiaColors.success : ShipKiaColors.ink,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
