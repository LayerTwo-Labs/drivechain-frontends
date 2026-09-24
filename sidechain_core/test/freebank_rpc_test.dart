import 'dart:io';

import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/sidechain_core.dart';

class _FakeOrchestrator implements OrchestratorRPC {
  final balanceReads = <BinaryType>[];
  final stops = <String>[];
  GetSidechainBalanceResponse balance = GetSidechainBalanceResponse();
  GetSyncStatusResponse syncStatus = GetSyncStatusResponse();

  @override
  Future<GetSidechainBalanceResponse> getSidechainBalance(BinaryType sidechain) async {
    balanceReads.add(sidechain);
    return balance;
  }

  @override
  Future<GetSyncStatusResponse> getSyncStatus() async => syncStatus;

  @override
  Future<StopBinaryResponse> stopBinary(String name, {bool force = false, bool forceBackend = false}) async {
    stops.add(name);
    return StopBinaryResponse();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

SidechainStatus _status(SidechainType type, {int blocks = 0, int headers = 0, String error = ''}) => SidechainStatus(
  type: type,
  sync: ChainSync(blocks: blocks, headers: headers, error: error),
);

void main() {
  late _FakeOrchestrator orchestrator;
  late FreeBankRPC rpc;

  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    orchestrator = _FakeOrchestrator();
    GetIt.I.registerSingleton<OrchestratorRPC>(orchestrator);
    rpc = FreeBankRPC();
    GetIt.I.registerSingleton<FreeBankRPC>(rpc);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  test('the balance is the orchestrator FreeBank balance', () async {
    orchestrator.balance = GetSidechainBalanceResponse(
      confirmedSats: Int64(250000000),
      pendingSats: Int64(1000000),
    );

    expect(await rpc.balance(), (2.5, 0.01));
    expect(orchestrator.balanceReads, [BinaryType.BINARY_TYPE_FREEBANK]);
  });

  test('the height is the FreeBank entry of the orchestrator sync status', () async {
    orchestrator.syncStatus = GetSyncStatusResponse(
      sidechains: [
        _status(SidechainType.SIDECHAIN_TYPE_THUNDER, blocks: 7, headers: 7),
        _status(SidechainType.SIDECHAIN_TYPE_FREEBANK, blocks: 80, headers: 90),
      ],
    );

    expect(await rpc.getBlockCount(), 80);
    final info = await rpc.getBlockchainInfo();
    expect(info.blocks, 80);
    expect(info.headers, 90);
    expect(info.initialBlockDownload, isTrue);
  });

  test('a node the orchestrator cannot read gives its reason, not a height', () async {
    orchestrator.syncStatus = GetSyncStatusResponse(
      sidechains: [_status(SidechainType.SIDECHAIN_TYPE_FREEBANK, error: 'not running')],
    );
    await expectLater(
      rpc.getBlockCount(),
      throwsA(isA<StateError>().having((e) => e.message, 'message', 'not running')),
    );

    orchestrator.syncStatus = GetSyncStatusResponse();
    await expectLater(rpc.getBlockchainInfo(), throwsStateError);
  });

  test('stop goes through the orchestrator', () async {
    await rpc.stopRPC();
    expect(orchestrator.stops, ['freebank']);
  });

  test('a call the orchestrator has no route for is unsupported', () async {
    await expectLater(rpc.getDepositAddress(), throwsUnsupportedError);
    await expectLater(rpc.getSideAddress(), throwsUnsupportedError);
    await expectLater(rpc.sideSend('addr', 1, false), throwsUnsupportedError);
    await expectLater(rpc.listTransactions(), throwsUnsupportedError);
    await expectLater(rpc.mine(1000), throwsUnsupportedError);
    await expectLater(rpc.getPendingWithdrawalBundle(), throwsUnsupportedError);
    await expectLater(rpc.withdraw('addr', 1000, 10, 10), throwsUnsupportedError);
    await expectLater(rpc.callRAW('getbalance'), throwsUnsupportedError);
    expect(rpc.getMethods(), isEmpty);
    expect(await rpc.binaryArgs(), isEmpty);
  });

  test('the binary state reads the FreeBank connection', () {
    final binaries = BinaryProvider.test(appDir: Directory.systemTemp, binaries: [FreeBank()]);
    GetIt.I.registerSingleton<BinaryProvider>(binaries);

    expect(binaries.isConnected(FreeBank()), isFalse);
    rpc.initializingBinary = true;
    expect(binaries.isInitializing(FreeBank()), isTrue);
    rpc
      ..initializingBinary = false
      ..connected = true;
    expect(binaries.isConnected(FreeBank()), isTrue);
    expect(binaries.isSidechainUp(FreeBank()), isTrue);
    rpc.stoppingBinary = true;
    expect(binaries.isStopping(FreeBank()), isTrue);
    rpc.connectionError = 'refused';
    expect(binaries.connectionError(FreeBank()), 'refused');
  });

  test('a stopped FreeBank reads no balance, a running one reads it once per fetch', () async {
    orchestrator.balance = GetSidechainBalanceResponse(confirmedSats: Int64(100000000));
    final balances = BalanceProvider(connections: [rpc]);
    addTearDown(balances.dispose);

    await balances.fetch();
    expect(orchestrator.balanceReads, isEmpty);

    rpc.connected = true;
    await balances.fetch();
    expect(orchestrator.balanceReads, [BinaryType.BINARY_TYPE_FREEBANK]);
    expect(balances.balanceFor(rpc), (1.0, 0.0));
  });
}
