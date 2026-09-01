import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';
import '../../../theme/shipkia_colors.dart';
import '../models/dynamic_form_schema.dart';
import '../registry/dynamic_field_registry.dart';
import '../registry/shipkia_field_registrations.dart';
import '../state/dynamic_form_controller.dart';
import 'dynamic_form_field.dart';

class DynamicFormBuilder extends StatefulWidget {
  DynamicFormBuilder({
    required this.schema,
    required this.controller,
    DynamicFieldRegistry? registry,
    this.padding = EdgeInsets.zero,
    this.spacing = ShipKiaSpacing.md,
    this.maxColumns = 2,
    super.key,
  }) : registry = registry ?? _defaultRegistry;

  static final DynamicFieldRegistry _defaultRegistry =
      createShipKiaFieldRegistry();

  final DynamicFormSchema schema;
  final DynamicFormController controller;
  final DynamicFieldRegistry registry;
  final EdgeInsetsGeometry padding;
  final double spacing;
  final int maxColumns;

  @override
  State<DynamicFormBuilder> createState() => DynamicFormBuilderState();
}

class DynamicFormBuilderState extends State<DynamicFormBuilder> {
  final Map<String, GlobalKey> _fieldKeys = {};

  bool validateAndFocusFirstError() {
    final valid = widget.controller.validate();
    if (!valid) _focusFirstError();
    return valid;
  }

  void _focusFirstError() {
    for (final field in widget.schema.fields) {
      if (widget.controller.fieldState(field.id).errorText == null) continue;
      final context = _fieldKeys[field.id]?.currentContext;
      if (context == null) continue;
      Scrollable.ensureVisible(
        context,
        duration: ShipKiaMotion.normal,
        curve: ShipKiaMotion.standard,
        alignment: 0.2,
      );
      FocusScope.of(context).requestFocus(FocusNode());
      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FormErrorBanner(
            controller: widget.controller,
            spacing: widget.spacing,
          ),
          for (final section in widget.schema.sections) ...[
            _FormSection(
              schemaId: widget.schema.id,
              section: section,
              controller: widget.controller,
              registry: widget.registry,
              spacing: widget.spacing,
              maxColumns: widget.maxColumns,
              fieldKeys: _fieldKeys,
            ),
            SizedBox(height: widget.spacing),
          ],
        ],
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.schemaId,
    required this.section,
    required this.controller,
    required this.registry,
    required this.spacing,
    required this.maxColumns,
    required this.fieldKeys,
  });

  final String schemaId;
  final DynamicFormSectionSchema section;
  final DynamicFormController controller;
  final DynamicFieldRegistry registry;
  final double spacing;
  final int maxColumns;
  final Map<String, GlobalKey> fieldKeys;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (section.title != null) ...[
          Text(section.title!, style: Theme.of(context).textTheme.titleLarge),
          if (section.description != null) ...[
            const SizedBox(height: ShipKiaSpacing.xs),
            Text(
              section.description!,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: ShipKiaColors.textSecondary(context)),
            ),
          ],
          SizedBox(height: spacing),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= ShipKiaBreakpoints.medium
                ? maxColumns.clamp(1, 4).toInt()
                : 1;
            final gapCount = columns - 1;
            final width =
                (constraints.maxWidth - (spacing * gapCount)) / columns;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final field in section.fields)
                  SizedBox(
                    key: fieldKeys.putIfAbsent(field.id, GlobalKey.new),
                    width: columns == 1
                        ? constraints.maxWidth
                        : (((width * field.columnSpan) +
                                  (spacing * (field.columnSpan - 1)))
                              .clamp(width, constraints.maxWidth)
                              .toDouble()),
                    child: DynamicFormField(
                      formId: schemaId,
                      field: field,
                      controller: controller,
                      registry: registry,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _FormErrorBanner extends StatelessWidget {
  const _FormErrorBanner({required this.controller, required this.spacing});

  final DynamicFormController controller;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final message = controller.formErrorText;
        if (message == null) return const SizedBox.shrink();
        return Padding(
          padding: EdgeInsets.only(bottom: spacing),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: ShipKiaColors.error.withValues(alpha: 0.08),
              border: Border.all(
                color: ShipKiaColors.error.withValues(alpha: 0.22),
              ),
              borderRadius: ShipKiaRadius.mdBorder,
            ),
            child: Padding(
              padding: const EdgeInsets.all(ShipKiaSpacing.md),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: ShipKiaColors.error,
                    size: 18,
                  ),
                  const SizedBox(width: ShipKiaSpacing.sm),
                  Expanded(child: Text(message)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
