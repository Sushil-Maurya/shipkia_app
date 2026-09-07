import 'package:flutter/material.dart';

import '../../design_system/design_system.dart';
import '../../theme/shipkia_colors.dart';
import 'feedback_event.dart';
import 'feedback_mapper.dart';
import 'feedback_messages.dart';

class ShipKiaFeedback {
  ShipKiaFeedback._();

  static final messengerKey = GlobalKey<ScaffoldMessengerState>();
  static final _lastShownAt = <String, DateTime>{};

  static const duplicateWindow = Duration(seconds: 3);

  static ShipKiaFeedbackEvent? _currentEvent;

  static void show(ShipKiaFeedbackEvent event) {
    final ScaffoldMessengerState? messenger;
    try {
      messenger = messengerKey.currentState;
    } on FlutterError {
      return;
    }
    if (messenger == null) return;
    if (_shouldSuppressDuplicate(event)) return;

    if (_currentEvent != null &&
        _currentEvent!.priority.index > event.priority.index) {
      return;
    }

    _currentEvent = event;
    _lastShownAt[event.duplicateKey] = DateTime.now();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(_snackBar(event)).closed.whenComplete(() {
        if (_currentEvent == event) _currentEvent = null;
      });
  }

  static void success(
    String message, {
    String? eventKey,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      ShipKiaFeedbackEvent(
        message: message,
        type: ShipKiaFeedbackType.success,
        priority: ShipKiaFeedbackPriority.success,
        eventKey: eventKey,
        actionLabel: actionLabel,
        onAction: onAction,
      ),
    );
  }

  static void error(
    String message, {
    String? eventKey,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      ShipKiaFeedbackEvent(
        message: message,
        type: ShipKiaFeedbackType.error,
        priority: ShipKiaFeedbackPriority.error,
        eventKey: eventKey,
        actionLabel: actionLabel,
        onAction: onAction,
      ),
    );
  }

  static void warning(String message, {String? eventKey}) {
    show(
      ShipKiaFeedbackEvent(
        message: message,
        type: ShipKiaFeedbackType.warning,
        priority: ShipKiaFeedbackPriority.warning,
        eventKey: eventKey,
      ),
    );
  }

  static void info(String message, {String? eventKey}) {
    show(
      ShipKiaFeedbackEvent(
        message: message,
        type: ShipKiaFeedbackType.info,
        priority: ShipKiaFeedbackPriority.info,
        eventKey: eventKey,
      ),
    );
  }

  static void offline() {
    show(
      const ShipKiaFeedbackEvent(
        message: ShipKiaFeedbackMessages.networkOffline,
        type: ShipKiaFeedbackType.warning,
        priority: ShipKiaFeedbackPriority.warning,
        eventKey: 'network-offline',
        duration: Duration(seconds: 5),
      ),
    );
  }

  static void online() {
    show(
      const ShipKiaFeedbackEvent(
        message: ShipKiaFeedbackMessages.networkRestored,
        type: ShipKiaFeedbackType.success,
        priority: ShipKiaFeedbackPriority.success,
        eventKey: 'network-restored',
      ),
    );
  }

  static void syncStarted() {
    info(ShipKiaFeedbackMessages.syncStarted, eventKey: 'sync-started');
  }

  static void syncCompleted() {
    success(ShipKiaFeedbackMessages.syncCompleted, eventKey: 'sync-completed');
  }

  static void syncFailed({VoidCallback? onRetry}) {
    error(
      ShipKiaFeedbackMessages.syncFailed,
      eventKey: 'sync-failed',
      actionLabel: onRetry == null ? null : 'Retry',
      onAction: onRetry,
    );
  }

  static void apiError(
    Object error, {
    int? statusCode,
    String? eventKey,
    String? userSafeMessage,
    VoidCallback? onRetry,
  }) {
    show(
      statusCode == null
          ? ShipKiaFeedbackMapper.fromException(
              error,
              eventKey: eventKey,
              onRetry: onRetry,
            )
          : ShipKiaFeedbackMapper.fromStatusCode(
              statusCode,
              eventKey: eventKey,
              userSafeMessage: userSafeMessage,
              onRetry: onRetry,
            ),
    );
  }

