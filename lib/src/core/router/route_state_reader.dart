import 'package:go_router/go_router.dart';

class RouteStateReader {
  const RouteStateReader(this.state);

  final GoRouterState state;

  String? requiredEntityId(String name) {
    final value = state.pathParameters[name]?.trim();
    if (value == null || value.isEmpty) return null;
    final decoded = Uri.decodeComponent(value);
    if (!RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(decoded)) return null;
    return decoded;
  }

  String? optionalQueryValue(
    String name, {
    Set<String>? allowedValues,
    String? fallback,
  }) {
    final value = state.uri.queryParameters[name]?.trim();
    if (value == null || value.isEmpty) return fallback;
    if (allowedValues != null && !allowedValues.contains(value)) {
      return fallback;
    }
    return value;
  }
}

class OrdersRouteQuery {
  const OrdersRouteQuery({this.stage, this.search});

  final String? stage;
  final String? search;

  factory OrdersRouteQuery.fromState(GoRouterState state) {
    final reader = RouteStateReader(state);
    return OrdersRouteQuery(
      stage: reader.optionalQueryValue(
        'stage',
        allowedValues: const {
          'New',
          'Ready to Ship',
          'Ready to Pickup',
          'In-Transit',
          'Delivered',
          'Cancelled',
          'RTO',
          'All',
        },
      ),
      search: reader.optionalQueryValue('search'),
    );
  }
}
