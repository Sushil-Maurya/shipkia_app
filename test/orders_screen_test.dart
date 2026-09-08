import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shipkia_app/src/core/api/api.dart';
import 'package:shipkia_app/src/core/feedback/feedback_mapper.dart';
import 'package:shipkia_app/src/core/router/route_state_reader.dart';
import 'package:shipkia_app/src/features/orders/orders_screen.dart';
import 'package:shipkia_app/src/features/orders/order_detail_screen.dart';
import 'package:shipkia_app/src/theme/shipkia_theme.dart';

import 'support/recording_api_client.dart';

import 'package:shipkia_app/src/widgets/shipkia_widgets.dart';

void main() {
  testWidgets('compact list actions create an order and refresh the queue', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var lists = 0;
    final api = RecordingApiClient((r) async {
      if (r.path.endsWith('/permissions')) return {'create': true};
      if (r.path.endsWith('/fields')) {
        return [
          {
            'name': 'delivery_full_name',
            'label': 'Delivery Full Name',
            'type': 'text',
            'required': true,
          },
        ];
      }
      if (r.path.endsWith('/list')) {
        lists++;
        return pageFixture([orderFixture('ORDER-1', stage: 'New')]);
      }
      return {
        'value': {'id': 'CREATED'},
      };
    });
    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byTooltip('Refresh orders')),
      const Size(30, 30),
    );
    expect(tester.getSize(find.byTooltip('Filter orders')), const Size(36, 36));
    final reload = tester.getRect(find.byTooltip('Refresh orders'));
    final create = tester.getRect(find.text('Create Order'));
    final heading = tester.getRect(find.text('Orders'));
    expect(reload.left, greaterThan(heading.right));
    expect(reload.center.dy, closeTo(heading.center.dy, 1));
    expect(create.left, greaterThan(reload.right));
    expect(create.center.dy, closeTo(reload.center.dy, 1));
    final search = tester.getRect(find.byType(TextField));
    final filter = tester.getRect(find.byTooltip('Filter orders'));
    expect(search.height, filter.height);
    expect(search.center.dy, filter.center.dy);
    final card = tester.getRect(find.byType(SkOrderRow));
    final badge = tester.getRect(find.byType(SkStatusBadge));
    expect(card.right - badge.right, closeTo(29, 1));
    await tester.tap(find.text('Create Order'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Customer');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();
    expect(find.byType(OrdersScreen), findsOneWidget);
    expect(lists, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'API failures show retry instead of sample orders; retry can resolve to empty',
    (tester) async {
      var fail = true;
      final api = RecordingApiClient((_) async {
        if (fail) {
          throw const ApiException(
            type: ShipKiaApiFailureType.network,
            message: 'No connection',
          );
        }
        return pageFixture([]);
      });
      await tester.pumpWidget(_app(api));
      await tester.pumpAndSettle();
      expect(find.text('No connection'), findsOneWidget);
      expect(find.text('ORD-10491'), findsNothing);
      fail = false;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('No orders yet'), findsOneWidget);
      expect(api.requests, hasLength(2));
    },
  );

  testWidgets(
    'search is debounced, stage preserves search, and server stages are not filtered locally',
    (tester) async {
      final api = RecordingApiClient(
        (_) async =>
            pageFixture([orderFixture('LIVE-1', stage: 'Pickup Exception')]),
      );
      await tester.pumpWidget(_app(api));
      await tester.pumpAndSettle();
      expect(find.text('PICKUP EXCEPTION'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '900');
      await tester.pump(const Duration(milliseconds: 150));
      await tester.enterText(find.byType(TextField), '9001');
      await tester.pump(const Duration(milliseconds: 349));
      expect(api.requests, hasLength(1));
      await tester.pumpAndSettle();
      expect(api.requests, hasLength(2));
      await tester.tap(find.text('New'));
      await tester.pumpAndSettle();
      expect(find.text('LIVE-1'), findsOneWidget);
      final filters =
          (api.requests.last.data as Map)['filters']['filterSet'] as List;
      expect(
        filters,
        contains(equals({'id': 'stage', 'opr': '=', 'value': 'New'})),
      );
      expect(filters.last['filterSet'].first['value'], '9001');
    },
  );

  testWidgets('new query clears stale records while awaiting its result', (
    tester,
  ) async {
    final pending = Completer<Object?>();
    var calls = 0;
    final api = RecordingApiClient(
      (_) async =>
          ++calls == 1 ? pageFixture([orderFixture('OLD')]) : pending.future,
    );
    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 30));
    expect(find.text('OLD'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    pending.complete(pageFixture([orderFixture('NEW-RESULT')]));
    await tester.pumpAndSettle();
    expect(find.text('NEW-RESULT'), findsOneWidget);
  });

  testWidgets(
    'filter sheet supports payment, exclusive date picks and reset at phone width',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final api = RecordingApiClient((_) async => pageFixture([]));
      await tester.pumpWidget(_app(api, dark: true));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Filter orders'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Today'));
      await tester.tap(find.text('Last 7 days'));
      await tester.tap(find.text('COD'));
      await tester.tap(find.text('Apply filters'));
      await tester.pumpAndSettle();
      final filters =
          (api.requests.last.data as Map)['filters']['filterSet'] as List;
      expect(filters.where((f) => f['id'] == 'created_at'), hasLength(1));
      expect(
        filters,
        contains(equals({'id': 'payment_method', 'opr': '=', 'value': 'cod'})),
      );
      await tester.tap(find.text('Clear all'));
      await tester.pumpAndSettle();
      expect(api.requests.last.data, isNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'long order identities and statuses render at narrow width and larger text',
    (tester) async {
      tester.view.physicalSize = const Size(320, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final api = RecordingApiClient(
        (_) async => pageFixture([
          orderFixture(
            'ORDER-WITH-A-LONG-IDENTITY-2026',
            stage: 'Custom Cleared Overseas',
          ),
        ]),
      );
      await tester.pumpWidget(_app(api, textScale: 1.4));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'direct detail route loads without preview and failed refresh keeps real record',
    (tester) async {
      var fail = false;
      final api = RecordingApiClient((_) async {
        if (fail) {
          throw const ApiException(
            type: ShipKiaApiFailureType.network,
            message: 'Refresh failed',
          );
        }
        return {
          'value': orderFixture('LIVE-DETAIL'),
          'fields': [
            {
              'name': 'delivery_full_name',
              'type': 'text',
              'label': 'Delivery Full Name',
            },
          ],
        };
      });
      await tester.pumpWidget(
        MaterialApp(
          theme: ShipKiaTheme.light,
          home: ShipKiaApiScope(
            apiClient: api,
            child: const OrderDetailScreen(orderId: 'LIVE-DETAIL'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byTooltip('Order actions'), findsOneWidget);
      expect(find.text('Shipping label downloaded.'), findsNothing);
      fail = true;
      await tester.tap(find.byTooltip('Order actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Refresh order'));
      await tester.pumpAndSettle();
      expect(find.text('Refresh failed'), findsOneWidget);
      expect(find.text('LIVE-DETAIL'), findsWidgets);
    },
  );
}

Widget _app(RecordingApiClient api, {bool dark = false, double textScale = 1}) {
  final router = GoRouter(
    initialLocation: '/orders',
    routes: [
      GoRoute(
        path: '/orders',
        builder: (context, state) => Scaffold(
          body: SafeArea(
            child: OrdersScreen(query: OrdersRouteQuery.fromState(state)),
          ),
        ),
      ),
    ],
  );
  return ShipKiaApiScope(
    apiClient: api,
    child: MaterialApp.router(
      theme: dark ? ShipKiaTheme.dark : ShipKiaTheme.light,
      routerConfig: router,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
    ),
  );
}
