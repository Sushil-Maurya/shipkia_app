import 'package:flutter/material.dart';

import 'src/app/shipkia_app.dart';
import 'src/core/api/api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvironmentConfig.load();
  runApp(const ShipKiaApp());
}
