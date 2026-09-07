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
    final scope = context.dependOnInheritedWidgetOfExactType<ShipKiaApiScope>();
    assert(scope != null, 'ShipKiaApiScope was not found in the widget tree.');
    return scope!.apiClient;
  }

  @override
  bool updateShouldNotify(ShipKiaApiScope oldWidget) {
    return apiClient != oldWidget.apiClient;
  }
}
