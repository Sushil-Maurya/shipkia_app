import 'package:flutter/material.dart';

import '../theme/shipkia_colors.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.margin,
    this.padding = const EdgeInsets.all(12),
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark
        ? ShipKiaColors.nightBorder
        : ShipKiaColors.neutralBorder;
    final surface = isDark ? ShipKiaColors.nightCard : ShipKiaColors.paper;

    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: surface,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(padding: padding, child: child),
    );

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: onTap == null
          ? content
          : InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onTap,
              child: content,
            ),
    );
  }
}
