import '../conditions/form_condition.dart';
import '../models/dynamic_field_access.dart';
import '../models/dynamic_field_schema.dart';
import '../state/dynamic_form_controller.dart';
import 'validation_rule.dart';

class DynamicFormValidator {
  const DynamicFormValidator();

  String? validateField({
    required DynamicFieldSchema<Object?> field,
    required DynamicFormController controller,
  }) {
    if (!field.visible || !field.visibleWhen.matches(controller)) return null;
    if (field.access == DynamicFieldAccess.disabled) return null;

    final rules = <ValidationRule>[
      if (field.required ||
          (field.requiredWhen != null &&
              field.requiredWhen.matches(controller)))
        const RequiredRule(),
      ...field.validationRules,
    ];
    for (final rule in rules) {
      final error = rule.validate(
        value: controller.getValue<Object?>(field.id),
        values: controller.values,
        label: field.label,
      );
      if (error != null) return error;
    }
    return null;
  }
}
