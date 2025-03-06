import 'dart:io';

import 'package:bip39_mnemonic/bip39_mnemonic.dart';
import 'package:bs58/bs58.dart';
import 'package:convert/convert.dart';
import 'package:dart_bip32_bip44/dart_bip32_bip44.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:pointycastle/digests/ripemd160.dart';
import 'package:pointycastle/digests/sha256.dart';

class HDWalletProvider extends ChangeNotifier {
  Logger get log => GetIt.I.get<Logger>();

  String? _seedHex;
  String? _masterKey;
  String? _error;
  bool _initialized = false;

  String? get seedHex => _seedHex;
  String? get masterKey => _masterKey;
  String? get error => _error;
  bool get isInitialized => _initialized;

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

  Future<List<String>> _getMnemonicPaths() async {
    var mnemonicPaths = <String>[];
    String base = '';

    if (Platform.isMacOS) {
      base = '${Platform.environment['HOME']}/Library/Application Support';
    } else if (Platform.isLinux) {
      base = '${Platform.environment['HOME']}/.config';
    } else if (Platform.isWindows) {
      base = Platform.environment['APPDATA']!;
    } else {
      throw Exception('Unsupported platform');
    }

    mnemonicPaths.add(path.join(base, 'com.layertwolabs.launcher', 'wallet_starters', 'mnemonics', 'l1.txt'));
    mnemonicPaths.add(path.join(base, 'drivechain-launcher', 'wallet_starters', 'mnemonics', 'l1.txt'));

    return mnemonicPaths;
  }

  Future<void> _loadMnemonic() async {
    try {
      final paths = await _getMnemonicPaths();
      File? file;

      for (final path in paths) {
        try {
          file = File(path);
          if (await file.exists()) {
            break;
          }
        } catch (e) {
          log.e('could not load mnemonic from $path: $e');
        }
      }

      if (file == null) {
        throw Exception("Couldn't sync to wallet for HD Explorer");
      }

      final mnemonic = (await file.readAsString()).trim();
      final mnemonicObj = Mnemonic.fromSentence(mnemonic, Language.english);
      _seedHex = hex.encode(mnemonicObj.seed);

      final chain = Chain.seed(_seedHex!);
      final masterKey = chain.forPath('m');
      _masterKey = masterKey.privateKeyHex();

      _error = null;
      _initialized = true;
    } catch (e) {
      _error = "Couldn't sync to wallet for HD Explorer";
      _seedHex = null;
      _masterKey = null;
      _initialized = false;
    }
  }

  Future<String> derivePrivateKey(String path) async {
    log.d('Attempting to derive private key, initialized: $_initialized');
    if (!_initialized) await init();

    try {
      final chain = Chain.seed(_seedHex!);
      final extendedPrivateKey = chain.forPath(path) as ExtendedPrivateKey;
      return extendedPrivateKey.privateKeyHex();
    } catch (e) {
      log.e('Error deriving private key: $e');
      return '';
    }
  }

  Future<String> deriveWIF(String path) async {
    try {
      final privateKeyHex = await derivePrivateKey(path);
      final cleanHex = privateKeyHex.startsWith('00') ? privateKeyHex.substring(2) : privateKeyHex;
      final privateKeyBytes = hex.decode(cleanHex);

      final buffer = Uint8List(34);
      buffer[0] = 0x80; // Version byte for mainnet private key
      buffer.setRange(1, 33, privateKeyBytes);
      buffer[33] = 0x01; // Compression byte

      final hash1 = SHA256Digest().process(buffer);
      final hash2 = SHA256Digest().process(hash1);
      final checksum = hash2.sublist(0, 4);

      final wifBytes = Uint8List(38);
      wifBytes.setRange(0, 34, buffer);
      wifBytes.setRange(34, 38, checksum);

      return base58.encode(wifBytes);
    } catch (e) {
      log.e('Error deriving WIF: $e');
      return '';
    }
  }

  Future<String> deriveAddress(String path) async {
    if (!_initialized) await init();

    try {
      final chain = Chain.seed(_seedHex!);
      final extendedPrivateKey = chain.forPath(path) as ExtendedPrivateKey;
      final publicKey = extendedPrivateKey.publicKey();

      final q = publicKey.q;
      if (q == null) {
        log.e('Public key point is null');
        return '';
      }

      final pubKeyBytes = q.getEncoded(true);
      final sha256Result = SHA256Digest().process(Uint8List.fromList(pubKeyBytes));
      final ripemd160 = RIPEMD160Digest();
      final pubKeyHash = ripemd160.process(sha256Result);

      final versionedHash = Uint8List(21);
      versionedHash[0] = 0x00; // Version byte for mainnet address
      versionedHash.setRange(1, 21, pubKeyHash);

      final firstSHA = SHA256Digest().process(versionedHash.sublist(0, 21));
      final doubleSHA = SHA256Digest().process(firstSHA);
      final checksum = doubleSHA.sublist(0, 4);

      final addressBytes = Uint8List(25);
      addressBytes.setRange(0, 21, versionedHash);
      addressBytes.setRange(21, 25, checksum);

      return base58.encode(addressBytes);
    } catch (e) {
      log.e('Error deriving address: $e');
      return '';
    }
  }

  Future<String> derivePublicKey(String path) async {
    if (!_initialized) await init();

    try {
      final chain = Chain.seed(_seedHex!);
      final extendedPrivateKey = chain.forPath(path) as ExtendedPrivateKey;
      final publicKey = extendedPrivateKey.publicKey();

      final q = publicKey.q;
      if (q == null) {
        log.e('Public key point is null');
        return '';
      }

      final pubKeyBytes = q.getEncoded(true);
      return hex.encode(pubKeyBytes);
    } catch (e) {
      log.e('Error deriving public key: $e');
      return '';
    }
  }
}
