enum DynamicFieldAccess {
  editable,
  readOnly,
  disabled;

  bool get canEdit => this == DynamicFieldAccess.editable;
  bool get canFocus => this != DynamicFieldAccess.disabled;
  bool get isReadOnly => this == DynamicFieldAccess.readOnly;
  bool get isDisabled => this == DynamicFieldAccess.disabled;
}
