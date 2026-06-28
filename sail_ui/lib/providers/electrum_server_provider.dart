import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/rpcs/orchestrator_rpc.dart';

/// Surfaces the electrum wallet's Esplora server selection.
///
/// The orchestrator validates connectivity on a switch and keeps the previous
/// server on failure, so this provider just forwards calls and caches the
/// current/default endpoint.
class ElectrumServerProvider extends ChangeNotifier {
  final Logger _logger = GetIt.I.get<Logger>();
  OrchestratorRPC get _orch => GetIt.I.get<OrchestratorRPC>();

  String _url = '';
  String _defaultUrl = '';
  bool _isOverride = false;
  bool _busy = false;
  String? _lastError;

  String get url => _url;
  String get defaultUrl => _defaultUrl;
  bool get isOverride => _isOverride;
  bool get busy => _busy;
  String? get lastError => _lastError;

  Future<void> refresh() async {
    try {
      final resp = await _orch.wallet.getElectrumServer();
      _url = resp.url;
      _defaultUrl = resp.defaultUrl;
      _isOverride = resp.isOverride;
      _lastError = null;
      notifyListeners();
    } catch (e) {
      _logger.e('ElectrumServerProvider: get failed: $e');
      _lastError = e.toString();
      notifyListeners();
    }
  }

  /// Switches the Esplora endpoint. Pass an empty url to reset to the network
  /// default. Returns the chain tip height on success, or null on failure (the
  /// previous server is kept; [lastError] holds the reason).
  Future<int?> setServer(String url) async {
    if (_busy) return null;
    _busy = true;
    _lastError = null;
    notifyListeners();
    try {
      final resp = await _orch.wallet.setElectrumServer(url);
      await refresh();
      return resp.tipHeight.toInt();
    } catch (e) {
      _logger.e('ElectrumServerProvider: set "$url" failed: $e');
      _lastError = e.toString();
      return null;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
