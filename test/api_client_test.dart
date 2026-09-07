import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shipkia_app/src/core/api/api.dart';
import 'package:shipkia_app/src/core/feedback/feedback_mapper.dart';

void main() {
  test('request sends axios-style config through Dio', () async {
    late RequestOptions captured;
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.shipkia.test',
        headers: {
          Headers.acceptHeader: Headers.jsonContentType,
          'X-App-Version': '1.0.0',
        },
      ),
    );
    final client = DioApiClient(
      dio: dio,
      tokenProvider: const StaticApiTokenProvider('shipkia-token'),
    );
    dio.interceptors.add(
      _ResolveInterceptor((options) {
        captured = options;
        return Response<Object?>(
          requestOptions: options,
          statusCode: 200,
          data: {'id': 1, 'status': 'created', 'message': 'Order created'},
        );
      }),
    );

    final order = await client.request<_Order>(
      ApiRequestConfig(
        method: HttpMethod.post,
        path: ApiEndpoints.orders.create,
        data: [
          {'id': 1},
          {'id': 2},
        ],
        params: const {'search': '455'},
        headers: const {'X-Feature': 'orders'},
        showSuccessMessage: true,
      ),
      fromJson: (data) => _Order.fromJson(data as Map<String, dynamic>),
    );

    expect(order.id, 1);
    expect(captured.method, 'POST');
    expect(captured.path, ApiEndpoints.orders.create);
    expect(captured.data, isA<List<Map<String, int>>>());
    expect(captured.queryParameters, {'search': '455'});
    expect(captured.headers['accept'], Headers.jsonContentType);
    expect(captured.headers['Authorization'], 'Bearer shipkia-token');
    expect(captured.headers['X-Feature'], 'orders');
    expect(captured.extra['withCredentials'], isTrue);
  });

  test('unwraps backend success envelopes before parsing', () async {
    final dio = Dio();
    final client = DioApiClient(
      dio: dio,
      tokenProvider: const StaticApiTokenProvider(null),
    );
    dio.interceptors.add(
      _ResolveInterceptor(
        (options) => Response<Object?>(
          requestOptions: options,
          statusCode: 201,
          data: {
            'success': true,
            'message': 'Login successfull.',
            'result': {'session': 'session-token'},
            'traceId': 'fb5a710e-7dbf-400a-ae19-9eb56c369803',
          },
        ),
      ),
    );

    final response = await client.requestResponse<String>(
      const ApiRequestConfig(
        method: HttpMethod.post,
        path: '/auth/login',
        requiresAuth: false,
      ),
      fromJson: (data) => (data as Map<String, dynamic>)['session'] as String,
    );

    expect(response.data, 'session-token');
    expect(response.message, 'Login successfull.');
    expect(response.statusCode, 201);
  });

  test('maps unsuccessful backend envelopes to ApiException', () async {
    final dio = Dio();
    final client = DioApiClient(
      dio: dio,
      tokenProvider: const StaticApiTokenProvider(null),
    );
    dio.interceptors.add(
      _ResolveInterceptor(
        (options) => Response<Object?>(
          requestOptions: options,
          statusCode: 200,
          data: {
            'success': false,
            'message': 'Invalid Credentials.',
            'traceId': '29ee8a79-614e-49e5-ba04-eef4cf027465',
          },
        ),
      ),
    );

    await expectLater(
      client.request<void>(
        const ApiRequestConfig(
          method: HttpMethod.post,
          path: '/auth/login',
          requiresAuth: false,
        ),
      ),
      throwsA(
        isA<ApiException>()
            .having((error) => error.message, 'message', 'Invalid Credentials.')
            .having((error) => error.statusCode, 'statusCode', 200),
      ),
    );
  });

  test('request-specific headers can intentionally override auth', () async {
    late RequestOptions captured;
    final dio = Dio();
    final client = DioApiClient(
      dio: dio,
      tokenProvider: const StaticApiTokenProvider('central-token'),
    );
    dio.interceptors.add(
      _ResolveInterceptor((options) {
        captured = options;
        return Response<Object?>(requestOptions: options, statusCode: 204);
      }),
    );

    await client.request<void>(
      ApiRequestConfig(
        method: HttpMethod.delete,
        path: ApiEndpoints.orders.delete(1),
        headers: {'Authorization': 'Bearer request-token'},
      ),
    );

    expect(captured.headers['Authorization'], 'Bearer request-token');
  });

  test('public requests skip auth and preserve primitive payloads', () async {
    late RequestOptions captured;
    final dio = Dio();
    final client = DioApiClient(
      dio: dio,
      tokenProvider: const StaticApiTokenProvider('private-token'),
    );
    dio.interceptors.add(
      _ResolveInterceptor((options) {
        captured = options;
        return Response<Object?>(
          requestOptions: options,
          statusCode: 200,
          data: true,
        );
      }),
    );

    final accepted = await client.request<bool>(
      ApiRequestConfig(
        method: HttpMethod.post,
        path: ApiEndpoints.auth.login,
        data: 'raw credentials',
        requiresAuth: false,
      ),
    );

    expect(accepted, isTrue);
    expect(captured.data, 'raw credentials');
    expect(captured.headers.containsKey('Authorization'), isFalse);
  });

  test('captures refresh token from Set-Cookie responses', () async {
    final tokenProvider = InMemoryApiTokenProvider();
    final dio = Dio();
    dio.httpClientAdapter = _MockAdapter(
      (options) => ResponseBody.fromString(
        jsonEncode({
          'success': true,
          'result': {'session': 'session-123'},
        }),
        201,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
          'set-cookie': ['refresh_token=refresh-123; Path=/; HttpOnly'],
        },
      ),
    );
    final client = DioApiClient(dio: dio, tokenProvider: tokenProvider);

    await client.request<String>(
      const ApiRequestConfig(
        method: HttpMethod.post,
        path: '/auth/login',
        requiresAuth: false,
      ),
      fromJson: (data) => (data as Map<String, dynamic>)['session'] as String,
    );

    expect(await tokenProvider.getRefreshToken(), 'refresh-123');
  });

  test(
    'protected requests use access token and refresh cookie separately',
    () async {
      late RequestOptions captured;
      final tokenProvider = InMemoryApiTokenProvider()
        ..setAccessToken('access-token');
      await tokenProvider.saveRefreshToken('refresh-token');
      final dio = Dio();
      final client = DioApiClient(dio: dio, tokenProvider: tokenProvider);
      dio.interceptors.add(
        _ResolveInterceptor((options) {
          captured = options;
          return Response<Object?>(
            requestOptions: options,
            statusCode: 200,
            data: {
              'success': true,
              'result': {'ok': true},
            },
          );
        }),
      );

      final result = await client.request<Map<String, dynamic>>(
        const ApiRequestConfig(
          method: HttpMethod.get,
          path: '/auth/users/profile',
        ),
      );

      expect(result, {'ok': true});
      expect(captured.headers['Authorization'], 'Bearer access-token');
      expect(captured.headers['Cookie'], 'refresh_token=refresh-token');
    },
  );

  test(
    '401 responses renew access token with cookie and retry request',
    () async {
      final tokenProvider = InMemoryApiTokenProvider()
        ..setAccessToken('expired-access');
      await tokenProvider.saveRefreshToken('refresh-token');
      final dio = Dio(BaseOptions(baseUrl: 'http://api.shipkia.lcl'));
      final adapter = _MockAdapter((options) {
        if (options.path == '/auth/token/renew') {
          return ResponseBody.fromString(
            jsonEncode({
              'success': true,
              'message': 'Access token generated successfully.',
              'result': {
                'access_token': 'new-access-token',
                'expires_at': '2026-09-07T11:40:12.860Z',
              },
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        if (options.headers['Authorization'] == 'Bearer new-access-token') {
          return ResponseBody.fromString(
            jsonEncode({
              'success': true,
              'result': {'ok': true},
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        return ResponseBody.fromString(
          jsonEncode({'success': false, 'message': 'Unauthorized'}),
          401,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });
      dio.httpClientAdapter = adapter;
      final client = DioApiClient(dio: dio, tokenProvider: tokenProvider);

      final result = await client.request<Map<String, dynamic>>(
        const ApiRequestConfig(method: HttpMethod.get, path: '/orders'),
      );

      expect(result, {'ok': true});
      expect(await tokenProvider.getAccessToken(), 'new-access-token');
      expect(adapter.requests.map((options) => options.path), [
        '/orders',
        '/auth/token/renew',
        '/orders',
      ]);
      final renew = adapter.requests[1];
      expect(renew.data, isNull);
      expect(renew.headers.containsKey('Authorization'), isFalse);
      expect(renew.headers['Cookie'], 'refresh_token=refresh-token');
      expect(
        adapter.requests.last.headers['Authorization'],
        'Bearer new-access-token',
      );
    },
  );

  test('failed token renew expires local credentials', () async {
    var expired = false;
    final tokenProvider = InMemoryApiTokenProvider()
      ..setAccessToken('expired-access')
      ..setSessionId('session-token');
    await tokenProvider.saveRefreshToken('refresh-token');
    final dio = Dio(BaseOptions(baseUrl: 'http://api.shipkia.lcl'));
    dio.httpClientAdapter = _MockAdapter((options) {
      if (options.path == '/auth/token/renew') {
        return ResponseBody.fromString(
          jsonEncode({'success': false, 'message': 'Invalid refresh token'}),
          400,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      }
      return ResponseBody.fromString(
        jsonEncode({'success': false, 'message': 'Unauthorized'}),
        401,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    });
    final client = DioApiClient(
      dio: dio,
      tokenProvider: tokenProvider,
      onSessionExpired: () => expired = true,
    );

    await expectLater(
      client.request<void>(
        const ApiRequestConfig(method: HttpMethod.get, path: '/orders'),
      ),
      throwsA(isA<ApiException>()),
    );

    expect(expired, isTrue);
    expect(await tokenProvider.getAccessToken(), isNull);
    expect(await tokenProvider.getSessionId(), isNull);
    expect(await tokenProvider.getRefreshToken(), isNull);
  });

  test('requestResponse exposes wrapper metadata', () async {
    final dio = Dio();
    final client = DioApiClient(
      dio: dio,
      tokenProvider: const StaticApiTokenProvider(null),
    );
    dio.interceptors.add(
      _ResolveInterceptor(
        (options) => Response<Object?>(
          requestOptions: options,
          statusCode: 200,
          data: {'message': 'Loaded', 'value': 7},
          headers: Headers.fromMap({
            'x-request-id': ['abc'],
          }),
        ),
      ),
    );

    final response = await client.requestResponse<int>(
      const ApiRequestConfig(method: HttpMethod.get, path: '/count'),
      fromJson: (data) => (data as Map<String, dynamic>)['value'] as int,
    );

    expect(response.data, 7);
    expect(response.message, 'Loaded');
    expect(response.statusCode, 200);
    expect(response.headers['x-request-id'], ['abc']);
  });

  test(
    'Dio errors are mapped and configurable feedback receives them',
    () async {
      final feedback = _RecordingFeedbackHandler();
      final dio = Dio();
      final client = DioApiClient(
        dio: dio,
        tokenProvider: const StaticApiTokenProvider(null),
        feedbackHandler: feedback,
      );
      dio.interceptors.add(
        _RejectInterceptor(
          (options) => DioException(
            requestOptions: options,
            type: DioExceptionType.badResponse,
            response: Response<Object?>(
              requestOptions: options,
              statusCode: 500,
              data: {'message': 'Server exploded'},
            ),
          ),
        ),
      );

      await expectLater(
        client.request<void>(
          ApiRequestConfig(
            method: HttpMethod.get,
            path: ApiEndpoints.orders.list,
            errorMessage: 'Unable to load orders.',
          ),
        ),
        throwsA(
          isA<ApiException>()
              .having(
                (error) => error.type,
                'type',
                ShipKiaApiFailureType.server,
              )
              .having((error) => error.statusCode, 'statusCode', 500),
        ),
      );

      expect(feedback.errorMessages, ['Unable to load orders.']);
    },
  );

  test('retry is opt-in and limited to retryable failures', () async {
    var attempts = 0;
    final dio = Dio();
    final client = DioApiClient(
      dio: dio,
      tokenProvider: const StaticApiTokenProvider(null),
    );
    dio.interceptors.add(
      _ResolveInterceptor((options) {
        attempts += 1;
        if (attempts == 1) {
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.badResponse,
            response: Response<Object?>(
              requestOptions: options,
              statusCode: 500,
            ),
          );
        }
        return Response<Object?>(
          requestOptions: options,
          statusCode: 200,
          data: {'ok': true},
        );
      }),
    );

    final result = await client.request<Map<String, dynamic>>(
      ApiRequestConfig(
        method: HttpMethod.get,
        path: ApiEndpoints.orders.list,
        retry: RetryConfig(
          enabled: true,
          maxAttempts: 2,
          retryDelay: Duration.zero,
        ),
      ),
    );

    expect(result, {'ok': true});
    expect(attempts, 2);
  });
}

class _Order {
  const _Order({required this.id});

  final int id;

  factory _Order.fromJson(Map<String, dynamic> json) {
    return _Order(id: json['id'] as int);
  }
}

class _ResolveInterceptor extends Interceptor {
  _ResolveInterceptor(this.resolve);

  final Response<Object?> Function(RequestOptions options) resolve;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      handler.resolve(resolve(options));
    } on DioException catch (error) {
      handler.reject(error);
    }
  }
}

class _RejectInterceptor extends Interceptor {
  _RejectInterceptor(this.reject);

  final DioException Function(RequestOptions options) reject;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.reject(reject(options));
  }
}

class _RecordingFeedbackHandler implements ApiFeedbackHandler {
  final errorMessages = <String?>[];
  final successMessages = <String>[];

  @override
  void error(
    Object error, {
    int? statusCode,
    String? message,
    String? eventKey,
  }) {
    errorMessages.add(message);
  }

  @override
  void success(String message, {String? eventKey}) {
    successMessages.add(message);
  }
}

class _MockAdapter implements HttpClientAdapter {
  _MockAdapter(this.respond);

  final ResponseBody Function(RequestOptions options) respond;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}
