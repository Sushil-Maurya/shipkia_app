import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../../../theme/shipkia_colors.dart';
import '../../models/dynamic_field_type.dart';
import '../../registry/field_renderer.dart';

class OptionsDynamicFieldRenderer implements DynamicFieldRenderer {
  const OptionsDynamicFieldRenderer();

  @override
  Widget build(DynamicFieldContext context) {
    final field = context.field;
    if (field.type == DynamicFieldType.radio) {
      return _FieldFrame(context: context, child: _radioGroup(context));
    }
    if (field.type == DynamicFieldType.multiSelect) {
      return _FieldFrame(context: context, child: _multiSelect(context));
    }
    return _select(context);
  }

  Widget _select(DynamicFieldContext context) {
    final field = context.field;
    final enabled = context.access.canEdit && field.options.isNotEmpty;
    return Builder(
      builder: (buildContext) => DropdownButtonFormField<Object?>(
        initialValue:
            field.options.any((option) => option.value == context.value)
            ? context.value
            : null,
        items: field.options
            .map(
              (option) => DropdownMenuItem<Object?>(
                value: option.value,
                enabled: option.enabled && enabled,
                child: Text(option.label),
              ),
            )
            .toList(),
        onChanged: enabled ? context.onChanged : null,
        decoration: InputDecoration(
          labelText: context.isRequired ? '${field.label} *' : field.label,
          hintText: field.placeholder,
          helperText: field.options.isEmpty
              ? 'No options available.'
              : field.helperText,
          errorText: context.errorText,
          filled: !context.access.canFocus || context.access.isReadOnly,
          fillColor: ShipKiaColors.surfaceMuted(buildContext),
        ),
      ),
    );
  }

  Widget _radioGroup(DynamicFieldContext context) {
    return Column(
      children: [
        for (final option in context.field.options)
          InkWell(
            onTap: context.canEdit && option.enabled
                ? () => context.onChanged(option.value)
                : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  AppRadio<Object?>(
                    value: option.value,
                    groupValue: context.value,
                    onChanged: context.canEdit && option.enabled
                        ? context.onChanged
                        : null,
                  ),
                  const SizedBox(width: 6),
                  Expanded(child: Text(option.label)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _multiSelect(DynamicFieldContext context) {
    final values = context.value is Iterable<Object?>
        ? Set<Object?>.from(context.value as Iterable<Object?>)
        : <Object?>{};
    return Column(
      children: [
        for (final option in context.field.options)
          InkWell(
            onTap: context.canEdit && option.enabled
                ? () {
                    final next = Set<Object?>.from(values);
                    if (!next.add(option.value)) next.remove(option.value);
                    context.onChanged(next.toList(growable: false));
                  }
                : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  AppCheckbox(
                    value: values.contains(option.value),
                    onChanged: context.canEdit && option.enabled
                        ? (_) {
                            final next = Set<Object?>.from(values);
                            if (!next.add(option.value)) {
                              next.remove(option.value);
                            }
                            context.onChanged(next.toList(growable: false));
                          }
                        : null,
                  ),
                  const SizedBox(width: 6),
                  Expanded(child: Text(option.label)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _FieldFrame extends StatelessWidget {
  const _FieldFrame({required this.context, required this.child});

  final DynamicFieldContext context;
  final Widget child;

  @override
  Widget build(BuildContext buildContext) {
    return Semantics(
      label: context.field.label,
      enabled: context.access.canFocus,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.isRequired
                      ? '${context.field.label} *'
                      : context.field.label,
                  style: Theme.of(buildContext).textTheme.labelSmall
                      ?.copyWith(fontSize: 11, letterSpacing: 0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: ShipKiaColors.border(buildContext)),
              borderRadius: ShipKiaRadius.mdBorder,
              color: context.access.isDisabled
                  ? ShipKiaColors.surfaceMuted(buildContext)
                  : ShipKiaColors.surface(buildContext),
            ),
            child: Padding(padding: const EdgeInsets.all(8), child: child),
          ),
          if (context.errorText != null) ...[
            const SizedBox(height: 5),
            Text(
              context.errorText!,
              style: Theme.of(buildContext).textTheme.bodySmall
                  ?.copyWith(color: ShipKiaColors.error),
            ),
          ] else if (context.field.helperText != null) ...[
            const SizedBox(height: 5),
            Text(
              context.field.helperText!,
              style: Theme.of(buildContext).textTheme.bodySmall
                  ?.copyWith(color: ShipKiaColors.textSecondary(buildContext)),
            ),
          ],
        ],
      ),
    );
  }
}
