import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/shipkia_colors.dart';
import 'app_button.dart';
import 'app_platform.dart';
import 'shipkia_tokens.dart';

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
    barrierDismissible: false,
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
        contentTextStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: ShipKiaColors.textSecondary(context),
          height: 1.5,
        ),
        actions: [
          for (final action in actions)
            AppButton(
              label: action.label,
              onPressed: action.onPressed,
              variant: action.isDestructive
                  ? AppButtonVariant.destructive
                  : action.isDefault
                  ? AppButtonVariant.primary
                  : AppButtonVariant.ghost,
              height: 36,
            ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(
          ShipKiaSpacing.lg,
          0,
          ShipKiaSpacing.lg,
          ShipKiaSpacing.lg,
        ),
      );
    },
  );
}
