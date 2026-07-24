import 'dart:convert';
import 'dart:io';

import 'package:bitwindow/widgets/animated_ur_qr.dart';
import 'package:bitwindow/widgets/ur_qr_scanner.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

enum _Stage { export, import }

/// Airgap round-trip: export an unsigned PSBT, then ingest the signed PSBT and
/// hand it back via [onSigned].
class AirgapSignStep extends StatefulWidget {
  final String unsignedPsbtBase64;
  final void Function(String signedPsbtBase64) onSigned;
  final void Function() onCancel;

  const AirgapSignStep({
    super.key,
    required this.unsignedPsbtBase64,
    required this.onSigned,
    required this.onCancel,
  });

  @override
  State<AirgapSignStep> createState() => _AirgapSignStepState();
}

class _AirgapSignStepState extends State<AirgapSignStep> {
  _Stage _stage = _Stage.export;
  final TextEditingController _signedController = TextEditingController();
  bool _scanning = false;
  String? _error;

  @override
  void dispose() {
    _signedController.dispose();
    super.dispose();
  }

  Uint8List get _unsignedBytes => base64.decode(widget.unsignedPsbtBase64);

  Future<void> _copyUnsigned() async {
    await Clipboard.setData(ClipboardData(text: widget.unsignedPsbtBase64));
    if (mounted) showSailToast(context, 'Unsigned PSBT copied', variant: SailToastVariant.success);
  }

  Future<void> _saveUnsigned() async {
    final path = await FilePicker.saveFile(
      dialogTitle: 'Save Unsigned PSBT',
      fileName: 'unsigned_${DateTime.now().millisecondsSinceEpoch}.psbt',
      type: FileType.custom,
      allowedExtensions: ['psbt'],
    );
    if (path == null) return;
    await File(path).writeAsBytes(_unsignedBytes);
    if (mounted) showSailToast(context, 'Saved unsigned PSBT', variant: SailToastVariant.success);
  }

  Future<void> _loadSignedFile() async {
    setState(() => _error = null);
    try {
      final result = await FilePicker.pickFiles(
        dialogTitle: 'Select Signed PSBT',
        type: FileType.any,
      );
      if (result == null || result.files.single.path == null) return;
      final file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();
      // A .psbt is raw binary (magic 0x70736274ff); text exports are base64.
      final isBinary =
          bytes.length >= 5 &&
          bytes[0] == 0x70 &&
          bytes[1] == 0x73 &&
          bytes[2] == 0x62 &&
          bytes[3] == 0x74 &&
          bytes[4] == 0xff;
      final text = isBinary ? base64.encode(bytes) : utf8.decode(bytes).trim();
      setState(() => _signedController.text = text);
    } catch (e) {
      setState(() => _error = 'Could not read file: $e');
    }
  }

  void _onScanned(String psbtBase64) {
    setState(() {
      _signedController.text = psbtBase64;
      _scanning = false;
    });
    widget.onSigned(psbtBase64);
  }

  @override
  Widget build(BuildContext context) {
    return SailCard(
      title: 'External signer (airgap)',
      subtitle: _stage == _Stage.export ? 'Show this unsigned PSBT to your signer' : 'Import the signed PSBT',
      error: _error,
      child: SingleChildScrollView(
        child: _stage == _Stage.export ? _exportBody() : _importBody(),
      ),
    );
  }

  Widget _exportBody() {
    return SailColumn(
      spacing: SailStyleValues.padding16,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AnimatedURQR(psbt: _unsignedBytes),
        SailRow(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: SailStyleValues.padding08,
          children: [
            SailButton(label: 'Copy base64', variant: ButtonVariant.secondary, onPressed: _copyUnsigned),
            SailButton(label: 'Save .psbt', variant: ButtonVariant.secondary, onPressed: _saveUnsigned),
          ],
        ),
        const SailSpacing(SailStyleValues.padding08),
        SailRow(
          mainAxisAlignment: MainAxisAlignment.end,
          spacing: SailStyleValues.padding08,
          children: [
            SailButton(
              label: 'Cancel',
              variant: ButtonVariant.ghost,
              onPressed: () async => widget.onCancel(),
            ),
            SailButton(
              label: 'Next: import signed',
              onPressed: () async => setState(() => _stage = _Stage.import),
            ),
          ],
        ),
      ],
    );
  }

  Widget _importBody() {
    return SailColumn(
      spacing: SailStyleValues.padding16,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_scanning)
          Center(
            child: URQrScanner(onComplete: _onScanned),
          )
        else ...[
          if (urCameraScanSupported)
            SailButton(
              label: 'Scan signed QR',
              onPressed: () async => setState(() => _scanning = true),
            ),
          SailButton(
            label: 'Load from file',
            variant: ButtonVariant.secondary,
            onPressed: _loadSignedFile,
          ),
          SailTextField(
            controller: _signedController,
            label: 'Or paste signed PSBT (base64)',
            hintText: 'cHNidP8B...',
            minLines: 3,
            maxLines: 6,
            monospace: true,
          ),
          SailRow(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: SailStyleValues.padding08,
            children: [
              SailButton(
                label: 'Back',
                variant: ButtonVariant.ghost,
                onPressed: () async => setState(() => _stage = _Stage.export),
              ),
              SailButton(
                label: 'Confirm signed',
                onPressed: () async {
                  final signed = _signedController.text.replaceAll(RegExp(r'\s'), '');
                  if (signed.isEmpty) {
                    setState(() => _error = 'Provide the signed PSBT first');
                    return;
                  }
                  widget.onSigned(signed);
                },
              ),
            ],
          ),
        ],
      ],
    );
  }
}
