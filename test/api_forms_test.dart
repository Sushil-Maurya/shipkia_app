import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shipkia_app/src/core/api/api.dart';
import 'package:shipkia_app/src/core/auth/shipkia_auth_controller.dart';
import 'package:shipkia_app/src/core/auth/shipkia_auth_scope.dart';
import 'package:shipkia_app/src/core/forms/forms.dart';
import 'package:shipkia_app/src/core/router/web_module_catalog.dart';
import 'package:shipkia_app/src/features/auth/data/auth_session.dart';
import 'package:shipkia_app/src/features/modules/asset_form_screen.dart';
import 'package:shipkia_app/src/theme/shipkia_theme.dart';

import 'support/recording_api_client.dart';

class _Auth extends ShipKiaAuthController {
  _Auth(this.role)
    : super(
        initialStatus: ShipKiaAuthStatus.authenticated,
        restoreDelay: Duration.zero,
      );
  final String role;
  @override
  AuthProfile get profile => AuthProfile(
    id: '1',
    email: 'fixture@example.test',
    phone: '',
    type: 'customer',
    roles: [role],
  );
}

void main() {
  const adapter = ApiFormAdapter();
  test('wire types register through native registry; sections retain order and name wins over empty id', () {
    final schema = adapter.parse([
      {'type': 'section', 'name': 'same', 'label': 'Company'},
      {'id': '', 'name': 'company', 'type': 'text', 'required': true},
      {'type': 'section', 'name': 'same', 'label': 'Financial'},
      {'name': 'rate', 'type': 'float', 'min': 0, 'max': 100},
      {'name': 'bank', 'type': 'option', 'options': 'One,Two'},
      {'name': 'active', 'type': 'bool'},
    ], id: 'test');
    expect(schema.sections.map((s) => s.title), ['Company', 'Financial']);
    expect(schema.fields.first.id, 'company');
    expect(schema.fields.map((f) => f.type), [
      DynamicFieldType.text,
      DynamicFieldType.decimal,
      DynamicFieldType.select,
      DynamicFieldType.checkbox,
    ]);
    expect(schema.fields.elementAt(2).options.map((o) => o.value), [
      'One',
      'Two',
    ]);
    for (final type in [
      'unit',
      'link',
      'grid',
      'datetime',
      'postal_code',
      'json',
    ]) {
      expect(
        createShipKiaFieldRegistry().resolve(DynamicFieldType.fromWire(type)),
        isNot(isA<UnknownFieldRenderer>()),
      );
    }
  });
  test('web defaults and multi-select preserve IDs and form visibility', () {
    final schema = adapter.parse({
      'data': {
        'fields': [
          {
            'name': 'choices',
            'type': 'option',
            'multiSelect': true,
            'defaultValue': [2],
            'options': [
              {'id': 2, 'label': 'Two'},
            ],
          },
          {'name': 'internal', 'type': 'text', 'form_view': false},
        ],
      },
    }, id: 'defaults');
    expect(schema.fields.first.type, DynamicFieldType.multiSelect);
    expect(schema.fields.first.initialValue, [2]);
    expect(schema.fields.last.visible, false);
  });

  test(
    'numeric units validate display bounds and serialize API storage once',
    () {
      final schema = adapter.parse(
        [
          {
            'name': 'weight',
            'type': 'unit',
            'display': 'weight',
            'required': true,
            'min': 100,
            'max': 2000,
          },
          {'name': 'price', 'type': 'unit', 'display': 'currency'},
        ],
        id: 'product',
        values: {'weight': 1250, 'price': 12999},
      );
      final c = DynamicFormController(schema: schema);
      addTearDown(c.dispose);
      expect(c.values['weight'], 1.25);
      expect(c.values['price'], 129.99);
      expect(adapter.serialize(schema, c.values), {
        'weight': 1250,
        'price': 12999,
      });
      c.setValue('weight', '3');
      expect(c.validate(), false);
      c.setValue('weight', 'NaN');
      expect(c.validate(), false);
      c.setValue('weight', '0.5');
      expect(c.validate(), true);
      expect(adapter.serialize(schema, c.values)['weight'], 500);
    },
  );
  test('readonly generated IDs do not block creation and hidden fields are not submitted', () {
    final schema = adapter.parse([
      {'name': 'id', 'type': 'uid', 'readonly': true, 'required': true},
      {
        'name': 'bank',
        'type': 'option',
        'options': [
          {'id': 7, 'label': 'Bank'},
        ],
      },
      {'name': 'hidden', 'type': 'text', 'hidden': true, 'required': true},
    ], id: 'bank');
    final c = DynamicFormController(schema: schema);
    addTearDown(c.dispose);
    c.setValue('bank', 7);
    expect(c.validate(), true);
    expect(adapter.serialize(schema, c.values), {'bank': 7});
  });
  test(
    'grid rows validate required children and API values survive round trip',
    () {
      final fields = [
        {
          'name': 'days',
          'type': 'grid',
          'min': 1,
          'max': 2,
          'fields': [
            {
              'name': 'day',
              'type': 'option',
              'required': true,
              'options': 'Monday,Tuesday',
            },
          ],
        },
      ];
      final schema = adapter.parse(
        fields,
        id: 'pickup',
        values: {
          'days': [
            {'day': 'Monday'},
          ],
        },
      );
      final c = DynamicFormController(schema: schema);
      addTearDown(c.dispose);
      expect(c.validate(), true);
      expect(adapter.serialize(schema, c.values)['days'], [
        {'day': 'Monday'},
      ]);
      c.setValue('days', [{}]);
      expect(c.validate(), false);
      expect(c.fieldState('days').errorText, contains('Row 1'));
    },
  );
  test(
    'unknown editable fields block submission and duplicate field names fail',
    () {
      final c = DynamicFormController(
        schema: adapter.parse([
          {'name': 'special', 'type': 'future-widget'},
        ], id: 'future'),
      );
      addTearDown(c.dispose);
      expect(c.validate(), false);
      expect(
        () => adapter.parse([
          {'name': 'a', 'type': 'text'},
          {'name': 'a', 'type': 'text'},
        ], id: 'bad'),
        throwsArgumentError,
      );
    },
  );
  test('conditional fields and dates serialize without display labels', () {
    final schema = adapter.parse(
      [
        {'name': 'bank', 'type': 'option', 'options': 'Other,Example'},
        {'name': 'bank_name', 'type': 'text', 'required': true},
        {'name': 'time', 'type': 'time'},
        {'name': 'date', 'type': 'date'},
        {'name': 'data', 'type': 'json'},
      ],
      id: 'bank',
      values: {
        'bank': 'Example',
        'time': '09:30',
        'date': '2026-09-08',
        'data': {'a': 1},
      },
    );
    final c = DynamicFormController(schema: schema);
    addTearDown(c.dispose);
    expect(c.validate(), true);
    final payload = adapter.serialize(schema, c.values);
    expect(payload.containsKey('bank_name'), false);
    expect(payload['time'], '09:30');
    expect(payload['date'], '2026-09-08');
    expect(payload['data'], {'a': 1});
    c.setValue('bank', 'Other');
    expect(c.validate(), false);
  });
  testWidgets('API metadata renders and creates product with storage units', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final api = RecordingApiClient(
      (r) async => r.path.endsWith('/fields')
          ? [
              {
                'name': 'product_name',
                'type': 'text',
                'label': 'Product name',
                'required': true,
              },
              {
                'name': 'weight',
                'type': 'unit',
                'display': 'weight',
                'label': 'Weight',
                'required': true,
              },
            ]
          : {
              'value': {'id': 'NEW'},
            },
    );
    final auth = _Auth('ordermanager');
    addTearDown(auth.dispose);
    final module = WebModuleCatalog.allRoutes.firstWhere(
      (r) => r.objectType == 'products',
    );
    await tester.pumpWidget(
      ShipKiaAuthScope(
        controller: auth,
        child: ShipKiaApiScope(
          apiClient: api,
          child: MaterialApp(
            theme: ShipKiaTheme.light,
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => AssetFormScreen(route: module),
                    ),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.byType(DynamicFormBuilder), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(0), 'Canvas tote');
    await tester.enterText(find.byType(TextField).at(1), '0.25');
    expect(find.text('KG'), findsOneWidget);
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();
    final save = api.requests.firstWhere((r) => r.method == HttpMethod.post);
    expect(save.path, '/oms/products/records');
    expect(save.data, {'product_name': 'Canvas tote', 'weight': 250});
    expect(tester.takeException(), isNull);
  });
  testWidgets('readonly role sees API form without save action', (
    tester,
  ) async {
    final auth = _Auth('buopso');
    addTearDown(auth.dispose);
    final api = RecordingApiClient(
      (r) async => r.path.endsWith('/fields')
          ? [
              {'name': 'account_name', 'type': 'text', 'label': 'Account name'},
            ]
          : {
              'value': {'id': 'BANK', 'account_name': 'Example'},
            },
    );
    await tester.pumpWidget(
      ShipKiaAuthScope(
        controller: auth,
        child: ShipKiaApiScope(
          apiClient: api,
          child: MaterialApp(
            theme: ShipKiaTheme.light,
            home: AssetFormScreen(
              route: WebModuleCatalog.allRoutes.firstWhere(
                (r) => r.objectType == 'bank_accounts',
              ),
              recordId: 'BANK',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Save'), findsNothing);
    expect(tester.widget<TextField>(find.byType(TextField)).readOnly, true);
    expect(find.text('Example'), findsOneWidget);
  });
  testWidgets(
    'postal lookup ignores stale results and fills metadata mapped fields',
    (tester) async {
      final pending = Completer<Object?>();
      final api = RecordingApiClient(
        (r) async => r.params!['postal_code'] == '110001'
            ? pending.future
            : {'city': 'Mumbai', 'state': 'MH', 'country': 'India'},
      );
      final schema = adapter.parse([
        {
          'name': 'postal_code',
          'type': 'postal_code',
          'display': '{"city":"city"}',
        },
        {'name': 'city', 'type': 'text', 'readonly': true},
      ], id: 'pickup');
      final c = DynamicFormController(schema: schema);
      addTearDown(c.dispose);
      await tester.pumpWidget(
        ShipKiaApiScope(
          apiClient: api,
          child: MaterialApp(
            theme: ShipKiaTheme.light,
            home: Scaffold(
              body: DynamicFormBuilder(schema: schema, controller: c),
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField).first, '110001');
      await tester.pump(const Duration(milliseconds: 400));
      expect(c.validate(), false);
      await tester.enterText(find.byType(TextField).first, '400001');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      pending.complete({'city': 'Delhi'});
      await tester.pumpAndSettle();
      expect(c.values['city'], 'Mumbai');
      expect(c.validate(), true);
    },
  );
}
