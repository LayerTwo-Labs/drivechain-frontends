import 'dart:convert';
import 'dart:io';

import 'package:bip39_mnemonic/bip39_mnemonic.dart';
import 'package:bitwindow/env.dart';
import 'package:bitwindow/providers/wallet_provider.dart';
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

  final Directory appDir;

  String? _seedHex;
  String? _masterKey;
  String? _error;
  bool _initialized = false;
  final bool _isProcessing = false;
  String? _mnemonic;
  String _bip47PaymentCode = '';

  String? get seedHex => _seedHex;
  String? get masterKey => _masterKey;
  String? get error => _error;
  bool get isInitialized => _initialized;
  bool get isProcessing => _isProcessing;
  String? get mnemonic => _mnemonic;
  String get bip47PaymentCode => _bip47PaymentCode;

  HDWalletProvider(this.appDir);

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

  /// Force reinitialize the HD wallet provider
  Future<void> reinitialize() async {
    _initialized = false;
    _mnemonic = null;
    _seedHex = null;
    _masterKey = null;
    _error = null;
    await init();
  }

  Future<void> _loadMnemonic() async {
    try {
      // Use WalletProvider to load L1 mnemonic (supports both old and new structure)
      final walletProvider = GetIt.I.get<WalletProvider>();
      final l1Mnemonic = await walletProvider.getL1Starter();

      if (l1Mnemonic == null || l1Mnemonic.isEmpty) {
        throw Exception('Could not load L1 wallet mnemonic');
      }

      _mnemonic = l1Mnemonic.trim();

      final mnemonicObj = Mnemonic.fromSentence(_mnemonic!, Language.english);
      _seedHex = hex.encode(mnemonicObj.seed);

      final chain = Chain.seed(_seedHex!);
      final masterKey = chain.forPath('m');
      _masterKey = masterKey.privateKeyHex();

      try {
        final extendedPublicKey = (masterKey as ExtendedPrivateKey).publicKey();
        final masterQ = extendedPublicKey.q;
        if (masterQ != null) {
          final masterPubKeyBytes = masterQ.getEncoded(true);
          final masterPubKeyHex = hex.encode(masterPubKeyBytes);
          _bip47PaymentCode = _generateBip47v3PaymentCode(masterPubKeyHex);
        }
      } catch (e) {
        _bip47PaymentCode = '';
      }

      _error = null;
      _initialized = true;
    } catch (e) {
      _error = "Couldn't load wallet for HD Explorer";
      _seedHex = _masterKey = _mnemonic = null;
      _initialized = false;
    }
  }

  /// Reset the provider state to allow re-initialization with new wallet data
  Future<void> reset() async {
    _initialized = false;
    _seedHex = null;
    _masterKey = null;
    _mnemonic = null;
    _bip47PaymentCode = '';
    _error = null;
    notifyListeners();
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
        length: MnemonicLength.words12,
        passphrase: 'layertwolabs',
      );
      return mnemonic.sentence;
    } catch (e) {
      _error = 'Error generating random mnemonic';
      notifyListeners();
      return '';
    }
  }

  Uint8List hash160(Uint8List data) {
    final sha256Digest = SHA256Digest();
    final ripemd160 = RIPEMD160Digest();
    final sha256Result = sha256Digest.process(data);
    return ripemd160.process(sha256Result);
  }

  String _generateBip47v3PaymentCode(String masterPubKeyHex) {
    try {
      if (masterPubKeyHex.length != 66) {
        return '';
      }

      final pubKeyBytes = hex.decode(masterPubKeyHex);
      if (pubKeyBytes.length != 33) {
        return '';
      }

      final binaryPayload = Uint8List(34);
      binaryPayload[0] = 0x03;
      binaryPayload.setRange(1, 34, pubKeyBytes);

      final versionedPayload = Uint8List(35);
      versionedPayload[0] = 0x22;
      versionedPayload.setRange(1, 35, binaryPayload);

      final sha256Digest = SHA256Digest();
      final hash1 = sha256Digest.process(versionedPayload);
      final hash2 = sha256Digest.process(hash1);
      final checksum = hash2.sublist(0, 4);

      final finalBytes = Uint8List(39);
      finalBytes.setRange(0, 35, versionedPayload);
      finalBytes.setRange(35, 39, checksum);

      return base58.encode(finalBytes);
    } catch (e) {
      return '';
    }
  }

  bool _validateExtendedKey(String extendedKey) {
    try {
      final decoded = base58.decode(extendedKey);
      if (decoded.length != 82) {
        return false;
      }

      final payload = decoded.sublist(0, 78);
      final providedChecksum = decoded.sublist(78, 82);

      final sha256Digest = SHA256Digest();
      final hash1 = sha256Digest.process(payload);
      final hash2 = sha256Digest.process(hash1);
      final calculatedChecksum = hash2.sublist(0, 4);

      for (int i = 0; i < 4; i++) {
        if (providedChecksum[i] != calculatedChecksum[i]) {
          return false;
        }
      }

      final version = (decoded[0] << 24) | (decoded[1] << 16) | (decoded[2] << 8) | decoded[3];
      final keyData = decoded.sublist(45, 78);

      final isMainnetVersion = version == 0x0488b21e;
      final isTestnetVersion = version == 0x043587cf;

      if (!isMainnetVersion && !isTestnetVersion) {
        return false;
      }

      if (keyData[0] != 0x02 && keyData[0] != 0x03) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  bool _canDeriveChild(String extendedKey) {
    try {
      final chain = Chain.import(extendedKey);
      final childKey = chain.forPath('0/0');
      childKey.publicKey();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, String>> deriveExtendedKeyInfo(String mnemonic, String path, [bool isMainnet = false]) async {
    try {
      String adjustedPath = path;
      if (isMainnet && path.contains("'1'/")) {
        adjustedPath = path.replaceAll("'1'/", "'0'/");
      } else if (!isMainnet && path.contains("'0'/")) {
        adjustedPath = path.replaceAll("'0'/", "'1'/");
      }

      final mnemonicObj = Mnemonic.fromSentence(mnemonic, Language.english);
      final seedHex = hex.encode(mnemonicObj.seed);
      final chain = Chain.seed(seedHex);

      final masterKey = chain.forPath('m') as ExtendedPrivateKey;
      final masterPubKey = masterKey.publicKey();
      final masterQ = masterPubKey.q;
      if (masterQ == null) return {};

      final masterPubBytes = masterQ.getEncoded(true);
      final fingerprintBytes = hash160(Uint8List.fromList(masterPubBytes));
      final fingerprint = hex.encode(fingerprintBytes.sublist(0, 4));

      final extendedPrivateKey = chain.forPath(adjustedPath) as ExtendedPrivateKey;
      final extendedPublicKey = extendedPrivateKey.publicKey();

      var xprv = extendedPrivateKey.toString();
      var xpub = extendedPublicKey.toString();

      if (!isMainnet && xpub.startsWith('xpub')) {
        try {
          final decoded = base58.decode(xpub);
          if (decoded.length == 82) {
            decoded[0] = 0x04;
            decoded[1] = 0x35;
            decoded[2] = 0x87;
            decoded[3] = 0xcf;

            final payload = decoded.sublist(0, 78);
            final sha256Digest = SHA256Digest();
            final hash1 = sha256Digest.process(payload);
            final hash2 = sha256Digest.process(hash1);
            final newChecksum = hash2.sublist(0, 4);

            decoded.setRange(78, 82, newChecksum);
            xpub = base58.encode(decoded);
          }
        } catch (e) {
          // do nothing
        }

        if (xprv.startsWith('xprv')) {
          try {
            final decodedPriv = base58.decode(xprv);
            if (decodedPriv.length == 82) {
              decodedPriv[0] = 0x04;
              decodedPriv[1] = 0x35;
              decodedPriv[2] = 0x83;
              decodedPriv[3] = 0x94;

              // Recalculate checksum
              final payload = decodedPriv.sublist(0, 78);
              final sha256Digest = SHA256Digest();
              final hash1 = sha256Digest.process(payload);
              final hash2 = sha256Digest.process(hash1);
              final newChecksum = hash2.sublist(0, 4);

              decodedPriv.setRange(78, 82, newChecksum);
              xprv = base58.encode(decodedPriv);
            }
          } catch (e) {
            // do nothing
          }
        }
      } else if (isMainnet && xpub.startsWith('tpub')) {
        try {
          final decoded = base58.decode(xpub);
          if (decoded.length == 82) {
            decoded[0] = 0x04;
            decoded[1] = 0x88;
            decoded[2] = 0xb2;
            decoded[3] = 0x1e;

            final payload = decoded.sublist(0, 78);
            final sha256Digest = SHA256Digest();
            final hash1 = sha256Digest.process(payload);
            final hash2 = sha256Digest.process(hash1);
            final newChecksum = hash2.sublist(0, 4);

            decoded.setRange(78, 82, newChecksum);
            xpub = base58.encode(decoded);
          }
        } catch (e) {
          // do nothing
        }

        if (xprv.startsWith('tprv')) {
          try {
            final decodedPriv = base58.decode(xprv);
            if (decodedPriv.length == 82) {
              decodedPriv[0] = 0x04;
              decodedPriv[1] = 0x88;
              decodedPriv[2] = 0xad;
              decodedPriv[3] = 0xe4;

              // Recalculate checksum
              final payload = decodedPriv.sublist(0, 78);
              final sha256Digest = SHA256Digest();
              final hash1 = sha256Digest.process(payload);
              final hash2 = sha256Digest.process(hash1);
              final newChecksum = hash2.sublist(0, 4);

              decodedPriv.setRange(78, 82, newChecksum);
              xprv = base58.encode(decodedPriv);
            }
          } catch (e) {
            // do nothing
          }
        }
      }

      if (!_validateExtendedKey(xpub)) {
        throw Exception('Generated extended key is invalid');
      }

      if (isMainnet || xpub.startsWith('xpub')) {
        if (!_canDeriveChild(xpub)) {}
      }
      final q = extendedPublicKey.q;
      if (q == null) return {};
      final pubKeyBytes = q.getEncoded(true);
      final pubKeyHex = hex.encode(pubKeyBytes);

      final pubKeyHash = hash160(Uint8List.fromList(pubKeyBytes));
      final versionedHash = Uint8List(21);
      versionedHash[0] = isMainnet ? 0x00 : 0x6F;
      versionedHash.setRange(1, 21, pubKeyHash);

      final sha256Digest = SHA256Digest();
      final hash1 = sha256Digest.process(versionedHash);
      final hash2 = sha256Digest.process(hash1);
      final checksum = hash2.sublist(0, 4);

      final addressBytes = Uint8List(25);
      addressBytes.setRange(0, 21, versionedHash);
      addressBytes.setRange(21, 25, checksum);
      final address = base58.encode(addressBytes);

      final privateKeyHex = extendedPrivateKey.privateKeyHex();
      final cleanHex = privateKeyHex.startsWith('00') ? privateKeyHex.substring(2) : privateKeyHex;
      final privateKeyBytes = hex.decode(cleanHex);

      final wifBuffer = Uint8List(34);
      wifBuffer[0] = isMainnet ? 0x80 : 0xEF;
      wifBuffer.setRange(1, 33, privateKeyBytes);
      wifBuffer[33] = 0x01;

      final wifHash1 = sha256Digest.process(wifBuffer);
      final wifHash2 = sha256Digest.process(wifHash1);
      final wifChecksum = wifHash2.sublist(0, 4);

      final wifBytes = Uint8List(38);
      wifBytes.setRange(0, 34, wifBuffer);
      wifBytes.setRange(34, 38, wifChecksum);
      final wif = base58.encode(wifBytes);

      return {
        'xprv': xprv,
        'xpub': xpub,
        'fingerprint': fingerprint,
        'privateKey': privateKeyHex,
        'publicKey': pubKeyHex,
        'address': address,
        'wif': wif,
      };
    } catch (e) {
      return {};
    }
  }

  Future<Map<String, String>> generateWalletXpub(int accountIndex, [bool isMainnet = false]) async {
    final coinType = isMainnet ? "0'" : "1'";
    final path = "m/84'/$coinType/$accountIndex'";

    final info = await deriveExtendedKeyInfo(_mnemonic ?? '', path, isMainnet);

    if (info.isEmpty) {
      return {};
    }

    final originPath = path.replaceFirst('m/', '');
    info['xpub_with_origin'] = "[${info['fingerprint']}/$originPath]${info['xpub']}";
    info['derivation_path'] = path;

    return info;
  }

  Future<int> getNextAccountIndex([Set<int>? additionalUsedIndices]) async {
    try {
      final appDir = await Environment.datadir();
      final bitdriveDir = path.join(appDir.path, 'bitdrive');
      final file = File(path.join(bitdriveDir, 'multisig', 'multisig.json'));

      int maxAccountIndex = 7999;

      if (await file.exists()) {
        final content = await file.readAsString();
        final jsonData = json.decode(content) as Map<String, dynamic>;

        final groups = jsonData['groups'] as List<dynamic>? ?? [];

        for (final jsonGroup in groups) {
          final List<dynamic> keys = jsonGroup['keys'] ?? [];

          for (final keyData in keys) {
            final isWallet = keyData['is_wallet'] == true;
            final derivationPath = keyData['path'] as String?;

            if (isWallet && derivationPath != null) {
              final match = RegExp(r"m/84'/[01]'/(\d+)'").firstMatch(derivationPath);
              if (match != null) {
                final accountIndex = int.parse(match.group(1)!);
                if (accountIndex > maxAccountIndex) {
                  maxAccountIndex = accountIndex;
                }
              }
            }
          }
        }

        final soloKeys = jsonData['solo_keys'] as List<dynamic>? ?? [];

        for (final keyData in soloKeys) {
          final derivationPath = keyData['path'] as String?;
          final expectedXpub = keyData['xpub'] as String?;

          if (derivationPath != null && expectedXpub != null) {
            final match = RegExp(r"m/84'/[01]'/(\d+)'").firstMatch(derivationPath);
            if (match != null) {
              final accountIndex = int.parse(match.group(1)!);

              if (accountIndex > maxAccountIndex) {
                maxAccountIndex = accountIndex;
              }
            }
          }
        }
      }

      if (additionalUsedIndices != null) {
        for (final index in additionalUsedIndices) {
          if (index > maxAccountIndex) {
            maxAccountIndex = index;
          }
        }
      }

      final nextIndex = maxAccountIndex + 1;
      return nextIndex;
    } catch (e) {
      return 8000;
    }
  }

  Future<Map<String, String>> deriveKeyInfo(String mnemonic, String path) async {
    final isMainnet = const String.fromEnvironment('BITWINDOW_NETWORK', defaultValue: 'signet') == 'mainnet';
    return deriveExtendedKeyInfo(mnemonic, path, isMainnet);
  }
}
