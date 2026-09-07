import 'package:dio/dio.dart';

import '../feedback/feedback_mapper.dart';
import '../feedback/shipkia_feedback.dart';
import 'api_exception.dart';
import 'api_request_config.dart';
import 'api_response.dart';
import 'api_token_provider.dart';

typedef ApiJsonParser<T> = T Function(dynamic data);

abstract interface class ApiClient {
  Future<T> request<T>(ApiRequestConfig config, {ApiJsonParser<T>? fromJson});

  Future<ApiResponse<T>> requestResponse<T>(
    ApiRequestConfig config, {
    ApiJsonParser<T>? fromJson,
  });
}

abstract interface class ApiFeedbackHandler {
  void success(String message, {String? eventKey});

  void error(
    Object error, {
    int? statusCode,
    String? message,
    String? eventKey,
  });
}

class ShipKiaApiFeedbackHandler implements ApiFeedbackHandler {
  const ShipKiaApiFeedbackHandler();

  @override
  void success(String message, {String? eventKey}) {
    ShipKiaFeedback.success(message, eventKey: eventKey);
  }

  @override
  void error(
    Object error, {
    int? statusCode,
    String? message,
    String? eventKey,
  }) {
    ShipKiaFeedback.apiError(
      error,
      statusCode: statusCode,
      eventKey: eventKey,
      userSafeMessage: message,
    );
  }
}

class DioApiClient implements ApiClient {
  DioApiClient({
    Dio? dio,
    required ApiTokenProvider tokenProvider,
    ApiFeedbackHandler? feedbackHandler,
    Map<String, dynamic>? commonHeaders,
    Duration connectTimeout = const Duration(seconds: 20),
    Duration receiveTimeout = const Duration(seconds: 30),
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               connectTimeout: connectTimeout,
               receiveTimeout: receiveTimeout,
               headers: {
                 Headers.acceptHeader: Headers.jsonContentType,
                 ...?commonHeaders,
               },
             ),
           ),
       _feedbackHandler = feedbackHandler ?? const ShipKiaApiFeedbackHandler() {
    _dio.interceptors.add(_AuthHeaderInterceptor(tokenProvider));
  }

  static const _requestHeadersExtraKey = '_shipkiaRequestHeaders';
  static const _requiresAuthExtraKey = '_shipkiaRequiresAuth';

  final Dio _dio;
  final ApiFeedbackHandler? _feedbackHandler;

  @override
  Future<T> request<T>(
    ApiRequestConfig config, {
    ApiJsonParser<T>? fromJson,
  }) async {
    final response = await requestResponse<T>(config, fromJson: fromJson);
    return response.data as T;
  }

  @override
  Future<ApiResponse<T>> requestResponse<T>(
    ApiRequestConfig config, {
    ApiJsonParser<T>? fromJson,
  }) async {
    var attempt = 0;
    while (true) {
      try {
        final response = await _dio.request<Object?>(
          config.path,
          data: config.data,
          queryParameters: config.params,
          cancelToken: config.cancelToken,
          options: _optionsFor(config),
          onSendProgress: config.onSendProgress,
          onReceiveProgress: config.onReceiveProgress,
        );
        final apiResponse = _parseResponse<T>(response, fromJson);
        _showSuccessFeedback(config, apiResponse);
        return apiResponse;
      } on DioException catch (error) {
        final exception = ApiExceptionMapper.fromDio(error);
        if (_shouldRetry(config, exception, attempt)) {
          attempt += 1;
          await Future<void>.delayed(config.retry.retryDelay);
          continue;
        }
        _showErrorFeedback(config, exception);
        throw exception;
      } on Object catch (error) {
        final exception = ApiExceptionMapper.unknown(error);
        _showErrorFeedback(config, exception);
        throw exception;
      }
    }
  }

