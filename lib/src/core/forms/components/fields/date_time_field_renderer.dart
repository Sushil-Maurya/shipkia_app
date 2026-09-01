import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../models/dynamic_field_type.dart';
import '../../registry/field_renderer.dart';

class DateTimeDynamicFieldRenderer implements DynamicFieldRenderer {
  const DateTimeDynamicFieldRenderer();

  @override
  Widget build(DynamicFieldContext context) {
    final field = context.field;
    final display = field.type == DynamicFieldType.time
        ? _formatTime(context.value)
        : _formatDate(context.value);

    return AppTextField(
      label: context.isRequired ? '${field.label} *' : field.label,
      hintText: field.placeholder,
      helperText: field.helperText,
      errorText: context.errorText,
      initialValue: display,
      enabled: context.access.canFocus,
      readOnly: true,
      showReadOnlyBadge: context.access.isReadOnly,
      suffix: IconButton(
        tooltip: field.type == DynamicFieldType.time
            ? 'Pick time'
            : 'Pick date',
        icon: Icon(
          field.type == DynamicFieldType.time
              ? Icons.schedule_outlined
              : Icons.calendar_today_outlined,
          size: 18,
        ),
        onPressed: context.canEdit
            ? () async {
                if (field.type == DynamicFieldType.time) {
                  final current = context.value is TimeOfDay
                      ? context.value! as TimeOfDay
                      : TimeOfDay.now();
                  final result = await showAppTimePicker(
                    context: context.buildContext,
                    initialTime: current,
                  );
                  if (result != null) context.onChanged(result);
                  return;
                }
                final now = DateTime.now();
                final current = context.value is DateTime
                    ? context.value! as DateTime
                    : now;
                final result = await showAppDatePicker(
                  context: context.buildContext,
                  initialDate: current,
                  firstDate: DateTime(now.year - 5),
                  lastDate: DateTime(now.year + 5),
                );
                if (result != null) context.onChanged(result);
              }
            : null,
      ),
    );
  }

  String? _formatDate(Object? value) {
    if (value == null) return null;
    if (value is! DateTime) return value.toString();
    return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
  }

  String? _formatTime(Object? value) {
    if (value == null) return null;
    if (value is! TimeOfDay) return value.toString();
    final hour = value.hourOfPeriod == 0 ? 12 : value.hourOfPeriod;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
