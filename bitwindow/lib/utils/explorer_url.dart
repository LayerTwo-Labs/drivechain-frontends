import 'package:sail_ui/sail_ui.dart';

/// Build a block-explorer address URL for the active network. Forknet has a
/// dedicated drivechain explorer; everything else falls through to
/// mempool.space (with /signet as a sensible default for regtest, which isn't
/// hosted anywhere public).
String mempoolAddressUrl(String address, BitcoinNetwork network) {
  if (network == BitcoinNetwork.BITCOIN_NETWORK_FORKNET) {
    return 'https://explorer.forknet.drivechain.info/address/$address';
  }
  final prefix = switch (network) {
    BitcoinNetwork.BITCOIN_NETWORK_MAINNET => '',
    BitcoinNetwork.BITCOIN_NETWORK_TESTNET => '/testnet',
    _ => '/signet',
  };
  return 'https://mempool.space$prefix/address/$address';
}
