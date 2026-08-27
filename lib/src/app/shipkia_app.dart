import 'package:flutter/material.dart';

import '../design_system/design_system.dart';
import '../features/auth/login_screen.dart';
import '../theme/shipkia_theme.dart';
import 'shipkia_theme_controller.dart';

class ShipKiaApp extends StatefulWidget {
  const ShipKiaApp({super.key});

  @override
  State<ShipKiaApp> createState() => _ShipKiaAppState();
}

class _ShipKiaAppState extends State<ShipKiaApp> {
  final _themeMode = ValueNotifier(ThemeMode.system);

  @override
  void dispose() {
    _themeMode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShipKiaThemeController(
      notifier: _themeMode,
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: _themeMode,
        builder: (context, themeMode, child) {
          return MaterialApp(
            title: 'ShipKia',
            debugShowCheckedModeBanner: false,
            theme: ShipKiaTheme.light,
            darkTheme: ShipKiaTheme.dark,
            themeMode: themeMode,
            home: child,
          );
        },
        child: const _ShipKiaStartupGate(child: LoginScreen()),
      ),
    );
  }
}

class _ShipKiaStartupGate extends StatefulWidget {
  const _ShipKiaStartupGate({required this.child});

  final Widget child;

  @override
  State<_ShipKiaStartupGate> createState() => _ShipKiaStartupGateState();
}

class _ShipKiaStartupGateState extends State<_ShipKiaStartupGate> {
  var _ready = false;

  @override
  void initState() {
    super.initState();
    _prepareAppContent();
  }

  Future<void> _prepareAppContent() async {
    await Future<void>.delayed(ShipKiaMotion.startup);
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    return AppAnimatedSwitcher(
      duration: ShipKiaMotion.emphasized,
      child: _ready
          ? widget.child
          : const AppLoadingScreen(
              key: ValueKey('shipkia-loading'),
              message: 'Loading your workspace.',
            ),
    );
  }
}
