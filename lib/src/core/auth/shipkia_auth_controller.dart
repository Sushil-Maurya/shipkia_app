import 'package:flutter/foundation.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/data/auth_session.dart';
import '../api/api_token_provider.dart';

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
    this.authRepository,
    this.tokenProvider,
    ShipKiaAuthStatus initialStatus = ShipKiaAuthStatus.loading,
    Set<String>? permissions,
    this.restoreDelay = const Duration(milliseconds: 650),
  }) : _status = initialStatus,
       _permissions = permissions ?? _defaultPermissions;

  ShipKiaAuthStatus _status;
  Set<String> _permissions;
  final Duration restoreDelay;
  final AuthRepository? authRepository;
  final InMemoryApiTokenProvider? tokenProvider;
  bool _isSubmitting = false;
  AuthProfile? _profile;

  ShipKiaAuthStatus get status => _status;
  bool get isLoading => _status == ShipKiaAuthStatus.loading;
  bool get isAuthenticated => _status == ShipKiaAuthStatus.authenticated;
  bool get isSubmitting => _isSubmitting;
  Set<String> get permissions => Set.unmodifiable(_permissions);
  AuthProfile? get profile => _profile;

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
    await Future<void>.delayed(restoreDelay);
    _setStatus(ShipKiaAuthStatus.unauthenticated);
  }

  void signIn({Set<String>? permissions}) {
    _permissions = permissions ?? _defaultPermissions;
    _setStatus(ShipKiaAuthStatus.authenticated);
  }

  Future<void> login({required String email, required String password}) async {
    final repository = authRepository;
    if (repository == null) {
      signIn();
      return;
    }

    _setSubmitting(true);
    try {
      final session = await repository.login(email: email, password: password);
      tokenProvider?.setSessionId(session.session);
      signIn(
        permissions: session.permissions.isEmpty
            ? _defaultPermissions
            : session.permissions,
      );
      await _loadAuthenticatedProfile(repository);
    } finally {
      _setSubmitting(false);
    }
  }

  void signOut() {
    tokenProvider?.clear();
    _profile = null;
    _setStatus(ShipKiaAuthStatus.unauthenticated);
  }

  Future<void> logout() async {
    final repository = authRepository;
    if (repository == null) {
      signOut();
      return;
    }

    _setSubmitting(true);
    try {
      await repository.logout();
    } finally {
      _setSubmitting(false);
      signOut();
    }
  }

  void expireSession() {
    tokenProvider?.clear();
    _profile = null;
    _setStatus(ShipKiaAuthStatus.unauthenticated);
  }

  void setPermissions(Set<String> permissions) {
    _permissions = permissions;
    notifyListeners();
  }

  bool hasPermissions(Iterable<String> requiredPermissions) {
    return requiredPermissions.every(_permissions.contains);
  }

  Future<void> _loadAuthenticatedProfile(AuthRepository repository) async {
    final token = await repository.renewToken();
    tokenProvider
      ?..setAccessToken(token.accessToken)
      ..setSessionId(token.session);

    final profile = await repository.getProfile(accessToken: token.accessToken);
    _profile = profile;
    if (profile.roles.isNotEmpty) {
      _permissions = profile.roles.toSet();
    }
    notifyListeners();
  }

  void _setStatus(ShipKiaAuthStatus value) {
    if (_status == value) return;
    _status = value;
    notifyListeners();
  }

  void _setSubmitting(bool value) {
    if (_isSubmitting == value) return;
    _isSubmitting = value;
    notifyListeners();
  }
}
