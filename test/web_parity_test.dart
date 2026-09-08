import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shipkia_app/src/core/forms/forms.dart';
import 'package:shipkia_app/src/core/router/web_module_catalog.dart';
import 'package:shipkia_app/src/features/home/home_screen.dart';
import 'package:shipkia_app/src/features/modules/asset_form_overrides.dart';
import 'package:shipkia_app/src/features/modules/module_list_tabs.dart';
import 'package:shipkia_app/src/features/modules/module_records.dart';
import 'package:shipkia_app/src/theme/shipkia_theme.dart';

import 'support/recording_api_client.dart';

void main() {
  test('Returns inherit order stages with the web exclusions', () {
    final tabs = ModuleListTab.forType('return_orders');
    expect(tabs.map((t) => t.label), [
      'New',
      'Ready to Pickup',
      'In Transit',
      'Delivered',
      'Cancelled',
      'All',
    ]);
    expect(tabs[2].filter, {'id': 'stage', 'opr': '=', 'value': 'In-Transit'});
    expect(tabs.last.filter, isNull);
  });
  test(
    'NDR tab filter combines with search without changing OR semantics',
    () async {
      final api = RecordingApiClient((_) async => pageFixture([]));
      final route = WebModuleCatalog.allRoutes.firstWhere(
        (r) => r.objectType == 'delivery_attempt',
      );
      await ModuleRepository(api, route).list(
        1,
        20,
        CancelToken(),
        search: 'AWB',
        tab: ModuleListTab.forType('delivery_attempt')[1],
      );
      final filters =
          (api.requests.single.data as Map)['filters']['filterSet'] as List;
      expect(filters.first, {
        'id': 'stage',
        'opr': 'in',
        'value': ['Pending'],
      });
      expect(filters.last['connector'], 'or');
      expect(filters.last['filterSet'].map((f) => f['id']), [
        'order_id',
        'awb',
      ]);
      expect(ModuleListTab.forType('pickup_and_manifest')[1].filter, {
        'id': 'status',
        'opr': '=',
        'value': 'Scheduled',
      });
    },
  );
  test(
    'bank placeholders and pickup defaults come from web module overrides',
    () {
      final bank = AssetFormOverrides.fields('bank_accounts', [
        {'name': 'account_number', 'type': 'text'},
      ]);
      expect(bank.single['placeholder'], 'Enter account number');
      final raw = AssetFormOverrides.fields('pickup_address', [
        {
          'name': 'operational_days',
          'type': 'grid',
          'min': 1,
          'fields': [
            {'name': 'day', 'type': 'option', 'options': 'Monday,Tuesday'},
          ],
        },
        {'name': 'rto_address', 'type': 'link'},
      ]);
      final schema = const ApiFormAdapter().parse(raw, id: 'pickup_address');
      final c = DynamicFormController(schema: schema);
      addTearDown(c.dispose);
      expect(c.values['operational_days'], [
        {'day': 'Monday'},
        {'day': 'Tuesday'},
      ]);
      expect(schema.fields.last.required, true);
      expect(
        const ApiFormAdapter().serialize(schema, c.values)['operational_days'],
        [
          {'day': 'Monday'},
          {'day': 'Tuesday'},
        ],
      );
    },
  );
  testWidgets(
    'pickup days use the server week checklist and hide empty derived fields',
    (tester) async {
      final raw = AssetFormOverrides.fields('pickup_address', [
        {'name': 'postal_code', 'type': 'postal_code'},
        {'name': 'city', 'type': 'text', 'label': 'City', 'readonly': true},
        {
          'name': 'operational_days',
          'label': 'Operational Days',
          'type': 'grid',
          'fields': [
            {'name': 'day', 'type': 'option', 'options': 'Monday,Tuesday'},
          ],
        },
      ]);
      final schema = const ApiFormAdapter().parse(raw, id: 'pickup_address');
      final c = DynamicFormController(schema: schema);
      addTearDown(c.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: ShipKiaTheme.light,
          home: Scaffold(
            body: SingleChildScrollView(
              child: DynamicFormBuilder(schema: schema, controller: c),
            ),
          ),
        ),
      );
      expect(find.text('Monday'), findsOneWidget);
      expect(find.text('Add row'), findsNothing);
      expect(find.text('City'), findsNothing);
      await tester.tap(find.text('Monday'));
      await tester.pumpAndSettle();
      expect(c.values['operational_days'], [
        {'day': 'Tuesday'},
      ]);
      c.setValue('city', 'Delhi');
      await tester.pumpAndSettle();
      expect(find.text('Delhi'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('Home uses workflow shortcuts without fabricated order metrics', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ShipKiaTheme.light,
        home: const Scaffold(body: HomeScreen()),
      ),
    );
    expect(find.text('Welcome there'), findsOneWidget);
    expect(find.text('Quick actions'), findsOneWidget);
    expect(find.text('Priority Orders'), findsNothing);
    expect(find.text('ORD-10491'), findsNothing);
  });
}
