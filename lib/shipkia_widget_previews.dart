import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'src/app/shipkia_app.dart';
import 'src/core/auth/shipkia_auth_controller.dart';
import 'src/data/shipkia_mock_data.dart';
import 'src/features/auth/login_screen.dart';
import 'src/features/orders/order_detail_screen.dart';
import 'src/features/tracking/tracking_screen.dart';
import 'src/theme/shipkia_theme.dart';
import 'src/widgets/shipkia_widgets.dart';

Widget _previewFrame(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ShipKiaTheme.light,
    darkTheme: ShipKiaTheme.dark,
    home: child,
  );
}

@Preview(name: 'Login', group: 'ShipKia Mobile', size: Size(390, 844))
Widget shipKiaLoginPreview() {
  return _previewFrame(const LoginScreen());
}

@Preview(
  name: 'Operations Shell',
  group: 'ShipKia Mobile',
  size: Size(390, 844),
)
Widget shipKiaShellPreview() {
  return ShipKiaApp(
    authController: ShipKiaAuthController(
      initialStatus: ShipKiaAuthStatus.authenticated,
    ),
  );
}

@Preview(name: 'Order Row', group: 'ShipKia Components', size: Size(390, 160))
Widget shipKiaOrderRowPreview() {
  return _previewFrame(
    Scaffold(
      body: Center(
        child: SkOrderRow(order: orders.first, onTap: () {}),
      ),
    ),
  );
}

@Preview(name: 'Order Detail', group: 'ShipKia Mobile', size: Size(390, 844))
Widget shipKiaOrderDetailPreview() {
  return _previewFrame(
    OrderDetailScreen(orderId: orders.first.id, order: orders.first),
  );
}

@Preview(name: 'Tracking', group: 'ShipKia Mobile', size: Size(390, 844))
Widget shipKiaTrackingPreview() {
  return _previewFrame(const TrackingScreen());
}
