import 'package:bitwindow/providers/encryption_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

/// Dialog for changing the wallet password
class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();

  /// Show the change password dialog
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ChangePasswordDialog(),
    );
  }
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isChanging = false;
  String? _errorMessage;
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    // Validate inputs
    if (_oldPasswordController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter your current password');
      return;
    }

    if (_newPasswordController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter a new password');
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'New passwords do not match');
      return;
    }

    if (_oldPasswordController.text == _newPasswordController.text) {
      setState(() => _errorMessage = 'New password must be different from old password');
      return;
    }

    setState(() {
      _isChanging = true;
      _errorMessage = null;
    });

    try {
      final encryptionProvider = GetIt.I.get<EncryptionProvider>();
      await encryptionProvider.changePassword(
        _oldPasswordController.text,
        _newPasswordController.text,
      );

      if (!mounted) return;

      // Password change successful, close dialog
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().contains('Incorrect old password')
            ? 'Incorrect current password'
            : 'Error changing password: $e';
        _isChanging = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return AlertDialog(
      title: SailText.primary20('Change Password'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary13(
              'Enter your current password and choose a new password for your wallet.',
            ),
            const SizedBox(height: 24),
            SailTextField(
              controller: _oldPasswordController,
              label: 'Current Encryption Password',
              hintText: 'Enter your current password',
              obscureText: _obscureOldPassword,
              enabled: !_isChanging,
              autofocus: true,
              maxLines: 1,
              suffixWidget: GestureDetector(
                onTap: () => setState(() => _obscureOldPassword = !_obscureOldPassword),
                child: Icon(
                  _obscureOldPassword ? Icons.visibility : Icons.visibility_off,
                  color: SailTheme.of(context).colors.text,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SailTextField(
              controller: _newPasswordController,
              label: 'New Encryption Password',
              hintText: 'Choose a new password',
              obscureText: _obscureNewPassword,
              enabled: !_isChanging,
              maxLines: 1,
              suffixWidget: GestureDetector(
                onTap: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                child: Icon(
                  _obscureNewPassword ? Icons.visibility : Icons.visibility_off,
                  color: SailTheme.of(context).colors.text,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SailTextField(
              controller: _confirmPasswordController,
              label: 'Confirm New Encryption Password',
              hintText: 'Confirm your new password',
              obscureText: _obscureConfirmPassword,
              enabled: !_isChanging,
              maxLines: 1,
              onSubmitted: (_) => _changePassword(),
              suffixWidget: GestureDetector(
                onTap: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                child: Icon(
                  _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                  color: SailTheme.of(context).colors.text,
                ),
              ),
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
          onPressed: _isChanging ? null : () async => Navigator.of(context).pop(false),
        ),
        SailButton(
          label: 'Change Password',
          loading: _isChanging,
          onPressed: () async => _changePassword(),
        ),
      ],
    );
  }
}
