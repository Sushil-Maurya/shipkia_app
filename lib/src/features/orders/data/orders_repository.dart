import 'package:dio/dio.dart';

import '../../../core/api/api.dart';
import '../../../core/api/record_page.dart';
import '../../../core/api/record_units.dart';
import '../domain/order_list_filters.dart';
import '../domain/order_summary.dart';

class OrdersRepository {
  const OrdersRepository(this.api);
  final ApiClient api;

  Future<RecordPage<OrderSummary>> list({
    required int page,
    required int pageSize,
    required CancelToken cancelToken,
    String? stage,
    String? search,
    OrderListFilters filters = const OrderListFilters(),
  }) async {
    final data = await api.request<Object?>(
      ApiRequestConfig(
        method: HttpMethod.post,
        path: OrderEndpoints.recordsList,
        params: {'page': '$page', 'rows': '$pageSize'},
        data: filters.toPayload(stage: stage, search: search),
        cancelToken: cancelToken,
        showErrorMessage: false,
      ),
    );
    return RecordPage.fromJson(data, (record) {
      _validateIdentity(record);
      return OrderSummary.fromJson(
        RecordUnits.displayCurrencies(
          record,
          data is Map ? data['fields'] : null,
        ),
      );
    });
  }

  Future<Map<String, dynamic>> detail(String id, CancelToken token) async {
    final data = await api.request<Object?>(
      ApiRequestConfig(
        method: HttpMethod.get,
        path: OrderEndpoints.recordById(id),
        cancelToken: token,
        showErrorMessage: false,
      ),
    );
    if (data is! Map) throw const FormatException('Expected an order record.');
    final raw = data['value'] ?? data;
    if (raw is! Map) throw const FormatException('Expected order values.');
    final record = Map<String, dynamic>.from(raw);
    _validateIdentity(record);
    return RecordUnits.displayCurrencies(record, data['fields']);
  }

  Future<Map<String, dynamic>> formRecord(String id, CancelToken token) async {
    final data = await api.request<Object?>(
      ApiRequestConfig(
        method: HttpMethod.get,
        path: OrderEndpoints.recordById(id),
        cancelToken: token,
        showErrorMessage: false,
      ),
    );
    if (data is! Map) throw const FormatException('Expected an order record.');
    final raw = data['value'] ?? data;
    if (raw is! Map) throw const FormatException('Expected order values.');
    _validateIdentity(Map<String, dynamic>.from(raw));
    return {'value': Map<String, dynamic>.from(raw), 'fields': data['fields']};
  }

  Future<Object?> fields(CancelToken token) => api.request<Object?>(
    ApiRequestConfig(
      method: HttpMethod.get,
      path: '/oms/orders/records/fields',
      cancelToken: token,
      showErrorMessage: false,
    ),
  );

  Future<bool> canUpdate(CancelToken token) async {
    try {
      final data = await api.request<Object?>(
        ApiRequestConfig(
          method: HttpMethod.get,
          path: '/oms/orders/permissions',
          cancelToken: token,
          showErrorMessage: false,
        ),
      );
      return data is Map && data['update'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<void> update(
    String id,
    Map<String, Object?> changes,
    CancelToken token,
  ) async {
    await api.request<Object?>(
      ApiRequestConfig(
        method: HttpMethod.patch,
        path: OrderEndpoints.recordById(id),
        data: changes,
        cancelToken: token,
        showErrorMessage: false,
      ),
    );
  }

  static void _validateIdentity(Map<String, dynamic> record) {
    if (![record['name'], record['id'], record['row_id']].any(
      (value) =>
          (value is String || value is num) &&
          value.toString().trim().isNotEmpty,
    )) {
      throw const FormatException('Order record has no identity.');
    }
  }
}
