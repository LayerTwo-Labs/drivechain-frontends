import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/mocks/mocks.dart';
import 'package:sidechain_core/rpcs/bitcoind_connection.dart';
import 'package:sidechain_core/rpcs/zside_rpc.dart';
import 'package:zside/providers/zside_provider.dart';
import 'package:zside/routing/router.dart';
import 'package:zside/zside_module.dart';

import 'mocks/rpc_mock_zside.dart';

class _WalletRPC extends MockZSideRPC {
  List<String> owned = ['a1'];
  int newAddresses = 0;
  Object? fault;
  final Set<String> failShield = {};

  @override
  Future<String> shield(UnshieldedUTXO utxo, double amount) async {
    if (failShield.contains(utxo.txid)) throw Exception('shield failed');
    return 'opid';
  }

  @override
  Future<List<String>> getShieldedWalletAddresses() async {
    if (fault != null) throw fault!;
    return owned;
  }

  @override
  Future<String> getNewShieldedAddress() async {
    newAddresses++;
    owned = [...owned, 'new$newAddresses'];
    return 'new$newAddresses';
  }
}

void main() {
  late _WalletRPC rpc;

  setUp(() async {
    await GetIt.I.reset();
    rpc = _WalletRPC();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    GetIt.I.registerSingleton<ZSideRPC>(rpc);
    GetIt.I.registerSingleton<BitcoindConnection>(MockBitcoindConnection());
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  test('the shielded address stays one the wallet owns', () async {
    final provider = ZSideProvider();
    await pumpEventQueue();
    expect(provider.zsideAddress, 'a1');

    await provider.fetch();
    expect(provider.zsideAddress, 'a1');
    expect(rpc.newAddresses, 0, reason: 'a poll makes no address');

    rpc.owned = ['b1'];
    await provider.fetch();
    expect(provider.zsideAddress, 'b1', reason: 'a restored wallet does not own the old address');

    rpc.owned = [];
    await provider.fetch();
    expect(provider.zsideAddress, 'new1');
    expect(rpc.newAddresses, 1);
  });
  test('a failed fetch sets the error, and the next fetch clears it', () async {
    final provider = ZSideProvider();
    await pumpEventQueue();
    expect(provider.error, isNull);

    rpc.fault = Exception('node is down');
    await provider.fetch();
    expect(provider.error, contains('node is down'));

    rpc.fault = null;
    await provider.fetch();
    expect(provider.error, isNull);
  });

  test('a melt reports one event after its last UTXO, with the failed count', () async {
    final provider = ZSideProvider();
    await pumpEventQueue();
    UnshieldedUTXO utxo(String txid) =>
        UnshieldedUTXO(txid: txid, address: 'addr', amount: 0.5, confirmations: 3, generated: false, raw: '');
    rpc.failShield.add('t2');
    final events = <CompletedMelt>[];
    provider.meltsCompleted.listen(events.add);

    await provider.melt([utxo('t1'), utxo('t2')], 1 / 60);
    expect(provider.utxosToMelt, hasLength(2));
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    expect(provider.utxosToMelt, isEmpty);
    expect(events, hasLength(1));
    expect(events.single.shielded, 1);
    expect(events.single.failed, 1);
    expect(events.single.amount, closeTo(0.5 - provider.sideFee, 1e-12));
    provider.dispose();
  });

  test('the melt notification opens the Melt/Cast tab', () {
    final event = meltEvent(
      CompletedMelt(startedAt: DateTime.utc(2026, 11, 1), shielded: 3, failed: 1, amount: 1.5),
      (btc) => '$btc BTC',
    );

    expect(event.title, 'Melt complete on ZSide');
    expect(event.content, 'ZSide shielded 3 UTXOs, 1.5 BTC in all. 1 failed.');
    expect(event.tab.routeName, ZSideMeltCastTabRoute.name);
    expect(event.id, 'zside-melt-${DateTime.utc(2026, 11, 1).microsecondsSinceEpoch}');
  });
}
