import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/sidechain_core.dart';

void main() {
  group('tickerForNetwork', () {
    test('the eCash network names the coin ECX', () {
      final ticker = tickerForNetwork(BitcoinNetwork.BITCOIN_NETWORK_ECASH);

      expect(ticker.symbol, 'ECX');
      expect(ticker.subunit, 'szats');
      expect(ticker.subunitLabel, 'Szats');
      expect(ticker.feeRate, 'szat/vB');
    });

    test('every other network names the coin BTC', () {
      for (final network in [
        BitcoinNetwork.BITCOIN_NETWORK_MAINNET,
        BitcoinNetwork.BITCOIN_NETWORK_SIGNET,
        BitcoinNetwork.BITCOIN_NETWORK_REGTEST,
      ]) {
        final ticker = tickerForNetwork(network);

        expect(ticker.symbol, 'BTC', reason: '$network');
        expect(ticker.subunit, 'sats', reason: '$network');
      }
    });
  });

  group('formatBitcoin', () {
    test('an amount takes the unit of the active network', () {
      // No BitcoinConfProvider runs in a test, so the ticker falls back to
      // Bitcoin. The symbol argument names the unit of another network.
      expect(formatBitcoin(1.0), endsWith('BTC'));
      expect(formatBitcoin(1.0, symbol: Ticker.ecash.symbol), endsWith('ECX'));
      expect(formatBitcoin(1.0, symbol: ''), isNot(contains('BTC')));
    });
  });
}
