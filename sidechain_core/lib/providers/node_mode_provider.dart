import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sidechain_core/sidechain_core.dart';

/// How much of Bitcoin this install runs. Full mode starts Bitcoin Core and the
/// enforcer locally. Light mode reads the chain from a remote server and starts
/// no daemon.
class NodeModeProvider extends ChangeNotifier implements NetworkScoped {
  final Logger _logger = GetIt.I.get<Logger>();
  OrchestratorWalletRPC get _client => GetIt.I.get<OrchestratorRPC>().wallet;

  wmpb.NodeMode mode = wmpb.NodeMode.NODE_MODE_UNSPECIFIED;

  /// False on a network with no remote chain server. Regtest and testnet.
  bool lightModeAvailable = true;

  /// True once a read reaches the backend. A failed read is not an unpicked
  /// mode, so the first-run question waits for this.
  bool loaded = false;

  /// True until the user picks. The app must ask before it boots anything.
  bool get needsChoice => mode == wmpb.NodeMode.NODE_MODE_UNSPECIFIED;

  bool get isLight => mode == wmpb.NodeMode.NODE_MODE_LIGHT;
  bool get isFull => mode == wmpb.NodeMode.NODE_MODE_FULL;

  /// True when this install runs Bitcoin Core and the enforcer locally. The one
  /// predicate every backend-dependent surface reads, so none of them can drift
  /// from the mode the user picked.
  ///
  /// A sidechain app runs full mode by definition: it has its own backends and
  /// registers no node mode, so it reads true. An unpicked mode reads false —
  /// nothing boots until the user chooses.
  static bool get runsLocalBackends {
    if (!GetIt.I.isRegistered<NodeModeProvider>()) {
      return true;
    }
    return GetIt.I.get<NodeModeProvider>().isFull;
  }

  Future<void> load() async {
    try {
      final resp = await _client.getNodeMode();
      mode = resp.mode;
      lightModeAvailable = resp.lightModeAvailable;
      loaded = true;
      notifyListeners();
    } catch (e) {
      // A failed read is not an unpicked mode. Clearing it here would drop a
      // full-mode install to the light-mode UI and skip the L1 boot, on
      // nothing worse than an orchestrator restart.
      _logger.w('NodeModeProvider: read failed, keeping $mode: $e');
    }
  }

  /// Records the choice, then brings the daemons in step with it. Without the
  /// second half a first full-mode choice starts nothing until the next launch,
  /// and a switch to light leaves the local node running.
  Future<void> select(wmpb.NodeMode next) async {
    final previous = mode;
    await _client.setNodeMode(next);
    mode = next;
    loaded = true;
    notifyListeners();

    if (next == previous) {
      return;
    }
    try {
      final orchestrator = GetIt.I.get<OrchestratorRPC>();
      if (next == wmpb.NodeMode.NODE_MODE_FULL) {
        await orchestrator.startWithL1('enforcer');
      } else {
        await orchestrator.shutdownAll().drain<void>();
      }
    } catch (e) {
      // The mode is on disk either way, so the next launch obeys it.
      _logger.w('NodeModeProvider: could not bring the daemons in step: $e');
    }
  }

  /// A network change moves both facts: regtest and testnet serve no remote
  /// chain, so the backend narrows light mode to full there.
  @override
  Future<void> onNetworkChanged() => load();
}
