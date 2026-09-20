import 'package:bitwindow/dialogs/mining_settings_dialog.dart';
import 'package:bitwindow/pages/wallet/wallet_solo_mining.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/google/protobuf/timestamp.pb.dart' as wkt;
import 'package:sidechain_core/gen/stratum/v1/stratum.pb.dart';
import 'package:sidechain_core/rpcs/orchestrator_stratum_rpc.dart';

import 'test_utils.dart';

class _FakeStratum implements OrchestratorStratumRPC {
  GetStratumStatusResponse next = GetStratumStatusResponse(target: Target(kind: TargetKind.TARGET_KIND_SOLO));
  List<CatalogPool> pools = [];
  GetHashrateHistoryResponse history = GetHashrateHistoryResponse();
  ListPoolBlocksResponse blocks = ListPoolBlocksResponse();
  SetMiningSettingsRequest? saved;

  @override
  Future<void> setTarget(Target target) async {
    throw Exception('the enforcer serves no template');
  }

  @override
  Future<GetStratumStatusResponse> status() async => next;

  @override
  Future<List<CatalogPool>> listPools() async => pools;

  @override
  Future<GetHashrateHistoryResponse> hashrateHistory(HashrateRange range) async => history;

  @override
  Future<ListPoolBlocksResponse> listPoolBlocks({int limit = 0}) async => blocks;

