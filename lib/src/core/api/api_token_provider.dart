abstract interface class ApiTokenProvider {
  Future<String?> getAccessToken();
}

class StaticApiTokenProvider implements ApiTokenProvider {
  const StaticApiTokenProvider(this.token);

  final String? token;

  @override
  Future<String?> getAccessToken() async => token;
}
