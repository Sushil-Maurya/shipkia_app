import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../api/api.dart';
import '../../../api/record_page.dart';
import '../../../state/paginated_controller.dart';
import '../../../../design_system/design_system.dart';
import '../../forms.dart';

class UnsupportedApiFieldRenderer implements DynamicFieldRenderer {
  const UnsupportedApiFieldRenderer();
  @override
  Widget build(DynamicFieldContext c) => InputDecorator(
    decoration: InputDecoration(
      labelText: c.field.label,
      errorText: c.errorText,
    ),
    child: Text(
      c.canEdit
          ? 'This field is available in the web workspace.'
          : c.value == null
          ? 'Not set'
          : 'View this field in the web workspace.',
    ),
  );
}

class LinkApiFieldRenderer implements DynamicFieldRenderer {
  const LinkApiFieldRenderer({this.allowFreeText = false});
  final bool allowFreeText;
  @override
  Widget build(DynamicFieldContext c) =>
      ApiOptionsField(context: c, allowFreeText: allowFreeText);
}

class PostalApiFieldRenderer implements DynamicFieldRenderer {
  const PostalApiFieldRenderer();
  @override
  Widget build(DynamicFieldContext context) => _PostalField(context: context);
}

class _PostalField extends StatefulWidget {
  const _PostalField({required this.context});
  final DynamicFieldContext context;
  @override
  State<_PostalField> createState() => _PostalFieldState();
}

class _PostalFieldState extends State<_PostalField> {
  Timer? timer;
  CancelToken? token;
  bool loading = false;
  String? error;
  Map get mapping {
    final raw = widget.context.field.metadata['display'];
    if (raw is Map) return raw;
    if (raw is String) {
      try {
        final parsed = jsonDecode(raw);
        if (parsed is Map) return parsed;
      } catch (_) {}
    }
    return const {'city': 'city', 'state': 'state', 'country': 'country'};
  }

  void change(String v) {
    final c = widget.context;
    timer?.cancel();
    token?.cancel();
    c.onChanged(v);
    for (final target in mapping.values) {
      if (c.controller.schema.fields.any((f) => f.id == '$target')) {
        c.controller.setValue('$target', '');
      }
    }
    setState(() {
      error = null;
      loading = v.length == 6;
    });
    c.controller.setExternalError(
      c.field.id,
      v.length == 6 ? 'Checking postal code.' : null,
    );
    if (v.length == 6) {
      timer = Timer(const Duration(milliseconds: 350), () => lookup(v));
    }
  }

