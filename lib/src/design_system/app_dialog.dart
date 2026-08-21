import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_platform.dart';

class AppDialogAction {
  const AppDialogAction({
    required this.label,
    required this.onPressed,
    this.isDestructive = false,
    this.isDefault = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isDestructive;
  final bool isDefault;
}

Future<T?> showAppDialog<T>({
  required BuildContext context,
  required String title,
  required String message,
  required List<AppDialogAction> actions,
}) {
  return showDialog<T>(
    context: context,
    builder: (context) {
      if (AppPlatform.isCupertino) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            for (final action in actions)
              CupertinoDialogAction(
                isDestructiveAction: action.isDestructive,
                isDefaultAction: action.isDefault,
                onPressed: action.onPressed,
                child: Text(action.label),
              ),
          ],
        );
      }

      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          for (final action in actions)
            TextButton(onPressed: action.onPressed, child: Text(action.label)),
        ],
      );
    },
  );
}
