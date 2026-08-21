import 'package:flutter/material.dart';

import 'app_shipkia_loader.dart';

class AppProgressIndicator extends StatelessWidget {
  const AppProgressIndicator({this.value, this.size = 20, super.key});

  final double? value;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (value != null) {
      return LinearProgressIndicator(value: value);
    }

    return AppShipKiaLoader(size: size * 2.4, showLabel: false);
  }
}
