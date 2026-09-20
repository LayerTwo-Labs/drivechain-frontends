import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sidechain_core/gen/stratum/v1/stratum.pb.dart';
import 'package:sidechain_core/rpcs/orchestrator_stratum_rpc.dart';
import 'package:sidechain_core/sidechain_core.dart';

class _FakeStratum implements OrchestratorStratumRPC {
  GetStratumStatusResponse next = GetStratumStatusResponse();

  @override
  Future<GetStratumStatusResponse> status() async => next;

  @override
  Future<List<CatalogPool>> listPools() async => [];

  @override
  Future<GetHashrateHistoryResponse> hashrateHistory(HashrateRange range) async => GetHashrateHistoryResponse();

  @override
  Future<ListPoolBlocksResponse> listPoolBlocks({int limit = 0}) async => ListPoolBlocksResponse();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeOrchestrator implements OrchestratorRPC {
  _FakeOrchestrator(this.stratum);

  @override
  final OrchestratorStratumRPC stratum;

  int shutdowns = 0;

  @override
  Future<ShutdownResponse> shutdown({bool onlyIfLast = false}) async {
    shutdowns++;
    return ShutdownResponse();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<_FakeOrchestrator> _boot(GetStratumStatusResponse status) async {
  await GetIt.I.reset();
  final stratum = _FakeStratum()..next = status;
  final orchestrator = _FakeOrchestrator(stratum);
  GetIt.I.registerSingleton<OrchestratorRPC>(orchestrator);
  final provider = StratumProvider();
  GetIt.I.registerSingleton<StratumProvider>(provider);
  await provider.refresh();
  return orchestrator;
}

BinaryProvider _binaries() => BinaryProvider.test(appDir: Directory.systemTemp, binaries: []);

void main() {
  tearDown(() async {
    await GetIt.I.reset();
  });

  test('a running server with the setting on keeps drivechaind up', () async {
    final orchestrator = await _boot(
      GetStratumStatusResponse(running: true, settings: MiningSettings(keepMiningOnClose: true)),
    );

    expect(await _binaries().onShutdown(), isTrue);
    expect(orchestrator.shutdowns, 0);
  });

  test('a running server with the setting off shuts drivechaind down', () async {
    final orchestrator = await _boot(
      GetStratumStatusResponse(running: true, settings: MiningSettings(keepMiningOnClose: false)),
    );

    expect(await _binaries().onShutdown(), isTrue);
    expect(orchestrator.shutdowns, 1);
  });

  test('a stopped server shuts drivechaind down whatever the setting says', () async {
    final orchestrator = await _boot(
      GetStratumStatusResponse(settings: MiningSettings(keepMiningOnClose: true)),
    );

    expect(await _binaries().onShutdown(), isTrue);
    expect(orchestrator.shutdowns, 1);
  });

  test('an app with no stratum provider shuts drivechaind down', () async {
    await GetIt.I.reset();
    final orchestrator = _FakeOrchestrator(_FakeStratum());
    GetIt.I.registerSingleton<OrchestratorRPC>(orchestrator);

    expect(await _binaries().onShutdown(), isTrue);
    expect(orchestrator.shutdowns, 1);
  });
}
