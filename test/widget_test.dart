import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shipkia_app/src/app/shipkia_app.dart';
import 'package:shipkia_app/src/core/auth/shipkia_auth_controller.dart';
import 'package:shipkia_app/src/core/feedback/network_status_controller.dart';

void main() {
  testWidgets('ShipKia app opens login and enters operations shell', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ShipKiaApp(authController: _auth(), networkController: _onlineNetwork()),
    );
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    expect(find.text('Login to ShipKia'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Dispatch Console'), findsWidgets);
    expect(find.text('Orders'), findsWidgets);
  });

  testWidgets('account page theme toggle switches app brightness', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ShipKiaApp(authController: _auth(), networkController: _onlineNetwork()),
    );
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(
      Theme.of(tester.element(find.text('Dispatch Console').first)).brightness,
      Brightness.light,
    );

    await tester.tap(find.byTooltip('Open account'));
    await tester.pumpAndSettle();

    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Manage users'), findsOneWidget);
    expect(find.text('Account settings'), findsOneWidget);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(
      Theme.of(tester.element(find.text('Account').first)).brightness,
      Brightness.dark,
    );
  });
}

ShipKiaNetworkStatusController _onlineNetwork() {
  final controller = ShipKiaNetworkStatusController(
    checkConnection: () async => true,
    stabilizationDelay: Duration.zero,
    pollInterval: const Duration(minutes: 1),
  );
  return controller;
}

ShipKiaAuthController _auth() {
  return ShipKiaAuthController(
    initialStatus: ShipKiaAuthStatus.loading,
    restoreDelay: Duration.zero,
  );
}
