import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../feedback/feedback_mapper.dart';
import '../feedback/shipkia_feedback.dart';
import 'api_exception.dart';
import 'api_request_config.dart';
import 'api_response.dart';
import 'api_token_provider.dart';
import 'endpoints/auth.dart';
import 'environment_config.dart';
import 'network_config.dart';

typedef ApiJsonParser<T> = T Function(dynamic data);
typedef SessionExpiredCallback = void Function();

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
    SessionExpiredCallback? onSessionExpired,
    Map<String, dynamic>? commonHeaders,
    NetworkConfig? networkConfig,
    Duration? connectTimeout,
    Duration? receiveTimeout,
  }) : _dio =
           dio ??
           _createDio(
             networkConfig ?? EnvironmentConfig.networkConfig,
             commonHeaders: commonHeaders,
             connectTimeout: connectTimeout,
             receiveTimeout: receiveTimeout,
           ),
       _feedbackHandler = feedbackHandler ?? const ShipKiaApiFeedbackHandler() {
    _dio.interceptors.add(
      _AuthInterceptor(
        dio: _dio,
        tokenProvider: tokenProvider,
        onSessionExpired: onSessionExpired,
      ),
    );
  }

  static const _requestHeadersExtraKey = '_shipkiaRequestHeaders';
  static const _requiresAuthExtraKey = '_shipkiaRequiresAuth';
  static const _skipTokenRefreshExtraKey = '_shipkiaSkipTokenRefresh';
  static const _hasRetriedAuthExtraKey = '_shipkiaHasRetriedAuth';

  final Dio _dio;
  final ApiFeedbackHandler? _feedbackHandler;

  static Dio _createDio(
    NetworkConfig config, {
    Map<String, dynamic>? commonHeaders,
    Duration? connectTimeout,
    Duration? receiveTimeout,
  }) {
    return Dio(
      BaseOptions(
        baseUrl: config.resolvedBaseUrl,
        connectTimeout: connectTimeout ?? config.timeout,
        receiveTimeout: receiveTimeout ?? config.timeout,
        headers: {
          Headers.acceptHeader: Headers.jsonContentType,
          ...?commonHeaders,
        },
        extra: const {'withCredentials': true},
      ),
    );
  }

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
      } on ApiException catch (exception) {
        _showErrorFeedback(config, exception);
        rethrow;
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
        'withCredentials': true,
        ...?config.extra,
        _requiresAuthExtraKey: config.requiresAuth,
        _skipTokenRefreshExtraKey:
            config.extra?[_skipTokenRefreshExtraKey] == true,
        if (config.headers != null) _requestHeadersExtraKey: config.headers,
      },
    );
  }

  ApiResponse<T> _parseResponse<T>(
    Response<Object?> response,
    ApiJsonParser<T>? fromJson,
  ) {
    final envelope = _unwrapEnvelope(response.data, response.statusCode);
    final parsed = _parseData<T>(envelope.data, fromJson);
    return ApiResponse<T>(
      data: parsed,
      statusCode: response.statusCode,
      message: envelope.message,
      headers: response.headers.map,
    );
  }

  ({Object? data, String? message}) _unwrapEnvelope(
    Object? data,
    int? httpStatusCode,
  ) {
    if (data is! Map) return (data: data, message: null);

    final json = Map<String, dynamic>.from(data);
    final message = _messageFrom(json);
    if (json.containsKey('statusCode') && json.containsKey('result')) {
      final statusCode = _intFrom(json['statusCode']) ?? httpStatusCode;
      if (statusCode != null && statusCode >= 400) {
        throw ApiExceptionMapper.fromEnvelope(
          data: json,
          statusCode: statusCode,
          message: message,
        );
      }
      return (data: json['result'], message: message);
    }

    if (json.containsKey('success')) {
      if (json['success'] == false) {
        throw ApiExceptionMapper.fromEnvelope(
          data: json,
          statusCode: httpStatusCode,
          message: message,
        );
      }
      return (data: json['result'], message: message);
    }

    return (data: data, message: message);
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

  int? _intFrom(Object? value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
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

class _AuthInterceptor extends QueuedInterceptor {
  _AuthInterceptor({
    required Dio dio,
    required ApiTokenProvider tokenProvider,
    SessionExpiredCallback? onSessionExpired,
  }) : this._(dio, tokenProvider, onSessionExpired);

  _AuthInterceptor._(this._dio, this._tokenProvider, this._onSessionExpired);

  final Dio _dio;
  final ApiTokenProvider _tokenProvider;
  final SessionExpiredCallback? _onSessionExpired;
  Future<String?>? _refreshInFlight;

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

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _captureRefreshCookie(response.headers).then(
      (_) => handler.next(response),
      onError: (Object error, StackTrace stackTrace) {
        handler.reject(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
            error: error,
            stackTrace: stackTrace,
          ),
        );
      },
    );
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _handleUnauthorized(err).then(
      (response) {
        if (response == null) {
          handler.next(err);
        } else {
          handler.resolve(response);
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        if (error is DioException) {
          handler.next(error);
          return;
        }
        handler.next(
          DioException(
            requestOptions: err.requestOptions,
            response: err.response,
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

    final refreshToken = await _tokenProvider.getRefreshToken();
    if (!kIsWeb && refreshToken != null && refreshToken.trim().isNotEmpty) {
      headers['Cookie'] = _cookieHeaderWithRefreshToken(
        headers['Cookie'],
        refreshToken,
      );
    }

    if (requestHeaders is Map<String, dynamic>) {
      headers.addAll(requestHeaders);
    }

    options.headers
      ..clear()
      ..addAll(headers);
  }

  Future<Response<Object?>?> _handleUnauthorized(DioException error) async {
    final response = error.response;
    final options = error.requestOptions;
    if (response?.statusCode != 401) return null;
    if (options.extra[DioApiClient._requiresAuthExtraKey] == false) {
      return null;
    }
    if (options.extra[DioApiClient._skipTokenRefreshExtraKey] == true) {
      await _expireSession();
      return null;
    }
    if (options.extra[DioApiClient._hasRetriedAuthExtraKey] == true) {
      await _expireSession();
      return null;
    }

    final accessToken = await _refreshToken();
    if (accessToken == null || accessToken.trim().isEmpty) {
      await _expireSession();
      return null;
    }

    final retryOptions = _copyForRetry(options);
    retryOptions.extra[DioApiClient._hasRetriedAuthExtraKey] = true;
    retryOptions.headers['Authorization'] = 'Bearer $accessToken';
    return _dio.fetch<Object?>(retryOptions);
  }

  Future<String?> _refreshToken() {
    final current = _refreshInFlight;
    if (current != null) return current;
    final refresh = _renewAccessToken().whenComplete(() {
      _refreshInFlight = null;
    });
    _refreshInFlight = refresh;
    return refresh;
  }

  Future<String?> _renewAccessToken() async {
    try {
      final renewDio = Dio(
        BaseOptions(
          baseUrl: _dio.options.baseUrl,
          connectTimeout: _dio.options.connectTimeout,
          sendTimeout: _dio.options.sendTimeout,
          receiveTimeout: _dio.options.receiveTimeout,
          headers: await _renewHeaders(),
          responseType: ResponseType.json,
          contentType: _dio.options.contentType,
          validateStatus: _dio.options.validateStatus,
          extra: const {'withCredentials': true},
        ),
      )..httpClientAdapter = _dio.httpClientAdapter;
      final response = await renewDio.request<Object?>(
        AuthEndpoints.tokenRenew,
        options: Options(method: 'POST'),
      );
      await _captureRefreshCookie(response.headers);
      final data = _unwrapCredentialPayload(response.data);
      final accessToken = _stringValue(data, const ['access_token']);
      final session = _stringValue(data, const ['session']);
      final refreshToken = _stringValue(data, const [
        'refresh_token',
        'refreshToken',
      ]);

      if (accessToken == null || accessToken.trim().isEmpty) return null;
      await _tokenProvider.saveAccessToken(accessToken);
      if (session != null && session.trim().isNotEmpty) {
        await _tokenProvider.saveSessionId(session);
      }
      if (refreshToken != null && refreshToken.trim().isNotEmpty) {
        await _tokenProvider.saveRefreshToken(refreshToken);
      }
      return accessToken;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> _renewHeaders() async {
    final headers = Map<String, dynamic>.of(_dio.options.headers)
      ..remove('Authorization')
      ..remove('authorization');
    final refreshToken = await _tokenProvider.getRefreshToken();
    if (!kIsWeb && refreshToken != null && refreshToken.trim().isNotEmpty) {
      headers['Cookie'] = _cookieHeaderWithRefreshToken(
        headers['Cookie'],
        refreshToken,
      );
    }

    return headers;
  }

  Future<void> _captureRefreshCookie(Headers headers) async {
    final values = headers.map['set-cookie'] ?? headers.map['Set-Cookie'];
    if (values == null) return;

    for (final value in values) {
      final refreshToken = _refreshTokenFromSetCookie(value);
      if (refreshToken == null) continue;
      if (refreshToken.isEmpty) {
        await _tokenProvider.clearRefreshToken();
      } else {
        await _tokenProvider.saveRefreshToken(refreshToken);
      }
    }
  }

  Future<void> _expireSession() async {
    await _tokenProvider.clear();
    _onSessionExpired?.call();
  }

  RequestOptions _copyForRetry(RequestOptions options) {
    return RequestOptions(
      path: options.path,
      method: options.method,
      baseUrl: options.baseUrl,
      queryParameters: Map<String, dynamic>.of(options.queryParameters),
      data: options.data,
      headers: Map<String, dynamic>.of(options.headers),
      extra: Map<String, dynamic>.of(options.extra),
      responseType: options.responseType,
      contentType: options.contentType,
      validateStatus: options.validateStatus,
      receiveDataWhenStatusError: options.receiveDataWhenStatusError,
      followRedirects: options.followRedirects,
      maxRedirects: options.maxRedirects,
      requestEncoder: options.requestEncoder,
      responseDecoder: options.responseDecoder,
      listFormat: options.listFormat,
      connectTimeout: options.connectTimeout,
      sendTimeout: options.sendTimeout,
      receiveTimeout: options.receiveTimeout,
    );
  }

  Map<String, dynamic> _unwrapCredentialPayload(Object? data) {
    if (data is! Map) return const <String, dynamic>{};
    final json = Map<String, dynamic>.from(data);
    final nested = json['result'] ?? json['data'];
    if (nested is Map) return Map<String, dynamic>.from(nested);
    return json;
  }

  String? _stringValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String) return value;
    }
    return null;
  }

  String _cookieHeaderWithRefreshToken(Object? currentHeader, String token) {
    final values = <String>[];
    if (currentHeader is String && currentHeader.trim().isNotEmpty) {
      values.addAll(
        currentHeader
            .split(';')
            .map((value) => value.trim())
            .where(
              (value) =>
                  value.isNotEmpty &&
                  !value.toLowerCase().startsWith('refresh_token='),
            ),
      );
    }
    values.add('refresh_token=$token');
    return values.join('; ');
  }

  String? _refreshTokenFromSetCookie(String header) {
    for (final part in header.split(';')) {
      final trimmed = part.trim();
      final separator = trimmed.indexOf('=');
      if (separator <= 0) continue;
      final name = trimmed.substring(0, separator).trim().toLowerCase();
      if (name != 'refresh_token') continue;
      return trimmed.substring(separator + 1).trim();
    }
    return null;
  }
}
