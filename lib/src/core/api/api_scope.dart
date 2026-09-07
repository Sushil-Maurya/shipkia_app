import 'package:flutter/widgets.dart';

import 'api_client.dart';

class ShipKiaApiScope extends InheritedWidget {
  const ShipKiaApiScope({
    required this.apiClient,
    required super.child,
    super.key,
  });

  final ApiClient apiClient;

  static ApiClient of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'ShipKiaApiScope was not found in the widget tree.');
    return scope!;
  }

  static ApiClient? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ShipKiaApiScope>()
        ?.apiClient;
  }

  @override
  bool updateShouldNotify(ShipKiaApiScope oldWidget) {
    return apiClient != oldWidget.apiClient;
  }
}
