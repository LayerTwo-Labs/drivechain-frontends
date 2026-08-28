import 'package:bitwindow/utils/ur_key.dart';
import 'package:bitwindow/widgets/ur_qr_scanner.dart' show urCameraScanSupported;
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sail_ui/sail_ui.dart';

/// Shows the key scanner and returns the picked key, or null on cancel.
///
/// [scriptType] selects which key a multi-key export gives back: the multisig
/// policy's own script type, e.g. `wsh`.
Future<UrKey?> showKeyQrScanner(BuildContext context, {required String scriptType}) {
  return showThemedDialog<UrKey>(
    context: context,
    builder: (context) => KeyQrScannerDialog(scriptType: scriptType),
  );
}

/// Camera scanner for an extended public key.
///
/// Reads a single QR that holds `[fingerprint/origin]xpub`, a bare xpub, or a
/// wallet export in JSON. Reads an animated UR sequence as well: airgap
/// signers send `crypto-hdkey`, `crypto-account`, or a `bytes` export over
/// many frames, and the scanner joins them.
class KeyQrScannerDialog extends StatefulWidget {
  final String scriptType;

  const KeyQrScannerDialog({super.key, required this.scriptType});

  @override
  State<KeyQrScannerDialog> createState() => _KeyQrScannerDialogState();
}

class _KeyQrScannerDialogState extends State<KeyQrScannerDialog> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );
  URDecoder _decoder = URDecoder();
  bool _done = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_done) {
      return;
    }
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue?.trim();
      if (raw == null || raw.isEmpty) {
        continue;
      }
      if (raw.toLowerCase().startsWith('ur:')) {
        _receiveUrFrame(raw);
      } else {
        _finish(parseKeyText(raw), 'That QR code holds no extended public key');
      }
      if (_done) {
        return;
      }
    }
  }

  void _receiveUrFrame(String frame) {
    try {
      _decoder.receive(frame);
    } on FormatException {
      // A frame from a different export would otherwise hold the scanner on a
      // set it can never complete. Restart and read this frame as the first.
      _decoder = URDecoder();
      try {
        _decoder.receive(frame);
      } on FormatException {
        return;
      }
    }

    if (_decoder.type == 'crypto-psbt') {
      _setError('That QR code holds a transaction, not a key');
      return;
    }
    if (!_decoder.isComplete) {
      _setError(null);
      return;
    }

    try {
      _finish(
        parseUrKeyMessage(_decoder.messageBytes(), urType: _decoder.type),
        'That QR code holds no extended public key',
      );
    } on FormatException catch (e) {
      _decoder = URDecoder();
      _setError('Could not read the QR code: ${e.message}');
    }
  }

  void _finish(List<UrKey> keys, String emptyMessage) {
    final key = pickKeyForScriptType(keys, widget.scriptType);
    if (key == null) {
      _setError(emptyMessage);
      return;
    }
    _done = true;
    Navigator.of(context).pop(key);
  }

  void _setError(String? message) {
    if (!mounted || _error == message) {
      return;
    }
    setState(() => _error = message);
  }

  @override
  Widget build(BuildContext context) {
    final received = _decoder.receivedCount;
    final expected = _decoder.expectedCount;

    return SailModal(
      constraints: const BoxConstraints(maxWidth: 420),
      child: SailCard(
        title: 'Scan key QR',
        error: _error,
        child: SailColumn(
          spacing: SailStyleValues.padding16,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (urCameraScanSupported)
              SizedBox(
                width: 320,
                height: 320,
                child: MobileScanner(
                  controller: _controller,
                  onDetect: _onDetect,
                  errorBuilder: (context, error) => Center(
                    child: SailText.secondary13('Camera error: ${error.errorCode.name}'),
                  ),
                ),
              )
            else
              SailText.secondary13('Camera scanning is not available on this platform.'),
            if (urCameraScanSupported && expected != null && expected > 1)
              SailText.secondary12('Scanned $received of $expected parts'),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SailButton(
                  label: 'Cancel',
                  variant: ButtonVariant.ghost,
                  onPressed: () async => Navigator.of(context).pop(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
