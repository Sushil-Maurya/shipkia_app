import '../auth/shipkia_auth_controller.dart';
import 'app_route_paths.dart';

enum AppRouteTransitionType { none, fade, slide, modal }

class AppRouteMeta {
  const AppRouteMeta({
    this.requiresAuth = true,
    this.permissions = const {},
    this.transition = AppRouteTransitionType.slide,
  });

  final bool requiresAuth;
  final Set<String> permissions;
  final AppRouteTransitionType transition;
}

abstract final class AppRoutes {
  static const publicPaths = {
    AppRoutePaths.splash,
    AppRoutePaths.login,
    AppRoutePaths.signUp,
    AppRoutePaths.signUpWeb,
    AppRoutePaths.signUpEmbed,
    AppRoutePaths.loginEmbed,
    AppRoutePaths.commit,
    AppRoutePaths.onboardingWelcome,
    AppRoutePaths.forgotPassword,
    AppRoutePaths.resetPassword,
    AppRoutePaths.updatePasswordWeb,
    AppRoutePaths.registerVerify,
  };

  static const protectedPrefixes = {
    AppRoutePaths.home,
    AppRoutePaths.dashboard,
    AppRoutePaths.orders,
    AppRoutePaths.shipments,
    AppRoutePaths.tracking,
    AppRoutePaths.ndr,
    AppRoutePaths.wallet,
    AppRoutePaths.more,
    AppRoutePaths.account,
    AppRoutePaths.help,
    AppRoutePaths.settings,
    AppRoutePaths.tools,
    AppRoutePaths.remittance,
    AppRoutePaths.channels,
    AppRoutePaths.returns,
    AppRoutePaths.pickupAndManifest,
    AppRoutePaths.deliveryAttempt,
    AppRoutePaths.weightDispute,
    AppRoutePaths.weightDisputeDetails,
    AppRoutePaths.walletTransactions,
    AppRoutePaths.wallets,
    AppRoutePaths.supportTicket,
    AppRoutePaths.orderDetailsWeb,
    AppRoutePaths.returnOrderDetails,
    AppRoutePaths.pickupAndManifestDetails,
    AppRoutePaths.scheduledDeliveryAction,
    AppRoutePaths.customers,
    AppRoutePaths.quotations,
    AppRoutePaths.invoice,
  };

  static const routeMeta = <String, AppRouteMeta>{
    AppRoutePaths.orders: AppRouteMeta(
      permissions: {ShipKiaPermissions.ordersView},
    ),
    AppRoutePaths.orderCreate: AppRouteMeta(
      permissions: {ShipKiaPermissions.ordersCreate},
      transition: AppRouteTransitionType.modal,
    ),
    AppRoutePaths.shipments: AppRouteMeta(
      permissions: {ShipKiaPermissions.shipmentsView},
    ),
    AppRoutePaths.tracking: AppRouteMeta(
      permissions: {ShipKiaPermissions.trackingView},
    ),
    AppRoutePaths.wallet: AppRouteMeta(
      permissions: {ShipKiaPermissions.walletView},
    ),
  };
}
