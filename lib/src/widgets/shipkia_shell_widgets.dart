import 'package:flutter/material.dart';

import '../theme/shipkia_colors.dart';

class ShipKiaTopBar extends StatelessWidget {
  const ShipKiaTopBar({
    required this.title,
    required this.subtitle,
    required this.onOpenModules,
    required this.onSignOut,
    super.key,
  });

  final String title;
  final String subtitle;
  final VoidCallback onOpenModules;
  final VoidCallback onSignOut;

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
              IconButton.outlined(
                onPressed: onOpenModules,
                icon: const Icon(Icons.menu, size: 18),
                tooltip: 'Open modules',
                style: IconButton.styleFrom(
                  fixedSize: const Size(34, 34),
                  backgroundColor: ShipKiaColors.neutralMuted,
                  foregroundColor: ShipKiaColors.ink,
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
              ShipKiaUserProfileMenu(onSignOut: onSignOut),
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
                height: 28,
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
    final iconColor = selected ? ShipKiaColors.paper : color;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: selected ? ShipKiaColors.shipkiaBlue : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
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

class ShipKiaUserProfileMenu extends StatelessWidget {
  const ShipKiaUserProfileMenu({required this.onSignOut, super.key});

  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      style: MenuStyle(
        padding: WidgetStateProperty.all(EdgeInsets.zero),
        backgroundColor: WidgetStateProperty.all(Colors.transparent),
        elevation: WidgetStateProperty.all(0),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      menuChildren: [_UserProfilePanel(onSignOut: onSignOut)],
      builder: (context, controller, child) {
        return IconButton(
          onPressed: () =>
              controller.isOpen ? controller.close() : controller.open(),
          icon: const Icon(Icons.person_outline, size: 19),
          tooltip: 'Open profile menu',
        );
      },
    );
  }
}

class _UserProfilePanel extends StatelessWidget {
  const _UserProfilePanel({required this.onSignOut});

  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 310,
        constraints: const BoxConstraints(maxWidth: 310),
        decoration: BoxDecoration(
          color: ShipKiaColors.paper.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ShipKiaColors.neutralBorder),
          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 60,
              offset: Offset(0, 18),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(height: 4, color: ShipKiaColors.shipkiaBlue),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: ShipKiaColors.shipkiaBlue.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ShipKiaColors.shipkiaBlue.withValues(
                          alpha: 0.25,
                        ),
                      ),
                    ),
                    child: Text(
                      'OS',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: ShipKiaColors.shipkiaBlue,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Ops Supervisor',
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                            ),
                            _ProfilePill(label: 'ADMIN'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ops@shipkia.com',
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: ShipKiaColors.mutedInk,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.business_outlined,
                              size: 12,
                              color: ShipKiaColors.mutedInk,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'SHIPKIA-DEMO',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: ShipKiaColors.mutedInk),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            _ProfileMenuAction(
              icon: Icons.group_outlined,
              label: 'Manage users',
            ),
            _ProfileMenuAction(
              icon: Icons.settings_outlined,
              label: 'Account settings',
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text(
                    'THEME',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: ShipKiaColors.mutedInk,
                      letterSpacing: 1.6,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.light_mode_outlined, size: 16),
                  const SizedBox(width: 8),
                  const Icon(Icons.dark_mode_outlined, size: 16),
                ],
              ),
            ),
            const Divider(),
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: ShipKiaColors.neutralMuted,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ShipKiaColors.neutralBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('BUILD:', style: Theme.of(context).textTheme.labelSmall),
                  const SizedBox(height: 4),
                  Text('dev', style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: onSignOut,
                    icon: const Icon(Icons.logout, size: 14),
                    label: const Text('Sign out'),
                    style: TextButton.styleFrom(
                      foregroundColor: ShipKiaColors.destructive,
                      padding: EdgeInsets.zero,
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.privacy_tip_outlined, size: 14),
                    label: const Text('Privacy'),
                    style: TextButton.styleFrom(
                      foregroundColor: ShipKiaColors.mutedInk,
                      padding: EdgeInsets.zero,
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfilePill extends StatelessWidget {
  const _ProfilePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ShipKiaColors.shipkiaBlue.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: ShipKiaColors.shipkiaBlue.withValues(alpha: 0.20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: ShipKiaColors.shipkiaBlue, fontSize: 9),
        ),
      ),
    );
  }
}

class _ProfileMenuAction extends StatelessWidget {
  const _ProfileMenuAction({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: TextButton.icon(
        onPressed: () {},
        icon: Icon(icon, size: 15),
        label: Text(label),
        style: TextButton.styleFrom(
          alignment: Alignment.centerLeft,
          foregroundColor: ShipKiaColors.ink,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
