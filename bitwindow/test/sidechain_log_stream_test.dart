import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/config/backend_sidechain_runtime.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wallet;
import 'package:sidechain_core/sidechain_core.dart';

void main() {
  late _FakeOrchestrator orchestrator;
  late Logger log;

  setUp(() async {
    await GetIt.I.reset();
    NetworkScopedRegistry.clearRegistrations();
    log = Logger(level: Level.off);
    orchestrator = _FakeOrchestrator();
    GetIt.I.registerSingleton<Logger>(log);
    GetIt.I.registerSingleton<OrchestratorRPC>(orchestrator);
    GetIt.I.registerSingleton<LogProvider>(LogProvider());
    GetIt.I.registerSingleton<BinaryProvider>(_FakeBinaryProvider());
    GetIt.I.registerSingleton<BackendStateProvider>(_FakeBackendState());
  });

  tearDown(() async {
    NetworkScopedRegistry.clearRegistrations();
    await GetIt.I.reset();
  });

  test('a clean end opens one new stream after five seconds', () {
    fakeAsync((async) {
      unawaited(bootBackendManagedSidechain(log: log, binary: BinaryType.BINARY_TYPE_THUNDER));
      async.flushMicrotasks();
      expect(orchestrator.requests.map((request) => request.name), ['thunder', 'bitcoind', 'enforcer']);

      async.elapse(const Duration(seconds: 5));
      expect(orchestrator.requests.where((request) => request.name == 'thunder'), hasLength(2));
      expect(orchestrator.requests.where((request) => request.name == 'bitcoind'), hasLength(2));
      expect(orchestrator.requests.where((request) => request.name == 'enforcer'), hasLength(2));
    });
  });

  test('an error and a close open one new stream', () {
    fakeAsync((async) {
      orchestrator.failFirst = true;
      unawaited(bootBackendManagedSidechain(log: log, binary: BinaryType.BINARY_TYPE_THUNDER));
      async.flushMicrotasks();
      async.elapse(const Duration(seconds: 5));

      expect(orchestrator.requests.where((request) => request.name == 'thunder'), hasLength(2));
    });
  });

  test('each stream keeps its cursor across retries and replaces it for a new run', () {
    fakeAsync((async) {
      orchestrator.outputs['thunder'] = [
        [
          StreamLogsResponse(runId: 'first', sequence: Int64(7), line: 'same line'),
          StreamLogsResponse(runId: 'first', sequence: Int64(8), line: 'same line'),
        ],
        [StreamLogsResponse(runId: 'second', sequence: Int64(1), line: 'startup line')],
      ];
      orchestrator.outputs['bitcoind'] = [
        [StreamLogsResponse(runId: 'core', sequence: Int64(20))],
      ];
      unawaited(bootBackendManagedSidechain(log: log, binary: BinaryType.BINARY_TYPE_THUNDER));
      async.flushMicrotasks();
      async.elapse(const Duration(seconds: 5));

      final first = orchestrator.requests.lastWhere((request) => request.name == 'thunder');
      final core = orchestrator.requests.lastWhere((request) => request.name == 'bitcoind');
      expect((first.runId, first.afterSequence, first.tail), ('first', Int64(8), 100));
      expect((core.runId, core.afterSequence), ('core', Int64(20)));

      async.elapse(const Duration(seconds: 5));
      final second = orchestrator.requests.lastWhere((request) => request.name == 'thunder');
      expect((second.runId, second.afterSequence, second.tail), ('second', Int64(1), 100));
      expect(
        GetIt.I.get<LogProvider>().getLogsForBinary(BinaryType.BINARY_TYPE_THUNDER).map((entry) => entry.message),
        ['same line', 'same line', 'startup line'],
      );
    });
  });
}

class _FakeOrchestrator implements OrchestratorRPC {
  final requests = <StreamLogsRequest>[];
  final outputs = <String, List<List<StreamLogsResponse>>>{};
  bool failFirst = false;

  @override
  final wallet = _FakeWallet();

  @override
  Future<ListBinariesResponse> listBinaries({bool forceBackend = false}) async => ListBinariesResponse();

  @override
  Future<StartWithL1Response> startWithL1(
    String target, {
    List<String>? targetArgs,
    Map<String, String>? targetEnv,
    List<String>? coreArgs,
    List<String>? enforcerArgs,
    bool immediate = false,
    bool forceBackend = false,
  }) async => StartWithL1Response();

  @override
  Stream<StreamLogsResponse> streamLogs(String name, {int tail = 0, String runId = '', Int64? afterSequence}) {
    requests.add(StreamLogsRequest(name: name, tail: tail, runId: runId, afterSequence: afterSequence));
    if (failFirst) {
      failFirst = false;
      return Stream<StreamLogsResponse>.error(Exception('the backend closed the connection'));
    }
    final batches = outputs[name];
    return Stream<StreamLogsResponse>.fromIterable(batches == null || batches.isEmpty ? [] : batches.removeAt(0));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeWallet implements OrchestratorWalletRPC {
  @override
  Future<wallet.GetNodeModeResponse> getNodeMode() async => wallet.GetNodeModeResponse();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeBinaryProvider implements BinaryProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeBackendState implements BackendStateProvider {
  @override
  void startWatching() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
