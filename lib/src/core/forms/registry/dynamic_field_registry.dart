import 'package:flutter/widgets.dart';

import '../models/dynamic_field_type.dart';
import 'field_renderer.dart';

class DynamicFieldRegistry {
  DynamicFieldRegistry({DynamicFieldRenderer? fallbackRenderer})
    : _fallbackRenderer = fallbackRenderer ?? const UnknownFieldRenderer();

  final DynamicFieldRenderer _fallbackRenderer;
  final Map<DynamicFieldType, DynamicFieldRenderer> _renderers = {};

  void register(
    DynamicFieldType type,
    DynamicFieldRenderer renderer, {
    bool replace = false,
  }) {
    if (_renderers.containsKey(type) && !replace) {
      throw StateError('Renderer already registered for $type.');
    }
    _renderers[type] = renderer;
  }

  void registerAll(Map<DynamicFieldType, DynamicFieldRenderer> renderers) {
    for (final entry in renderers.entries) {
      register(entry.key, entry.value);
    }
  }

  DynamicFieldRenderer resolve(DynamicFieldType type) =>
      _renderers[type] ?? _fallbackRenderer;
}

class UnknownFieldRenderer implements DynamicFieldRenderer {
  const UnknownFieldRenderer();

  @override
  Widget build(DynamicFieldContext context) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: StateError(
          'No renderer for ${context.field.type} on ${context.field.id}.',
        ),
        library: 'shipkia dynamic forms',
        context: ErrorDescription('resolving a dynamic field renderer'),
      ),
    );

    return Semantics(
      label: '${context.field.label} unavailable',
      child: const Text('This field is currently unavailable.'),
    );
  }
}
