import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart' hide Key;
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:synchronized/synchronized.dart';

/// Metadata stored alongside encrypted wallet
class EncryptionMetadata {
  final String salt; // Hex-encoded 32-byte salt
  final int iterations; // PBKDF2 iterations (default: 100,000)
  final bool encrypted; // Whether wallet is encrypted
  final String version; // Encryption version

  EncryptionMetadata({
    required this.salt,
    required this.iterations,
    required this.encrypted,
    this.version = '1.0',
  });

  Map<String, dynamic> toJson() {
    return {
      'salt': salt,
      'iterations': iterations,
      'encrypted': encrypted,
      'version': version,
    };
  }

  factory EncryptionMetadata.fromJson(Map<String, dynamic> json) {
    return EncryptionMetadata(
      salt: json['salt'] as String,
      iterations: json['iterations'] as int,
      encrypted: json['encrypted'] as bool,
      version: json['version'] as String? ?? '1.0',
    );
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  factory EncryptionMetadata.fromJsonString(String jsonString) {
    return EncryptionMetadata.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }
}

/// Provider for wallet encryption/decryption using AES-256-GCM
/// Shared across all apps for unlocking encrypted wallets
class EncryptionProvider extends ChangeNotifier {
  final Directory appDir;
  final _logger = GetIt.I.get<Logger>();

  // In-memory storage for decrypted wallet data
  String? _decryptedWalletJson;
  final Lock _lock = Lock();

  // Encryption configuration
  static const int _keyLength = 32; // 256 bits for AES-256

  EncryptionProvider({required this.appDir});

  /// Get encryption metadata file path
  File _getMetadataFile() {
    return File(path.join(appDir.path, 'wallet_encryption.json'));
  }

  /// Get wallet.json file path
  File _getWalletFile() {
    return File(path.join(appDir.path, 'wallet.json'));
  }

  /// Check if wallet is encrypted
  Future<bool> isWalletEncrypted() async {
    return await _lock.synchronized(() async {
      final metadataFile = _getMetadataFile();
      if (!await metadataFile.exists()) {
        return false;
      }

      try {
        final metadataJson = await metadataFile.readAsString();
        final metadata = EncryptionMetadata.fromJsonString(metadataJson);
        return metadata.encrypted;
      } catch (e, stack) {
        _logger.e('isWalletEncrypted: Error reading metadata: $e\n$stack');
        return false;
      }
    });
  }

  /// Check if wallet is currently unlocked (decrypted in memory)
  bool get isWalletUnlocked => _decryptedWalletJson != null;

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

  /// Unlock wallet with password (decrypt into memory)
  Future<bool> unlockWallet(String password) async {
    return await _lock.synchronized(() async {
      try {
        _logger.i('unlockWallet: Attempting to unlock wallet');

        // Check if wallet is encrypted
        final metadata = await _loadMetadata();
        if (metadata == null || !metadata.encrypted) {
          _logger.w('unlockWallet: Wallet is not encrypted');
          return false;
        }

        // Read encrypted wallet
        final walletFile = _getWalletFile();
        if (!await walletFile.exists()) {
          throw Exception('Wallet file not found');
        }

        final encryptedData = await walletFile.readAsString();
        _logger.i('unlockWallet: Read encrypted wallet file');

        // Derive key from password
        final salt = base64.decode(metadata.salt);
        final key = _deriveKey(password, salt, metadata.iterations);
        _logger.i('unlockWallet: Derived key from password');

        // Try to decrypt
        try {
          final decryptedJson = _decrypt(encryptedData, key);
          _logger.i('unlockWallet: Successfully decrypted wallet');

          // Validate that it's valid JSON
          jsonDecode(decryptedJson);

          // Store in memory
          _decryptedWalletJson = decryptedJson;

          _logger.i('unlockWallet: Wallet unlocked successfully');
          notifyListeners();
          return true;
        } catch (e) {
          _logger.w('unlockWallet: Failed to decrypt (wrong password?): $e');
          return false;
        }
      } catch (e, stack) {
        _logger.e('unlockWallet: Error unlocking wallet: $e\n$stack');
        return false;
      }
    });
  }

  /// Lock wallet (clear decrypted data from memory and cleanup temp files)
  Future<void> lockWallet() async {
    await _lock.synchronized(() async {
      _logger.i('lockWallet: Locking wallet');
      _decryptedWalletJson = null;

      // Clean up temporary starter files
      try {
        final tmpDir = Directory(path.join(Directory.systemTemp.path, 'bitwindow_starters_$pid'));
        if (await tmpDir.exists()) {
          await tmpDir.delete(recursive: true);
          _logger.i('lockWallet: Cleaned up temporary starter files');
        }
      } catch (e, stack) {
        _logger.w('lockWallet: Failed to cleanup starter files: $e\n$stack');
        // Don't rethrow - cleanup failures shouldn't prevent locking
      }

      _logger.i('lockWallet: Wallet locked');
      notifyListeners();
    });
  }

  /// Get decrypted wallet JSON (only available when unlocked)
  String? get decryptedWalletJson => _decryptedWalletJson;

  /// Load encryption metadata
  Future<EncryptionMetadata?> _loadMetadata() async {
    final metadataFile = _getMetadataFile();
    if (!await metadataFile.exists()) {
      return null;
    }

    try {
      final metadataJson = await metadataFile.readAsString();
      return EncryptionMetadata.fromJsonString(metadataJson);
    } catch (e, stack) {
      _logger.e('_loadMetadata: Error reading metadata: $e\n$stack');
      return null;
    }
  }

  @override
  void dispose() {
    // Clear sensitive data on dispose
    _decryptedWalletJson = null;
    super.dispose();
  }
}
