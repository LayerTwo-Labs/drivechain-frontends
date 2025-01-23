import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:launcher/services/wallet_service.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/providers/binary_provider.dart';

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

  @override
  void initState() {
    super.initState();
    _checkMasterStarter();
    _mnemonicController.addListener(() {
      setState(() {
        _isValidInput = _isValidMnemonic(_mnemonicController.text);
      });
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

  void _handleRestore() {
    if (!_isValidMnemonic(_mnemonicController.text)) {
      _showErrorDialog('Invalid mnemonic format. Please enter 12 or 24 words.');
      return;
    }

    _walletService
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
            child: SailButton.primary(
              'Create Wallet',
              onPressed: () => setState(() => _currentScreen = WelcomeScreen.create),
              size: ButtonSize.regular,
            ),
          ),
          const SizedBox(height: SailStyleValues.padding08),
          SailTextButton(
            label: 'Restore Wallet',
            onPressed: () => setState(() => _currentScreen = WelcomeScreen.restore),
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
              child: SailButton.primary(
                'Restore',
                onPressed: _handleRestore,
                disabled: !_isValidInput,
                size: ButtonSize.regular,
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
            child: SailButton.primary(
              'Fast Wallet',
              onPressed: _handleFastMode,
              size: ButtonSize.regular,
            ),
          ),
          const SizedBox(height: SailStyleValues.padding08),
          SailTextButton(
            label: 'Advanced',
            onPressed: () => setState(() => _currentScreen = WelcomeScreen.advanced),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedScreen() {
    return Padding(
      padding: const EdgeInsets.all(SailStyleValues.padding16),
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
    String? title;
    BoxConstraints constraints;

    switch (_currentScreen) {
      case WelcomeScreen.initial:
      case WelcomeScreen.create:
        constraints = const BoxConstraints(maxWidth: 300);
        break;
      case WelcomeScreen.restore:
      case WelcomeScreen.advanced:
        constraints = const BoxConstraints(maxWidth: 400);
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
      child: SailRawCard(
        padding: false,
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SailTextButton(
                      label: '←',
                      onPressed: () {
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
                    ),
                    Expanded(
                      child: Center(
                        child: SailText.primary20(title, bold: true),
                      ),
                    ),
                    // Add invisible button to balance the layout
                    SizedBox(
                      width: 36, // Width to match the back button
                      height: 24,
                    ),
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
