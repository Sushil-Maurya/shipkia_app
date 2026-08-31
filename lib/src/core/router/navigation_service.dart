import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../data/shipkia_mock_data.dart';
import 'app_route_paths.dart';
import 'navigation_intent.dart';

extension AppNavigation on BuildContext {
  void toHome() => go(AppRoutePaths.home);
  void toDashboard() => go(AppRoutePaths.dashboard);
  void toOrders({String? status, String? search, String? sort}) {
    go(_withQuery(AppRoutePaths.orders, {
      if (status != null && status.isNotEmpty) 'status': status,
      if (search != null && search.isNotEmpty) 'search': search,
      if (sort != null && sort.isNotEmpty) 'sort': sort,
    }));
  }

  Future<T?> toOrderDetails<T>(String orderId, {OrderSummary? order}) {
    return push<T>(AppRoutePaths.orderDetails(Uri.encodeComponent(orderId)),
        extra: order);
  }

  Future<T?> toTracking<T>({String? trackingId}) {
    final location = trackingId == null || trackingId.isEmpty
        ? AppRoutePaths.tracking
        : AppRoutePaths.trackingDetails(Uri.encodeComponent(trackingId));
    return push<T>(location);
  }

  Future<T?> toAccount<T>() => push<T>(AppRoutePaths.account);

  void navigateToIntent(NavigationIntent intent) {
    final resolved = NavigationIntentResolver.resolveIntent(intent);
    if (resolved == null) return;
    go(resolved.location, extra: resolved.extra);
  }

  void navigateFromNotification(NotificationNavigationPayload payload) {
    final resolved = NavigationIntentResolver.resolve(payload);
    if (resolved == null) return;
    go(resolved.location, extra: resolved.extra);
  }
}

String _withQuery(String path, Map<String, String> queryParameters) {
  if (queryParameters.isEmpty) return path;
  return Uri(path: path, queryParameters: queryParameters).toString();
}

