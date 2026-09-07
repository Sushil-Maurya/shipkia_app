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
          headers: Headers.fromMap({
            'set-cookie': ['refresh_token=refresh-123; Path=/; HttpOnly'],
          }),
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
                'message': 'Access token generated successfully.',
                'result': {
                  'access_token': 'access-token',
                  'expires_at': '2026-09-07T11:40:12.860Z',
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
                  'roles': ['Buopso Admin'],
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
      expect(tokenProvider.sessionId, 'session-token');
      expect(await tokenProvider.getAccessToken(), 'access-token');
      expect(controller.profile?.email, 'ada@example.com');
      expect(controller.profile?.name, 'Ada Lovelace');
      expect(
        controller.permissions,
        containsAll([
          ShipKiaPermissions.ordersView,
          ShipKiaPermissions.walletView,
        ]),
      );

      controller.signOut();

      expect(controller.isAuthenticated, isFalse);
      expect(await tokenProvider.getAccessToken(), isNull);
    },
  );

  test(
    'auth controller expires login when token renew cannot create access token',
    () async {
      final tokenProvider = InMemoryApiTokenProvider();
      final requestedPaths = <String>[];
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
        _ResolveInterceptor((options) {
          requestedPaths.add(options.path);

          return Response<Object?>(
            requestOptions: options,
            statusCode: 200,
            data: switch (options.path) {
              '/auth/login' => {
                'success': true,
                'message': 'Login successfull.',
                'result': {'session': 'session-token'},
              },
              '/auth/token/renew' => {
                'success': false,
                'message': 'Token renewal failed',
              },
              '/auth/users/profile' => {
                'success': false,
                'message': 'Profile fetch failed',
              },
              _ => {'success': false, 'message': 'Unexpected endpoint'},
            },
          );
        }),
      );

      await controller.login(email: 'ops@shipkia.com', password: 'secret');

      expect(controller.isAuthenticated, isFalse);
      expect(tokenProvider.sessionId, isNull);
      expect(await tokenProvider.getAccessToken(), isNull);
      expect(requestedPaths, [
        ApiEndpoints.auth.login,
        ApiEndpoints.auth.tokenRenew,
      ]);
    },
  );

  test('auth controller clears local state when logout api fails', () async {
    final tokenProvider = InMemoryApiTokenProvider()
      ..setAccessToken('access-token')
      ..setSessionId('session-token');
    await tokenProvider.saveRefreshToken('refresh-token');
    final dio = Dio(BaseOptions(baseUrl: 'http://api.shipkia.lcl'));
    final controller = ShipKiaAuthController(
      authRepository: AuthRepository(
        DioApiClient(dio: dio, tokenProvider: tokenProvider),
      ),
      tokenProvider: tokenProvider,
      initialStatus: ShipKiaAuthStatus.authenticated,
      restoreDelay: Duration.zero,
    );
    addTearDown(controller.dispose);
    dio.interceptors.add(
      _ResolveInterceptor(
        (options) => Response<Object?>(
          requestOptions: options,
          statusCode: 200,
          data: {'success': false, 'message': 'Unauthorized'},
        ),
      ),
    );

    await controller.logout();

    expect(controller.isAuthenticated, isFalse);
    expect(tokenProvider.sessionId, isNull);
    expect(await tokenProvider.getAccessToken(), isNull);
    expect(await tokenProvider.getRefreshToken(), isNull);
  });

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
