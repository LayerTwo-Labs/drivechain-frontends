import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

/// Currency naming for the active network. Forknet and drynet are eCash, every
/// other network is Bitcoin.
class Ticker {
  const Ticker._(this.symbol, this.subunit, this.subunitLabel);

  /// Unit symbol shown next to whole amounts, e.g. "1.0000,0000 ECX".
  final String symbol;

  /// Smallest-unit name shown next to integer amounts, e.g. "150 000 sztorcs".
  final String subunit;

  /// Title-case [subunit] for menus and headings.
  final String subunitLabel;

  static const bitcoin = Ticker._('BTC', 'sats', 'Satoshis');
  static const ecash = Ticker._('ECX', 'sztorcs', 'Sztorcs');

  /// Fee rate unit, e.g. "sztorc/vB".
  String get feeRate => '${subunit.substring(0, subunit.length - 1)}/vB';
}

/// The active network's currency naming. Falls back to Bitcoin before the
/// provider is registered (tests, early boot).
Ticker get activeTicker {
  if (!GetIt.I.isRegistered<BitcoinConfProvider>()) return Ticker.bitcoin;
  return tickerForNetwork(GetIt.I.get<BitcoinConfProvider>().network);
}

Ticker tickerForNetwork(BitcoinNetwork network) {
  switch (network) {
    case BitcoinNetwork.BITCOIN_NETWORK_FORKNET:
    case BitcoinNetwork.BITCOIN_NETWORK_DRYNET:
      return Ticker.ecash;
    default:
      return Ticker.bitcoin;
  }
}
