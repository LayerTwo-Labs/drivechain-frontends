import 'dart:convert' show utf8;
import 'dart:io';
import 'dart:math';

import 'package:convert/convert.dart' show hex;
import 'package:crypto/crypto.dart' show sha256;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:launcher/services/wallet_service.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sail_ui/sail_ui.dart';

// Extension method for chunking lists
extension ListExtension<T> on List<T> {
  List<List<T>> chunked(int size) {
    var chunks = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      chunks.add(sublist(i, i + size > length ? length : i + size));
    }
    return chunks;
  }
}

Future<bool?> showWelcomeModal(BuildContext context) async {
  final theme = SailTheme.of(context);

  return showThemedDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: theme.colors.backgroundSecondary,
      child: IntrinsicHeight(
        child: _WelcomeModalContent(
          keepOpen: true,
        ),
      ),
    ),
  );
}

class _WelcomeModalContent extends StatefulWidget {
  final bool keepOpen;

  const _WelcomeModalContent({
    this.keepOpen = false,
  });

  @override
  _WelcomeModalContentState createState() => _WelcomeModalContentState();
}

enum WelcomeScreen {
  initial,
  restore,
  create,
  advanced,
}

class _WelcomeModalContentState extends State<_WelcomeModalContent> {
  WelcomeScreen _currentScreen = WelcomeScreen.initial;
  final TextEditingController _mnemonicController = TextEditingController();
  final TextEditingController _passphraseController = TextEditingController();
  final WalletService _walletService = GetIt.I.get<WalletService>();
  final BinaryProvider _binaryProvider = GetIt.I.get<BinaryProvider>();
  bool _isValidInput = false;
  bool _isHexMode = false;
  Map<String, dynamic> _currentWalletData = {};

  @override
  void initState() {
    super.initState();
    _checkMasterStarter();
    _mnemonicController.addListener(_onEntropyChanged);
    _passphraseController.addListener(_onPassphraseChanged);
  }

  void _onPassphraseChanged() {
    if (_currentScreen != WelcomeScreen.advanced) return;
    if (_mnemonicController.text.isEmpty) return;

    // For hex mode, use the current entropy directly
    if (_isHexMode) {
      final entropyHex = _mnemonicController.text.trim();
      if (_isValidEntropy(entropyHex)) {
        _generateWalletFromEntropy(entropyHex);
      }
    } else {
      // For text mode, rehash the input
      final input = _mnemonicController.text.trim();
      final bytes = utf8.encode(input);
      final hash = sha256.convert(bytes);
      final entropy = hash.bytes.sublist(0, 16);
      final entropyHex = hex.encode(entropy);
      _generateWalletFromEntropy(entropyHex);
    }
  }

  void _onEntropyChanged() {
    if (_currentScreen != WelcomeScreen.advanced) return;

    final input = _mnemonicController.text.trim();

    if (input.isEmpty) {
      _clearWalletData();
      return;
    }

    if (_isHexMode) {
      final isValid = _isValidEntropy(input);
      setState(() {
        _isValidInput = isValid;
      });
      if (isValid) {
        _generateWalletFromEntropy(input);
      } else {
        _clearWalletData();
      }
    } else {
      // Hash the input text and use as entropy
      final bytes = utf8.encode(input);
      final hash = sha256.convert(bytes);
      final entropy = hash.bytes.sublist(0, 16); // Use first 16 bytes
      final entropyHex = hex.encode(entropy);
      _generateWalletFromEntropy(entropyHex);
      setState(() {
        _isValidInput = true;
      });
    }
  }

