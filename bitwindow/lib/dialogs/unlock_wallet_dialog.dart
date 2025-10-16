import 'package:bitwindow/providers/encryption_provider.dart';
import 'package:bitwindow/providers/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

/// Dialog for unlocking an encrypted wallet
class UnlockWalletDialog extends StatefulWidget {
  const UnlockWalletDialog({super.key});

  @override
  State<UnlockWalletDialog> createState() => _UnlockWalletDialogState();

  /// Show the unlock wallet dialog
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const UnlockWalletDialog(),
    );
  }
}

class _UnlockWalletDialogState extends State<UnlockWalletDialog> {
  final _passwordController = TextEditingController();
  final _encryptionProvider = GetIt.I.get<EncryptionProvider>();
  final _logger = GetIt.I.get<Logger>();
  bool _isUnlocking = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    // Validate password
    if (_passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter your password');
      return;
    }

    setState(() {
      _isUnlocking = true;
      _errorMessage = null;
    });

    try {
      final success = await _encryptionProvider.unlockWallet(_passwordController.text);

      if (!mounted) return;

      if (success) {
        // Unlock successful, sync starter files so binaries can use the wallet
        try {
          final walletProvider = GetIt.I.get<WalletProvider>();
          await walletProvider.syncStarterFiles();
          _logger.i('Synced starter files after wallet unlock');
        } catch (e) {
          _logger.e('Failed to sync starter files after unlock: $e');
        }

        // Close dialog with success
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _errorMessage = 'Incorrect password';
          _isUnlocking = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error unlocking wallet: $e';
        _isUnlocking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 400),
        child: SailCard(
          title: 'Unlock Wallet',
          subtitle: 'Enter your password to unlock the wallet',
          error: _errorMessage,
          child: SingleChildScrollView(
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
                  child: SailText.primary13(
                    'Your wallet is encrypted. Please enter your password to access sidechain features.',
                  ),
                ),

                // Password field
                SailTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hintText: 'Enter your password',
                  obscureText: _obscurePassword,
                  enabled: !_isUnlocking,
                  autofocus: true,
                  maxLines: 1,
                  onSubmitted: (_) => _unlock(),
                  suffixWidget: GestureDetector(
                    onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                    child: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: theme.colors.text,
                    ),
                  ),
                ),

                // Action buttons
                SailRow(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: SailStyleValues.padding08,
                  children: [
                    SailButton(
                      label: 'Cancel',
                      variant: ButtonVariant.secondary,
                      onPressed: _isUnlocking ? null : () async => Navigator.of(context).pop(false),
                    ),
                    SailButton(
                      label: 'Unlock',
                      loading: _isUnlocking,
                      onPressed: () async => _unlock(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
