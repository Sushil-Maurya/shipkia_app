import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../api/api_exception.dart';
import '../api/record_page.dart';

typedef PageLoader<T> = Future<RecordPage<T>> Function(
  int page,
  int pageSize,
  CancelToken token,
);

/// Shared lifecycle for API lists. Query changes replace the loader and cancel
/// earlier work; retries never advance the page until a request succeeds.
class PaginatedController<T> extends ChangeNotifier {
  PaginatedController({required this.recordKey, this.pageSize = 20});

  final int pageSize;
  final String Function(T) recordKey;
  PageLoader<T>? _loader;
  CancelToken? _token;
  int _generation = 0;
  bool _disposed = false;
  List<T> _records = const [];
  List<T> get records => _records;
  int page = 0;
  int? totalRecords;
  bool loading = false;
  bool loadingMore = false;
  bool hasMore = false;
  ApiException? error;
  bool _failedAppend = false;

  Future<void> setQuery(PageLoader<T> loader) {
    _loader = loader;
    _records = const [];
    page = 0;
    totalRecords = null;
    hasMore = false;
    return _fetch(append: false);
  }

  Future<void> refresh() => _fetch(append: false);
  Future<void> retry() => _fetch(append: _failedAppend);
  Future<void> loadMore() async {
    if (!hasMore || loading || loadingMore) return;
    await _fetch(append: true);
  }

  Future<void> _fetch({required bool append}) async {
    final loader = _loader;
    if (_disposed || loader == null) return;
    final generation = ++_generation;
    _token?.cancel();
    final token = _token = CancelToken();
    final requestedPage = append ? page + 1 : 1;
    loading = !append;
    loadingMore = append;
    error = null;
    notifyListeners();
    try {
      final result = await loader(requestedPage, pageSize, token);
      if (_disposed || generation != _generation) return;
      final byId = <String, T>{
        if (append)
          for (final record in _records) recordKey(record): record,
        for (final record in result.records) recordKey(record): record,
      };
      _records = List.unmodifiable(byId.values);
      page = requestedPage;
      totalRecords = result.totalRecords;
      hasMore =
          result.records.isNotEmpty &&
          (result.totalPages != null
              ? page < result.totalPages!
              : totalRecords != null
              ? page * pageSize < totalRecords!
              : result.records.length == pageSize);
    } on Object catch (failure) {
      if (_disposed || generation != _generation || token.isCancelled) return;
      error = ApiExceptionMapper.unknown(failure);
      _failedAppend = append;
    } finally {
      if (!_disposed && generation == _generation) {
        loading = false;
        loadingMore = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    _token?.cancel();
    super.dispose();
  }
}
