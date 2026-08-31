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
  const OrdersRouteQuery({
    this.status,
    this.search,
    this.sort = 'latest',
  });

  final String? status;
  final String? search;
  final String sort;

  factory OrdersRouteQuery.fromState(GoRouterState state) {
    final reader = RouteStateReader(state);
    return OrdersRouteQuery(
      status: reader.optionalQueryValue(
        'status',
        allowedValues: const {
          'ready',
          'in-transit',
          'ndr',
          'delivered',
          'cancelled',
        },
      ),
      search: reader.optionalQueryValue('search'),
      sort: reader.optionalQueryValue(
            'sort',
            allowedValues: const {'latest', 'oldest'},
            fallback: 'latest',
          ) ??
          'latest',
    );
  }
}

