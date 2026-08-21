import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shipkia_app/src/app/shipkia_app.dart';

void main() {
  testWidgets('ShipKia app opens login and enters operations shell', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ShipKiaApp());
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
}
