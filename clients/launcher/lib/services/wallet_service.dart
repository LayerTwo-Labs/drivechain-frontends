import 'dart:convert';
import 'dart:io';
import 'package:bip39_mnemonic/bip39_mnemonic.dart';
import 'package:dart_bip32_bip44/dart_bip32_bip44.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;
import 'package:launcher/env.dart';
import 'package:logger/logger.dart';

class WalletService {
  final _logger = Logger();
  static const String defaultBip32Path = "m/44'/0'/0'";

  Future<bool> hasExistingWallet() async {
    final walletFile = await _getWalletFile();
    return walletFile.existsSync();
  }

  Future<Map<String, dynamic>> generateWallet({String? customMnemonic, String? passphrase}) async {
    try {
      final Mnemonic mnemonicObj;

      if (customMnemonic != null) {
        try {
          mnemonicObj = Mnemonic.fromSentence(
            customMnemonic,
            Language.english,
            passphrase: passphrase ?? '', // Empty string if no passphrase
          );
        } catch (e) {
          if (e.toString().contains('is not in the wordlist')) {
            return {'error': 'One or more words are not valid BIP39 words'};
          }
          rethrow;
        }
      } else {
        mnemonicObj = Mnemonic.generate(
          Language.english,
          entropyLength: 128,
          passphrase: passphrase ?? '',
        );
      }

      final seedHex = hex.encode(mnemonicObj.seed);

      final chain = Chain.seed(seedHex);
      final masterKey = chain.forPath('m') as ExtendedPrivateKey;

      final bip39Bin = _bytesToBinary(mnemonicObj.entropy);
      final checksumBits = _calculateChecksumBits(mnemonicObj.entropy);

      return {
        'mnemonic': mnemonicObj.sentence,
        'seed_hex': seedHex,
        'xprv': masterKey.toString(),
        'bip39_bin': bip39Bin,
        'bip39_csum': checksumBits,
        'bip39_csum_hex': hex.encode([int.parse(checksumBits, radix: 2)]),
      };
    } catch (e) {
      _logger.e('Error generating wallet: $e');
      return {'error': e.toString()};
    }
  }

  Future<ExtendedPrivateKey> getAccountKey(String xprv) async {
    final chain = Chain.import(xprv);
    return chain.forPath(defaultBip32Path) as ExtendedPrivateKey;
  }

  String _bytesToBinary(List<int> bytes) {
    return bytes.map((byte) => byte.toRadixString(2).padLeft(8, '0')).join('');
  }

  String _calculateChecksumBits(List<int> entropy) {
    final entropyBits = entropy.length * 8;
    final checksumSize = entropyBits ~/ 32;

    final hash = sha256.convert(entropy);
    final hashBits = _bytesToBinary(hash.bytes);
    return hashBits.substring(0, checksumSize);
  }

  Future<bool> saveWallet(Map<String, dynamic> walletData) async {
    try {
      final walletFile = await _getWalletFile();

      if (!walletFile.parent.existsSync()) {
        await walletFile.parent.create(recursive: true);
      }

      final requiredFields = [
        'mnemonic',
        'seed_hex',
        'xprv',
      ];

      for (final field in requiredFields) {
        if (!walletData.containsKey(field) || walletData[field] == null) {
          throw Exception('Missing required wallet field: $field');
        }
      }

      await walletFile.writeAsString(jsonEncode(walletData));
      return true;
    } catch (e) {
      _logger.e('Error saving wallet: $e');
      return false;
    }
  }

  Future<bool> deleteWallet() async {
    try {
      final walletFile = await _getWalletFile();
      if (await walletFile.exists()) {
        await walletFile.delete();
      }
      return true;
    } catch (e) {
      _logger.e('Error deleting wallet: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> loadWallet() async {
    try {
      final walletFile = await _getWalletFile();
      if (!await walletFile.exists()) return null;

      final walletJson = await walletFile.readAsString();
      final walletData = jsonDecode(walletJson) as Map<String, dynamic>;

      if (!walletData.containsKey('mnemonic') || !walletData.containsKey('xprv')) {
        throw Exception('Invalid wallet data format');
      }

      return walletData;
    } catch (e) {
      _logger.e('Error loading wallet: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> deriveSidechainStarter(int sidechainSlot) async {
    try {
      // Load master starter
      final masterWallet = await loadWallet();
      if (masterWallet == null) {
        _logger.e('Master starter not found');
        throw Exception('Master starter not found');
      }
      
      // Validate master wallet data
      if (!masterWallet.containsKey('xprv')) {
        _logger.e('Master starter is missing required field: xprv');
        throw Exception('Master starter is missing required field: xprv');
      }

      // Import master key and derive sidechain key
      final chain = Chain.import(masterWallet['xprv']);
      final sidechainPath = "m/44'/0'/$sidechainSlot'";
      final sidechainKey = chain.forPath(sidechainPath) as ExtendedPrivateKey;
      
      // Hash the private key with SHA256 to get proper entropy length
      final privateKeyBytes = hex.decode(sidechainKey.privateKeyHex());
      final entropy = sha256.convert(privateKeyBytes).bytes;
      
      final mnemonic = Mnemonic(entropy, Language.english);

      // Create a new chain from the mnemonic's seed to get a proper master key
      final sidechainChain = Chain.seed(hex.encode(mnemonic.seed));
      final sidechainMasterKey = sidechainChain.forPath('m') as ExtendedPrivateKey;

      // Create sidechain starter with new mnemonic and master key
      final sidechainStarter = {
        'mnemonic': mnemonic.sentence,
        'seed_hex': hex.encode(mnemonic.seed),
        'xprv': sidechainMasterKey.toString(),
        'parent_xprv': masterWallet['xprv'],
        'derivation_path': sidechainPath,
      };

      // Save to sidechain-specific file
      await _saveSidechainStarter(sidechainSlot, sidechainStarter);

      return sidechainStarter;
    } catch (e, stackTrace) {
      _logger.e('Error deriving sidechain starter: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<void> _saveSidechainStarter(int sidechainSlot, Map<String, dynamic> starterData) async {
    try {
      final appDir = await Environment.datadir();
      final walletDir = Directory(path.join(appDir.path, 'wallet_starters'));
      
      // Ensure wallet directory exists
      if (!walletDir.existsSync()) {
        await walletDir.create(recursive: true);
      }

      // Create sidechain starter file with clear naming
      final sidechainStarterFile = File(path.join(walletDir.path, 'sidechain_${sidechainSlot}_starter.json'));
      
      // Write data with proper formatting
      await sidechainStarterFile.writeAsString(
        JsonEncoder.withIndent('  ').convert(starterData),
      );
      
      // Verify file was written successfully
      if (!sidechainStarterFile.existsSync()) {
        throw Exception('Failed to write sidechain starter file: File does not exist after write');
      }
    } catch (e, stackTrace) {
      _logger.e('Error saving sidechain starter: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<File> _getWalletFile() async {
    final appDir = await Environment.datadir();
    final walletDir = Directory(path.join(appDir.path, 'wallet_starters'));
    return File(path.join(walletDir.path, 'master_starter.json'));
  }
}
