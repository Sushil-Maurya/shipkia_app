import 'package:flutter/material.dart';

class ShipKiaThemeController
    extends InheritedNotifier<ValueNotifier<ThemeMode>> {
  const ShipKiaThemeController({
    required ValueNotifier<ThemeMode> notifier,
    required super.child,
    super.key,
  }) : super(notifier: notifier);

  static ThemeMode modeOf(BuildContext context) {
    final controller = context
        .dependOnInheritedWidgetOfExactType<ShipKiaThemeController>();
    return controller?.notifier?.value ?? ThemeMode.system;
  }

  static void setMode(BuildContext context, ThemeMode mode) {
    final controller = context
        .dependOnInheritedWidgetOfExactType<ShipKiaThemeController>();
    controller?.notifier?.value = mode;
  }
}
