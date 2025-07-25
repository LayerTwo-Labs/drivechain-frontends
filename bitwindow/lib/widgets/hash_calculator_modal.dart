import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pointycastle/export.dart' as pc;
import 'package:sail_ui/sail_ui.dart';

class HashCalculator extends StatefulWidget {
  const HashCalculator({super.key});

  @override
  State<HashCalculator> createState() => _HashCalculatorState();
}

class _HashCalculatorState extends State<HashCalculator> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _hmacKeyController = TextEditingController();
  bool _isHexMode = false;
  bool _useHmac = false;
  String _output = '';
  String _hexValidationError = '';

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailCard(
      padding: true,
      widgetHeaderEnd: SailButton(
        label: '?',
        onPressed: () async => _showHelpDialog(context),
        variant: ButtonVariant.ghost,
      ),
      withCloseButton: false,
      child: Padding(
        padding: const EdgeInsets.all(SailStyleValues.padding16),
        child: SailColumn(
          spacing: SailStyleValues.padding12,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input controls
            SailCard(
              padding: true,
              secondary: true,
              child: SailColumn(
                spacing: SailStyleValues.padding12,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SailRow(
                    spacing: SailStyleValues.padding08,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SailText.primary13('Input'),
                      SailCheckbox(
                        value: _isHexMode,
                        onChanged: (value) {
                          setState(() {
                            _isHexMode = value;
                            _calculateHash();
                          });
                        },
                        label: 'Hex',
                      ),
                      SailCheckbox(
                        value: _useHmac,
                        onChanged: (value) {
                          setState(() {
                            _useHmac = value;
                            _calculateHash();
                          });
                        },
                        label: 'HMAC',
                      ),
                      if (_isHexMode && _hexValidationError.isNotEmpty)
                        SailText.primary13(
                          _hexValidationError,
                          color: theme.colors.error,
                        ),
                      const Spacer(),
                      SailButton(
                        label: 'Clear',
                        onPressed: () async {
                          _inputController.clear();
                          _hmacKeyController.clear();
                        },
                        variant: ButtonVariant.secondary,
                      ),
                      SailButton(
                        label: 'Paste',
                        onPressed: () async {
                          final data = await Clipboard.getData(Clipboard.kTextPlain);
                          final text = data?.text;
                          if (text != null) {
                            _inputController.text = text;
                          }
                        },
                        variant: ButtonVariant.secondary,
                      ),
                      if (_isHexMode)
                        SailButton(
                          label: 'Flip Bytes',
                          onPressed: () async {
                            if (_isValidHex(_inputController.text)) {
                              final bytes = _getInputBytes().toList().reversed.toList();
                              _inputController.text = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
                            }
                          },
                          variant: ButtonVariant.secondary,
                        ),
                    ],
                  ),
                  SailTextField(
                    controller: _inputController,
                    hintText: _isHexMode ? 'Enter hex without spaces or 0x prefix' : 'Enter text to hash',
                    textFieldType: TextFieldType.text,
                    size: TextFieldSize.small,
                    maxLines: 1,
                  ),
                  if (_useHmac)
                    SailTextField(
                      controller: _hmacKeyController,
                      hintText: _isHexMode ? 'Enter key hex' : 'Enter key text',
                      textFieldType: TextFieldType.text,
                      size: TextFieldSize.small,
                      maxLines: 1,
                    ),
                ],
              ),
            ),

            // Result section
            Expanded(
              child: SingleChildScrollView(
                child: SailCard(
                  padding: true,
                  secondary: true,
                  child: SailColumn(
                    spacing: 4,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _useHmac ? _buildHMACResults(theme) : _buildHashResults(theme),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _calculateHash() {
    if (_inputController.text.isEmpty) {
      setState(() {
        _output = '';
        _hexValidationError = '';
      });
      return;
    }

    if (_isHexMode) {
      final inputError = _getHexValidationError(_inputController.text);
      final keyError = _useHmac ? _getHexValidationError(_hmacKeyController.text) : '';

      if (inputError.isNotEmpty || (_useHmac && keyError.isNotEmpty)) {
        setState(() {
          _output = '';
          _hexValidationError = inputError.isNotEmpty ? 'Input: $inputError' : 'Key: $keyError';
        });
        return;
      }
    }

    setState(() {
      _hexValidationError = '';
      _output = _generateOutput();
    });
  }

  String _getHexValidationError(String text) {
    if (text.isEmpty) {
      return '';
    }
    if (text.length % 2 != 0) {
      return 'Invalid length';
    }
    if (!RegExp(r'^[0-9a-fA-F]*$').hasMatch(text)) {
      return 'Invalid hex';
    }
    return '';
  }

  bool _isValidHex(String text) {
    return _getHexValidationError(text).isEmpty;
  }

  List<int> _getInputBytes() {
    if (_isHexMode) {
      final hexStr = _inputController.text.toLowerCase();
      if (!_isValidHex(hexStr)) {
        return [];
      }
      try {
        final bytes = <int>[];
        for (var i = 0; i < hexStr.length; i += 2) {
          if (i + 1 >= hexStr.length) {
            return [];
          }
          bytes.add(int.parse(hexStr.substring(i, i + 2), radix: 16));
        }
        return bytes;
      } catch (e) {
        return [];
      }
    } else {
      return utf8.encode(_inputController.text);
    }
  }

  String _hexToBin(String hex) {
    final result = StringBuffer();
    for (var i = 0; i < hex.length; i++) {
      switch (hex[i].toLowerCase()) {
        case '0':
          result.write('0000');
          break;
        case '1':
          result.write('0001');
          break;
        case '2':
          result.write('0010');
          break;
        case '3':
          result.write('0011');
          break;
        case '4':
          result.write('0100');
          break;
        case '5':
          result.write('0101');
          break;
        case '6':
          result.write('0110');
          break;
        case '7':
          result.write('0111');
          break;
        case '8':
          result.write('1000');
          break;
        case '9':
          result.write('1001');
          break;
        case 'a':
          result.write('1010');
          break;
        case 'b':
          result.write('1011');
          break;
        case 'c':
          result.write('1100');
          break;
        case 'd':
          result.write('1101');
          break;
        case 'e':
          result.write('1110');
          break;
        case 'f':
          result.write('1111');
          break;
      }
    }
    return result.toString();
  }

  String _generateOutput() {
    final bytes = _getInputBytes();

    if (_isHexMode && bytes.isEmpty) {
      return '';
    }

    final result = StringBuffer();

    // SHA256D (double SHA256)
    final sha256d = sha256.convert(sha256.convert(bytes).bytes);
    result.writeln('<b>SHA256D:</b> ${sha256d.toString()}');
    result.writeln('<font color="gray" size=2px>${_hexToBin(sha256d.toString())}</font><br>');

    // Hash160 (SHA256 + RIPEMD160)
    final ripemd160Digest = pc.Digest('RIPEMD-160');
    final hash160 = ripemd160Digest.process(Uint8List.fromList(sha256.convert(bytes).bytes));
    final hash160Hex = hash160.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    result.writeln('<b>Hash160 - RIPEMD160(SHA256):</b> $hash160Hex');
    result.writeln('<font color="gray" size=2px>${_hexToBin(hash160Hex)}</font><br>');

    // RIPEMD160
    final ripemd160 = ripemd160Digest.process(Uint8List.fromList(bytes));
    final ripemd160Hex = ripemd160.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    result.writeln('<b>RIPEMD160:</b> $ripemd160Hex');
    result.writeln('<font color="gray" size=2px>${_hexToBin(ripemd160Hex)}</font><br>');

    // SHA256
    final sha256Result = sha256.convert(bytes);
    result.writeln('<b>SHA256:</b> ${sha256Result.toString()}');
    result.writeln('<font color="gray" size=2px>${_hexToBin(sha256Result.toString())}</font><br>');

    // SHA512
    final sha512Result = sha512.convert(bytes);
    result.writeln('<b>SHA512:</b> ${sha512Result.toString()}');
    result.writeln('<font color="gray" size=2px>${_hexToBin(sha512Result.toString())}</font><br>');

    // Decode
    if (_isHexMode) {
      result.writeln('<b>Decode:</b> ${String.fromCharCodes(bytes)}');
    } else {
      result.writeln('<b>Decode:</b> ${_inputController.text}');
    }
    result.writeln('');

    // Hex
    if (_isHexMode) {
      result.writeln('<b>Hex:</b> ${_inputController.text}');
    } else {
      result.writeln('<b>Hex:</b> ${bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}');
    }

    // Binary
    if (_isHexMode) {
      result.writeln('<b>Bin:</b> ${_hexToBin(_inputController.text)}');
    } else {
      result.writeln('<b>Bin:</b> ${_hexToBin(bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join())}');
    }

    return result.toString();
  }

  String _generateHMACOutput() {
    if (_hmacKeyController.text.isEmpty || _inputController.text.isEmpty) {
      return '';
    }

    final key = _hmacKeyController.text;
    final bytes = _getInputBytes();
    final keyBytes = _isHexMode ? _hexToBytes(key) : utf8.encode(key);

    if (_isHexMode && (bytes.isEmpty || keyBytes.isEmpty)) {
      return '';
    }

    final result = StringBuffer();

    // HMAC-SHA256
    final hmacSha256 = Hmac(sha256, keyBytes);
    final hmacSha256Result = hmacSha256.convert(bytes);
    result.writeln('<b>HMAC-SHA256:</b> ${hmacSha256Result.toString()}');
    result.writeln('<font color="gray" size=2px>${_hexToBin(hmacSha256Result.toString())}</font><br>');

    // HMAC-SHA512
    final hmacSha512 = Hmac(sha512, keyBytes);
    final hmacSha512Result = hmacSha512.convert(bytes);
    result.writeln('<b>HMAC-SHA512:</b> ${hmacSha512Result.toString()}');
    result.writeln('<font color="gray" size=2px>${_hexToBin(hmacSha512Result.toString())}</font><br>');

    return result.toString();
  }

  List<int> _hexToBytes(String hex) {
    if (!_isValidHex(hex)) {
      return [];
    }
    try {
      final bytes = <int>[];
      for (var i = 0; i < hex.length; i += 2) {
        if (i + 1 >= hex.length) {
          return [];
        }
        bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
      }
      return bytes;
    } catch (e) {
      return [];
    }
  }

  List<Widget> _buildHashResults(SailThemeData theme) {
    final results = <Widget>[];

    // SHA256D
    results.add(
      SailRow(
        spacing: SailStyleValues.padding08,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SailText.primary13('SHA256D: ', color: theme.colors.text),
          if (_output.isNotEmpty)
            Expanded(
              child: SailText.primary13(
                RegExp(r'<b>SHA256D:</b> ([a-fA-F0-9]+)').firstMatch(_output)?.group(1) ?? '',
                color: theme.colors.textSecondary,
              ),
            ),
        ],
      ),
    );
    if (_output.isNotEmpty) {
      final sha256dMatch = RegExp(r'<b>SHA256D:</b> ([a-fA-F0-9]+)').firstMatch(_output);
      if (sha256dMatch != null) {
        results.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: SailText.primary10(
              _hexToBin(sha256dMatch.group(1)!),
              color: theme.colors.textTertiary,
            ),
          ),
        );
      }
    }

    // Hash160
    results.add(
      SailRow(
        spacing: SailStyleValues.padding08,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SailText.primary13('Hash160 - RIPEMD160(SHA256): ', color: theme.colors.text),
          if (_output.isNotEmpty)
            Expanded(
              child: SailText.primary13(
                RegExp(r'<b>Hash160.*?:</b> ([a-fA-F0-9]+)').firstMatch(_output)?.group(1) ?? '',
                color: theme.colors.textSecondary,
              ),
            ),
        ],
      ),
    );
    if (_output.isNotEmpty) {
      final hash160Match = RegExp(r'<b>Hash160.*?:</b> ([a-fA-F0-9]+)').firstMatch(_output);
      if (hash160Match != null) {
        results.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: SailText.primary10(
              _hexToBin(hash160Match.group(1)!),
              color: theme.colors.textTertiary,
            ),
          ),
        );
      }
    }

    // RIPEMD160
    results.add(
      SailRow(
        spacing: SailStyleValues.padding08,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SailText.primary13('RIPEMD160: ', color: theme.colors.text),
          if (_output.isNotEmpty)
            Expanded(
              child: SailText.primary13(
                RegExp(r'<b>RIPEMD160:</b> ([a-fA-F0-9]+)').firstMatch(_output)?.group(1) ?? '',
                color: theme.colors.textSecondary,
              ),
            ),
        ],
      ),
    );
    if (_output.isNotEmpty) {
      final ripemd160Match = RegExp(r'<b>RIPEMD160:</b> ([a-fA-F0-9]+)').firstMatch(_output);
      if (ripemd160Match != null) {
        results.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: SailText.primary10(
              _hexToBin(ripemd160Match.group(1)!),
              color: theme.colors.textTertiary,
            ),
          ),
        );
      }
    }

    // SHA256
    results.add(
      SailRow(
        spacing: SailStyleValues.padding08,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SailText.primary13('SHA256: ', color: theme.colors.text),
          if (_output.isNotEmpty)
            Expanded(
              child: SailText.primary13(
                RegExp(r'<b>SHA256:</b> ([a-fA-F0-9]+)').firstMatch(_output)?.group(1) ?? '',
                color: theme.colors.textSecondary,
              ),
            ),
        ],
      ),
    );
    if (_output.isNotEmpty) {
      final sha256Match = RegExp(r'<b>SHA256:</b> ([a-fA-F0-9]+)').firstMatch(_output);
      if (sha256Match != null) {
        results.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: SailText.primary10(
              _hexToBin(sha256Match.group(1)!),
              color: theme.colors.textTertiary,
            ),
          ),
        );
      }
    }

    // SHA512
    results.add(
      SailRow(
        spacing: SailStyleValues.padding08,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SailText.primary13('SHA512: ', color: theme.colors.text),
          if (_output.isNotEmpty)
            Expanded(
              child: SailText.primary13(
                RegExp(r'<b>SHA512:</b> ([a-fA-F0-9]+)').firstMatch(_output)?.group(1) ?? '',
                color: theme.colors.textSecondary,
              ),
            ),
        ],
      ),
    );
    if (_output.isNotEmpty) {
      final sha512Match = RegExp(r'<b>SHA512:</b> ([a-fA-F0-9]+)').firstMatch(_output);
      if (sha512Match != null) {
        results.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: SailText.primary10(
              _hexToBin(sha512Match.group(1)!),
              color: theme.colors.textTertiary,
            ),
          ),
        );
      }
    }

    // Decode
    results.add(
      SailRow(
        spacing: SailStyleValues.padding08,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SailText.primary13('Decode: ', color: theme.colors.text),
          if (_output.isNotEmpty)
            Expanded(
              child: SailText.primary13(
                RegExp(r'<b>Decode:</b> (.+)').firstMatch(_output)?.group(1) ?? '',
                color: theme.colors.textSecondary,
              ),
            ),
        ],
      ),
    );

    // Hex
    results.add(
      SailRow(
        spacing: SailStyleValues.padding08,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SailText.primary13('Hex: ', color: theme.colors.text),
          if (_output.isNotEmpty)
            Expanded(
              child: SailText.primary13(
                RegExp(r'<b>Hex:</b> ([a-fA-F0-9]+)').firstMatch(_output)?.group(1) ?? '',
                color: theme.colors.textSecondary,
              ),
            ),
        ],
      ),
    );

    // Binary
    results.add(
      SailRow(
        spacing: SailStyleValues.padding08,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SailText.primary13('Bin: ', color: theme.colors.text),
          if (_output.isNotEmpty)
            Expanded(
              child: SailText.primary13(
                RegExp(r'<b>Bin:</b> ([01]+)').firstMatch(_output)?.group(1) ?? '',
                color: theme.colors.textSecondary,
              ),
            ),
        ],
      ),
    );

    return results;
  }

  List<Widget> _buildHMACResults(SailThemeData theme) {
    final results = <Widget>[];

    // HMAC-SHA256
    results.add(
      SailRow(
        spacing: SailStyleValues.padding08,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SailText.primary13('HMAC-SHA256: ', color: theme.colors.text),
          if (_hmacKeyController.text.isNotEmpty && _inputController.text.isNotEmpty)
            Expanded(
              child: SailText.primary13(
                RegExp(r'<b>HMAC-SHA256:</b> ([a-fA-F0-9]+)').firstMatch(_generateHMACOutput())?.group(1) ?? '',
                color: theme.colors.textSecondary,
              ),
            ),
        ],
      ),
    );
    if (_hmacKeyController.text.isNotEmpty && _inputController.text.isNotEmpty) {
      final hmacOutput = _generateHMACOutput();
      final hmacSha256Match = RegExp(r'<b>HMAC-SHA256:</b> ([a-fA-F0-9]+)').firstMatch(hmacOutput);
      if (hmacSha256Match != null) {
        results.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: SailText.primary10(
              _hexToBin(hmacSha256Match.group(1)!),
              color: theme.colors.textTertiary,
            ),
          ),
        );
      }
    }

    // HMAC-SHA512
    results.add(
      SailRow(
        spacing: SailStyleValues.padding08,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SailText.primary13('HMAC-SHA512: ', color: theme.colors.text),
          if (_hmacKeyController.text.isNotEmpty && _inputController.text.isNotEmpty)
            Expanded(
              child: SailText.primary13(
                RegExp(r'<b>HMAC-SHA512:</b> ([a-fA-F0-9]+)').firstMatch(_generateHMACOutput())?.group(1) ?? '',
                color: theme.colors.textSecondary,
              ),
            ),
        ],
      ),
    );
    if (_hmacKeyController.text.isNotEmpty && _inputController.text.isNotEmpty) {
      final hmacOutput = _generateHMACOutput();
      final hmacSha512Match = RegExp(r'<b>HMAC-SHA512:</b> ([a-fA-F0-9]+)').firstMatch(hmacOutput);
      if (hmacSha512Match != null) {
        results.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: SailText.primary10(
              _hexToBin(hmacSha512Match.group(1)!),
              color: theme.colors.textTertiary,
            ),
          ),
        );
      }
    }

    return results;
  }

  void _showHelpDialog(BuildContext context) {
    final theme = SailTheme.of(context);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: theme.colors.backgroundSecondary,
        child: IntrinsicWidth(
          child: SailCard(
            title: 'Hash Calculator Help',
            subtitle: '',
            padding: true,
            withCloseButton: true,
            child: SailColumn(
              spacing: SailStyleValues.padding08,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SailText.primary13(
                  "SHA256D: 256 bit output from Bitcoin's SHA-256D [sha256(sha256())] hash function. Outputs in Little-Endian byte order.",
                ),
                SailText.primary13(
                  "Hash160: 160 bit output from Bitcoin's Hash160 [RIPEMD160(sha256())] hash function. Outputs in Little-Endian byte order.",
                ),
                SailText.primary13(
                  'RIPEMD160: 160 bit RIPE Message Digest.',
                ),
                SailText.primary13(
                  'SHA256: 256 bit output from the Secure Hash Algorithm 2 hash function.',
                ),
                SailText.primary13(
                  'SHA512: 512 bit output from the Secure Hash Algorithm 2 hash function.',
                ),
                SailText.primary13(
                  'Decode: Shows the input text or decoded hex bytes as text.',
                ),
                SailText.primary13(
                  'Hex: The hexadecimal (base 16) representation.',
                ),
                SailText.primary13(
                  'Bin: The binary (base 2) representation.',
                ),
                SailText.primary13(
                  'HMAC: Hash-based Message Authentication Code using SHA256 or SHA512 with a provided key.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _inputController.addListener(_calculateHash);
    _hmacKeyController.addListener(_calculateHash);
  }

  @override
  void dispose() {
    _inputController.removeListener(_calculateHash);
    _hmacKeyController.removeListener(_calculateHash);
    _inputController.dispose();
    _hmacKeyController.dispose();
    super.dispose();
  }
}