  Future<void> lookup(String value) async {
    final c = widget.context;
    final requestToken = token = CancelToken();
    try {
      final api = ShipKiaApiScope.maybeOf(context);
      if (api == null) throw StateError('Connection unavailable');
      final data = await api.request<Object?>(
        ApiRequestConfig(
          method: HttpMethod.get,
          path: '/oms/postal-code',
          params: {'postal_code': value},
          cancelToken: requestToken,
          showErrorMessage: false,
        ),
      );
      if (!mounted || requestToken.isCancelled) return;
      if (data is! Map) {
        throw const FormatException('Postal code was not found.');
      }
      for (final entry in mapping.entries) {
        if (c.controller.schema.fields.any((f) => f.id == '${entry.value}')) {
          c.controller.setValue('${entry.value}', data[entry.key] ?? '');
        }
      }
      c.controller.setExternalError(c.field.id, null);
    } catch (e) {
      if (!mounted || requestToken.isCancelled) return;
      error = ApiExceptionMapper.unknown(e).message;
      c.controller.setExternalError(c.field.id, error);
    } finally {
      if (mounted && !requestToken.isCancelled) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    token?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.context;
    return AppTextField(
      label: c.isRequired ? '${c.field.label} *' : c.field.label,
      initialValue: c.value?.toString() ?? '',
      readOnly: !c.canEdit,
      keyboardType: TextInputType.number,
      maxLength: 6,
      errorText: error ?? c.errorText,
      onChanged: change,
      suffix: loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : error != null
          ? IconButton(
              tooltip: 'Retry postal lookup',
              onPressed: () => change('${c.value}'),
              icon: const Icon(Icons.refresh),
            )
          : null,
    );
  }
}

class GridApiFieldRenderer implements DynamicFieldRenderer {
  const GridApiFieldRenderer();
  @override
  Widget build(DynamicFieldContext c) {
    final rows = c.value is List
        ? List<Object?>.from(c.value as List)
        : <Object?>[];
    if (c.field.metadata['_presentation'] == 'operational_days') {
      final children = ApiFormAdapter.fieldsFrom(
        c.field.metadata['fields'] ?? [],
      );
      final day = children
          .where((f) => ApiFormAdapter.nameOf(f) == 'day')
          .firstOrNull;
      final options = ApiFormAdapter.parseOptions(day?['options']);
      final selected = rows.whereType<Map>().map((r) => r['day']).toSet();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            c.isRequired ? '${c.field.label} *' : c.field.label,
            style: Theme.of(c.buildContext).textTheme.titleSmall,
          ),
          for (final option in options)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(option.label),
              value: selected.contains(option.value),
              onChanged: !c.canEdit
                  ? null
                  : (open) {
                      if (open == true) {
                        selected.add(option.value);
                      } else {
                        selected.remove(option.value);
                      }
                      c.onChanged([
                        for (final value in options.where(
                          (o) => selected.contains(o.value),
                        ))
                          {'day': value.value},
                      ]);
                    },
            ),
          if (c.errorText != null)
            Text(
              c.errorText!,
              style: TextStyle(
                color: Theme.of(c.buildContext).colorScheme.error,
              ),
            ),
        ],
      );
    }
    final max = num.tryParse('${c.field.metadata['max']}');
    Future<void> edit(int? index) async {
      const adapter = ApiFormAdapter();
      final raw = index == null
          ? Map<String, dynamic>.from(
              c.field.metadata['defaultRow'] as Map? ?? {},
            )
          : Map<String, dynamic>.from(rows[index] as Map);
      final schema = adapter.parse(
        c.field.metadata['fields'] ?? [],
        id: '${c.field.id}-row',
        values: raw,
        readOnly: !c.canEdit,
      );
      final controller = DynamicFormController(schema: schema);
      final key = GlobalKey<DynamicFormBuilderState>();
      final result = await showModalBottomSheet<Map<String, Object?>>(
        context: c.buildContext,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (context) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: FractionallySizedBox(
            heightFactor: .85,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        c.field.label,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    AppIconButton(
                      icon: Icons.close,
                      tooltip: 'Close',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DynamicFormBuilder(
                  key: key,
                  schema: schema,
                  controller: controller,
                  maxColumns: 1,
                ),
                if (c.canEdit)
                  Align(
                    alignment: Alignment.centerRight,
                    child: AppButton(
                      label: 'Done',
                      onPressed: () {
                        if (key.currentState!.validateAndFocusFirstError()) {
                          Navigator.pop(
                            context,
                            adapter.serialize(schema, controller.values),
                          );
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
      controller.dispose();
      if (result == null || !c.buildContext.mounted) return;
      if (index == null) {
        rows.add(result);
      } else {
        rows[index] = result;
      }
      c.onChanged(rows);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          c.isRequired ? '${c.field.label} *' : c.field.label,
          style: Theme.of(c.buildContext).textTheme.titleSmall,
        ),
        for (final (i, row) in rows.indexed)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              c.field.metadata['_presentation'] == 'order_products' &&
                      row is Map
                  ? '${row['product_name'] ?? 'Product ${i + 1}'}'
                  : 'Row ${i + 1}',
            ),
            subtitle: Text(
              row is Map
                  ? c.field.metadata['_presentation'] == 'order_products'
                        ? 'Qty ${row['quantity'] ?? 0}  |  INR ${((num.tryParse('${row['unit_price']}') ?? 0) / 100).toStringAsFixed(2)} each'
                        : row.values.where((v) => v != null).join(' - ')
                  : '$row',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => edit(i),
            trailing: c.canEdit
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (c.field.metadata['_presentation'] ==
                              'order_products' &&
                          (max == null || rows.length < max))
                        IconButton(
                          tooltip: 'Duplicate row ${i + 1}',
                          icon: const Icon(Icons.copy_outlined),
                          onPressed: () {
                            rows.insert(
                              i + 1,
                              Map<String, dynamic>.from(row as Map),
                            );
                            c.onChanged(rows);
                          },
                        ),
                      IconButton(
                        tooltip: 'Remove row ${i + 1}',
                        onPressed: () {
                          rows.removeAt(i);
                          c.onChanged(rows);
                        },
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  )
                : const Icon(Icons.chevron_right),
          ),
        if (rows.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('No rows'),
          ),
        if (c.canEdit && (max == null || rows.length < max))
          TextButton.icon(
            onPressed: () => edit(null),
            icon: const Icon(Icons.add),
            label: const Text('Add row'),
          ),
        if (c.errorText != null)
          Text(
            c.errorText!,
            style: TextStyle(color: Theme.of(c.buildContext).colorScheme.error),
          ),
      ],
    );
  }
}

class ApiOptionsField extends StatefulWidget {
  const ApiOptionsField({
    required this.context,
    this.allowFreeText = false,
    super.key,
  });
  final bool allowFreeText;
  final DynamicFieldContext context;
  @override
  State<ApiOptionsField> createState() => _ApiOptionsFieldState();
}

class _ApiOptionsFieldState extends State<ApiOptionsField> {
  late final TextEditingController text;
  final focus = FocusNode();
  final options = PaginatedController<Map<String, dynamic>>(
    recordKey: (r) => '${r['id'] ?? r['value'] ?? r['name']}',
    pageSize: 15,
  );
  Timer? timer;
  bool open = false;
  @override
  void initState() {
    super.initState();
    text = TextEditingController(text: labelFor(widget.context.value));
  }

  @override
  void didUpdateWidget(covariant ApiOptionsField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.context.value != widget.context.value && !focus.hasFocus) {
      text.text = labelFor(widget.context.value);
    }
  }

  String labelFor(Object? value) =>
      widget.context.field.options
          .where((o) => o.value == value)
          .firstOrNull
          ?.label ??
      '${value ?? ''}';

  Future<void> select(Map<String, dynamic> row) async {
    final c = widget.context;
    final value = row['id'] ?? row['record_id'] ?? row['value'] ?? row['name'];
    if (value == null) return;
    timer?.cancel();
    c.onChanged(value);
    c.controller.setExternalError(c.field.id, null);
    text.text = '${row['label'] ?? value}';
    focus.unfocus();
    setState(() => open = false);
    final mapping = c.field.metadata['display'];
    final type = c.field.metadata['object_type'];
    if (mapping is! Map || type == null) return;
    c.controller.setExternalError(c.field.id, 'Loading linked record...');
    try {
      final data = mapping.keys.every(row.containsKey)
          ? row
          : await ShipKiaApiScope.maybeOf(c.buildContext)!.request<Object?>(
              ApiRequestConfig(
                method: HttpMethod.get,
                path:
                    '/oms/${Uri.encodeComponent('$type')}/records/${Uri.encodeComponent('$value')}',
                showErrorMessage: false,
              ),
            );
      if (!c.buildContext.mounted || c.controller.values[c.field.id] != value) {
        return;
      }
      final raw = data is Map ? data['value'] ?? data : null;
      if (raw is! Map) {
        throw const FormatException('Linked record unavailable.');
      }
      for (final entry in mapping.entries) {
        final target = c.controller.schema.fields
            .where((f) => f.id == '${entry.value}')
            .firstOrNull;
        if (target == null) continue;
        final converted = const ApiFormAdapter()
            .field(
              Map<String, dynamic>.from(target.metadata),
              values: {target.id: raw[entry.key]},
            )
            .initialValue;
        c.controller.setValue(target.id, converted);
      }
      c.controller.setExternalError(c.field.id, null);
    } catch (_) {
      if (c.buildContext.mounted && c.controller.values[c.field.id] == value) {
        c.controller.setExternalError(
          c.field.id,
          'Unable to load linked details. Choose the record again.',
        );
      }
    }
  }

  void search(String value) {
    setState(() => open = true);
    options.setQuery((page, rows, token) async {
      final field = widget.context.field;
      final type =
          field.metadata['object_type'] ?? field.metadata['objectType'];
      if (field.options.isNotEmpty || type == null) {
        return RecordPage(
          records: [
            for (final option in field.options)
              if (option.label.toLowerCase().contains(value.toLowerCase()))
                <String, dynamic>{
                  'id': option.value,
                  'label': option.label,
                  'disabled': !option.enabled,
                },
          ],
          totalPages: 1,
        );
      }
      final api = ShipKiaApiScope.maybeOf(context);
      if (api == null) throw StateError('Connection unavailable');
      final result = await api.request<Object?>(
        ApiRequestConfig(
          method: HttpMethod.get,
          path: type == 'roles'
              ? '/auth/users/roles'
              : '/oms/${Uri.encodeComponent('$type')}/options',
          params: {
            'page': page,
            'rows': rows,
            'search': value,
            if (field.metadata['src_obj'] != null)
              'src_obj': field.metadata['src_obj'],
            if (field.metadata['view'] != null) 'view': field.metadata['view'],
          },
          cancelToken: token,
          showErrorMessage: false,
        ),
      );
      if (result is List) {
        return RecordPage(
          records: [
            for (final row in result)
              if ('$row'.toLowerCase().contains(value.toLowerCase()))
                row is Map
                    ? Map<String, dynamic>.from(row)
                    : <String, dynamic>{'id': row, 'label': '$row'},
          ],
          totalPages: 1,
        );
      }
      return RecordPage.fromJson(result, (r) => r);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    text.dispose();
    focus.dispose();
    options.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.context;
    return TextFieldTapRegion(
      onTapOutside: (_) {
        timer?.cancel();
        focus.unfocus();
        setState(() => open = false);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            controller: text,
            focusNode: focus,
            readOnly: !c.canEdit,
            decoration: InputDecoration(
              labelText: '${c.field.label}${c.isRequired ? ' *' : ''}',
              hintText: 'Search ${c.field.label.toLowerCase()}',
              errorText: c.errorText,
              suffixIcon: IconButton(
                tooltip: text.text.isEmpty
                    ? 'Choose ${c.field.label}'
                    : 'Clear ${c.field.label}',
                icon: Icon(text.text.isEmpty ? Icons.search : Icons.close),
                onPressed: !c.canEdit
                    ? null
                    : () {
                        timer?.cancel();
                        if (text.text.isNotEmpty) {
                          text.clear();
                          c.onChanged(null);
                          c.controller.setExternalError(c.field.id, null);
                          setState(() => open = false);
                        } else {
                          focus.requestFocus();
                          search('');
                        }
                      },
              ),
            ),
            onTap: c.canEdit ? () => search('') : null,
            onChanged: !c.canEdit
                ? null
                : (value) {
                    setState(() => open = false);
                    c.onChanged(widget.allowFreeText ? value : null);
                    c.controller.setExternalError(
                      c.field.id,
                      widget.allowFreeText
                          ? null
                          : 'Choose ${c.field.label.toLowerCase()} from the results.',
                    );
                    timer?.cancel();
                    timer = Timer(
                      const Duration(milliseconds: 300),
                      () => search(value),
                    );
                  },
          ),
          if (open && c.canEdit)
            ListenableBuilder(
              listenable: options,
              builder: (context, _) => Container(
                constraints: const BoxConstraints(maxHeight: 230),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  children: [
                    if (options.loading) const LinearProgressIndicator(),
                    if (options.error != null)
                      ListTile(
                        title: Text(options.error!.message),
                        trailing: TextButton(
                          onPressed: options.retry,
                          child: const Text('Retry'),
                        ),
                      ),
                    if (!options.loading &&
                        options.error == null &&
                        options.records.isEmpty)
                      const ListTile(title: Text('No matching options')),
                    for (final (index, row) in options.records.indexed)
                      Material(
                        color: index.isEven
                            ? Theme.of(context).colorScheme.surface
                            : Theme.of(context).colorScheme.surfaceContainerLow,
                        child: ListTile(
                          dense: true,
                          title: Text(
                            '${row['label'] ?? row['name'] ?? row['id']}',
                          ),
                          subtitle: row['description'] == null
                              ? null
                              : Text('${row['description']}'),
                          enabled: row['disabled'] != true,
                          onTap: () => select(row),
                        ),
                      ),
                    if (options.hasMore)
                      TextButton(
                        onPressed: options.loadingMore
                            ? null
                            : options.loadMore,
                        child: const Text('More options'),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
