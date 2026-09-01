import 'package:flutter/foundation.dart';

import 'dynamic_field_schema.dart';

@immutable
class DynamicFormSchema {
  const DynamicFormSchema({
    required this.id,
    required this.sections,
    this.title,
  });

  factory DynamicFormSchema.singleSection({
    required String id,
    required List<DynamicFieldSchema<Object?>> fields,
    String? title,
  }) {
    return DynamicFormSchema(
      id: id,
      title: title,
      sections: [DynamicFormSectionSchema(title: title, fields: fields)],
    );
  }

  final String id;
  final String? title;
  final List<DynamicFormSectionSchema> sections;

  Iterable<DynamicFieldSchema<Object?>> get fields sync* {
    for (final section in sections) {
      yield* section.fields;
    }
  }

  void validate() {
    final seen = <String>{};
    for (final field in fields) {
      if (field.id.trim().isEmpty) {
        throw ArgumentError.value(
          field.id,
          'field.id',
          'Field id is required.',
        );
      }
      if (!seen.add(field.id)) {
        throw ArgumentError.value(
          field.id,
          'field.id',
          'Duplicate field id in form "$id".',
        );
      }
    }
  }
}

@immutable
class DynamicFormSectionSchema {
  const DynamicFormSectionSchema({
    required this.fields,
    this.id,
    this.title,
    this.description,
  });

  final String? id;
  final String? title;
  final String? description;
  final List<DynamicFieldSchema<Object?>> fields;
}
