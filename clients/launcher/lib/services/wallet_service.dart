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

class WalletService extends ChangeNotifier {
  BinaryProvider get binaryProvider => GetIt.I.get<BinaryProvider>();

  final _logger = Logger();
  static const String defaultBip32Path = "m/44'/0'/0'";

  Future<bool> hasExistingWallet() async {
    final walletFile = await _getWalletFile();
    return walletFile.existsSync();
  }

  Future<Map<String, dynamic>> generateWalletFromEntropy(List<int> entropy) async {
    try {
      // Create mnemonic from entropy
      final mnemonic = Mnemonic(entropy, Language.english);
      
      // Get seed from mnemonic
      final seedHex = hex.encode(mnemonic.seed);

      // Create HD wallet chain
      final chain = Chain.seed(seedHex);
      final masterKey = chain.forPath('m') as ExtendedPrivateKey;

      // Get binary representation and checksum
      final bip39Bin = _bytesToBinary(mnemonic.entropy);
      final checksumBits = _calculateChecksumBits(mnemonic.entropy);

      return {
        'mnemonic': mnemonic.sentence,
        'seed_hex': seedHex,
        'xprv': masterKey.toString(),
        'bip39_bin': bip39Bin,
        'bip39_csum': checksumBits,
        'bip39_csum_hex': hex.encode([int.parse(checksumBits, radix: 2)]),
      };
    } catch (e) {
      _logger.e('Error generating wallet from entropy: $e');
      return {'error': e.toString()};
    }
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

      // Add name field for master starter
      walletData['name'] = 'Master';

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
      final walletFile = await _getWalletFile();
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

      // Hash the private key and take first 16 bytes for 128-bit entropy
      final privateKeyBytes = hex.decode(sidechainKey.privateKeyHex());
      final hashedKey = sha256.convert(privateKeyBytes).bytes;
      final entropy = hashedKey.sublist(0, 16);

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
    } finally {
      notifyListeners();
    }
  }

  Future<void> _saveSidechainStarter(int sidechainSlot, Map<String, dynamic> starterData) async {
    try {
      final appDir = await Environment.appDir();
      final walletDir = Directory(path.join(appDir.path, 'wallet_starters'));

      final binary =
          binaryProvider.binaries.where((binary) => binary is Sidechain && binary.slot == sidechainSlot).firstOrNull;
      if (binary == null) {
        throw Exception('Could not find chain config for sidechain slot $sidechainSlot');
      }

      // Add name to starter data
      starterData['name'] = binary.name;

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

      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('Error saving sidechain starter: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<File> _getWalletFile() async {
    final appDir = await Environment.appDir();
    final walletDir = Directory(path.join(appDir.path, 'wallet_starters'));
    return File(path.join(walletDir.path, 'master_starter.json'));
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
      for (final chain in binaryProvider.getL2Chains()) {
        if (chain is Sidechain) {
          final binaryPath = path.join(assetsDir.path, chain.binary);
          if (File(binaryPath).existsSync()) {
            await deriveSidechainStarter(chain.slot);
          }
        }
      }

      // Notify listeners after all starters are generated
      notifyListeners();
    } catch (e, stack) {
      debugPrint('Error generating starters: $e\n$stack');
    }
  }

  Future<Map<String, dynamic>?> deriveL1Starter() async {
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

      // Import master key and derive L1 key with fixed path
      final chain = Chain.import(masterWallet['xprv']);
      const l1Path = "m/44'/0'/256'";
      final l1Key = chain.forPath(l1Path) as ExtendedPrivateKey;

      // Hash the private key and take first 16 bytes for 128-bit entropy
      final privateKeyBytes = hex.decode(l1Key.privateKeyHex());
      final hashedKey = sha256.convert(privateKeyBytes).bytes;
      final entropy = hashedKey.sublist(0, 16);

      final mnemonic = Mnemonic(entropy, Language.english);

      // Create a new chain from the mnemonic's seed to get a proper master key
      final l1Chain = Chain.seed(hex.encode(mnemonic.seed));
      final l1MasterKey = l1Chain.forPath('m') as ExtendedPrivateKey;

      // Create L1 starter with new mnemonic and master key
      final l1Starter = {
        'mnemonic': mnemonic.sentence,
        'seed_hex': hex.encode(mnemonic.seed),
        'xprv': l1MasterKey.toString(),
        'parent_xprv': masterWallet['xprv'],
        'derivation_path': l1Path,
        'name': 'Bitcoin Core (Patched)',
        'chain_layer': 1,
      };

      // Save to L1-specific file
      await _saveL1Starter(l1Starter);

      return l1Starter;
    } catch (e, stackTrace) {
      _logger.e('Error deriving L1 starter: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<void> _saveL1Starter(Map<String, dynamic> starterData) async {
    try {
      final appDir = await Environment.appDir();
      final walletDir = Directory(path.join(appDir.path, 'wallet_starters'));

      // Ensure wallet directory exists
      if (!walletDir.existsSync()) {
        await walletDir.create(recursive: true);
      }

      // Create L1 starter file
      final l1StarterFile = File(path.join(walletDir.path, 'l1_starter.json'));

      // Write data with proper formatting
      await l1StarterFile.writeAsString(
        JsonEncoder.withIndent('  ').convert(starterData),
      );

      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('Error saving L1 starter: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<void> deleteL1Starter() async {
    try {
      final appDir = await Environment.appDir();
      final walletDir = Directory(path.join(appDir.path, 'wallet_starters'));
      final l1StarterFile = File(path.join(walletDir.path, 'l1_starter.json'));

      if (l1StarterFile.existsSync()) {
        await l1StarterFile.delete();
      }

      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('Error deleting L1 starter: $e\n$stackTrace');
      rethrow;
    }
  }
}
