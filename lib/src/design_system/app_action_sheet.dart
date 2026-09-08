import 'package:flutter/material.dart';

import '../theme/shipkia_colors.dart';
import 'app_bottom_sheet.dart';
import 'app_button.dart';
import 'app_chip.dart';
import 'app_icon_button.dart';
import 'app_list_tile.dart';
import 'shipkia_tokens.dart';

class AppActionSheetItem {
  const AppActionSheetItem({
    required this.label,
    required this.icon,
    required this.onSelected,
    this.subtitle,
  });

  final String label;
  final IconData icon;
  final VoidCallback onSelected;
  final String? subtitle;
}

Future<void> showAppActionSheet({
  required BuildContext context,
  required String title,
  required List<AppActionSheetItem> items,
}) {
  return showAppBottomSheet<void>(
    context: context,
    builder: (context) => AppActionSheet(title: title, items: items),
  );
}

class AppActionSheet extends StatelessWidget {
  const AppActionSheet({required this.title, required this.items, super.key});

  final String title;
  final List<AppActionSheetItem> items;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SheetHeader(title: title),
            const SizedBox(height: ShipKiaSpacing.sm),
            for (final item in items)
              AppListTile(
                leading: Icon(item.icon, color: ShipKiaColors.shipkiaBlue),
                title: item.label,
                subtitle: item.subtitle,
                trailing: const Icon(Icons.chevron_right, size: 18),
                onTap: () {
                  Navigator.of(context).pop();
                  item.onSelected();
                },
              ),
          ],
        ),
      ),
    );
  }
}

Future<T?> showAppFilterSheet<T>({
  required BuildContext context,
  required String title,
  required List<AppFilterOption<T>> options,
  required T? selectedValue,
  required ValueChanged<T?> onApply,
  String? allLabel,
}) {
  return showAppBottomSheet<T>(
    context: context,
    builder: (context) => AppFilterSheet<T>(
      title: title,
      options: options,
      selectedValue: selectedValue,
      onApply: onApply,
      allLabel: allLabel,
    ),
  );
}

class AppFilterOption<T> {
  const AppFilterOption({required this.label, required this.value});

  final String label;
  final T value;
}

class AppFilterSheet<T> extends StatefulWidget {
  const AppFilterSheet({
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onApply,
    this.allLabel,
    super.key,
  });

  final String title;
  final List<AppFilterOption<T>> options;
  final T? selectedValue;
  final ValueChanged<T?> onApply;
  final String? allLabel;

  @override
  State<AppFilterSheet<T>> createState() => _AppFilterSheetState<T>();
}

class _AppFilterSheetState<T> extends State<AppFilterSheet<T>> {
  T? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.selectedValue;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SheetHeader(title: widget.title),
            const SizedBox(height: ShipKiaSpacing.md),
            Wrap(
              runSpacing: ShipKiaSpacing.sm,
              children: [
                if (widget.allLabel != null)
                  AppChip(
                    label: widget.allLabel!,
                    selected: _selectedValue == null,
                    onSelected: (_) => setState(() => _selectedValue = null),
                  ),
                for (final option in widget.options)
                  AppChip(
                    label: option.label,
                    selected: _selectedValue == option.value,
                    onSelected: (_) =>
                        setState(() => _selectedValue = option.value),
                  ),
              ],
            ),
            const SizedBox(height: ShipKiaSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Reset',
                    icon: Icons.restart_alt,
                    variant: AppButtonVariant.secondary,
                    onPressed: () => setState(() => _selectedValue = null),
                  ),
                ),
                const SizedBox(width: ShipKiaSpacing.sm),
                Expanded(
                  child: AppButton(
                    label: 'Apply',
                    icon: Icons.check,
                    onPressed: () {
                      widget.onApply(_selectedValue);
                      Navigator.of(context).pop(_selectedValue);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        AppIconButton(
          icon: Icons.close,
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Close',
        ),
      ],
    );
  }
}
