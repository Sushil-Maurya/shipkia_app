class AuthSession {
  const AuthSession({
    required this.session,
    this.permissions = const <String>{},
    this.rawData,
  });

  final String session;
  final Set<String> permissions;
  final Map<String, dynamic>? rawData;

  factory AuthSession.fromJson(dynamic data) {
    if (data is! Map) {
      throw const FormatException('Login response must be a JSON object.');
    }

    final json = Map<String, dynamic>.from(data);
    final source = _payloadJson(json);
    final token = _stringValue(source, const [
      'session',
      'access_token',
      'accessToken',
      'token',
      'authToken',
    ]);

    if (token == null || token.trim().isEmpty) {
      throw const FormatException('Login response did not include a token.');
    }

    return AuthSession(
      session: token,
      permissions: _permissionsFrom(source['permissions']),
      rawData: json,
    );
  }
}

class AuthToken {
  const AuthToken({
    required this.accessToken,
    required this.session,
    this.expiresIn,
    this.rawData,
  });

  final String accessToken;
  final String session;
  final String? expiresIn;
  final Map<String, dynamic>? rawData;

  factory AuthToken.fromJson(dynamic data) {
    if (data is! Map) {
      throw const FormatException(
        'Token renew response must be a JSON object.',
      );
    }

    final json = Map<String, dynamic>.from(data);
    final source = _payloadJson(json);
    final accessToken = _stringValue(source, const ['access_token']);
    final session = _stringValue(source, const ['session']);

    if (accessToken == null || accessToken.trim().isEmpty) {
      throw const FormatException(
        'Token renew response did not include an access token.',
      );
    }
    if (session == null || session.trim().isEmpty) {
      throw const FormatException(
        'Token renew response did not include a session.',
      );
    }

    return AuthToken(
      accessToken: accessToken,
      session: session,
      expiresIn: _stringValue(source, const ['expires_in']),
      rawData: json,
    );
  }
}

class AuthProfile {
  const AuthProfile({
    required this.id,
    required this.email,
    required this.phone,
    required this.type,
    required this.roles,
    this.firstName = '',
    this.lastName = '',
    this.customerId = '',
    this.rawData,
  });

  final String id;
  final String email;
  final String phone;
  final String type;
  final List<String> roles;
  final String firstName;
  final String lastName;
  final String customerId;
  final Map<String, dynamic>? rawData;

  String get name => '$firstName $lastName'.trim();

  factory AuthProfile.fromJson(dynamic data) {
    if (data is! Map) {
      throw const FormatException('Profile response must be a JSON object.');
    }

    final json = Map<String, dynamic>.from(data);
    final source = _payloadJson(json);
    return AuthProfile(
      id: _stringValue(source, const ['id']) ?? '',
      email: _stringValue(source, const ['email']) ?? '',
      phone: _stringValue(source, const ['phone']) ?? '',
      type: _stringValue(source, const ['type']) ?? '',
      firstName: _stringValue(source, const ['first_name', 'firstName']) ?? '',
      lastName: _stringValue(source, const ['last_name', 'lastName']) ?? '',
      customerId:
          _stringValue(source, const ['customer_id', 'customerId']) ?? '',
      roles: _listOfStrings(source['roles']),
      rawData: json,
    );
  }

  static List<String> _listOfStrings(Object? value) {
    if (value is Iterable) return value.whereType<String>().toList();
    return const <String>[];
  }
}

Map<String, dynamic> _payloadJson(Map<String, dynamic> json) {
  final nested = json['result'] ?? json['data'];
  if (nested is Map) return Map<String, dynamic>.from(nested);
  return json;
}

String? _stringValue(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String) return value;
  }
  return null;
}

Set<String> _permissionsFrom(Object? value) {
  if (value is Iterable) {
    return value.whereType<String>().toSet();
  }
  return const <String>{};
}