  Future<void> _checkMasterStarter() async {
    final appDir = await getApplicationSupportDirectory();
    final walletDir = Directory(path.join(appDir.path, 'wallet_starters'));
    final masterFile = File(path.join(walletDir.path, 'master_starter.json'));

    if (!widget.keepOpen && masterFile.existsSync()) {
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  void dispose() {
    _mnemonicController.removeListener(_onEntropyChanged);
    _passphraseController.removeListener(_onPassphraseChanged);
    _mnemonicController.dispose();
    _passphraseController.dispose();
    _currentWalletData.clear();
    super.dispose();
  }

  Future<void> _showErrorDialog(String message) async {
    await errorDialog(
      context: context,
      action: 'Error',
      title: 'Error',
      subtitle: message,
    );
    _mnemonicController.clear();
  }

  bool _isValidMnemonic(String mnemonic) {
    final words = mnemonic.trim().split(' ');
    return words.length == 12 || words.length == 24;
  }

  bool _isValidEntropy(String entropyHex) {
    if (entropyHex.isEmpty) return false;

    try {
      // First check if the string contains only valid hex characters
      if (!RegExp(r'^[0-9a-fA-F]+$').hasMatch(entropyHex)) {
        return false;
      }

      // Check if input is too long
      if (entropyHex.length > 64) {
        return false;
      }

      // Pad with zeros to nearest 32 chars if needed
      final paddedHex = entropyHex.padRight(((entropyHex.length + 31) ~/ 32) * 32, '0');

      // Try decoding it - no need to store the result
      hex.decode(paddedHex);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _handleFastMode() async {
    await _walletService.generateWallet().then((wallet) {
      if (!mounted) return;

      if (wallet.containsKey('error')) {
        _showErrorDialog('Failed to generate wallet: ${wallet['error']}');
        return;
      }

      _walletService.saveWallet(wallet).then((success) {
        if (!mounted) return;

        if (!success) {
          _showErrorDialog('Failed to save wallet');
          return;
        }

        // Generate starters for all downloaded chains
        _walletService.generateStartersForDownloadedChains().then((_) {
          if (!mounted) return;

          // After starters are generated, enable them in the binary provider
          for (final chain in _binaryProvider.getL2Chains()) {
            _binaryProvider.setUseStarter(chain, true);
          }

          Navigator.of(context).pop(true);
        });
      });
    }).catchError((e) {
      if (!mounted) return;
      _showErrorDialog('Unexpected error: $e');
    });
  }

  Future<void> _handleRestore() async {
    if (!_isValidMnemonic(_mnemonicController.text)) {
      await _showErrorDialog('Invalid mnemonic format. Please enter 12 or 24 words.');
      return;
    }

    await _walletService
        .generateWallet(
      customMnemonic: _mnemonicController.text,
      passphrase: _passphraseController.text.isNotEmpty ? _passphraseController.text : null,
    )
        .then((wallet) {
      if (!mounted) return;

      if (wallet.containsKey('error')) {
        _showErrorDialog('Failed to generate wallet: ${wallet['error']}');
        return;
      }

      _walletService.saveWallet(wallet).then((success) {
        if (!mounted) return;

        if (!success) {
          _showErrorDialog('Failed to save wallet');
          return;
        }

        // Generate starters for all downloaded chains
        _walletService.generateStartersForDownloadedChains().then((_) {
          if (!mounted) return;

          // After starters are generated, enable them in the binary provider
          for (final chain in _binaryProvider.getL2Chains()) {
            _binaryProvider.setUseStarter(chain, true);
          }

          Navigator.of(context).pop(true);
        });
      });
    }).catchError((e) {
      if (!mounted) return;
      _showErrorDialog('Invalid mnemonic: $e');
    });
  }

  Widget _buildInitialScreen() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SailStyleValues.padding16,
        vertical: SailStyleValues.padding08,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: SailButton(
              label: 'Create Wallet',
              onPressed: () async => setState(() => _currentScreen = WelcomeScreen.create),
              variant: ButtonVariant.primary,
            ),
          ),
          const SizedBox(height: SailStyleValues.padding08),
          SailButton(
            label: 'Restore Wallet',
            onPressed: () async => setState(() => _currentScreen = WelcomeScreen.restore),
            variant: ButtonVariant.ghost,
          ),
        ],
      ),
    );
  }

  Widget _buildRestoreScreen() {
    return Padding(
      padding: const EdgeInsets.all(SailStyleValues.padding16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SailTextField(
            controller: _mnemonicController,
            hintText: 'Enter BIP39 mnemonic (12 or 24 words)',
            maxLines: 3,
            textFieldType: TextFieldType.text,
            size: TextFieldSize.regular,
          ),
          const SizedBox(height: SailStyleValues.padding12),
          SailTextField(
            controller: _passphraseController,
            hintText: 'Optional passphrase',
            textFieldType: TextFieldType.text,
            size: TextFieldSize.regular,
          ),
          const SizedBox(height: SailStyleValues.padding16),
          Center(
            child: SizedBox(
              width: 120,
              height: 40,
              child: SailButton(
                label: 'Restore',
                onPressed: _handleRestore,
                disabled: !_isValidInput,
                variant: ButtonVariant.primary,
              ),
            ),
          ),
          const SizedBox(height: SailStyleValues.padding08),
        ],
      ),
    );
  }

  Widget _buildCreateScreen() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SailStyleValues.padding16,
        vertical: SailStyleValues.padding08,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: SailButton(
              label: 'Fast Wallet',
              onPressed: _handleFastMode,
              variant: ButtonVariant.primary,
            ),
          ),
          const SizedBox(height: SailStyleValues.padding08),
          SailButton(
            label: 'Advanced',
            onPressed: () async => setState(() => _currentScreen = WelcomeScreen.advanced),
            variant: ButtonVariant.ghost,
          ),
        ],
      ),
    );
  }

  Widget _buildMnemonicDisplay() {
    if (_currentWalletData.isEmpty || !_currentWalletData.containsKey('mnemonic')) {
      return const SizedBox.shrink();
    }

    final theme = SailTheme.of(context);
    final words = _currentWalletData['mnemonic'].split(' ');
    final binaryString = _currentWalletData['bip39_binary'] ?? '';
    final checksumBinary = _currentWalletData['bip39_checksum'] ?? '';

    // Calculate total length for verification
    final entropyBits = binaryString.length;
    final checksumBits = entropyBits ~/ 32; // BIP39 spec: checksum length = entropy length / 32
    final totalBits = entropyBits + checksumBits;
    final expectedWords = totalBits ~/ 11; // Each word represents 11 bits

    if (words.length != expectedWords) {
      return const SizedBox.shrink(); // Invalid state
    }

    final fullBinary = binaryString + checksumBinary;
    final binaryStrings = <String>[];

    // Split into 11-bit chunks as per BIP39
    for (int i = 0; i < fullBinary.length; i += 11) {
      final end = i + 11 > fullBinary.length ? fullBinary.length : i + 11;
      final chunk = fullBinary.substring(i, end).padRight(11, '0');
      binaryStrings.add(chunk);
    }

    return SailCard(
      padding: true,
      secondary: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SailText.primary10(
              'Entropy ($entropyBits bits) + Checksum ($checksumBits bits) = $totalBits bits ÷ 11 = $expectedWords words',
              color: theme.colors.textSecondary,
            ),
          ),
          for (int row = 0; row < (words.length ~/ 6); row++)
            Padding(
              padding: EdgeInsets.only(bottom: row < (words.length ~/ 6) - 1 ? 4 : 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  for (int col = 0; col < 6; col++) ...[
                    if (row * 6 + col < words.length)
                      SizedBox(
                        width: 100,
                        child: SailColumn(
                          spacing: 2,
                          children: [
                            SailText.primary10(words[row * 6 + col], bold: true),
                            if (row * 6 + col < binaryStrings.length)
                              row * 6 + col == words.length - 1
                                  ? RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: binaryStrings[row * 6 + col].substring(0, 7),
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: theme.colors.textSecondary,
                                              fontFamily: 'IBM Plex Mono',
                                            ),
                                          ),
                                          TextSpan(
                                            text: binaryStrings[row * 6 + col].substring(7),
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: theme.colors.success,
                                              fontFamily: 'IBM Plex Mono',
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : SailText.primary10(
                                      binaryStrings[row * 6 + col],
                                      color: theme.colors.textSecondary,
                                    ),
                          ],
                        ),
                      ),
                    if (col < 5 && row * 6 + col < words.length - 1) const SizedBox(width: 2),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoPanel() {
    final theme = SailTheme.of(context);
    final binaryString = _currentWalletData['bip39_binary'] ?? '';
    final checksumBinary = _currentWalletData['bip39_checksum'] ?? '';

    return SailCard(
      padding: true,
      secondary: true,
      child: SailColumn(
        spacing: SailStyleValues.padding08,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // BIP39 Binary
          SailRow(
            spacing: SailStyleValues.padding08,
            children: [
              SizedBox(
                width: 100,
                child: SailText.primary10('BIP39 Binary:', bold: true),
              ),
              Expanded(
                child: SailText.primary10(
                  binaryString,
                  color: theme.colors.textSecondary,
                ),
              ),
            ],
          ),
          // BIP39 Checksum
          SailRow(
            spacing: SailStyleValues.padding08,
            children: [
              SizedBox(
                width: 100,
                child: SailText.primary10('Checksum:', bold: true),
              ),
              SailText.primary10(
                checksumBinary,
                color: theme.colors.success,
              ),
              const SizedBox(width: SailStyleValues.padding16),
              SailText.primary10('Hex:', bold: true),
              const SizedBox(width: SailStyleValues.padding04),
              SailText.primary10(
                _currentWalletData['bip39_checksum_hex'] ?? '',
                color: theme.colors.success,
              ),
              Expanded(child: Container()),
            ],
          ),
          // Master Key
          SailRow(
            spacing: SailStyleValues.padding08,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SailText.primary10('Master Key:', bold: true),
                    SailText.primary10(
                      _currentWalletData['master_key'] ?? '',
                      color: theme.colors.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Chain Code
          SailRow(
            spacing: SailStyleValues.padding08,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SailText.primary10('Chain Code:', bold: true),
                    SailText.primary10(
                      _currentWalletData['chain_code'] ?? '',
                      color: theme.colors.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedScreen() {
    final theme = SailTheme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 900, maxHeight: 950),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(SailStyleValues.padding16),
          child: SailColumn(
            spacing: SailStyleValues.padding12,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Combined Entropy Input Section
              SailCard(
                padding: true,
                secondary: true,
                child: SailColumn(
                  spacing: SailStyleValues.padding12,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SailRow(
                      spacing: SailStyleValues.padding08,
                      children: [
                        SailText.primary13('Custom Entropy'),
                        SailCheckbox(
                          value: _isHexMode,
                          onChanged: (value) {
                            setState(() {
                              _isHexMode = value;
                              _mnemonicController.clear();
                              _clearWalletData();
                            });
                          },
                          label: 'Hex',
                        ),
                        const Spacer(),
                        if (_isHexMode)
                          SailText.secondary12(
                            _mnemonicController.text.isEmpty
                                ? 'Enter up to 64 hex characters (0-9 and A-F)'
                                : (!RegExp(r'^[0-9a-fA-F]+$').hasMatch(_mnemonicController.text)
                                    ? 'Invalid hex characters (only 0-9 and A-F allowed)'
                                    : (_mnemonicController.text.length > 64
                                        ? 'Too many characters (maximum 64)'
                                        : 'Valid hex input')),
                            color: _mnemonicController.text.isEmpty
                                ? theme.colors.textSecondary
                                : (!RegExp(r'^[0-9a-fA-F]+$').hasMatch(_mnemonicController.text) ||
                                        _mnemonicController.text.length > 64
                                    ? theme.colors.error
                                    : theme.colors.success),
                          ),
                      ],
                    ),
                    SizedBox(
                      height: 40,
                      child: SailTextField(
                        controller: _mnemonicController,
                        hintText: _isHexMode ? 'Enter hex entropy (16-32 bytes)' : 'Enter text to hash',
                        textFieldType: TextFieldType.text,
                        size: TextFieldSize.small,
                      ),
                    ),
                  ],
                ),
              ),

              // Mnemonic Display
              if (_currentWalletData.containsKey('mnemonic')) _buildMnemonicDisplay(),

              // Combined Info Panel
              if (_currentWalletData.containsKey('mnemonic')) _buildInfoPanel(),

              // Action Buttons
              SailRow(
                spacing: SailStyleValues.padding08,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentWalletData.containsKey('mnemonic'))
                    SizedBox(
                      height: 40,
                      child: SailButton(
                        label: 'Copy Mnemonic',
                        variant: ButtonVariant.secondary,
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: _currentWalletData['mnemonic']));
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Mnemonic copied to clipboard'),
                                backgroundColor: SailTheme.of(context).colors.success,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  const Spacer(),
                  SizedBox(
                    height: 40,
                    child: SailButton(
                      label: 'Random',
                      variant: ButtonVariant.secondary,
                      onPressed: () async {
                        setState(() {
                          _isHexMode = true; // Force hex mode
                        });
                        // Generate 16 bytes (128 bits) of entropy for 12 words
                        final entropy = List.generate(16, (index) => Random.secure().nextInt(256));
                        final entropyHex = hex.encode(entropy);
                        _mnemonicController.text = entropyHex;
                        _onEntropyChanged();
                      },
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: SailButton(
                      label: 'Create Wallet',
                      variant: ButtonVariant.primary,
                      disabled: !_isValidInput,
                      onPressed: () => _handleAdvancedCreate(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAdvancedHelp() async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: SailTheme.of(context).colors.backgroundSecondary,
        child: SailCard(
          padding: true,
          withCloseButton: true,
          child: SailColumn(
            spacing: SailStyleValues.padding16,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.primary13('Advanced Wallet Creation Help', bold: true),
              SailText.primary13(
                'This screen allows you to create a wallet using custom entropy or a random value.\n\n'
                '• Entropy: Must be 16-32 bytes (32-64 hex characters)\n'
                '• Passphrase: Optional additional security (BIP39)\n'
                '• BIP39: Shows technical details of seed generation\n'
                '• HD Keys: Displays hierarchical deterministic key info\n\n'
                'The generated wallet will be used for both mainchain and sidechain operations.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearWalletData() {
    setState(() {
      _currentWalletData.clear();
      _isValidInput = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_currentScreen == WelcomeScreen.advanced) {
      _mnemonicController.addListener(() {
        if (_isValidEntropy(_mnemonicController.text)) {
          _generateWalletFromEntropy(_mnemonicController.text);
        } else {
          _clearWalletData();
        }
      });
    }
  }

  Future<void> _generateWalletFromEntropy(String entropyHex) async {
    try {
      // Pad with zeros to nearest 32 chars if needed
      final paddedHex = entropyHex.trim().padRight(((entropyHex.length + 31) ~/ 32) * 32, '0');
      final entropy = hex.decode(paddedHex);

      if (entropy.isEmpty) {
        _clearWalletData();
        return;
      }

      final wallet = await _walletService.generateWalletFromEntropy(
        entropy,
        passphrase: _currentScreen == WelcomeScreen.restore ? _passphraseController.text : null,
      );

      if (wallet.containsKey('error')) {
        _clearWalletData();
        return;
      }

      setState(() {
        _currentWalletData = Map<String, dynamic>.from(wallet);
        _isValidInput = true;
      });
    } catch (e) {
      _clearWalletData();
    }
  }

  Future<void> _handleAdvancedCreate() async {
    if (!_isValidInput) return;

    try {
      final entropyHex = _mnemonicController.text.trim();
      List<int> entropy;

      if (_isHexMode) {
        entropy = hex.decode(entropyHex);
        if (entropy.length < 16 || entropy.length > 32 || entropy.length % 4 != 0) {
          await _showErrorDialog('Invalid entropy length. Must be 16-32 bytes and a multiple of 4.');
          return;
        }
      } else {
        final bytes = utf8.encode(entropyHex);
        final hash = sha256.convert(bytes);
        entropy = hash.bytes.sublist(0, 16);
      }

      final wallet = await _walletService.generateWalletFromEntropy(
        entropy,
        passphrase: null, // No passphrase in advanced mode
      );

      if (wallet.containsKey('error')) {
        await _showErrorDialog('Failed to generate wallet: ${wallet['error']}');
        return;
      }

      final success = await _walletService.saveWallet(wallet);
      if (!success) {
        await _showErrorDialog('Failed to save wallet');
        return;
      }

      await _walletService.generateStartersForDownloadedChains();

      for (final chain in _binaryProvider.getL2Chains()) {
        _binaryProvider.setUseStarter(chain, true);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      await _showErrorDialog('Error creating wallet: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    String? title;
    BoxConstraints constraints;

    switch (_currentScreen) {
      case WelcomeScreen.initial:
      case WelcomeScreen.create:
        constraints = const BoxConstraints(maxWidth: 300);
        break;
      case WelcomeScreen.restore:
        constraints = const BoxConstraints(maxWidth: 400);
        break;
      case WelcomeScreen.advanced:
        constraints = const BoxConstraints(maxWidth: 900, maxHeight: 950);
        break;
    }

    switch (_currentScreen) {
      case WelcomeScreen.initial:
        content = _buildInitialScreen();
        title = 'Welcome to Drivechain';
        break;
      case WelcomeScreen.restore:
        content = _buildRestoreScreen();
        title = 'Restore Wallet';
        break;
      case WelcomeScreen.create:
        content = _buildCreateScreen();
        title = 'Create Wallet';
        break;
      case WelcomeScreen.advanced:
        content = _buildAdvancedScreen();
        title = 'Advanced Options';
        break;
    }

    return ConstrainedBox(
      constraints: constraints,
      child: SailCard(
        padding: true,
        child: IntrinsicHeight(
          child: SailColumn(
            spacing: SailStyleValues.padding04,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_currentScreen == WelcomeScreen.initial)
                Padding(
                  padding: const EdgeInsets.only(top: SailStyleValues.padding08),
                  child: Center(
                    child: SailText.primary20(title, bold: true),
                  ),
                )
              else
                SailRow(
                  spacing: SailStyleValues.padding08,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SailButton(
                      label: '←',
                      onPressed: () async {
                        if (_currentScreen == WelcomeScreen.advanced) {
                          setState(() => _currentScreen = WelcomeScreen.create);
                        } else {
                          setState(() {
                            _currentScreen = WelcomeScreen.initial;
                            _mnemonicController.clear();
                            _passphraseController.clear();
                          });
                        }
                      },
                      variant: ButtonVariant.ghost,
                    ),
                    Expanded(
                      child: Center(
                        child: SailText.primary20(title, bold: true),
                      ),
                    ),
                    if (_currentScreen == WelcomeScreen.advanced)
                      SailButton(
                        label: '?',
                        onPressed: _showAdvancedHelp,
                        variant: ButtonVariant.ghost,
                      )
                    else
                      const SizedBox(width: 36, height: 24),
                  ],
                ),
              content,
            ],
          ),
        ),
      ),
    );
  }
}
