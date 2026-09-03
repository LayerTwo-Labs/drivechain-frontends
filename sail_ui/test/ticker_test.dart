import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

void main() {
  group('tickerForNetwork', () {
    test('eCash is eCash', () {
      expect(tickerForNetwork(BitcoinNetwork.BITCOIN_NETWORK_ECASH), Ticker.ecash);
    });

    test('every other network is Bitcoin', () {
      for (final n in [
        BitcoinNetwork.BITCOIN_NETWORK_MAINNET,
        BitcoinNetwork.BITCOIN_NETWORK_SIGNET,
        BitcoinNetwork.BITCOIN_NETWORK_TESTNET,
        BitcoinNetwork.BITCOIN_NETWORK_REGTEST,
        BitcoinNetwork.BITCOIN_NETWORK_UNKNOWN,
        BitcoinNetwork.BITCOIN_NETWORK_UNSPECIFIED,
      ]) {
        expect(tickerForNetwork(n), Ticker.bitcoin, reason: '$n must stay BTC');
      }
    });

    test('naming', () {
      expect(Ticker.ecash.symbol, 'ECX');
      expect(Ticker.ecash.subunit, 'szats');
      expect(Ticker.ecash.subunitLabel, 'Szats');
      expect(Ticker.ecash.feeRate, 'szat/vB');

      expect(Ticker.bitcoin.symbol, 'BTC');
      expect(Ticker.bitcoin.subunit, 'sats');
      expect(Ticker.bitcoin.feeRate, 'sat/vB');
    });
  });

  // Formatting runs before the provider is registered (tests, early boot) and
  // must not throw.
  test('falls back to Bitcoin with no provider registered', () {
    expect(activeTicker, Ticker.bitcoin);
    expect(formatBitcoin(1.5), '1.5000,0000 BTC');
    expect(formatSatoshis(150000), '150 000 sats');
    expect(formatSatoshis(0), '0 sats');
  });

  test('an explicit symbol still wins, including empty', () {
    expect(formatBitcoin(1.5, symbol: ''), '1.5000,0000');
    expect(formatBitcoin(1.5, symbol: 'XYZ'), '1.5000,0000 XYZ');
  });
}
