import 'package:flutter/foundation.dart';

@immutable
class DynamicFormFieldState {
  const DynamicFormFieldState({
    this.value,
    this.errorText,
    this.touched = false,
    this.dirty = false,
    this.loading = false,
  });

  final Object? value;
  final String? errorText;
  final bool touched;
  final bool dirty;
  final bool loading;

  DynamicFormFieldState copyWith({
    Object? value,
    String? errorText,
    bool clearError = false,
    bool? touched,
    bool? dirty,
    bool? loading,
  }) {
    return DynamicFormFieldState(
      value: value ?? this.value,
      errorText: clearError ? null : errorText ?? this.errorText,
      touched: touched ?? this.touched,
      dirty: dirty ?? this.dirty,
      loading: loading ?? this.loading,
    );
  }
}
