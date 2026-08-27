import 'package:flutter/material.dart';

import '../../design_system/design_system.dart';
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
            borderRadius: ShipKiaRadius.mdBorder,
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
              AppButton(
                label: 'Recharge wallet',
                icon: Icons.add_card,
                onPressed: () {},
                variant: AppButtonVariant.secondary,
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
    return AppListTile(
      title: label,
      trailing: Text(
        value,
        style: TextStyle(
          color: positive
              ? ShipKiaColors.success
              : ShipKiaColors.textPrimary(context),
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
