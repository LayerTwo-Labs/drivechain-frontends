import 'dart:io';

import 'package:bitwindow/pages/sidechain_host_page.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:bitwindow/sidechains/sidechain_scope.dart';
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

void main() {
  late Directory appDir;
  late MockThunderRPC thunderRPC;
  late MockTruthcoinRPC truthcoinRPC;
  late BalanceProvider bitwindowBalance;
  late BMMProvider bitwindowBmm;
  late HomepageProvider bitwindowHomepage;
  late AppRouter bitwindowRouter;
  final log = Logger(level: Level.off);

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await GetIt.I.reset();
    appDir = await Directory.systemTemp.createTemp('inapp-scope');
    GetIt.I.registerSingleton<Logger>(log);
    GetIt.I.registerSingleton<ClientSettings>(ClientSettings(store: MockStore(), log: log));
    thunderRPC = MockThunderRPC();
    truthcoinRPC = MockTruthcoinRPC();
    GetIt.I.registerSingleton<ThunderRPC>(thunderRPC);
    GetIt.I.registerSingleton<TruthcoinRPC>(truthcoinRPC);
    bitwindowBalance = BalanceProvider(connections: [thunderRPC, truthcoinRPC]);
    bitwindowBmm = _Bmm();
    bitwindowHomepage = _Homepage();
    bitwindowRouter = AppRouter();
    GetIt.I.registerSingleton<BalanceProvider>(bitwindowBalance);
    GetIt.I.registerSingleton<BMMProvider>(bitwindowBmm);
    GetIt.I.registerSingleton<HomepageProvider>(bitwindowHomepage);
    GetIt.I.registerSingleton<AppRouter>(bitwindowRouter);
  });

  tearDown(() async {
    await GetIt.I.reset();
    await appDir.delete(recursive: true);
  });

  Future<void> enter(SidechainModule module) => enterSidechainScope(
    module,
    navigator: HostChainNavigator(module.chain),
    applicationDir: appDir,
    log: log,
  );

  void expectBitWindowInstances() {
    expect(GetIt.I.get<BalanceProvider>(), same(bitwindowBalance));
    expect(GetIt.I.get<BMMProvider>(), same(bitwindowBmm));
    expect(GetIt.I.get<HomepageProvider>(), same(bitwindowHomepage));
    expect(GetIt.I.get<AppRouter>(), same(bitwindowRouter));
  }

  test('a chain scope registers the chain types and keeps the BitWindow instances', () async {
    final module = ThunderModule();
    await enter(module);

    expect(GetIt.I.get<SidechainModule>(), same(module));
    expect(GetIt.I.get<SidechainRPC>(), same(thunderRPC));
    expect(GetIt.I.get<ChainNavigator>(), isA<HostChainNavigator>());
    expect(GetIt.I.get<SidechainBalanceProvider>().connections, [thunderRPC]);
    expect(GetIt.I.isRegistered<SidechainBMMProvider>(), isTrue);
    expect(GetIt.I.get<AddressProvider>().rpc, same(thunderRPC));
    expect(GetIt.I.get<SidechainTransactionsProvider>().rpc, same(thunderRPC));
    expect(GetIt.I.get<GenericSidechainConfProvider>().configFileName, 'thunder.conf');
    expect(GetIt.I.get<SidechainHomepageProvider>().module, same(module));
    expectBitWindowInstances();
  });

  test('leaving a chain scope disposes the chain types', () async {
    final module = ThunderModule();
    await enter(module);
    final balance = GetIt.I.get<SidechainBalanceProvider>();
    final transactions = GetIt.I.get<SidechainTransactionsProvider>();

    await exitSidechainScope(module);

    for (final registered in [
      GetIt.I.isRegistered<SidechainModule>(),
      GetIt.I.isRegistered<SidechainRPC>(),
      GetIt.I.isRegistered<ChainNavigator>(),
      GetIt.I.isRegistered<SidechainBalanceProvider>(),
      GetIt.I.isRegistered<SidechainTransactionsProvider>(),
      GetIt.I.isRegistered<GenericSidechainConfProvider>(),
      GetIt.I.isRegistered<SidechainHomepageProvider>(),
    ]) {
      expect(registered, isFalse);
    }
    expect(() => balance.addListener(() {}), throwsFlutterError);
    expect(() => transactions.addListener(() {}), throwsFlutterError);
    // The typed RPC belongs to BitWindow, so it stays up.
    expect(GetIt.I.get<ThunderRPC>(), same(thunderRPC));
    expectBitWindowInstances();
  });

  test('a switch of chains leaves only the new chain in scope', () async {
    final thunder = ThunderModule();
    final truthcoin = TruthcoinModule();
    await enter(thunder);
    await enter(truthcoin);
    await exitSidechainScope(thunder);

    expect(GetIt.I.get<SidechainModule>(), same(truthcoin));
    expect(GetIt.I.get<SidechainRPC>(), same(truthcoinRPC));
    expect(GetIt.I.isRegistered<PriceHistoryProvider>(), isTrue);
    expectBitWindowInstances();

    await exitSidechainScope(truthcoin);
    expect(GetIt.I.isRegistered<PriceHistoryProvider>(), isFalse);
    expect(GetIt.I.isRegistered<SidechainModule>(), isFalse);
  });
}
