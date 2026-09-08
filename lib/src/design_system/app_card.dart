import 'package:flutter/material.dart';

import '../theme/shipkia_colors.dart';
import 'shipkia_tokens.dart';

class AppCard extends StatefulWidget {
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
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    final surface = ShipKiaColors.surface(context);

    final content = AnimatedScale(
      scale: _pressed ? 0.985 : 1,
      duration: ShipKiaMotion.duration(context, ShipKiaMotion.fast),
      curve: ShipKiaMotion.standard,
      child: AnimatedContainer(
        duration: ShipKiaMotion.duration(context, ShipKiaMotion.fast),
        curve: ShipKiaMotion.standard,
        decoration: BoxDecoration(
          color: surface,
          border: Border.all(color: ShipKiaColors.border(context)),
          borderRadius: ShipKiaRadius.mdBorder,
          boxShadow: _pressed ? ShipKiaElevation.none : ShipKiaElevation.raised,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: Padding(padding: widget.padding, child: widget.child),
        ),
      ),
    );

    return Padding(
      padding: widget.margin ?? EdgeInsets.zero,
      child: widget.onTap == null
          ? content
          : MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (_) => setState(() => _pressed = true),
                onTapCancel: () => setState(() => _pressed = false),
                onTapUp: (_) => setState(() => _pressed = false),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: ShipKiaRadius.mdBorder,
                    onTap: widget.onTap,
                    child: content,
                  ),
                ),
              ),
            ),
    );
  }
}
