import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shipkia_app/src/core/forms/forms.dart';

class _TestRenderer implements DynamicFieldRenderer {
  const _TestRenderer(this.child);

  final Widget child;

  @override
  Widget build(DynamicFieldContext context) => child;
}

void main() {
  group('DynamicFieldRegistry', () {
    test('resolves registered renderers', () {
      final renderer = _TestRenderer(const Text('ok'));
      final registry = DynamicFieldRegistry()
        ..register(DynamicFieldType.text, renderer);

      expect(registry.resolve(DynamicFieldType.text), same(renderer));
    });

    test('returns fallback for unknown field types', () {
      final fallback = _TestRenderer(const Text('fallback'));
      final registry = DynamicFieldRegistry(fallbackRenderer: fallback);

      expect(registry.resolve(DynamicFieldType.unknown), same(fallback));
    });

    test('rejects duplicate registrations', () {
      final registry = DynamicFieldRegistry()
        ..register(DynamicFieldType.text, _TestRenderer(const Text('one')));

      expect(
        () => registry.register(
          DynamicFieldType.text,
          _TestRenderer(const Text('two')),
        ),
        throwsStateError,
      );
    });
  });

  group('DynamicFormController', () {
    test('tracks values, dirty state, and reset', () {
      final schema = DynamicFormSchema.singleSection(
        id: 'profile',
        fields: const [
          DynamicFieldSchema<Object?>(
            id: 'name',
            type: DynamicFieldType.text,
            label: 'Name',
            initialValue: 'ShipKia',
          ),
        ],
      );
      final controller = DynamicFormController(schema: schema);

      expect(controller.getValue<String>('name'), 'ShipKia');
      expect(controller.isDirty, isFalse);

      controller.setValue('name', 'ShipKia Express');

      expect(controller.getValue<String>('name'), 'ShipKia Express');
      expect(controller.fieldState('name').touched, isTrue);
      expect(controller.isDirty, isTrue);

      controller.reset();

      expect(controller.getValue<String>('name'), 'ShipKia');
      expect(controller.isDirty, isFalse);
    });

    test('validates required and conditional fields', () {
      final schema = DynamicFormSchema.singleSection(
        id: 'create_order',
        fields: [
          const DynamicFieldSchema<Object?>(
            id: 'payment_mode',
            type: DynamicFieldType.select,
            label: 'Payment Mode',
          ),
          DynamicFieldSchema<Object?>(
            id: 'cod_amount',
            type: DynamicFieldType.decimal,
            label: 'COD Amount',
            requiredWhen: FormCondition.equals(
              fieldId: 'payment_mode',
              value: 'cod',
            ),
          ),
        ],
      );
      final controller = DynamicFormController(schema: schema);

      expect(controller.validate(), isTrue);

      controller.setValue('payment_mode', 'cod');

      expect(controller.validate(), isFalse);
      expect(
        controller.fieldState('cod_amount').errorText,
        'COD Amount is required.',
      );

      controller.setValue('cod_amount', '100');

      expect(controller.validate(), isTrue);
    });

    test('maps provided validation errors to fields', () {
      final schema = DynamicFormSchema.singleSection(
        id: 'sender',
        fields: const [
          DynamicFieldSchema<Object?>(
            id: 'phone',
            type: DynamicFieldType.phone,
            label: 'Phone',
          ),
        ],
      );
      final controller = DynamicFormController(schema: schema);

      controller.applyFieldErrors({'phone': 'Phone already exists.'});

      expect(controller.fieldState('phone').errorText, 'Phone already exists.');
    });
  });

  testWidgets('renders fields through the central registry', (tester) async {
    final schema = DynamicFormSchema.singleSection(
      id: 'login',
      fields: const [
        DynamicFieldSchema<Object?>(
          id: 'email',
          type: DynamicFieldType.email,
          label: 'Email',
          required: true,
        ),
      ],
    );
    final controller = DynamicFormController(schema: schema);
    final registry = DynamicFieldRegistry()
      ..register(
        DynamicFieldType.email,
        _TestRenderer(const Text('central renderer')),
      );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DynamicFormBuilder(
            schema: schema,
            controller: controller,
            registry: registry,
          ),
        ),
      ),
    );

    expect(find.text('central renderer'), findsOneWidget);
  });
}
