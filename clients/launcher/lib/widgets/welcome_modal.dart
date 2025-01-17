import 'package:flutter/material.dart';
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

  @override
  void dispose() {
    _mnemonicController.dispose();
    _passphraseController.dispose();
    super.dispose();
  }

  void _handleFastMode() {
    // TODO: Implement fast withdrawal creation logic
    Navigator.of(context).pop(true);
  }

  void _handleAdvancedMode() {
    setState(() {
      _showAdvanced = true;
    });
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
                    // Clear input fields when switching modes
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
                onPressed: () {
                  // TODO: Implement random generation
                },
                size: ButtonSize.regular,
              ),
              const SizedBox(width: 8),
              SailButton.primary(
                'Create Wallet',
                onPressed: () {
                  // TODO: Implement wallet creation
                },
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
