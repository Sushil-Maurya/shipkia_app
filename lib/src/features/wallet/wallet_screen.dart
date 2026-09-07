import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/api/api.dart';
import '../../design_system/design_system.dart';
import '../../theme/shipkia_colors.dart';
import '../../widgets/shipkia_widgets.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool _requestedLiveData = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requestedLiveData) return;
    final apiClient = ShipKiaApiScope.maybeOf(context);
    if (apiClient == null) return;
    _requestedLiveData = true;
    unawaited(_loadLiveWallet(apiClient));
  }

  Future<void> _loadLiveWallet(ApiClient apiClient) async {
    await Future.wait<Object?>([
      _silentGet(apiClient, ApiEndpoints.wallet.wallet),
      _silentGet(apiClient, ApiEndpoints.wallet.summary),
    ]);
  }

  Future<Object?> _silentGet(ApiClient apiClient, String path) async {
    try {
      return await apiClient.request<Object?>(
        ApiRequestConfig(
          method: HttpMethod.get,
          path: path,
          showSuccessMessage: false,
          showErrorMessage: false,
        ),
      );
    } catch (_) {
      return null;
    }
  }

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
