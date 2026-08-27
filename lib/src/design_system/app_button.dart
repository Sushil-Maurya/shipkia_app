import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/shipkia_colors.dart';
import 'app_platform.dart';
import 'shipkia_tokens.dart';

enum AppButtonVariant { primary, secondary, ghost, destructive }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.fullWidth = false,
    this.height = 40,
    this.loading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final bool fullWidth;
  final double height;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final foreground = _foregroundColor(context);
    final background = _backgroundColor(context);
    final border = _borderColor(context);
    final effectiveOnPressed = loading ? null : onPressed;
    final child = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading) ...[
          SizedBox.square(
            dimension: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: foreground.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(width: ShipKiaSpacing.sm),
        ] else if (icon != null) ...[
          Icon(icon, size: 15),
          const SizedBox(width: 6),
        ],
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    );

    if (AppPlatform.isCupertino && variant != AppButtonVariant.secondary) {
      return SizedBox(
        width: fullWidth ? double.infinity : null,
        height: height,
        child: CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          borderRadius: ShipKiaRadius.mdBorder,
          color: variant == AppButtonVariant.ghost ? null : background,
          disabledColor: ShipKiaColors.neutralMuted,
          onPressed: effectiveOnPressed,
          child: IconTheme(
            data: IconThemeData(color: foreground, size: 15),
            child: DefaultTextStyle(
              style: TextStyle(
                color: foreground,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
              child: child,
            ),
          ),
        ),
      );
    }

    final style = ButtonStyle(
      minimumSize: WidgetStateProperty.all(Size(0, height)),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 12),
      ),
      foregroundColor: WidgetStateProperty.all(foreground),
      backgroundColor: WidgetStateProperty.all(background),
      side: WidgetStateProperty.all(BorderSide(color: border)),
      elevation: WidgetStateProperty.all(0),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: ShipKiaRadius.mdBorder),
      ),
      textStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
      ),
    );

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height,
      child: TextButton(
        onPressed: effectiveOnPressed,
        style: style,
        child: AnimatedSwitcher(
          duration: ShipKiaMotion.duration(context, ShipKiaMotion.fast),
          child: child,
        ),
      ),
    );
  }

  Color _backgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return switch (variant) {
      AppButtonVariant.primary => ShipKiaColors.shipkiaBlue,
      AppButtonVariant.secondary =>
        isDark ? ShipKiaColors.nightCard : ShipKiaColors.paper,
      AppButtonVariant.ghost => Colors.transparent,
      AppButtonVariant.destructive => ShipKiaColors.destructive,
    };
  }

  Color _foregroundColor(BuildContext context) {
    return switch (variant) {
      AppButtonVariant.primary => ShipKiaColors.paper,
      AppButtonVariant.secondary => Theme.of(context).colorScheme.onSurface,
      AppButtonVariant.ghost => ShipKiaColors.shipkiaBlue,
      AppButtonVariant.destructive => ShipKiaColors.paper,
    };
  }

  Color _borderColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return switch (variant) {
      AppButtonVariant.secondary =>
        isDark ? ShipKiaColors.nightBorder : ShipKiaColors.neutralBorder,
      AppButtonVariant.ghost => Colors.transparent,
      AppButtonVariant.primary => ShipKiaColors.shipkiaBlue,
      AppButtonVariant.destructive => ShipKiaColors.destructive,
    };
  }
}
