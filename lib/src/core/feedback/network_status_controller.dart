import 'dart:async';
import 'dart:io';

enum ShipKiaNetworkStatus { unknown, online, offline }

typedef ShipKiaConnectivityCheck = Future<bool> Function();

class ShipKiaNetworkStatusController {
  ShipKiaNetworkStatusController({
    ShipKiaConnectivityCheck? checkConnection,
    this._pollInterval = const Duration(seconds: 12),
    this._stabilizationDelay = const Duration(milliseconds: 1200),
  }) : _checkConnection = checkConnection ?? _defaultCheckConnection,
       assert(_pollInterval > Duration.zero),
       assert(_stabilizationDelay >= Duration.zero);

  final ShipKiaConnectivityCheck _checkConnection;
  final Duration _pollInterval;
  final Duration _stabilizationDelay;
  final _controller = StreamController<ShipKiaNetworkStatus>.broadcast();

  Timer? _pollTimer;
  Timer? _stabilizationTimer;
  ShipKiaNetworkStatus _status = ShipKiaNetworkStatus.unknown;
  var _isDisposed = false;

  ShipKiaNetworkStatus get status => _status;
  Stream<ShipKiaNetworkStatus> get stream => _controller.stream;

  void start() {
    if (_isDisposed) return;
    _pollTimer?.cancel();
    checkNow();
    _pollTimer = Timer.periodic(_pollInterval, (_) => checkNow());
  }

  Future<void> checkNow() async {
    if (_isDisposed) return;
    final isOnline = await _safeCheckConnection();
    if (_isDisposed) return;
    final next = isOnline
        ? ShipKiaNetworkStatus.online
        : ShipKiaNetworkStatus.offline;
    _scheduleStableStatus(next);
  }

  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _pollTimer?.cancel();
    _stabilizationTimer?.cancel();
    _controller.close();
  }

  Future<bool> _safeCheckConnection() async {
    try {
      return await _checkConnection().timeout(const Duration(seconds: 3));
    } catch (_) {
      return false;
    }
  }

  void _scheduleStableStatus(ShipKiaNetworkStatus next) {
    if (_isDisposed) return;
    if (next == _status) return;
    _stabilizationTimer?.cancel();
    _stabilizationTimer = Timer(_stabilizationDelay, () {
      if (_isDisposed) return;
      if (next == _status) return;
      _status = next;
      if (!_controller.isClosed) _controller.add(next);
    });
  }

  static Future<bool> _defaultCheckConnection() async {
    final result = await InternetAddress.lookup('example.com');
    return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
  }
}
