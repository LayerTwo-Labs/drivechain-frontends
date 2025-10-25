import 'dart:math';
import 'dart:typed_data';
import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';

/// Generate a new Bitcoin keypair for paper wallets
class PaperWalletGenerator {
  /// Generate a new random keypair
  static PaperWalletKeypair generate() {
    // Generate random private key (32 bytes)
    final random = Random.secure();
    final privateKeyBytes = Uint8List(32);
    for (int i = 0; i < 32; i++) {
      privateKeyBytes[i] = random.nextInt(256);
    }

    // Create ECPrivateKey from bytes
    final privateKey = ECPrivate.fromBytes(privateKeyBytes);

    // Derive public key
    final publicKey = privateKey.getPublic();

    // Generate P2PKH address (legacy address starting with '1') for mainnet
    final p2pkhAddress = publicKey.toAddress();
    final address = p2pkhAddress.toAddress(BitcoinNetwork.mainnet);

    // Convert private key to WIF (Wallet Import Format) for mainnet
    final wif = privateKey.toWif();

    return PaperWalletKeypair(
      privateKeyWIF: wif,
      publicAddress: address,
      privateKeyHex: BytesUtils.toHexString(privateKeyBytes),
    );
  }

  /// Validate a WIF private key
  static bool isValidWIF(String wif) {
    try {
      ECPrivate.fromWif(wif);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Convert WIF to address (for verification)
  static String? wifToAddress(String wif) {
    try {
      final privateKey = ECPrivate.fromWif(wif);
      final publicKey = privateKey.getPublic();
      final p2pkhAddress = publicKey.toAddress();
      return p2pkhAddress.toAddress(BitcoinNetwork.mainnet);
    } catch (e) {
      return null;
    }
  }
}

/// Keypair result for paper wallet
class PaperWalletKeypair {
  final String privateKeyWIF;
  final String publicAddress;
  final String privateKeyHex;

  PaperWalletKeypair({
    required this.privateKeyWIF,
    required this.publicAddress,
    required this.privateKeyHex,
  });

  @override
  String toString() {
    return 'PaperWalletKeypair(\n'
        '  address: $publicAddress\n'
        '  privateKey (WIF): $privateKeyWIF\n'
        '  privateKey (hex): $privateKeyHex\n'
        ')';
  }
}
