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

  Future<File> _getWalletFile() async {
    final appDir = await Environment.datadir();
    final walletDir = Directory(path.join(appDir.path, 'wallet_starters'));
    return File(path.join(walletDir.path, 'master_starter.json'));
  }
}
