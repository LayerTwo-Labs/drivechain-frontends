import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:launcher/services/wallet_service.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sail_ui/sail_ui.dart';

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
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 400),
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

  @override
  void initState() {
    super.initState();
    _checkMasterStarter();
    _mnemonicController.addListener(() {
      setState(() {});
    });
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

  void _handleFastMode() {
    _walletService.generateWallet().then((wallet) {
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

        _walletService.generateStartersForDownloadedChains().then((_) {
          if (!mounted) return;
          Navigator.of(context).pop(true);
        });
      });
    }).catchError((e) {
      if (!mounted) return;
      _showErrorDialog('Unexpected error: $e');
    });
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
            child: Container(
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
            child: Container(
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
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: SailText.primary13(
              'Advanced options coming soon...',
            ),
          ),
        ],
      ),
    );
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
