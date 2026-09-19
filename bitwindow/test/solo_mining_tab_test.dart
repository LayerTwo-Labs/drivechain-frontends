import 'package:bitwindow/pages/wallet/wallet_solo_mining.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sidechain_core/gen/google/protobuf/timestamp.pb.dart' as wkt;
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/stratum/v1/stratum.pb.dart';
import 'package:sidechain_core/rpcs/orchestrator_stratum_rpc.dart';

import 'test_utils.dart';

class _FakeStratum implements OrchestratorStratumRPC {
  GetStratumStatusResponse next = GetStratumStatusResponse(target: Target(kind: TargetKind.TARGET_KIND_SOLO));
  List<CatalogPool> pools = [];

  @override
  Future<void> setTarget(Target target) async {
    throw Exception('the enforcer serves no template');
  }

  @override
  Future<GetStratumStatusResponse> status() async => next;

  @override
  Future<List<CatalogPool>> listPools() async => pools;

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
  GetIt.I.registerSingleton<MiningProvider>(MiningProvider());
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
    await _pump(tester, (_) {});

    expect(find.text('Stratum server'), findsOneWidget);
    expect(find.text('Mining for ASIC miners on your network'), findsOneWidget);
    expect(find.text('Stopped'), findsNWidgets(2));
    expect(find.text('Solo, your node  ·  No fee'), findsOneWidget);
    expect(find.text('Enforcer wallet'), findsOneWidget);
    expect(find.text('No miner connected'), findsOneWidget);
    expect(find.text('No block found'), findsOneWidget);
    expect(find.text('Expected time to a block'), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
    expect(find.text('CPU miner'), findsOneWidget);
  });

  testWidgets('a running solo server with a miner and a block', (tester) async {
    await _pump(tester, (stratum) {
      stratum.next = GetStratumStatusResponse(
        running: true,
        port: 3333,
        poolUrl: 'stratum+tcp://192.168.1.20:3333',
        hashrate: 6.02e12,
        bestShare: 1234567,
        networkDifficulty: 90e12,
        target: Target(kind: TargetKind.TARGET_KIND_SOLO),
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
    expect(find.text('network difficulty 90.00T'), findsOneWidget);
    expect(find.text('avalon.1'), findsNWidgets(2));
    expect(find.text('64 °C'), findsOneWidget);
    expect(find.text('512 / 2'), findsOneWidget);
    expect(find.text('High'), findsOneWidget);
    expect(find.text('00000000…deadbeef'), findsOneWidget);
    expect(find.text('Immature · 3 of 100'), findsOneWidget);
  });

  testWidgets('a running server that relays to a catalog pool', (tester) async {
    await _pump(tester, (stratum) {
      stratum.pools = [CatalogPool(id: 'bip300', name: 'bip300 pool', fee: '1%', hashrate: 16.5e12)];
      stratum.next = GetStratumStatusResponse(
        running: true,
        port: 3333,
        target: Target(kind: TargetKind.TARGET_KIND_POOL, poolId: 'bip300'),
        payoutAddress: 'bc1qpayout',
        poolConnected: true,
        poolHost: 'pool.beta.bip300.xyz:3334',
        acceptedShares: Int64(40),
        rejectedShares: Int64(1),
      );
    });

    expect(find.text('bip300 pool  ·  16.5 TH/s  ·  1% fee'), findsOneWidget);
    expect(find.text('bc1qpayout'), findsOneWidget);
    expect(find.text('Accepted shares'), findsOneWidget);
    expect(find.text('1 rejected'), findsOneWidget);
    expect(find.text('Connected'), findsOneWidget);
    expect(find.text('pool.beta.bip300.xyz:3334'), findsOneWidget);
    expect(find.text('Blocks found'), findsNothing);
  });

  testWidgets('a failed switch keeps the target the server holds', (tester) async {
    await _pump(tester, (stratum) {
      stratum.pools = [CatalogPool(id: 'bip300', name: 'bip300 pool', fee: '1%', hashrate: 16.5e12)];
      stratum.next = GetStratumStatusResponse(
        running: true,
        target: Target(kind: TargetKind.TARGET_KIND_POOL, poolId: 'bip300'),
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
      stratum.next = GetStratumStatusResponse(running: true, target: Target(kind: TargetKind.TARGET_KIND_SOLO));
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
