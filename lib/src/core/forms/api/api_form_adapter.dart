import 'dart:convert';

import 'package:flutter/material.dart';

import '../../api/record_units.dart';
import '../forms.dart';

/// Converts the web object field contract to the single native form registry.
/// Values inside the controller use display units; serialization restores storage units.
class ApiFormAdapter {
  const ApiFormAdapter();
  static String nameOf(Map field) => '${field['name'] ?? ''}'.trim().isNotEmpty
      ? '${field['name']}'
      : '${field['id'] ?? ''}';
  static bool flag(Object? value) =>
      value == true || value == 1 || value == 'true' || value == '1';
  static List<Map<String, dynamic>> fieldsFrom(Object? response) {
    final raw = response is Map
        ? response['fields'] ??
              (response['data'] is List
                  ? response['data']
                  : response['data'] is Map
                  ? response['data']['fields']
                  : null) ??
              (response['form'] is Map ? response['form']['fields'] : null)
        : response;
    if (raw is! List || raw.any((v) => v is! Map)) {
      throw const FormatException('Expected API form fields.');
    }
    return raw.map((v) => Map<String, dynamic>.from(v as Map)).toList();
  }

  DynamicFormSchema parse(
    Object? response, {
    required String id,
    Map<String, dynamic> values = const {},
    bool readOnly = false,
  }) {
    final sections = <DynamicFormSectionSchema>[];
    var fields = <DynamicFieldSchema<Object?>>[];
    String? title, description;
    void flush() {
      if (fields.isNotEmpty || title != null) {
        sections.add(
          DynamicFormSectionSchema(
            id: 'section-${sections.length}',
            title: title,
            description: description,
            fields: fields,
          ),
        );
      }
      fields = [];
    }

    for (final raw in fieldsFrom(response)) {
      if (raw['type'] == 'section') {
        flush();
        title = raw['label']?.toString();
        description = raw['description']?.toString();
        if (raw['fields'] is List) {
          for (final child in fieldsFrom(raw['fields'])) {
            fields.add(field(child, values: values, readOnly: readOnly));
          }
        }
        continue;
      }
      fields.add(field(raw, values: values, readOnly: readOnly));
    }
    flush();
    final schema = DynamicFormSchema(id: id, sections: sections);
    schema.validate();
    return schema;
  }

  DynamicFieldSchema<Object?> field(
    Map<String, dynamic> raw, {
    Map<String, dynamic> values = const {},
    bool readOnly = false,
  }) {
    final id = nameOf(raw);
    if (id.trim().isEmpty) {
      throw const FormatException('API field has no name.');
    }
    final wireType = DynamicFieldType.fromWire(raw['type']?.toString());
    final type = wireType == DynamicFieldType.select && flag(raw['multiSelect'])
        ? DynamicFieldType.multiSelect
        : wireType;
    final label = raw['label']?.toString() ?? id.replaceAll('_', ' ');
    Object? value = values.containsKey(id)
        ? values[id]
        : raw['defaultValue'] ?? raw['default_value'] ?? raw['default'];
    final category = RecordUnits.category(raw);
    if (type == DynamicFieldType.unit && num.tryParse('$value') != null) {
      value = RecordUnits.toDisplay(num.parse('$value'), category);
    }
    if (type == DynamicFieldType.checkbox ||
        type == DynamicFieldType.switchField) {
      value = flag(value);
    }
    if (type == DynamicFieldType.date || type == DynamicFieldType.dateTime) {
      value = value is DateTime ? value : DateTime.tryParse('$value');
      if (type == DynamicFieldType.dateTime && value is DateTime) {
        value = value.toLocal();
      }
    }
    if (type == DynamicFieldType.time && value is String) {
      final parts = value.split(':');
      if (parts.length >= 2) {
        final h = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        if (h != null && m != null && h >= 0 && h < 24 && m >= 0 && m < 60) {
          value = TimeOfDay(hour: h, minute: m);
        }
      }
    }
    if (type == DynamicFieldType.json && value != null && value is! String) {
      value = const JsonEncoder.withIndent('  ').convert(value);
    }
    final options = parseOptions(raw['options']);
    final numeric = [
      DynamicFieldType.number,
      DynamicFieldType.decimal,
      DynamicFieldType.unit,
    ].contains(type);
    final min = num.tryParse('${raw['min']}'),
        max = num.tryParse('${raw['max']}');
    num? bound(num? n) => n == null
        ? null
        : type == DynamicFieldType.unit
        ? RecordUnits.toDisplay(n, category)
        : n;
    FormCondition? visibleWhen = raw['_visibleWhen'] is FormCondition
        ? raw['_visibleWhen'] as FormCondition
        : null;
    if (raw['_visibleWhenNotEmpty'] is String) {
      final present = FormCondition.notEmpty(
        raw['_visibleWhenNotEmpty'] as String,
      );
      visibleWhen = visibleWhen == null
          ? present
          : FormCondition.all([visibleWhen, present]);
    }
    if (id == 'bank_name') {
      visibleWhen = FormCondition.equals(fieldId: 'bank', value: 'Other');
    }
    if (id == 'rto_address') {
      visibleWhen = FormCondition.equals(
        fieldId: 'rto_is_same_as_pickup',
        value: false,
      );
    }
    final unsupported =
        type == DynamicFieldType.unknown ||
        type == DynamicFieldType.unsupported;
    return DynamicFieldSchema<Object?>(
      id: id,
      type: unsupported ? DynamicFieldType.unsupported : type,
      label: label,
      placeholder: raw['placeholder']?.toString(),
      helperText: raw['description']?.toString(),
      required: flag(raw['required']),
      visible: !flag(raw['hidden']) && raw['form_view'] != false,
      visibleWhen: visibleWhen,
      access: readOnly || flag(raw['readonly'])
          ? DynamicFieldAccess.readOnly
          : flag(raw['disabled'])
          ? DynamicFieldAccess.disabled
          : DynamicFieldAccess.editable,
      initialValue: value,
      options: options,
      metadata: {
        ...raw,
        'unit_category': category,
        'api_readonly': flag(raw['readonly']),
      },
      maxLines: type == DynamicFieldType.json
          ? 6
          : int.tryParse(
              '${raw['maxLines'] ?? raw['max_rows'] ?? raw['minRows']}',
            ),
      validationRules: [
        if (numeric) RangeRule(min: bound(min), max: bound(max)),
        if (type == DynamicFieldType.number)
          CustomRule(
            (v, _) => v == null || '$v'.isEmpty || int.tryParse('$v') != null
                ? null
                : '$label must be a whole number.',
          ),
        if (!numeric && type != DynamicFieldType.grid) ...[
          if (min != null) MinLengthRule(min.toInt()),
          if (max != null) MaxLengthRule(max.toInt()),
        ],
        if (type == DynamicFieldType.email) EmailRule(),
        if (type == DynamicFieldType.pincode) PatternRule(RegExp(r'^\d{6}$')),
        if (type == DynamicFieldType.select && options.isNotEmpty)
          CustomRule(
            (v, _) =>
                v == null || '$v'.isEmpty || options.any((o) => o.value == v)
                ? null
                : 'Choose an available $label.',
          ),
        if (type == DynamicFieldType.json)
          CustomRule((v, _) {
            if (v == null || '$v'.isEmpty) return null;
            try {
              jsonDecode('$v');
              return null;
            } catch (_) {
              return 'Enter valid JSON.';
            }
          }),
        if (type == DynamicFieldType.grid)
          CustomRule((v, _) => validateGrid(raw, v)),
        if (unsupported && !readOnly && !flag(raw['readonly']))
          CustomRule(
            (_, _) => '$label must be completed in the web workspace.',
          ),
      ],
    );
  }

