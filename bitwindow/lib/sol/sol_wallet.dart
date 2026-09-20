import 'package:bip39_mnemonic/bip39_mnemonic.dart' as bip39;
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:sidechain_core/bitcoin.dart';
import 'package:sidechain_core/gen/bitwindowd/v1/bitwindowd.pbenum.dart';

/// The sidechain slot of the SOL drivechain.
const int solSidechainSlot = 8;

/// The title that the slot 8 M1 carries.
///
/// BitWindow lists this beside Thunder and BitNames, so it is a display name.
const String solSidechainTitle = 'Solana';

/// The name that the wallet files the slot 8 seed phrase under.
const String solStarterName = 'SOL';

/// The eCash generation that the hosted SOL drivechain pegs to.
///
/// Every generation reads as `BITCOIN_NETWORK_ECASH`, so the enum alone names
/// the wrong chain on alphanet or drynet.
const String solEcashNetworkId = 'betanet';

/// True when this L1 is the one the hosted SOL drivechain pegs to.
bool solPegsToL1(BitcoinNetwork network, String ecashNetworkId) =>
    network == BitcoinNetwork.BITCOIN_NETWORK_ECASH && ecashNetworkId == solEcashNetworkId;

/// True when a slot carries the hosted SOL drivechain.
///
/// The slot and the title are not sufficient. The regtest harness claims slot
/// 8 with this same title, and its Solana chain is not the hosted one. A
/// balance from the wrong chain beside a real deposit misleads.
bool isSolSidechain(int slot, String? title, BitcoinNetwork network, String ecashNetworkId) =>
    slot == solSidechainSlot && title == solSidechainTitle && solPegsToL1(network, ecashNetworkId);

/// The peg is 1 SOL to 1 BTC, so one satoshi is ten lamports.
const int lamportsPerSat = 10;

/// The BIP44 derivation path of one Solana account.
///
/// `solana-keygen recover` and Phantom read this same path, so an address from
/// this wallet opens in either of them.
String solDerivationPath(int account) => "m/44'/501'/$account'/0'";

/// Builds the Solana address of one account from a BIP39 seed phrase.
///
/// BitWindow holds one seed phrase per sidechain slot. This turns the slot 8
/// phrase into the address that a peg in pays.
String solAddressFromMnemonic(String sentence, {int account = 0}) {
  final mnemonic = bip39.Mnemonic.fromSentence(sentence.trim(), bip39.Language.english);
  final master = Bip32Slip10Ed25519.fromSeed(mnemonic.seed);
  final child = master.derivePath(solDerivationPath(account));
  return SolAddrEncoder().encodeKey(child.publicKey.compressed);
}

/// True when a cached seed phrase still belongs to the active wallet.
///
/// A phrase belongs to one wallet. A phrase from another wallet derives an
/// address that the user cannot spend, so a peg in to it is lost.
bool cacheFitsWallet(String? cachedWalletId, String? activeWalletId) =>
    cachedWalletId != null && cachedWalletId == activeWalletId;

/// Reads a lamport count as satoshis. A part of a satoshi rounds down.
int satsFromLamports(int lamports) => lamports ~/ lamportsPerSat;

/// What the deposit view prints beside the SOL address button.
String solBalanceLabel({required bool loading, String? error, int? sats}) {
  if (loading) {
    return 'Reading the SOL balance...';
  }
  if (error != null) {
    return error;
  }
  if (sats == null) {
    return '';
  }
  return 'SOL balance: ${formatBitcoin(satoshiToBTC(sats), symbol: 'BTC')}';
}
