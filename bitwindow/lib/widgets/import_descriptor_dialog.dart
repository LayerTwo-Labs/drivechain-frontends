import 'dart:io';

import 'package:bitwindow/pages/welcome/wallet_creation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

/// Opens the import descriptor dialog. It closes when the wallet exists.
Future<void> showImportDescriptorDialog(BuildContext context) {
  return showThemedDialog<void>(
    context: context,
    builder: (context) => const ImportDescriptorDialog(),
  );
}

class ImportDescriptorDialog extends StatefulWidget {
  const ImportDescriptorDialog({super.key});

  @override
  State<ImportDescriptorDialog> createState() => _ImportDescriptorDialogState();
}

class _ImportDescriptorDialogState extends State<ImportDescriptorDialog> {
  final TextEditingController _descriptor = TextEditingController();
  bool _importing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _descriptor.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _descriptor.dispose();
    super.dispose();
  }

  Future<void> _run(Future<String> Function() create) async {
    setState(() {
      _importing = true;
      _error = null;
    });
    try {
      await create();
    } catch (e) {
      if (mounted) {
        setState(() {
          _importing = false;
          _error = extractConnectException(e);
        });
      }
      return;
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _import() => _run(() => importDescriptorWallet(_descriptor.text));

  Future<void> _importFile() async {
    final result = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['txt', 'json', 'conf'],
      dialogTitle: 'Import multisig config',
    );
    if (result == null) {
      return;
    }
    final path = result.path;
    if (path == null) {
      setState(() => _error = 'Could not read the selected file');
      return;
    }
    await _run(() async => importMultisigConfigWallet(await File(path).readAsString()));
  }

  @override
  Widget build(BuildContext context) {
    return SailModal(
      constraints: const BoxConstraints(maxWidth: 560),
      child: SailCard(
        title: 'Import descriptor',
        subtitle:
            'Paste an output descriptor. A descriptor with private keys can spend. One with public keys only watches.',
        error: _error,
        child: SailColumn(
          spacing: SailStyleValues.padding16,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailTextField(
              controller: _descriptor,
              label: 'Descriptor',
              hintText: "wpkh([d34db33f/84'/0'/0']xpub6CUGRUo.../0/*)",
              monospace: true,
              minLines: 3,
              maxLines: 6,
            ),
            SailButton(
              label: 'Import file',
              variant: ButtonVariant.secondary,
              small: true,
              disabled: _importing,
              onPressed: _importFile,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SailButton(
                  label: 'Cancel',
                  variant: ButtonVariant.ghost,
                  disabled: _importing,
                  onPressed: () async => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
                SailButton(
                  label: 'Import',
                  loading: _importing,
                  disabled: _descriptor.text.trim().isEmpty,
                  onPressed: _import,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
