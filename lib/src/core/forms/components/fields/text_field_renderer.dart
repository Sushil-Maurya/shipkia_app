import 'api_field_renderers.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../design_system/design_system.dart';
import '../../models/dynamic_field_type.dart';
import '../../registry/field_renderer.dart';

class TextDynamicFieldRenderer implements DynamicFieldRenderer {
  const TextDynamicFieldRenderer();

  @override
  Widget build(DynamicFieldContext context) {
    final field = context.field;
    final type = field.type;
    if (type == DynamicFieldType.text &&
        field.metadata['object_type'] != null &&
        field.metadata['display'] is Map) {
      return const LinkApiFieldRenderer(allowFreeText: true).build(context);
    }
    final rawValue = context.value?.toString();
    final value = type == DynamicFieldType.phone
        ? rawValue?.replaceFirst(RegExp(r'^\+91[- ]?'), '')
        : rawValue;
    final keyboardType = field.keyboardType ?? _keyboardType(type);
    final inputFormatters = field.inputFormatters ?? _formatters(type);

    return Semantics(
      textField: true,
      label: _label(context),
      child: AppTextField(
        key: ValueKey(field.id),
        label: _label(context),
        hintText: field.placeholder,
        prefix: type == DynamicFieldType.phone
            ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('\u{1F1EE}\u{1F1F3}', semanticsLabel: 'India'),
                    SizedBox(width: 6),
                    Text('+91'),
                    SizedBox(width: 8),
                    SizedBox(height: 20, child: VerticalDivider(width: 1)),
                  ],
                ),
              )
            : null,
        helperText: field.helperText,
        suffix: field.type == DynamicFieldType.unit
            ? SizedBox(
                height: 40,
                child: Align(
                  alignment: Alignment.centerRight,
                  widthFactor: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(switch (field.metadata['unit_category']) {
                      'currency' => '\u20b9',
                      'weight' => 'KG',
                      'length' => 'CM',
                      _ => '',
                    }),
                  ),
                ),
              )
            : null,
        errorText: context.errorText,
        initialValue: value,
        enabled: context.access.canFocus,
        readOnly: context.access.isReadOnly,
        obscureText: type == DynamicFieldType.password,
        keyboardType: keyboardType,
        maxLines:
            field.maxLines ??
            ((type == DynamicFieldType.textarea ||
                    type == DynamicFieldType.json)
                ? 4
                : 1),
        maxLength: field.maxLength,
        inputFormatters: inputFormatters,
        textInputAction:
            (type == DynamicFieldType.textarea || type == DynamicFieldType.json)
            ? TextInputAction.newline
            : TextInputAction.next,
        height:
            (type == DynamicFieldType.textarea || type == DynamicFieldType.json)
            ? 104
            : 40,
        onChanged: (value) => context.onChanged(value),
      ),
    );
  }

  String _label(DynamicFieldContext context) {
    return context.isRequired
        ? '${context.field.label} *'
        : context.field.label;
  }

  TextInputType? _keyboardType(DynamicFieldType type) {
    return switch (type) {
      DynamicFieldType.email => TextInputType.emailAddress,
      DynamicFieldType.phone => TextInputType.phone,
      DynamicFieldType.number ||
      DynamicFieldType.quantity ||
      DynamicFieldType.pincode => TextInputType.number,
      DynamicFieldType.decimal || DynamicFieldType.unit =>
        const TextInputType.numberWithOptions(decimal: true),
      DynamicFieldType.textarea ||
      DynamicFieldType.json => TextInputType.multiline,
      _ => null,
    };
  }

  List<TextInputFormatter>? _formatters(DynamicFieldType type) {
    return switch (type) {
      DynamicFieldType.phone ||
      DynamicFieldType.pincode ||
      DynamicFieldType.number ||
      DynamicFieldType.quantity => [FilteringTextInputFormatter.digitsOnly],
      DynamicFieldType.decimal || DynamicFieldType.unit => [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      _ => null,
    };
  }
}

class HiddenDynamicFieldRenderer implements DynamicFieldRenderer {
  const HiddenDynamicFieldRenderer();

  @override
  Widget build(DynamicFieldContext context) => const SizedBox.shrink();
}
