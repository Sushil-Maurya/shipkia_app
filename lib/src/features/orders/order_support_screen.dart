import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api.dart';
import '../../core/api/record_page.dart';
import '../../core/forms/forms.dart';
import '../../core/state/paginated_controller.dart';
import '../../design_system/design_system.dart';
import '../../design_system/app_paginated_list.dart';
import 'data/order_actions_repository.dart';

class OrderSupportScreen extends StatefulWidget {
  const OrderSupportScreen({required this.api, required this.order, super.key});
  final ApiClient api;
  final Map<String, dynamic> order;
  @override
  State<OrderSupportScreen> createState() => _OrderSupportScreenState();
}

class _OrderSupportScreenState extends State<OrderSupportScreen> {
  final list = PaginatedController<Map<String, dynamic>>(
    recordKey: (r) => '${r['id'] ?? r['name']}',
  );
  final token = CancelToken();
  bool canCreate = false;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    list.setQuery((page, rows, cancellation) async {
      final data = await widget.api.request<Object?>(
        ApiRequestConfig(
          method: HttpMethod.post,
          path: '/oms/support_ticket/records/list',
          params: {'page': page, 'rows': rows},
          data: {
            'filters': {
              'id': 'order-ticket',
              'type': 'nested',
              'connector': 'and',
              'filterSet': [
                {'id': 'record_id', 'opr': '=', 'value': widget.order['id']},
              ],
            },
          },
          cancelToken: cancellation,
          showErrorMessage: false,
        ),
      );
      return RecordPage.fromJson(data, (r) => r);
    });
    try {
      final permissions = await OrderActionsRepository(widget.api)
          .permissions('support_ticket', token);
      if (mounted) setState(() => canCreate = permissions['create'] == true);
    } catch (_) {
      if (mounted) setState(() => canCreate = false);
    }
  }

  Future<void> create() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => _TicketForm(api: widget.api, order: widget.order),
      ),
    );
    if (saved == true && mounted) list.refresh();
  }

  @override
  void dispose() {
    token.cancel();
    list.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    title: 'Support Tickets',
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(child: Text('Order ${widget.order['id']}')),
              if (canCreate)
                AppButton(label: 'Raise Ticket', onPressed: create),
            ],
          ),
        ),
        Expanded(
          child: AppPaginatedList<Map<String, dynamic>>(
            controller: list,
            emptyTitle: 'No tickets for this order',
            emptyMessage: 'Create a ticket to contact support.',
            itemBuilder: (context, row) => ListTile(
              title: Text(
                '${row['subject'] ?? row['title'] ?? row['id'] ?? row['name']}',
              ),
              subtitle: Text('${row['status'] ?? ''}'),
              onTap: () => context.push(
                '/support_ticket/${Uri.encodeComponent('${row['id'] ?? row['name']}')}',
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _TicketForm extends StatefulWidget {
  const _TicketForm({required this.api, required this.order});
  final ApiClient api;
  final Map<String, dynamic> order;
  @override
  State<_TicketForm> createState() => _TicketFormState();
}

class _TicketFormState extends State<_TicketForm> {
  final token = CancelToken();
  final key = GlobalKey<DynamicFormBuilderState>();
  DynamicFormController? form;
  Object? error;
  bool saving = false, loading = true;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final results = await Future.wait<Object?>([
        widget.api.request<Object?>(
          ApiRequestConfig(
            method: HttpMethod.get,
            path: '/oms/support_ticket/records/fields',
            cancelToken: token,
            showErrorMessage: false,
          ),
        ),
        widget.api.request<Object?>(
          ApiRequestConfig(
            method: HttpMethod.get,
            path: '/oms/support_ticket/categories',
            params: {'reference_type': 'orders'},
            cancelToken: token,
            showErrorMessage: false,
          ),
        ),
      ]);
      final categories = results[1] is Map
          ? (results[1] as Map)['data'] ?? (results[1] as Map)['values']
          : results[1];
      final fields = ApiFormAdapter.fieldsFrom(results[0])
          .where((f) => ApiFormAdapter.nameOf(f) != 'attachments')
          .map((raw) {
            final f = Map<String, dynamic>.from(raw);
            final name = ApiFormAdapter.nameOf(f);
            if (name == 'issue_type') {
              f['type'] = 'option';
              f['options'] = categories;
            }
            if ({
              'reference_type',
              'record_id',
              'courier_partner',
            }.contains(name)) {
              f['readonly'] = true;
            }
            return f;
          })
          .toList();
      final schema = const ApiFormAdapter().parse(
        fields,
        id: 'order-ticket',
        values: {
          'reference_type': 'orders',
          'record_id': widget.order['id'],
          'awb': widget.order['awb'],
          'awb_number': widget.order['awb'],
          'courier_partner': widget.order['courier_partner'],
        },
      );
      if (!mounted) return;
      form?.dispose();
      form = DynamicFormController(schema: schema);
    } catch (e) {
      if (mounted) error = e;
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> save() async {
    if (saving || !key.currentState!.validateAndFocusFirstError()) return;
    setState(() {
      saving = true;
      error = null;
    });
    try {
      final values = const ApiFormAdapter().serialize(
        form!.schema,
        form!.values,
      );
      await widget.api.request<Object?>(
        ApiRequestConfig(
          method: HttpMethod.post,
          path: '/oms/support_ticket/records',
          data: {
            ...values,
            'reference_type': 'orders',
            'record_id': widget.order['id'],
          },
          cancelToken: token,
          showErrorMessage: false,
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => error = e);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  void dispose() {
    token.cancel();
    form?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ShipKiaApiScope(
    apiClient: widget.api,
    child: AppScaffold(
      title: 'Raise Ticket',
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : form == null
          ? AppErrorState(
              message: ApiExceptionMapper.unknown(error!).message,
              onRetry: load,
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                AbsorbPointer(
                  absorbing: saving,
                  child: DynamicFormBuilder(
                    key: key,
                    schema: form!.schema,
                    controller: form!,
                    maxColumns: 1,
                  ),
                ),
                if (error != null)
                  Text(ApiExceptionMapper.unknown(error!).message),
                AppButton(
                  label: 'Create Ticket',
                  loading: saving,
                  onPressed: saving ? null : save,
                ),
              ],
            ),
    ),
  );
}
