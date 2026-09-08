import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/api/api.dart';
import '../../design_system/design_system.dart';
import 'data/order_actions_repository.dart';

bool pickupDateAllowed(DateTime date, DateTime now, Map address) {
  final today = DateTime(now.year, now.month, now.day);
  if (date.isBefore(today)) return false;
  final days = address['operational_days'];
  if (days is List && days.isNotEmpty) {
    const week = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    if (!days.any(
      (d) =>
          '${d is Map ? d['day'] : d}'.toLowerCase() ==
          week[date.weekday - 1].toLowerCase(),
    )) {
      return false;
    }
  }
  if (date == today) {
    final parts = '${address['closing_time'] ?? ''}'
        .split(':')
        .map(int.tryParse)
        .toList();
    if (parts.length >= 2 && parts[0] != null && parts[1] != null) {
      return now.hour * 3600 + now.minute * 60 + now.second <
          parts[0]! * 3600 +
              parts[1]! * 60 +
              (parts.length > 2 ? parts[2] ?? 0 : 0);
    }
  }
  return true;
}

class OrderShippingSheet extends StatefulWidget {
  const OrderShippingSheet({
    required this.api,
    required this.order,
    this.scheduleOnly = false,
    super.key,
  });
  final ApiClient api;
  final Map<String, dynamic> order;
  final bool scheduleOnly;
  @override
  State<OrderShippingSheet> createState() => _OrderShippingSheetState();
}

class _OrderShippingSheetState extends State<OrderShippingSheet> {
  final token = CancelToken();
  bool loading = true, saving = false, scheduling = false, shipped = false;
  Object? error;
  List<Map<String, dynamic>> quotes = [];
  Map<String, dynamic> address = {};
  String? selectedQuote;
  DateTime? selectedDate;
  late final repository = OrderActionsRepository(widget.api);
  String get id => '${widget.order['id']}';
  @override
  void initState() {
    super.initState();
    scheduling = widget.scheduleOnly;
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      if (scheduling) {
        final data = await widget.api.request<Object?>(
          ApiRequestConfig(
            method: HttpMethod.get,
            path:
                '/oms/pickup_address/records/${Uri.encodeComponent('${widget.order['pickup_address']}')}',
            cancelToken: token,
            showErrorMessage: false,
          ),
        );
        final raw = data is Map ? data['value'] ?? data : null;
        if (raw is! Map) {
          throw const FormatException('Pickup address unavailable');
        }
        address = Map<String, dynamic>.from(raw);
      } else {
        quotes = await repository.quotes(id, token);
      }
    } catch (e) {
      if (mounted) error = e;
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> submit() async {
    if (saving) return;
    if (scheduling &&
        (selectedDate == null ||
            !pickupDateAllowed(selectedDate!, DateTime.now(), address))) {
      return;
    }
    if (!scheduling && selectedQuote == null) return;
    setState(() {
      saving = true;
      error = null;
    });
    try {
      if (scheduling) {
        await repository.schedule(
          id,
          selectedDate!.toIso8601String().substring(0, 10),
          token,
        );
        if (mounted) Navigator.pop(context, true);
      } else {
        final result = await repository.ship(id, selectedQuote!, token);
        shipped = true;
        if (!mounted) return;
        if (result['auto_pickup'] == true) {
          Navigator.pop(context, true);
        } else {
          setState(() {
            scheduling = true;
            selectedDate = null;
          });
          await load();
        }
      }
    } catch (e) {
      if (mounted) setState(() => error = e);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  void dispose() {
    token.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .8,
        child: Column(
          children: [
            ListTile(
              title: Text(scheduling ? 'Schedule Pickup' : 'Ship Now'),
              trailing: IconButton(
                tooltip: 'Close',
                icon: const Icon(Icons.close),
                onPressed: saving
                    ? null
                    : () => Navigator.pop(context, shipped),
              ),
            ),
            if (shipped)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Shipment created. Choose a pickup date, or schedule later.',
                ),
              ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(ApiExceptionMapper.unknown(error!).message),
              ),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : error != null &&
                        (scheduling ? address.isEmpty : quotes.isEmpty)
                  ? Center(
                      child: TextButton(
                        onPressed: load,
                        child: const Text('Retry'),
                      ),
                    )
                  : RadioGroup<Object>(
                      groupValue: scheduling ? selectedDate : selectedQuote,
                      onChanged: (value) => setState(() {
                        if (scheduling) {
                          selectedDate = value as DateTime?;
                        } else {
                          selectedQuote = value as String?;
                        }
                      }),
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          if (!scheduling && quotes.isEmpty)
                            const Text(
                              'No couriers are available for this order.',
                            ),
                          if (!scheduling)
                            for (final quote in quotes)
                              RadioListTile<Object>(
                                title: Text('${quote['name']}'),
                                subtitle: Text(
                                  '${quote['mode'] ?? ''}  |  INR ${((num.tryParse('${quote['total_charges']}') ?? 0) / 100).toStringAsFixed(2)}\nDelivery: ${quote['expected_delivery_date'] ?? 'Not provided'}',
                                ),
                                value: '${quote['quote_id']}',
                                enabled: !saving && quote['quote_id'] != null,
                              ),
                          if (scheduling)
                            for (var i = 0; i < 6; i++)
                              Builder(
                                builder: (context) {
                                  final date = DateTime(
                                    now.year,
                                    now.month,
                                    now.day + i,
                                  );
                                  final allowed = pickupDateAllowed(
                                    date,
                                    now,
                                    address,
                                  );
                                  return RadioListTile<Object>(
                                    title: Text(
                                      date.toIso8601String().substring(0, 10),
                                    ),
                                    subtitle: allowed
                                        ? null
                                        : const Text('Pickup unavailable'),
                                    value: date,
                                    enabled: !saving && allowed,
                                  );
                                },
                              ),
                        ],
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: AppButton(
                label: scheduling ? 'Schedule Pickup' : 'Confirm shipment',
                loading: saving,
                onPressed:
                    loading ||
                        saving ||
                        (scheduling
                            ? selectedDate == null
                            : selectedQuote == null)
                    ? null
                    : submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
