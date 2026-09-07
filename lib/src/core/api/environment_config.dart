import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'network_config.dart';

class EnvironmentConfigException implements Exception {
  const EnvironmentConfigException(this.message);

  final String message;

  @override
  String toString() => 'EnvironmentConfigException: $message';
}

abstract final class EnvironmentConfig {
  static const defaultEnvironmentName = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );
  static const _apiBaseUrlOverride = String.fromEnvironment('API_BASE_URL');
  static const _apiTimeoutOverride = String.fromEnvironment('API_TIMEOUT');
  static const _apiPrefixOverride = String.fromEnvironment('API_PREFIX');

  static bool _isLoaded = false;
  static late NetworkEnvironment _environment;
  static late String _apiBaseUrl;
  static late String _apiPrefix;
  static late Duration _apiTimeout;

  static bool get isLoaded => _isLoaded;

  static NetworkEnvironment get environment {
    _ensureLoaded();
    return _environment;
  }

  static String get appEnv => environment.name;

  static String get apiBaseUrl {
    _ensureLoaded();
    return _apiBaseUrl;
  }

  static String get apiPrefix {
    _ensureLoaded();
    return _apiPrefix;
  }

  static Duration get apiTimeout {
    _ensureLoaded();
    return _apiTimeout;
  }

  static NetworkConfig get networkConfig {
    _ensureLoaded();
    return NetworkConfig(
      baseUrl: _apiBaseUrl,
      apiPrefix: _apiPrefix,
      timeout: _apiTimeout,
      environment: _environment,
    );
  }

  static Future<void> load({
    String environment = defaultEnvironmentName,
  }) async {
    final selectedEnvironment = _parseEnvironment(environment);
    await dotenv.load(
      fileName: '.env',
      overrideWithFiles: ['.env.${selectedEnvironment.name}'],
      mergeWith: {
        'APP_ENV': selectedEnvironment.name,
        if (_apiBaseUrlOverride.isNotEmpty) 'API_BASE_URL': _apiBaseUrlOverride,
        if (_apiTimeoutOverride.isNotEmpty) 'API_TIMEOUT': _apiTimeoutOverride,
        if (_apiPrefixOverride.isNotEmpty) 'API_PREFIX': _apiPrefixOverride,
      },
    );
    _apply(dotenv.env);
  }

  static void loadFromString(String value) {
    dotenv.loadFromString(envString: value);
    _apply(dotenv.env);
  }

  static void resetForTesting() {
    dotenv.clean();
    _isLoaded = false;
  }

  static void _apply(Map<String, String> values) {
    final environment = _parseEnvironment(_required(values, 'APP_ENV'));
    final apiBaseUrl = _validatedUrl(_required(values, 'API_BASE_URL'));
    final apiTimeout = _validatedTimeout(_required(values, 'API_TIMEOUT'));
    final apiPrefix = values['API_PREFIX']?.trim() ?? '';

    _environment = environment;
    _apiBaseUrl = apiBaseUrl;
    _apiTimeout = apiTimeout;
    _apiPrefix = apiPrefix;
    _isLoaded = true;
  }

  static String _required(Map<String, String> values, String key) {
    final value = values[key]?.trim();
    if (value == null || value.isEmpty) {
      throw EnvironmentConfigException('Missing required env variable: $key');
    }
    return value;
  }

  static NetworkEnvironment _parseEnvironment(String value) {
    return switch (value.trim().toLowerCase()) {
      'development' || 'dev' => NetworkEnvironment.development,
      'staging' || 'stage' => NetworkEnvironment.staging,
      'production' || 'prod' => NetworkEnvironment.production,
      _ => throw EnvironmentConfigException(
        'APP_ENV must be one of: development, staging, production',
      ),
    };
  }

  static String _validatedUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null ||
        !uri.hasScheme ||
        uri.host.isEmpty ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      throw const EnvironmentConfigException(
        'API_BASE_URL must be a valid http or https URL',
      );
    }
    return _withoutTrailingSlash(value);
  }

  static Duration _validatedTimeout(String value) {
    final milliseconds = int.tryParse(value);
    if (milliseconds == null || milliseconds <= 0) {
      throw const EnvironmentConfigException(
        'API_TIMEOUT must be a positive integer in milliseconds',
      );
    }
    return Duration(milliseconds: milliseconds);
  }

  static String _withoutTrailingSlash(String value) {
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }

  static void _ensureLoaded() {
    if (!_isLoaded) {
      throw const EnvironmentConfigException(
        'EnvironmentConfig.load() must complete before reading configuration',
      );
    }
  }
}
