import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sidechain_core/sidechain_core.dart';

class _Conf extends ChangeNotifier implements BitcoinConfProvider {
  @override
  BitcoinNetwork network = BitcoinNetwork.BITCOIN_NETWORK_ECASH;

  @override
  String ecashNetworkId = '';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('tickerForNetwork', () {
    test('the eCash network names the coin ECX', () {
      final ticker = tickerForNetwork(BitcoinNetwork.BITCOIN_NETWORK_ECASH);

      expect(ticker.symbol, 'ECX');
      expect(ticker.subunit, 'szats');
      expect(ticker.subunitLabel, 'Szats');
      expect(ticker.feeRate, 'szat/vB');
    });

    test('alphanet names the coin aECX', () {
      final ticker = tickerForNetwork(BitcoinNetwork.BITCOIN_NETWORK_ECASH, ecashNetworkId: 'alphanet');

      expect(ticker.symbol, 'aECX');
      expect(ticker.subunit, 'szats');
    });

    test('betanet names the coin bECX', () {
      final ticker = tickerForNetwork(BitcoinNetwork.BITCOIN_NETWORK_ECASH, ecashNetworkId: 'betanet');

      expect(ticker.symbol, 'bECX');
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

  group('activeTicker', () {
    tearDown(() => GetIt.I.reset());

    test('names the coin of the live eCash network', () {
      GetIt.I.registerSingleton<BitcoinConfProvider>(_Conf()..ecashNetworkId = 'alphanet');

      expect(activeTicker.symbol, 'aECX');
    });

    test('an empty network id takes the eCash network the build shipped with', () {
      GetIt.I.registerSingleton<BitcoinConfProvider>(_Conf());

      expect(activeTicker, tickerForNetwork(BitcoinNetwork.BITCOIN_NETWORK_ECASH, ecashNetworkId: ecashNetworkId()));
      expect(activeTicker, isNot(Ticker.ecash));
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
