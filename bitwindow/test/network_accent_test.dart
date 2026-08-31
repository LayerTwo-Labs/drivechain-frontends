import 'package:bitwindow/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/sidechain_core.dart';

void main() {
  test('the app accent is the colour the network carries', () {
    for (final network in [
      BitcoinNetwork.BITCOIN_NETWORK_MAINNET,
      BitcoinNetwork.BITCOIN_NETWORK_ECASH,
      BitcoinNetwork.BITCOIN_NETWORK_SIGNET,
      BitcoinNetwork.BITCOIN_NETWORK_REGTEST,
    ]) {
      expect(getNetworkAccentColor(network), network.toColor(), reason: '$network');
    }
  });

  test('alphanet wears red and regtest wears grey, never the other way round', () {
    expect(getNetworkAccentColor(BitcoinNetwork.BITCOIN_NETWORK_ECASH), SailColorScheme.red);
    expect(getNetworkAccentColor(BitcoinNetwork.BITCOIN_NETWORK_REGTEST), SailColorScheme.greyMiddle);
  });

  test('a network with no colour of its own wears grey', () {
    expect(getNetworkAccentColor(BitcoinNetwork.BITCOIN_NETWORK_TESTNET), SailColorScheme.greyMiddle);
    expect(getNetworkAccentColor(BitcoinNetwork.BITCOIN_NETWORK_FORKNET), SailColorScheme.greyMiddle);
  });
}
