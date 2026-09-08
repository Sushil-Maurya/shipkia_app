import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shipkia_app/src/core/api/api.dart';
import 'package:shipkia_app/src/core/router/web_module_catalog.dart';
import 'package:shipkia_app/src/features/modules/module_records.dart';
import 'package:shipkia_app/src/features/modules/web_module_screen.dart';
import 'package:shipkia_app/src/theme/shipkia_theme.dart';

import 'support/recording_api_client.dart';

import 'package:shipkia_app/src/core/feedback/feedback_mapper.dart';

WebModuleRoute route(String type) =>
    WebModuleCatalog.allRoutes.firstWhere((r) => r.objectType == type);
void main() {
  test(
    'detail unwraps metadata and preserves requested identity for templates',
    () {
      final record = ModuleRecord.detail({
        'value': {'name': 'Label'},
        'fields': [
          {'id': '', 'name': 'name', 'label': 'Template name'},
        ],
      }, '1');
      expect(record.id, '1');
      expect(record.title, 'Label');
      expect(record.fields.single.name, 'name');
    },
  );
  test('units follow storage precision and nested fields retain metadata', () {
    expect(
      RecordField({'type': 'unit', 'display': 'currency'}).format(12345),
      'INR 123.45',
    );
    expect(
      RecordField({'type': 'unit', 'display': 'weight'}).format(1250),
      '1.25 kg',
    );
    expect(
      RecordField({'type': 'unit', 'display': 'dimension'}).format(105),
      '10.5 cm',
    );
    expect(RecordField({'type': 'boolean'}).format(false), 'No');
    final record = ModuleRecord({
      'password': 'secret',
      'product_name': 'Item',
    }, []);
    expect(record.displayFields.map((f) => f.name), ['product_name']);
  });
  test(
    'asset search uses configured OR filters and users accept alternate pages',
    () async {
      final api = RecordingApiClient(
        (_) async => {
          'values': [
            {'id': '1'},
          ],
          'pages': {'totalNoOfPages': 3, 'totalRecords': 41},
        },
      );
      final page = await ModuleRepository(
        api,
        route('products'),
      ).list(2, 20, CancelToken(), search: 'shoe');
      expect(page.totalPages, 3);
      expect(api.requests.single.params, {'page': '2', 'rows': '20'});
      expect(
        (api.requests.single.data
            as Map)['filters']['filterSet'][0]['filterSet'][0],
        {'id': 'product_name', 'opr': 'contains', 'value': 'shoe'},
      );
      await ModuleRepository(api, route('users')).detail('a/b', CancelToken());
      expect(api.requests.last.path, '/auth/users/a%2Fb');
      expect(
        ModuleRepository(api, route('print_template')).base,
        '/oms/print_template/records',
      );
    },
  );
  testWidgets(
    'mobile asset list opens real detail and renders units without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final api = RecordingApiClient(
        (r) async => r.method == HttpMethod.get
            ? {
                'value': {
                  'id': 'P1',
                  'product_name': 'Running shoes',
                  'weight': 1250,
                },
                'fields': [
                  {
                    'name': 'weight',
                    'label': 'Weight',
                    'type': 'unit',
                    'display': 'weight',
                  },
                ],
              }
            : pageFixture([
                {'id': 'P1', 'product_name': 'Running shoes'},
              ]),
      );
      final module = route('products');
      final router = GoRouter(
        initialLocation: module.path,
        routes: [
          GoRoute(
            path: module.path,
            builder: (c, s) => WebModuleScreen(route: module),
            routes: [
              GoRoute(
                path: ':name',
                builder: (c, s) => WebModuleScreen(
                  route: module,
                  recordId: s.pathParameters['name'],
                ),
              ),
            ],
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ShipKiaApiScope(
          apiClient: api,
          child: MaterialApp.router(
            theme: ShipKiaTheme.light,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Running shoes'));
      await tester.pumpAndSettle();
      expect(find.text('1.25 kg'), findsOneWidget);
      expect(api.requests.last.path, '/oms/products/records/P1');
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('asset failure is retryable and never claims empty success', (
    tester,
  ) async {
    final api = RecordingApiClient(
      (_) async => throw const ApiException(
        type: ShipKiaApiFailureType.network,
        message: 'Offline',
      ),
    );
    await tester.pumpWidget(
      ShipKiaApiScope(
        apiClient: api,
        child: MaterialApp(
          theme: ShipKiaTheme.light,
          home: WebModuleScreen(route: route('bank_accounts')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Offline'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.textContaining('No bank'), findsNothing);
  });
  testWidgets('notification changes save the documented typed envelope', (
    tester,
  ) async {
    final api = RecordingApiClient(
      (_) async => {
        'whatsapp': {'new': false},
      },
    );
    final module = WebModuleCatalog.allRoutes.firstWhere(
      (r) => r.path.endsWith('/order-notification'),
    );
    await tester.pumpWidget(
      ShipKiaApiScope(
        apiClient: api,
        child: MaterialApp(
          theme: ShipKiaTheme.light,
          home: WebModuleScreen(route: module),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('New order'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save changes'));
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    final save = api.requests.firstWhere((r) => r.method == HttpMethod.put);
    expect(save.path, '/oms/customer-settings');
    expect(save.params, {'type': 'whatsapp'});
    expect((save.data as Map)['whatsapp']['new'], true);
  });
}
