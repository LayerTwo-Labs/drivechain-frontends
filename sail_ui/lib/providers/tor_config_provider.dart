import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/rpcs/orchestrator_rpc.dart';

/// Surfaces the electrum wallet's Tor SOCKS5 routing config.
///
/// The orchestrator probes connectivity through the proxy on a switch and keeps
/// the previous config on failure, so this provider just forwards calls and
/// caches the current state.
class TorConfigProvider extends ChangeNotifier {
  final Logger _logger = GetIt.I.get<Logger>();
  OrchestratorRPC get _orch => GetIt.I.get<OrchestratorRPC>();

  bool _enabled = false;
  String _proxy = '';
  String _defaultProxy = '';
  bool _busy = false;
  String? _lastError;

  bool get enabled => _enabled;
  String get proxy => _proxy;
  String get defaultProxy => _defaultProxy;
  bool get busy => _busy;
  String? get lastError => _lastError;

  Future<void> refresh() async {
    try {
      final resp = await _orch.wallet.getTorConfig();
      _enabled = resp.enabled;
      _proxy = resp.proxy;
      _defaultProxy = resp.defaultProxy;
      _lastError = null;
      notifyListeners();
    } catch (e) {
      _logger.e('TorConfigProvider: get failed: $e');
      _lastError = e.toString();
      notifyListeners();
    }
  }

  /// Applies a Tor routing config. When enabling, an empty proxy uses the
  /// default. Returns the chain tip height on success, or null on failure (the
  /// previous config is kept; [lastError] holds the reason).
  Future<int?> apply(bool enabled, String proxy) async {
    if (_busy) return null;
    _busy = true;
    _lastError = null;
    notifyListeners();
    try {
      final resp = await _orch.wallet.setTorConfig(enabled, proxy);
      await refresh();
      return resp.tipHeight.toInt();
    } catch (e) {
      _logger.e('TorConfigProvider: set (enabled=$enabled, proxy="$proxy") failed: $e');
      _lastError = e.toString();
      return null;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
