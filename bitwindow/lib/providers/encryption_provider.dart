import 'dart:convert';
import 'dart:io';
import 'dart:math';

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
class EncryptionProvider extends ChangeNotifier {
  final Directory bitwindowAppDir;
  final _logger = GetIt.I.get<Logger>();

  // In-memory storage for decrypted wallet data and encryption key
  String? _decryptedWalletJson;
  Uint8List? _encryptionKey;
  final Lock _lock = Lock();

  // Encryption configuration
  static const int _keyLength = 32; // 256 bits for AES-256
  static const int _saltLength = 32; // 32 bytes
  static const int _defaultIterations = 100000; // PBKDF2 iterations

  EncryptionProvider({required this.bitwindowAppDir});

  /// Get encryption metadata file path
  File _getMetadataFile() {
    return File(path.join(bitwindowAppDir.path, 'wallet_encryption.json'));
  }

  /// Get wallet.json file path
  File _getWalletFile() {
    return File(path.join(bitwindowAppDir.path, 'wallet.json'));
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

  /// Generate random salt
  Uint8List _generateSalt() {
    final random = Random.secure();
    final salt = Uint8List(_saltLength);
    for (var i = 0; i < _saltLength; i++) {
      salt[i] = random.nextInt(256);
    }
    return salt;
  }

  /// Encrypt data using AES-256-GCM
  String _encrypt(String plaintext, Uint8List key) {
    final keyObj = Key(key);
    final iv = IV.fromSecureRandom(16); // 128-bit IV for GCM
    final encrypter = Encrypter(AES(keyObj, mode: AESMode.gcm));

    final encrypted = encrypter.encrypt(plaintext, iv: iv);

    // Return IV + encrypted data (both base64 encoded, separated by ':')
    return '${iv.base64}:${encrypted.base64}';
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

  /// Encrypt the wallet with a password
  Future<void> encryptWallet(String password) async {
    await _lock.synchronized(() async {
      try {
        _logger.i('encryptWallet: Starting wallet encryption');

        // Check if already encrypted
        if (await isWalletEncrypted()) {
          throw Exception('Wallet is already encrypted');
        }

        final walletFile = _getWalletFile();
        if (!await walletFile.exists()) {
          throw Exception('No wallet file found to encrypt');
        }

        // 1. Read the current wallet file
        final walletJson = await walletFile.readAsString();
        _logger.i('encryptWallet: Read wallet file');

        // 2. Generate salt and derive key
        final salt = _generateSalt();
        final key = _deriveKey(password, salt, _defaultIterations);
        _logger.i('encryptWallet: Derived encryption key');

        // 3. Encrypt the wallet data
        final encryptedData = _encrypt(walletJson, key);
        _logger.i('encryptWallet: Encrypted wallet data');

        // 4. Create backup of unencrypted wallet
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final backupFile = File(path.join(bitwindowAppDir.path, 'wallet.json.backup_before_encryption_$timestamp'));
        await walletFile.copy(backupFile.path);
        _logger.i('encryptWallet: Created backup at ${backupFile.path}');

        // 5. Write encrypted wallet
        final tempFile = File('${walletFile.path}.tmp');
        await tempFile.writeAsString(encryptedData);
        await tempFile.rename(walletFile.path);
        _logger.i('encryptWallet: Wrote encrypted wallet');

        // 6. Create and save metadata
        final metadata = EncryptionMetadata(
          salt: base64.encode(salt),
          iterations: _defaultIterations,
          encrypted: true,
        );
        final metadataFile = _getMetadataFile();
        await metadataFile.writeAsString(metadata.toJsonString());
        _logger.i('encryptWallet: Saved encryption metadata');

        // 7. Keep decrypted copy in memory
        _decryptedWalletJson = walletJson;
        _encryptionKey = key;
        _logger.i('encryptWallet: Wallet encrypted and unlocked in current session');

        notifyListeners();
      } catch (e, stack) {
        _logger.e('encryptWallet: Failed to encrypt wallet: $e\n$stack');
        rethrow;
      }
    });
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
          _encryptionKey = key;

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

  /// Lock wallet (clear decrypted data from memory)
  void lockWallet() {
    _lock.synchronized(() {
      _logger.i('lockWallet: Locking wallet');
      _decryptedWalletJson = null;
      _encryptionKey = null;
      _logger.i('lockWallet: Wallet locked');
      notifyListeners();
    });
  }

  /// Change wallet password
  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _lock.synchronized(() async {
      try {
        _logger.i('changePassword: Starting password change');

        // Check if wallet is encrypted
        final metadata = await _loadMetadata();
        if (metadata == null || !metadata.encrypted) {
          throw Exception('Wallet is not encrypted');
        }

        // Try to unlock with old password
        final unlocked = await unlockWallet(oldPassword);
        if (!unlocked || _decryptedWalletJson == null) {
          throw Exception('Incorrect old password');
        }

        _logger.i('changePassword: Old password verified');

        // Generate new salt and derive new key
        final newSalt = _generateSalt();
        final newKey = _deriveKey(newPassword, newSalt, _defaultIterations);
        _logger.i('changePassword: Derived new encryption key');

        // Encrypt with new key
        final newEncryptedData = _encrypt(_decryptedWalletJson!, newKey);
        _logger.i('changePassword: Re-encrypted wallet with new password');

        // Write encrypted wallet
        final walletFile = _getWalletFile();
        final tempFile = File('${walletFile.path}.tmp');
        await tempFile.writeAsString(newEncryptedData);
        await tempFile.rename(walletFile.path);
        _logger.i('changePassword: Wrote re-encrypted wallet');

        // Update metadata
        final newMetadata = EncryptionMetadata(
          salt: base64.encode(newSalt),
          iterations: _defaultIterations,
          encrypted: true,
        );
        final metadataFile = _getMetadataFile();
        await metadataFile.writeAsString(newMetadata.toJsonString());
        _logger.i('changePassword: Updated encryption metadata');

        // Update key in memory
        _encryptionKey = newKey;

        _logger.i('changePassword: Password changed successfully');
        notifyListeners();
      } catch (e, stack) {
        _logger.e('changePassword: Failed to change password: $e\n$stack');
        rethrow;
      }
    });
  }

  /// Get decrypted wallet JSON (only available when unlocked)
  String? get decryptedWalletJson => _decryptedWalletJson;

  /// Update wallet data and re-encrypt to disk (only for already encrypted wallets)
  /// This should be called after wallet modifications when wallet is encrypted
  Future<void> updateEncryptedWallet(String newWalletJson) async {
    await _lock.synchronized(() async {
      try {
        _logger.i('updateEncryptedWallet: Updating encrypted wallet');

        // Check if wallet is encrypted
        final metadata = await _loadMetadata();
        if (metadata == null || !metadata.encrypted) {
          throw Exception('Wallet is not encrypted');
        }

        // Check if wallet is unlocked
        if (_encryptionKey == null) {
          throw Exception('Wallet is locked');
        }

        // Validate that new data is valid JSON
        jsonDecode(newWalletJson);

        // Update in-memory copy
        _decryptedWalletJson = newWalletJson;
        _logger.i('updateEncryptedWallet: Updated in-memory wallet');

        // Re-encrypt and save to disk
        final encryptedData = _encrypt(newWalletJson, _encryptionKey!);
        _logger.i('updateEncryptedWallet: Re-encrypted wallet data');

        final walletFile = _getWalletFile();
        final tempFile = File('${walletFile.path}.tmp');
        await tempFile.writeAsString(encryptedData);
        await tempFile.rename(walletFile.path);
        _logger.i('updateEncryptedWallet: Saved re-encrypted wallet to disk');

        notifyListeners();
      } catch (e, stack) {
        _logger.e('updateEncryptedWallet: Failed to update encrypted wallet: $e\n$stack');
        rethrow;
      }
    });
  }

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
    _encryptionKey = null;
    super.dispose();
  }
}
