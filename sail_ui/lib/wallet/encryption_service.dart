import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart' hide Key;

/// Metadata stored alongside encrypted wallet
class EncryptionMetadata {
  final String salt;
  final int iterations;
  final bool encrypted;
  final String version;

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

/// Pure encryption/decryption service
class EncryptionService {
  static const int _keyLength = 32;
  static const int _saltLength = 32;
  static const int defaultIterations = 100000;

  /// Derive encryption key from password using PBKDF2 in an isolate
  static Future<Uint8List> deriveKey(String password, Uint8List salt, int iterations) async {
    return await compute(_deriveKeyIsolate, {
      'password': password,
      'salt': salt,
      'iterations': iterations,
      'keyLength': _keyLength,
    });
  }

  /// PBKDF2 implementation (runs in isolate)
  static Uint8List _deriveKeyIsolate(Map<String, dynamic> params) {
    final password = params['password'] as String;
    final salt = params['salt'] as Uint8List;
    final iterations = params['iterations'] as int;
    final keyLength = params['keyLength'] as int;

    final passwordBytes = utf8.encode(password);

    final result = Uint8List(keyLength);
    var blockIndex = 1;
    var offset = 0;

    while (offset < keyLength) {
      final block = Uint8List(salt.length + 4);
      block.setAll(0, salt);
      block[salt.length] = (blockIndex >> 24) & 0xff;
      block[salt.length + 1] = (blockIndex >> 16) & 0xff;
      block[salt.length + 2] = (blockIndex >> 8) & 0xff;
      block[salt.length + 3] = blockIndex & 0xff;

      var u = Uint8List.fromList(Hmac(sha256, passwordBytes).convert(block).bytes);
      var f = Uint8List.fromList(u);

      for (var i = 1; i < iterations; i++) {
        u = Uint8List.fromList(Hmac(sha256, passwordBytes).convert(u).bytes);
        for (var j = 0; j < f.length; j++) {
          f[j] ^= u[j];
        }
      }

      final remaining = keyLength - offset;
      final toCopy = remaining < f.length ? remaining : f.length;
      result.setRange(offset, offset + toCopy, f);
      offset += toCopy;
      blockIndex++;
    }

    return result;
  }

  /// Generate random salt
  static Uint8List generateSalt() {
    final random = Random.secure();
    final salt = Uint8List(_saltLength);
    for (var i = 0; i < _saltLength; i++) {
      salt[i] = random.nextInt(256);
    }
    return salt;
  }

  /// Encrypt data using AES-256-GCM
  static String encrypt(String plaintext, Uint8List key) {
    final keyObj = Key(key);
    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(keyObj, mode: AESMode.gcm));

    final encrypted = encrypter.encrypt(plaintext, iv: iv);

    return '${iv.base64}:${encrypted.base64}';
  }

  /// Decrypt data using AES-256-GCM
  static String decrypt(String ciphertext, Uint8List key) {
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
