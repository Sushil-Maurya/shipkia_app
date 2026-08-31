import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shipkia_app/src/core/feedback/feedback_mapper.dart';
import 'package:shipkia_app/src/core/feedback/network_status_controller.dart';
import 'package:shipkia_app/src/core/feedback/shipkia_feedback.dart';

void main() {
  test('normalizes api status codes into user-safe messages', () {
    expect(
      ShipKiaFeedbackMapper.fromStatusCode(401).message,
      'Your session has expired. Please sign in again.',
    );
    expect(
      ShipKiaFeedbackMapper.fromStatusCode(403).message,
      "You don't have permission to perform this action.",
    );
    expect(
      ShipKiaFeedbackMapper.fromStatusCode(500).message,
      'Something went wrong on our server. Please try again.',
    );
  });

  test('rejects technical api messages', () {
    expect(
      ShipKiaFeedbackMapper.fromStatusCode(
        500,
        userSafeMessage: 'SocketException: failed host lookup',
      ).message,
      'Something went wrong on our server. Please try again.',
    );
  });

  test('network controller emits stabilized transitions only', () async {
    var online = true;
    final controller = ShipKiaNetworkStatusController(
      checkConnection: () async => online,
      stabilizationDelay: const Duration(milliseconds: 10),
      pollInterval: const Duration(minutes: 1),
    );
    addTearDown(controller.dispose);

    final statuses = <ShipKiaNetworkStatus>[];
    final subscription = controller.stream.listen(statuses.add);
    addTearDown(subscription.cancel);

    await controller.checkNow();
    await Future<void>.delayed(const Duration(milliseconds: 20));
    online = false;
    await controller.checkNow();
    await Future<void>.delayed(const Duration(milliseconds: 20));
    online = true;
    await controller.checkNow();
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(statuses, [
      ShipKiaNetworkStatus.online,
      ShipKiaNetworkStatus.offline,
      ShipKiaNetworkStatus.online,
    ]);
  });

  testWidgets('feedback snackbar renders semantic action', (tester) async {
    ShipKiaFeedback.resetForTesting();
    addTearDown(ShipKiaFeedback.resetForTesting);
    var retried = false;
    await tester.pumpWidget(
      MaterialApp(
        scaffoldMessengerKey: ShipKiaFeedback.messengerKey,
        home: const Scaffold(body: SizedBox.shrink()),
      ),
    );

    ShipKiaFeedback.error(
      'Unable to load orders. Please try again.',
      eventKey: 'test-orders-error',
      actionLabel: 'Retry',
      onAction: () => retried = true,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.text('Unable to load orders. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    expect(retried, isTrue);
  });

  testWidgets('feedback suppresses rapid duplicates', (tester) async {
    ShipKiaFeedback.resetForTesting();
    addTearDown(ShipKiaFeedback.resetForTesting);
    await tester.pumpWidget(
      MaterialApp(
        scaffoldMessengerKey: ShipKiaFeedback.messengerKey,
        home: const Scaffold(body: SizedBox.shrink()),
      ),
    );

    ShipKiaFeedback.success('Settings saved.', eventKey: 'test-settings-saved');
    ShipKiaFeedback.success('Settings saved.', eventKey: 'test-settings-saved');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Settings saved.'), findsOneWidget);
  });
}
