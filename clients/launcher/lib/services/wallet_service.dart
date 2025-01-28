import 'dart:convert';
import 'dart:io';

import 'package:bip39_mnemonic/bip39_mnemonic.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:dart_bip32_bip44/dart_bip32_bip44.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:launcher/env.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/config/chains.dart';
import 'package:sail_ui/providers/binary_provider.dart';
import 'package:pointycastle/key_derivators/api.dart' show Pbkdf2Parameters;
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/macs/hmac.dart';
import 'package:pointycastle/digests/sha512.dart';

class WalletService extends ChangeNotifier {
  BinaryProvider get binaryProvider => GetIt.I.get<BinaryProvider>();

  final _logger = Logger();
  static const String defaultBip32Path = "m/44'/0'/0'";

  Future<bool> hasExistingWallet() async {
    final walletFile = await _getWalletFile('master_starter.json');
    return walletFile.existsSync();
  }

  Future<Map<String, dynamic>> generateWallet({String? customMnemonic, String? passphrase}) async {
    try {
      final Mnemonic mnemonicObj = customMnemonic != null 
        ? Mnemonic.fromSentence(customMnemonic, Language.english, passphrase: passphrase ?? '')
        : Mnemonic.generate(Language.english, entropyLength: 128, passphrase: passphrase ?? '');

      final seedHex = hex.encode(mnemonicObj.seed);
      
      // Create chain from seed
      final chain = Chain.seed(seedHex);
      final masterKey = chain.forPath('m') as ExtendedPrivateKey;

      final walletData = {
        'mnemonic': mnemonicObj.sentence,
        'seed_hex': seedHex,
        'master_key': masterKey.privateKeyHex(),
        'chain_code': hex.encode(masterKey.chainCode!),
        'bip39_binary': _bytesToBinary(mnemonicObj.entropy),
        'bip39_checksum': _calculateChecksumBits(mnemonicObj.entropy),
        'bip39_checksum_hex': hex.encode([int.parse(_calculateChecksumBits(mnemonicObj.entropy), radix: 2)]),
      };

      return walletData;
    } catch (e) {
      if (e.toString().contains('is not in the wordlist')) {
        return {'error': 'One or more words are not valid BIP39 words'};
      }
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> generateWalletFromEntropy(List<int> entropy, {String? passphrase}) async {
    try {
      // Create mnemonic from entropy
      final mnemonic = Mnemonic(entropy, Language.english);
      
      // Generate seed using PBKDF2-HMAC-SHA512
      final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA512Digest(), 128));
      final params = Pbkdf2Parameters(utf8.encode('Bitcoin seed'), 2048, 64);
      pbkdf2.init(params);
      
      // Use mnemonic sentence as the input key material
      final seedBytes = pbkdf2.process(utf8.encode(mnemonic.sentence + (passphrase ?? '')));
      final seedHex = hex.encode(seedBytes);
      
      // Create master key from seed
      final chain = Chain.seed(seedHex);
      final masterKey = chain.forPath('m') as ExtendedPrivateKey;

      return {
        'mnemonic': mnemonic.sentence,
        'seed_hex': seedHex,
        'bip39_binary': _bytesToBinary(mnemonic.entropy),
        'bip39_checksum': _calculateChecksumBits(mnemonic.entropy),
        'bip39_checksum_hex': hex.encode([int.parse(_calculateChecksumBits(mnemonic.entropy), radix: 2)]),
        'master_key': masterKey.privateKeyHex(),
        'chain_code': hex.encode(masterKey.chainCode!),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
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
      walletData['name'] = 'Master';

      final requiredFields = ['mnemonic', 'seed_hex', 'master_key'];
      for (final field in requiredFields) {
        if (!walletData.containsKey(field) || walletData[field] == null) {
          throw Exception('Missing required wallet field: $field');
        }
      }

      await _ensureWalletDir();
      final walletFile = await _getWalletFile('master_starter.json');
      await walletFile.writeAsString(jsonEncode(walletData));
      notifyListeners();
      return true;
    } catch (e) {
      _logger.e('Error saving wallet: $e');
      return false;
    }
  }

  Future<bool> deleteWallet() async {
    try {
      final walletFile = await _getWalletFile('master_starter.json');
      if (await walletFile.exists()) {
        await walletFile.delete();
        notifyListeners();
      }
      return true;
    } catch (e) {
      _logger.e('Error deleting wallet: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> loadWallet() async {
    try {
      final walletFile = await _getWalletFile('master_starter.json');
      if (!await walletFile.exists()) return null;

      final walletJson = await walletFile.readAsString();
      final walletData = jsonDecode(walletJson) as Map<String, dynamic>;

      if (!walletData.containsKey('mnemonic') || !walletData.containsKey('master_key')) {
        throw Exception('Invalid wallet data format');
      }

      return walletData;
    } catch (e) {
      _logger.e('Error loading wallet: $e');
      return null;
    }
  }

  /// Derive a starter from the master wallet using a specific derivation path
  Future<Map<String, dynamic>> _deriveStarter(String derivationPath, {String? name}) async {
    try {
      // Load and validate master wallet
      final masterWallet = await loadWallet();
      if (masterWallet == null) {
        throw Exception('Master starter not found');
      }
      if (!masterWallet.containsKey('seed_hex')) {
        throw Exception('Master starter is missing required field: seed_hex');
      }

      // Create chain from seed hex and derive key
      final chain = Chain.seed(masterWallet['seed_hex']);
      final derivedKey = chain.forPath(derivationPath) as ExtendedPrivateKey;

      // Generate new entropy from derived key
      final privateKeyBytes = hex.decode(derivedKey.privateKeyHex());
      final hashedKey = sha256.convert(privateKeyBytes).bytes;
      final entropy = hashedKey.sublist(0, 16);

      // Create new mnemonic from entropy
      final mnemonic = Mnemonic(entropy, Language.english);
      final seedHex = hex.encode(mnemonic.seed);

      return {
        'mnemonic': mnemonic.sentence,
        'seed_hex': seedHex,
        'master_key': derivedKey.privateKeyHex(),
        'chain_code': hex.encode(derivedKey.chainCode!),
        'parent_master_key': masterWallet['master_key'],
        'derivation_path': derivationPath,
        if (name != null) 'name': name,
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> deriveSidechainStarter(int sidechainSlot) async {
    try {
      final binary =
          binaryProvider.binaries.where((binary) => binary is Sidechain && binary.slot == sidechainSlot).firstOrNull;
      if (binary == null) {
        throw Exception('Could not find chain config for sidechain slot $sidechainSlot');
      }

      final starterData = await _deriveStarter(
        "m/44'/0'/$sidechainSlot'",
        name: binary.name,
      );

      // Save to sidechain-specific file
      await _saveMnemonicStarter('sidechain_${sidechainSlot}_starter.txt', starterData['mnemonic']);

      return starterData;
    } catch (e, stackTrace) {
      _logger.e('Error deriving sidechain starter: $e\n$stackTrace');
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> deriveL1Starter() async {
    try {
      final starterData = await _deriveStarter(
        "m/44'/0'/256'",
        name: 'Bitcoin Core (Patched)',
      );
      starterData['chain_layer'] = 1;

      // Save to L1-specific file
      await _saveMnemonicStarter('l1_starter.txt', starterData['mnemonic']);

      return starterData;
    } catch (e, stackTrace) {
      _logger.e('Error deriving L1 starter: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<void> deleteL1Starter() async {
    await _deleteStarter('l1_starter.txt');
  }

  Future<String?> loadL1Starter() async {
    return _loadMnemonicStarter('l1_starter.txt');
  }

  Future<String?> loadSidechainStarter(int sidechainSlot) async {
    return _loadMnemonicStarter('sidechain_${sidechainSlot}_starter.txt');
  }

  Future<void> deleteSidechainStarter(int sidechainSlot) async {
    await _deleteStarter('sidechain_${sidechainSlot}_starter.txt');
  }

  Future<String?> _loadMnemonicStarter(String fileName) async {
    try {
      final file = await _getWalletFile(fileName);
      if (!file.existsSync()) return null;
      return await file.readAsString();
    } catch (e) {
      _logger.e('Error loading starter $fileName: $e');
      return null;
    }
  }

  Future<void> _saveMnemonicStarter(String fileName, String mnemonic) async {
    try {
      await _ensureWalletDir();
      final file = await _getWalletFile(fileName);
      await file.writeAsString(mnemonic);
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('Error saving starter $fileName: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<void> _deleteStarter(String fileName) async {
    try {
      final file = await _getWalletFile(fileName);
      if (file.existsSync()) {
        await file.delete();
        notifyListeners();
      }
    } catch (e, stackTrace) {
      _logger.e('Error deleting starter $fileName: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<File> _getWalletFile(String fileName) async {
    final walletDir = await _getWalletDir();
    return File(path.join(walletDir.path, fileName));
  }

  Future<Directory> _getWalletDir() async {
    final appDir = await Environment.appDir();
    return Directory(path.join(appDir.path, 'wallet_starters'));
  }

  Future<void> _ensureWalletDir() async {
    final walletDir = await _getWalletDir();
    if (!walletDir.existsSync()) {
      await walletDir.create(recursive: true);
    }
  }

  Future<void> generateStartersForDownloadedChains() async {
    try {
      final binaries = binaryProvider.binaries;

      // Check for downloaded L1 chain first
      final l1Chain = binaries.firstWhere((b) => b.chainLayer == 1);
      
      final appDir = await Environment.appDir();
      final assetsDir = Directory(path.join(appDir.path, 'assets'));
      final binaryPath = path.join(assetsDir.path, l1Chain.binary);

      if (File(binaryPath).existsSync()) {
        await deriveL1Starter();
      }

      // For each L2 chain in binaries
      final l2Chains = binaryProvider.getL2Chains();
      
      for (final chain in l2Chains) {
        if (chain is Sidechain) {
          final binaryPath = path.join(assetsDir.path, chain.binary);
          
          if (File(binaryPath).existsSync()) {
            try {
              await deriveSidechainStarter(chain.slot);
            } catch (e) {
              _logger.e('Error deriving starter for ${chain.name}: $e');
            }
          }
        }
      }

      // Notify listeners after all starters are generated
      notifyListeners();
    } catch (e, stack) {
      _logger.e('Error generating starters for downloaded chains: $e\n$stack');
    }
  }
}
