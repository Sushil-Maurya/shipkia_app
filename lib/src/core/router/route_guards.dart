import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../auth/shipkia_auth_controller.dart';
import 'app_route_paths.dart';
import 'app_routes.dart';

class ShipKiaRouteGuards {
  const ShipKiaRouteGuards(this.authController);

  final ShipKiaAuthController authController;

  String? redirect(BuildContext context, GoRouterState state) {
    final path = state.uri.path;
    final isPublic = AppRoutes.publicPaths.contains(path);
    final isLogin = path == AppRoutePaths.login;
    final isSplash = path == AppRoutePaths.splash || path == '/';
    final isProtected = _isProtectedPath(path);

    if (authController.isLoading) {
      if (isSplash) return null;
      return _withRedirect(AppRoutePaths.splash, state.uri);
    }

    if (!authController.isAuthenticated) {
      if (isSplash) {
        final redirectTarget = _validatedRedirectTarget(state);
        if (redirectTarget == null) return AppRoutePaths.login;
        return Uri(
          path: AppRoutePaths.login,
          queryParameters: {'redirect': redirectTarget},
        ).toString();
      }

      if (isProtected) {
        return _withRedirect(AppRoutePaths.login, state.uri);
      }
    }

    if (authController.isAuthenticated && (isLogin || isSplash)) {
      return _validatedRedirectTarget(state) ?? AppRoutePaths.home;
    }

    if (authController.isAuthenticated && isProtected) {
      final requiredPermissions = _permissionsFor(path);
      if (!authController.hasPermissions(requiredPermissions)) {
        return AppRoutePaths.notAuthorized;
      }
    }

    if (!isPublic && !isProtected && path != AppRoutePaths.notAuthorized) {
      return null;
    }

    return null;
  }

  bool _isProtectedPath(String path) {
    return AppRoutes.protectedPrefixes.any(
      (prefix) => path == prefix || path.startsWith('$prefix/'),
    );
  }

  Set<String> _permissionsFor(String path) {
    if (path.startsWith('${AppRoutePaths.orders}/')) {
      if (path.endsWith('/edit')) return {ShipKiaPermissions.ordersEdit};
      return {ShipKiaPermissions.ordersView};
    }

    if (path.startsWith('${AppRoutePaths.shipments}/')) {
      return {ShipKiaPermissions.shipmentsView};
    }

    return AppRoutes.routeMeta[path]?.permissions ?? const {};
  }

  String? _validatedRedirectTarget(GoRouterState state) {
    final redirect = state.uri.queryParameters['redirect'];
    if (redirect == null || redirect.isEmpty) return null;
    final decoded = Uri.decodeComponent(redirect);
    if (!decoded.startsWith('/')) return null;
    if (decoded.startsWith('//')) return null;
    final uri = Uri.tryParse(decoded);
    if (uri == null || uri.hasScheme || uri.hasAuthority) return null;
    if (!_isProtectedPath(uri.path)) return null;
    return decoded;
  }

  String _withRedirect(String target, Uri requestedUri) {
    final requested = requestedUri.toString();
    if (requested == '/' || requested == target) return target;
    return Uri(
      path: target,
      queryParameters: {'redirect': requested},
    ).toString();
  }
}
