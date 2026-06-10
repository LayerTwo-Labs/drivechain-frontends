import 'package:bitwindow/utils/base58.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:sail_ui/sail_ui.dart';

/// Base58Check Decoder Dialog - Decode and encode Base58Check strings
///
/// Qt equivalent: drivechaingui.cpp showBase58Dialog() (empty implementation)
/// This dialog provides Base58Check encoding/decoding functionality
class Base58DecoderDialog extends StatefulWidget {
  const Base58DecoderDialog({super.key});

  @override
  State<Base58DecoderDialog> createState() => _Base58DecoderDialogState();
}

class _Base58DecoderDialogState extends State<Base58DecoderDialog> {
  final TextEditingController _decodeInputController = TextEditingController();
  final TextEditingController _encodePayloadController = TextEditingController();
  final TextEditingController _encodeResultController = TextEditingController();

  Base58DecodeResult? _decodeResult;
  String? _decodeError;
  String? _encodeError;

  int _selectedVersionByte = 0x00; // P2PKH mainnet default

  final Map<int, String> _versionBytes = {
    0x00: '0x00 - P2PKH Mainnet',
    0x05: '0x05 - P2SH Mainnet',
    0x6F: '0x6F - P2PKH Testnet',
    0xC4: '0xC4 - P2SH Testnet',
    0x80: '0x80 - WIF Private Key Mainnet',
    0xEF: '0xEF - WIF Private Key Testnet',
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _decodeInputController.dispose();
    _encodePayloadController.dispose();
    _encodeResultController.dispose();
    super.dispose();
  }

  void _decode() {
    setState(() {
      _decodeError = null;
      _decodeResult = null;

      final input = _decodeInputController.text.trim();

      if (input.isEmpty) {
        _decodeError = 'Please enter a Base58 string';
        return;
      }

      if (!Base58Check.isValidBase58(input)) {
        _decodeError =
            'Invalid Base58 characters (allowed: 123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz)';
        return;
      }

      final result = Base58Check.decode(input);
      if (result == null) {
        _decodeError = 'Failed to decode Base58 string (invalid format or too short)';
        return;
      }

      _decodeResult = result;
    });
  }

  void _encode() {
    setState(() {
      _encodeError = null;
      _encodeResultController.clear();

      final payloadHex = _encodePayloadController.text.trim().replaceAll(' ', '');

      if (payloadHex.isEmpty) {
        _encodeError = 'Please enter a hex payload';
        return;
      }

      // Validate hex
      if (!RegExp(r'^[0-9a-fA-F]+$').hasMatch(payloadHex)) {
        _encodeError = 'Invalid hexadecimal input (only 0-9, a-f, A-F allowed)';
        return;
      }

      if (payloadHex.length % 2 != 0) {
        _encodeError = 'Hex string must have even length';
        return;
      }

      // Convert hex to bytes
      final bytes = <int>[];
      for (int i = 0; i < payloadHex.length; i += 2) {
        bytes.add(int.parse(payloadHex.substring(i, i + 2), radix: 16));
      }

      // Encode
      final result = Base58Check.encode(_selectedVersionByte, bytes);
      if (result == null) {
        _encodeError = 'Failed to encode data';
        return;
      }

      _encodeResultController.text = result;
    });
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    showSailToast(context, '$label copied to clipboard');
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    // Qt dialog structure: Header → Content → Footer
    return SailModal(
      child: Container(
        width: 800,
        constraints: const BoxConstraints(maxHeight: 700),
        decoration: BoxDecoration(
          color: theme.colors.backgroundSecondary,
          borderRadius: SailStyleValues.borderRadiusSmall,
          border: Border.all(color: theme.colors.border, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header - matches Qt dialog title bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: theme.colors.border),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SailText.primary20('Base58Check Decoder'), // Qt windowTitle
                  SailTappable(
                    onTap: () async => Navigator.of(context).pop(),
                    borderRadius: SailStyleValues.borderRadiusSmall,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: SailSVG.fromAsset(SailSVGAsset.x, color: theme.colors.text),
                    ),
                  ),
                ],
              ),
            ),

