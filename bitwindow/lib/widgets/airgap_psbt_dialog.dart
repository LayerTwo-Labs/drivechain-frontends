import 'dart:convert';
import 'dart:io';

import 'package:bitwindow/utils/explorer_url.dart';
import 'package:bitwindow/widgets/animated_ur_qr.dart';
import 'package:bitwindow/widgets/ur_qr_scanner.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

enum _Stage { export, import, broadcasting }

/// Drives the single-sig external-signer (airgap) PSBT flow once an unsigned
/// PSBT has been built: show it (animated QR / file / text) for the signer,
/// then ingest the signed PSBT (scan / file / text), combine, finalize and
/// broadcast.
class AirgapPsbtDialog extends StatefulWidget {
  final String unsignedPsbtBase64;

  /// Called with the broadcast txid on success.
  final void Function(String txid)? onBroadcast;

  const AirgapPsbtDialog({
    super.key,
    required this.unsignedPsbtBase64,
    this.onBroadcast,
  });

  @override
  State<AirgapPsbtDialog> createState() => _AirgapPsbtDialogState();
}

class _AirgapPsbtDialogState extends State<AirgapPsbtDialog> {
  _Stage _stage = _Stage.export;
  final TextEditingController _signedController = TextEditingController();
  bool _scanning = false;
  String? _error;
  String? _broadcastTxid;

  OrchestratorWalletRPC get _wallet => GetIt.I<OrchestratorRPC>().wallet;

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

  Future<void> _finalizeAndBroadcast(String signedPsbtBase64) async {
    setState(() {
      _stage = _Stage.broadcasting;
      _error = null;
    });
    try {
      final combined = await _wallet.combinePsbt(
        psbtsBase64: [widget.unsignedPsbtBase64, signedPsbtBase64],
      );
      final rawTxHex = await _wallet.finalizePsbt(psbtBase64: combined);
      final txid = await bitcoindRpcCall('sendrawtransaction', params: [rawTxHex]) as String;

      _broadcastTxid = txid;
      widget.onBroadcast?.call(txid);

      final network = GetIt.I.get<BitcoinConfProvider>().network;
      GetIt.I.get<NotificationProvider>().add(
        title: 'Transaction broadcast',
        content: txid,
        dialogType: DialogType.info,
        links: [NotificationLink(text: 'View transaction', url: mempoolTxUrl(txid, network))],
      );

      if (mounted) {
        showSailToast(context, 'Transaction broadcast', variant: SailToastVariant.success);
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _stage = _Stage.import;
          _error = 'Failed to broadcast: $e';
        });
      }
    }
  }

  void _onScanned(String psbtBase64) {
    setState(() {
      _signedController.text = psbtBase64;
      _scanning = false;
    });
    _finalizeAndBroadcast(psbtBase64);
  }

  @override
  Widget build(BuildContext context) {
    return SailModal(
      constraints: const BoxConstraints(maxWidth: 560, maxHeight: 760),
      child: SailCard(
        title: 'External signer (airgap)',
        subtitle: _stage == _Stage.export
            ? 'Show this unsigned PSBT to your signer'
            : 'Import the signed PSBT to broadcast',
        error: _error,
        child: SingleChildScrollView(child: _body()),
      ),
    );
  }

  Widget _body() {
    switch (_stage) {
      case _Stage.export:
        return _exportBody();
      case _Stage.import:
        return _importBody();
      case _Stage.broadcasting:
        return SailColumn(
          spacing: SailStyleValues.padding16,
          children: [
            const SizedBox(height: 40),
            const Center(child: LoadingIndicator()),
            SailText.secondary13('Combining, finalizing and broadcasting...'),
            if (_broadcastTxid != null) SailText.secondary12('txid: $_broadcastTxid'),
          ],
        );
    }
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
              onPressed: () async => Navigator.of(context).pop(false),
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
                label: 'Combine & broadcast',
                onPressed: () async {
                  final signed = _signedController.text.replaceAll(RegExp(r'\s'), '');
                  if (signed.isEmpty) {
                    setState(() => _error = 'Provide the signed PSBT first');
                    return;
                  }
                  await _finalizeAndBroadcast(signed);
                },
              ),
            ],
          ),
        ],
      ],
    );
  }
}
