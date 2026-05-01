import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:sail_ui/gen/orchestrator/v1/orchestrator.pb.dart' as orch_pb;
import 'package:sail_ui/sail_ui.dart';

/// Connection-state holder for Bitcoin Core. Owns:
///
///  - the standard [RPCConnection] flags (connected, startupError, ...)
///    that the daemon-status card binds against;
///  - IBD flags (`inIBD`/`inHeaderSync`/`inSync`) driven by orchestrator's
///    `WatchBinaries.blockchain_sync` via [applyBackendSync];
///  - [binaryArgs] for the chain-settings-modal launch path.
///
/// **No RPC client** — orchestratord's `BitcoinService` is the canonical
/// bitcoind proxy. All bitcoind RPCs go through `OrchestratorRPC.bitcoind`
/// (or, for methods btc-buf doesn't type, `OrchestratorRPC.coreRawCall`).
class BitcoindConnection extends RPCConnection {
  BitcoindConnection() : super(binaryType: BinaryType.bitcoinCore);

  // IBD state mirrors what the orchestrator tells us via WatchBinaries.
  // [applyBackendSync] is the single mutation point, called from
  // BackendStateProvider whenever the stream pushes new state.
  bool inIBD = true;
  bool inHeaderSync = true;
  // Misnamed historically: true while *syncing*, false when fully caught up.
  bool inSync = true;

  /// Mirror the orchestrator's blockchain_sync field onto our IBD flags.
  /// Pass null when the backend hasn't reported a sample yet — flags reset
  /// to the initial "still syncing" state so UI shows the loading affordance.
  void applyBackendSync(orch_pb.BlockchainSyncMsg? sync) {
    final bool nextHeaderSync;
    final bool nextIBD;
    final bool nextSync;
    if (sync == null) {
      nextHeaderSync = true;
      nextIBD = true;
      nextSync = true;
    } else {
      nextHeaderSync = sync.inHeaderSync;
      nextIBD = nextHeaderSync || sync.initialBlockDownload;
      nextSync = nextIBD || sync.blocks != sync.headers;
    }

    if (nextHeaderSync == inHeaderSync && nextIBD == inIBD && nextSync == inSync) {
      return;
    }
    inHeaderSync = nextHeaderSync;
    inIBD = nextIBD;
    inSync = nextSync;
    notifyListeners();
  }

  @override
  Future<List<String>> binaryArgs() async {
    final coreBinary = GetIt.I.get<BinaryProvider>().binaries.where((b) => b.name == binary.name).first;

    final List<String> args = [];

    try {
      // Pass `-conf=...` so bitcoind picks up our managed conf. If the file
      // is missing (typically after a reset), recreate it from defaults.
      final confFile = BitcoinCore().confFile();
      if (!File(confFile).existsSync()) {
        log.w('Config file missing ($confFile), recreating');
        await GetIt.I.get<BitcoinConfProvider>().loadConfig();
      }
      args.add('-conf=$confFile');
    } catch (error) {
      log.w('could not read conf file to get core binary args: $error');
    }

    args.addAll(coreBinary.extraBootArgs);

    // -reindex is a one-shot recovery flag; consume it after first use so
    // subsequent boots don't keep paying the reindex cost.
    if (coreBinary.extraBootArgs.contains('-reindex')) {
      coreBinary.extraBootArgs = List<String>.from(coreBinary.extraBootArgs)..remove('-reindex');
      GetIt.I.get<BinaryProvider>().updateBinary(coreBinary.type, (current) {
        final updated = current.copyWith();
        updated.extraBootArgs = coreBinary.extraBootArgs;
        return updated;
      });
    }

    return args;
  }

  // RPCConnection abstracts. No live bitcoind callers — orchestratord's
  // BitcoinService is the canonical proxy.
  @override
  Future<void> stopRPC() async {
    throw UnsupportedError('bitcoind shutdown routes via orchestrator');
  }

  @override
  Future<(double, double)> balance() async {
    throw UnsupportedError('use orchestrator.bitcoind wallet RPCs');
  }

  @override
  Future<BlockchainInfo> getBlockchainInfo() async {
    throw UnsupportedError('use OrchestratorRPC.getMainchainBlockchainInfo or applyBackendSync flags');
  }
}
