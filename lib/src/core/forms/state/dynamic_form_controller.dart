import 'package:flutter/foundation.dart';

import '../models/dynamic_form_schema.dart';
import '../validation/dynamic_form_validator.dart';
import 'dynamic_form_field_state.dart';

enum DynamicFormSubmissionStatus {
  idle,
  validating,
  submitting,
  success,
  failure,
}

class DynamicFormController extends ChangeNotifier {
  DynamicFormController({
    required this.schema,
    this.validator = const DynamicFormValidator(),
  }) {
    schema.validate();
    for (final field in schema.fields) {
      _fields[field.id] = DynamicFormFieldState(value: field.initialValue);
      _fieldNotifiers[field.id] = ValueNotifier(_fields[field.id]!);
    }
  }

  final DynamicFormSchema schema;
  final DynamicFormValidator validator;
  final Map<String, DynamicFormFieldState> _fields = {};
  final Map<String, ValueNotifier<DynamicFormFieldState>> _fieldNotifiers = {};

  DynamicFormSubmissionStatus submissionStatus =
      DynamicFormSubmissionStatus.idle;
  String? formErrorText;

  bool get isDirty => _fields.values.any((field) => field.dirty);
  bool get isSubmitting =>
      submissionStatus == DynamicFormSubmissionStatus.submitting ||
      submissionStatus == DynamicFormSubmissionStatus.validating;

  Map<String, Object?> get values => {
    for (final entry in _fields.entries) entry.key: entry.value.value,
  };

  T? getValue<T extends Object?>(String fieldId) {
    final value = _fields[fieldId]?.value;
    if (value is T) return value;
    return null;
  }

  DynamicFormFieldState fieldState(String fieldId) =>
      _fields[fieldId] ?? const DynamicFormFieldState();

  ValueListenable<DynamicFormFieldState> listenableFor(String fieldId) {
    return _fieldNotifiers.putIfAbsent(
      fieldId,
      () => ValueNotifier(fieldState(fieldId)),
    );
  }

  void setValue(String fieldId, Object? value, {bool markTouched = true}) {
    final current = fieldState(fieldId);
    if (current.value == value && (!markTouched || current.touched)) return;
    _setFieldState(
      fieldId,
      DynamicFormFieldState(
        value: value,
        touched: markTouched ? true : current.touched,
        dirty: true,
        loading: current.loading,
      ),
    );
    notifyListeners();
  }

  void setFieldError(String fieldId, String? errorText) {
    final current = fieldState(fieldId);
    _setFieldState(
      fieldId,
      DynamicFormFieldState(
        value: current.value,
        errorText: errorText,
        touched: current.touched,
        dirty: current.dirty,
        loading: current.loading,
      ),
    );
  }

  void applyFieldErrors(Map<String, String> errors) {
    for (final entry in errors.entries) {
      if (_fields.containsKey(entry.key)) setFieldError(entry.key, entry.value);
    }
    notifyListeners();
  }

  bool validate() {
    submissionStatus = DynamicFormSubmissionStatus.validating;
    var isValid = true;
    for (final field in schema.fields) {
      final error = validator.validateField(field: field, controller: this);
      setFieldError(field.id, error);
      if (error != null) isValid = false;
    }
    submissionStatus = DynamicFormSubmissionStatus.idle;
    notifyListeners();
    return isValid;
  }

  Future<bool> submit(
    Future<void> Function(Map<String, Object?> values) action,
  ) async {
    if (isSubmitting) return false;
    if (!validate()) return false;
    submissionStatus = DynamicFormSubmissionStatus.submitting;
    formErrorText = null;
    notifyListeners();
    try {
      await action(values);
      submissionStatus = DynamicFormSubmissionStatus.success;
      notifyListeners();
      return true;
    } catch (_) {
      submissionStatus = DynamicFormSubmissionStatus.failure;
      formErrorText = 'Something went wrong. Please try again.';
      notifyListeners();
      return false;
    }
  }

  void reset() {
    for (final field in schema.fields) {
      _setFieldState(
        field.id,
        DynamicFormFieldState(value: field.initialValue),
      );
    }
    formErrorText = null;
    submissionStatus = DynamicFormSubmissionStatus.idle;
    notifyListeners();
  }

  void _setFieldState(String fieldId, DynamicFormFieldState state) {
    _fields[fieldId] = state;
    _fieldNotifiers[fieldId]?.value = state;
  }

  @override
  void dispose() {
    for (final notifier in _fieldNotifiers.values) {
      notifier.dispose();
    }
    super.dispose();
  }
}
