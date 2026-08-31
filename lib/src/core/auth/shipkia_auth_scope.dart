import 'package:flutter/widgets.dart';

import 'shipkia_auth_controller.dart';

class ShipKiaAuthScope extends InheritedNotifier<ShipKiaAuthController> {
  const ShipKiaAuthScope({
    required ShipKiaAuthController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static ShipKiaAuthController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<ShipKiaAuthScope>();
    assert(scope != null, 'ShipKiaAuthScope was not found in the widget tree.');
    return scope!.notifier!;
  }
}

