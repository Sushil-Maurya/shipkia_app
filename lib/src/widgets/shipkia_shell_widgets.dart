import 'package:flutter/material.dart';

import '../design_system/design_system.dart';
import '../theme/shipkia_colors.dart';

class ShipKiaTopBar extends StatelessWidget {
  const ShipKiaTopBar({
    required this.title,
    required this.subtitle,
    required this.onOpenModules,
    required this.onOpenProfile,
    super.key,
  });

  final String title;
  final String subtitle;
  final VoidCallback onOpenModules;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final showSyncPill = MediaQuery.sizeOf(context).width >= 430;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: ShipKiaColors.surface(context),
        border: Border(
          bottom: BorderSide(color: ShipKiaColors.border(context)),
        ),
        boxShadow: ShipKiaElevation.raised,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
          child: Row(
            children: [
              AppIconButton(
                icon: Icons.menu,
                onPressed: onOpenModules,
                tooltip: 'Open modules',
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
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: ShipKiaColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              AppIconButton(
                icon: Icons.search,
                onPressed: () {},
                tooltip: 'Search',
              ),
              AppIconButton(
                icon: Icons.notifications_none,
                onPressed: () {},
                tooltip: 'Alerts',
              ),
              if (showSyncPill) ...[
                const SizedBox(width: ShipKiaSpacing.xs),
                const _SyncStatusPill(),
                const SizedBox(width: ShipKiaSpacing.xs),
              ],
              AppIconButton(
                icon: Icons.person_outline,
                onPressed: onOpenProfile,
                tooltip: 'Open account',
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
      decoration: BoxDecoration(
        color: ShipKiaColors.surfaceMuted(context),
        border: Border(
          bottom: BorderSide(color: ShipKiaColors.border(context)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 28,
                child: AppTextField(
                  hintText: hint,
                  prefixIcon: Icons.search,
                  suffix: const Icon(Icons.keyboard_command_key, size: 15),
                  height: 28,
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
      decoration: BoxDecoration(
        color: ShipKiaColors.surface(context),
        border: Border(top: BorderSide(color: ShipKiaColors.border(context))),
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
                      borderRadius: ShipKiaRadius.mdBorder,
                    ),
                    child: const Icon(
                      Icons.local_shipping,
                      color: ShipKiaColors.paper,
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
                  return AppListTile(
                    leading: Icon(module.$1, size: 20),
                    title: module.$2,
                    subtitle: module.$3,
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
    final color = selected
        ? ShipKiaColors.shipkiaBlue
        : ShipKiaColors.textSecondary(context);
    final iconColor = selected ? ShipKiaColors.paper : color;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: ShipKiaMotion.duration(context, ShipKiaMotion.fast),
            curve: ShipKiaMotion.standard,
            decoration: BoxDecoration(
              color: selected ? ShipKiaColors.shipkiaBlue : Colors.transparent,
              borderRadius: ShipKiaRadius.mdBorder,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Icon(icon, color: iconColor, size: 19),
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

class _SyncStatusPill extends StatelessWidget {
  const _SyncStatusPill();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ShipKiaColors.success.withValues(alpha: 0.10),
        borderRadius: ShipKiaRadius.pillBorder,
        border: Border.all(color: ShipKiaColors.success.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ShipKiaSpacing.sm,
          vertical: ShipKiaSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_done_outlined,
              size: 13,
              color: ShipKiaColors.success,
            ),
            const SizedBox(width: ShipKiaSpacing.xs),
            Text(
              'Synced',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: ShipKiaColors.success,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
