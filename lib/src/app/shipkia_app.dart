import 'package:flutter/material.dart';

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
      home: const LoginScreen(),
    );
  }
}
