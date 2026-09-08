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
  unit,
  link,
  grid,
  dateTime,
  json,
  unsupported,
  unknown;

  static DynamicFieldType fromWire(String? value) {
    if (value == null) return DynamicFieldType.unknown;
    final normalized = value.trim().replaceAll('-', '_');
    for (final type in DynamicFieldType.values) {
      if (type.name == normalized) return type;
    }
    return switch (normalized) {
      'int' || 'integer' => DynamicFieldType.number,
      'float' => DynamicFieldType.decimal,
      'option' || 'autocomplete' => DynamicFieldType.select,
      'bool' || 'boolean' => DynamicFieldType.checkbox,
      'postal_code' => DynamicFieldType.pincode,
      'datetime' => DynamicFieldType.dateTime,
      'editableGrid' => DynamicFieldType.grid,
      'uid' => DynamicFieldType.text,
      'attachment' ||
      'supportAttachment' ||
      'imageUploader' ||
      'apikey' ||
      'conditionalFieldGroup' => DynamicFieldType.unsupported,
      'switch' => DynamicFieldType.switchField,
      'multiselect' || 'multi_select' => DynamicFieldType.multiSelect,
      _ => DynamicFieldType.unknown,
    };
  }
}
