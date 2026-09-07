import 'package:dio/dio.dart';

import '../feedback/feedback_mapper.dart';

class ApiException implements Exception {
  const ApiException({
    required this.type,
    required this.message,
    this.statusCode,
    this.responseData,
    this.cause,
  });

  final ShipKiaApiFailureType type;
  final String message;
  final int? statusCode;
  final Object? responseData;
  final Object? cause;

  @override
  String toString() => 'ApiException($type, $statusCode, $message)';
}

class ApiExceptionMapper {
  const ApiExceptionMapper._();

  static ApiException fromDio(DioException error) {
    final statusCode = error.response?.statusCode;
    final type = switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => ShipKiaApiFailureType.timeout,
      DioExceptionType.cancel => ShipKiaApiFailureType.cancelled,
      DioExceptionType.connectionError => ShipKiaApiFailureType.network,
      DioExceptionType.badResponse =>
        ShipKiaFeedbackMapper.failureTypeForStatusCode(statusCode),
      _ => ShipKiaApiFailureType.unknown,
    };

    return ApiException(
      type: type,
      statusCode: statusCode,
      responseData: error.response?.data,
      cause: error,
      message: _messageFrom(error.response?.data) ?? _messageFor(type),
    );
  }

  static ApiException unknown(Object error) {
    return ApiException(
      type: ShipKiaApiFailureType.unknown,
      message: _messageFor(ShipKiaApiFailureType.unknown),
      cause: error,
    );
  }

  static String? _messageFrom(Object? data) {
    if (data is Map) {
      final value = data['message'] ?? data['error'];
      if (value is String && value.trim().isNotEmpty) return value;
    }
    return null;
  }

  static String _messageFor(ShipKiaApiFailureType type) {
    return ShipKiaFeedbackMapper.fromFailureType(type).message;
  }
}
