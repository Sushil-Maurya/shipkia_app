import 'package:flutter_test/flutter_test.dart';
import 'package:shipkia_app/src/core/api/api.dart';

void main() {
  tearDown(EnvironmentConfig.resetForTesting);

  test('loads strongly typed environment values from dotenv content', () {
    EnvironmentConfig.loadFromString('''
APP_ENV=development
API_BASE_URL=http://api.shipkia.lcl/
API_TIMEOUT=45000
API_PREFIX=/api/v1/
''');

    expect(EnvironmentConfig.appEnv, 'development');
    expect(EnvironmentConfig.apiBaseUrl, 'http://api.shipkia.lcl');
    expect(EnvironmentConfig.apiTimeout, const Duration(milliseconds: 45000));
    expect(EnvironmentConfig.apiPrefix, '/api/v1/');
    expect(
      EnvironmentConfig.networkConfig.resolvedBaseUrl,
      'http://api.shipkia.lcl/api/v1',
    );
  });

  test('fails before environment config has loaded', () {
    expect(
      () => EnvironmentConfig.apiBaseUrl,
      throwsA(isA<EnvironmentConfigException>()),
    );
  });

  test('fails when required environment values are missing', () {
    expect(
      () => EnvironmentConfig.loadFromString('''
APP_ENV=development
API_TIMEOUT=30000
'''),
      throwsA(
        isA<EnvironmentConfigException>().having(
          (error) => error.message,
          'message',
          contains('API_BASE_URL'),
        ),
      ),
    );
  });

  test('fails when the API base URL is invalid', () {
    expect(
      () => EnvironmentConfig.loadFromString('''
APP_ENV=development
API_BASE_URL=not-a-url
API_TIMEOUT=30000
'''),
      throwsA(
        isA<EnvironmentConfigException>().having(
          (error) => error.message,
          'message',
          contains('valid http or https URL'),
        ),
      ),
    );
  });

  test('fails when timeout is not a positive integer', () {
    expect(
      () => EnvironmentConfig.loadFromString('''
APP_ENV=development
API_BASE_URL=http://api.shipkia.lcl
API_TIMEOUT=0
'''),
      throwsA(
        isA<EnvironmentConfigException>().having(
          (error) => error.message,
          'message',
          contains('positive integer'),
        ),
      ),
    );
  });

  test('fails when environment name is unsupported', () {
    expect(
      () => EnvironmentConfig.loadFromString('''
APP_ENV=qa
API_BASE_URL=http://api.shipkia.lcl
API_TIMEOUT=30000
'''),
      throwsA(
        isA<EnvironmentConfigException>().having(
          (error) => error.message,
          'message',
          contains('development, staging, production'),
        ),
      ),
    );
  });

  test('supports staging and production environments', () {
    EnvironmentConfig.loadFromString('''
APP_ENV=staging
API_BASE_URL=https://staging-api.shipkia.com
API_TIMEOUT=30000
''');
    expect(EnvironmentConfig.environment, NetworkEnvironment.staging);

    EnvironmentConfig.resetForTesting();
    EnvironmentConfig.loadFromString('''
APP_ENV=production
API_BASE_URL=https://api.shipkia.com
API_TIMEOUT=30000
''');
    expect(EnvironmentConfig.environment, NetworkEnvironment.production);
  });
}
