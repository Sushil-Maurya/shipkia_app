import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shipkia_app/src/core/api/api.dart';
import 'package:shipkia_app/src/core/auth/shipkia_auth_controller.dart';
import 'package:shipkia_app/src/features/auth/data/auth_repository.dart';
import 'package:shipkia_app/src/features/auth/data/auth_session.dart';

void main() {
  test('login posts credentials to the centralized login endpoint', () async {
    late RequestOptions captured;
    final dio = Dio(BaseOptions(baseUrl: 'http://api.shipkia.lcl'));
    final repository = AuthRepository(
      DioApiClient(dio: dio, tokenProvider: const StaticApiTokenProvider(null)),
    );
    dio.interceptors.add(
      _ResolveInterceptor((options) {
        captured = options;
        return Response<Object?>(
          requestOptions: options,
          statusCode: 200,
          data: {
            'success': true,
            'message': 'Login successfull.',
            'result': {'session': 'token-123'},
            'permissions': ['orders.view'],
            'traceId': 'fb5a710e-7dbf-400a-ae19-9eb56c369803',
          },
        );
      }),
    );

    final session = await repository.login(
      email: 'ops@shipkia.com',
      password: 'secret',
    );

    expect(captured.method, 'POST');
    expect(captured.path, ApiEndpoints.auth.login);
    expect(captured.uri.toString(), 'http://api.shipkia.lcl/auth/login');
    expect(captured.data, {
      'type': 'email',
      'uid': 'ops@shipkia.com',
      'password': 'secret',
    });
    expect(captured.headers.containsKey('Authorization'), isFalse);
    expect(session.session, 'token-123');
    expect(session.permissions, isEmpty);
  });

  test('logout posts to the centralized logout endpoint with auth', () async {
    late RequestOptions captured;
    final dio = Dio(BaseOptions(baseUrl: 'http://api.shipkia.lcl'));
    final repository = AuthRepository(
      DioApiClient(
        dio: dio,
        tokenProvider: const StaticApiTokenProvider('token-123'),
      ),
    );
    dio.interceptors.add(
      _ResolveInterceptor((options) {
        captured = options;
        return Response<Object?>(requestOptions: options, statusCode: 204);
      }),
    );

    await repository.logout();

    expect(captured.method, 'POST');
    expect(captured.path, ApiEndpoints.auth.logout);
    expect(captured.headers['Authorization'], 'Bearer token-123');
  });

  test(
    'auth controller stores token after login and clears it after logout',
    () async {
      final tokenProvider = InMemoryApiTokenProvider();
      final dio = Dio(BaseOptions(baseUrl: 'http://api.shipkia.lcl'));
      final controller = ShipKiaAuthController(
        authRepository: AuthRepository(
          DioApiClient(dio: dio, tokenProvider: tokenProvider),
        ),
        tokenProvider: tokenProvider,
        initialStatus: ShipKiaAuthStatus.unauthenticated,
        restoreDelay: Duration.zero,
      );
      addTearDown(controller.dispose);
      dio.interceptors.add(
        _ResolveInterceptor(
          (options) => Response<Object?>(
            requestOptions: options,
            statusCode: 200,
            data: switch (options.path) {
              '/auth/login' => {
                'success': true,
                'message': 'Login successfull.',
                'result': {'session': 'session-token'},
                'traceId': 'fb5a710e-7dbf-400a-ae19-9eb56c369803',
              },
              '/auth/token/renew' => {
                'success': true,
                'message': 'Token renewed.',
                'result': {
                  'access_token': 'access-token',
                  'session': 'renewed-session-token',
                  'expires_in': '3600',
                },
              },
              '/auth/users/profile' => {
                'success': true,
                'message': 'Profile loaded.',
                'result': {
                  'id': 'user-1',
                  'email': 'ada@example.com',
                  'phone': '1234567890',
                  'type': 'admin',
                  'first_name': 'Ada',
                  'last_name': 'Lovelace',
                  'customer_id': 'SHIPKIA-CUST',
                  'roles': ['orders.view'],
                },
              },
              _ => {
                'success': false,
                'message': 'Unexpected endpoint ${options.path}',
              },
            },
          ),
        ),
      );

      await controller.login(email: 'ops@shipkia.com', password: 'secret');

      expect(controller.isAuthenticated, isTrue);
      expect(tokenProvider.sessionId, 'renewed-session-token');
      expect(await tokenProvider.getAccessToken(), 'access-token');
      expect(controller.profile?.email, 'ada@example.com');
      expect(controller.profile?.name, 'Ada Lovelace');
      expect(controller.permissions, {'orders.view'});

      controller.signOut();

      expect(controller.isAuthenticated, isFalse);
      expect(await tokenProvider.getAccessToken(), isNull);
    },
  );

  test('auth session parser accepts nested data payloads', () {
    final session = AuthSession.fromJson({
      'success': true,
      'message': 'Login successfull.',
      'result': {'session': 'nested-token'},
      'traceId': 'fb5a710e-7dbf-400a-ae19-9eb56c369803',
    });

    expect(session.session, 'nested-token');
  });
}

class _ResolveInterceptor extends Interceptor {
  _ResolveInterceptor(this.resolve);

  final Response<Object?> Function(RequestOptions options) resolve;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.resolve(resolve(options));
  }
}
