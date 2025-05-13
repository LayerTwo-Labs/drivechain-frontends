import 'dart:io';

import 'package:bip39_mnemonic/bip39_mnemonic.dart';
import 'package:bs58/bs58.dart';
import 'package:convert/convert.dart';
import 'package:dart_bip32_bip44/dart_bip32_bip44.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pointycastle/digests/ripemd160.dart';
import 'package:pointycastle/digests/sha256.dart';

class HDWalletProvider extends ChangeNotifier {
  Logger get log => GetIt.I.get<Logger>();

  String? _seedHex;
  String? _masterKey;
  String? _error;
  bool _initialized = false;
  final bool _isProcessing = false;
  String? _mnemonic;

  String? get seedHex => _seedHex;
  String? get masterKey => _masterKey;
  String? get error => _error;
  bool get isInitialized => _initialized;
  bool get isProcessing => _isProcessing;
  String? get mnemonic => _mnemonic;

  Future<void> init() async {
    if (_initialized) return;

    try {
      await _loadMnemonic();
      notifyListeners();
    } catch (e) {
      _error = "Couldn't sync to wallet for HD Explorer";
      notifyListeners();
    }
  }

  Future<String> _getMnemonicPath() async {
    final downloadsDir = await getDownloadsDirectory();
    if (downloadsDir == null) {
      throw Exception('Could not determine downloads directory');
    }
    return path.join(
      downloadsDir.path,
      'Drivechain-Launcher-Downloads',
      'enforcer',
      'mnemonic',
      'mnemonic.txt',
    );
  }

  Future<bool> loadMnemonic() async {
    try {
      await _loadMnemonic();
      return true;
    } catch (e) {
      _error = "Couldn't load wallet mnemonic: $e";
      notifyListeners();
      return false;
    }
  }

  Future<void> _loadMnemonic() async {
    try {
      final mnemonicPath = await _getMnemonicPath();
      final file = File(mnemonicPath);
      if (!await file.exists()) {
        throw Exception("Couldn't sync to wallet for HD Explorer");
      }

      _mnemonic = (await file.readAsString()).trim();
      final mnemonicObj = Mnemonic.fromSentence(_mnemonic!, Language.english);
      _seedHex = hex.encode(mnemonicObj.seed);

      final chain = Chain.seed(_seedHex!);
      final masterKey = chain.forPath('m');
      _masterKey = masterKey.privateKeyHex();

      _error = null;
      _initialized = true;
    } catch (e) {
      _error = "Couldn't sync to wallet for HD Explorer";
      _seedHex = _masterKey = _mnemonic = null;
      _initialized = false;
    }
  }

  Future<bool> validateMnemonic(String mnemonic) async {
    try {
      Mnemonic.fromSentence(mnemonic, Language.english);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String> generateRandomMnemonic() async {
    try {
      final mnemonic = Mnemonic.generate(
        Language.english,
        entropyLength: 128,
        passphrase: 'layertwolabs',
      );
      return mnemonic.sentence;
    } catch (e) {
      _error = 'Error generating random mnemonic';
      notifyListeners();
      return '';
    }
  }

  // Combined key derivation method that can return any needed info
  Future<Map<String, String>> deriveKeyInfo(String mnemonic, String path) async {
    try {
      final mnemonicObj = Mnemonic.fromSentence(mnemonic, Language.english);
      final seedHex = hex.encode(mnemonicObj.seed);
      final chain = Chain.seed(seedHex);
      final extendedPrivateKey = chain.forPath(path) as ExtendedPrivateKey;
      final privateKeyHex = extendedPrivateKey.privateKeyHex();
      final publicKey = extendedPrivateKey.publicKey();

      // Return empty results if something is wrong
      final q = publicKey.q;
      if (q == null) return {};

      final pubKeyBytes = q.getEncoded(true);
      final pubKeyHex = hex.encode(pubKeyBytes);

      // Derive Bitcoin address
      final sha256Digest = SHA256Digest();
      final ripemd160 = RIPEMD160Digest();
      final sha256Result = sha256Digest.process(Uint8List.fromList(pubKeyBytes));
      final pubKeyHash = ripemd160.process(sha256Result);

      final versionedHash = Uint8List(21);
      versionedHash[0] = 0x00; // Version byte for mainnet
      versionedHash.setRange(1, 21, pubKeyHash);

      final hash1 = sha256Digest.process(versionedHash);
      final hash2 = sha256Digest.process(hash1);
      final checksum = hash2.sublist(0, 4);

      final addressBytes = Uint8List(25);
      addressBytes.setRange(0, 21, versionedHash);
      addressBytes.setRange(21, 25, checksum);
      final address = base58.encode(addressBytes);

      // Derive WIF
      final cleanHex = privateKeyHex.startsWith('00') ? privateKeyHex.substring(2) : privateKeyHex;
      final privateKeyBytes = hex.decode(cleanHex);

      final wifBuffer = Uint8List(34);
      wifBuffer[0] = 0x80; // Version byte for mainnet private key
      wifBuffer.setRange(1, 33, privateKeyBytes);
      wifBuffer[33] = 0x01; // Compression byte

      final wifHash1 = sha256Digest.process(wifBuffer);
      final wifHash2 = sha256Digest.process(wifHash1);
      final wifChecksum = wifHash2.sublist(0, 4);

      final wifBytes = Uint8List(38);
      wifBytes.setRange(0, 34, wifBuffer);
      wifBytes.setRange(34, 38, wifChecksum);
      final wif = base58.encode(wifBytes);

      return {
        'privateKey': privateKeyHex,
        'publicKey': pubKeyHex,
        'address': address,
        'wif': wif,
      };
    } catch (e) {
      return {};
    }
  }
}