  static void copiedTrackingNumber() {
    success(
      ShipKiaFeedbackMessages.copiedTrackingNumber,
      eventKey: 'tracking-number-copied',
    );
  }

  @visibleForTesting
  static void resetForTesting() {
    _lastShownAt.clear();
    _currentEvent = null;
    messengerKey.currentState?.clearSnackBars();
  }

  static bool _shouldSuppressDuplicate(ShipKiaFeedbackEvent event) {
    final lastShown = _lastShownAt[event.duplicateKey];
    if (lastShown == null) return false;
    return DateTime.now().difference(lastShown) < duplicateWindow;
  }

  static SnackBar _snackBar(ShipKiaFeedbackEvent event) {
    return SnackBar(
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      duration: event.duration ?? _durationFor(event),
      backgroundColor: Colors.transparent,
      content: _ShipKiaSnackBarContent(event: event),
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.fromLTRB(
        ShipKiaSpacing.page,
        0,
        ShipKiaSpacing.page,
        ShipKiaSpacing.page,
      ),
    );
  }

  static Duration _durationFor(ShipKiaFeedbackEvent event) {
    if (event.onAction != null) return const Duration(seconds: 7);
    return switch (event.type) {
      ShipKiaFeedbackType.success => const Duration(seconds: 3),
      ShipKiaFeedbackType.info => const Duration(seconds: 3),
      ShipKiaFeedbackType.warning => const Duration(seconds: 5),
      ShipKiaFeedbackType.error => const Duration(seconds: 6),
    };
  }
}

class _ShipKiaSnackBarContent extends StatelessWidget {
  const _ShipKiaSnackBarContent({required this.event});

  final ShipKiaFeedbackEvent event;

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(event.type);

    return Semantics(
      liveRegion: true,
      label: '${event.type.name} notification. ${event.message}',
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          decoration: BoxDecoration(
            color: ShipKiaColors.surface(context),
            borderRadius: ShipKiaRadius.lgBorder,
            border: Border.all(color: color.withValues(alpha: 0.32)),
            boxShadow: ShipKiaElevation.overlay,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ShipKiaSpacing.md,
              vertical: ShipKiaSpacing.sm,
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: ShipKiaRadius.mdBorder,
                  ),
                  child: Icon(_iconFor(event.type), size: 18, color: color),
                ),
                const SizedBox(width: ShipKiaSpacing.md),
                Expanded(
                  child: Text(
                    event.message,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ShipKiaColors.textPrimary(context),
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                ),
                if (event.actionLabel != null && event.onAction != null) ...[
                  const SizedBox(width: ShipKiaSpacing.sm),
                  TextButton(
                    onPressed: () {
                      ShipKiaFeedback.messengerKey.currentState
                          ?.hideCurrentSnackBar();
                      event.onAction!();
                    },
                    child: Text(event.actionLabel!),
                  ),
                ],
                IconButton(
                  tooltip: 'Dismiss notification',
                  onPressed: () => ShipKiaFeedback.messengerKey.currentState
                      ?.hideCurrentSnackBar(),
                  icon: Icon(
                    Icons.close,
                    size: 18,
                    color: ShipKiaColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _colorFor(ShipKiaFeedbackType type) {
    return switch (type) {
      ShipKiaFeedbackType.success => ShipKiaColors.success,
      ShipKiaFeedbackType.error => ShipKiaColors.error,
      ShipKiaFeedbackType.warning => ShipKiaColors.warning,
      ShipKiaFeedbackType.info => ShipKiaColors.info,
    };
  }

  IconData _iconFor(ShipKiaFeedbackType type) {
    return switch (type) {
      ShipKiaFeedbackType.success => Icons.check_circle_outline,
      ShipKiaFeedbackType.error => Icons.error_outline,
      ShipKiaFeedbackType.warning => Icons.warning_amber_rounded,
      ShipKiaFeedbackType.info => Icons.info_outline,
    };
  }
}
