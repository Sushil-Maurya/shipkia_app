import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/design_system.dart';
import '../../theme/shipkia_colors.dart';
import 'app_route_paths.dart';

class AppRouteErrorScreen extends StatelessWidget {
  const AppRouteErrorScreen({
    required this.title,
    required this.message,
    this.icon = Icons.route_outlined,
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;

  const AppRouteErrorScreen.notFound({super.key})
    : title = 'Page not found',
      message = 'This ShipKia route is unavailable or no longer exists.',
      icon = Icons.travel_explore;

  const AppRouteErrorScreen.notAuthorized({super.key})
    : title = 'Access restricted',
      message = 'Your current role does not include permission for this area.',
      icon = Icons.lock_outline;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(ShipKiaSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: ShipKiaColors.shipkiaBlue.withValues(alpha: 0.12),
                    borderRadius: ShipKiaRadius.mdBorder,
                  ),
                  child: Icon(icon, color: ShipKiaColors.shipkiaBlue),
                ),
                const SizedBox(height: ShipKiaSpacing.md),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: ShipKiaSpacing.sm),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ShipKiaColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: ShipKiaSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Back',
                        icon: Icons.arrow_back,
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go(AppRoutePaths.home);
                          }
                        },
                        variant: AppButtonVariant.secondary,
                      ),
                    ),
                    const SizedBox(width: ShipKiaSpacing.sm),
                    Expanded(
                      child: AppButton(
                        label: 'Home',
                        icon: Icons.home_outlined,
                        onPressed: () => context.go(AppRoutePaths.home),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

