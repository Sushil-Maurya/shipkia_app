import 'package:flutter/material.dart';

import '../conditions/form_condition.dart';
import '../models/dynamic_field_access.dart';
import '../models/dynamic_field_schema.dart';
import '../registry/dynamic_field_registry.dart';
import '../registry/field_renderer.dart';
import '../state/dynamic_form_controller.dart';
import '../state/dynamic_form_field_state.dart';

class DynamicFormField extends StatelessWidget {
  const DynamicFormField({
    required this.formId,
    required this.field,
    required this.controller,
    required this.registry,
    super.key,
  });

  final String formId;
  final DynamicFieldSchema<Object?> field;
  final DynamicFormController controller;
  final DynamicFieldRegistry registry;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (!field.visible || !field.visibleWhen.matches(controller)) {
          return const SizedBox.shrink();
        }

        return ValueListenableBuilder<DynamicFormFieldState>(
          valueListenable: controller.listenableFor(field.id),
          builder: (context, fieldState, _) {
            final access = _effectiveAccess();
            final rendererContext = DynamicFieldContext(
              buildContext: context,
              formId: formId,
              field: field,
              fieldState: fieldState,
              controller: controller,
              access: access,
              isRequired:
                  field.required ||
                  (field.requiredWhen != null &&
                      field.requiredWhen.matches(controller)),
            );
            Widget child;
            try {
              child = registry.resolve(field.type).build(rendererContext);
            } catch (error, stackTrace) {
              FlutterError.reportError(
                FlutterErrorDetails(
                  exception: error,
                  stack: stackTrace,
                  library: 'shipkia dynamic forms',
                  context: ErrorDescription('building field ${field.id}'),
                ),
              );
              child = Text(
                'This field could not be loaded.',
                style: Theme.of(context).textTheme.bodySmall,
              );
            }

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 140),
              child: KeyedSubtree(
                key: ValueKey('${field.id}-${access.name}'),
                child: child,
              ),
            );
          },
        );
      },
    );
  }

  DynamicFieldAccess _effectiveAccess() {
    if (field.access == DynamicFieldAccess.disabled) {
      return DynamicFieldAccess.disabled;
    }
    if (!field.enabledWhen.matches(controller)) {
      return DynamicFieldAccess.disabled;
    }
    return field.access;
  }
}