  static List<FormOption<Object?>> parseOptions(Object? raw) {
    final list = raw is String
        ? raw
              .split(raw.contains('\n') ? '\n' : ',')
              .map((v) => v.trim())
              .where((v) => v.isNotEmpty)
              .toList()
        : raw is List
        ? raw
        : const [];
    final byValue = <Object?, FormOption<Object?>>{};
    for (final item in list) {
      final value = item is Map
          ? item['id'] ?? item['value'] ?? item['label']
          : item;
      if (value == null) continue;
      byValue[value] = FormOption(
        value: value,
        label: item is Map ? '${item['label'] ?? value}' : '$value',
        enabled: item is! Map || !flag(item['disabled']),
      );
    }
    return byValue.values.toList();
  }

  String? validateGrid(Map<String, dynamic> field, Object? value) {
    if (value == null) return null;
    if (value is! List) return 'Expected rows.';
    final min = num.tryParse('${field['min']}'),
        max = num.tryParse('${field['max']}');
    if (min != null && value.length < min) return 'Add at least $min rows.';
    if (max != null && value.length > max) return 'Use at most $max rows.';
    for (final (i, row) in value.indexed) {
      if (row is! Map) return 'Row ${i + 1} is invalid.';
      final controller = DynamicFormController(
        schema: parse(
          field['fields'] ?? [],
          id: 'row',
          values: Map<String, dynamic>.from(row),
        ),
      );
      final valid = controller.validate();
      final errors = controller.schema.fields
          .map((f) => controller.fieldState(f.id).errorText)
          .whereType<String>()
          .toList();
      controller.dispose();
      if (!valid) return 'Row ${i + 1}: ${errors.first}';
    }
    return null;
  }

  Map<String, Object?> serialize(
    DynamicFormSchema schema,
    Map<String, Object?> values,
  ) {
    final result = <String, Object?>{};
    for (final field in schema.fields) {
      if (!field.visible ||
          (field.visibleWhen != null && !field.visibleWhen!.evaluate(values))) {
        continue;
      }
      var value = values[field.id];
      if (value == null && flag(field.metadata['api_readonly'])) continue;
      if (field.type == DynamicFieldType.unsupported) {
        if (value != null) result[field.id] = value;
        continue;
      }
      if (field.type == DynamicFieldType.unit &&
          value != null &&
          '$value'.isNotEmpty) {
        final category = '${field.metadata['unit_category']}';
        value =
            (num.parse('$value') *
                    switch (category) {
                      'currency' => 100,
                      'weight' => 1000,
                      'length' => 10,
                      _ => 1,
                    })
                .round();
      }
      if ([
            DynamicFieldType.number,
            DynamicFieldType.decimal,
          ].contains(field.type) &&
          value != null &&
          '$value'.isNotEmpty) {
        value = num.parse('$value');
      }
      if (value is DateTime) {
        value = field.type == DynamicFieldType.date
            ? '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}'
            : value.toUtc().toIso8601String();
      }
      if (value is TimeOfDay) {
        value =
            '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
      }
      if (field.type == DynamicFieldType.json &&
          value is String &&
          value.isNotEmpty) {
        value = jsonDecode(value);
      }
      // Grid controllers retain raw API row values; row dialogs perform their own conversion.
      result[field.id] = value;
    }
    return result;
  }
}
