import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shipkia_app/src/core/api/api.dart';
import 'package:shipkia_app/src/core/forms/forms.dart';
import 'package:shipkia_app/src/features/orders/data/order_actions_repository.dart';
import 'package:shipkia_app/src/features/orders/domain/order_form.dart';
import 'package:shipkia_app/src/features/orders/order_detail_screen.dart';
import 'package:shipkia_app/src/features/orders/order_shipping_sheet.dart';
import 'package:shipkia_app/src/theme/shipkia_theme.dart';
import 'package:dio/dio.dart';

import 'support/recording_api_client.dart';

void main() {
  test(
    'document retrieval validates PDF and exports through the platform save UI',
    () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      MethodCall? export;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('shipkia/documents'), (
            call,
          ) async {
            export = call;
            return true;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel('shipkia/documents'),
              null,
            ),
      );
      final api = RecordingApiClient((_) async => utf8.encode('%PDF-1.7 test'));
      expect(
        await OrderActionsRepository(api)
            .exportDocument('ORDER/1', 'invoice', CancelToken()),
        isTrue,
      );
      expect(api.requests.single.path, '/drms/orders/invoice');
      expect(api.requests.single.params, {'ids': 'ORDER/1'});
      expect(api.requests.single.responseType, ResponseType.bytes);
      expect(export!.arguments['name'], 'invoice-ORDER_1.pdf');
      await expectLater(
        OrderActionsRepository(
          RecordingApiClient((_) async => utf8.encode('<html>error')),
        ).document('1', 'label', CancelToken()),
        throwsFormatException,
      );
    },
  );
  test('shipping actions preserve quote and schedule API payloads', () async {
    final api = RecordingApiClient(
      (r) async => r.path.endsWith('estimated-cost')
          ? {
              'Courier': {'quote_id': 'Q-1', 'total_charges': 5000},
            }
          : {'awb': 'A-1', 'auto_pickup': true},
    );
    final repo = OrderActionsRepository(api);
    expect(
      (await repo.quotes('ORDER-1', CancelToken())).single['quote_id'],
      'Q-1',
    );
    expect(api.requests.single.params, {
      'order_id': 'ORDER-1',
      'forward': 'true',
    });
    await repo.ship('ORDER-1', 'Q-1', CancelToken());
    expect(api.requests.last.data, {'order_id': 'ORDER-1', 'quote_id': 'Q-1'});
    await repo.schedule('ORDER-1', '2026-09-09', CancelToken());
    expect(api.requests.last.data, {
      'order_ids': ['ORDER-1'],
      'pickup_date': '2026-09-09',
    });
  });
  test(
    'pickup dates respect operational weekdays and the same-day closing cutoff',
    () {
      final now = DateTime(2026, 9, 8, 17);
      final address = {
        'closing_time': '17:00:00',
        'operational_days': [
          {'day': 'Tuesday'},
          {'day': 'Wednesday'},
        ],
      };
      expect(pickupDateAllowed(DateTime(2026, 9, 8), now, address), isFalse);
      expect(pickupDateAllowed(DateTime(2026, 9, 9), now, address), isTrue);
      expect(pickupDateAllowed(DateTime(2026, 9, 10), now, address), isFalse);
    },
  );
  test('duplicate preserves order content and removes shipment, identity and ecommerce metadata', () {
    expect(
      OrderForm.duplicateValues({
        'id': 'OLD',
        'awb': 'AWB',
        'stage': 'Delivered',
        'ecom_order_name': 'SHOP-1',
        'created_at': 'old',
        'delivery_full_name': 'Customer',
        'product_details': [],
      }),
      {'delivery_full_name': 'Customer', 'product_details': []},
    );
  });
  testWidgets('local options match field width and units align at the end', (
    tester,
  ) async {
    final form = DynamicFormController(
      schema: const ApiFormAdapter().parse([
        {
          'name': 'status',
          'type': 'option',
          'label': 'Status',
          'options': ['New', 'Ready'],
        },
        {
          'name': 'weight',
          'type': 'unit',
          'label': 'Weight',
          'display': 'weight',
        },
      ], id: 'local'),
    );
    final api = RecordingApiClient(
      (_) async => throw StateError('Local options must not fetch'),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: ShipKiaTheme.light,
        home: ShipKiaApiScope(
          apiClient: api,
          child: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 320,
                child: DynamicFormBuilder(
                  schema: form.schema,
                  controller: form,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byTooltip('Choose Status'));
    await tester.pumpAndSettle();
    final input = tester.getRect(find.byType(TextField).first);
    final option = tester.getRect(
      find.ancestor(of: find.text('Ready'), matching: find.byType(ListTile)),
    );
    expect(option.width, closeTo(input.width - 2, 1));
    await tester.tap(find.text('Ready'));
    await tester.pumpAndSettle();
    expect(form.values['status'], 'Ready');
    expect(api.requests, isEmpty);
    final unit = tester.getRect(find.byType(TextField).last);
    final suffix = tester.getRect(find.text('KG'));
    expect(unit.right - suffix.right, lessThanOrEqualTo(16));
    expect(suffix.center.dy, closeTo(unit.center.dy, 1));
    await tester.pumpWidget(const SizedBox.shrink());
    form.dispose();
  });

  testWidgets('product row editor has top close and right aligned Done', (
    tester,
  ) async {
    final form = DynamicFormController(
      schema: const ApiFormAdapter().parse([
        {
          'name': 'items',
          'type': 'grid',
          'label': 'Products',
          'fields': [
            {'name': 'product_name', 'type': 'text', 'label': 'Product'},
          ],
        },
      ], id: 'rows'),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: ShipKiaTheme.light,
        home: Scaffold(
          body: DynamicFormBuilder(schema: form.schema, controller: form),
        ),
      ),
    );
    await tester.tap(find.text('Add row'));
    await tester.pumpAndSettle();
    expect(find.text('Close'), findsNothing);
    final close = tester.getRect(find.byTooltip('Close'));
    final field = tester.getRect(find.byType(TextField));
    final done = tester.getRect(find.text('Done'));
    expect(close.center.dx, greaterThan(field.center.dx));
    expect(close.bottom, lessThan(field.top));
    expect(done.center.dx, greaterThan(field.center.dx));
    await tester.enterText(find.byType(TextField), 'Product A');
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect((form.values['items'] as List).single['product_name'], 'Product A');
    await tester.pumpWidget(const SizedBox.shrink());
    form.dispose();
  });

  testWidgets('phone fields show India prefix and dismiss keyboard outside', (
    tester,
  ) async {
    final form = DynamicFormController(
      schema: const ApiFormAdapter().parse(
        [
          {'name': 'phone', 'type': 'phone', 'label': 'Phone'},
        ],
        id: 'phone',
        values: {'phone': '+91-9876543210'},
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: ShipKiaTheme.light,
        home: Scaffold(
          body: DynamicFormBuilder(schema: form.schema, controller: form),
        ),
      ),
    );
    expect(find.text('+91'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('India')), findsWidgets);
    final field = find.byType(TextField);
    expect(tester.widget<TextField>(field).controller!.text, '9876543210');
    await tester.tap(field);
    await tester.pumpAndSettle();
    expect(tester.testTextInput.isVisible, isTrue);
    await tester.tapAt(const Offset(790, 590));
    await tester.pumpAndSettle();
    expect(tester.testTextInput.isVisible, isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
    form.dispose();
  });

  testWidgets(
    'pickup autocomplete searches API and requires an actual option',
    (tester) async {
      final form = DynamicFormController(
        schema: const ApiFormAdapter().parse([
          {
            'name': 'pickup_address',
            'label': 'Pickup Address',
            'type': 'link',
            'object_type': 'pickup_address',
            'required': true,
          },
        ], id: 'lookup'),
      );
      final api = RecordingApiClient(
        (r) async => pageFixture([
          {'id': 'PA-1', 'label': 'Main warehouse', 'description': 'Delhi'},
        ]),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: ShipKiaTheme.light,
          home: ShipKiaApiScope(
            apiClient: api,
            child: Scaffold(
              body: DynamicFormBuilder(schema: form.schema, controller: form),
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'Main');
      await tester.pumpAndSettle(const Duration(milliseconds: 350));
      expect(api.requests.last.params?['search'], 'Main');
      expect(form.validate(), isFalse);
      await tester.tap(find.text('Main warehouse'));
      await tester.pumpAndSettle();
      expect(form.values['pickup_address'], 'PA-1');
      expect(form.validate(), isTrue);
      expect(find.text('Close'), findsNothing);
      await tester.tap(find.byTooltip('Clear Pickup Address'));
      await tester.pumpAndSettle();
      expect(form.values['pickup_address'], isNull);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(790, 590));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus,
        isFalse,
      );
      expect(find.text('Main warehouse'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      form.dispose();
    },
  );
  testWidgets(
    'new order uses fields endpoint and submits create payload without source identity',
    (tester) async {
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
        return {
          'value': {'id': 'CREATED'},
        };
      });
      await tester.pumpWidget(
        MaterialApp(
          theme: ShipKiaTheme.light,
          home: ShipKiaApiScope(
            apiClient: api,
            child: const OrderDetailScreen(orderId: 'new'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(api.requests.any((r) => r.path.endsWith('/records/new')), isFalse);
      expect(find.byTooltip('Copy order ID'), findsNothing);
      await tester.enterText(find.byType(TextField), 'Customer');
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();
      expect(api.requests.last.method, HttpMethod.post);
      expect(api.requests.last.path, '/oms/orders/records');
      expect(api.requests.last.data, {'delivery_full_name': 'Customer'});
    },
  );
}
