import 'package:sail_ui/sail_ui.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

/// Dialog for encrypting an unencrypted wallet
class EncryptWalletDialog extends StatefulWidget {
  const EncryptWalletDialog({super.key});

  @override
  State<EncryptWalletDialog> createState() => _EncryptWalletDialogState();

  /// Show the encrypt wallet dialog
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const EncryptWalletDialog(),
    );
  }
}

class _EncryptWalletDialogState extends State<EncryptWalletDialog> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isEncrypting = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _encrypt() async {
    // Validate passwords
    if (_passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter a password');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Passwords do not match');
      return;
    }

    setState(() {
      _isEncrypting = true;
      _errorMessage = null;
    });

    try {
      final encryptionProvider = GetIt.I.get<EncryptionProvider>();
      await encryptionProvider.encryptWallet(_passwordController.text);

      if (!mounted) return;

      // Encryption successful, close dialog
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error encrypting wallet: $e';
        _isEncrypting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailDialog(
      title: 'Encrypt Wallet',
      subtitle: 'Protect your wallet with a password',
      error: _errorMessage,
      actions: [
        SailButton(
          label: 'Cancel',
          variant: ButtonVariant.secondary,
          onPressed: _isEncrypting ? null : () async => Navigator.of(context).pop(false),
        ),
        SailButton(
          label: 'Encrypt Wallet',
          loading: _isEncrypting,
          onPressed: () async => _encrypt(),
        ),
      ],
      child: SailColumn(
        spacing: SailStyleValues.padding16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info section
          Container(
            padding: const EdgeInsets.all(SailStyleValues.padding12),
            decoration: BoxDecoration(
              color: theme.colors.backgroundSecondary,
              borderRadius: SailStyleValues.borderRadiusSmall,
              border: Border.all(color: theme.colors.border),
            ),
            child: SailColumn(
              spacing: SailStyleValues.padding08,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SailText.primary13(
                  'You will need to enter this password every time you start BitWindow.',
                ),
                SailText.secondary12(
                  'WARNING: If you lose your password, you will need to restore your wallet '
                  'using your seed phrase. Make sure to keep your seed phrase safe!',
                ),
              ],
            ),
          ),

          // Password fields
          SailTextField(
            controller: _passwordController,
            label: 'Password',
            hintText: 'Enter a password',
            obscureText: _obscurePassword,
            enabled: !_isEncrypting,
            autofocus: true,
            maxLines: 1,
            suffixWidget: GestureDetector(
              onTap: () => setState(() => _obscurePassword = !_obscurePassword),
              child: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                color: theme.colors.text,
              ),
            ),
          ),

          SailTextField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            hintText: 'Confirm password',
            obscureText: _obscureConfirmPassword,
            enabled: !_isEncrypting,
            maxLines: 1,
            onSubmitted: (_) => _encrypt(),
            suffixWidget: GestureDetector(
              onTap: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              child: Icon(
                _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                color: theme.colors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
