import 'dart:async';

import 'package:flutter/material.dart';

import '../../design_system/design_system.dart';
import 'network_status_controller.dart';
import 'shipkia_feedback.dart';

class ShipKiaFeedbackHost extends StatefulWidget {
  const ShipKiaFeedbackHost({
    required this.child,
    this._networkController,
    super.key,
  });

  final Widget child;
  final ShipKiaNetworkStatusController? _networkController;

  @override
  State<ShipKiaFeedbackHost> createState() => _ShipKiaFeedbackHostState();
}

class _ShipKiaFeedbackHostState extends State<ShipKiaFeedbackHost> {
  late final ShipKiaNetworkStatusController _networkController;
  StreamSubscription<ShipKiaNetworkStatus>? _networkSubscription;
  ShipKiaNetworkStatus _status = ShipKiaNetworkStatus.unknown;
  var _hasSeenOnline = false;

  @override
  void initState() {
    super.initState();
    _networkController =
        widget._networkController ?? ShipKiaNetworkStatusController();
    _networkSubscription = _networkController.stream.listen(_handleStatus);
    _networkController.start();
  }

  @override
  void dispose() {
    _networkSubscription?.cancel();
    _networkController.dispose();
    super.dispose();
  }

  void _handleStatus(ShipKiaNetworkStatus status) {
    if (!mounted || status == _status) return;
    final previous = _status;
    setState(() => _status = status);

    if (status == ShipKiaNetworkStatus.offline) {
      ShipKiaFeedback.offline();
      return;
    }

    if (status == ShipKiaNetworkStatus.online) {
      final restoredFromOffline = previous == ShipKiaNetworkStatus.offline;
      if (restoredFromOffline || _hasSeenOnline) {
        ShipKiaFeedback.online();
      }
      _hasSeenOnline = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOffline = _status == ShipKiaNetworkStatus.offline;

    return Stack(
      children: [
        widget.child,
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: SafeArea(
            bottom: false,
            child: AppAnimatedSwitcher(
              child: isOffline
                  ? const AppOfflineBanner(key: ValueKey('offline-banner'))
                  : const SizedBox.shrink(key: ValueKey('online-banner')),
            ),
          ),
        ),
      ],
    );
  }
}
