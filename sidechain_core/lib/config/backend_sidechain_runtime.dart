import 'dart:async';
import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/classes/rpc_connection.dart';
import 'package:sidechain_core/config/binaries.dart';
import 'package:sidechain_core/providers/backend_state_provider.dart';
import 'package:sidechain_core/providers/binaries/binary_provider.dart';
import 'package:sidechain_core/providers/log_provider.dart';
import 'package:sidechain_core/providers/wallet_reader_provider.dart';
import 'package:sidechain_core/rpcs/orchestrator_rpc.dart';

Future<void> initBackendManagedSidechainRuntime({
  required Logger log,
  required BinaryType binary,
  RPCConnection? appRpc,
  String host = 'localhost',
  int port = 30400,
}) async {
  if (!GetIt.I.isRegistered<OrchestratorRPC>()) {
    GetIt.I.registerSingleton<OrchestratorRPC>(
      OrchestratorRPC(host: host, port: port),
    );
  }

  if (!GetIt.I.isRegistered<BackendStateProvider>()) {
    GetIt.I.registerSingleton<BackendStateProvider>(
      BackendStateProvider(GetIt.I.get<OrchestratorRPC>()),
    );
  }

  await bootBackendManagedSidechain(
    log: log,
    binary: binary,
    appRpc: appRpc,
  );
}

Future<void> bootBackendManagedSidechain({
  required Logger log,
  required BinaryType binary,
  RPCConnection? appRpc,
}) async {
  try {
    final binaryProvider = GetIt.I.get<BinaryProvider>();
    final orchestrator = GetIt.I.get<OrchestratorRPC>();
    final backendState = GetIt.I.get<BackendStateProvider>();
    final targetBinaryName = binaryTypeToJsonKey(binary);

    if (await _backendIsReady(orchestrator)) {
      log.i('bootBackendManagedSidechain: drivechaind already ready');
      // Cold-start funnels --binary=<target> into drivechaind's auto-boot
      // hook (cmd/drivechaind/main.go:336), but a hot-start lands here and
      // never tells anyone to bring the sidechain up. StartWithL1 on the Go
      // side is idempotent — bitcoind/enforcer get adopted via PID files and
      // the target sidechain is only spawned if it isn't already running —
      // so calling it unconditionally here is safe and necessary.
      unawaited(() async {
        try {
          // forceBackend: sidechain frontends always want the prod-download
          // binary for their own backend. Without this, a user who toggled
          // "Use test sidechains" in Bitwindow would have drivechaind
          // re-spawn another Flutter bundle here instead of the real node.
          await orchestrator.startWithL1(targetBinaryName, forceBackend: true);
        } catch (e) {
          log.w('bootBackendManagedSidechain: hot-start startWithL1($targetBinaryName) failed: $e');
        }
      }());
    } else {
      // Seed the app-level "initializing" state so DaemonConnectionCard
      // renders the spinner + startup log during the pre-drivechaind
      // phase of cold-boot rather than flashing "Not connected".
      // BackendStateProvider.startWatching() clears the flag once the
      // orchestrator's listBinaries poll starts reporting.
      if (appRpc != null) {
        appRpc.initializingBinary = true;
        appRpc.connectionError = null;
        appRpc.markStateChanged();
        binaryProvider.addStartupLogForBinary(appRpc.binaryType, 'Starting drivechaind...');
      }
      binaryProvider.addStartupLogForBinary(BinaryType.BINARY_TYPE_DRIVECHAIND, 'Starting drivechaind...');

      // Pass --binary flag so drivechaind auto-boots the sidechain with deps.
      // --force-backend pairs with it so the auto-boot skips the frontend build
      // (see hot-start path above for the rationale).
      final drivechaind = binaryProvider.binaries.firstWhere((b) => b.type == BinaryType.BINARY_TYPE_DRIVECHAIND);
      drivechaind.addBootArg('--binary=$targetBinaryName');
      drivechaind.addBootArg('--force-backend');
      // Detached from us, so it needs our pid to know when we are gone.
      drivechaind.addBootArg('--owner-pid=$pid');
      log.i('bootBackendManagedSidechain: starting drivechaind with --binary=$targetBinaryName --force-backend');
      await binaryProvider.start(drivechaind);

      log.i('bootBackendManagedSidechain: waiting for drivechaind readiness');
      if (appRpc != null) {
        binaryProvider.addStartupLogForBinary(appRpc.binaryType, 'Waiting for drivechaind...');
      }
      binaryProvider.addStartupLogForBinary(BinaryType.BINARY_TYPE_DRIVECHAIND, 'Waiting for drivechaind...');
      final ready = await _waitForBackendReady(orchestrator);
      if (!ready) {
        throw StateError('drivechaind did not become ready after 15s');
      }

      log.i('bootBackendManagedSidechain: drivechaind is ready');
      // Leave clearing the flag to BackendStateProvider — it owns the
      // authoritative connection state once the listBinaries poll is up.
    }

    _streamBinaryLogs(orchestrator, targetBinaryName, binary);
    _streamBinaryLogs(orchestrator, 'bitcoind', BinaryType.BINARY_TYPE_BITCOIND);
    _streamBinaryLogs(orchestrator, 'enforcer', BinaryType.BINARY_TYPE_ENFORCER);

    // Seed wallet state now that OrchestratorRPC is registered + reachable.
    // initSidechainDependencies registers the provider lazily but cannot
    // call init() itself — the seed RPC needs an OrchestratorRPC, and
    // standalone sidechain launches don't have one until we get here.
    if (GetIt.I.isRegistered<WalletReaderProvider>()) {
      unawaited(GetIt.I.get<WalletReaderProvider>().init());
    }

    log.i('bootBackendManagedSidechain: starting backend state watch');
    backendState.startWatching();
  } catch (e, st) {
    log.e('bootBackendManagedSidechain failed: $e\n$st');
  }
}

Future<bool> _backendIsReady(OrchestratorRPC orchestrator) async {
  try {
    await orchestrator.listBinaries();
    return true;
  } catch (_) {
    return false;
  }
}

Future<bool> _waitForBackendReady(OrchestratorRPC orchestrator) async {
  for (var i = 0; i < 30; i++) {
    if (await _backendIsReady(orchestrator)) {
      return true;
    }
    await Future.delayed(const Duration(milliseconds: 500));
  }

  return false;
}

void _streamBinaryLogs(OrchestratorRPC orchestrator, String binaryName, BinaryType binaryType) {
  final logProvider = GetIt.I.get<LogProvider>();

  orchestrator
      .streamLogs(binaryName, tail: 100)
      .listen(
        (response) {
          logProvider.addLog(
            FullProcessLogEntry(
              timestamp: DateTime.fromMillisecondsSinceEpoch(response.timestampUnix.toInt() * 1000),
              message: response.line,
              isStderr: response.stream == 'stderr',
              binaryType: binaryType,
            ),
          );
        },
        onError: (e) {
          Future.delayed(const Duration(seconds: 5), () {
            _streamBinaryLogs(orchestrator, binaryName, binaryType);
          });
        },
      );
}
