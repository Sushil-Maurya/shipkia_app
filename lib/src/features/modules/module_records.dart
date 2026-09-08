import 'module_list_tabs.dart';

import 'package:dio/dio.dart';

import '../../core/api/api.dart';
import '../../core/api/record_page.dart';
import '../../core/api/record_units.dart';
import '../../core/router/web_module_catalog.dart';

String fieldLabel(String key) => key
    .replaceAll('_', ' ')
    .split(' ')
    .map((v) => v.isEmpty ? v : '${v[0].toUpperCase()}${v.substring(1)}')
    .join(' ');
bool privateField(String key) => RegExp(
  r'password|token|secret|api_key',
  caseSensitive: false,
).hasMatch(key);

class RecordField {
  RecordField(this.json);
  final Map<String, dynamic> json;
  String get name => '${json['name'] ?? json['id'] ?? ''}';
  String get label => '${json['label'] ?? fieldLabel(name)}';
  String get type => '${json['type'] ?? 'text'}';
  String? get objectType => json['object_type']?.toString();
  bool get visible => !privateField(name) && json['hidden'] != true;
  List<RecordField> get children => parseFields(json['fields']);
  String format(Object? value) {
    if (value == null || value == '') return 'Not set';
    if (type == 'boolean' || value is bool) {
      return value == true || value == 1 || value == 'true' ? 'Yes' : 'No';
    }
    final number = num.tryParse('$value');
    if (type == 'unit' && number != null) {
      final category = RecordUnits.category(json);
      final display = RecordUnits.toDisplay(number, category);
      if (category == 'currency') return 'INR ${display.toStringAsFixed(2)}';
      if (category == 'weight') return '${_decimal(display)} kg';
      if (category == 'length') return '${_decimal(display)} cm';
    }
    if (type == 'datetime') {
      final date = DateTime.tryParse('$value')?.toLocal();
      if (date != null) {
        return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      }
    }
    if (name == 'rate' && number != null) return '${_decimal(number)}%';
    return '$value';
  }

  static String _decimal(num n) =>
      n.toStringAsFixed(3).replaceFirst(RegExp(r'\.?0+$'), '');
}

List<RecordField> parseFields(Object? raw) => raw is List
    ? raw
          .whereType<Map>()
          .map((f) => RecordField(Map<String, dynamic>.from(f)))
          .toList()
    : [];

class ModuleRecord {
  ModuleRecord(this.values, this.fields, {String? requestedId})
    : id =
          requestedId ??
          '${values['id'] ?? values['name'] ?? values['row_id'] ?? ''}';
  final String id;
  final Map<String, dynamic> values;
  final List<RecordField> fields;
  String get title {
    for (final key in [
      'product_name',
      'account_name',
      'company_name',
      'full_name',
      'subject',
      'first_name',
      'name',
      'type',
      'id',
    ]) {
      if (values[key] != null && '${values[key]}'.trim().isNotEmpty) {
        return '${values[key]}';
      }
    }
    return id;
  }

  bool get primary => values['is_primary'] == true || values['is_primary'] == 1;
  List<RecordField> get displayFields {
    final declared = fields.map((f) => f.name).toSet();
    return [
      ...fields.where((f) => f.visible),
      ...values.keys
          .where((k) => !declared.contains(k) && !privateField(k))
          .map((k) => RecordField({'name': k})),
    ];
  }

  factory ModuleRecord.detail(Object? data, String id) {
    if (data is! Map) throw const FormatException('Expected record details.');
    final raw = data['value'] ?? data;
    if (raw is! Map) throw const FormatException('Expected record values.');
    return ModuleRecord(
      {
        ...Map<String, dynamic>.from(raw),
        if (data['is_primary'] != null) 'is_primary': data['is_primary'],
      },
      parseFields(data['fields']),
      requestedId: id,
    );
  }
}

class ModuleRepository {
  const ModuleRepository(this.api, this.route);
  final ApiClient api;
  final WebModuleRoute route;
  String get base => route.objectType == 'users'
      ? '/auth/users'
      : '/oms/${route.objectType}/records';
  static const searchFields = <String, List<String>>{
    'products': ['product_name'],
    'bank_accounts': ['account_name', 'bank', 'account_number', 'ifsc_code'],
    'pickup_address': ['city', 'complete_address', 'postal_code'],
    'print_template': ['name', 'type'],
    'return_orders': ['id', 'reference_id', 'awb', 'phone', 'postal_code'],
    'delivery_attempt': ['order_id', 'awb'],
    'customers': ['first_name', 'last_name'],
    'pickup_and_manifest': ['id', 'courier_partner'],
    'remittances': ['awb', 'partner', 'order_id'],
  };
  Future<RecordPage<ModuleRecord>> list(
    int page,
    int size,
    CancelToken token, {
    String search = '',
    ModuleListTab? tab,
  }) async {
    final keys = searchFields[route.objectType];
    final query = search.trim();
    final data = await api.request<Object?>(
      ApiRequestConfig(
        method: route.method,
        path:
            route.endpoint ??
            WebModuleCatalog.listEndpointFor(route.objectType!),
        params: {
          'page': '$page',
          'rows': '$size',
          if (query.isNotEmpty && keys == null) 'search': query,
        },
        data:
            query.isEmpty && tab?.filter == null ||
                keys == null && tab?.filter == null
            ? const []
            : {
                'filters': {
                  'id': 'query',
                  'type': 'nested',
                  'connector': 'and',
                  'filterSet': [
                    if (tab?.filter != null) tab!.filter!,
                    if (query.isNotEmpty && keys != null)
                      {
                        'id': 'search-fields',
                        'type': 'nested',
                        'connector': 'or',
                        'filterSet': keys
                            .map(
                              (key) => {
                                'id': key,
                                'opr': 'contains',
                                'value': query,
                              },
                            )
                            .toList(),
                      },
                  ],
                },
              },
        cancelToken: token,
        showErrorMessage: false,
      ),
    );
    final fields = parseFields(data is Map ? data['fields'] : null);
    return RecordPage.fromJson(data, (row) {
      final record = ModuleRecord(row, fields);
      if (record.id.isEmpty) {
        throw const FormatException('Record has no identity.');
      }
      return record;
    });
  }

  Future<Object?> fields(CancelToken token) => api.request<Object?>(
    ApiRequestConfig(
      method: HttpMethod.get,
      path: '$base/fields',
      cancelToken: token,
      showErrorMessage: false,
    ),
  );
  Future<void> save(
    Map<String, Object?> values,
    CancelToken token, {
    String? id,
  }) async {
    await api.request<Object?>(
      ApiRequestConfig(
        method: id == null ? HttpMethod.post : HttpMethod.patch,
        path: id == null ? base : '$base/${Uri.encodeComponent(id)}',
        data: values,
        cancelToken: token,
        showErrorMessage: false,
      ),
    );
  }

  Future<ModuleRecord> detail(String id, CancelToken token) async =>
      ModuleRecord.detail(
        await api.request<Object?>(
          ApiRequestConfig(
            method: HttpMethod.get,
            path: '$base/${Uri.encodeComponent(id)}',
            cancelToken: token,
            showErrorMessage: false,
          ),
        ),
        id,
      );
}
