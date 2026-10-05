import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/sidechain_core.dart';

void main() {
  test('truthcoin lists the RPC names of release 0.20', () {
    expect(truthcoinRPCMethods, containsAll(['balance', 'create_transfer', 'create_withdrawal']));
    expect(truthcoinRPCMethods, isNot(contains(anyOf('bitcoin_balance', 'transfer', 'withdraw'))));
  });
}
