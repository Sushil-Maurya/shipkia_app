import 'package:dio/dio.dart';

enum HttpMethod { get, post, put, patch, delete }

extension HttpMethodName on HttpMethod {
  String get value => switch (this) {
    HttpMethod.get => 'GET',
    HttpMethod.post => 'POST',
    HttpMethod.put => 'PUT',
    HttpMethod.patch => 'PATCH',
    HttpMethod.delete => 'DELETE',
  };
}

class RetryConfig {
  const RetryConfig({
    this.enabled = false,
    this.maxAttempts = 1,
    this.retryDelay = const Duration(milliseconds: 350),
  }) : assert(maxAttempts >= 1, 'maxAttempts must be at least 1');

  final bool enabled;
  final int maxAttempts;
  final Duration retryDelay;

  static const disabled = RetryConfig();
}

class ApiRequestConfig {
  const ApiRequestConfig({
    required this.method,
    required this.path,
    this.data,
    this.params,
    this.headers,
    this.requiresAuth = true,
    this.showSuccessMessage = false,
    this.showErrorMessage = true,
    this.successMessage,
    this.errorMessage,
    this.connectTimeout,
    this.sendTimeout,
    this.receiveTimeout,
    this.cancelToken,
    this.responseType,
    this.extra,
    this.retry = RetryConfig.disabled,
    this.onSendProgress,
    this.onReceiveProgress,
  });

  final HttpMethod method;
  final String path;
  final Object? data;
  final Map<String, dynamic>? params;
  final Map<String, dynamic>? headers;
  final bool requiresAuth;
  final bool showSuccessMessage;
  final bool showErrorMessage;
  final String? successMessage;
  final String? errorMessage;
  final Duration? connectTimeout;
  final Duration? sendTimeout;
  final Duration? receiveTimeout;
  final CancelToken? cancelToken;
  final ResponseType? responseType;
  final Map<String, dynamic>? extra;
  final RetryConfig retry;
  final ProgressCallback? onSendProgress;
  final ProgressCallback? onReceiveProgress;
}
