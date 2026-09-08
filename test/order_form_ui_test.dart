import 'package:shipkia_app/src/features/orders/order_detail_widgets.dart';

import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shipkia_app/src/core/api/api.dart';
import 'package:shipkia_app/src/core/forms/forms.dart';
import 'package:shipkia_app/src/design_system/design_system.dart';
import 'package:shipkia_app/src/features/orders/domain/order_form.dart';
import 'package:shipkia_app/src/features/orders/domain/order_summary.dart';
import 'package:shipkia_app/src/features/orders/order_detail_screen.dart';
import 'package:shipkia_app/src/theme/shipkia_theme.dart';
import 'package:shipkia_app/src/widgets/shipkia_widgets.dart';

import 'support/recording_api_client.dart';

const fields = [
  {
    'name': 'stage',
    'type': 'option',
    'options': 'New,Delivered',
    'readonly': true,
  },
  {'name': 'delivery_section', 'type': 'section', 'label': 'Delivery Details'},
  {
    'name': 'delivery_full_name',
    'type': 'text',
    'label': 'Delivery Full Name',
    'required': true,
  },
  {'name': 'is_billing_same', 'type': 'bool', 'label': 'Is billing same'},
  {'name': 'billing_section', 'type': 'section', 'label': 'Billing Address'},
  {'name': 'billing_full_name', 'type': 'text', 'label': 'Billing Full Name'},
  {'name': 'payment_section', 'type': 'section', 'label': 'Payment Details'},
  {
    'name': 'payment_method',
    'type': 'option',
    'label': 'Payment Method',
    'options': 'cod,prepaid',
  },
  {
    'name': 'prepaid_amount',
    'type': 'unit',
    'label': 'Prepaid Amount',
    'display': 'currency',
  },
  {
    'name': 'total_order_value',
    'type': 'unit',
    'display': 'currency',
    'readonly': true,
  },
];

