import 'package:flutter/foundation.dart';

@immutable
class FormOption<T extends Object?> {
  const FormOption({
    required this.label,
    required this.value,
    this.enabled = true,
    this.helperText,
  });

  final String label;
  final T value;
  final bool enabled;
  final String? helperText;
}
