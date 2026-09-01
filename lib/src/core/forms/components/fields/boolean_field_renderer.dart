import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../../../theme/shipkia_colors.dart';
import '../../models/dynamic_field_type.dart';
import '../../registry/field_renderer.dart';

class BooleanDynamicFieldRenderer implements DynamicFieldRenderer {
  const BooleanDynamicFieldRenderer();

  @override
  Widget build(DynamicFieldContext context) {
    final field = context.field;
    final value = context.value == true;
    final onChanged = context.canEdit
        ? (bool? v) => context.onChanged(v)
        : null;

    return Builder(
      builder: (buildContext) => Semantics(
        label: field.label,
        toggled: value,
        enabled: context.access.canFocus,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: ShipKiaColors.border(buildContext)),
            borderRadius: ShipKiaRadius.mdBorder,
            color: context.access.isDisabled
                ? ShipKiaColors.surfaceMuted(buildContext)
                : ShipKiaColors.surface(buildContext),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                if (field.type == DynamicFieldType.switchField)
                  AppSwitch(
                    value: value,
                    onChanged: context.canEdit
                        ? (value) => context.onChanged(value)
                        : null,
                  )
                else
                  AppCheckbox(value: value, onChanged: onChanged),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.isRequired ? '${field.label} *' : field.label,
                    style: Theme.of(buildContext).textTheme.bodyMedium,
                  ),
                ),
                if (context.access.isReadOnly)
                  Text(
                    'Read only',
                    style: Theme.of(buildContext).textTheme.bodySmall?.copyWith(
                      color: ShipKiaColors.textSecondary(buildContext),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
