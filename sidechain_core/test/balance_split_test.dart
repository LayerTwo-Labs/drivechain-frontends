import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/mocks/mocks.dart';
import 'package:sidechain_core/sidechain_core.dart';

void main() {
  late MockBitwindowRPC mainchain;
  late MockThunderRPC thunder;
  late MockBitnamesRPC bitnames;
  late BalanceProvider provider;

  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    GetIt.I.registerSingleton<BinaryProvider>(MockBinaryProvider());
    mainchain = MockBitwindowRPC();
    thunder = MockThunderRPC();
    bitnames = MockBitnamesRPC();
    provider = BalanceProvider(
      connections: [mainchain, thunder, bitnames],
      mainConnection: mainchain,
    );
  });

  tearDown(() async {
    provider.dispose();
    await GetIt.I.reset();
  });

  // A total over every chain reads as mainchain money the Send page can spend.
  test('the headline balance holds the mainchain wallet alone', () {
    provider.setBalance(mainchain, 0, 330.99479104);
    provider.setBalance(thunder, 2.01999, 1);

    expect(provider.balance, 0);
    expect(provider.pendingBalance, 330.99479104);
  });

  test('the sidechain figure adds every chain but the mainchain one', () {
    provider.setBalance(mainchain, 1, 0);
    provider.setBalance(thunder, 2, 0.5);
    provider.setBalance(bitnames, 0.25, 0);

    expect(provider.sidechainBalance, 2.25);
    expect(provider.sidechainPendingBalance, 0.5);
  });

  // The bar stops its loading skeleton on initialized. A sidechain answer with
  // no mainchain answer would leave an unread zero reading as the balance.
  test('a sidechain answer alone leaves the provider uninitialized', () {
    provider.setBalance(thunder, 2, 0);
    expect(provider.initialized, isFalse);

    provider.setBalance(mainchain, 0, 0);
    expect(provider.initialized, isTrue);
  });

  // A sidechain window holds one connection, so it owns the headline figure.
  test('a lone connection drives the headline figure', () {
    final lone = MockThunderRPC();
    final chainProvider = BalanceProvider(connections: [lone]);
    addTearDown(chainProvider.dispose);

    chainProvider.setBalance(lone, 4, 2);

    expect(chainProvider.balance, 4);
    expect(chainProvider.pendingBalance, 2);
    expect(chainProvider.sidechainBalance, 0);
  });
}
