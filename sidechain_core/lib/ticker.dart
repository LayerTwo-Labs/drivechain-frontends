import 'package:get_it/get_it.dart';
import 'package:sidechain_core/sidechain_core.dart';

/// Currency naming for the active network. eCash is eCash, every other
/// network is Bitcoin. Each eCash test network prefixes its own letter.
class Ticker {
  const Ticker._(this.name, this.symbol, this.subunit, this.subunitSingular, this.subunitLabel);

  /// Coin name for prose, e.g. "eCash".
  final String name;

  /// Unit symbol shown next to whole amounts, e.g. "1.0000,0000 ECX".
  final String symbol;

  /// Smallest-unit name shown next to integer amounts, e.g. "150 000 szats".
  final String subunit;

  /// Singular [subunit], used by rate units.
  final String subunitSingular;

  /// Title-case [subunit] for menus and headings.
  final String subunitLabel;

  static const bitcoin = Ticker._('Bitcoin', 'BTC', 'sats', 'sat', 'Satoshis');
  static const ecash = Ticker._('eCash', 'ECX', 'szats', 'szat', 'Szats');
  static const alphanet = Ticker._('eCash', 'aECX', 'szats', 'szat', 'Szats');
  static const betanet = Ticker._('eCash', 'bECX', 'szats', 'szat', 'Szats');

  /// Fee rate unit, e.g. "szat/vB".
  String get feeRate => '$subunitSingular/vB';
}

/// The active network's currency naming. Falls back to Bitcoin before the
/// provider is registered (tests, early boot).
Ticker get activeTicker {
  if (!GetIt.I.isRegistered<BitcoinConfProvider>()) {
    return Ticker.bitcoin;
  }
  return tickerForNetwork(GetIt.I.get<BitcoinConfProvider>().network, ecashNetworkId: ecashNetworkId());
}

/// [ecashNetworkId] is the catalog id of the live eCash network, e.g. "betanet".
Ticker tickerForNetwork(BitcoinNetwork network, {String ecashNetworkId = ''}) {
  if (network != BitcoinNetwork.BITCOIN_NETWORK_ECASH) {
    return Ticker.bitcoin;
  }
  return switch (ecashNetworkId) {
    'alphanet' => Ticker.alphanet,
    'betanet' => Ticker.betanet,
    _ => Ticker.ecash,
  };
}
