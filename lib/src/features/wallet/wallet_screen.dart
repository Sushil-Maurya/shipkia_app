import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/api/api.dart';
import '../../core/api/api_record_parser.dart';
import '../../core/router/web_module_catalog.dart';
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
  bool _loading = false;
  String? _balance;
  List<_WalletLine>? _summary;
  List<_WalletLine>? _transactions;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requestedLiveData) return;
    final apiClient = ShipKiaApiScope.maybeOf(context);
    if (apiClient == null) return;
    _requestedLiveData = true;
    _loading = true;
    unawaited(_loadLiveWallet(apiClient));
  }

  Future<void> _loadLiveWallet(ApiClient apiClient) async {
    final responses = await Future.wait<Object?>([
      _silentGet(apiClient, ApiEndpoints.wallet.wallet),
      _silentGet(apiClient, ApiEndpoints.wallet.summary),
      _silentPost(
        apiClient,
        WebModuleCatalog.listEndpointFor('wallet_transactions'),
      ),
    ]);
    if (!mounted) return;
    setState(() {
      _balance = _balanceFrom(responses[0]) ?? _balanceFrom(responses[1]);
      _summary = _summaryFrom(responses[1]);
      _transactions = _transactionsFrom(responses[2]);
      _loading = false;
    });
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

  Future<Object?> _silentPost(ApiClient apiClient, String path) async {
    try {
      return await apiClient.request<Object?>(
        ApiRequestConfig(
          method: HttpMethod.post,
          path: path,
          data: const [],
          params: const {'page': '1', 'rows': '10'},
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
    final summary = _summary ?? _fallbackSummary;
    final transactions = _transactions ?? _fallbackTransactions;

    return ListView(
      children: [
        if (_loading) const LinearProgressIndicator(minHeight: 2),
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
              Text(
                _balance ?? 'Rs 82,420',
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
        for (final line in summary)
          _WalletRow(
            label: line.label,
            value: line.value,
            positive: line.positive,
          ),
        const SkSectionHeader(title: 'Recent Transactions'),
        for (final line in transactions)
          _WalletRow(
            label: line.label,
            value: line.value,
            positive: line.positive,
          ),
      ],
    );
  }

  String? _balanceFrom(Object? data) {
    if (data is! Map) return null;
    final json = Map<String, dynamic>.from(data);
    final value = _firstValue(json, const [
      'balance',
      'available_balance',
      'availableBalance',
      'wallet_balance',
      'walletBalance',
      'amount',
    ]);
    return _money(value);
  }

  List<_WalletLine>? _summaryFrom(Object? data) {
    if (data is! Map) return null;
    final json = Map<String, dynamic>.from(data);
    final rows = extractApiRecords(json);
    if (rows.isNotEmpty) return rows.map(_lineFromRow).toList();

    final lines = <_WalletLine>[];
    for (final entry in json.entries) {
      final value = _money(entry.value);
      if (value == null) continue;
      lines.add(_WalletLine(label: _labelFromKey(entry.key), value: value));
    }
    return lines.isEmpty ? null : lines;
  }

  List<_WalletLine>? _transactionsFrom(Object? data) {
    final rows = extractApiRecords(data);
    if (rows.isEmpty) return null;
    return rows.map(_lineFromRow).toList();
  }

  _WalletLine _lineFromRow(Map<String, dynamic> row) {
    final rawAmount = _firstValue(row, const [
      'amount',
      'balance',
      'value',
      'transaction_amount',
      'transactionAmount',
    ]);
    final value = _money(rawAmount) ?? '-';
    final label =
        _firstText(row, const [
          'label',
          'title',
          'description',
          'particular',
          'type',
          'status',
          'id',
        ]) ??
        'Wallet entry';
    final positive = _isPositive(row, rawAmount);
    return _WalletLine(label: label, value: value, positive: positive);
  }

  Object? _firstValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().trim().isNotEmpty) return value;
    }
    return null;
  }

  String? _firstText(Map<String, dynamic> json, List<String> keys) {
    final value = _firstValue(json, keys);
    return value?.toString().trim();
  }

  String? _money(Object? value) {
    if (value == null) return null;
    if (value is num) return 'Rs ${value.toStringAsFixed(0)}';
    final text = value.toString().trim();
    if (text.isEmpty) return null;
    if (text.toLowerCase().startsWith('rs')) return text;
    final number = num.tryParse(text.replaceAll(',', ''));
    if (number == null) return text;
    return 'Rs ${number.toStringAsFixed(0)}';
  }

  bool _isPositive(Map<String, dynamic> row, Object? rawAmount) {
    final type = _firstText(row, const ['type', 'transaction_type', 'mode']);
    if (type != null) {
      final normalized = type.toLowerCase();
      if (normalized.contains('credit') || normalized.contains('recharge')) {
        return true;
      }
      if (normalized.contains('debit') || normalized.contains('deduct')) {
        return false;
      }
    }
    if (rawAmount is num) return rawAmount >= 0;
    return rawAmount?.toString().trim().startsWith('+') ?? false;
  }

  String _labelFromKey(String key) {
    return key
        .replaceAll('_', ' ')
        .replaceAllMapped(
          RegExp(r'(^|\s)\w'),
          (match) => match[0]!.toUpperCase(),
        );
  }
}

class _WalletLine {
  const _WalletLine({
    required this.label,
    required this.value,
    this.positive = false,
  });

  final String label;
  final String value;
  final bool positive;
}

const _fallbackSummary = [
  _WalletLine(label: 'Freight Charges', value: 'Rs 14,820'),
  _WalletLine(label: 'COD Charges', value: 'Rs 2,130'),
  _WalletLine(label: 'RTO Charges', value: 'Rs 1,920'),
];

const _fallbackTransactions = [
  _WalletLine(label: 'Recharge verified', value: '+Rs 50,000', positive: true),
  _WalletLine(label: 'Shipment debit - ORD-10491', value: '-Rs 142'),
  _WalletLine(label: 'COD adjustment', value: '+Rs 830', positive: true),
];

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
