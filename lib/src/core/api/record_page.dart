/// A server page after the API client has unwrapped the response envelope.
class RecordPage<T> {
  RecordPage({required List<T> records, this.totalRecords, this.totalPages})
    : records = List.unmodifiable(records);

  final List<T> records;
  final int? totalRecords;
  final int? totalPages;

  factory RecordPage.fromJson(
    Object? data,
    T Function(Map<String, dynamic>) parse,
  ) {
    if (data is! Map || data['values'] is! List) {
      throw const FormatException('Expected an object list with values.');
    }
    final values = data['values'] as List;
    final pages = data['pages'];
    return RecordPage(
      records: values.map((value) {
        if (value is! Map) {
          throw const FormatException('Expected an object record.');
        }
        return parse(Map<String, dynamic>.from(value));
      }).toList(),
      totalRecords: pages is Map ? _count(pages['totalRecords']) : null,
      totalPages: pages is Map
          ? _count(pages['totalPages'] ?? pages['totalNoOfPages'])
          : null,
    );
  }

  static int? _count(Object? value) {
    if (value == null) return null;
    final count = int.tryParse(value.toString());
    if (count == null || count < 0) {
      throw const FormatException('Invalid pagination count.');
    }
    return count;
  }
}
