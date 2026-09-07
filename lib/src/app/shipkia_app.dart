import 'package:flutter/material.dart';

import '../core/auth/shipkia_auth_controller.dart';
import '../core/auth/shipkia_auth_scope.dart';
import '../core/api/api.dart';
import '../core/feedback/network_status_controller.dart';
import '../core/feedback/shipkia_feedback.dart';
import '../core/feedback/shipkia_feedback_host.dart';
import '../core/router/app_router.dart';
import '../features/auth/data/auth_repository.dart';
import '../theme/shipkia_theme.dart';
import 'shipkia_theme_controller.dart';

class ShipKiaApp extends StatefulWidget {
  const ShipKiaApp({this.authController, this.networkController, super.key});

  final ShipKiaAuthController? authController;
  final ShipKiaNetworkStatusController? networkController;

  @override
  State<ShipKiaApp> createState() => _ShipKiaAppState();
}

class _ShipKiaAppState extends State<ShipKiaApp> {
  final _themeMode = ValueNotifier(ThemeMode.system);
  late final ShipKiaAuthController _authController;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _authController = widget.authController ?? _createAuthController();
    _appRouter = AppRouter(authController: _authController);
    _authController.restoreSession();
  }

  ShipKiaAuthController _createAuthController() {
    final tokenProvider = InMemoryApiTokenProvider();
    final apiClient = DioApiClient(tokenProvider: tokenProvider);
    return ShipKiaAuthController(
      authRepository: AuthRepository(apiClient),
      tokenProvider: tokenProvider,
    );
  }

  @override
  void dispose() {
    _themeMode.dispose();
    if (widget.authController == null) _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShipKiaAuthScope(
      controller: _authController,
      child: ShipKiaThemeController(
        notifier: _themeMode,
        child: ValueListenableBuilder<ThemeMode>(
          valueListenable: _themeMode,
          builder: (context, themeMode, child) {
            return MaterialApp.router(
              title: 'ShipKia',
              debugShowCheckedModeBanner: false,
              scaffoldMessengerKey: ShipKiaFeedback.messengerKey,
              theme: ShipKiaTheme.light,
              darkTheme: ShipKiaTheme.dark,
              themeMode: themeMode,
              routerConfig: _appRouter.router,
              builder: (context, child) => ShipKiaFeedbackHost(
                networkController: widget.networkController,
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
        ),
      ),
    );
  }
}
