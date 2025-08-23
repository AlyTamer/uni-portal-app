import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();

  final _controller = StreamController<bool>.broadcast();
  Stream<bool> get onlineStream => _controller.stream;

  // NOTE: v6 uses a *list* of results
  StreamSubscription<List<ConnectivityResult>>? _connSub;
  StreamSubscription<InternetConnectionStatus>? _netSub;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  final InternetConnectionCheckerPlus _checker = InternetConnectionCheckerPlus();

  void init() {
    // 1) Interface changes (wifi/cell). v6 delivers a list.
    _connSub ??= Connectivity().onConnectivityChanged.listen((results) async {
      final hasInterface = results.any((r) => r != ConnectivityResult.none);
      // Only report online if there’s an interface *and* actual reachability.
      final reachable = await _checker.hasConnection;
      _update(hasInterface && reachable);
    });

    // 2) Reachability (DNS/ping) changes from the checker itself.
    _netSub ??= _checker.onStatusChange.listen((status) {
      _update(status == InternetConnectionStatus.connected);
    });

    // 3) Seed initial value
    _seedInitial();
  }

  Future<void> _seedInitial() async {
    final results = await Connectivity().checkConnectivity(); // v6 returns List<ConnectivityResult>
    final hasInterface = results.any((r) => r != ConnectivityResult.none);
    final reachable = await _checker.hasConnection;
    _update(hasInterface && reachable);
  }

  void _update(bool online) {
    if (_isOnline != online) {
      _isOnline = online;
      _controller.add(online);
    }
  }

  void dispose() {
    _connSub?.cancel();
    _netSub?.cancel();
    _controller.close();
  }
}
