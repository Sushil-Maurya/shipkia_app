import 'package:flutter/material.dart';

import '../theme/shipkia_colors.dart';

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

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onSelected == null ? null : () => onSelected!(!selected),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? ShipKiaColors.shipkiaBlue
                  : ShipKiaColors.neutralBorder,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(
              label,
              style: TextStyle(
                color: foreground,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
