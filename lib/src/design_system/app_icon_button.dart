import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/shipkia_colors.dart';
import 'app_platform.dart';

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.filled = false,
    this.size = 34,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool filled;
  final double size;

  @override
  Widget build(BuildContext context) {
    final foreground = filled ? ShipKiaColors.paper : ShipKiaColors.ink;
    final background = filled
        ? ShipKiaColors.shipkiaBlue
        : ShipKiaColors.neutralMuted;

    if (AppPlatform.isCupertino) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: Size.square(size),
        borderRadius: BorderRadius.circular(8),
        color: background,
        onPressed: onPressed,
        child: Icon(icon, size: 18, color: foreground),
      );
    }

    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      tooltip: tooltip,
      style: IconButton.styleFrom(
        fixedSize: Size(size, size),
        backgroundColor: background,
        foregroundColor: foreground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
