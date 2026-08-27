import 'package:flutter/material.dart';

import '../app/shipkia_theme_controller.dart';
import '../design_system/design_system.dart';
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
                      style: Theme.of(context).textTheme.labelSmall
                          ?.copyWith(color: ShipKiaColors.mutedInk),
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
          RoundedRectangleBorder(borderRadius: ShipKiaRadius.lgBorder),
        ),
      ),
      menuChildren: [_UserProfilePanel(onSignOut: onSignOut)],
      builder: (context, controller, child) {
        return AppIconButton(
          icon: Icons.person_outline,
          onPressed: () =>
              controller.isOpen ? controller.close() : controller.open(),
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
        width: 332,
        constraints: const BoxConstraints(maxWidth: 332),
        decoration: BoxDecoration(
          color: ShipKiaColors.surface(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ShipKiaColors.border(context)),
          boxShadow: ShipKiaElevation.overlay,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [ShipKiaColors.shipkiaBlue, ShipKiaColors.teal],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: ShipKiaColors.paper.withValues(alpha: 0.18),
                        borderRadius: ShipKiaRadius.lgBorder,
                        border: Border.all(
                          color: ShipKiaColors.paper.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Text(
                        'OS',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: ShipKiaColors.paper,
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
                                      ?.copyWith(
                                        color: ShipKiaColors.paper,
                                        fontWeight: FontWeight.w900,
                                      ),
                                ),
                              ),
                              const _ProfilePill(label: 'ADMIN'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ops@shipkia.com',
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: ShipKiaColors.paper.withValues(
                                    alpha: 0.82,
                                  ),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.business_outlined,
                                size: 12,
                                color: ShipKiaColors.paper,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'SHIPKIA-DEMO',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: ShipKiaColors.paper.withValues(
                                        alpha: 0.78,
                                      ),
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: ShipKiaSpacing.sm),
            _ProfileMenuAction(
              icon: Icons.group_outlined,
              label: 'Manage users',
            ),
            _ProfileMenuAction(
              icon: Icons.settings_outlined,
              label: 'Account settings',
            ),
            const Divider(),
            const _ThemeModeToggle(),
            const Divider(),
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: ShipKiaColors.surfaceMuted(context),
                borderRadius: ShipKiaRadius.mdBorder,
                border: Border.all(color: ShipKiaColors.border(context)),
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
                  AppButton(
                    label: 'Sign out',
                    icon: Icons.logout,
                    onPressed: () => showAppDialog<void>(
                      context: context,
                      title: 'Sign out?',
                      message: 'You will return to the ShipKia login screen. Unsynced local changes should finish before signing out.',
                      actions: [
                        AppDialogAction(
                          label: 'Cancel',
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        AppDialogAction(
                          label: 'Sign out',
                          isDestructive: true,
                          isDefault: true,
                          onPressed: () {
                            Navigator.of(context).pop();
                            onSignOut();
                          },
                        ),
                      ],
                    ),
                    variant: AppButtonVariant.destructive,
                    height: 28,
                  ),
                  const Spacer(),
                  AppButton(
                    label: 'Privacy',
                    icon: Icons.privacy_tip_outlined,
                    onPressed: () {},
                    variant: AppButtonVariant.ghost,
                    height: 28,
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

class _ThemeModeToggle extends StatelessWidget {
  const _ThemeModeToggle();

  @override
  Widget build(BuildContext context) {
    final mode = ShipKiaThemeController.modeOf(context);
    final enabled =
        mode == ThemeMode.dark ||
        (mode == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ShipKiaSpacing.md,
        vertical: 3,
      ),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          height: 44,
          decoration: BoxDecoration(
            color: ShipKiaColors.surfaceMuted(context),
            borderRadius: ShipKiaRadius.lgBorder,
            border: Border.all(color: ShipKiaColors.border(context)),
          ),
          child: InkWell(
            borderRadius: ShipKiaRadius.lgBorder,
            onTap: () => ShipKiaThemeController.setMode(
              context,
              enabled ? ThemeMode.light : ThemeMode.dark,
            ),
            child: Row(
              children: [
                const SizedBox(width: ShipKiaSpacing.md),
                Icon(
                  enabled
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,
                  size: 18,
                  color: ShipKiaColors.shipkiaBlue,
                ),
                const SizedBox(width: ShipKiaSpacing.md),
                Expanded(
                  child: Text(
                    'Theme',
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                ),
                AppSwitch(
                  value: enabled,
                  onChanged: (value) => ShipKiaThemeController.setMode(
                    context,
                    value ? ThemeMode.dark : ThemeMode.light,
                  ),
                ),
                const SizedBox(width: ShipKiaSpacing.sm),
              ],
            ),
          ),
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
        color: ShipKiaColors.paper.withValues(alpha: 0.18),
        borderRadius: ShipKiaRadius.pillBorder,
        border: Border.all(color: ShipKiaColors.paper.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: ShipKiaColors.paper,
            fontSize: 9,
            fontWeight: FontWeight.w900,
          ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ShipKiaSpacing.md,
        vertical: 3,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: ShipKiaRadius.lgBorder,
          onTap: () {},
          child: Ink(
            height: 44,
            decoration: BoxDecoration(
              color: ShipKiaColors.surfaceMuted(context),
              borderRadius: ShipKiaRadius.lgBorder,
              border: Border.all(color: ShipKiaColors.border(context)),
            ),
            child: Padding(
              padding: EdgeInsets.zero,
              child: Row(
                children: [
                  const SizedBox(width: ShipKiaSpacing.md),
                  Icon(icon, size: 18, color: ShipKiaColors.shipkiaBlue),
                  const SizedBox(width: ShipKiaSpacing.md),
                  Expanded(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: ShipKiaColors.textPrimary(context),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: ShipKiaColors.textSecondary(context),
                  ),
                  const SizedBox(width: ShipKiaSpacing.sm),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
