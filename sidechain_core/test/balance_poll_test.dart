import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/mocks/mocks.dart';
import 'package:sidechain_core/sidechain_core.dart';

class _CountingMainchain extends MockBitwindowRPC {
  int calls = 0;

  @override
  Future<(double, double, double)> balances() async {
    calls++;
    return (1.0, 0.0, 0.0);
  }
}

void main() {
  late _CountingMainchain mainchain;
  late BalanceProvider provider;

  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    GetIt.I.registerSingleton<BinaryProvider>(MockBinaryProvider());
    mainchain = _CountingMainchain()..setConnected(true);
    provider = BalanceProvider(connections: [mainchain]);
    await pumpEventQueue();
    mainchain.calls = 0;
  });

  tearDown(() async {
    provider.dispose();
    await GetIt.I.reset();
  });

  test('a poll skips a balance that setBalance wrote', () async {
    await provider.poll();
    expect(mainchain.calls, 1);

    provider.setBalance(mainchain, 1, 0);
    await provider.poll();
    expect(mainchain.calls, 1);
  });

  test('a poll reads the maturing balance of a connection it never read', () async {
    provider.clear();
    provider.setBalance(mainchain, 1, 0);
    await provider.poll();
    expect(mainchain.calls, 1);

    provider.setBalance(mainchain, 1, 0);
    await provider.poll();
    expect(mainchain.calls, 1);
  });

  test('a fetch reads a balance that setBalance wrote', () async {
    provider.setBalance(mainchain, 1, 0);
    await provider.fetch();
    expect(mainchain.calls, 1);
  });
}
