class ApiResponse<T> {
  const ApiResponse({
    required this.data,
    required this.statusCode,
    required this.headers,
    this.message,
  });

  final T? data;
  final String? message;
  final int? statusCode;
  final Map<String, List<String>> headers;
}
