import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/sidechain_core.dart';

void main() {
  test('every network a user picks carries its own colour', () {
    expect(BitcoinNetwork.BITCOIN_NETWORK_MAINNET.toColor(), SailColorScheme.orange);
    expect(BitcoinNetwork.BITCOIN_NETWORK_ECASH.toColor(), SailColorScheme.red);
    expect(BitcoinNetwork.BITCOIN_NETWORK_SIGNET.toColor(), SailColorScheme.blue);
    expect(BitcoinNetwork.BITCOIN_NETWORK_REGTEST.toColor(), SailColorScheme.greyMiddle);
  });

  test('no two networks share a colour, or a user cannot tell them apart', () {
    final coloured = [
      BitcoinNetwork.BITCOIN_NETWORK_MAINNET,
      BitcoinNetwork.BITCOIN_NETWORK_ECASH,
      BitcoinNetwork.BITCOIN_NETWORK_SIGNET,
      BitcoinNetwork.BITCOIN_NETWORK_REGTEST,
    ].map((n) => n.toColor()).toSet();
    expect(coloured.length, 4);
  });

  test('a network with no colour of its own answers none', () {
    expect(BitcoinNetwork.BITCOIN_NETWORK_TESTNET.toColor(), isNull);
    expect(BitcoinNetwork.BITCOIN_NETWORK_UNSPECIFIED.toColor(), isNull);
  });
}
