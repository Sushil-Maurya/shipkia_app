import 'package:flutter/material.dart';

import '../theme/shipkia_colors.dart';
import 'shipkia_tokens.dart';

class AppChip extends StatelessWidget {
  const AppChip({
    required this.label,
    this.selected = false,
    this.onSelected,
    super.key,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;

  @override
  Widget build(BuildContext context) {
    final foreground = selected
        ? ShipKiaColors.paper
        : Theme.of(context).colorScheme.onSurface;
    final background = selected
        ? ShipKiaColors.shipkiaBlue
        : Theme.of(context).colorScheme.surface;

    return Align(
      alignment: Alignment.centerLeft,
      widthFactor: 1,
      heightFactor: 1,
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Semantics(
          button: onSelected != null,
          selected: selected,
          child: InkWell(
            borderRadius: ShipKiaRadius.mdBorder,
            onTap: onSelected == null ? null : () => onSelected!(!selected),
            child: AnimatedContainer(
              duration: ShipKiaMotion.duration(context, ShipKiaMotion.fast),
              curve: ShipKiaMotion.standard,

              decoration: BoxDecoration(
                color: background,
                borderRadius: ShipKiaRadius.mdBorder,
                border: Border.all(
                  color: selected
                      ? ShipKiaColors.shipkiaBlue
                      : ShipKiaColors.border(context),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 12,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
