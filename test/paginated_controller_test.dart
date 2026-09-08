import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shipkia_app/src/core/api/record_page.dart';
import 'package:shipkia_app/src/core/state/paginated_controller.dart';

void main() {
  test('query changes cancel previous work and ignore responses arriving out of order', () async {
    final controller = PaginatedController<String>(recordKey: (value) => value);
    addTearDown(controller.dispose);
    final old = Completer<RecordPage<String>>();
    late CancelToken oldToken;
    final first = controller.setQuery((page, size, token) {
      oldToken = token;
      return old.future;
    });
    await controller.setQuery(
      (page, size, token) async =>
          RecordPage(records: ['new'], totalRecords: 1),
    );
    expect(oldToken.isCancelled, isTrue);
    old.complete(RecordPage(records: ['old'], totalRecords: 500));
    await first;
    expect(controller.records, ['new']);
    expect(controller.totalRecords, 1);
  });

  test('load-more retries failed page, deduplicates overlapping rows, and stops at totalPages', () async {
    final controller = PaginatedController<String>(
      recordKey: (value) => value,
      pageSize: 2,
    );
    addTearDown(controller.dispose);
    final requests = <int>[];
    var fail = true;
    await controller.setQuery((page, size, token) async {
      requests.add(page);
      if (page == 2 && fail) {
        fail = false;
        throw StateError('offline');
      }
      return RecordPage(
        records: page == 1 ? ['A', 'B'] : ['B', 'C'],
        totalRecords: 3,
        totalPages: 2,
      );
    });
    await controller.loadMore();
    expect(controller.records, ['A', 'B']);
    expect(controller.page, 1);
    expect(controller.error, isNotNull);
    await controller.retry();
    expect(requests, [1, 2, 2]);
    expect(controller.records, ['A', 'B', 'C']);
    expect(controller.error, isNull);
    expect(controller.hasMore, isFalse);
  });

  test(
    'refresh failure retains records and retry starts again at page one',
    () async {
      final controller = PaginatedController<String>(
        recordKey: (value) => value,
      );
      addTearDown(controller.dispose);
      var calls = 0;
      await controller.setQuery((page, size, token) async {
        expect(page, 1);
        if (++calls == 2) throw StateError('offline');
        return RecordPage(records: calls == 1 ? ['A'] : ['B']);
      });
      await controller.refresh();
      expect(controller.records, ['A']);
      expect(controller.error, isNotNull);
      await controller.retry();
      expect(controller.records, ['B']);
    },
  );

  test(
    'duplicate load-more calls are suppressed; disposed requests cannot notify',
    () async {
      final controller = PaginatedController<String>(
        recordKey: (value) => value,
        pageSize: 1,
      );
      final more = Completer<RecordPage<String>>();
      late CancelToken active;
      var calls = 0;
      await controller.setQuery((page, size, token) {
        calls++;
        active = token;
        return page == 1
            ? Future.value(RecordPage(records: ['A'], totalPages: 2))
            : more.future;
      });
      final first = controller.loadMore();
      await controller.loadMore();
      expect(calls, 2);
      controller.dispose();
      expect(active.isCancelled, isTrue);
      more.complete(RecordPage(records: ['B']));
      await first;
      expect(controller.records, ['A']);
    },
  );
}