            // Content - Qt QVBoxLayout with tabs
            Expanded(
              child: InlineTabBar(
                initialIndex: 0,
                tabs: [
                  TabItem(
                    label: 'Decode',
                    child: _DecodeTab(
                      controller: _decodeInputController,
                      decodeResult: _decodeResult,
                      decodeError: _decodeError,
                      onDecode: _decode,
                      onInputChanged: () {
                        if (_decodeResult != null || _decodeError != null) {
                          setState(() {
                            _decodeResult = null;
                            _decodeError = null;
                          });
                        }
                      },
                    ),
                  ),
                  TabItem(
                    label: 'Encode',
                    child: _EncodeTab(
                      payloadController: _encodePayloadController,
                      resultController: _encodeResultController,
                      selectedVersionByte: _selectedVersionByte,
                      versionBytes: _versionBytes,
                      encodeError: _encodeError,
                      onEncode: _encode,
                      onVersionChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedVersionByte = value);
                        }
                      },
                      onInputChanged: () {
                        if (_encodeResultController.text.isNotEmpty || _encodeError != null) {
                          setState(() {
                            _encodeResultController.clear();
                            _encodeError = null;
                          });
                        }
                      },
                      onCopy: _copyToClipboard,
                    ),
                  ),
                ],
              ),
            ),

            // Footer buttons
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: theme.colors.border),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SailButton(
                    label: 'Close',
                    variant: ButtonVariant.secondary,
                    onPressed: () async => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DecodeTab extends StatelessWidget {
  final TextEditingController controller;
  final Base58DecodeResult? decodeResult;
  final String? decodeError;
  final VoidCallback onDecode;
  final VoidCallback onInputChanged;

  const _DecodeTab({
    required this.controller,
    required this.decodeResult,
    required this.decodeError,
    required this.onDecode,
    required this.onInputChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Input section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colors.background,
              borderRadius: SailStyleValues.borderRadiusSmall,
              border: Border.all(color: theme.colors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SailSVG.fromAsset(SailSVGAsset.cornerDownRight, width: 20, color: theme.colors.primary),
                    const SizedBox(width: 8),
                    SailText.primary15('Base58 Input', bold: true),
                  ],
                ),
                const SizedBox(height: 12),
                SailText.secondary12(
                  'Enter a Base58Check encoded string (Bitcoin address or WIF private key)',
                ),
                const SizedBox(height: 16),
                SailTextField(
                  controller: controller,
                  hintText: 'e.g., 1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa',
                  monospace: true,
                  minLines: 3,
                  maxLines: 3,
                  onChanged: (_) => onInputChanged(),
                ),
                const SizedBox(height: 16),
                SailButton(
                  onPressed: () async => onDecode(),
                  label: 'Decode',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Error display
          if (decodeError != null) ...[
            SailAlert(
              variant: SailAlertVariant.destructive,
              icon: SailSVG.fromAsset(SailSVGAsset.circleAlert, width: 24, color: theme.colors.error),
              description: decodeError!,
            ),
            const SizedBox(height: 24),
          ],

          // Results display
          if (decodeResult != null) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colors.background,
                borderRadius: SailStyleValues.borderRadiusSmall,
                border: Border.all(
                  color: decodeResult!.checksumValid ? theme.colors.success : theme.colors.error,
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SailSVG.fromAsset(
                        decodeResult!.checksumValid ? SailSVGAsset.circleCheck : SailSVGAsset.circleAlert,
                        width: 24,
                        color: decodeResult!.checksumValid ? theme.colors.success : theme.colors.error,
                      ),
                      const SizedBox(width: 8),
                      SailText.primary15('Decode Results', bold: true),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ResultRow(
                    label: 'Checksum Status:',
                    value: decodeResult!.checksumValid ? 'Valid ✓' : 'Invalid ✗',
                    color: decodeResult!.checksumValid ? theme.colors.success : theme.colors.error,
                  ),
                  const SizedBox(height: 12),
                  ResultRow(label: 'Version Byte:', value: decodeResult!.versionHex),
                  const SizedBox(height: 12),
                  ResultRow(label: 'Address Type:', value: decodeResult!.addressType),
                  const SizedBox(height: 12),
                  ResultRow(
                    label: 'Payload (Hex):',
                    value: decodeResult!.payloadHex,
                    monospace: true,
                    copyable: true,
                  ),
                  const SizedBox(height: 12),
                  ResultRow(
                    label: 'Checksum (Hex):',
                    value: decodeResult!.checksumHex,
                    monospace: true,
                    copyable: true,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EncodeTab extends StatelessWidget {
  final TextEditingController payloadController;
  final TextEditingController resultController;
  final int selectedVersionByte;
  final Map<int, String> versionBytes;
  final String? encodeError;
  final VoidCallback onEncode;
  final ValueChanged<int?> onVersionChanged;
  final VoidCallback onInputChanged;
  final void Function(String text, String label) onCopy;

  const _EncodeTab({
    required this.payloadController,
    required this.resultController,
    required this.selectedVersionByte,
    required this.versionBytes,
    required this.encodeError,
    required this.onEncode,
    required this.onVersionChanged,
    required this.onInputChanged,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Input section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colors.background,
              borderRadius: SailStyleValues.borderRadiusSmall,
              border: Border.all(color: theme.colors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SailSVG.fromAsset(SailSVGAsset.slidersHorizontal, width: 20, color: theme.colors.primary),
                    const SizedBox(width: 8),
                    SailText.primary15('Encode Parameters', bold: true),
                  ],
                ),
                const SizedBox(height: 12),
                SailText.secondary12('Configure version byte and payload to encode'),
                const SizedBox(height: 16),

                // Version byte selector
                SailText.primary13('Version Byte:'),
                const SizedBox(height: 8),
                SailDropdownButton<int>(
                  value: selectedVersionByte,
                  items: [
                    for (final entry in versionBytes.entries)
                      SailDropdownItem<int>(value: entry.key, label: entry.value),
                  ],
                  onChanged: onVersionChanged,
                ),
                const SizedBox(height: 16),

                // Payload input
                SailText.primary13('Payload (Hex):'),
                const SizedBox(height: 8),
                SailTextField(
                  controller: payloadController,
                  hintText: 'e.g., 62e907b15cbf27d5425399ebf6f0fb50ebb88f18',
                  monospace: true,
                  minLines: 3,
                  maxLines: 3,
                  onChanged: (_) => onInputChanged(),
                ),
                const SizedBox(height: 16),
                SailButton(
                  onPressed: () async => onEncode(),
                  label: 'Encode',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Error display
          if (encodeError != null) ...[
            SailAlert(
              variant: SailAlertVariant.destructive,
              icon: SailSVG.fromAsset(SailSVGAsset.circleAlert, width: 24, color: theme.colors.error),
              description: encodeError!,
            ),
            const SizedBox(height: 24),
          ],

          // Result display
          if (resultController.text.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colors.background,
                borderRadius: SailStyleValues.borderRadiusSmall,
                border: Border.all(color: theme.colors.success, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SailSVG.fromAsset(SailSVGAsset.circleCheck, width: 24, color: theme.colors.success),
                      const SizedBox(width: 8),
                      SailText.primary15('Base58 Result', bold: true),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colors.backgroundSecondary,
                      borderRadius: SailStyleValues.borderRadiusSmall,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SailSelectableText(
                            resultController.text,
                            style: TextStyle(
                              fontFamily: 'IBMPlexMono',
                              fontSize: 13,
                              color: theme.colors.text,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SailTappable(
                          onTap: () async => onCopy(resultController.text, 'Base58 result'),
                          borderRadius: SailStyleValues.borderRadiusSmall,
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: SailSVG.fromAsset(SailSVGAsset.copy, color: theme.colors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
