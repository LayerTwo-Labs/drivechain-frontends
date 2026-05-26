import 'package:sail_ui/sail_ui.dart';

/// Resolve the explorer host for the active network. Mainnet sits at the
/// bare `explorer.drivechain.info`; every other network gets its own
/// subdomain. Regtest has no public explorer, so fall through to signet's.
String _explorerHost(BitcoinNetwork network) => switch (network) {
  BitcoinNetwork.BITCOIN_NETWORK_MAINNET => 'explorer.drivechain.info',
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
