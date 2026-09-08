import 'package:go_router/go_router.dart';

class RouteStateReader {
  const RouteStateReader(this.state);

  final GoRouterState state;

  String? requiredEntityId(String name) {
    final value = state.pathParameters[name]?.trim();
    if (value == null || value.isEmpty) return null;
    // go_router has already decoded the path parameter. Backend identities
    // can contain punctuation; the repository encodes them for the API path.
    if (value == '.' ||
        value == '..' ||
        RegExp(r'[\x00-\x1f\x7f]').hasMatch(value)) {
      return null;
    }
    return value;
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
