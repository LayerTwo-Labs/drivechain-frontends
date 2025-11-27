import 'package:sail_ui/sail_ui.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

/// Dialog for removing wallet encryption entirely
class RemoveEncryptionDialog extends StatefulWidget {
  const RemoveEncryptionDialog({super.key});

  @override
  State<RemoveEncryptionDialog> createState() => _RemoveEncryptionDialogState();

  /// Show the remove encryption dialog
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const RemoveEncryptionDialog(),
    );
  }
}

class _RemoveEncryptionDialogState extends State<RemoveEncryptionDialog> {
  final _passwordController = TextEditingController();
  bool _isRemoving = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _removeEncryption() async {
    if (_passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter your password');
      return;
    }

    setState(() {
      _isRemoving = true;
      _errorMessage = null;
    });

    try {
      final walletReader = GetIt.I.get<WalletReaderProvider>();
      await walletReader.removeEncryption(_passwordController.text);

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().contains('Incorrect password')
            ? 'Incorrect password'
            : 'Error removing encryption: $e';
        _isRemoving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailDialog(
      title: 'Remove Encryption',
      subtitle: 'This will decrypt your wallet and store it unencrypted.',
      error: _errorMessage,
      actions: [
        SailButton(
          label: 'Cancel',
          variant: ButtonVariant.secondary,
          onPressed: _isRemoving ? null : () async => Navigator.of(context).pop(false),
        ),
        SailButton(
          label: 'Remove Encryption',
          variant: ButtonVariant.destructive,
          loading: _isRemoving,
          onPressed: () async => _removeEncryption(),
        ),
      ],
      child: SailColumn(
        spacing: SailStyleValues.padding16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(SailStyleValues.padding12),
            decoration: BoxDecoration(
              color: theme.colors.orange.withValues(alpha: 0.1),
              borderRadius: SailStyleValues.borderRadiusSmall,
              border: Border.all(
                color: theme.colors.orange.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                SailSVG.icon(SailSVGAsset.iconWarning, width: 20),
                const SizedBox(width: SailStyleValues.padding12),
                Expanded(
                  child: SailText.secondary13(
                    'Your wallet will be stored without encryption. '
                    'Anyone with access to your device could access your funds.',
                  ),
                ),
              ],
            ),
          ),
          SailTextField(
            controller: _passwordController,
            label: 'Current Password',
            hintText: 'Enter your current password',
            obscureText: _obscurePassword,
            enabled: !_isRemoving,
            autofocus: true,
            maxLines: 1,
            onSubmitted: (_) => _removeEncryption(),
            suffixWidget: GestureDetector(
              onTap: () => setState(() => _obscurePassword = !_obscurePassword),
              child: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                color: theme.colors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
