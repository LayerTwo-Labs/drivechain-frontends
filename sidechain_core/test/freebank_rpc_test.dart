import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/sidechain_core.dart';

class _FakeOrchestrator implements OrchestratorRPC {
  final balanceReads = <BinaryType>[];
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
    rpc = FreeBankLive();
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

  test('a call the orchestrator does not serve is unsupported', () async {
    await expectLater(rpc.getDepositAddress(), throwsUnsupportedError);
    await expectLater(rpc.sideSend('addr', 1, false), throwsUnsupportedError);
    await expectLater(rpc.withdraw('addr', 1000, 10, 10), throwsUnsupportedError);
  });
}
