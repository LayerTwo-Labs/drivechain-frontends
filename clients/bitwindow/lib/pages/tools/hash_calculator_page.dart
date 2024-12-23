import 'dart:convert';
import 'dart:typed_data';
import 'package:auto_route/auto_route.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

@RoutePage()
class HashCalculatorPage extends StatefulWidget {
  const HashCalculatorPage({Key? key}) : super(key: key);

  @override
  _HashCalculatorPageState createState() => _HashCalculatorPageState();
}

class _HashCalculatorPageState extends State<HashCalculatorPage> {
  // Basic section
  final TextEditingController _basicInputController = TextEditingController();
  bool _isHexMode = false;
  bool _invalidHex = false;
  bool _canFlip = false;

  // HMAC section
  final TextEditingController _hmacKeyController = TextEditingController();
  final TextEditingController _hmacMessageController = TextEditingController();
  bool _hmacIsHexMode = false;
  bool _hmacInvalidHex = false;

  @override
  void initState() {
    super.initState();
    _basicInputController.addListener(_updateBasicOutput);
    _hmacKeyController.addListener(_updateHmacOutput);
    _hmacMessageController.addListener(_updateHmacOutput);
  }

  @override
  void dispose() {
    _basicInputController.removeListener(_updateBasicOutput);
    _hmacKeyController.removeListener(_updateHmacOutput);
    _hmacMessageController.removeListener(_updateHmacOutput);

    _basicInputController.dispose();
    _hmacKeyController.dispose();
    _hmacMessageController.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data != null && data.text != null) {
      _basicInputController.text = data.text!;
    }
  }

  void _showBasicHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Information"),
        content: SingleChildScrollView(
          child: Text(
            "Hex:\n"
            "The hexadecimal (base 16) representation.\n\n"
            "SHA-256:\n"
            "256 bit output from the Secure Hash Algorithm 2 hash function.\n\n"
            "SHA-256D:\n"
            "256 bit output from Bitcoin's SHA-256D / Hash256 [sha256(sha256())].\n\n"
            "SHA-512:\n"
            "512 bit output from the Secure Hash Algorithm 2 hash function.\n"
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Ok"))
        ],
      ),
    );
  }

  void _showInvalidHexHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Information"),
        content: Text("Please enter valid Hex without spaces or 0x prefix."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Ok"))
        ],
      ),
    );
  }

  void _showHmacHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Information"),
        content: Text(
            "HMAC: Keyed-Hashing for Message Authentication\n\n"
            "HMAC-SHA256:\n"
            "256 bit keyed-hash output.\n\n"
            "HMAC-SHA512:\n"
            "512 bit keyed-hash output.\n"
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Ok"))
        ],
      ),
    );
  }

  Widget _buildBasicOutput() {
    final str = _basicInputController.text;
    if (str.isEmpty || (_isHexMode && _invalidHex)) {
      return Container();
    }

    List<int> dataBytes = _isHexMode ? hexDecode(str) : utf8.encode(str);

    // SHA256D
    var hash256D = sha256d(dataBytes);
    String hash256DHex = hexEncode(hash256D);
    String hash256DBin = hexToBinStr(hash256DHex);

    // SHA256
    var sha256res = crypto.sha256.convert(dataBytes).bytes;
    String sha256Hex = hexEncode(sha256res);
    String sha256Bin = hexToBinStr(sha256Hex);

    // SHA512
    var sha512res = crypto.sha512.convert(dataBytes).bytes;
    String sha512Hex = hexEncode(sha512res);
    String sha512Bin = hexToBinStr(sha512Hex);

    // Decode
    String decodeStr = _isHexMode ? String.fromCharCodes(dataBytes) : str;

    // Hex
    String hexStr = _isHexMode ? str.toLowerCase() : hexEncode(dataBytes);
    String binStr = hexToBinStr(hexStr);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("=== BASIC OUTPUT ===", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text("SHA256D:", style: TextStyle(fontWeight: FontWeight.bold)),
        SelectableText("$hash256DHex"),
        Text(hash256DBin, style: TextStyle(color: Colors.grey, fontSize: 12)),

        SizedBox(height: 8),
        Text("SHA256:", style: TextStyle(fontWeight: FontWeight.bold)),
        SelectableText("$sha256Hex"),
        Text(sha256Bin, style: TextStyle(color: Colors.grey, fontSize: 12)),

        SizedBox(height: 8),
        Text("SHA512:", style: TextStyle(fontWeight: FontWeight.bold)),
        SelectableText("$sha512Hex"),
        Text(sha512Bin, style: TextStyle(color: Colors.grey, fontSize: 12)),

        SizedBox(height: 8),
        Text("Decode:", style: TextStyle(fontWeight: FontWeight.bold)),
        SelectableText("$decodeStr"),

        SizedBox(height: 8),
        Text("Hex:", style: TextStyle(fontWeight: FontWeight.bold)),
        SelectableText("$hexStr"),

        Text("Bin:", style: TextStyle(fontWeight: FontWeight.bold)),
        SelectableText("$binStr"),
      ],
    );
  }

  void _updateBasicOutput() {
    final str = _basicInputController.text;
    if (_isHexMode) {
      bool fHex = isHex(str);
      setState(() {
        _invalidHex = !fHex && str.isNotEmpty;
        _canFlip = fHex && str.isNotEmpty;
      });
    } else {
      setState(() {
        _invalidHex = false;
        _canFlip = false;
      });
    }
  }

  void _flipHex() {
    final str = _basicInputController.text;
    if (str.isEmpty || !isHex(str)) return;
    List<int> bytes = hexDecode(str);
    bytes = bytes.reversed.toList();
    _basicInputController.text = hexEncode(bytes);
  }

  Widget _buildHmacOutput() {
    final keyStr = _hmacKeyController.text;
    final dataStr = _hmacMessageController.text;

    if (keyStr.isEmpty || dataStr.isEmpty || (_hmacIsHexMode && _hmacInvalidHex)) {
      return Container();
    }

    List<int> keyBytes = _hmacIsHexMode ? hexDecode(keyStr) : utf8.encode(keyStr);
    List<int> dataBytes = _hmacIsHexMode ? hexDecode(dataStr) : utf8.encode(dataStr);

    var hmacSha256 = crypto.Hmac(crypto.sha256, keyBytes);
    var sha256HmacRes = hmacSha256.convert(dataBytes).bytes;
    var sha256HmacHex = hexEncode(sha256HmacRes);
    var sha256HmacBin = hexToBinStr(sha256HmacHex);

    var hmacSha512 = crypto.Hmac(crypto.sha512, keyBytes);
    var sha512HmacRes = hmacSha512.convert(dataBytes).bytes;
    var sha512HmacHex = hexEncode(sha512HmacRes);
    var sha512HmacBin = hexToBinStr(sha512HmacHex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("=== HMAC OUTPUT ===", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text("HMAC-SHA256:", style: TextStyle(fontWeight: FontWeight.bold)),
        SelectableText("$sha256HmacHex"),
        Text(sha256HmacBin, style: TextStyle(color: Colors.grey, fontSize: 12)),

        SizedBox(height: 8),
        Text("HMAC-SHA512:", style: TextStyle(fontWeight: FontWeight.bold)),
        SelectableText("$sha512HmacHex"),
        Text(sha512HmacBin, style: TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  void _updateHmacOutput() {
    final keyStr = _hmacKeyController.text;
    final dataStr = _hmacMessageController.text;
    if (_hmacIsHexMode) {
      bool fHexKey = isHex(keyStr);
      bool fHexData = isHex(dataStr);
      setState(() {
        _hmacInvalidHex = (!fHexKey || !fHexData) && (keyStr.isNotEmpty && dataStr.isNotEmpty);
      });
    } else {
      setState(() {
        _hmacInvalidHex = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final basicWarningVisible = _isHexMode && _invalidHex;
    final hmacWarningVisible = _hmacIsHexMode && _hmacInvalidHex;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hash Calculator'),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side: Input area
          Container(
            width: 300,
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // BASIC INPUT
                Text("Basic Input", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        _basicInputController.clear();
                      }, 
                      icon: Icon(Icons.clear),
                      label: Text("Clear")
                    ),
                    SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _pasteFromClipboard, 
                      icon: Icon(Icons.paste),
                      label: Text("Paste")
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _showBasicHelp, 
                      icon: Icon(Icons.info_outline),
                      label: Text("Help")
                    ),
                    SizedBox(width: 8),
                    if (basicWarningVisible) 
                      IconButton(
                        icon: Icon(Icons.warning, color: Colors.orange),
                        onPressed: _showInvalidHexHelp,
                      ),
                    if (_canFlip)
                      ElevatedButton.icon(
                        onPressed: _flipHex,
                        icon: Icon(Icons.swap_horiz),
                        label: Text("Flip")
                      ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text("Hex mode:"),
                    Switch(
                      value: _isHexMode, 
                      onChanged: (val) {
                        setState(() {
                          _isHexMode = val;
                          _updateBasicOutput();
                        });
                      }
                    ),
                  ],
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _basicInputController,
                  decoration: InputDecoration(
                    labelText: _isHexMode ? "Enter Hex" : "Enter text",
                    border: OutlineInputBorder(),
                    errorText: basicWarningVisible ? "Invalid Hex input" : null,
                  ),
                  maxLines: 5,
                ),
                Divider(height: 32, thickness: 2),

                // HMAC INPUT
                Text("HMAC Input", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        _hmacKeyController.clear();
                        _hmacMessageController.clear();
                      }, 
                      icon: Icon(Icons.clear),
                      label: Text("Clear")
                    ),
                    SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _showHmacHelp, 
                      icon: Icon(Icons.info_outline),
                      label: Text("Help")
                    ),
                  ],
                ),
                SizedBox(height: 8),
                if (hmacWarningVisible)
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange),
                      SizedBox(width: 4),
                      GestureDetector(
                        onTap: _showInvalidHexHelp,
                        child: Text("Invalid Hex input!", style: TextStyle(color: Colors.red)),
                      )
                    ],
                  ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text("Hex mode:"),
                    Switch(
                      value: _hmacIsHexMode, 
                      onChanged: (val) {
                        setState(() {
                          _hmacIsHexMode = val;
                          _updateHmacOutput();
                        });
                      }
                    ),
                  ],
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _hmacKeyController,
                  decoration: InputDecoration(
                    labelText: _hmacIsHexMode ? "Key Hex" : "Key Text",
                    border: OutlineInputBorder(),
                    errorText: hmacWarningVisible ? "Invalid Hex input" : null,
                  ),
                  maxLines: 1,
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _hmacMessageController,
                  decoration: InputDecoration(
                    labelText: _hmacIsHexMode ? "Message Hex" : "Message Text",
                    border: OutlineInputBorder(),
                    errorText: hmacWarningVisible ? "Invalid Hex input" : null,
                  ),
                  maxLines: 5,
                ),
              ],
            ),
          ),

          // Right side: Output area
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBasicOutput(),
                  SizedBox(height: 32),
                  _buildHmacOutput(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}