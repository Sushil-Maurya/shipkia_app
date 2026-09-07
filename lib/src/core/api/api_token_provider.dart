import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class ApiTokenProvider {
  Future<String?> getAccessToken();

  Future<void> saveAccessToken(String token);

  Future<void> clearAccessToken();

  Future<String?> getSessionId();

  Future<void> saveSessionId(String sessionId);

  Future<String?> getRefreshToken();

  Future<void> saveRefreshToken(String refreshToken);

  Future<void> clearRefreshToken();

  Future<void> clear();
}

class StaticApiTokenProvider implements ApiTokenProvider {
  const StaticApiTokenProvider(this.token);

  final String? token;

  @override
  Future<String?> getAccessToken() async => token;

  @override
  Future<void> saveAccessToken(String token) async {}

  @override
  Future<void> clearAccessToken() async {}

  @override
  Future<String?> getSessionId() async => null;

  @override
  Future<void> saveSessionId(String sessionId) async {}

  @override
  Future<String?> getRefreshToken() async => null;

  @override
  Future<void> saveRefreshToken(String refreshToken) async {}

  @override
  Future<void> clearRefreshToken() async {}

  @override
  Future<void> clear() async {}
}

class InMemoryApiTokenProvider implements ApiTokenProvider {
  String? _accessToken;
  String? _sessionId;

  @override
  Future<String?> getAccessToken() async => _accessToken;

  void setAccessToken(String? token) {
    _accessToken = token;
  }

  @override
  Future<void> saveAccessToken(String token) async {
    _accessToken = token;
  }

  @override
  Future<void> clearAccessToken() async {
    _accessToken = null;
  }

  String? get sessionId => _sessionId;

  void setSessionId(String? sessionId) {
    _sessionId = sessionId;
  }

  @override
  Future<String?> getSessionId() async => _sessionId;

  @override
  Future<void> saveSessionId(String sessionId) async {
    _sessionId = sessionId;
  }

  String? _refreshToken;

  @override
  Future<String?> getRefreshToken() async => _refreshToken;

  @override
  Future<void> saveRefreshToken(String refreshToken) async {
    _refreshToken = refreshToken;
  }

  @override
  Future<void> clearRefreshToken() async {
    _refreshToken = null;
  }

  @override
  Future<void> clear() async {
    _accessToken = null;
    _sessionId = null;
    _refreshToken = null;
  }
}

class SecureApiTokenProvider implements ApiTokenProvider {
  const SecureApiTokenProvider({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : this._(storage);

  const SecureApiTokenProvider._(this._storage);

  static const _accessTokenKey = 'shipkia.access_token';
  static const _sessionIdKey = 'shipkia.session_id';
  static const _refreshTokenKey = 'shipkia.refresh_token';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> getAccessToken() {
    return _storage.read(key: _accessTokenKey);
  }

  @override
  Future<void> saveAccessToken(String token) {
    return _storage.write(key: _accessTokenKey, value: token);
  }

  @override
  Future<void> clearAccessToken() {
    return _storage.delete(key: _accessTokenKey);
  }

  @override
  Future<String?> getSessionId() {
    return _storage.read(key: _sessionIdKey);
  }

  @override
  Future<void> saveSessionId(String sessionId) {
    return _storage.write(key: _sessionIdKey, value: sessionId);
  }

  @override
  Future<String?> getRefreshToken() {
    return _storage.read(key: _refreshTokenKey);
  }

  @override
  Future<void> saveRefreshToken(String refreshToken) {
    return _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  @override
  Future<void> clearRefreshToken() {
    return _storage.delete(key: _refreshTokenKey);
  }

  @override
  Future<void> clear() async {
    await Future.wait([
      clearAccessToken(),
      _storage.delete(key: _sessionIdKey),
      clearRefreshToken(),
    ]);
  }
}
