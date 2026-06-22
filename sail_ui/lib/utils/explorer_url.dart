import 'package:sail_ui/sail_ui.dart';

/// Resolve the explorer host for the active network. Mainnet is real Bitcoin,
/// so it points at mempool.space; the drivechain test networks each get their
/// own explorer. Regtest has no public explorer, so fall through to signet's.
String _explorerHost(BitcoinNetwork network) => switch (network) {
  BitcoinNetwork.BITCOIN_NETWORK_MAINNET => 'mempool.space',
  BitcoinNetwork.BITCOIN_NETWORK_FORKNET => 'explorer.forknet.drivechain.info',
  BitcoinNetwork.BITCOIN_NETWORK_TESTNET => 'explorer.testnet.drivechain.info',
  _ => 'explorer.signet.drivechain.info',
};

String mempoolAddressUrl(String address, BitcoinNetwork network) {
  return 'https://${_explorerHost(network)}/address/$address';
}

String mempoolTxUrl(String txid, BitcoinNetwork network) {
  return 'https://${_explorerHost(network)}/tx/$txid';
}
