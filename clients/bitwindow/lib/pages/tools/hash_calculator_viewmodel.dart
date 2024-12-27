import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart' as crypto;
import 'package:pointycastle/digests/ripemd160.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:sail_ui/sail_ui.dart';

bool isHex(String str) {
  final hexRegex = RegExp(r'^[0-9a-fA-F]+$');
  return hexRegex.hasMatch(str);
}

String hexToBinStr(String hex) {
  if (!isHex(hex)) return "";
  return hex.split('').map((c) {
    int val = int.parse(c, radix: 16);
    return val.toRadixString(2).padLeft(4, '0');
  }).join();
}

List<int> hexDecode(String hexStr) {
  return List<int>.generate(hexStr.length ~/ 2,
    (i) => int.parse(hexStr.substring(i*2,i*2+2), radix:16));
}

String hexEncode(List<int> bytes) {
  return bytes.map((b) => b.toRadixString(16).padLeft(2,'0')).join();
}

Uint8List sha256d(List<int> data) {
  var first = crypto.sha256.convert(data).bytes;
  var second = crypto.sha256.convert(first).bytes;
  return Uint8List.fromList(second);
}

Uint8List hash160(List<int> data) {
  var sha256Result = crypto.sha256.convert(data).bytes;
  final ripemd160 = RIPEMD160Digest();
  return Uint8List.fromList(ripemd160.process(Uint8List.fromList(sha256Result)));
}

class HashOutput {
  final String hex;
  final String bin;
  final bool isBitcoinChecksum;

  HashOutput(this.hex, this.bin, {this.isBitcoinChecksum = false});

  @override
  String toString() {
    return '$hex\n$bin';
  }
}

class HashSection {
  final String title;
  final HashOutput output;
  final String bitcoinUsage;

  HashSection(this.title, this.output, {required this.bitcoinUsage});
}

class HashCalculatorViewModel extends BaseViewModel {
  // Basic section
  final TextEditingController basicInputController = TextEditingController();
  bool isHexMode = false;
  bool invalidHex = false;
  bool canFlip = false;
  bool showBitcoinUsage = false;

  // HMAC section
  final TextEditingController hmacKeyController = TextEditingController();
  final TextEditingController hmacMessageController = TextEditingController();
  bool hmacIsHexMode = false;
  bool hmacInvalidHex = false;

  HashCalculatorViewModel() {
    basicInputController.addListener(_updateBasicOutput);
    hmacKeyController.addListener(_updateHmacOutput);
    hmacMessageController.addListener(_updateHmacOutput);
  }

