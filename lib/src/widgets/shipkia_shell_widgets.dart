import 'package:flutter/material.dart';

import '../theme/shipkia_colors.dart';

class ShipKiaTopBar extends StatelessWidget {
  const ShipKiaTopBar({
    required this.title,
    required this.subtitle,
    required this.onOpenModules,
    super.key,
  });

  final String title;
  final String subtitle;
  final VoidCallback onOpenModules;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: ShipKiaColors.paper,
        border: Border(bottom: BorderSide(color: ShipKiaColors.neutralBorder)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
          child: Row(
            children: [
              IconButton.filled(
                onPressed: onOpenModules,
                icon: const Icon(Icons.menu, size: 18),
                tooltip: 'Open modules',
                style: IconButton.styleFrom(
                  fixedSize: const Size(34, 34),
                  backgroundColor: ShipKiaColors.shipkiaBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall
                          ?.copyWith(color: ShipKiaColors.mutedInk),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search, size: 19),
                tooltip: 'Search',
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none, size: 19),
                tooltip: 'Alerts',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShipKiaCommandBar extends StatelessWidget {
  const ShipKiaCommandBar({required this.hint, this.trailing, super.key});

  final String hint;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: ShipKiaColors.neutralMuted,
        border: Border(bottom: BorderSide(color: ShipKiaColors.neutralBorder)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 36,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: hint,
                    prefixIcon: const Icon(Icons.search, size: 18),
                    suffixIcon: const Icon(
                      Icons.keyboard_command_key,
                      size: 15,
                    ),
                  ),
                ),
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ],
        ),
      ),
    );
  }
}

class ShipKiaBottomNav extends StatelessWidget {
  const ShipKiaBottomNav({
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_outlined, 'Home'),
      (Icons.dashboard_outlined, 'Dash'),
      (Icons.inventory_2_outlined, 'Orders'),
      (Icons.report_outlined, 'NDR'),
      (Icons.account_balance_wallet_outlined, 'Wallet'),
      (Icons.more_horiz, 'More'),
    ];

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: ShipKiaColors.paper,
        border: Border(top: BorderSide(color: ShipKiaColors.neutralBorder)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _BottomNavItem(
                    icon: items[i].$1,
                    label: items[i].$2,
                    selected: selectedIndex == i,
                    onTap: () => onSelected(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? ShipKiaColors.shipkiaBlue : ShipKiaColors.mutedInk;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: selected
                  ? ShipKiaColors.shipkiaBlue.withValues(alpha: 0.10)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Icon(icon, color: color, size: 19),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class ShipKiaModuleDrawer extends StatelessWidget {
  const ShipKiaModuleDrawer({required this.modules, super.key});

  final List<(IconData, String, String)> modules;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 276,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: ShipKiaColors.shipkiaBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.local_shipping,
                      color: Colors.white,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'ShipKia',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 6),
                itemCount: modules.length,
                itemBuilder: (context, index) {
                  final module = modules[index];
                  return ListTile(
                    dense: true,
                    leading: Icon(module.$1, size: 20),
                    title: Text(
                      module.$2,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Text(module.$3),
                    trailing: const Icon(Icons.chevron_right, size: 17),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
