import 'package:flutter/widgets.dart';

import '../models/dynamic_field_access.dart';
import '../models/dynamic_field_schema.dart';
import '../state/dynamic_form_controller.dart';
import '../state/dynamic_form_field_state.dart';

abstract interface class DynamicFieldRenderer {
  Widget build(DynamicFieldContext context);
}

class DynamicFieldContext {
  const DynamicFieldContext({
    required this.buildContext,
    required this.formId,
    required this.field,
    required this.fieldState,
    required this.controller,
    required this.access,
    required this.isRequired,
  });

  final BuildContext buildContext;
  final String formId;
  final DynamicFieldSchema<Object?> field;
  final DynamicFormFieldState fieldState;
  final DynamicFormController controller;
  final DynamicFieldAccess access;
  final bool isRequired;

  Object? get value => fieldState.value;
  String? get errorText => fieldState.errorText;
  bool get canEdit => access.canEdit;

  void onChanged(Object? value) {
    if (canEdit) controller.setValue(field.id, value);
  }
}
