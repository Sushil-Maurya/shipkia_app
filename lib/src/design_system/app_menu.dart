import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_platform.dart';

class AppMenuItem {
  const AppMenuItem({required this.label, required this.onSelected, this.icon});

  final String label;
  final VoidCallback onSelected;
  final IconData? icon;
}

class AppMenu extends StatelessWidget {
  const AppMenu({required this.anchor, required this.items, super.key});

  final Widget anchor;
  final List<AppMenuItem> items;

  @override
  Widget build(BuildContext context) {
    if (AppPlatform.isCupertino) {
      return GestureDetector(
        onTap: () => showCupertinoModalPopup<void>(
          context: context,
          builder: (context) => CupertinoActionSheet(
            actions: [
              for (final item in items)
                CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    item.onSelected();
                  },
                  child: Text(item.label),
                ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ),
        ),
        child: anchor,
      );
    }

    return MenuAnchor(
      menuChildren: [
        for (final item in items)
          MenuItemButton(
            onPressed: item.onSelected,
            leadingIcon: item.icon == null ? null : Icon(item.icon, size: 16),
            child: Text(item.label),
          ),
      ],
      builder: (context, controller, child) {
        return GestureDetector(
          onTap: () =>
              controller.isOpen ? controller.close() : controller.open(),
          child: anchor,
        );
      },
    );
  }
}
