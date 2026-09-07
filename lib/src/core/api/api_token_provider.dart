abstract interface class ApiTokenProvider {
  Future<String?> getAccessToken();
}

class StaticApiTokenProvider implements ApiTokenProvider {
  const StaticApiTokenProvider(this.token);

  final String? token;

  @override
  Future<String?> getAccessToken() async => token;
}

class InMemoryApiTokenProvider implements ApiTokenProvider {
  String? _accessToken;
  String? _sessionId;

  @override
  Future<String?> getAccessToken() async => _accessToken;

  void setAccessToken(String? token) {
    _accessToken = token;
  }

  String? get sessionId => _sessionId;

  void setSessionId(String? sessionId) {
    _sessionId = sessionId;
  }

  void clear() {
    _accessToken = null;
    _sessionId = null;
  }
}
