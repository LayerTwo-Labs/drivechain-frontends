import 'package:flutter/material.dart';
import 'package:sail_ui/models/wallet_gradient.dart';
import 'package:sail_ui/models/wallet_metadata.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/widgets/buttons/button.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';
import 'package:sail_ui/widgets/inputs/text_field.dart';
import 'package:sail_ui/widgets/wallet_blob_avatar.dart';
import 'package:uuid/uuid.dart';

/// Dialog for creating or editing wallet metadata
class WalletManagementDialog extends StatefulWidget {
  final WalletMetadata? existingWallet;
  final Future<void> Function(String name, WalletGradient gradient) onSave;
  final Future<void> Function()? onDelete;

  const WalletManagementDialog({
    super.key,
    this.existingWallet,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<WalletManagementDialog> createState() => _WalletManagementDialogState();
}

class _WalletManagementDialogState extends State<WalletManagementDialog> {
  late TextEditingController _nameController;
  late WalletGradient _gradient;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingWallet?.name ?? '',
    );
    _gradient = widget.existingWallet?.gradient ?? WalletGradient.fromWalletId(_generateId());
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _generateId() {
    return const Uuid().v4().replaceAll('-', '').toUpperCase();
  }

  void _regenerateGradient() {
    setState(() {
      _gradient = WalletGradient.fromWalletId(_generateId());
    });
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await widget.onSave(_nameController.text.trim(), _gradient);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _delete() async {
    if (widget.onDelete == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _DeleteConfirmationDialog(
        walletName: widget.existingWallet!.name,
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      await widget.onDelete!();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final isEditing = widget.existingWallet != null;

    return Dialog(
      backgroundColor: theme.colors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary20(
              isEditing ? 'Edit Wallet' : 'Create New Wallet',
              bold: true,
            ),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  WalletBlobAvatar(
                    gradient: _gradient,
                    size: 80,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _regenerateGradient,
                    child: SailText.primary12(
                      'Regenerate icon',
                      color: theme.colors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SailText.primary13('Wallet Name', bold: true),
            const SizedBox(height: 8),
            SailTextField(
              controller: _nameController,
              hintText: 'Enter wallet name',
              enabled: !_isLoading,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isEditing && widget.onDelete != null) ...[
                  SailButton(
                    label: 'Delete',
                    onPressed: _delete,
                    loading: _isLoading,
                    variant: ButtonVariant.destructive,
                  ),
                  const Spacer(),
                ],
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  child: SailText.primary13('Cancel'),
                ),
                const SizedBox(width: 8),
                SailButton(
                  label: isEditing ? 'Save' : 'Create',
                  onPressed: _save,
                  loading: _isLoading,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteConfirmationDialog extends StatelessWidget {
  final String walletName;

  const _DeleteConfirmationDialog({
    required this.walletName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return AlertDialog(
      backgroundColor: theme.colors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: SailText.primary15('Delete Wallet?', bold: true),
      content: SailText.primary13(
        'Are you sure you want to delete "$walletName"? This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: SailText.primary13('Cancel'),
        ),
        SailButton(
          label: 'Delete',
          onPressed: () async => Navigator.of(context).pop(true),
          variant: ButtonVariant.destructive,
        ),
      ],
    );
  }
}
