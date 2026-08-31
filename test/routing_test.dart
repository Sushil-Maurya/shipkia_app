import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shipkia_app/src/core/auth/shipkia_auth_controller.dart';
import 'package:shipkia_app/src/core/auth/shipkia_auth_scope.dart';
import 'package:shipkia_app/src/core/router/app_router.dart';
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

    expect(find.text('Dispatch Console'), findsWidgets);
    expect(find.text('Login to ShipKia'), findsNothing);
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

  testWidgets('authorized users can open orders', (tester) async {
    final auth = _auth(ShipKiaAuthStatus.authenticated);
    await tester.pumpWidget(_routerApp(auth, initialLocation: '/orders'));
    await tester.pumpAndSettle();

    expect(find.textContaining('4 records'), findsOneWidget);
    expect(find.text('ORD-10491'), findsOneWidget);
  });

  testWidgets('missing permission redirects to forbidden screen', (
    tester,
  ) async {
    final auth = _auth(ShipKiaAuthStatus.authenticated, permissions: <String>{});
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

    expect(find.textContaining('4 records'), findsOneWidget);

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
    child: MaterialApp.router(
      theme: ShipKiaTheme.light,
      darkTheme: ShipKiaTheme.dark,
      routerConfig: router.router,
    ),
  );
}
