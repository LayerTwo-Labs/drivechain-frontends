import 'dart:io';

import 'package:bitnames/bitnames_module.dart';
import 'package:bitnames/providers/bitnames_provider.dart';
import 'package:bitwindow/pages/sidechain_host_page.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:bitwindow/sidechains/hosted_chains.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/shell/shell.dart';
import 'package:sidechain_core/mocks/mocks.dart';
import 'package:thunder/thunder_module.dart';
import 'package:truthcoin/providers/price_history_provider.dart';
import 'package:truthcoin/truthcoin_module.dart';

import 'mocks/store_mock.dart';

class _Bmm extends ChangeNotifier implements BMMProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Homepage extends ChangeNotifier implements HomepageProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Node state that a test sets by hand.
class _Binaries extends ChangeNotifier implements BinaryProvider {
  final Set<BinaryType> _up = {};

  @override
  List<Binary> binaries = [];

  void setUp(Binary chain, bool up) {
    up ? _up.add(chain.type) : _up.remove(chain.type);
    notifyListeners();
  }

  @override
  bool isConnected(Binary binary) => _up.contains(binary.type);

  @override
  bool isInitializing(Binary binary) => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late Directory appDir;
  late MockThunderRPC thunderRPC;
  late MockTruthcoinRPC truthcoinRPC;
  late MockBitnamesRPC bitnamesRPC;
  late BalanceProvider bitwindowBalance;
  late BMMProvider bitwindowBmm;
  late HomepageProvider bitwindowHomepage;
  late AppRouter bitwindowRouter;
  late _Binaries binaries;
  late HostedChains hosted;
  final log = Logger(level: Level.off);
  final thunder = ThunderModule();
  final truthcoin = TruthcoinModule();
  final bitnames = BitnamesModule();

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await GetIt.I.reset();
    appDir = await Directory.systemTemp.createTemp('hosted-chains');
    GetIt.I.registerSingleton<Logger>(log);
    GetIt.I.registerSingleton<ClientSettings>(ClientSettings(store: MockStore(), log: log));
    thunderRPC = MockThunderRPC();
    truthcoinRPC = MockTruthcoinRPC();
    bitnamesRPC = MockBitnamesRPC();
    GetIt.I.registerSingleton<ThunderRPC>(thunderRPC);
    GetIt.I.registerSingleton<TruthcoinRPC>(truthcoinRPC);
    GetIt.I.registerSingleton<BitnamesRPC>(bitnamesRPC);
    bitwindowBalance = BalanceProvider(connections: [thunderRPC, truthcoinRPC]);
    bitwindowBmm = _Bmm();
    bitwindowHomepage = _Homepage();
    bitwindowRouter = AppRouter();
    GetIt.I.registerSingleton<BalanceProvider>(bitwindowBalance);
    GetIt.I.registerSingleton<BMMProvider>(bitwindowBmm);
    GetIt.I.registerSingleton<HomepageProvider>(bitwindowHomepage);
    GetIt.I.registerSingleton<AppRouter>(bitwindowRouter);
    binaries = _Binaries();
    hosted = HostedChains(
      binaries: binaries,
      modules: [thunder, truthcoin, bitnames],
      applicationDir: appDir,
      log: log,
      navigatorFor: (module) => HostChainNavigator(module.chain),
    );
  });

  tearDown(() async {
    hosted.dispose();
    await GetIt.I.reset();
    await appDir.delete(recursive: true);
  });

  void expectBitWindowInstances() {
    expect(GetIt.I.get<BalanceProvider>(), same(bitwindowBalance));
    expect(GetIt.I.get<BMMProvider>(), same(bitwindowBmm));
    expect(GetIt.I.get<HomepageProvider>(), same(bitwindowHomepage));
    expect(GetIt.I.get<AppRouter>(), same(bitwindowRouter));
  }

  void expectView(SidechainModule module, SidechainRPC rpc) {
    expect(GetIt.I.get<SidechainModule>(), same(module));
    expect(GetIt.I.get<SidechainRPC>(), same(rpc));
    expect(GetIt.I.get<SidechainBalanceProvider>().connections, [rpc]);
    expect(GetIt.I.get<AddressProvider>().rpc, same(rpc));
    expect(GetIt.I.get<SidechainTransactionsProvider>().rpc, same(rpc));
    expect(GetIt.I.get<SidechainHomepageProvider>().module, same(module));
    expect(GetIt.I.isRegistered<SidechainBMMProvider>(), isTrue);
    expectBitWindowInstances();
  }

  Future<void> idle() => hosted.settled();

  test('a view of a chain reads the types of that chain and keeps the BitWindow instances', () async {
    await hosted.openView(thunder);

    expectView(thunder, thunderRPC);
    expect(GetIt.I.get<ChainNavigator>(), isA<HostChainNavigator>());
    expect(GetIt.I.get<GenericSidechainConfProvider>().configFileName, 'thunder.conf');
    expect(hosted.session(thunder), isNotNull);
  });

  test('the session of a running chain stays when its view closes', () async {
    binaries.setUp(thunder.chain, true);
    await hosted.openView(thunder);
    final session = hosted.session(thunder)!;

    await hosted.closeView(thunder);
    await idle();

    expect(hosted.session(thunder), same(session));
    expect(() => session.transactions.addListener(() {}), returnsNormally);
    expect(() => session.balance.addListener(() {}), returnsNormally);
    expect(GetIt.I.isRegistered<SidechainModule>(), isFalse, reason: 'only a view holds the shared types');
    expectBitWindowInstances();
  });

  test('a switch of chains keeps the running chain and shows the new one', () async {
    binaries.setUp(truthcoin.chain, true);
    await idle();
    final truthcoinSession = hosted.session(truthcoin);
    expect(truthcoinSession, isNotNull);
    final priceHistory = GetIt.I.get<PriceHistoryProvider>();

    await hosted.openView(truthcoin);
    await hosted.openView(thunder);
    await hosted.closeView(truthcoin);

    expectView(thunder, thunderRPC);
    expect(hosted.session(truthcoin), same(truthcoinSession));
    expect(GetIt.I.get<PriceHistoryProvider>(), same(priceHistory));
    expect(() => priceHistory.addListener(() {}), returnsNormally);
  });

  test('the session closes and disposes its providers when the node stops', () async {
    binaries.setUp(truthcoin.chain, true);
    await idle();
    final session = hosted.session(truthcoin)!;
    final priceHistory = GetIt.I.get<PriceHistoryProvider>();

    binaries.setUp(truthcoin.chain, false);
    await idle();

    expect(hosted.session(truthcoin), isNull);
    expect(() => session.transactions.addListener(() {}), throwsFlutterError);
    expect(() => priceHistory.addListener(() {}), throwsFlutterError);
    expect(GetIt.I.isRegistered<PriceHistoryProvider>(), isFalse);
    expect(GetIt.I.isRegistered<SidechainModule>(), isFalse);
    expect(GetIt.I.get<TruthcoinRPC>(), same(truthcoinRPC), reason: 'the typed RPC belongs to BitWindow');
    expectBitWindowInstances();
  });

  test('a session of a node that stops stays while its view is open', () async {
    binaries.setUp(thunder.chain, true);
    await hosted.openView(thunder);
    final session = hosted.session(thunder)!;

    binaries.setUp(thunder.chain, false);
    await idle();
    expect(hosted.session(thunder), same(session));
    expectView(thunder, thunderRPC);

    await hosted.closeView(thunder);
    await idle();
    await hosted.openView(bitnames);
    expect(hosted.session(thunder), isNull);
  });

  test('two running chains each keep the providers of their own chain', () async {
    binaries.setUp(thunder.chain, true);
    binaries.setUp(bitnames.chain, true);
    await hosted.openView(thunder);
    await idle();

    final thunderSession = hosted.session(thunder)!;
    final bitnamesSession = hosted.session(bitnames)!;
    expect(thunderSession.transactions.rpc, same(thunderRPC));
    expect(bitnamesSession.transactions.rpc, same(bitnamesRPC));
    expect(bitnamesSession.addresses.rpc, same(bitnamesRPC));
    expect(GetIt.I.isRegistered<BitnamesProvider>(), isTrue);
    expectView(thunder, thunderRPC);

    await hosted.openView(bitnames);
    await hosted.closeView(thunder);
    expectView(bitnames, bitnamesRPC);
    expect(GetIt.I.get<SidechainBalanceProvider>(), same(bitnamesSession.balance));
  });

  test('a session that opens behind a view leaves that view on top', () async {
    await hosted.openView(thunder);

    binaries.setUp(truthcoin.chain, true);
    await idle();

    expect(hosted.session(truthcoin), isNotNull);
    expect(hosted.session(truthcoin)!.transactions.rpc, same(truthcoinRPC));
    expectView(thunder, thunderRPC);
  });

  test('a session scope holds no shared type, so a chain that starts never hides the view', () async {
    await hosted.openView(thunder);
    binaries.setUp(truthcoin.chain, true);
    await idle();

    final scope = sidechainSessionScope(truthcoin);
    for (final shared in [
      GetIt.I.findAll<SidechainModule>(onlyInScope: scope),
      GetIt.I.findAll<SidechainRPC>(onlyInScope: scope, includeSubtypes: false, includeMatchedByInstance: false),
      GetIt.I.findAll<SidechainBalanceProvider>(onlyInScope: scope),
      GetIt.I.findAll<SidechainTransactionsProvider>(onlyInScope: scope),
      GetIt.I.findAll<AddressProvider>(onlyInScope: scope),
      GetIt.I.findAll<GenericSidechainConfProvider>(onlyInScope: scope),
      GetIt.I.findAll<SidechainHomepageProvider>(onlyInScope: scope),
      GetIt.I.findAll<ChainNavigator>(onlyInScope: scope),
    ]) {
      expect(shared, isEmpty);
    }
    expect(GetIt.I.isRegistered<PriceHistoryProvider>(), isTrue);
    expectView(thunder, thunderRPC);
  });

  test('closeAll drops every session and the view', () async {
    binaries.setUp(thunder.chain, true);
    binaries.setUp(truthcoin.chain, true);
    await hosted.openView(thunder);
    await idle();

    await hosted.closeAll();

    expect(hosted.session(thunder), isNull);
    expect(hosted.session(truthcoin), isNull);
    expect(GetIt.I.isRegistered<SidechainModule>(), isFalse);
    expect(GetIt.I.isRegistered<PriceHistoryProvider>(), isFalse);
    expectBitWindowInstances();
  });
}
