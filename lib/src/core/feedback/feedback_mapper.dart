import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'feedback_event.dart';

enum ShipKiaApiFailureType {
  validation,
  authentication,
  permission,
  notFound,
  timeout,
  conflict,
  rateLimited,
  cancelled,
  server,
  network,
  unknown,
}

class ShipKiaFeedbackMapper {
  const ShipKiaFeedbackMapper._();

  static ShipKiaFeedbackEvent fromStatusCode(
    int? statusCode, {
    String? eventKey,
    String? userSafeMessage,
    VoidCallback? onRetry,
  }) {
    final type = failureTypeForStatusCode(statusCode);
    return fromFailureType(
      type,
      eventKey: eventKey,
      userSafeMessage: userSafeMessage,
      onRetry: onRetry,
    );
  }

  static ShipKiaFeedbackEvent fromException(
    Object error, {
    String? eventKey,
    VoidCallback? onRetry,
  }) {
    final type = error is SocketException || error is TimeoutException
        ? ShipKiaApiFailureType.network
        : ShipKiaApiFailureType.unknown;
    return fromFailureType(type, eventKey: eventKey, onRetry: onRetry);
  }

  static ShipKiaApiFailureType failureTypeForStatusCode(int? statusCode) {
    if (statusCode == null) return ShipKiaApiFailureType.unknown;

    return switch (statusCode) {
      400 || 422 => ShipKiaApiFailureType.validation,
      401 => ShipKiaApiFailureType.authentication,
      403 => ShipKiaApiFailureType.permission,
      404 => ShipKiaApiFailureType.notFound,
      408 => ShipKiaApiFailureType.timeout,
      409 => ShipKiaApiFailureType.conflict,
      429 => ShipKiaApiFailureType.rateLimited,
      >= 500 && < 600 => ShipKiaApiFailureType.server,
      _ => ShipKiaApiFailureType.unknown,
    };
  }

  static ShipKiaFeedbackEvent fromFailureType(
    ShipKiaApiFailureType type, {
    String? eventKey,
    String? userSafeMessage,
    VoidCallback? onRetry,
  }) {
    final message = _isUserSafe(userSafeMessage)
        ? userSafeMessage!
        : switch (type) {
            ShipKiaApiFailureType.validation =>
              'Please check the highlighted fields.',
            ShipKiaApiFailureType.authentication =>
              'Your session has expired. Please sign in again.',
            ShipKiaApiFailureType.permission =>
              "You don't have permission to perform this action.",
            ShipKiaApiFailureType.notFound =>
              'The requested shipment could not be found.',
            ShipKiaApiFailureType.timeout =>
              'The request took too long. Please try again.',
            ShipKiaApiFailureType.conflict =>
              'This shipment was updated elsewhere. Refresh and try again.',
            ShipKiaApiFailureType.rateLimited =>
              'Too many requests. Please wait a moment.',
            ShipKiaApiFailureType.cancelled => 'The request was cancelled.',
            ShipKiaApiFailureType.server =>
              'Something went wrong on our server. Please try again.',
            ShipKiaApiFailureType.network =>
              "You're offline. Please check your connection.",
            ShipKiaApiFailureType.unknown =>
              'Something went wrong. Please try again.',
          };

    return ShipKiaFeedbackEvent(
      message: message,
      type: type == ShipKiaApiFailureType.validation
          ? ShipKiaFeedbackType.warning
          : ShipKiaFeedbackType.error,
      priority: type == ShipKiaApiFailureType.authentication
          ? ShipKiaFeedbackPriority.critical
          : ShipKiaFeedbackPriority.error,
      eventKey: eventKey,
      actionLabel: onRetry == null ? null : 'Retry',
      onAction: onRetry,
    );
  }

  static bool _isUserSafe(String? message) {
    if (message == null || message.trim().isEmpty) return false;
    final value = message.toLowerCase();
    return !value.contains('exception') &&
        !value.contains('stack') &&
        !value.contains('http ') &&
        !value.contains('socket') &&
        !value.contains('dio');
  }
}
