enum NetworkEnvironment { development, staging, production }

class NetworkConfig {
  const NetworkConfig({
    required this.baseUrl,
    this.apiPrefix = '',
    this.timeout = const Duration(seconds: 30),
    this.environment = NetworkEnvironment.development,
  });

  final String baseUrl;
  final String apiPrefix;
  final Duration timeout;
  final NetworkEnvironment environment;

  static const development = NetworkConfig(
    baseUrl: 'http://api.shipkia.lcl',
    timeout: Duration(milliseconds: 30000),
  );

  static const staging = NetworkConfig(
    baseUrl: 'https://staging-api.shipkia.com',
    timeout: Duration(milliseconds: 30000),
    environment: NetworkEnvironment.staging,
  );

  static const production = NetworkConfig(
    baseUrl: 'https://api.shipkia.com',
    timeout: Duration(milliseconds: 30000),
    environment: NetworkEnvironment.production,
  );

  String get resolvedBaseUrl {
    final cleanBaseUrl = _withoutTrailingSlash(baseUrl);
    final cleanPrefix = _normalizedPrefix(apiPrefix);
    return '$cleanBaseUrl$cleanPrefix';
  }

  static String _withoutTrailingSlash(String value) {
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }

  static String _normalizedPrefix(String value) {
    if (value.isEmpty || value == '/') return '';
    final withLeadingSlash = value.startsWith('/') ? value : '/$value';
    return withLeadingSlash.endsWith('/')
        ? withLeadingSlash.substring(0, withLeadingSlash.length - 1)
        : withLeadingSlash;
  }
}
