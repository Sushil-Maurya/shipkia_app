import 'dart:convert';

import '../../../core/forms/forms.dart';

/// Order-only rules from the web formConfig, payload and totals contracts.
abstract final class OrderForm {
  static const hidden = {
    'id',
    'stage',
    'section_break_final_chrg',
    'total_order_value',
    'volumetric_weight',
    'remaining_cod_amount',
    'cod_amount',
  };

  static List<Map<String, dynamic>> fields(Object? response) {
    Map<String, dynamic> normalize(
      Map<String, dynamic> raw, {
      bool productRow = false,
    }) {
      final f = Map<String, dynamic>.from(raw);
      final name = ApiFormAdapter.nameOf(f);
      if (!productRow && hidden.contains(name)) f['form_view'] = false;
      if (!productRow &&
          ApiFormAdapter.flag(f['readonly']) &&
          name != 'status') {
        f['_visibleWhenNotEmpty'] = name;
      }
      if (name.startsWith('billing_')) {
        f['_visibleWhen'] = FormCondition.equals(
          fieldId: 'is_billing_same',
          value: false,
        );
        if (name != 'billing_landmark') f['required'] = true;
      }
      if (name == 'prepaid_amount') {
        f['defaultValue'] ??= 0;
        f['_visibleWhen'] = FormCondition.any([
          FormCondition.equals(fieldId: 'payment_method', value: 'cod'),
          FormCondition.equals(
            fieldId: 'payment_method',
            value: 'Cash on delivery',
          ),
        ]);
      }
      if (name == 'payment_method') {
        f['options'] = [
          for (final o in ApiFormAdapter.parseOptions(f['options']))
            {
              'id': o.value,
              'label': switch ('${o.value}'.toLowerCase()) {
                'cod' => 'COD(Cash on Delivery)',
                'prepaid' => 'Prepaid',
                _ => o.label,
              },
            },
        ];
      }
      if (f['fields'] is List) {
        f['fields'] = ApiFormAdapter.fieldsFrom(f['fields'])
            .map(
              (child) => normalize(
                child,
                productRow: productRow || name == 'product_details',
              ),
            )
            .toList();
      }
      if (name == 'product_details') {
        f['defaultRow'] = {'quantity': 1, ...?f['defaultRow'] as Map?};
        f['_presentation'] = 'order_products';
      }
      if (name == 'product_discount') {
        f['min'] = 0;
        f['defaultValue'] ??= 0;
      }
      return f;
    }

    return ApiFormAdapter.fieldsFrom(response)
        .map(normalize)
        .where((f) => !(f['type'] == 'section' && f['form_view'] == false))
        .toList();
  }

  static Map<String, dynamic> duplicateValues(Map<String, dynamic> values) {
    const excluded = {
      'id',
      'name',
      'awb',
      'reference_id',
      'stage',
      'status',
      'courier_partner',
      'courier_mode',
      'download_status',
      'ecom_linked_mapping',
      'ecom_order_name',
      'ecom_platform',
      'ecom_store_name',
      'creation',
      'created_at',
      'created_by',
      'modified',
      'modified_at',
      'modified_by',
      'row_id',
      'updated_at',
      'pickup_date',
      'delivered_date',
      'estimated_delivery_date',
      'promised_delivery_date',
      'sort_code',
      'customer_engagement',
    };
    return {
      for (final e in values.entries)
        if (!excluded.contains(e.key)) e.key: e.value,
    };
  }

  static num number(Object? value) => num.tryParse('$value') ?? 0;
  static bool isCod(Object? value) =>
      {'cod', 'cash on delivery'}.contains('$value'.toLowerCase());
  static Map<String, Object?> stored(
    DynamicFormController form, {
    bool forPreview = false,
  }) {
    final values = form.values;
    if (forPreview) {
      for (final field in form.schema.fields) {
        if ({
              DynamicFieldType.unit,
              DynamicFieldType.number,
              DynamicFieldType.decimal,
            }.contains(field.type) &&
            num.tryParse('${values[field.id]}') == null) {
          values[field.id] = null;
        }
      }
    }
    return const ApiFormAdapter().serialize(form.schema, values);
  }

  static Map<String, Object?> changes(
    DynamicFormController form,
    Map<String, Object?> original,
  ) {
    final current = stored(form);
    final changed = <String, Object?>{};
    for (final field in form.schema.fields) {
      if (!field.access.canEdit || !current.containsKey(field.id)) continue;
      if (jsonEncode(current[field.id]) != jsonEncode(original[field.id])) {
        changed[field.id] = current[field.id] == '' ? null : current[field.id];
      }
    }
    if (changed['is_billing_same'] == false) {
      for (final entry in current.entries.where(
        (e) => e.key.startsWith('billing_'),
      )) {
        changed[entry.key] = entry.value;
      }
    }
    if (changed['product_details'] is List) {
      const keys = {
        'product_name',
        'hsn_code',
        'quantity',
        'unit_price',
        'tax_rate',
        'tax_preference',
        'product_discount',
        'weight',
      };
      changed['product_details'] = [
        for (final row in changed['product_details'] as List)
          if (row is Map)
            {
              for (final e in row.entries)
                if (keys.contains(e.key)) '${e.key}': e.value,
            },
      ];
    }
    return changed;
  }
}

class OrderFormTotals {
  OrderFormTotals(Map<String, Object?> values, {num? savedTotal}) {
    final products = values['product_details'];
    if (products is List) {
      for (final (index, row) in products.indexed) {
        if (row is! Map) continue;
        final line =
            OrderForm.number(row['unit_price']) *
            OrderForm.number(row['quantity']);
        final rowDiscount = OrderForm.number(row['product_discount']);
        subtotal +=
            line *
            ('${row['tax_preference']}'.toLowerCase() == 'exclusive'
                ? 1 + OrderForm.number(row['tax_rate']) / 100
                : 1);
        discount += rowDiscount;
        if (rowDiscount > line) {
          error ??=
              'Product discount exceeds price times quantity in row ${index + 1}.';
        }
      }
    }
    otherCharges =
        OrderForm.number(values['shipping_charge']) +
        OrderForm.number(values['transaction_charge']) +
        OrderForm.number(values['gift_wrap_charge']);
    discount +=
        OrderForm.number(values['additional_discount']) +
        OrderForm.number(values['total_discount']);
    total = savedTotal ?? (subtotal + otherCharges - discount);
    prepaid = OrderForm.number(values['prepaid_amount']);
    cod = OrderForm.isCod(values['payment_method']);
    remaining = cod ? (total - prepaid).clamp(0, double.infinity) : 0;
    if (total < 0) error ??= 'Order value cannot be negative.';
    if (cod && prepaid > total) {
      error ??= 'Prepaid amount cannot be greater than order value.';
    }
  }
  num subtotal = 0,
      discount = 0,
      otherCharges = 0,
      total = 0,
      prepaid = 0,
      remaining = 0;
  bool cod = false;
  String? error;
}
