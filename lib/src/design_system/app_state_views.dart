import 'package:flutter/material.dart';

import '../theme/shipkia_colors.dart';
import 'app_button.dart';
import 'shipkia_tokens.dart';

enum AppStateTone { neutral, info, success, warning, error, offline }

class AppStateView extends StatelessWidget {
  const AppStateView({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.tone = AppStateTone.neutral,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final AppStateTone tone;

  @override
  Widget build(BuildContext context) {
    final color = _toneColor(context);

    return Semantics(
      liveRegion: tone == AppStateTone.error || tone == AppStateTone.offline,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(ShipKiaSpacing.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: ShipKiaRadius.lgBorder,
                    border: Border.all(color: color.withValues(alpha: 0.22)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(ShipKiaSpacing.md),
                    child: Icon(icon, color: color, size: 28),
                  ),
                ),
                const SizedBox(height: ShipKiaSpacing.lg),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: ShipKiaSpacing.sm),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ShipKiaColors.textSecondary(context),
                    height: 1.5,
                  ),
                ),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: ShipKiaSpacing.lg),
                  AppButton(
                    label: actionLabel!,
                    icon: Icons.refresh,
                    onPressed: onAction,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _toneColor(BuildContext context) {
    return switch (tone) {
      AppStateTone.neutral => ShipKiaColors.textSecondary(context),
      AppStateTone.info => ShipKiaColors.info,
      AppStateTone.success => ShipKiaColors.success,
      AppStateTone.warning => ShipKiaColors.warning,
      AppStateTone.error => ShipKiaColors.error,
      AppStateTone.offline => ShipKiaColors.warning,
    };
  }
}

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return AppStateView(
      icon: Icons.inventory_2_outlined,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      tone: AppStateTone.info,
    );
  }
}

class AppErrorState extends StatelessWidget {
  const AppErrorState({
    required this.message,
    required this.onRetry,
    this.title = 'Something went wrong',
    super.key,
  });

  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppStateView(
      icon: Icons.wifi_tethering_error_rounded,
      title: title,
      message: message,
      actionLabel: 'Retry',
      onAction: onRetry,
      tone: AppStateTone.error,
    );
  }
}

class AppOfflineBanner extends StatelessWidget {
  const AppOfflineBanner({this.syncing = false, super.key});

  final bool syncing;

  @override
  Widget build(BuildContext context) {
    final color = syncing ? ShipKiaColors.info : ShipKiaColors.warning;

    return AnimatedContainer(
      duration: ShipKiaMotion.duration(context, ShipKiaMotion.fast),
      curve: ShipKiaMotion.standard,
      padding: const EdgeInsets.symmetric(
        horizontal: ShipKiaSpacing.md,
        vertical: ShipKiaSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        border: Border(bottom: BorderSide(color: color.withValues(alpha: 0.2))),
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Row(
          children: [
            Icon(
              syncing ? Icons.sync : Icons.cloud_off_outlined,
              color: color,
              size: 16,
            ),
            const SizedBox(width: ShipKiaSpacing.sm),
            Expanded(
              child: Text(
                syncing
                    ? 'Syncing workspace changes.'
                    : "Offline. You're viewing cached data.",
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(color: color, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