  Options _optionsFor(ApiRequestConfig config) {
    return Options(
      method: config.method.value,
      responseType: config.responseType,
      connectTimeout: config.connectTimeout,
      sendTimeout: config.sendTimeout,
      receiveTimeout: config.receiveTimeout,
      extra: {
        ...?config.extra,
        _requiresAuthExtraKey: config.requiresAuth,
        if (config.headers != null) _requestHeadersExtraKey: config.headers,
      },
    );
  }

  ApiResponse<T> _parseResponse<T>(
    Response<Object?> response,
    ApiJsonParser<T>? fromJson,
  ) {
    final data = response.data;
    final parsed = _parseData<T>(data, fromJson);
    return ApiResponse<T>(
      data: parsed,
      statusCode: response.statusCode,
      message: _messageFrom(data),
      headers: response.headers.map,
    );
  }

  T? _parseData<T>(Object? data, ApiJsonParser<T>? fromJson) {
    if (fromJson != null) return fromJson(data);
    if (data == null) return null;
    if (data is T) return data as T;
    throw ApiException(
      type: ShipKiaApiFailureType.unknown,
      message: 'The server response did not match the expected format.',
      responseData: data,
    );
  }

  String? _messageFrom(Object? data) {
    if (data is Map) {
      final value = data['message'];
      if (value is String && value.trim().isNotEmpty) return value;
    }
    return null;
  }

  bool _shouldRetry(ApiRequestConfig config, ApiException error, int attempt) {
    if (!config.retry.enabled) return false;
    if (attempt >= config.retry.maxAttempts - 1) return false;
    if (config.cancelToken?.isCancelled ?? false) return false;
    if (!_isRetrySafe(config)) return false;
    return switch (error.type) {
      ShipKiaApiFailureType.timeout ||
      ShipKiaApiFailureType.network ||
      ShipKiaApiFailureType.server => true,
      _ => false,
    };
  }

  bool _isRetrySafe(ApiRequestConfig config) {
    if (config.method == HttpMethod.get) return true;
    if (config.method == HttpMethod.put) return true;
    if (config.method == HttpMethod.delete) return true;
    final idempotencyKey = config.extra?['idempotencyKey'];
    return idempotencyKey is String && idempotencyKey.trim().isNotEmpty;
  }

  void _showSuccessFeedback<T>(
    ApiRequestConfig config,
    ApiResponse<T> response,
  ) {
    if (!config.showSuccessMessage) return;
    final message = config.successMessage ?? response.message;
    if (message == null || message.trim().isEmpty) return;
    _feedbackHandler?.success(message, eventKey: config.path);
  }

  void _showErrorFeedback(ApiRequestConfig config, ApiException exception) {
    if (!config.showErrorMessage) return;
    if (exception.type == ShipKiaApiFailureType.cancelled) return;
    _feedbackHandler?.error(
      exception,
      statusCode: exception.statusCode,
      message: config.errorMessage ?? exception.message,
      eventKey: config.path,
    );
  }
}

class _AuthHeaderInterceptor extends Interceptor {
  _AuthHeaderInterceptor(this._tokenProvider);

  final ApiTokenProvider _tokenProvider;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _applyHeaders(options).then(
      (_) => handler.next(options),
      onError: (Object error, StackTrace stackTrace) {
        handler.reject(
          DioException(
            requestOptions: options,
            error: error,
            stackTrace: stackTrace,
          ),
        );
      },
    );
  }

  Future<void> _applyHeaders(RequestOptions options) async {
    final headers = Map<String, dynamic>.of(options.headers);
    final requiresAuth =
        options.extra[DioApiClient._requiresAuthExtraKey] != false;
    final requestHeaders = options.extra[DioApiClient._requestHeadersExtraKey];

    if (requiresAuth) {
      final token = await _tokenProvider.getAccessToken();
      if (token != null && token.trim().isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    if (requestHeaders is Map<String, dynamic>) {
      headers.addAll(requestHeaders);
    }

    options.headers
      ..clear()
      ..addAll(headers);
  }
}
