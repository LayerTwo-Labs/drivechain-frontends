import 'dart:convert';
import 'dart:io';

import 'package:bip39_mnemonic/bip39_mnemonic.dart';
import 'package:bitwindow/env.dart';
import 'package:bs58/bs58.dart';
import 'package:convert/convert.dart';
import 'package:dart_bip32_bip44/dart_bip32_bip44.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:pointycastle/digests/ripemd160.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:sail_ui/config/sidechains.dart';

// Helper function to log multisig debugging information to file
Future<void> _logToFile(String message) async {
  try {
    final dir = Directory(path.dirname(path.current));
    final file = File(path.join(dir.path, 'bitwindow', 'multisig_output.txt'));
    
    // Ensure parent directory exists
    await file.parent.create(recursive: true);
    
    final timestamp = DateTime.now().toIso8601String();
    await file.writeAsString('[$timestamp] HD_WALLET: $message\n', mode: FileMode.append);
  } catch (e) {
    print('Failed to write to multisig_output.txt: $e');
  }
}

class HDWalletProvider extends ChangeNotifier {
  Logger get log => GetIt.I.get<Logger>();

  final Directory appDir;

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

  Future<void> _loadMnemonic() async {
    try {
      final walletDir = getWalletDir(appDir);
      if (walletDir == null) {
        throw Exception("Couldn't sync to wallet for HD Explorer");
      }

      final txtPath = path.join(walletDir.path, 'l1_starter.txt');
      final file = File(txtPath);
      if (!await file.exists()) {
        throw Exception('could not find l1_starter.txt');
      }

      final fileContent = await file.readAsString();
      _mnemonic = fileContent.trim();
      if (_mnemonic == null || _mnemonic!.isEmpty) {
        throw Exception('l1_starter.txt is empty or contains no mnemonic');
      }

      final mnemonicObj = Mnemonic.fromSentence(_mnemonic!, Language.english);
      _seedHex = hex.encode(mnemonicObj.seed);

      final chain = Chain.seed(_seedHex!);
      final masterKey = chain.forPath('m');
      _masterKey = masterKey.privateKeyHex();

      _error = null;
      _initialized = true;
    } catch (e) {
      _error = "Couldn't load wallet for HD Explorer";
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

  // Helper function for hash160 (SHA256 + RIPEMD160)
  Uint8List hash160(Uint8List data) {
    final sha256Digest = SHA256Digest();
    final ripemd160 = RIPEMD160Digest();
    final sha256Result = sha256Digest.process(data);
    return ripemd160.process(sha256Result);
  }

  // Validate extended key format and checksum
  bool _validateExtendedKey(String extendedKey) {
    try {
      final decoded = base58.decode(extendedKey);
      if (decoded.length != 82) {
        log.e('Extended key wrong length: ${decoded.length}, expected 82');
        return false;
      }
      
      // Verify checksum
      final payload = decoded.sublist(0, 78);
      final providedChecksum = decoded.sublist(78, 82);
      
      final sha256Digest = SHA256Digest();
      final hash1 = sha256Digest.process(payload);
      final hash2 = sha256Digest.process(hash1);
      final calculatedChecksum = hash2.sublist(0, 4);
      
      for (int i = 0; i < 4; i++) {
        if (providedChecksum[i] != calculatedChecksum[i]) {
          log.e('Extended key checksum mismatch at byte $i: ${providedChecksum[i]} != ${calculatedChecksum[i]}');
          return false;
        }
      }
      
      // Additional validation: check the extended key structure
      final version = (decoded[0] << 24) | (decoded[1] << 16) | (decoded[2] << 8) | decoded[3];
      final depth = decoded[4];
      final parentFingerprint = decoded.sublist(5, 9);
      final childNumber = decoded.sublist(9, 13);
      final chainCode = decoded.sublist(13, 45);
      final keyData = decoded.sublist(45, 78);
      
      log.d('Extended key validation passed: ${extendedKey.substring(0, 8)}...');
      log.d('  Version: 0x${version.toRadixString(16).padLeft(8, '0')}');
      log.d('  Depth: $depth');
      log.d('  Parent fingerprint: ${hex.encode(parentFingerprint)}');
      log.d('  Child number: ${hex.encode(childNumber)}');
      log.d('  Chain code: ${hex.encode(chainCode).substring(0, 16)}...');
      log.d('  Key data: ${hex.encode(keyData).substring(0, 16)}...');
      
      // Check if version matches expected network
      final isMainnetVersion = version == 0x0488b21e; // xpub
      final isTestnetVersion = version == 0x043587cf; // tpub
      
      if (!isMainnetVersion && !isTestnetVersion) {
        log.e('Unknown extended key version: 0x${version.toRadixString(16)}');
        return false;
      }
      
      // Check if key data starts with proper compression byte for public key
      if (keyData[0] != 0x02 && keyData[0] != 0x03) {
        log.e('Invalid public key compression byte: 0x${keyData[0].toRadixString(16)}');
        return false;
      }
      
      return true;
    } catch (e) {
      log.e('Extended key validation error: $e');
      return false;
    }
  }

  // Test if we can derive a child key from the extended key (additional validation)
  bool _canDeriveChild(String extendedKey) {
    try {
      // Try to use the dart_bip32_bip44 library to derive a child key
      // This will fail if the extended key format is incorrect
      final chain = Chain.import(extendedKey);
      final childKey = chain.forPath('0/0'); // Try to derive m/0/0
      childKey.publicKey(); // Just call to verify derivation works
      
      // If we got here, the extended key is valid enough to derive children
      log.d('Successfully derived child key from extended key');
      return true;
    } catch (e) {
      log.e('Failed to derive child key from extended key: $e');
      return false;
    }
  }


  // Key derivation method with proper xPub/tpub handling
  Future<Map<String, String>> deriveExtendedKeyInfo(String mnemonic, String path, [bool isMainnet = false]) async {
    try {
      // Adjust path for network-specific coin type
      final coinType = isMainnet ? "0'" : "1'";
      final adjustedPath = path.replaceAll("'0'", coinType).replaceAll("'1'", coinType);
      
      final mnemonicObj = Mnemonic.fromSentence(mnemonic, Language.english);
      final seedHex = hex.encode(mnemonicObj.seed);
      final chain = Chain.seed(seedHex);
      
      // Derive master key for fingerprint
      final masterKey = chain.forPath('m') as ExtendedPrivateKey;
      final masterPubKey = masterKey.publicKey();
      final masterQ = masterPubKey.q;
      if (masterQ == null) return {};
      
      final masterPubBytes = masterQ.getEncoded(true);
      final fingerprintBytes = hash160(Uint8List.fromList(masterPubBytes));
      final fingerprint = hex.encode(fingerprintBytes.sublist(0, 4));
      
      // Derive key at requested path
      final extendedPrivateKey = chain.forPath(adjustedPath) as ExtendedPrivateKey;
      final extendedPublicKey = extendedPrivateKey.publicKey();
      
      // Get raw extended keys
      var xprv = extendedPrivateKey.toString();
      var xpub = extendedPublicKey.toString();
      
      log.d('Network: ${isMainnet ? "mainnet" : "testnet/signet"}, Original xpub: $xpub, Original xprv: ${xprv.substring(0, 8)}...');
      
      // For testnet, convert both xpub to tpub and xprv to tprv with proper checksums
      // Bitcoin Core should accept this even if dart_bip32_bip44 can't import it
      if (!isMainnet && xpub.startsWith('xpub')) {
        try {
          final decoded = base58.decode(xpub);
          if (decoded.length == 82) {
            // Change version bytes: xpub (0x0488b21e) -> tpub (0x043587cf)  
            decoded[0] = 0x04; decoded[1] = 0x35; decoded[2] = 0x87; decoded[3] = 0xcf;
            
            // Recalculate checksum
            final payload = decoded.sublist(0, 78);
            final sha256Digest = SHA256Digest();
            final hash1 = sha256Digest.process(payload);
            final hash2 = sha256Digest.process(hash1);
            final newChecksum = hash2.sublist(0, 4);
            
            decoded.setRange(78, 82, newChecksum);
            xpub = base58.encode(decoded);
            log.d('Generated testnet tpub: $xpub');
          }
        } catch (e) {
          log.e('Failed to convert to tpub: $e');
        }
        
        // Also convert xprv to tprv for testnet
        if (xprv.startsWith('xprv')) {
          try {
            final decodedPriv = base58.decode(xprv);
            if (decodedPriv.length == 82) {
              // Change version bytes: xprv (0x0488ade4) -> tprv (0x04358394)
              decodedPriv[0] = 0x04; decodedPriv[1] = 0x35; decodedPriv[2] = 0x83; decodedPriv[3] = 0x94;
              
              // Recalculate checksum
              final payload = decodedPriv.sublist(0, 78);
              final sha256Digest = SHA256Digest();
              final hash1 = sha256Digest.process(payload);
              final hash2 = sha256Digest.process(hash1);
              final newChecksum = hash2.sublist(0, 4);
              
              decodedPriv.setRange(78, 82, newChecksum);
              xprv = base58.encode(decodedPriv);
              log.d('Generated testnet tprv: ${xprv.substring(0, 8)}...');
            }
          } catch (e) {
            log.e('Failed to convert to tprv: $e');
          }
        }
      } else if (isMainnet && xpub.startsWith('tpub')) {
        // Convert tpub to xpub for mainnet
        try {
          final decoded = base58.decode(xpub);
          if (decoded.length == 82) {
            // Change version bytes: tpub (0x043587cf) -> xpub (0x0488b21e)
            decoded[0] = 0x04; decoded[1] = 0x88; decoded[2] = 0xb2; decoded[3] = 0x1e;
            
            // Recalculate checksum
            final payload = decoded.sublist(0, 78);
            final sha256Digest = SHA256Digest();
            final hash1 = sha256Digest.process(payload);
            final hash2 = sha256Digest.process(hash1);
            final newChecksum = hash2.sublist(0, 4);
            
            decoded.setRange(78, 82, newChecksum);
            xpub = base58.encode(decoded);
            log.d('Converted testnet tpub to mainnet xpub');
          }
        } catch (e) {
          log.e('Failed to convert tpub version bytes: $e');
        }
        
        // Also convert tprv to xprv for mainnet
        if (xprv.startsWith('tprv')) {
          try {
            final decodedPriv = base58.decode(xprv);
            if (decodedPriv.length == 82) {
              // Change version bytes: tprv (0x04358394) -> xprv (0x0488ade4)
              decodedPriv[0] = 0x04; decodedPriv[1] = 0x88; decodedPriv[2] = 0xad; decodedPriv[3] = 0xe4;
              
              // Recalculate checksum
              final payload = decodedPriv.sublist(0, 78);
              final sha256Digest = SHA256Digest();
              final hash1 = sha256Digest.process(payload);
              final hash2 = sha256Digest.process(hash1);
              final newChecksum = hash2.sublist(0, 4);
              
              decodedPriv.setRange(78, 82, newChecksum);
              xprv = base58.encode(decodedPriv);
              log.d('Converted testnet tprv to mainnet xprv');
            }
          } catch (e) {
            log.e('Failed to convert tprv version bytes: $e');
          }
        }
      }
      
      // Validate the final extended key format
      if (!_validateExtendedKey(xpub)) {
        log.e('Generated extended key failed validation: $xpub');
        throw Exception('Generated extended key is invalid');
      }
      
      // Note: We skip the dart_bip32_bip44 child derivation test for testnet tpub keys
      // because the library may not support them, but Bitcoin Core should accept them
      if (isMainnet || xpub.startsWith('xpub')) {
        if (!_canDeriveChild(xpub)) {
          log.w('Extended key cannot derive child keys in dart_bip32_bip44, but may still work with Bitcoin Core');
        }
      } else {
        log.i('Skipping dart_bip32_bip44 child derivation test for testnet tpub key');
      }
      
      // Get pubkey if at leaf level (for validation)
      final q = extendedPublicKey.q;
      if (q == null) return {};
      final pubKeyBytes = q.getEncoded(true);
      final pubKeyHex = hex.encode(pubKeyBytes);
      
      // Generate legacy P2PKH address
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
      
      // Generate WIF
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
      log.e('Error in fallback key derivation: $e');
      return {};
    }
  }

  // Generate wallet xPub with origin info
  Future<Map<String, String>> generateWalletXpub(int accountIndex, [bool isMainnet = false]) async {
    await _logToFile('generateWalletXpub called with accountIndex=$accountIndex, isMainnet=$isMainnet');
    
    final coinType = isMainnet ? "0'" : "1'";
    final path = "m/84'/$coinType/$accountIndex'";
    
    await _logToFile('Deriving key at path: $path');
    final info = await deriveExtendedKeyInfo(_mnemonic ?? '', path, isMainnet);
    
    if (info.isEmpty) {
      await _logToFile('Failed to derive key info for path: $path');
      return {};
    }
    
    await _logToFile('Successfully derived key info: xpub=${info['xpub']?.substring(0, 20)}..., fingerprint=${info['fingerprint']}');
    
    // Add origin info to xpub
    final originPath = path.replaceFirst('m/', '');
    info['xpub_with_origin'] = "[${info['fingerprint']}/$originPath]${info['xpub']}";
    info['derivation_path'] = path;
    
    await _logToFile('Added derivation_path=$path to key info');
    
    return info;
  }

  // Get next available account index for multisig
  Future<int> getNextAccountIndex([Set<int>? additionalUsedIndices]) async {
    try {
      final appDir = await Environment.datadir();
      final bitdriveDir = path.join(appDir.path, 'bitdrive');
      final file = File(path.join(bitdriveDir, 'multisig.json'));
      
      int maxAccountIndex = 7999; // Start before 8000
      
      if (await file.exists()) {
        final content = await file.readAsString();
        final jsonData = json.decode(content);
        
        // Expect new format only: object with groups and solo_keys
        if (jsonData is! Map<String, dynamic>) {
          throw Exception('Invalid multisig.json format: expected object with groups and solo_keys');
        }
        
        // Check groups for wallet keys
        final groups = jsonData['groups'] as List<dynamic>? ?? [];
        log.d('Found ${groups.length} groups in multisig.json');
        
        for (final jsonGroup in groups) {
          final groupName = jsonGroup['name'] ?? 'unnamed';
          final List<dynamic> keys = jsonGroup['keys'] ?? [];
          log.d('Group "$groupName" has ${keys.length} keys');
          
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
        
        // Check solo_keys
        final soloKeys = jsonData['solo_keys'] as List<dynamic>? ?? [];
        log.d('Found ${soloKeys.length} solo keys in multisig.json');
        
        for (final keyData in soloKeys) {
          final derivationPath = keyData['path'] as String?;
          
          if (derivationPath != null) {
            final match = RegExp(r"m/84'/[01]'/(\d+)'").firstMatch(derivationPath);
            if (match != null) {
              final accountIndex = int.parse(match.group(1)!);
              if (accountIndex > maxAccountIndex) {
                maxAccountIndex = accountIndex;
                log.d('Updated max account index from solo_keys to: $maxAccountIndex');
              }
            }
          }
        }
      }
      
      // Include additional indices from current session
      if (additionalUsedIndices != null) {
        log.d('Session used indices: $additionalUsedIndices');
        for (final index in additionalUsedIndices) {
          if (index > maxAccountIndex) {
            maxAccountIndex = index;
            log.d('Updated max account index from session to: $maxAccountIndex');
          }
        }
      }
      
      final nextIndex = maxAccountIndex + 1;
      log.d('Returning next account index: $nextIndex');
      return nextIndex;
    } catch (e) {
      log.e('Error getting next account index: $e');
      return 8000;
    }
  }

  // Compatibility method for existing callers
  Future<Map<String, String>> deriveKeyInfo(String mnemonic, String path) async {
    final isMainnet = const String.fromEnvironment('BITWINDOW_NETWORK', defaultValue: 'signet') == 'mainnet';
    return deriveExtendedKeyInfo(mnemonic, path, isMainnet);
  }
}
