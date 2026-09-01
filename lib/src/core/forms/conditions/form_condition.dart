import '../state/dynamic_form_controller.dart';

typedef DynamicFormValues = Map<String, Object?>;

abstract interface class FormCondition {
  bool evaluate(DynamicFormValues values);

  factory FormCondition.equals({
    required String fieldId,
    required Object? value,
  }) = EqualsFieldCondition;

  factory FormCondition.notEmpty(String fieldId) = NotEmptyFieldCondition;

  factory FormCondition.all(List<FormCondition> conditions) = AllFormCondition;

  factory FormCondition.any(List<FormCondition> conditions) = AnyFormCondition;
}

class EqualsFieldCondition implements FormCondition {
  const EqualsFieldCondition({required this.fieldId, required this.value});

  final String fieldId;
  final Object? value;

  @override
  bool evaluate(DynamicFormValues values) => values[fieldId] == value;
}

class NotEmptyFieldCondition implements FormCondition {
  const NotEmptyFieldCondition(this.fieldId);

  final String fieldId;

  @override
  bool evaluate(DynamicFormValues values) {
    final value = values[fieldId];
    if (value == null) return false;
    if (value is String) return value.trim().isNotEmpty;
    if (value is Iterable<Object?>) return value.isNotEmpty;
    return true;
  }
}

class AllFormCondition implements FormCondition {
  const AllFormCondition(this.conditions);

  final List<FormCondition> conditions;

  @override
  bool evaluate(DynamicFormValues values) =>
      conditions.every((condition) => condition.evaluate(values));
}

class AnyFormCondition implements FormCondition {
  const AnyFormCondition(this.conditions);

  final List<FormCondition> conditions;

  @override
  bool evaluate(DynamicFormValues values) =>
      conditions.any((condition) => condition.evaluate(values));
}

extension FormConditionControllerX on FormCondition? {
  bool matches(DynamicFormController controller) {
    final condition = this;
    return condition == null || condition.evaluate(controller.values);
  }
}
