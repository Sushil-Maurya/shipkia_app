import 'package:go_router/go_router.dart';

import '../../data/shipkia_mock_data.dart';
import '../../design_system/design_system.dart';
import '../../features/account/account_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/more/more_screen.dart';
import '../../features/ndr/ndr_screen.dart';
import '../../features/orders/order_detail_screen.dart';
import '../../features/orders/orders_screen.dart';
import '../../features/tracking/tracking_screen.dart';
import '../../features/wallet/wallet_screen.dart';
import '../../shell/shipkia_shell.dart';
import '../auth/shipkia_auth_controller.dart';
import 'app_route_names.dart';
import 'app_route_paths.dart';
import 'app_routes.dart';
import 'route_error_screen.dart';
import 'route_guards.dart';
import 'route_state_reader.dart';
import 'route_transitions.dart';

class AppRouter {
  AppRouter({
    required ShipKiaAuthController authController,
    String initialLocation = AppRoutePaths.splash,
  }) : _guards = ShipKiaRouteGuards(authController) {
    router = GoRouter(
      initialLocation: initialLocation,
      refreshListenable: authController,
      redirect: _guards.redirect,
      errorBuilder: (context, state) => const AppRouteErrorScreen.notFound(),
      routes: [
        GoRoute(path: '/', redirect: (context, state) => AppRoutePaths.home),
        GoRoute(
          path: AppRoutePaths.splash,
          name: AppRouteNames.splash,
          pageBuilder: (context, state) => shipKiaPage<void>(
            state: state,
            transition: AppRouteTransitionType.fade,
            child: const AppLoadingScreen(message: 'Loading your workspace.'),
          ),
        ),
        GoRoute(
          path: AppRoutePaths.login,
          name: AppRouteNames.login,
          pageBuilder: (context, state) => shipKiaPage<void>(
            state: state,
            transition: AppRouteTransitionType.fade,
            child: const LoginScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutePaths.signUp,
          name: AppRouteNames.signUp,
          pageBuilder: (context, state) => shipKiaPage<void>(
            state: state,
            transition: AppRouteTransitionType.modal,
            child: const SignUpScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutePaths.forgotPassword,
          name: AppRouteNames.forgotPassword,
          pageBuilder: (context, state) => shipKiaPage<void>(
            state: state,
            transition: AppRouteTransitionType.modal,
            child: const ForgotPasswordScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutePaths.resetPassword,
          name: AppRouteNames.resetPassword,
          pageBuilder: (context, state) => shipKiaPage<void>(
            state: state,
            transition: AppRouteTransitionType.modal,
            child: const UpdatePasswordScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutePaths.registerVerify,
          name: AppRouteNames.registerVerify,
          pageBuilder: (context, state) {
            final email =
                state.uri.queryParameters['email'] ?? 'user@example.com';
            return shipKiaPage<void>(
              state: state,
              transition: AppRouteTransitionType.modal,
              child: RegisterVerifyScreen(email: email),
            );
          },
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return ShipKiaShell(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutePaths.home,
                  name: AppRouteNames.home,
                  pageBuilder: (context, state) => shipKiaPage<void>(
                    state: state,
                    transition: AppRouteTransitionType.none,
                    child: const HomeScreen(),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutePaths.dashboard,
                  name: AppRouteNames.dashboard,
                  pageBuilder: (context, state) => shipKiaPage<void>(
                    state: state,
                    transition: AppRouteTransitionType.none,
                    child: const DashboardScreen(),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutePaths.orders,
                  name: AppRouteNames.orders,
                  pageBuilder: (context, state) => shipKiaPage<void>(
                    state: state,
                    transition: AppRouteTransitionType.none,
                    child: OrdersScreen(
                      query: OrdersRouteQuery.fromState(state),
                    ),
                  ),
                  routes: [_orderDetailsRoute()],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutePaths.ndr,
                  name: AppRouteNames.ndr,
                  pageBuilder: (context, state) => shipKiaPage<void>(
                    state: state,
                    transition: AppRouteTransitionType.none,
                    child: const NdrScreen(),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutePaths.wallet,
                  name: AppRouteNames.wallet,
                  pageBuilder: (context, state) => shipKiaPage<void>(
                    state: state,
                    transition: AppRouteTransitionType.none,
                    child: const WalletScreen(),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutePaths.more,
                  name: AppRouteNames.more,
                  pageBuilder: (context, state) => shipKiaPage<void>(
                    state: state,
                    transition: AppRouteTransitionType.none,
                    child: const MoreScreen(),
                  ),
                  routes: [
                    GoRoute(
                      path: 'tracking',
                      pageBuilder: (context, state) => shipKiaPage<void>(
                        state: state,
                        child: const TrackingScreen(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: AppRoutePaths.tracking,
          name: AppRouteNames.trackingDetails,
          pageBuilder: (context, state) =>
              shipKiaPage<void>(state: state, child: const TrackingScreen()),
          routes: [
            GoRoute(
              path: ':trackingId',
              pageBuilder: (context, state) => shipKiaPage<void>(
                state: state,
                child: const TrackingScreen(),
              ),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutePaths.account,
          name: AppRouteNames.account,
          pageBuilder: (context, state) => shipKiaPage<void>(
            state: state,
            child: AccountScreen(onSignOut: authController.logout),
          ),
        ),
        GoRoute(
          path: AppRoutePaths.notAuthorized,
          name: AppRouteNames.notAuthorized,
          pageBuilder: (context, state) => shipKiaPage<void>(
            state: state,
            transition: AppRouteTransitionType.fade,
            child: const AppRouteErrorScreen.notAuthorized(),
          ),
        ),
        GoRoute(
          path: AppRoutePaths.notFound,
          name: AppRouteNames.notFound,
          pageBuilder: (context, state) => shipKiaPage<void>(
            state: state,
            transition: AppRouteTransitionType.fade,
            child: const AppRouteErrorScreen.notFound(),
          ),
        ),
      ],
    );
  }

  late final GoRouter router;
  final ShipKiaRouteGuards _guards;

  static GoRoute _orderDetailsRoute() {
    return GoRoute(
      path: ':orderId',
      name: AppRouteNames.orderDetails,
      pageBuilder: (context, state) {
        final orderId = RouteStateReader(state).requiredEntityId('orderId');
        final extra = state.extra;
        final order = extra is OrderSummary ? extra : null;

        if (orderId == null) {
          return shipKiaPage<void>(
            state: state,
            child: const AppRouteErrorScreen.notFound(),
          );
        }

        return shipKiaPage<void>(
          state: state,
          child: OrderDetailScreen(orderId: orderId, order: order),
        );
      },
    );
  }
}
