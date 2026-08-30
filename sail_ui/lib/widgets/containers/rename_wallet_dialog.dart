import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

/// Asks for a new wallet name. Returns null when the user backs out.
Future<String?> showRenameWalletDialog(BuildContext context, String currentName) {
  return showThemedDialog<String>(
    context: context,
    builder: (context) => _RenameWalletDialog(currentName: currentName),
  );
}

class _RenameWalletDialog extends StatefulWidget {
  final String currentName;

  const _RenameWalletDialog({required this.currentName});

  @override
  State<_RenameWalletDialog> createState() => _RenameWalletDialogState();
}

class _RenameWalletDialogState extends State<_RenameWalletDialog> {
  late final TextEditingController _name = TextEditingController(text: widget.currentName);
  final FocusNode _focus = FocusNode();

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

  void _submit() {
    final next = _name.text.trim();
    if (next.isEmpty) {
      return;
    }
    Navigator.of(context).pop(next);
  }

  @override
  Widget build(BuildContext context) {
    return SailModal(
      constraints: const BoxConstraints(maxWidth: 420),
      child: SailCard(
        title: 'Rename wallet',
        subtitle: 'The name is only shown here. It does not change any keys.',
        child: SailColumn(
          mainAxisSize: MainAxisSize.min,
          spacing: SailStyleValues.padding16,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailTextField(
              controller: _name,
              focusNode: _focus,
              hintText: 'Wallet name',
              size: TextFieldSize.small,
              onSubmitted: (_) => _submit(),
            ),
            SailRow(
              spacing: SailStyleValues.padding08,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SailButton(
                  label: 'Cancel',
                  variant: ButtonVariant.secondary,
                  small: true,
                  onPressed: () async => Navigator.of(context).pop(),
                ),
                SailButton(
                  label: 'Rename',
                  small: true,
                  disabled: _name.text.trim().isEmpty,
                  onPressed: () async => _submit(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
