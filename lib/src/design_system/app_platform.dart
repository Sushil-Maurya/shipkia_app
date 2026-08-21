import 'package:flutter/foundation.dart';

class AppPlatform {
  const AppPlatform._();

  static bool get isCupertino {
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }
}
