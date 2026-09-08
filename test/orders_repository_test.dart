import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shipkia_app/src/core/api/api.dart';
import 'package:shipkia_app/src/features/orders/data/orders_repository.dart';
import 'package:shipkia_app/src/features/orders/domain/order_list_filters.dart';
import 'package:shipkia_app/src/features/orders/domain/order_summary.dart';

import 'support/recording_api_client.dart';

void main() {
  test(
    'Orders uses React POST list, OR search, AND stage and backend pagination',
    () async {
      final api = RecordingApiClient(
        (_) async => pageFixture(
          [orderFixture('A', stage: 'Out for Delivery')],
          total: 41,
          pages: 3,
        ),
      );
      final page = await OrdersRepository(api).list(
        page: 2,
        pageSize: 20,
        cancelToken: CancelToken(),
        stage: 'In-Transit',
        search: '  9001  ',
        filters: const OrderListFilters(deliveryDetails: {'COD'}),
      );
      final request = api.requests.single;
      expect(request.method, HttpMethod.post);
      expect(request.path, '/oms/orders/records/list');
      expect(request.params, {'page': '2', 'rows': '20'});
      expect(request.headers, isNull);
      expect(request.requiresAuth, isTrue);
      expect(request.cancelToken, isNotNull);
      final root = (request.data as Map)['filters'] as Map;
      expect(root['connector'], 'and');
      final filters = root['filterSet'] as List;
      expect(
        filters,
        contains(equals({'id': 'stage', 'opr': '=', 'value': 'In-Transit'})),
      );
      expect(
        filters,
        contains(equals({'id': 'payment_method', 'opr': '=', 'value': 'cod'})),
      );
      expect((filters.last as Map)['connector'], 'or');
      expect((filters.last as Map)['filterSet'], [
        {'id': 'awb', 'opr': 'contains', 'value': '9001'},
        {'id': 'delivery_phone', 'opr': 'contains', 'value': '9001'},
      ]);
      expect(page.totalRecords, 41);
      expect(page.totalPages, 3);
      expect(page.records.single.customer, 'Test customer');
      expect(page.records.single.city, 'Delhi');
      expect(page.records.single.amount, 2499.5);
      expect(page.records.single.stageLabel, 'Out for Delivery');
      expect(page.records.single.status, isNot(ShipmentStatus.delivered));
    },
  );

  test('unfiltered list has no invented filters or search parameter', () async {
    final api = RecordingApiClient((_) async => pageFixture([]));
    await OrdersRepository(api).list(
      page: 1,
      pageSize: 20,
      cancelToken: CancelToken(),
      stage: 'All',
      search: '  ',
    );
    expect(api.requests.single.data, isNull);
  });

  test('last seven calendar days includes today and serializes local midnight in UTC', () {
    final now = DateTime(2026, 9, 8, 17, 30);
    final payload = const OrderListFilters(
      quickPicks: {'last_7_days', 'missing_awb'},
      city: ' Delhi ',
      pincode: '110',
    ).toPayload(now: now) as Map;
    final filters = payload['filters']['filterSet'] as List;
    expect(
      filters,
      contains(
        equals({
          'id': 'created_at',
          'opr': '>=',
          'value': DateTime(2026, 9, 2).toUtc().toIso8601String(),
        }),
      ),
    );
    expect(
      filters,
      contains(equals({'id': 'awb', 'opr': 'is', 'value': false})),
    );
    expect(
      filters,
      contains(
        equals({
          'id': 'delivery_postal_code',
          'opr': 'contains',
          'value': '110',
        }),
      ),
    );
    expect(
      filters,
      contains(
        equals({'id': 'delivery_city', 'opr': 'contains', 'value': 'Delhi'}),
      ),
    );
  });

  test(
    'malformed response is a failure, never an empty successful list',
    () async {
      for (final data in [
        null,
        {},
        {
          'values': [null],
        },
        {
          'values': [
            {'stage': 'New'},
          ],
        },
        {
          'values': [],
          'pages': {'totalRecords': -1},
        },
      ]) {
        final repository = OrdersRepository(
          RecordingApiClient((_) async => data),
        );
        await expectLater(
          repository.list(page: 1, pageSize: 20, cancelToken: CancelToken()),
          throwsFormatException,
        );
      }
    },
  );

  test('identity prefers name and missing stage/date are not invented', () {
    final order = OrderSummary.fromJson({'id': 'DISPLAY', 'name': 'RECORD'});
    expect(order.id, 'DISPLAY');
    expect(order.key, 'RECORD');
    expect(order.stageLabel, 'Unknown');
    expect(order.status, ShipmentStatus.unknown);
    expect(order.hasCreatedAt, isFalse);
  });

  test('live detail wrapper converts metadata currency once', () async {
    final api = RecordingApiClient(
      (_) async => {
        'value': {...orderFixture('LIVE'), 'total_order_value': 12345},
        'fields': [
          {'name': 'total_order_value', 'type': 'unit', 'display': 'currency'},
        ],
      },
    );
    final record = await OrdersRepository(api).detail('LIVE', CancelToken());
    expect(OrderSummary.fromJson(record).amount, 123.45);
  });

  test('detail encodes identity exactly once', () async {
    final api = RecordingApiClient((_) async => orderFixture('ORDER/42'));
    await OrdersRepository(api).detail('ORDER/42', CancelToken());
    expect(api.requests.single.method, HttpMethod.get);
    expect(api.requests.single.path, '/oms/orders/records/ORDER%2F42');
  });
}
