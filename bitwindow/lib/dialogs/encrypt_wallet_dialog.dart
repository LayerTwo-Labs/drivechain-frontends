import 'package:bitwindow/providers/encryption_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

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

    if (_passwordController.text.length < 8) {
      setState(() => _errorMessage = 'Password must be at least 8 characters');
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

    return AlertDialog(
      title: SailText.primary20('Encrypt Wallet'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary13(
              'Protect your wallet with a password. You will need to enter this password '
              'every time you start the application.',
            ),
            const SizedBox(height: 8),
            SailText.secondary12(
              'WARNING: If you lose your password, you will need to restore your wallet '
              'using your seed phrase. Make sure to keep your seed phrase safe!',
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              enabled: !_isEncrypting,
              decoration: InputDecoration(
                labelText: 'Password',
                helperText: 'At least 8 characters',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              enabled: !_isEncrypting,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
              ),
              onSubmitted: (_) => _encrypt(),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.colors.error),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: theme.colors.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SailText.primary12(
                        _errorMessage!,
                        color: theme.colors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
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
    );
  }
}
