import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:launcher/services/wallet_service.dart';
import 'package:get_it/get_it.dart';

Future<bool?> showWelcomeModal(BuildContext context) async {
  return await widgetDialog<bool>(
    context: context,
    title: 'Welcome to Drivechain',
    child: const _WelcomeModalContent(),
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
  final TextEditingController _mnemonicController = TextEditingController();
  final TextEditingController _passphraseController = TextEditingController();
  final WalletService _walletService = GetIt.I.get<WalletService>();

  @override
  void dispose() {
    _mnemonicController.dispose();
    _passphraseController.dispose();
    super.dispose();
  }

  Future<void> _showErrorDialog(String message) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleFastMode() async {
    try {
      final wallet = await _walletService.generateWallet();
      if (!mounted) return;
      
      if (wallet.containsKey('error')) {
        await _showErrorDialog('Failed to generate wallet: ${wallet['error']}');
        return;
      }
      
      final success = await _walletService.saveWallet(wallet);
      if (!mounted) return;
      
      if (success) {
        Navigator.of(context).pop(true);
      } else {
        await _showErrorDialog('Failed to save wallet');
      }
    } catch (e) {
      if (!mounted) return;
      await _showErrorDialog('Unexpected error: $e');
    }
  }

  void _handleAdvancedMode() {
    setState(() {
      _showAdvanced = true;
    });
  }

  Future<void> _handleCreateWallet() async {
    try {
      String input = _useMnemonic ? _mnemonicController.text : _passphraseController.text;
      
      if (input.isEmpty) {
        await _showErrorDialog(_useMnemonic 
          ? 'Please enter a valid mnemonic phrase' 
          : 'Please enter a passphrase',
        );
        return;
      }

      if (_useMnemonic && !_isValidMnemonic(input)) {
        await _showErrorDialog(
          'Invalid mnemonic phrase. Please enter 12 or 24 words separated by spaces.',
        );
        return;
      }

      final wallet = await _walletService.generateWallet(
        customMnemonic: _useMnemonic ? input : null,
        passphrase: _useMnemonic ? null : input,
      );
      if (!mounted) return;

      if (wallet.containsKey('error')) {
        await _showErrorDialog('Failed to generate wallet: ${wallet['error']}');
        return;
      }

      final success = await _walletService.saveWallet(wallet);
      if (!mounted) return;
      
      if (success) {
        Navigator.of(context).pop(true);
      } else {
        await _showErrorDialog('Failed to save wallet');
      }
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
      final wallet = await _walletService.generateWallet();
      if (wallet.containsKey('error')) {
        await _showErrorDialog('Failed to generate wallet: ${wallet['error']}');
        return;
      }
      _mnemonicController.text = wallet['mnemonic'];
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
          'Get started by creating a wallet!',
          color: SailTheme.of(context).colors.textSecondary,
        ),
        if (_showAdvanced) ...[
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
              SailText.primary13('Mnemonic'),
            ],
          ),
          const SizedBox(height: 8),
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
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SailButton.secondary(
                'Generate Random',
                onPressed: _handleGenerateRandom,
                size: ButtonSize.regular,
              ),
              const SizedBox(width: 8),
              SailButton.primary(
                'Create Wallet',
                onPressed: _handleCreateWallet,
                size: ButtonSize.regular,
              ),
            ],
          ),
        ] else ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SailButton.secondary(
                'Fast Mode',
                onPressed: _handleFastMode,
                size: ButtonSize.regular,
              ),
              const SizedBox(width: 8),
              SailButton.primary(
                'Advanced Mode',
                onPressed: _handleAdvancedMode,
                size: ButtonSize.regular,
              ),
            ],
          ),
        ],
      ],
    );
  }
}
