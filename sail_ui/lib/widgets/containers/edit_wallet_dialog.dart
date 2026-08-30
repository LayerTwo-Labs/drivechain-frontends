import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

/// What the user asked for in the edit dialog.
class EditWalletResult {
  /// The name the wallet carries after the dialog.
  final String name;

  /// A new picture the user placed, as PNG bytes.
  final Uint8List? picture;

  /// True when the user asked for the generated avatar back.
  final bool removePicture;

  /// True when the user asked to delete the wallet.
  final bool delete;

  const EditWalletResult({
    required this.name,
    this.picture,
    this.removePicture = false,
    this.delete = false,
  });
}

/// Edits a wallet's name and picture, and offers to delete it. Returns null
/// when the user backs out.
Future<EditWalletResult?> showEditWalletDialog(
  BuildContext context, {
  required String currentName,
  required WalletGradient gradient,
  required Future<Uint8List?> Function() onChangePicture,
  required Future<bool> Function() onConfirmDelete,
}) {
  return showThemedDialog<EditWalletResult>(
    context: context,
    builder: (context) => _EditWalletDialog(
      currentName: currentName,
      gradient: gradient,
      onChangePicture: onChangePicture,
      onConfirmDelete: onConfirmDelete,
    ),
  );
}

class _EditWalletDialog extends StatefulWidget {
  final String currentName;
  final WalletGradient gradient;
  final Future<Uint8List?> Function() onChangePicture;
  final Future<bool> Function() onConfirmDelete;

  const _EditWalletDialog({
    required this.currentName,
    required this.gradient,
    required this.onChangePicture,
    required this.onConfirmDelete,
  });

  @override
  State<_EditWalletDialog> createState() => _EditWalletDialogState();
}

class _EditWalletDialogState extends State<_EditWalletDialog> {
  late final TextEditingController _name = TextEditingController(text: widget.currentName);
  final FocusNode _focus = FocusNode();
  Uint8List? _picture;
  bool _removePicture = false;

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
    _focus.requestFocus();
    _name.selection = TextSelection(baseOffset: 0, extentOffset: _name.text.length);
  }

  @override
  void dispose() {
    _name.dispose();
    _focus.dispose();
    super.dispose();
  }

  bool get _hasPicture => (widget.gradient.picturePath ?? '').isNotEmpty;

  bool get _showsPicture => _picture != null || (_hasPicture && !_removePicture);

  void _submit() {
    final next = _name.text.trim();
    if (next.isEmpty) {
      return;
    }
    Navigator.of(context).pop(
      EditWalletResult(name: next, picture: _picture, removePicture: _removePicture),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailModal(
      constraints: const BoxConstraints(maxWidth: 440),
      child: SailCard(
        title: 'Edit wallet',
        withCloseButton: true,
        child: SailColumn(
          mainAxisSize: MainAxisSize.min,
          spacing: SailStyleValues.padding20,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailRow(
              spacing: SailStyleValues.padding16,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _avatar(),
                Expanded(
                  child: SailColumn(
                    mainAxisSize: MainAxisSize.min,
                    spacing: SailStyleValues.padding08,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SailRow(
                        spacing: SailStyleValues.padding08,
                        children: [
                          SailButton(
                            label: 'Change picture',
                            variant: ButtonVariant.outline,
                            small: true,
                            onPressed: _pick,
                          ),
                          if (_showsPicture)
                            SailButton(
                              label: 'Remove',
                              variant: ButtonVariant.ghost,
                              small: true,
                              onPressed: () async => setState(() {
                                _picture = null;
                                _removePicture = true;
                              }),
                            ),
                        ],
                      ),
                      SailText.secondary12('Set your own picture avatar to remember this wallet by.'),
                    ],
                  ),
                ),
              ],
            ),
            SailTextField(
              label: 'Wallet name',
              controller: _name,
              focusNode: _focus,
              hintText: 'Wallet name',
              size: TextFieldSize.small,
              onSubmitted: (_) => _submit(),
            ),
            Divider(height: 1, thickness: 1, color: theme.colors.divider),
            SailRow(
              spacing: SailStyleValues.padding08,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SailButton(
                  label: 'Delete wallet',
                  variant: ButtonVariant.ghost,
                  textColor: theme.colors.error,
                  small: true,
                  onPressed: _delete,
                ),
                SailRow(
                  spacing: SailStyleValues.padding08,
                  children: [
                    SailButton(
                      label: 'Cancel',
                      variant: ButtonVariant.outline,
                      small: true,
                      onPressed: () async => Navigator.of(context).pop(),
                    ),
                    SailButton(
                      label: 'Save',
                      small: true,
                      disabled: _name.text.trim().isEmpty,
                      onPressed: () async => _submit(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Shows what the wallet looks like after the dialog: the picture the user
  /// just placed, or the avatar the wallet falls back to.
  Widget _avatar() {
    final picture = _picture;
    if (picture != null) {
      return ClipOval(
        child: Image.memory(picture, width: 48, height: 48, fit: BoxFit.cover),
      );
    }
    final gradient = _removePicture ? widget.gradient.withoutPicture() : widget.gradient;
    return WalletBlobAvatar(gradient: gradient, size: 48);
  }

  Future<void> _pick() async {
    final picked = await widget.onChangePicture();
    if (picked == null) {
      return;
    }
    setState(() {
      _picture = picked;
      _removePicture = false;
    });
  }

  Future<void> _delete() async {
    final go = await widget.onConfirmDelete();
    if (!go || !mounted) {
      return;
    }
    Navigator.of(context).pop(
      EditWalletResult(name: widget.currentName, delete: true),
    );
  }
}
