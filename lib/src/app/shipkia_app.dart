import 'package:flutter/material.dart';

import '../design_system/design_system.dart';
import '../features/auth/login_screen.dart';
import '../theme/shipkia_theme.dart';

class ShipKiaApp extends StatelessWidget {
  const ShipKiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShipKia',
      debugShowCheckedModeBanner: false,
      theme: ShipKiaTheme.light,
      darkTheme: ShipKiaTheme.dark,
      themeMode: ThemeMode.system,
      home: const _ShipKiaStartupGate(child: LoginScreen()),
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
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: _ready
          ? widget.child
          : const AppLoadingScreen(
              key: ValueKey('shipkia-loading'),
              message: 'Loading your workspace.',
            ),
    );
  }
}
