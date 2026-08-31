import 'package:flutter/material.dart';

enum ShipKiaFeedbackType { success, error, warning, info }

enum ShipKiaFeedbackPriority { info, success, warning, error, critical }

class ShipKiaFeedbackEvent {
  const ShipKiaFeedbackEvent({
    required this.message,
    required this.type,
    required this.priority,
    this.eventKey,
    this.actionLabel,
    this.onAction,
    this.duration,
  });

  final String message;
  final ShipKiaFeedbackType type;
  final ShipKiaFeedbackPriority priority;
  final String? eventKey;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Duration? duration;

  String get duplicateKey => '${eventKey ?? message}:$type';
}
