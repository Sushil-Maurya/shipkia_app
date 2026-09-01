import '../conditions/form_condition.dart';

typedef DynamicValidationMessage = String Function(String label);
typedef CustomValidation = String? Function(
  Object? value,
  DynamicFormValues values,
);

abstract interface class ValidationRule {
  String? validate({
    required Object? value,
    required DynamicFormValues values,
    required String label,
  });
}

class RequiredRule implements ValidationRule {
  const RequiredRule({this.message});

  final DynamicValidationMessage? message;

  @override
  String? validate({
    required Object? value,
    required DynamicFormValues values,
    required String label,
  }) {
    final invalid =
        value == null ||
        (value is String && value.trim().isEmpty) ||
        (value is Iterable<Object?> && value.isEmpty);
    return invalid ? message?.call(label) ?? '$label is required.' : null;
  }
}

class MinLengthRule implements ValidationRule {
  const MinLengthRule(this.length, {this.message});

  final int length;
  final DynamicValidationMessage? message;

  @override
  String? validate({
    required Object? value,
    required DynamicFormValues values,
    required String label,
  }) {
    final text = value?.toString() ?? '';
    if (text.isEmpty || text.length >= length) return null;
    return message?.call(label) ??
        '$label must be at least $length characters.';
  }
}

class MaxLengthRule implements ValidationRule {
  const MaxLengthRule(this.length, {this.message});

  final int length;
  final DynamicValidationMessage? message;

  @override
  String? validate({
    required Object? value,
    required DynamicFormValues values,
    required String label,
  }) {
    final text = value?.toString() ?? '';
    if (text.length <= length) return null;
    return message?.call(label) ?? '$label must be $length characters or less.';
  }
}

class PatternRule implements ValidationRule {
  const PatternRule(this.pattern, {this.message});

  final RegExp pattern;
  final DynamicValidationMessage? message;

  @override
  String? validate({
    required Object? value,
    required DynamicFormValues values,
    required String label,
  }) {
    final text = value?.toString() ?? '';
    if (text.isEmpty || pattern.hasMatch(text)) return null;
    return message?.call(label) ?? 'Please enter a valid $label.';
  }
}

class EmailRule extends PatternRule {
  EmailRule()
    : super(
        RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$'),
        message: (label) => 'Please enter a valid email address.',
      );
}

class PhoneRule extends PatternRule {
  PhoneRule()
    : super(
        RegExp(r'^[6-9]\d{9}$'),
        message: (label) => 'Please enter a valid 10-digit phone number.',
      );
}

class RangeRule implements ValidationRule {
  const RangeRule({this.min, this.max});

  final num? min;
  final num? max;

  @override
  String? validate({
    required Object? value,
    required DynamicFormValues values,
    required String label,
  }) {
    if (value == null || value.toString().trim().isEmpty) return null;
    final number = value is num ? value : num.tryParse(value.toString());
    if (number == null) return '$label must be a number.';
    if (min != null && number < min!) return '$label must be at least $min.';
    if (max != null && number > max!) return '$label must be at most $max.';
    return null;
  }
}

class CustomRule implements ValidationRule {
  const CustomRule(this.validator);

  final CustomValidation validator;

  @override
  String? validate({
    required Object? value,
    required DynamicFormValues values,
    required String label,
  }) => validator(value, values);
}
