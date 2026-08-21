import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shipkia_app/src/app/shipkia_app.dart';

void main() {
  testWidgets('ShipKia app opens login and enters operations shell', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ShipKiaApp());

    expect(find.text('ShipKia'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Dispatch Console'), findsWidgets);
    expect(find.text('Orders'), findsWidgets);
  });
}
