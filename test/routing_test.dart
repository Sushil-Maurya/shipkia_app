import 'package:flutter/material.dart';
import 'package:shipkia_app/src/core/api/api_scope.dart';

import 'support/recording_api_client.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:shipkia_app/src/core/auth/shipkia_auth_controller.dart';
import 'package:shipkia_app/src/core/auth/shipkia_auth_scope.dart';
import 'package:shipkia_app/src/core/router/app_router.dart';
import 'package:shipkia_app/src/features/auth/login_screen.dart';
import 'package:shipkia_app/src/theme/shipkia_theme.dart';

void main() {
  testWidgets('unauthenticated users land on login', (tester) async {
    final auth = _auth(ShipKiaAuthStatus.unauthenticated);
    await tester.pumpWidget(_routerApp(auth));
    await tester.pumpAndSettle();

    expect(find.text('Login to ShipKia'), findsOneWidget);
  });

  testWidgets('authenticated users are redirected away from login', (
    tester,
  ) async {
    final auth = _auth(ShipKiaAuthStatus.authenticated);
    await tester.pumpWidget(_routerApp(auth, initialLocation: '/login'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome there'), findsWidgets);
    expect(find.text('Login to ShipKia'), findsNothing);
  });

  testWidgets('React auth route aliases open public auth screens', (
    tester,
  ) async {
    final auth = _auth(ShipKiaAuthStatus.unauthenticated);
    await tester.pumpWidget(_routerApp(auth, initialLocation: '/signup'));
    await tester.pumpAndSettle();

    expect(find.byType(SignUpScreen), findsOneWidget);

    await tester.pumpWidget(
      _routerApp(auth, initialLocation: '/update-password'),
    );
    await tester.pumpAndSettle();

    expect(find.byType(UpdatePasswordScreen), findsOneWidget);
  });

  testWidgets('protected routes redirect to login and restore after sign in', (
    tester,
  ) async {
    final auth = _auth(ShipKiaAuthStatus.unauthenticated);
    await tester.pumpWidget(
      _routerApp(auth, initialLocation: '/orders/ORD-10491'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Login to ShipKia'), findsOneWidget);

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('ORD-10491'), findsWidgets);
    expect(find.text('Order Details'), findsOneWidget);
  });

  testWidgets('order detail preserves percent characters in backend identity', (
    tester,
  ) async {
    final auth = _auth(ShipKiaAuthStatus.authenticated);
    await tester.pumpWidget(
      _routerApp(auth, initialLocation: '/orders/ORDER%2542'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Order Details'), findsOneWidget);
    expect(find.text('ORDER%42'), findsWidgets);
  });

  testWidgets('authorized users can open orders', (tester) async {
    final auth = _auth(ShipKiaAuthStatus.authenticated);
    await tester.pumpWidget(_routerApp(auth, initialLocation: '/orders'));
    await tester.pumpAndSettle();

    expect(find.textContaining('4 orders'), findsOneWidget);
    expect(find.text('ORD-10491'), findsOneWidget);
  });

  testWidgets('authenticated users can open web module routes', (tester) async {
    final auth = _auth(ShipKiaAuthStatus.authenticated);
    await tester.pumpWidget(
      _routerApp(auth, initialLocation: '/return_orders'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Returns'), findsWidgets);
    expect(find.text('No returns found'), findsOneWidget);

    await tester.pumpWidget(
      _routerApp(auth, initialLocation: '/settings/products'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Products'), findsWidgets);
    expect(find.text('No products found'), findsOneWidget);
  });

  testWidgets('direct asset link opens the record rather than its list', (
    tester,
  ) async {
    final auth = _auth(ShipKiaAuthStatus.authenticated);
    await tester.pumpWidget(
      _routerApp(auth, initialLocation: '/settings/products/PRODUCT-42'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Product detail fixture'), findsWidgets);
    expect(find.text('No products found'), findsNothing);
  });

  testWidgets('missing permission redirects to forbidden screen', (
    tester,
  ) async {
    final auth = _auth(
      ShipKiaAuthStatus.authenticated,
      permissions: <String>{},
    );
    await tester.pumpWidget(_routerApp(auth, initialLocation: '/orders'));
    await tester.pumpAndSettle();

    expect(find.text('Access restricted'), findsOneWidget);
  });

  testWidgets('unknown routes show not found', (tester) async {
    final auth = _auth(ShipKiaAuthStatus.authenticated);
    await tester.pumpWidget(_routerApp(auth, initialLocation: '/bad-route'));
    await tester.pumpAndSettle();

    expect(find.text('Page not found'), findsOneWidget);
  });

  testWidgets('session expiration redirects protected page to login', (
    tester,
  ) async {
    final auth = _auth(ShipKiaAuthStatus.authenticated);
    await tester.pumpWidget(_routerApp(auth, initialLocation: '/orders'));
    await tester.pumpAndSettle();

    expect(find.textContaining('4 orders'), findsOneWidget);

    auth.expireSession();
    await tester.pumpAndSettle();

    expect(find.text('Login to ShipKia'), findsOneWidget);
  });

  testWidgets('bottom navigation preserves nested order stack', (tester) async {
    final auth = _auth(ShipKiaAuthStatus.authenticated);
    await tester.pumpWidget(_routerApp(auth, initialLocation: '/orders'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('ORD-10491'));
    await tester.pumpAndSettle();
    expect(find.text('Order Details'), findsOneWidget);

    await tester.tap(find.text('Wallet').last);
    await tester.pumpAndSettle();
    expect(find.text('Available Balance'), findsOneWidget);

    await tester.tap(find.text('Orders').last);
    await tester.pumpAndSettle();
    expect(find.text('Order Details'), findsOneWidget);
  });
}

ShipKiaAuthController _auth(
  ShipKiaAuthStatus status, {
  Set<String>? permissions,
}) {
  return ShipKiaAuthController(
    initialStatus: status,
    permissions: permissions,
    restoreDelay: Duration.zero,
  );
}

Widget _routerApp(
  ShipKiaAuthController auth, {
  String initialLocation = '/splash',
}) {
  final router = AppRouter(
    authController: auth,
    initialLocation: initialLocation,
  );
  return ShipKiaAuthScope(
    controller: auth,
    child: ShipKiaApiScope(
      apiClient: RecordingApiClient((config) async {
        if (config.path == '/oms/orders/records/list') {
          return pageFixture([
            for (final id in [
              'ORD-10491',
              'ORD-10490',
              'ORD-10489',
              'ORD-10488',
            ])
              orderFixture(id),
          ]);
        }
        if (config.path.startsWith('/oms/orders/records/')) {
          return {
            'value': orderFixture(
              Uri.decodeComponent(config.path.split('/').last),
            ),
            'fields': [
              {
                'name': 'delivery_full_name',
                'type': 'text',
                'label': 'Delivery Full Name',
              },
            ],
          };
        }
        if (config.path == '/oms/products/records/PRODUCT-42') {
          return {
            'value': {
              'id': 'PRODUCT-42',
              'product_name': 'Product detail fixture',
            },
            'fields': [],
          };
        }
        return pageFixture([]);
      }),
      child: MaterialApp.router(
        theme: ShipKiaTheme.light,
        darkTheme: ShipKiaTheme.dark,
        routerConfig: router.router,
      ),
    ),
  );
}
