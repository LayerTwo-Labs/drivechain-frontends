import 'package:bitwindow/pages/mining/mining_page.dart';
import 'package:bitwindow/pages/mining/pools_tab.dart';
import 'package:bitwindow/providers/mining_pools_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/stratum/v1/stratum.pb.dart';
import 'package:sidechain_core/rpcs/orchestrator_stratum_rpc.dart';

import 'mocks/mining_pools_mock.dart';
import 'test_utils.dart';

const _bip300 = 'stratum+tcp://stratum.beta.bip300.xyz:3334';
const _ecpool = 'stratum+tcp://mining.ecpool.tech:3334';

class _FakeStratum implements OrchestratorStratumRPC {
  GetStratumStatusResponse next = GetStratumStatusResponse(target: Target(kind: TargetKind.TARGET_KIND_SOLO));
  List<CatalogPool> pools = [CatalogPool(id: 'bip300', name: 'bip300 pool', url: _bip300)];
  final List<Target> targets = [];

  @override
  Future<void> setTarget(Target target) async {
    targets.add(target);
    next = GetStratumStatusResponse(running: next.running, target: target);
  }

  @override
  Future<GetStratumStatusResponse> status() async => next;

  @override
  Future<List<CatalogPool>> listPools() async => pools;

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

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeConf extends ChangeNotifier implements BitcoinConfProvider {
  _FakeConf(this.network);

  @override
  BitcoinNetwork network;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _shares = [
  poolShare('bip300.xyz', _bip300, 61),
  poolShare('eCPool.tech', _ecpool, 43, feeBps: 50, mode: 'proportional'),
  poolShare('Unknown', '', 13),
];

Future<_FakeStratum> _register({
  BitcoinNetwork network = BitcoinNetwork.BITCOIN_NETWORK_ECASH,
  void Function(_FakeStratum)? setUp,
}) async {
  await GetIt.I.reset();
  final stratum = _FakeStratum();
  setUp?.call(stratum);
  GetIt.I.registerSingleton<OrchestratorRPC>(_FakeOrchestrator(stratum));
  GetIt.I.registerSingleton<BitcoinConfProvider>(_FakeConf(network));
  GetIt.I.registerSingleton<MiningPoolsProvider>(FakeMiningPools(_shares));
  final provider = StratumProvider();
  GetIt.I.registerSingleton<StratumProvider>(provider);
  await provider.refresh();
  return stratum;
}

Finder _button(String label) => find.byWidgetPredicate((w) => w is SailButton && w.label == label);

void main() {
  tearDown(() async {
    MiningPage.requestedPoolUrl.value = null;
    await GetIt.I.reset();
  });

  testWidgets('the pools table marks the pool the server mines to', (tester) async {
    await _register(
      setUp: (stratum) => stratum.next = GetStratumStatusResponse(
        running: true,
        target: Target(kind: TargetKind.TARGET_KIND_POOL, poolId: 'bip300'),
      ),
    );
    await tester.pumpSailPage(const PoolsTab());
    await tester.pump();

    expect(find.text('Pools on the network'), findsOneWidget);
    expect(
      find.text('Who mined the last 117 blocks, read from each coinbase. Pool list from pool.drivechain.info.'),
      findsOneWidget,
    );
    expect(find.text('Network hashrate'), findsOneWidget);
    expect(find.text('42.4%'), findsNWidgets(2));
    expect(find.text('Mining here'), findsOneWidget);
    expect(_button('Mine here'), findsOneWidget);
    expect(find.text('0.5%'), findsOneWidget);
  });

  testWidgets('a stopped server shows its pool as selected', (tester) async {
    await _register(
      setUp: (stratum) => stratum.next = GetStratumStatusResponse(
        target: Target(kind: TargetKind.TARGET_KIND_CUSTOM, url: '$_ecpool/'),
      ),
    );
    await tester.pumpSailPage(const PoolsTab());
    await tester.pump();

    expect(find.text('Selected'), findsOneWidget);
    expect(find.text('Mining here'), findsNothing);
    expect(_button('Mine here'), findsOneWidget);
  });

  testWidgets('mine here sets a catalog pool as the target', (tester) async {
    final stratum = await _register();
    await tester.pumpSailPage(const PoolsTab());
    await tester.pump();

    expect(_button('Mine here'), findsNWidgets(2));

    await tester.tap(_button('Mine here').first);
    await tester.pumpAndSettle();

    expect(stratum.targets, [Target(kind: TargetKind.TARGET_KIND_POOL, poolId: 'bip300')]);
    expect(find.text('Selected'), findsOneWidget);
    expect(MiningPage.requestedPoolUrl.value, isNull);
  });

  testWidgets('mine here on a pool the catalog lacks asks the Mining tab for it', (tester) async {
    final stratum = await _register();
    await tester.pumpSailPage(const PoolsTab());
    await tester.pump();

    await tester.tap(_button('Mine here').last);
    await tester.pump();

    expect(stratum.targets, isEmpty);
    expect(MiningPage.requestedPoolUrl.value, _ecpool);
    expect(MiningPage.pendingSubtab, MiningPage.miningSubtabLabel);
  });

  testWidgets('a network with no mining shows no mine here column', (tester) async {
    await _register(network: BitcoinNetwork.BITCOIN_NETWORK_SIGNET);
    await tester.pumpSailPage(const PoolsTab());
    await tester.pump();

    expect(find.text('bip300.xyz'), findsWidgets);
    expect(_button('Mine here'), findsNothing);
  });

  testWidgets('the Mining page carries the Mining tab on eCash only', (tester) async {
    await _register();
    await tester.pumpSailPage(const MiningPage());
    await tester.pump();

    expect(find.text(MiningPage.miningSubtabLabel), findsOneWidget);
    expect(find.text(MiningPage.poolsSubtabLabel), findsOneWidget);

    await _register(network: BitcoinNetwork.BITCOIN_NETWORK_SIGNET);
    await tester.pumpSailPage(const MiningPage(key: ValueKey('signet')));
    await tester.pump();

    expect(find.text(MiningPage.miningSubtabLabel), findsNothing);
    expect(find.text('Pools on the network'), findsOneWidget);
  });

  test('two stratum URLs match apart from case and a trailing slash', () {
    expect(samePoolUrl(' STRATUM+TCP://Pool.example:3334/ ', 'stratum+tcp://pool.example:3334'), isTrue);
    expect(samePoolUrl('stratum+tcp://pool.example:3334', 'stratum+tcp://pool.example:3335'), isFalse);
    expect(samePoolUrl('', ''), isFalse);
  });

  test('shareFor finds the registered pool of a stratum URL', () {
    final provider = FakeMiningPools(_shares);

    expect(provider.shareFor('$_ecpool/')?.pool.name, 'eCPool.tech');
    expect(provider.shareFor(''), isNull);
    expect(provider.shareFor('stratum+tcp://other:1'), isNull);
  });
}
