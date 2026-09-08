import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

import '../../../core/api/api.dart';

class OrderActionsRepository {
  const OrderActionsRepository(this.api);
  final ApiClient api;
  Future<Map<String, dynamic>> permissions(
    String type,
    CancelToken token,
  ) async {
    final result = await api.request<Object?>(
      ApiRequestConfig(
        method: HttpMethod.get,
        path: '/oms/$type/permissions',
        cancelToken: token,
        showErrorMessage: false,
      ),
    );
    return result is Map ? Map<String, dynamic>.from(result) : {};
  }

  Future<Object?> create(Map<String, Object?> values, CancelToken token) =>
      api.request<Object?>(
        ApiRequestConfig(
          method: HttpMethod.post,
          path: '/oms/orders/records',
          data: values,
          cancelToken: token,
          showErrorMessage: false,
        ),
      );
  Future<List<Map<String, dynamic>>> quotes(
    String id,
    CancelToken token,
  ) async {
    final data = await api.request<Object?>(
      ApiRequestConfig(
        method: HttpMethod.post,
        path: '/oms/shipping/estimated-cost',
        params: {'order_id': id, 'forward': 'true'},
        cancelToken: token,
        showErrorMessage: false,
      ),
    );
    if (data is! Map) throw const FormatException('Expected courier quotes');
    return [
      for (final e in data.entries)
        if (e.value is Map)
          {'name': '${e.key}', ...Map<String, dynamic>.from(e.value as Map)},
    ];
  }

  Future<Map<String, dynamic>> ship(
    String id,
    String quote,
    CancelToken token,
  ) async {
    final result = await api.request<Object?>(
      ApiRequestConfig(
        method: HttpMethod.post,
        path: '/oms/shipping/order',
        data: {'order_id': id, 'quote_id': quote},
        cancelToken: token,
        showErrorMessage: false,
      ),
    );
    if (result is! Map) {
      throw const FormatException('Shipment response unavailable');
    }
    return Map<String, dynamic>.from(result);
  }

  Future<void> schedule(String id, String date, CancelToken token) async {
    await api.request<Object?>(
      ApiRequestConfig(
        method: HttpMethod.post,
        path: '/oms/shipping/order/schedule',
        data: {
          'order_ids': [id],
          'pickup_date': date,
        },
        cancelToken: token,
        showErrorMessage: false,
      ),
    );
  }

  Future<Uint8List> document(String id, String type, CancelToken token) async {
    if (!{'invoice', 'label'}.contains(type)) throw ArgumentError.value(type);
    final result = await api.request<Object?>(
      ApiRequestConfig(
        method: HttpMethod.get,
        path: '/drms/orders/$type',
        params: {'ids': id},
        responseType: ResponseType.bytes,
        cancelToken: token,
        showErrorMessage: false,
      ),
    );
    if (result is! List ||
        result.length < 5 ||
        String.fromCharCodes(result.take(5).cast<int>()) != '%PDF-') {
      throw const FormatException('The server did not return a PDF document.');
    }
    return Uint8List.fromList(result.cast<int>());
  }

  Future<bool> exportDocument(String id, String type, CancelToken token) async {
    final bytes = await document(id, type, token);
    final safeId = id.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    return await const MethodChannel('shipkia/documents').invokeMethod<bool>(
          'exportPdf',
          {'name': '$type-$safeId.pdf', 'bytes': bytes},
        ) ??
        false;
  }
}
