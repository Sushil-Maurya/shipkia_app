import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_platform.dart';

class AppProgressIndicator extends StatelessWidget {
  const AppProgressIndicator({this.value, this.size = 20, super.key});

  final double? value;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (value != null) {
      return LinearProgressIndicator(value: value);
    }

    return AppPlatform.isCupertino
        ? CupertinoActivityIndicator(radius: size / 2)
        : SizedBox.square(
            dimension: size,
            child: const CircularProgressIndicator(strokeWidth: 2),
          );
  }
}
