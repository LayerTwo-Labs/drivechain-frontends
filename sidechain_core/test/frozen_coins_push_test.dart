import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sidechain_core/sidechain_core.dart';

/// Reads the outpoint a [OrchestratorWalletRPC] would hand over, without a
/// transport. The mapper is the part that can turn a stored outpoint into a
/// request the orchestrator refuses.
wmpb.FrozenOutpoint map(String outpoint) {
  return OrchestratorWalletRPC.frozenOutpointOf(outpoint);
}

void main() {
  group('a frozen outpoint', () {
    test('reads a txid and a vout', () {
      final coin = map('aa:12');
      expect(coin.txid, 'aa');
      expect(coin.vout, 12);
    });

    test('refuses a string with no vout', () {
      expect(() => map('aa'), throwsArgumentError);
    });

    test('refuses a vout that is not a number', () {
      expect(() => map('aa:x'), throwsArgumentError);
    });

    test('refuses an empty txid', () {
      expect(() => map(':0'), throwsArgumentError);
    });

    test('refuses a negative vout', () {
      expect(() => map('aa:-1'), throwsArgumentError);
    });
  });
}
