import 'package:shipkia_app/src/core/api/api.dart';

class RecordingApiClient implements ApiClient {
  RecordingApiClient(this.respond);
  final Future<Object?> Function(ApiRequestConfig) respond;
  final requests = <ApiRequestConfig>[];
  @override
  Future<T> request<T>(
    ApiRequestConfig config, {
    ApiJsonParser<T>? fromJson,
  }) async {
    requests.add(config);
    final data = await respond(config);
    return fromJson == null ? data as T : fromJson(data);
  }

  @override
  Future<ApiResponse<T>> requestResponse<T>(
    ApiRequestConfig config, {
    ApiJsonParser<T>? fromJson,
  }) => throw UnimplementedError();
}

Map<String, dynamic> orderFixture(String id, {String stage = 'New'}) => {
  'id': id,
  'name': id,
  'awb': 'AWB-$id',
  'delivery_full_name': 'Test customer',
  'delivery_city': 'Delhi',
  'payment_method': 'cod',
  'total_order_value': '2499.50',
  'stage': stage,
  'created_at': '2026-09-01T10:00:00Z',
};

Map<String, dynamic> pageFixture(
  List<Object?> records, {
  int? total,
  int? pages,
}) => {
  'values': records,
  'pages': {'totalRecords': total ?? records.length, 'totalPages': ?pages},
};