  Future<void> pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data != null && data.text != null) {
      basicInputController.text = data.text!;
    }
  }

  void clearBasic() {
    basicInputController.clear();
  }

  void clearHmac() {
    hmacKeyController.clear();
    hmacMessageController.clear();
  }

  void toggleHexMode() {
    isHexMode = !isHexMode;
    _updateBasicOutput();
    notifyListeners();
  }

  void toggleHmacHexMode() {
    hmacIsHexMode = !hmacIsHexMode;
    _updateHmacOutput();
    notifyListeners();
  }

  void flipHex() {
    final str = basicInputController.text;
    if (str.isEmpty || !isHex(str)) return;
    List<int> bytes = hexDecode(str);
    bytes = bytes.reversed.toList();
    basicInputController.text = hexEncode(bytes);
  }

  void toggleBitcoinUsage() {
    showBitcoinUsage = !showBitcoinUsage;
    notifyListeners();
  }

  List<HashSection> getHashSections() {
    final str = basicInputController.text;
    if (str.isEmpty || (isHexMode && invalidHex)) {
      return [];
    }

    List<int> dataBytes = isHexMode ? hexDecode(str) : utf8.encode(str);

    return [
      HashSection(
        'SHA256',
        HashOutput(
          hexEncode(crypto.sha256.convert(dataBytes).bytes),
          hexToBinStr(hexEncode(crypto.sha256.convert(dataBytes).bytes))
        ),
        bitcoinUsage: 'Used in the first step of Hash160, HMAC for message signing, and various internal Bitcoin operations'
      ),
      HashSection(
        'SHA256D',
        HashOutput(
          hexEncode(sha256d(dataBytes)),
          hexToBinStr(hexEncode(sha256d(dataBytes))),
          isBitcoinChecksum: true
        ),
        bitcoinUsage: 'Used in block hashing, transaction IDs, and P2SH address generation'
      ),
      HashSection(
        'SHA512',
        HashOutput(
          hexEncode(crypto.sha512.convert(dataBytes).bytes),
          hexToBinStr(hexEncode(crypto.sha512.convert(dataBytes).bytes))
        ),
        bitcoinUsage: 'Used in BIP32 hierarchical deterministic wallet key derivation'
      ),
      HashSection(
        'RIPEMD160',
        HashOutput(
          hexEncode(RIPEMD160Digest().process(Uint8List.fromList(dataBytes))),
          hexToBinStr(hexEncode(RIPEMD160Digest().process(Uint8List.fromList(dataBytes))))
        ),
        bitcoinUsage: 'Used as the second step in Hash160 to create Bitcoin addresses'
      ),
      HashSection(
        'Hash160',
        HashOutput(
          hexEncode(hash160(dataBytes)),
          hexToBinStr(hexEncode(hash160(dataBytes))),
          isBitcoinChecksum: true
        ),
        bitcoinUsage: 'Used in P2PKH addresses for converting public keys to Bitcoin addresses'
      ),
    ];
  }

  String? getBasicOutput() {
    final str = basicInputController.text;
    if (str.isEmpty || (isHexMode && invalidHex)) {
      return null;
    }

    List<int> dataBytes = isHexMode ? hexDecode(str) : utf8.encode(str);

    // Decode
    String decodeStr = isHexMode ? String.fromCharCodes(dataBytes) : str;

    // Hex
    String hexStr = isHexMode ? str.toLowerCase() : hexEncode(dataBytes);
    String binStr = hexToBinStr(hexStr);

    final sections = getHashSections();
    final hashOutputs = sections.map((section) {
      final title = showBitcoinUsage ? '${section.title} - ${section.bitcoinUsage}' : section.title;
      return '$title:\n${section.output}';
    }).join('\n\n');

    return '''$hashOutputs

Decode:
$decodeStr

Hex:
$hexStr

Bin:
$binStr''';
  }

  HashOutput getHmacSha256() {
    final keyStr = hmacKeyController.text;
    final dataStr = hmacMessageController.text;

    if (keyStr.isEmpty || dataStr.isEmpty || (hmacIsHexMode && hmacInvalidHex)) {
      return HashOutput('', '');
    }

    List<int> keyBytes = hmacIsHexMode ? hexDecode(keyStr) : utf8.encode(keyStr);
    List<int> dataBytes = hmacIsHexMode ? hexDecode(dataStr) : utf8.encode(dataStr);

    var hmacSha256 = crypto.Hmac(crypto.sha256, keyBytes);
    var sha256HmacRes = hmacSha256.convert(dataBytes).bytes;
    var sha256HmacHex = hexEncode(sha256HmacRes);
    var sha256HmacBin = hexToBinStr(sha256HmacHex);

    return HashOutput(sha256HmacHex, sha256HmacBin);
  }

  HashOutput getHmacSha512() {
    final keyStr = hmacKeyController.text;
    final dataStr = hmacMessageController.text;

    if (keyStr.isEmpty || dataStr.isEmpty || (hmacIsHexMode && hmacInvalidHex)) {
      return HashOutput('', '');
    }

    List<int> keyBytes = hmacIsHexMode ? hexDecode(keyStr) : utf8.encode(keyStr);
    List<int> dataBytes = hmacIsHexMode ? hexDecode(dataStr) : utf8.encode(dataStr);

    var hmacSha512 = crypto.Hmac(crypto.sha512, keyBytes);
    var sha512HmacRes = hmacSha512.convert(dataBytes).bytes;
    var sha512HmacHex = hexEncode(sha512HmacRes);
    var sha512HmacBin = hexToBinStr(sha512HmacHex);

    return HashOutput(sha512HmacHex, sha512HmacBin);
  }

  String? getHmacOutput() {
    final keyStr = hmacKeyController.text;
    final dataStr = hmacMessageController.text;

    if (keyStr.isEmpty || dataStr.isEmpty || (hmacIsHexMode && hmacInvalidHex)) {
      return null;
    }

    return 'valid';
  }

  void _updateBasicOutput() {
    final str = basicInputController.text;
    if (isHexMode) {
      bool fHex = isHex(str);
      invalidHex = !fHex && str.isNotEmpty;
      canFlip = fHex && str.isNotEmpty;
    } else {
      invalidHex = false;
      canFlip = false;
    }
    notifyListeners();
  }

  void _updateHmacOutput() {
    final keyStr = hmacKeyController.text;
    final dataStr = hmacMessageController.text;
    if (hmacIsHexMode) {
      bool fHexKey = isHex(keyStr);
      bool fHexData = isHex(dataStr);
      hmacInvalidHex = (!fHexKey || !fHexData) && (keyStr.isNotEmpty && dataStr.isNotEmpty);
    } else {
      hmacInvalidHex = false;
    }
    notifyListeners();
  }

  Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  @override
  void dispose() {
    basicInputController.removeListener(_updateBasicOutput);
    hmacKeyController.removeListener(_updateHmacOutput);
    hmacMessageController.removeListener(_updateHmacOutput);

    basicInputController.dispose();
    hmacKeyController.dispose();
    hmacMessageController.dispose();
    super.dispose();
  }
} 