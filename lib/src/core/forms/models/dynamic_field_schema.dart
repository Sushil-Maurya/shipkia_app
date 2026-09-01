import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../conditions/form_condition.dart';
import '../validation/validation_rule.dart';
import 'dynamic_field_access.dart';
import 'dynamic_field_type.dart';
import 'form_option.dart';

@immutable
class DynamicFieldSchema<T extends Object?> {
  const DynamicFieldSchema({
    required this.id,
    required this.type,
    required this.label,
    this.placeholder,
    this.helperText,
    this.required = false,
    this.access = DynamicFieldAccess.editable,
    this.visible = true,
    this.initialValue,
    this.options = const [],
    this.validationRules = const [],
    this.visibleWhen,
    this.enabledWhen,
    this.requiredWhen,
    this.columnSpan = 1,
    this.maxLines,
    this.maxLength,
    this.keyboardType,
    this.inputFormatters,
    this.metadata = const {},
  }) : assert(id.length > 0),
       assert(columnSpan > 0);

  final String id;
  final DynamicFieldType type;
  final String label;
  final String? placeholder;
  final String? helperText;
  final bool required;
  final DynamicFieldAccess access;
  final bool visible;
  final T? initialValue;
  final List<FormOption<Object?>> options;
  final List<ValidationRule> validationRules;
  final FormCondition? visibleWhen;
  final FormCondition? enabledWhen;
  final FormCondition? requiredWhen;
  final int columnSpan;
  final int? maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Map<String, Object?> metadata;

  DynamicFieldSchema<T> copyWith({
    DynamicFieldAccess? access,
    bool? visible,
    T? initialValue,
    String? helperText,
  }) {
    return DynamicFieldSchema<T>(
      id: id,
      type: type,
      label: label,
      placeholder: placeholder,
      helperText: helperText ?? this.helperText,
      required: required,
      access: access ?? this.access,
      visible: visible ?? this.visible,
      initialValue: initialValue ?? this.initialValue,
      options: options,
      validationRules: validationRules,
      visibleWhen: visibleWhen,
      enabledWhen: enabledWhen,
      requiredWhen: requiredWhen,
      columnSpan: columnSpan,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      metadata: metadata,
    );
  }
}