  @override
  Future<void> setMiningSettings({int? port, bool? cpuMining, int? cpuThreads, bool? keepMiningOnClose}) async {
    saved = SetMiningSettingsRequest(
      port: port,
      cpuMining: cpuMining,
      cpuThreads: cpuThreads,
      keepMiningOnClose: keepMiningOnClose,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _DownStratum implements OrchestratorStratumRPC {
  @override
  Future<GetStratumStatusResponse> status() async => throw Exception('drivechaind is down');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeOrchestrator implements OrchestratorRPC {
  _FakeOrchestrator(this.stratum);

  @override
  final OrchestratorStratumRPC stratum;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<_FakeStratum> _pump(WidgetTester tester, void Function(_FakeStratum) setUp) async {
  await GetIt.I.reset();
  final stratum = _FakeStratum();
  setUp(stratum);
  GetIt.I.registerSingleton<OrchestratorRPC>(_FakeOrchestrator(stratum));
  final provider = StratumProvider();
  GetIt.I.registerSingleton<StratumProvider>(provider);
  await provider.refresh();
  await tester.pumpSailPage(const SoloMiningTab());
  await tester.pump();
  return stratum;
}

wkt.Timestamp _ago(Duration d) => wkt.Timestamp.fromDateTime(DateTime.now().subtract(d));

void main() {
  tearDown(() async {
    await GetIt.I.reset();
  });

  testWidgets('a stopped solo server', (tester) async {
    await _pump(tester, (stratum) {
      stratum.next = GetStratumStatusResponse(
        target: Target(kind: TargetKind.TARGET_KIND_SOLO),
        payoutAddress: 'bc1qpayout',
        settings: MiningSettings(port: 3333, cpuThreads: 4),
      );
    });

    expect(find.text('Stratum server'), findsOneWidget);
    expect(find.text('Mining for ASIC miners on your network'), findsOneWidget);
    expect(find.text('Stopped'), findsOneWidget);
    expect(find.text('Solo, your node  ·  No fee'), findsOneWidget);
    expect(find.text('Payout address'), findsOneWidget);
    expect(find.text('bc1qpayout'), findsOneWidget);
    expect(find.text('No miner connected'), findsOneWidget);
    expect(find.text('No share yet'), findsOneWidget);
    expect(find.text('No block found'), findsOneWidget);
    expect(find.text('CPU miner'), findsNothing);
    expect(find.text('Mine with this computer'), findsNothing);
  });

  testWidgets('a running solo server with a miner and a block', (tester) async {
    await _pump(tester, (stratum) {
      stratum.history = GetHashrateHistoryResponse(peak: 8.04e12, current: 7.33e12);
      stratum.next = GetStratumStatusResponse(
        running: true,
        port: 3333,
        poolUrl: 'stratum+tcp://192.168.1.20:3333',
        hashrate: 6.02e12,
        bestShare: 1234567,
        networkDifficulty: 90e12,
        target: Target(kind: TargetKind.TARGET_KIND_SOLO),
        settings: MiningSettings(port: 3333, cpuThreads: 4),
        miners: [
          ConnectedMiner(
            worker: 'avalon.1',
            address: '192.168.1.40',
            hashrate: 6.02e12,
            acceptedShares: Int64(512),
            rejectedShares: Int64(2),
            lastShareTime: _ago(const Duration(seconds: 3)),
            temperatureCelsius: 64,
            workMode: WorkMode.WORK_MODE_HIGH,
          ),
        ],
        blocksFound: [
          FoundBlock(
            height: 958400,
            hash: '0000000000000000000a1b2c3d4e5f60718293a4b5c6d7e8f9000000deadbeef',
            rewardSats: Int64(312500000),
            worker: 'avalon.1',
            foundTime: _ago(const Duration(minutes: 5)),
            confirmations: 3,
          ),
        ],
      );
    });

    expect(find.text('Running'), findsOneWidget);
    expect(find.text('stratum+tcp://192.168.1.20:3333'), findsOneWidget);
    expect(find.text('Any name'), findsOneWidget);
    expect(find.text('6.02 TH/s'), findsNWidgets(2));
    expect(find.text('1 miner'), findsOneWidget);
    expect(find.text('of 90.00T needed for a block'), findsOneWidget);
    expect(find.text('avalon.1'), findsNWidgets(2));
    expect(find.text('64 °C'), findsOneWidget);
    expect(find.text('512 / 2'), findsOneWidget);
    expect(find.text('High'), findsOneWidget);
    expect(find.text('00000000…deadbeef'), findsOneWidget);
    expect(find.text('Immature · 3 of 100'), findsOneWidget);
    expect(find.text('peak 8.04 TH/s  ·  now 7.33 TH/s'), findsOneWidget);
  });

  testWidgets('the hasher on this computer is a row like any miner', (tester) async {
    await _pump(tester, (stratum) {
      stratum.next = GetStratumStatusResponse(
        running: true,
        hashrate: 412000,
        target: Target(kind: TargetKind.TARGET_KIND_SOLO),
        settings: MiningSettings(port: 3333, cpuMining: true, cpuThreads: 4),
        miners: [
          ConnectedMiner(
            worker: 'cpu',
            address: 'this computer',
            hashrate: 412000,
            bestShare: 4096,
            acceptedShares: Int64(31),
            lastShareTime: _ago(const Duration(seconds: 2)),
          ),
        ],
      );
    });

    expect(find.text('cpu'), findsOneWidget);
    expect(find.text('this computer'), findsOneWidget);
    expect(find.text('412 KH/s'), findsNWidgets(2));
    expect(find.text('31 / 0'), findsOneWidget);
    expect(find.text('1 miner'), findsOneWidget);
  });

  testWidgets('the server card carries a settings button', (tester) async {
    await _pump(tester, (stratum) {
      stratum.next = GetStratumStatusResponse(
        running: true,
        target: Target(kind: TargetKind.TARGET_KIND_SOLO),
        settings: MiningSettings(port: 3333, cpuThreads: 4),
      );
    });

    expect(find.byWidgetPredicate((w) => w is SailButton && w.icon == SailSVGAsset.tabSettings), findsOneWidget);
  });

  testWidgets('the settings dialog saves every field', (tester) async {
    await GetIt.I.reset();
    final stratum = _FakeStratum();
    stratum.next = GetStratumStatusResponse(settings: MiningSettings(port: 3333, cpuThreads: 4));
    GetIt.I.registerSingleton<OrchestratorRPC>(_FakeOrchestrator(stratum));
    final provider = StratumProvider();
    GetIt.I.registerSingleton<StratumProvider>(provider);
    await provider.refresh();
    await tester.pumpSailPage(const MiningSettingsDialog());
    await tester.pump();

    expect(find.text('Mining settings'), findsOneWidget);
    expect(find.text('Mine with this computer'), findsOneWidget);
    expect(find.text('CPU threads'), findsOneWidget);
    expect(find.text('Keep mining when bitwindow closes'), findsOneWidget);

    await tester.tap(find.byType(SailSwitch).first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byWidgetPredicate((w) => w is SailButton && w.label == 'Save'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(stratum.saved?.cpuMining, isTrue);
    expect(stratum.saved?.port, 3333);
    expect(stratum.saved?.cpuThreads, 4);
  });

  testWidgets('the recent shares card lists what the miners sent', (tester) async {
    await _pump(tester, (stratum) {
      stratum.next = GetStratumStatusResponse(
        running: true,
        networkDifficulty: 4e9,
        target: Target(kind: TargetKind.TARGET_KIND_SOLO),
        settings: MiningSettings(port: 3333),
        recentShares: [
          AcceptedShare(
            time: _ago(const Duration(seconds: 4)),
            worker: 'cpu',
            target: 8192,
            actual: 40960,
            hash: '0000000000000000000a1b2c3d4e5f60718293a4b5c6d7e8f9000000deadbeef',
          ),
        ],
      );
    });

    expect(find.text('Recent shares'), findsOneWidget);
    expect(find.text('last 1 · a block needs 4.00G'), findsOneWidget);
    expect(find.text('8.19K'), findsOneWidget);
    expect(find.text('40.96K'), findsOneWidget);
  });

  testWidgets('a running server that relays to a catalog pool', (tester) async {
    await _pump(tester, (stratum) {
      stratum.pools = [CatalogPool(id: 'bip300', name: 'bip300 pool', fee: '1%', hashrate: 16.5e12)];
      stratum.blocks = ListPoolBlocksResponse(
        blocks: [
          PoolBlock(
            height: 958400,
            hash: '0000000000000000000a1b2c3d4e5f60718293a4b5c6d7e8f9000000deadbeef',
            rewardSats: Int64(312500000),
            finder: 'avalon.1',
            myPayoutSats: Int64(1200),
            mine: true,
            confirmations: 3,
            foundTime: _ago(const Duration(minutes: 5)),
          ),
        ],
      );
      stratum.next = GetStratumStatusResponse(
        running: true,
        port: 3333,
        target: Target(kind: TargetKind.TARGET_KIND_POOL, poolId: 'bip300'),
        payoutAddress: 'bc1qpayout',
        poolConnected: true,
        poolHost: 'pool.beta.bip300.xyz:3334',
        acceptedShares: Int64(40),
        rejectedShares: Int64(1),
        settings: MiningSettings(port: 3333),
      );
    });

    expect(find.text('bip300 pool  ·  16.5 TH/s  ·  1% fee'), findsOneWidget);
    expect(find.text('bc1qpayout'), findsOneWidget);
    expect(find.text('Accepted shares'), findsOneWidget);
    expect(find.text('1 rejected'), findsOneWidget);
    expect(find.text('Connected'), findsOneWidget);
    expect(find.text('pool.beta.bip300.xyz:3334'), findsOneWidget);
    expect(find.text('Blocks the pool found'), findsOneWidget);
    expect(find.text('avalon.1 (you)'), findsOneWidget);
    expect(find.text('Blocks found'), findsNothing);
  });

  testWidgets('a pool block with no time reads as unavailable', (tester) async {
    await _pump(tester, (stratum) {
      stratum.pools = [CatalogPool(id: 'bip300', name: 'bip300 pool')];
      stratum.blocks = ListPoolBlocksResponse(
        blocks: [
          PoolBlock(
            height: 968556,
            hash: '0000000000000001c8794cd30ae7c055a82d40d7f2d89b78e51f77149b0eef34',
            rewardSats: Int64(309375000),
            finder: 'someone.else',
          ),
        ],
      );
      stratum.next = GetStratumStatusResponse(
        running: true,
        target: Target(kind: TargetKind.TARGET_KIND_POOL, poolId: 'bip300'),
        settings: MiningSettings(port: 3333),
      );
    });

    expect(find.text('968556'), findsOneWidget);
    expect(find.textContaining('ago'), findsNothing);
    // A node that gave no block leaves the payout unknown, not zero.
    expect(find.text('0 sats'), findsNothing);
  });

  testWidgets('a custom pool says the block list is for a catalog pool', (tester) async {
    await _pump(tester, (stratum) {
      stratum.blocks = ListPoolBlocksResponse(
        unavailable: 'this list holds the blocks of a pool from the catalog only',
      );
      stratum.next = GetStratumStatusResponse(
        running: true,
        target: Target(kind: TargetKind.TARGET_KIND_CUSTOM, url: 'stratum+tcp://pool.example.com:3333', worker: 'me'),
        settings: MiningSettings(port: 3333),
      );
    });

    expect(find.text('this list holds the blocks of a pool from the catalog only'), findsWidgets);
    expect(find.text('No block found'), findsNothing);
  });

  testWidgets('a custom pool shows no payout address', (tester) async {
    await _pump(tester, (stratum) {
      stratum.next = GetStratumStatusResponse(
        running: true,
        payoutAddress: 'bc1qpayout',
        target: Target(
          kind: TargetKind.TARGET_KIND_CUSTOM,
          url: 'stratum+tcp://pool.example.com:3333',
          worker: 'bc1qme.rig',
          password: 'x',
        ),
        settings: MiningSettings(port: 3333),
      );
    });

    expect(find.text('Pool worker'), findsOneWidget);
    expect(find.text('Payout address'), findsNothing);
    expect(find.text('bc1qpayout'), findsNothing);
  });

  testWidgets('a pool that publishes no blocks says so', (tester) async {
    await _pump(tester, (stratum) {
      stratum.pools = [CatalogPool(id: 'bip300', name: 'bip300 pool')];
      stratum.blocks = ListPoolBlocksResponse(unavailable: 'this pool publishes no block list');
      stratum.next = GetStratumStatusResponse(
        running: true,
        target: Target(kind: TargetKind.TARGET_KIND_POOL, poolId: 'bip300'),
        settings: MiningSettings(port: 3333),
      );
    });

    expect(find.text('this pool publishes no block list'), findsWidgets);
    expect(find.text('No block found'), findsNothing);
  });

  testWidgets('a failed switch keeps the target the server holds', (tester) async {
    await _pump(tester, (stratum) {
      stratum.pools = [CatalogPool(id: 'bip300', name: 'bip300 pool', fee: '1%', hashrate: 16.5e12)];
      stratum.next = GetStratumStatusResponse(
        running: true,
        target: Target(kind: TargetKind.TARGET_KIND_POOL, poolId: 'bip300'),
        settings: MiningSettings(port: 3333),
      );
    });
    const pool = 'bip300 pool  ·  16.5 TH/s  ·  1% fee';

    await tester.tap(find.text(pool));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Solo, your node'));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.text(pool), findsOneWidget);
    expect(find.text('Accepted shares'), findsOneWidget);
  });

  testWidgets('a custom pool opens its fields on a running server', (tester) async {
    await _pump(tester, (stratum) {
      stratum.next = GetStratumStatusResponse(
        running: true,
        target: Target(kind: TargetKind.TARGET_KIND_SOLO),
        settings: MiningSettings(port: 3333),
      );
    });

    await tester.tap(find.text('Solo, your node  ·  No fee'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Custom pool'));
    await tester.pumpAndSettle();

    expect(find.byWidgetPredicate((w) => w is SailButton && w.label == 'Mine to this pool'), findsOneWidget);
    expect(find.text('Pool address'), findsOneWidget);
    expect(find.text('Any name'), findsNothing);
  });

  testWidgets('a failed status read shows on the server card', (tester) async {
    await _pump(tester, (stratum) {
      stratum.next = GetStratumStatusResponse(running: true, target: Target(kind: TargetKind.TARGET_KIND_SOLO));
    });

    GetIt.I.unregister<OrchestratorRPC>();
    GetIt.I.registerSingleton<OrchestratorRPC>(_FakeOrchestrator(_DownStratum()));
    await GetIt.I.get<StratumProvider>().refresh();
    await tester.pump();

    expect(find.textContaining('drivechaind is down'), findsOneWidget);
  });

  testWidgets('a saved custom pool fills its fields', (tester) async {
    await _pump(tester, (stratum) {
      stratum.next = GetStratumStatusResponse(
        target: Target(
          kind: TargetKind.TARGET_KIND_CUSTOM,
          url: 'stratum+tcp://pool.example.com:3333',
          worker: 'bc1qme.rig',
          password: 'x',
        ),
        settings: MiningSettings(port: 3333),
      );
    });

    expect(find.text('stratum+tcp://pool.example.com:3333'), findsOneWidget);
    expect(find.text('bc1qme.rig'), findsOneWidget);
  });

  test('block status', () {
    expect(blockStatus(0), 'Immature · 0 of 100');
    expect(blockStatus(99), 'Immature · 99 of 100');
    expect(blockStatus(100), 'Mature');
    expect(blockStatus(-1), 'Orphaned');
  });
}
