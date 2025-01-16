import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hex/hex.dart';
import 'package:launcher/services/wallet_service.dart';
import 'package:sail_ui/sail_ui.dart';

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
  late final WalletService _walletService;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _walletService = GetIt.I.get<WalletService>();
  }

  @override
  void dispose() {
    _mnemonicController.dispose();
    _passphraseController.dispose();
    super.dispose();
  }

  String _generateRandomHex() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return HEX.encode(bytes);
  }

  void _handleFastMode() async {
    try {
      // In fast mode, we generate a random mnemonic and create the wallet
      final mnemonic = _walletService.generateMnemonic();
      final success = await _walletService.createFromMnemonic(mnemonic);
      
      if (success) {
        if (mounted) Navigator.of(context).pop(true);
      } else {
        setState(() {
          _errorMessage = 'Failed to create wallet';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to create wallet: $e';
      });
    }
  }

  void _handleAdvancedMode() {
    setState(() {
      _showAdvanced = true;
      _errorMessage = null;
    });
  }

  void _handleGenerateRandom() {
    setState(() {
      if (_useMnemonic) {
        _mnemonicController.text = _walletService.generateMnemonic();
      } else {
        _mnemonicController.text = _generateRandomHex();
      }
      _errorMessage = null;
    });
  }

  Future<void> _handleCreateWallet() async {
    final input = _mnemonicController.text.trim();
    if (input.isEmpty) {
      setState(() {
        _errorMessage = _useMnemonic 
            ? 'Please enter a mnemonic phrase'
            : 'Please enter a hex key';
      });
      return;
    }

    bool success;
    if (_useMnemonic) {
      success = await _walletService.createFromMnemonic(
        input,
        passphrase: _passphraseController.text.trim(),
      );
    } else {
      success = await _walletService.createFromHex(input);
    }

    if (success) {
      if (mounted) Navigator.of(context).pop(true);
    } else {
      setState(() {
        _errorMessage = _useMnemonic 
            ? 'Invalid mnemonic phrase'
            : 'Invalid hex key';
      });
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
        if (_errorMessage != null) ...[
          const SizedBox(height: 8),
          SailText.primary13(
            _errorMessage!,
            color: SailTheme.of(context).colors.error,
          ),
        ],
        if (_showAdvanced) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _useMnemonic,
                onChanged: (value) {
                  setState(() {
                    _useMnemonic = value ?? false;
                    // Clear input fields when switching modes
                    _mnemonicController.clear();
                    _passphraseController.clear();
                    _errorMessage = null;
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
