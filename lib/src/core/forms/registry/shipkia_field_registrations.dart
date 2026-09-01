import '../models/dynamic_field_type.dart';
import '../components/fields/boolean_field_renderer.dart';
import '../components/fields/date_time_field_renderer.dart';
import '../components/fields/options_field_renderer.dart';
import '../components/fields/text_field_renderer.dart';
import 'dynamic_field_registry.dart';

DynamicFieldRegistry createShipKiaFieldRegistry() {
  final registry = DynamicFieldRegistry();
  registerShipKiaCoreFields(registry);
  registerShipKiaDomainFields(registry);
  return registry;
}

void registerShipKiaCoreFields(DynamicFieldRegistry registry) {
  const text = TextDynamicFieldRenderer();
  const options = OptionsDynamicFieldRenderer();
  const bools = BooleanDynamicFieldRenderer();
  const dates = DateTimeDynamicFieldRenderer();

  registry.registerAll({
    DynamicFieldType.text: text,
    DynamicFieldType.email: text,
    DynamicFieldType.phone: text,
    DynamicFieldType.password: text,
    DynamicFieldType.number: text,
    DynamicFieldType.decimal: text,
    DynamicFieldType.textarea: text,
    DynamicFieldType.select: options,
    DynamicFieldType.multiSelect: options,
    DynamicFieldType.radio: options,
    DynamicFieldType.checkbox: bools,
    DynamicFieldType.switchField: bools,
    DynamicFieldType.date: dates,
    DynamicFieldType.time: dates,
    DynamicFieldType.hidden: const HiddenDynamicFieldRenderer(),
  });
}

void registerShipKiaDomainFields(DynamicFieldRegistry registry) {
  const text = TextDynamicFieldRenderer();
  registry.registerAll({
    DynamicFieldType.pincode: text,
    DynamicFieldType.address: text,
    DynamicFieldType.product: text,
    DynamicFieldType.quantity: text,
  });
}
