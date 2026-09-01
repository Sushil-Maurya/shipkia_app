enum DynamicFieldType {
  text,
  email,
  phone,
  password,
  number,
  decimal,
  textarea,
  select,
  multiSelect,
  radio,
  checkbox,
  switchField,
  date,
  time,
  pincode,
  address,
  product,
  quantity,
  hidden,
  custom,
  unknown;

  static DynamicFieldType fromWire(String? value) {
    if (value == null) return DynamicFieldType.unknown;
    final normalized = value.trim().replaceAll('-', '_');
    for (final type in DynamicFieldType.values) {
      if (type.name == normalized) return type;
    }
    return switch (normalized) {
      'switch' => DynamicFieldType.switchField,
      'multiselect' || 'multi_select' => DynamicFieldType.multiSelect,
      _ => DynamicFieldType.unknown,
    };
  }
}
