import 'app_route_paths.dart';

enum NavigationIntentSource { deepLink, notification, internal }

class NavigationIntent {
  const NavigationIntent({
    required this.source,
    required this.type,
    this.id,
    this.action,
    this.queryParameters = const {},
  });

  final NavigationIntentSource source;
  final String type;
  final String? id;
  final String? action;
  final Map<String, String> queryParameters;
}

class ResolvedRoute {
  const ResolvedRoute(this.location, {this.extra});

  final String location;
  final Object? extra;
}

abstract final class NavigationIntentResolver {
  static ResolvedRoute? resolve(NotificationNavigationPayload payload) {
    return resolveIntent(
      NavigationIntent(
        source: NavigationIntentSource.notification,
        type: payload.type,
        id: payload.id,
        action: payload.action,
        queryParameters: payload.queryParameters,
      ),
    );
  }

  static ResolvedRoute? resolveIntent(NavigationIntent intent) {
    final id = intent.id?.trim();
    return switch (intent.type) {
      'order' when _isValidEntityId(id) =>
        ResolvedRoute(AppRoutePaths.orderDetails(Uri.encodeComponent(id!))),
      'shipment' when _isValidEntityId(id) =>
        ResolvedRoute(AppRoutePaths.shipmentDetails(Uri.encodeComponent(id!))),
      'tracking' when _isValidEntityId(id) =>
        ResolvedRoute(AppRoutePaths.trackingDetails(Uri.encodeComponent(id!))),
      'ndr' when _isValidEntityId(id) =>
        ResolvedRoute(AppRoutePaths.ndrDetails(Uri.encodeComponent(id!))),
      'wallet' => const ResolvedRoute(AppRoutePaths.wallet),
      _ => null,
    };
  }

  static bool _isValidEntityId(String? value) {
    if (value == null || value.isEmpty) return false;
    return RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(value);
  }
}

class NotificationNavigationPayload {
  const NotificationNavigationPayload({
    required this.type,
    this.id,
    this.action,
    this.queryParameters = const {},
  });

  final String type;
  final String? id;
  final String? action;
  final Map<String, String> queryParameters;

  factory NotificationNavigationPayload.fromMap(Map<String, Object?> data) {
    return NotificationNavigationPayload(
      type: data['type']?.toString() ?? '',
      id: data['id']?.toString(),
      action: data['action']?.toString(),
      queryParameters: data['query'] is Map
          ? (data['query'] as Map).map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            )
          : const {},
    );
  }
}

