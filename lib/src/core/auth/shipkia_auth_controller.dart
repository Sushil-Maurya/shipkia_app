import 'package:flutter/foundation.dart';

enum ShipKiaAuthStatus { loading, authenticated, unauthenticated }

abstract final class ShipKiaPermissions {
  static const ordersView = 'orders.view';
  static const ordersCreate = 'orders.create';
  static const ordersEdit = 'orders.edit';
  static const shipmentsView = 'shipments.view';
  static const trackingView = 'tracking.view';
  static const walletView = 'wallet.view';
}

class ShipKiaAuthController extends ChangeNotifier {
  ShipKiaAuthController({
    ShipKiaAuthStatus initialStatus = ShipKiaAuthStatus.loading,
    Set<String>? permissions,
    Duration restoreDelay = const Duration(milliseconds: 650),
  }) : _status = initialStatus,
       _permissions = permissions ?? _defaultPermissions,
       _restoreDelay = restoreDelay;

  ShipKiaAuthStatus _status;
  Set<String> _permissions;
  final Duration _restoreDelay;

  ShipKiaAuthStatus get status => _status;
  bool get isLoading => _status == ShipKiaAuthStatus.loading;
  bool get isAuthenticated => _status == ShipKiaAuthStatus.authenticated;
  Set<String> get permissions => Set.unmodifiable(_permissions);

  static const _defaultPermissions = {
    ShipKiaPermissions.ordersView,
    ShipKiaPermissions.ordersCreate,
    ShipKiaPermissions.ordersEdit,
    ShipKiaPermissions.shipmentsView,
    ShipKiaPermissions.trackingView,
    ShipKiaPermissions.walletView,
  };

  Future<void> restoreSession() async {
    if (_status != ShipKiaAuthStatus.loading) return;
    await Future<void>.delayed(_restoreDelay);
    _setStatus(ShipKiaAuthStatus.unauthenticated);
  }

  void signIn({Set<String>? permissions}) {
    _permissions = permissions ?? _defaultPermissions;
    _setStatus(ShipKiaAuthStatus.authenticated);
  }

  void signOut() {
    _setStatus(ShipKiaAuthStatus.unauthenticated);
  }

  void expireSession() {
    _setStatus(ShipKiaAuthStatus.unauthenticated);
  }

  void setPermissions(Set<String> permissions) {
    _permissions = permissions;
    notifyListeners();
  }

  bool hasPermissions(Iterable<String> requiredPermissions) {
    return requiredPermissions.every(_permissions.contains);
  }

  void _setStatus(ShipKiaAuthStatus value) {
    if (_status == value) return;
    _status = value;
    notifyListeners();
  }
}

