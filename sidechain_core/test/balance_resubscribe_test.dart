import 'dart:async';
import 'dart:io';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sidechain_core/mocks/mocks.dart';
import 'package:sidechain_core/sidechain_core.dart';

class _BootingMainchain extends MockBitwindowRPC {
  bool up = false;
  int subscribes = 0;
  final frames = StreamController<wmpb.WatchBalanceResponse>.broadcast();

  @override
  BalanceStream get balanceStream => BalanceStream(
    subscribe: () {
      subscribes++;
      if (!up) {
        return Stream.error(const SocketException('Connection refused'));
      }
      return frames.stream;
    },
    onTransportDeath: () {},
  );

  @override
  void dispose() {
    unawaited(frames.close());
    super.dispose();
  }

  @override
  Future<(double, double, double)> balances() => Future.error(const SocketException('Connection refused'));
}

void main() {
  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    GetIt.I.registerSingleton<BinaryProvider>(MockBinaryProvider());
  });

  tearDown(() => GetIt.I.reset());

  test('the balance stream subscribes at once when its chain comes up', () {
    fakeAsync((async) {
      final mainchain = _BootingMainchain();
      final provider = BalanceProvider(connections: [mainchain]);
      async.elapse(const Duration(seconds: 2));
      final before = mainchain.subscribes;
      expect(before, greaterThan(2));

      mainchain.up = true;
      mainchain.setConnected(true);
      async.elapse(const Duration(milliseconds: 10));
      expect(mainchain.subscribes, before + 1);

      mainchain.frames.add(
        wmpb.WatchBalanceResponse(walletId: 'w', balance: wmpb.GetBalanceResponse(confirmedSats: 2e8)),
      );
      async.flushMicrotasks();
      expect(provider.balance, 2.0);

      provider.dispose();
      mainchain.dispose();
      async.flushMicrotasks();
    });
  });
}
