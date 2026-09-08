import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/shipkia_colors.dart';
import 'app_platform.dart';
import 'shipkia_tokens.dart';

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.filled = false,
    this.size = 30,
    this.iconSize = 18,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool filled;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final foreground = filled
        ? ShipKiaColors.paper
        : ShipKiaColors.textPrimary(context);
    final background = filled
        ? ShipKiaColors.shipkiaBlue
        : ShipKiaColors.surfaceMuted(context);

    if (AppPlatform.isCupertino) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: Size.square(size),
        borderRadius: ShipKiaRadius.mdBorder,
        color: background,
        onPressed: onPressed,
        child: Icon(icon, size: iconSize, color: foreground),
      );
    }

    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: iconSize),
      tooltip: tooltip,
      style: IconButton.styleFrom(
        fixedSize: Size(size, size),
        minimumSize: Size(size, size),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.standard,
        backgroundColor: background,
        foregroundColor: foreground,
        shape: RoundedRectangleBorder(borderRadius: ShipKiaRadius.mdBorder),
      ),
    );
  }
}