void main() {
  testWidgets(
    'product drawer registers every API field and accepts tax options with max one',
    (tester) async {
      final raw = jsonDecode(
        File('test/fixtures/order_fields.json').readAsStringSync(),
      );
      final product = OrderForm.fields(raw)
          .firstWhere((f) => f['name'] == 'product_details');
      final schema = const ApiFormAdapter().parse([product], id: 'products');
      final form = DynamicFormController(schema: schema);
      await tester.pumpWidget(
        MaterialApp(
          theme: ShipKiaTheme.light,
          home: Scaffold(
            body: DynamicFormBuilder(schema: schema, controller: form),
          ),
        ),
      );
      await tester.tap(find.text('Add row'));
      await tester.pumpAndSettle();
      final rowBuilder = tester
          .widgetList<DynamicFormBuilder>(find.byType(DynamicFormBuilder))
          .last;
      final row = rowBuilder.controller;
      for (final field in row.schema.fields) {
        expect(field.visible, isTrue, reason: field.id);
        expect(field.visibleWhen, isNull, reason: field.id);
      }
      expect(
        row.schema.fields.map((f) => f.id),
        containsAll([
          'product_name',
          'hsn_code',
          'unit_price',
          'quantity',
          'product_discount',
          'tax_rate',
          'tax_preference',
        ]),
      );
      row.setValue('product_name', 'Test product');
      row.setValue('unit_price', 100);
      for (final value in ['Inclusive', 'Exclusive']) {
        row.setValue('tax_preference', value);
        expect(row.validate(), isTrue);
      }
      row.setValue('tax_preference', 'Invalid');
      expect(row.validate(), isFalse);
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox.shrink());
      form.dispose();
    },
  );

  testWidgets(
    'compact header has small copy, no status or ecommerce tags and mobile actions',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final api = RecordingApiClient((r) async {
        if (r.path.endsWith('/permissions')) {
          return {'update': true, 'create': true};
        }
        return {
          'value': {
            'id': 'ORD-2026-00017',
            'stage': 'New',
            'status': 'New',
            'ecom_platform': 'shopify',
            'ecom_order_name': '#1025',
            'is_billing_same': true,
          },
          'fields': fields,
        };
      });
      await tester.pumpWidget(
        MaterialApp(
          theme: ShipKiaTheme.light,
          home: ShipKiaApiScope(
            apiClient: api,
            child: const OrderDetailScreen(orderId: 'ORD-2026-00017'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final toolbar = find.byType(OrderDetailToolbar);
      expect(tester.getSize(toolbar).height, lessThan(80));
      expect(
        find.descendant(of: toolbar, matching: find.byTooltip('Copy order ID')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: toolbar, matching: find.text('New')),
        findsNothing,
      );
      expect(
        find.descendant(of: toolbar, matching: find.text('#1025')),
        findsNothing,
      );
      await tester.tap(find.byTooltip('Order actions'));
      await tester.pumpAndSettle();
      expect(find.byType(AppActionSheet), findsOneWidget);
      for (final label in [
        'Download Invoice',
        'Cancel',
        'Support Tickets',
        'New',
        'Refresh order',
        'Duplicate',
      ]) {
        expect(
          find.descendant(
            of: find.byType(AppActionSheet),
            matching: find.text(label),
          ),
          findsOneWidget,
        );
      }
      expect(find.textContaining('Shift'), findsNothing);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keep order'));
      await tester.pumpAndSettle();
      expect(api.requests.where((r) => r.method == HttpMethod.delete), isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  test(
    'attached API readonly flags are enforced including nested product fields',
    () {
      final fields = jsonDecode(
        File('test/fixtures/order_fields.json').readAsStringSync(),
      ) as List;
      final adapter = const ApiFormAdapter();
      void check(List source) {
        for (final raw in source.cast<Map>()) {
          if (raw['type'] != 'section') {
            final field = adapter.field(Map<String, dynamic>.from(raw));
            expect(
              field.access.isReadOnly,
              raw['readonly'] == true,
              reason: '${raw['name']}',
            );
          }
          if (raw['fields'] is List) check(raw['fields'] as List);
        }
      }

      check(fields);
      final form = DynamicFormController(
        schema: adapter.parse(
          OrderForm.fields(fields),
          id: 'order',
          values: {
            'status': 'New',
            'stage': 'New',
            'delivery_city': 'City',
            'is_billing_same': true,
          },
        ),
      );
      final original = OrderForm.stored(form);
      form.setValue('status', 'Delivered');
      form.setValue('delivery_city', 'Changed');
      expect(OrderForm.changes(form, original), isEmpty);
      form.dispose();
    },
  );

  testWidgets(
    'bottom buttons switch panels, preserve input and load activity on demand',
    (tester) async {
      final api = RecordingApiClient((r) async {
        if (r.path.endsWith('/permissions')) {
          return {'update': true, 'create': true};
        }
        if (r.path.endsWith('/activity')) return pageFixture([]);
        return {
          'value': {
            'id': 'TEST-ORDER',
            'stage': 'New',
            'delivery_full_name': 'Customer',
            'is_billing_same': true,
          },
          'fields': fields,
        };
      });
      await tester.pumpWidget(
        MaterialApp(
          theme: ShipKiaTheme.light,
          home: ShipKiaApiScope(
            apiClient: api,
            child: const OrderDetailScreen(orderId: 'TEST-ORDER'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('AWB not generated'), findsOneWidget);
      final name = find.descendant(
        of: find.byKey(const ValueKey('delivery_full_name')),
        matching: find.byType(TextField),
      );
      await tester.enterText(name, 'Unsaved name');
      await tester.tap(find.byTooltip('Order summary'));
      await tester.pumpAndSettle();
      expect(find.text('Product total'), findsOneWidget);
      expect(api.requests.where((r) => r.path.endsWith('/activity')), isEmpty);
      await tester.tap(find.byTooltip('Activity'));
      await tester.pumpAndSettle();
      expect(find.text('No activity yet'), findsOneWidget);
      expect(api.requests.last.params?['id'], 'TEST-ORDER');
      await tester.tap(find.byTooltip('Form'));
      await tester.pumpAndSettle();
      expect(find.text('Unsaved name'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'chips and buttons fit content, center labels and grow with text',
    (tester) async {
      for (final scale in [1.0, 1.8]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: ShipKiaTheme.light,
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: Scaffold(
                body: SizedBox(
                  width: 390,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppChip(label: 'New', onSelected: (_) {}),
                      AppButton(label: 'Update', onPressed: () {}),
                      const SkStatusBadge(status: ShipmentStatus.newOrder),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final chip = tester.getRect(
          find.descendant(
            of: find.byType(AppChip),
            matching: find.byType(AnimatedContainer),
          ),
        );
        final label = tester.getRect(find.text('New'));
        expect(chip.width, lessThan(110));
        expect(chip.height, lessThan(42));
        expect((chip.center.dy - label.center.dy).abs(), lessThan(1));
        expect((chip.center.dx - label.center.dx).abs(), lessThan(1));
        final button = tester.getRect(find.byType(TextButton));
        expect(button.width, lessThan(150));
        expect(button.height, lessThan(48));
        final badge = tester.getRect(
          find.descendant(
            of: find.byType(SkStatusBadge),
            matching: find.byType(AnimatedContainer),
          ),
        );
        expect(badge.width, lessThan(180));
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets('iOS buttons size to their label without a fixed-height clip', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [AppButton(label: 'Update', onPressed: () {})],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final bounds = tester.getRect(find.byType(CupertinoButton));
    expect(bounds.width, lessThan(150));
    expect(bounds.height, lessThan(40));
    expect(tester.takeException(), isNull);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets(
    'product lookup fills registered price and tax fields in display units',
    (tester) async {
      final schema = const ApiFormAdapter().parse([
        {
          'name': 'product_name',
          'label': 'Product Name',
          'type': 'text',
          'object_type': 'products',
          'display': {'price': 'unit_price', 'tax_rate': 'tax_rate'},
        },
        {
          'name': 'unit_price',
          'label': 'Unit Price',
          'type': 'unit',
          'display': 'currency',
        },
        {
          'name': 'tax_rate',
          'label': 'Tax Rate',
          'type': 'float',
          'readonly': true,
        },
      ], id: 'product-row');
      final form = DynamicFormController(schema: schema);
      final api = RecordingApiClient(
        (r) async => r.path.endsWith('/options')
            ? pageFixture([
                {'id': 'PRODUCT-1', 'label': 'Test product'},
              ])
            : {
                'value': {'price': 12500, 'tax_rate': 18},
              },
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: ShipKiaTheme.light,
          home: ShipKiaApiScope(
            apiClient: api,
            child: Scaffold(
              body: DynamicFormBuilder(schema: schema, controller: form),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Test');
      await tester.pumpAndSettle(const Duration(milliseconds: 350));
      expect(api.requests.last.params?['search'], 'Test');
      await tester.tap(find.text('Test product'));
      await tester.pumpAndSettle();
      expect(form.values['product_name'], 'PRODUCT-1');
      expect(form.values['unit_price'], 125);
      expect(form.values['tax_rate'], 18);
      expect(form.validate(), isTrue);
      expect(
        const ApiFormAdapter().serialize(schema, form.values)['unit_price'],
        12500,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      form.dispose();
    },
  );

  test('order totals use stored money and exclusive tax; invalid discounts and prepaid are rejected', () {
    final total = OrderFormTotals({
      'product_details': [
        {
          'unit_price': 10000,
          'quantity': 2,
          'tax_rate': 18,
          'tax_preference': 'Exclusive',
          'product_discount': 1000,
        },
      ],
      'shipping_charge': 500,
      'payment_method': 'cod',
      'prepaid_amount': 5000,
    });
    expect(total.total, 23100);
    expect(total.remaining, 18100);
    expect(total.error, isNull);
    expect(
      OrderFormTotals({
        'payment_method': 'cod',
        'prepaid_amount': 100,
      }, savedTotal: 50).error,
      isNotNull,
    );
    expect(
      OrderFormTotals({
        'product_details': [
          {'unit_price': 100, 'quantity': 1, 'product_discount': 101},
        ],
      }).error,
      isNotNull,
    );
  });

  test('order payload includes changed editable fields and newly enabled billing fields only', () {
    final form = DynamicFormController(
      schema: const ApiFormAdapter().parse(
        OrderForm.fields(fields),
        id: 'order',
        values: {
          'stage': 'New',
          'delivery_full_name': 'Customer',
          'is_billing_same': true,
          'billing_full_name': 'Billing customer',
          'payment_method': 'cod',
          'prepaid_amount': 5000,
        },
      ),
    );
    final original = OrderForm.stored(form);
    form.setValue('prepaid_amount', '75');
    form.setValue('is_billing_same', false);
    expect(OrderForm.changes(form, original), {
      'prepaid_amount': 7500,
      'is_billing_same': false,
      'billing_full_name': 'Billing customer',
    });
    form.dispose();
  });

  testWidgets(
    'order opens registered fields and PATCHes edits; failed save retains input',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var fail = true;
      final values = <String, dynamic>{
        'id': 'LIVE',
        'stage': 'New',
        'delivery_full_name': 'Customer',
        'is_billing_same': true,
        'payment_method': 'prepaid',
        'total_order_value': 10000,
      };
      final api = RecordingApiClient((request) async {
        if (request.path.endsWith('/permissions')) {
          return {'update': true, 'create': true};
        }
        if (request.method == HttpMethod.patch) {
          if (fail) throw const FormatException('Update failed');
          values.addAll(Map<String, dynamic>.from(request.data as Map));
        }
        return {'value': values, 'fields': fields};
      });
      await tester.pumpWidget(
        MaterialApp(
          theme: ShipKiaTheme.light,
          home: ShipKiaApiScope(
            apiClient: api,
            child: const OrderDetailScreen(orderId: 'LIVE'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(DynamicFormBuilder), findsOneWidget);
      expect(find.text('Delivery Details'), findsOneWidget);
      expect(find.text('Billing Address'), findsNothing);
      expect(find.text('Prepaid Amount'), findsNothing);
      final name = find.descendant(
        of: find.byKey(const ValueKey('delivery_full_name')),
        matching: find.byType(TextField),
      );
      await tester.enterText(name, 'Updated customer');
      await tester.tap(find.byTooltip('Order actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Update').last);
      await tester.pumpAndSettle();
      expect(api.requests.last.data, {
        'delivery_full_name': 'Updated customer',
      });
      expect(find.text('Updated customer'), findsOneWidget);
      fail = false;
      await tester.tap(find.byTooltip('Order actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Update').last);
      await tester.pumpAndSettle();
      expect(values['delivery_full_name'], 'Updated customer');
      expect(find.text('Order updated'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  test('summary preview tolerates incomplete numeric input while validation rejects it', () {
    final form = DynamicFormController(
      schema: const ApiFormAdapter().parse(
        OrderForm.fields(fields),
        id: 'partial',
        values: {'payment_method': 'cod'},
      ),
    );
    form.setValue('prepaid_amount', '.');
    expect(OrderForm.stored(form, forPreview: true)['prepaid_amount'], isNull);
    expect(form.validate(), isFalse);
    form.dispose();
  });

  testWidgets('later-stage orders remain form fields without update action', (
    tester,
  ) async {
    final api = RecordingApiClient(
      (r) async => r.path.endsWith('/permissions')
          ? {'update': true}
          : {
              'value': {
                'id': 'SENT',
                'stage': 'Delivered',
                'delivery_full_name': 'Customer',
                'is_billing_same': true,
              },
              'fields': fields,
            },
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: ShipKiaTheme.light,
        home: ShipKiaApiScope(
          apiClient: api,
          child: const OrderDetailScreen(orderId: 'SENT'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(DynamicFormBuilder), findsOneWidget);
    expect(find.text('Update'), findsNothing);
    expect(
      tester
          .widget<TextField>(
            find.descendant(
              of: find.byKey(const ValueKey('delivery_full_name')),
              matching: find.byType(TextField),
            ),
          )
          .readOnly,
      isTrue,
    );
  });
}
