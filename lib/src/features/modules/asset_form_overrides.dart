import 'dart:convert';

import '../../core/forms/forms.dart';

/// React module-specific normalization layered on top of server field metadata.
/// Keep overrides here so shared field renderers remain reusable.
abstract final class AssetFormOverrides {
  static List<Map<String, dynamic>> fields(String? type, Object? response) {
    final source = ApiFormAdapter.fieldsFrom(response);
    final derived = <String>{};
    for (final f in source.where((f) => f['type'] == 'postal_code')) {
      var mapping = f['display'];
      if (mapping is String) {
        try {
          mapping = jsonDecode(mapping);
        } catch (_) {
          mapping = null;
        }
      }
      if (mapping is Map) {
        derived.addAll(mapping.values.map((v) => '$v'));
      } else {
        derived.addAll(['city', 'state', 'country']);
      }
    }
    Map<String, dynamic> normalize(Map<String, dynamic> source) {
      final f = Map<String, dynamic>.from(source);
      final name = ApiFormAdapter.nameOf(f);
      if (f['fields'] is List) {
        f['fields'] = ApiFormAdapter.fieldsFrom(f['fields'])
            .map(normalize)
            .toList();
      }
      if (type == 'bank_accounts') {
        const placeholders = {
          'bank': 'Select bank',
          'account_name': 'Account holder or account label',
          'account_number': 'Enter account number',
          'ifsc_code': 'Enter IFSC code',
        };
        if (placeholders.containsKey(name)) {
          f['placeholder'] = placeholders[name];
        }
      }
      if (type == 'pickup_address') {
        if (name == 'rto_address') f['required'] = true;
        if (derived.contains(name)) f['_visibleWhenNotEmpty'] = name;
        if (name == 'operational_days' && f['type'] == 'grid') {
          final children = ApiFormAdapter.fieldsFrom(f['fields'] ?? []);
          final day = children
              .where((c) => ApiFormAdapter.nameOf(c) == 'day')
              .firstOrNull;
          final options = ApiFormAdapter.parseOptions(day?['options']);
          if (options.isNotEmpty) {
            f['_presentation'] = 'operational_days';
            f['defaultValue'] = [
              for (final option in options) {'day': option.value},
            ];
          }
        }
      }
      return f;
    }

    return source.map(normalize).toList();
  }
}
