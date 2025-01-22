import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:launcher/services/wallet_service.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';

class CenteredDialogHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;

  const CenteredDialogHeader({
    super.key,
    required this.title,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (onBack != null)
          Positioned(
            left: 16,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onBack,
                child: SailText.primary20(
                  '←',
                  color: SailTheme.of(context).colors.text,
                ),
              ),
            ),
          ),
        Center(
          child: SailText.primary20(title, bold: true),
        ),
      ],
    );
  }
}

Future<bool?> showWelcomeModal(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      backgroundColor: SailTheme.of(context).colors.backgroundSecondary,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 400),
        child: const _WelcomeModalContent(
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
  late final TextEditingController _entropyController;
  Map<String, dynamic> _currentWalletData = {};
  List<String> _mnemonicWords = [];
  List<String> _binaryWords = [];
  bool _isHexMode = false;

  @override
  void initState() {
    super.initState();
    _checkMasterStarter();
    _mnemonicController.addListener(() {
      setState(() {});
    });
    _entropyController = TextEditingController();
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
    _mnemonicController.dispose();
    _passphraseController.dispose();
    _entropyController.dispose();
    super.dispose();
  }

  Future<void> _showErrorDialog(String message) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: SailTheme.of(context).colors.backgroundSecondary,
        child: SailRawCard(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SailText.primary15(
                  message,
                  color: SailTheme.of(context).colors.textSecondary,
                ),
                const SizedBox(height: 24),
                SailButton.primary(
                  'Return',
                  onPressed: () {
                    _mnemonicController.clear();
                    Navigator.of(context).pop();
                  },
                  size: ButtonSize.regular,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isValidMnemonic(String mnemonic) {
    final words = mnemonic.trim().split(' ');
    return words.length == 12 || words.length == 24;
  }

  Future<void> _handleFastMode() async {
    try {
      final wallet = await _walletService.generateWallet();
      if (!mounted) return;

      if (wallet.containsKey('error')) {
        await _showErrorDialog('Failed to generate wallet: ${wallet['error']}');
        return;
      }

      final success = await _walletService.saveWallet(wallet);
      if (!mounted) return;

      if (!success) {
        await _showErrorDialog('Failed to save wallet');
        return;
      }

      // Generate starters for downloaded chains
      await _walletService.generateStartersForDownloadedChains();

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      await _showErrorDialog('Unexpected error: $e');
    }
  }

  void _handleRestore() {
    if (!_isValidMnemonic(_mnemonicController.text)) {
      _showErrorDialog('Invalid mnemonic format. Please enter 12 or 24 words.');
      return;
    }

    _walletService.generateWallet(
      customMnemonic: _mnemonicController.text,
      passphrase: _passphraseController.text.isNotEmpty ? _passphraseController.text : null,
    ).then((wallet) {
      if (!mounted) return;

      if (wallet.containsKey('error')) {
        _showErrorDialog('Failed to generate wallet: ${wallet['error']}').then((_) {
          // Clear the input after showing the error
          _mnemonicController.clear();
        });
        return;
      }

      _walletService.saveWallet(wallet).then((success) {
        if (!mounted) return;

        if (!success) {
          _showErrorDialog('Failed to save wallet').then((_) {
            // Clear the input after showing the error
            _mnemonicController.clear();
          });
          return;
        }

        _walletService.generateStartersForDownloadedChains().then((_) {
          if (!mounted) return;
          Navigator.of(context).pop(true);
        }).catchError((e) {
          if (!mounted) return;
          _showErrorDialog('Failed to generate starters: $e').then((_) {
            // Clear the input after showing the error
            _mnemonicController.clear();
          });
        });
      }).catchError((e) {
        if (!mounted) return;
        _showErrorDialog('Failed to save wallet: $e').then((_) {
          // Clear the input after showing the error
          _mnemonicController.clear();
        });
      });
    }).catchError((e) {
      if (!mounted) return;
      _showErrorDialog('Invalid mnemonic: $e').then((_) {
        // Clear the input after showing the error
        _mnemonicController.clear();
      });
    });
  }

  Widget _buildInitialScreen() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 160,
            child: SailButton.primary(
              'Create Wallet',
              onPressed: () => setState(() => _currentScreen = WelcomeScreen.create),
              size: ButtonSize.regular,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => setState(() => _currentScreen = WelcomeScreen.restore),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: SailText.secondary13(
                      'Restore Wallet',
                      color: SailTheme.of(context).colors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildRestoreScreen() {
    final isValidMnemonic = _isValidMnemonic(_mnemonicController.text);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SailTextField(
            controller: _mnemonicController,
            hintText: 'Enter BIP39 mnemonic (12 or 24 words)',
          ),
          const SizedBox(height: 16),
          SailTextField(
            controller: _passphraseController,
            hintText: 'Optional passphrase',
          ),
          const SizedBox(height: 24),
          Center(
            child: SizedBox(
              width: 160,
              height: 48,
              child: SailButton.primary(
                'Restore',
                onPressed: () => isValidMnemonic ? _handleRestore() : null,
                size: ButtonSize.regular,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateScreen() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 160,
            child: SailButton.primary(
              'Fast Wallet',
              onPressed: _handleFastMode,
              size: ButtonSize.regular,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => setState(() => _currentScreen = WelcomeScreen.advanced),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: SailText.secondary13(
                      'Advanced',
                      color: SailTheme.of(context).colors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAdvancedScreen() {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Input field for entropy/hex
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 24,
                          child: TextField(
                            controller: _entropyController,
                            style: const TextStyle(fontSize: 10, color: Colors.white),
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                              hintText: 'Enter any text or hex',
                              hintStyle: TextStyle(fontSize: 10, color: Colors.white70),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(2)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(2)),
                                borderSide: BorderSide(color: Colors.white24),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(2)),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                            onChanged: _handleEntropyInput,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          SizedBox(
                            height: 16,
                            width: 16,
                            child: Checkbox(
                              value: _isHexMode,
                              onChanged: (value) {
                                setState(() {
                                  _isHexMode = value ?? false;
                                  if (_entropyController.text.isNotEmpty) {
                                    _handleEntropyInput(_entropyController.text);
                                  }
                                });
                              },
                              side: const BorderSide(color: Colors.white70),
                              fillColor: WidgetStateProperty.resolveWith<Color>(
                                (Set<WidgetState> states) {
                                  if (states.contains(WidgetState.selected)) {
                                    return Colors.white24;
                                  }
                                  return Colors.transparent;
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'hex',
                            style: TextStyle(fontSize: 9, color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // BIP39 Info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'BIP39 Information',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      _buildCompactInfoRow('BIP39 Hex:', _currentWalletData['bip39_hex'] ?? ''),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 80,
                            child: Text(
                              'BIP39 Bin:',
                              style: const TextStyle(fontSize: 8, color: Colors.white70),
                            ),
                          ),
                          Expanded(
                            child: SelectableText.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: _currentWalletData['bip39_bin'] ?? '',
                                    style: const TextStyle(
                                      fontFamily: 'RobotoMono',
                                      fontSize: 8,
                                      color: Colors.white,
                                    ),
                                  ),
                                  TextSpan(
                                    text: _currentWalletData['bip39_csum'] ?? '',
                                    style: const TextStyle(
                                      fontFamily: 'RobotoMono',
                                      fontSize: 8,
                                      color: Color(0xFF4CAF50),
                                    ),
                                  ),
                                  if (_currentWalletData['bip39_csum'] != null)
                                    TextSpan(
                                      text: '  Checksum hex: ',
                                      style: const TextStyle(
                                        fontFamily: 'RobotoMono',
                                        fontSize: 8,
                                        color: Colors.white,
                                      ),
                                    ),
                                  if (_currentWalletData['bip39_csum'] != null)
                                    TextSpan(
                                      text: _currentWalletData['bip39_csum_hex'] ?? '',
                                      style: const TextStyle(
                                        fontFamily: 'RobotoMono',
                                        fontSize: 8,
                                        color: Color(0xFF4CAF50),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // HD Key Info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'HD Key Information',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      _buildCompactInfoRow('HD Key Data:', _currentWalletData['xprv'] ?? ''),
                      _buildCompactInfoRow('Master Key:', _currentWalletData['seed_hex'] ?? ''),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Mnemonic Words
                  const Text(
                    'Mnemonic',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  // Mnemonic grid - 3x4 layout
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(3, (rowIndex) {
                      return Row(
                        children: List.generate(4, (colIndex) {
                          final index = rowIndex * 4 + colIndex;
                          final word = _mnemonicWords.length > index ? _mnemonicWords[index] : '';
                          final binary = _binaryWords.length > index ? _binaryWords[index] : '';
                          
                          // For the last word, append the checksum
                          final isLastWord = index == 11;
                          final checksum = isLastWord ? _currentWalletData['bip39_csum'] ?? '' : '';
                          
                          return SizedBox(
                            width: 140,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    word,
                                    style: const TextStyle(fontSize: 9, color: Colors.white),
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        binary,
                                        style: const TextStyle(
                                          fontSize: 8,
                                          color: Colors.white70,
                                          fontFamily: 'RobotoMono',
                                        ),
                                      ),
                                      if (isLastWord && checksum.isNotEmpty)
                                        Text(
                                          checksum,
                                          style: const TextStyle(
                                            fontSize: 8,
                                            color: Color(0xFF4CAF50),
                                            fontFamily: 'RobotoMono',
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 20,
                child: TextButton(
                  onPressed: _handleFastMode,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Random', style: TextStyle(fontSize: 9)),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                height: 20,
                child: Tooltip(
                  message: 'Input must be exactly 32 characters long',
                  textStyle: const TextStyle(fontSize: 10, color: Colors.black),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ElevatedButton(
                    onPressed: _entropyController.text.length == 32 ? _handleCreateWallet : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      backgroundColor: _entropyController.text.length == 32 ? const Color(0xFFFF9500) : Colors.white12,
                      foregroundColor: _entropyController.text.length == 32 ? Colors.black : Colors.white38,
                      disabledBackgroundColor: Colors.white12,
                      disabledForegroundColor: Colors.white38,
                    ),
                    child: const Text('Create Wallet', style: TextStyle(fontSize: 9)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildCompactInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontSize: 8, color: Colors.white70),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 8,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleEntropyInput(String input) {
    if (input.isEmpty) {
      setState(() {
        _currentWalletData = {};
        _mnemonicWords = [];
        _binaryWords = [];
      });
      return;
    }

    if (_isHexMode) {
      // In hex mode, only process if valid hex
      if (!RegExp(r'^[0-9A-Fa-f]*$').hasMatch(input)) {
        setState(() {
          _currentWalletData = {};
          _mnemonicWords = [];
          _binaryWords = [];
        });
        return;
      }
      
      try {
        var paddedInput = input.padRight((input.length + 1) ~/ 2 * 2, '0');
        var bytes = hex.decode(paddedInput);
        
        // Ensure entropy length is valid (128, 160, 192, 224, or 256 bits)
        if (bytes.length < 16) {
          bytes = [...bytes, ...List<int>.filled(16 - bytes.length, 0)];
        } else if (bytes.length > 16 && bytes.length < 20) {
          bytes = bytes.sublist(0, 16);
        } else if (bytes.length > 20 && bytes.length < 24) {
          bytes = bytes.sublist(0, 20);
        } else if (bytes.length > 24 && bytes.length < 28) {
          bytes = bytes.sublist(0, 24);
        } else if (bytes.length > 28 && bytes.length < 32) {
          bytes = bytes.sublist(0, 28);
        } else if (bytes.length > 32) {
          bytes = bytes.sublist(0, 32);
        }
        
        _walletService.generateWalletFromEntropy(bytes)
          .then((data) {
            if (data.containsKey('error')) {
              _handleWalletData({});
            } else {
              data['bip39_hex'] = hex.encode(bytes);
              _handleWalletData(data);
            }
          });
      } catch (e) {
        _handleWalletData({});
      }
    } else {
      // For plain text input, always hash it
      final bytes = sha256.convert(utf8.encode(input)).bytes.sublist(0, 16);
      _walletService.generateWalletFromEntropy(bytes)
        .then((data) {
          if (!data.containsKey('error')) {
            data['bip39_hex'] = hex.encode(bytes);
          }
          _handleWalletData(data);
        });
    }
  }

  void _handleWalletData(Map<String, dynamic> walletData) {
    if (!mounted) return;
    
    if (walletData.containsKey('error')) {
      setState(() {
        _currentWalletData = {};
        _mnemonicWords = [];
        _binaryWords = [];
      });
      return;
    }

    setState(() {
      _currentWalletData = walletData;
      _mnemonicWords = walletData['mnemonic'].split(' ');
      
      // Split binary into 11-bit chunks
      final binaryStr = walletData['bip39_bin'];
      _binaryWords = [];
      for (var i = 0; i < binaryStr.length; i += 11) {
        final end = (i + 11) < binaryStr.length ? (i + 11) : binaryStr.length;
        _binaryWords.add(binaryStr.substring(i, end));
      }
    });
  }

  void _handleCreateWallet() {
    if (_entropyController.text.length != 32) return;
    
    _walletService.saveWallet(_currentWalletData).then((success) {
      if (success) {
        _walletService.generateStartersForDownloadedChains().then((_) {
          if (mounted) {
            Navigator.of(context).pop(true);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    String title = 'Welcome to Drivechain';
    VoidCallback? onBack;

    switch (_currentScreen) {
      case WelcomeScreen.initial:
        content = _buildInitialScreen();
        break;
      case WelcomeScreen.restore:
        content = _buildRestoreScreen();
        title = 'Restore Wallet';
        onBack = () => setState(() {
          _currentScreen = WelcomeScreen.initial;
          _mnemonicController.clear();
          _passphraseController.clear();
        });
        break;
      case WelcomeScreen.create:
        content = _buildCreateScreen();
        title = 'Create Wallet';
        onBack = () => setState(() => _currentScreen = WelcomeScreen.initial);
        break;
      case WelcomeScreen.advanced:
        content = _buildAdvancedScreen();
        title = 'Advanced Options';
        onBack = () => setState(() => _currentScreen = WelcomeScreen.create);
        break;
    }

    return SailRawCard(
      header: CenteredDialogHeader(
        title: title,
        onBack: onBack,
      ),
      child: content,
    );
  }
}
