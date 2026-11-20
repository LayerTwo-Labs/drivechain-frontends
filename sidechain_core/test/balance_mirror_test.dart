import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/mocks/mocks.dart';
import 'package:sidechain_core/sidechain_core.dart';

class _CountingThunder extends MockThunderRPC {
  int calls = 0;

  @override
  Future<(double, double)> balance() async {
    calls++;
    return (3.0, 1.0);
  }
}

void main() {
  late _CountingThunder thunder;
  late BalanceProvider source;
  late SidechainBalanceProvider mirror;

  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    GetIt.I.registerSingleton<BinaryProvider>(MockBinaryProvider());
    thunder = _CountingThunder()..setConnected(true);
    source = BalanceProvider(connections: [MockBitwindowRPC(), thunder]);
    await pumpEventQueue();
    thunder.calls = 0;
    mirror = SidechainBalanceProvider.mirror(sidechain: thunder, source: source);
  });

  tearDown(() async {
    mirror.dispose();
    source.dispose();
    await GetIt.I.reset();
  });

  test('a mirror shows the balance of the source and reads no balance itself', () async {
    expect(mirror.initialized, isTrue);
    expect((mirror.balance, mirror.pendingBalance), (3.0, 1.0));
    expect(thunder.calls, 0);

    var notified = 0;
    mirror.addListener(() => notified++);
    source.setBalance(thunder, 3, 1);
    expect(notified, 0, reason: 'no change, no notify');

    source.setBalance(thunder, 4, 0);
    expect(notified, 1);
    expect((mirror.balance, mirror.pendingBalance), (4.0, 0.0));
  });

  test('a fetch of a mirror reads the chain one time, through the source', () async {
    await mirror.fetch();
    expect(thunder.calls, 1);
  });

  test('a mirror clears when the source clears', () async {
    source.clear();
    expect(mirror.initialized, isFalse);
    expect(mirror.balance, 0);
  });
}
