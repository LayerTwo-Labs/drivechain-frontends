import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// Base58Check encoding and decoding utilities for Bitcoin addresses
class Base58Check {
  static const String _alphabet = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

  /// Decode a Base58Check string to its components
  static Base58DecodeResult? decode(String input) {
    try {
      // Decode Base58 to bytes
      final decoded = _base58Decode(input);
      if (decoded.isEmpty || decoded.length < 5) {
        return null; // Too short for valid Base58Check
      }

      // Split payload and checksum
      final payload = decoded.sublist(0, decoded.length - 4);
      final checksum = decoded.sublist(decoded.length - 4);

      // Verify checksum
      final calculatedChecksum = _doubleHash(payload).sublist(0, 4);
      final checksumValid = _bytesEqual(checksum, calculatedChecksum);

      // Extract version and data
      final version = payload[0];
      final data = payload.sublist(1);

      return Base58DecodeResult(
        versionByte: version,
        payload: data,
        checksum: checksum,
        checksumValid: checksumValid,
      );
    } catch (e) {
      return null;
    }
  }

  /// Encode data to Base58Check format
  static String? encode(int versionByte, List<int> data) {
    try {
      // Combine version + data
      final payload = Uint8List.fromList([versionByte, ...data]);

      // Calculate checksum
      final checksum = _doubleHash(payload).sublist(0, 4);

      // Combine payload + checksum
      final combined = Uint8List.fromList([...payload, ...checksum]);

      // Encode to Base58
      return _base58Encode(combined);
    } catch (e) {
      return null;
    }
  }

  /// Decode Base58 string to bytes
  static Uint8List _base58Decode(String input) {
    if (input.isEmpty) return Uint8List(0);

    // Count leading zeros
    int leadingZeros = 0;
    while (leadingZeros < input.length && input[leadingZeros] == '1') {
      leadingZeros++;
    }

    // Convert Base58 to BigInt
    BigInt value = BigInt.zero;
    final base = BigInt.from(58);

    for (int i = 0; i < input.length; i++) {
      final char = input[i];
      final index = _alphabet.indexOf(char);
      if (index == -1) {
        throw ArgumentError('Invalid Base58 character: $char');
      }
      value = value * base + BigInt.from(index);
    }

    // Convert BigInt to bytes
    final bytes = _bigIntToBytes(value);

    // Add leading zeros
    return Uint8List.fromList([...List.filled(leadingZeros, 0), ...bytes]);
  }

  /// Encode bytes to Base58 string
  static String _base58Encode(Uint8List input) {
    if (input.isEmpty) return '';

    // Count leading zeros
    int leadingZeros = 0;
    while (leadingZeros < input.length && input[leadingZeros] == 0) {
      leadingZeros++;
    }

    // Convert bytes to BigInt
    BigInt value = _bytesToBigInt(input);

    // Convert to Base58
    final base = BigInt.from(58);
    final result = StringBuffer();

    while (value > BigInt.zero) {
      final remainder = (value % base).toInt();
      result.write(_alphabet[remainder]);
      value = value ~/ base;
    }

    // Add leading '1's for leading zeros
    final encoded = result.toString().split('').reversed.join();
    return '${'1' * leadingZeros}$encoded';
  }

  /// Calculate double SHA-256 hash
  static Uint8List _doubleHash(List<int> data) {
    final firstHash = sha256.convert(data).bytes;
    final secondHash = sha256.convert(firstHash).bytes;
    return Uint8List.fromList(secondHash);
  }

  /// Convert bytes to BigInt
  static BigInt _bytesToBigInt(List<int> bytes) {
    BigInt result = BigInt.zero;
    for (final byte in bytes) {
      result = (result << 8) | BigInt.from(byte);
    }
    return result;
  }

  /// Convert BigInt to bytes
  static List<int> _bigIntToBytes(BigInt value) {
    if (value == BigInt.zero) return [0];

    final bytes = <int>[];
    while (value > BigInt.zero) {
      bytes.insert(0, (value & BigInt.from(0xff)).toInt());
      value = value >> 8;
    }
    return bytes;
  }

  /// Compare two byte arrays for equality
  static bool _bytesEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Get address type from version byte
  static String getAddressType(int versionByte) {
    switch (versionByte) {
      case 0x00:
        return 'P2PKH (Pay-to-PubKey-Hash) - Mainnet';
      case 0x05:
        return 'P2SH (Pay-to-Script-Hash) - Mainnet';
      case 0x6F:
        return 'P2PKH (Pay-to-PubKey-Hash) - Testnet';
      case 0xC4:
        return 'P2SH (Pay-to-Script-Hash) - Testnet';
      case 0x80:
        return 'Private Key (WIF) - Mainnet';
      case 0xEF:
        return 'Private Key (WIF) - Testnet';
      default:
        return 'Unknown (0x${versionByte.toRadixString(16).toUpperCase().padLeft(2, '0')})';
    }
  }

  /// Validate Base58 string characters
  static bool isValidBase58(String input) {
    for (int i = 0; i < input.length; i++) {
      if (!_alphabet.contains(input[i])) {
        return false;
      }
    }
    return true;
  }
}

/// Result of Base58Check decoding
class Base58DecodeResult {
  final int versionByte;
  final List<int> payload;
  final List<int> checksum;
  final bool checksumValid;

  Base58DecodeResult({
    required this.versionByte,
    required this.payload,
    required this.checksum,
    required this.checksumValid,
  });

  String get versionHex => '0x${versionByte.toRadixString(16).toUpperCase().padLeft(2, '0')}';
  String get payloadHex => payload.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
  String get checksumHex => checksum.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
  String get addressType => Base58Check.getAddressType(versionByte);
}
