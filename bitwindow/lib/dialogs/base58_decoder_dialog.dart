import 'package:bitwindow/utils/base58.dart';
import 'package:flutter/material.dart';
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

class _Base58DecoderDialogState extends State<Base58DecoderDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
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
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    // Qt dialog structure: Header → Content → Footer
    return Dialog(
      backgroundColor: theme.colors.backgroundSecondary,
      shape: RoundedRectangleBorder(
        borderRadius: SailStyleValues.borderRadiusSmall,
        side: BorderSide(color: theme.colors.border, width: 1),
      ),
      child: Container(
        width: 800,
        constraints: const BoxConstraints(maxHeight: 700),
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
                  IconButton(
                    icon: Icon(Icons.close, color: theme.colors.text),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Tab bar
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: theme.colors.border),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: theme.colors.primary,
                unselectedLabelColor: theme.colors.textTertiary,
                indicatorColor: theme.colors.primary,
                tabs: const [
                  Tab(text: 'Decode'),
                  Tab(text: 'Encode'),
                ],
              ),
            ),

            // Content - Qt QVBoxLayout with tabs
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDecodeTab(theme),
                  _buildEncodeTab(theme),
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

  Widget _buildDecodeTab(SailThemeData theme) {
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
                    Icon(Icons.input, color: theme.colors.primary, size: 20),
                    const SizedBox(width: 8),
                    SailText.primary15('Base58 Input', bold: true),
                  ],
                ),
                const SizedBox(height: 12),
                SailText.secondary12(
                  'Enter a Base58Check encoded string (Bitcoin address or WIF private key)',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _decodeInputController,
                  style: TextStyle(
                    fontFamily: 'IBMPlexMono',
                    fontSize: 13,
                    color: theme.colors.text,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g., 1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa',
                    hintStyle: TextStyle(color: theme.colors.textTertiary),
                    filled: true,
                    fillColor: theme.colors.backgroundSecondary,
                    border: OutlineInputBorder(
                      borderRadius: SailStyleValues.borderRadiusSmall,
                      borderSide: BorderSide(color: theme.colors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: SailStyleValues.borderRadiusSmall,
                      borderSide: BorderSide(color: theme.colors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: SailStyleValues.borderRadiusSmall,
                      borderSide: BorderSide(color: theme.colors.primary, width: 2),
                    ),
                  ),
                  maxLines: 3,
                  onChanged: (value) {
                    // Clear results when input changes
                    if (_decodeResult != null || _decodeError != null) {
                      setState(() {
                        _decodeResult = null;
                        _decodeError = null;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                SailButton(
                  onPressed: () async => _decode(),
                  label: 'Decode',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Error display
          if (_decodeError != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colors.error.withValues(alpha: 0.1),
                borderRadius: SailStyleValues.borderRadiusSmall,
                border: Border.all(color: theme.colors.error),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: theme.colors.error, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SailText.secondary13(_decodeError!, color: theme.colors.error),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Results display
          if (_decodeResult != null) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colors.background,
                borderRadius: SailStyleValues.borderRadiusSmall,
                border: Border.all(
                  color: _decodeResult!.checksumValid ? theme.colors.success : theme.colors.error,
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _decodeResult!.checksumValid ? Icons.check_circle : Icons.error,
                        color: _decodeResult!.checksumValid ? theme.colors.success : theme.colors.error,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      SailText.primary15('Decode Results', bold: true),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildResultRow(
                    theme,
                    'Checksum Status:',
                    _decodeResult!.checksumValid ? 'Valid ✓' : 'Invalid ✗',
                    color: _decodeResult!.checksumValid ? theme.colors.success : theme.colors.error,
                  ),
                  const SizedBox(height: 12),
                  _buildResultRow(theme, 'Version Byte:', _decodeResult!.versionHex),
                  const SizedBox(height: 12),
                  _buildResultRow(theme, 'Address Type:', _decodeResult!.addressType),
                  const SizedBox(height: 12),
                  _buildResultRow(
                    theme,
                    'Payload (Hex):',
                    _decodeResult!.payloadHex,
                    monospace: true,
                    copyable: true,
                  ),
                  const SizedBox(height: 12),
                  _buildResultRow(
                    theme,
                    'Checksum (Hex):',
                    _decodeResult!.checksumHex,
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

  Widget _buildEncodeTab(SailThemeData theme) {
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
                    Icon(Icons.settings_input_component, color: theme.colors.primary, size: 20),
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
                DropdownButtonFormField<int>(
                  initialValue: _selectedVersionByte,
                  dropdownColor: theme.colors.backgroundSecondary,
                  style: TextStyle(
                    color: theme.colors.text,
                    fontSize: 13,
                    fontFamily: 'IBMPlexMono',
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: theme.colors.backgroundSecondary,
                    border: OutlineInputBorder(
                      borderRadius: SailStyleValues.borderRadiusSmall,
                      borderSide: BorderSide(color: theme.colors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: SailStyleValues.borderRadiusSmall,
                      borderSide: BorderSide(color: theme.colors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: SailStyleValues.borderRadiusSmall,
                      borderSide: BorderSide(color: theme.colors.primary, width: 2),
                    ),
                  ),
                  items: _versionBytes.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedVersionByte = value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Payload input
                SailText.primary13('Payload (Hex):'),
                const SizedBox(height: 8),
                TextField(
                  controller: _encodePayloadController,
                  style: TextStyle(
                    fontFamily: 'IBMPlexMono',
                    fontSize: 13,
                    color: theme.colors.text,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g., 62e907b15cbf27d5425399ebf6f0fb50ebb88f18',
                    hintStyle: TextStyle(color: theme.colors.textTertiary),
                    filled: true,
                    fillColor: theme.colors.backgroundSecondary,
                    border: OutlineInputBorder(
                      borderRadius: SailStyleValues.borderRadiusSmall,
                      borderSide: BorderSide(color: theme.colors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: SailStyleValues.borderRadiusSmall,
                      borderSide: BorderSide(color: theme.colors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: SailStyleValues.borderRadiusSmall,
                      borderSide: BorderSide(color: theme.colors.primary, width: 2),
                    ),
                  ),
                  maxLines: 3,
                  onChanged: (value) {
                    // Clear results when input changes
                    if (_encodeResultController.text.isNotEmpty || _encodeError != null) {
                      setState(() {
                        _encodeResultController.clear();
                        _encodeError = null;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                SailButton(
                  onPressed: () async => _encode(),
                  label: 'Encode',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Error display
          if (_encodeError != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colors.error.withValues(alpha: 0.1),
                borderRadius: SailStyleValues.borderRadiusSmall,
                border: Border.all(color: theme.colors.error),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: theme.colors.error, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SailText.secondary13(_encodeError!, color: theme.colors.error),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Result display
          if (_encodeResultController.text.isNotEmpty) ...[
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
                      Icon(Icons.check_circle, color: theme.colors.success, size: 24),
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
                          child: SelectableText(
                            _encodeResultController.text,
                            style: TextStyle(
                              fontFamily: 'IBMPlexMono',
                              fontSize: 13,
                              color: theme.colors.text,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: Icon(Icons.copy, color: theme.colors.primary),
                          onPressed: () => _copyToClipboard(_encodeResultController.text, 'Base58 result'),
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

  Widget _buildResultRow(
    SailThemeData theme,
    String label,
    String value, {
    bool monospace = false,
    bool copyable = false,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colors.backgroundSecondary,
        borderRadius: SailStyleValues.borderRadiusSmall,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: SailText.secondary13(label, color: theme.colors.textSecondary),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    value,
                    style: TextStyle(
                      fontFamily: monospace ? 'IBMPlexMono' : 'Inter',
                      fontSize: 13,
                      color: color ?? theme.colors.text,
                    ),
                  ),
                ),
                if (copyable) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.copy, size: 18, color: theme.colors.primary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _copyToClipboard(value, label.replaceAll(':', '')),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
