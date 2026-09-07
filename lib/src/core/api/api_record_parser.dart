List<Map<String, dynamic>> extractApiRecords(Object? data) {
  if (data is List) return data.whereType<Map>().map(_jsonMap).toList();
  if (data is! Map) return const <Map<String, dynamic>>[];

  final json = _jsonMap(data);
  for (final key in const [
    'records',
    'rows',
    'data',
    'values',
    'items',
    'list',
    'docs',
    'results',
  ]) {
    final value = json[key];
    if (value is List) return value.whereType<Map>().map(_jsonMap).toList();
    if (value is Map) {
      final nested = extractApiRecords(value);
      if (nested.isNotEmpty) return nested;
    }
  }

  return const <Map<String, dynamic>>[];
}

int? extractApiRecordTotal(Object? data) {
  if (data is! Map) return null;
  final json = _jsonMap(data);
  for (final key in const ['total', 'count', 'recordsTotal', 'totalRecords']) {
    final value = json[key];
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
  }
  for (final key in const ['meta', 'pagination', 'pageInfo', 'data']) {
    final value = json[key];
    if (value is Map) {
      final nested = extractApiRecordTotal(value);
      if (nested != null) return nested;
    }
  }
  return null;
}

Map<String, dynamic> _jsonMap(Map<dynamic, dynamic> value) {
  return Map<String, dynamic>.from(value);
}
