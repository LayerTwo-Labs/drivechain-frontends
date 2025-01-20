import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:launcher/services/wallet_service.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<bool?> showWelcomeModal(BuildContext context) async {
  return await showThemedDialog<bool>(
    context: context,
    builder: (context) => PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: SailTheme.of(context).colors.backgroundSecondary,
        child: SailRawCard(
          header: DialogHeader(
            title: 'Welcome to Drivechain',
            onClose: () {}, // Disable close button
          ),
          child: const _WelcomeModalContent(),
        ),
      ),
    ),
  );
}

class WelcomeModal extends StatelessWidget {
  const WelcomeModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(); // Placeholder since we use showWelcomeModal
  }
}

class _WelcomeModalContent extends StatefulWidget {
  const _WelcomeModalContent();

  @override
  _WelcomeModalContentState createState() => _WelcomeModalContentState();
}

class _WelcomeModalContentState extends State<_WelcomeModalContent> {
  bool _showAdvanced = false;
  bool _useMnemonic = true;
  bool _generateStarters = true;
  final TextEditingController _mnemonicController = TextEditingController();
  final TextEditingController _passphraseController = TextEditingController();
  final WalletService _walletService = GetIt.I.get<WalletService>();

  @override
  void initState() {
    super.initState();
    // Check if we can close the modal
    _checkMasterStarter();
  }

  Future<void> _checkMasterStarter() async {
    final appDir = await getApplicationSupportDirectory();
    final walletDir = Directory(path.join(appDir.path, 'wallet_starters'));
    final masterFile = File(path.join(walletDir.path, 'master_starter.json'));

    if (masterFile.existsSync()) {
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

      // Generate starters if enabled
      if (_generateStarters) {
        await _walletService.generateStartersForDownloadedChains();
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      await _showErrorDialog('Unexpected error: $e');
    }
  }

  Future<void> _handleCreateWallet() async {
    try {
      if (_useMnemonic && _mnemonicController.text.isNotEmpty && !_isValidMnemonic(_mnemonicController.text)) {
        await _showErrorDialog('Invalid mnemonic format. Please enter 12 or 24 words.');
        return;
      }

      final wallet = await _walletService.generateWallet(
        customMnemonic: _mnemonicController.text.isNotEmpty ? _mnemonicController.text : null,
        passphrase: _passphraseController.text.isNotEmpty ? _passphraseController.text : null,
      );

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

      // Generate starters if enabled
      if (_generateStarters) {
        await _walletService.generateStartersForDownloadedChains();
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      await _showErrorDialog('Unexpected error: $e');
    }
  }

  bool _isValidMnemonic(String mnemonic) {
    final words = mnemonic.trim().split(' ');
    return words.length == 12 || words.length == 24;
  }

  Future<void> _handleGenerateRandom() async {
    try {
      if (_useMnemonic) {
        final wallet = await _walletService.generateWallet();
        if (wallet.containsKey('error')) {
          await _showErrorDialog('Failed to generate wallet: ${wallet['error']}');
          return;
        }
        _mnemonicController.text = wallet['mnemonic'];
      } else {
        // Generate 32 random bytes (64 hex characters)
        final wallet = await _walletService.generateWallet();
        if (wallet.containsKey('error')) {
          await _showErrorDialog('Failed to generate wallet: ${wallet['error']}');
          return;
        }
        _mnemonicController.text = wallet['seed_hex'];
      }
    } catch (e) {
      await _showErrorDialog('Unexpected error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SailColumn(
      spacing: SailStyleValues.padding12,
      mainAxisSize: MainAxisSize.min,
      children: [
        SailText.primary13(
          'Welcome to Drivechain Launcher! This application helps you manage and interact with your Drivechain sidechains.',
          color: SailTheme.of(context).colors.textSecondary,
        ),
        const SizedBox(height: 8),
        SailText.primary13(
          'Create a wallet starter - this generates a master key that will be used to derive unique keys for each sidechain, allowing you to securely manage multiple chains from a single source.',
          color: SailTheme.of(context).colors.textSecondary,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Checkbox(
              value: _useMnemonic,
              onChanged: (value) {
                setState(() {
                  _useMnemonic = value ?? false;
                  _mnemonicController.clear();
                  _passphraseController.clear();
                });
              },
            ),
            const SizedBox(width: 8),
            SailText.primary13('Use BIP39 Mnemonic'),
            const SizedBox(width: 24),
            Checkbox(
              value: _generateStarters,
              onChanged: (value) {
                setState(() {
                  _generateStarters = value ?? true;
                });
              },
            ),
            const SizedBox(width: 8),
            SailText.primary13('Generate starters for downloaded chains'),
            const Spacer(),
          ],
        ),
        if (_showAdvanced) ...[
          const SizedBox(height: 16),
          if (_useMnemonic) ...[
            SailTextField(
              controller: _mnemonicController,
              hintText: 'Enter BIP39 mnemonic (12 words) or generate random',
            ),
            const SizedBox(height: 16),
            SailText.primary13('Optional BIP39 Passphrase:'),
            const SizedBox(height: 8),
            SailTextField(
              controller: _passphraseController,
              hintText: 'Enter optional passphrase (leave empty for none)',
            ),
          ] else ...[
            SailTextField(
              controller: _mnemonicController,
              hintText: 'Enter 64 hex characters or generate random',
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SailButton.secondary(
                _showAdvanced ? 'Simple Mode' : 'Advanced Mode',
                onPressed: () {
                  setState(() {
                    _showAdvanced = !_showAdvanced;
                  });
                },
                size: ButtonSize.regular,
              ),
              Row(
                children: [
                  SailButton.secondary(
                    'Generate Random',
                    onPressed: _handleGenerateRandom,
                    size: ButtonSize.regular,
                  ),
                  const SizedBox(width: 8),
                  SailButton.primary(
                    'Create Wallet',
                    onPressed: _showAdvanced ? () => _handleCreateWallet() : () {},
                    size: ButtonSize.regular,
                  ),
                ],
              ),
            ],
          ),
        ] else ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SailButton.secondary(
                'Advanced Mode',
                onPressed: () {
                  setState(() {
                    _showAdvanced = true;
                  });
                },
                size: ButtonSize.regular,
              ),
              SailButton.primary(
                'Create Wallet',
                onPressed: _handleFastMode,
                size: ButtonSize.regular,
              ),
            ],
          ),
        ],
      ],
    );
  }
}
