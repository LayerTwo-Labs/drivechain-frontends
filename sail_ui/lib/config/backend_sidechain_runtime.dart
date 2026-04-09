import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/providers/backend_state_provider.dart';
import 'package:sail_ui/providers/binaries/binary_provider.dart';
import 'package:sail_ui/providers/log_provider.dart';
import 'package:sail_ui/rpcs/orchestratord_rpc.dart';
import 'package:sail_ui/rpcs/orchestrator_rpc.dart';

Future<void> initBackendManagedSidechainRuntime({
  required Logger log,
  required BinaryType binary,
  String host = 'localhost',
  int port = 30400,
}) async {
  if (!GetIt.I.isRegistered<OrchestratorRPC>()) {
    GetIt.I.registerSingleton<OrchestratorRPC>(
      OrchestratorRPC(host: host, port: port),
    );
  }

  if (!GetIt.I.isRegistered<OrchestratordRPC>()) {
    GetIt.I.registerSingleton<OrchestratordRPC>(OrchestratordLive());
  }

  if (!GetIt.I.isRegistered<BackendStateProvider>()) {
    GetIt.I.registerSingleton<BackendStateProvider>(
      BackendStateProvider(GetIt.I.get<OrchestratorRPC>()),
    );
  }

  await bootBackendManagedSidechain(
    log: log,
    binary: binary,
  );
}

Future<void> bootBackendManagedSidechain({
  required Logger log,
  required BinaryType binary,
}) async {
  try {
    final binaryProvider = GetIt.I.get<BinaryProvider>();
    final orchestrator = GetIt.I.get<OrchestratorRPC>();
    final backendState = GetIt.I.get<BackendStateProvider>();
    final targetBinaryName = binaryTypeToJsonKey(binary);

    if (await _backendIsReady(orchestrator)) {
      log.i('bootBackendManagedSidechain: orchestratord already ready');
    } else {
      // Pass --binary flag so orchestratord auto-boots the sidechain with deps
      final orchestratord = binaryProvider.binaries.firstWhere((b) => b.type == BinaryType.orchestratord);
      orchestratord.addBootArg('--binary=$targetBinaryName');
      log.i('bootBackendManagedSidechain: starting orchestratord with --binary=$targetBinaryName');
      await binaryProvider.start(orchestratord);

      log.i('bootBackendManagedSidechain: waiting for orchestratord readiness');
      final ready = await _waitForBackendReady(orchestrator);
      if (!ready) {
        throw StateError('orchestratord did not become ready after 15s');
      }

      log.i('bootBackendManagedSidechain: orchestratord is ready');
    }

    _streamBinaryLogs(orchestrator, targetBinaryName, binary);
    _streamBinaryLogs(orchestrator, 'bitcoind', BinaryType.bitcoinCore);
    _streamBinaryLogs(orchestrator, 'enforcer', BinaryType.enforcer);

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
  final log = GetIt.I.get<Logger>();

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

          log.i('[$binaryName] ${response.line}');
        },
        onError: (e) {
          Future.delayed(const Duration(seconds: 5), () {
            _streamBinaryLogs(orchestrator, binaryName, binaryType);
          });
        },
      );
}
