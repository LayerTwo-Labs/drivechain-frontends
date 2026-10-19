import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/mocks/mocks.dart';
import 'package:sidechain_core/rpcs/bitcoind_connection.dart';
import 'package:sidechain_core/rpcs/zside_rpc.dart';
import 'package:zside/providers/zside_provider.dart';

import 'mocks/rpc_mock_zside.dart';

class _WalletRPC extends MockZSideRPC {
  List<String> owned = ['a1'];
  int newAddresses = 0;
  Object? fault;

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
}
