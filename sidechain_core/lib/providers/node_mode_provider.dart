import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sidechain_core/sidechain_core.dart';

/// Keeps the node mode and network service support.
class NodeModeProvider extends ChangeNotifier implements NetworkScoped {
  final Logger _logger = GetIt.I.get<Logger>();
  OrchestratorWalletRPC get _client => GetIt.I.get<OrchestratorRPC>().wallet;

  wmpb.NodeMode mode = wmpb.NodeMode.NODE_MODE_UNSPECIFIED;

  /// True when the network supports light mode.
  bool lightModeAvailable = true;

  bool remoteEnforcerAvailable = false;

  /// Display names of the networks with a remote validator endpoint.
  List<String> remoteEnforcerNetworks = const [];

  /// True once a read reaches the backend. A failed read is not an unpicked
  /// mode, so the first-run question waits for this.
  bool loaded = false;

  /// True until the user picks. The app must ask before it boots anything.
  bool get needsChoice => mode == wmpb.NodeMode.NODE_MODE_UNSPECIFIED;

  bool get isLight => mode == wmpb.NodeMode.NODE_MODE_LIGHT;
  bool get isFull => mode == wmpb.NodeMode.NODE_MODE_FULL;

  bool get usesEnforcer => isFull || Binary.isSidechainApp || (isLight && remoteEnforcerAvailable);

  /// True when this install runs Bitcoin Core and the enforcer locally. The one
  /// predicate every backend-dependent surface reads, so none of them can drift
  /// from the mode the user picked.
  ///
  /// bitwindow shows a mode gate, so an unpicked mode boots nothing until the
  /// user answers. A sidechain app shows no gate, so it keeps the backends it
  /// always had, which is what the orchestrator starts for an unset mode.
  static bool get runsLocalBackends {
    if (!GetIt.I.isRegistered<NodeModeProvider>()) {
      return true;
    }
    final provider = GetIt.I.get<NodeModeProvider>();
    if (provider.needsChoice) {
      return Binary.isSidechainApp;
    }
    return provider.isFull;
  }

  Future<void> load() async {
    try {
      final resp = await _client.getNodeMode();
      mode = resp.mode;
      lightModeAvailable = resp.lightModeAvailable;
      remoteEnforcerAvailable = resp.remoteEnforcerAvailable;
      remoteEnforcerNetworks = List.unmodifiable(resp.remoteEnforcerNetworks);
      loaded = true;
      notifyListeners();
    } catch (e) {
      // A failed read is not an unpicked mode. Clearing it here would drop a
      // full-mode install to the light-mode UI and skip the L1 boot, on
      // nothing worse than an orchestrator restart.
      _logger.w('NodeModeProvider: read failed, keeping $mode: $e');
    }
  }

  /// Records the mode and starts its enforcer when necessary.
  Future<void> select(wmpb.NodeMode next) async {
    await _client.setNodeMode(next);
    mode = next;
    loaded = true;
    notifyListeners();

    if (!usesEnforcer) {
      return;
    }
    final orchestrator = GetIt.I.get<OrchestratorRPC>();
    if (next == wmpb.NodeMode.NODE_MODE_FULL) {
      final conf = GetIt.I.get<BitcoinConfProvider>();
      await conf.loadConfig();
      if (conf.mustSelectDatadir) {
        return;
      }
    }
    await orchestrator.startWithL1('enforcer');
  }

  /// Reads the mode and service support after a network change.
  @override
  Future<void> onNetworkChanged() => load();
}
