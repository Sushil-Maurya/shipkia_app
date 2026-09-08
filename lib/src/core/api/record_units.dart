/// Storage scales declared by the web object's field metadata.
abstract final class RecordUnits {
  static String category(Map<String, dynamic> field) {
    if (field['type'] != 'unit') return '';
    final display = '${field['display']} ${field['display_value']}'
        .toLowerCase();
    if (RegExp('currency|rupee|inr').hasMatch(display)) return 'currency';
    if (RegExp('weight|kg').hasMatch(display)) return 'weight';
    if (RegExp('dimension|length|cm').hasMatch(display)) return 'length';
    return '';
  }

  static num toDisplay(num value, String category) =>
      value /
      switch (category) {
        'currency' => 100,
        'weight' => 1000,
        'length' => 10,
        _ => 1,
      };
  static Map<String, dynamic> displayCurrencies(
    Map<String, dynamic> record,
    Object? metadata,
  ) {
    final result = Map<String, dynamic>.from(record);
    if (metadata is List) {
      for (final field in metadata.whereType<Map>()) {
        final map = Map<String, dynamic>.from(field);
        final key = map['name'] ?? map['id'];
        final number = num.tryParse('${result[key]}');
        if (category(map) == 'currency' && number != null) {
          result['$key'] = toDisplay(number, 'currency');
        }
      }
    }
    return result;
  }
}
