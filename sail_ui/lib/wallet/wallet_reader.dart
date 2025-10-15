import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart' hide Key;
import 'package:path/path.dart' as path;

/// WalletReader exists to read encrypted and unencrypted wallet.json files
class WalletReader {
  final Directory bitwindowAppDir;

  WalletReader(this.bitwindowAppDir);

  // Encryption configuration (matches EncryptionProvider)
  static const int _keyLength = 32; // 256 bits for AES-256

  /// Get wallet.json file path
  File _getWalletFile() {
    return File(path.join(bitwindowAppDir.path, 'wallet.json'));
  }

  /// Get encryption metadata file path
  File _getMetadataFile() {
    return File(path.join(bitwindowAppDir.path, 'wallet_encryption.json'));
  }

  /// Check if wallet exists
  bool walletExists() {
    return _getWalletFile().existsSync();
  }

  /// Check if wallet is encrypted
  bool isEncrypted() {
    final metadataFile = _getMetadataFile();
    if (!metadataFile.existsSync()) {
      return false;
    }

    try {
      final metadataJson = metadataFile.readAsStringSync();
      final metadata = jsonDecode(metadataJson) as Map<String, dynamic>;
      return metadata['encrypted'] as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Read unencrypted wallet.json
  /// Returns null if encrypted or doesn't exist
  Map<String, dynamic>? readWalletJson() {
    if (!walletExists()) return null;
    if (isEncrypted()) return null;

    try {
      final walletFile = _getWalletFile();
      final jsonString = walletFile.readAsStringSync();
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Decrypt and read encrypted wallet.json
  /// Returns null if not encrypted, doesn't exist, or wrong password
  Map<String, dynamic>? readEncryptedWalletJson(String password) {
    if (!walletExists()) return null;
    if (!isEncrypted()) return null;

    try {
      // Load metadata
      final metadataFile = _getMetadataFile();
      if (!metadataFile.existsSync()) return null;

      final metadataJson = metadataFile.readAsStringSync();
      final metadata = jsonDecode(metadataJson) as Map<String, dynamic>;

      final saltBase64 = metadata['salt'] as String;
      final iterations = metadata['iterations'] as int;

      // Read encrypted wallet
      final walletFile = _getWalletFile();
      final encryptedData = walletFile.readAsStringSync();

      // Derive key from password
      final salt = base64.decode(saltBase64);
      final key = _deriveKey(password, salt, iterations);

      // Decrypt
      final decryptedJson = _decrypt(encryptedData, key);

      // Parse and return
      return jsonDecode(decryptedJson) as Map<String, dynamic>;
    } catch (e) {
      return null; // Wrong password or corrupted data
    }
  }

  /// Get L1 mnemonic
  /// Returns null if wallet doesn't exist, is encrypted, or mnemonic not found
  String? getL1Mnemonic() {
    final wallet = readWalletJson();
    if (wallet == null) return null;

    try {
      final l1 = wallet['l1'] as Map<String, dynamic>?;
      return l1?['mnemonic'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// Get L1 mnemonic from encrypted wallet
  String? getL1MnemonicEncrypted(String password) {
    final wallet = readEncryptedWalletJson(password);
    if (wallet == null) return null;

    try {
      final l1 = wallet['l1'] as Map<String, dynamic>?;
      return l1?['mnemonic'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// Get sidechain mnemonic by slot
  /// Returns null if wallet doesn't exist, is encrypted, or sidechain not found
  String? getSidechainMnemonic(int slot) {
    final wallet = readWalletJson();
    if (wallet == null) return null;

    try {
      final sidechains = wallet['sidechains'] as List<dynamic>?;
      if (sidechains == null) return null;

      for (final sc in sidechains) {
        final scMap = sc as Map<String, dynamic>;
        if (scMap['slot'] == slot) {
          return scMap['mnemonic'] as String?;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get sidechain mnemonic from encrypted wallet
  String? getSidechainMnemonicEncrypted(int slot, String password) {
    final wallet = readEncryptedWalletJson(password);
    if (wallet == null) return null;

    try {
      final sidechains = wallet['sidechains'] as List<dynamic>?;
      if (sidechains == null) return null;

      for (final sc in sidechains) {
        final scMap = sc as Map<String, dynamic>;
        if (scMap['slot'] == slot) {
          return scMap['mnemonic'] as String?;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Derive encryption key from password using PBKDF2
  Uint8List _deriveKey(String password, Uint8List salt, int iterations) {
    final passwordBytes = utf8.encode(password);

    // PBKDF2 implementation
    Uint8List pbkdf2(Uint8List password, Uint8List salt, int iterations, int keyLength) {
      final result = Uint8List(keyLength);
      var blockIndex = 1;
      var offset = 0;

      while (offset < keyLength) {
        // Create block: salt + block index (big-endian)
        final block = Uint8List(salt.length + 4);
        block.setAll(0, salt);
        block[salt.length] = (blockIndex >> 24) & 0xff;
        block[salt.length + 1] = (blockIndex >> 16) & 0xff;
        block[salt.length + 2] = (blockIndex >> 8) & 0xff;
        block[salt.length + 3] = blockIndex & 0xff;

        // First iteration: U1 = PRF(password, salt || block_index)
        var u = Uint8List.fromList(Hmac(sha256, passwordBytes).convert(block).bytes);
        var f = Uint8List.fromList(u);

        // Remaining iterations: Un = PRF(password, Un-1)
        for (var i = 1; i < iterations; i++) {
          u = Uint8List.fromList(Hmac(sha256, passwordBytes).convert(u).bytes);
          // XOR with accumulated value
          for (var j = 0; j < f.length; j++) {
            f[j] ^= u[j];
          }
        }

        // Copy block to result
        final remaining = keyLength - offset;
        final toCopy = remaining < f.length ? remaining : f.length;
        result.setRange(offset, offset + toCopy, f);
        offset += toCopy;
        blockIndex++;
      }

      return result;
    }

    return pbkdf2(passwordBytes, salt, iterations, _keyLength);
  }

  /// Decrypt data using AES-256-GCM
  String _decrypt(String ciphertext, Uint8List key) {
    final parts = ciphertext.split(':');
    if (parts.length != 2) {
      throw Exception('Invalid ciphertext format');
    }

    final iv = IV.fromBase64(parts[0]);
    final encrypted = Encrypted.fromBase64(parts[1]);

    final keyObj = Key(key);
    final encrypter = Encrypter(AES(keyObj, mode: AESMode.gcm));

    return encrypter.decrypt(encrypted, iv: iv);
  }
}
