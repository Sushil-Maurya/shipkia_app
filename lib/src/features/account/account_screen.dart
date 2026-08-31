import 'package:flutter/material.dart';

import '../../app/shipkia_theme_controller.dart';
import '../../design_system/design_system.dart';
import '../../theme/shipkia_colors.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({required this.onSignOut, super.key});

  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Account',
      body: ListView(
        padding: const EdgeInsets.only(bottom: ShipKiaSpacing.xl),
        children: [
          const _AccountHeader(),
          const SizedBox(height: ShipKiaSpacing.md),
          const _AccountSection(
            children: [
              _AccountAction(
                icon: Icons.group_outlined,
                title: 'Manage users',
                subtitle: 'Roles, access and team permissions',
              ),
              _AccountAction(
                icon: Icons.settings_outlined,
                title: 'Account settings',
                subtitle: 'Company profile, billing defaults and security',
              ),
            ],
          ),
          const SizedBox(height: ShipKiaSpacing.md),
          const _AccountSection(children: [_ThemeAction()]),
          const SizedBox(height: ShipKiaSpacing.md),
          const _AccountSection(
            children: [
              _AccountAction(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy',
                subtitle: 'Data usage and account protection',
              ),
              _AccountAction(
                icon: Icons.data_object_outlined,
                title: 'Build',
                subtitle: 'dev',
              ),
            ],
          ),
          const SizedBox(height: ShipKiaSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ShipKiaSpacing.page,
            ),
            child: AppButton(
              label: 'Sign out',
              icon: Icons.logout,
              onPressed: () => _confirmSignOut(context),
              variant: AppButtonVariant.destructive,
              fullWidth: true,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showAppDialog<void>(
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
    );
  }
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(ShipKiaSpacing.page),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [ShipKiaColors.shipkiaBlue, ShipKiaColors.teal],
        ),
        borderRadius: ShipKiaRadius.lgBorder,
        boxShadow: ShipKiaElevation.raised,
      ),
      child: Padding(
        padding: const EdgeInsets.all(ShipKiaSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
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
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: ShipKiaColors.paper,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: ShipKiaSpacing.md),
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
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: ShipKiaColors.paper,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),
                      const _HeaderPill(label: 'ADMIN'),
                    ],
                  ),
                  const SizedBox(height: ShipKiaSpacing.xs),
                  Text(
                    'ops@shipkia.com',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ShipKiaColors.paper.withValues(alpha: 0.84),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: ShipKiaSpacing.xs),
                  Row(
                    children: [
                      const Icon(
                        Icons.business_outlined,
                        size: 14,
                        color: ShipKiaColors.paper,
                      ),
                      const SizedBox(width: ShipKiaSpacing.xs),
                      Text(
                        'SHIPKIA-DEMO',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: ShipKiaColors.paper.withValues(alpha: 0.78),
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
    );
  }
}

class _AccountSection extends StatelessWidget {
  const _AccountSection({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: ShipKiaSpacing.page),
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index != children.length - 1) const Divider(),
          ],
        ],
      ),
    );
  }
}

class _AccountAction extends StatelessWidget {
  const _AccountAction({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: ShipKiaRadius.mdBorder,
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(ShipKiaSpacing.md),
        child: Row(
          children: [
            _ActionIcon(icon: icon),
            const SizedBox(width: ShipKiaSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: ShipKiaSpacing.xs),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: ShipKiaColors.textSecondary(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: ShipKiaColors.textSecondary(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeAction extends StatelessWidget {
  const _ThemeAction();

  @override
  Widget build(BuildContext context) {
    final mode = ShipKiaThemeController.modeOf(context);
    final enabled =
        mode == ThemeMode.dark ||
        (mode == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);

    return InkWell(
      borderRadius: ShipKiaRadius.mdBorder,
      onTap: () => ShipKiaThemeController.setMode(
        context,
        enabled ? ThemeMode.light : ThemeMode.dark,
      ),
      child: Padding(
        padding: const EdgeInsets.all(ShipKiaSpacing.md),
        child: Row(
          children: [
            _ActionIcon(
              icon: enabled
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
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
          ],
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ShipKiaColors.shipkiaBlue.withValues(alpha: 0.12),
        borderRadius: ShipKiaRadius.mdBorder,
      ),
      child: Icon(icon, size: 19, color: ShipKiaColors.shipkiaBlue),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.label});

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
        padding: const EdgeInsets.symmetric(
          horizontal: ShipKiaSpacing.sm,
          vertical: ShipKiaSpacing.xs,
        ),
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
