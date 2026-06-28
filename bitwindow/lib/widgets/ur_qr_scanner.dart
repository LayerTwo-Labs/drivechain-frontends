import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sail_ui/sail_ui.dart';

/// True on platforms where [mobile_scanner] provides live camera scanning.
/// Windows and Linux have no plugin implementation, so callers must fall back
/// to file/text import there.
bool get urCameraScanSupported {
  if (kIsWeb) return true;
  return Platform.isMacOS || Platform.isIOS || Platform.isAndroid;
}

/// Live camera scanner that reassembles an animated UR `crypto-psbt` and
/// returns the decoded PSBT as base64 via [onComplete]. Shows received/total
/// part progress while scanning.
class URQrScanner extends StatefulWidget {
  final void Function(String psbtBase64) onComplete;
  final double size;

  const URQrScanner({super.key, required this.onComplete, this.size = 320});

  @override
  State<URQrScanner> createState() => _URQrScannerState();
}

class _URQrScannerState extends State<URQrScanner> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );
  late URDecoder _decoder;
  bool _done = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _decoder = URPsbt.decoder();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_done) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw == null) continue;
      if (!raw.toLowerCase().startsWith('ur:${URPsbt.type}/')) continue;
      try {
        _decoder.receive(raw);
      } catch (_) {
        // A frame from a different PSBT (or otherwise inconsistent with the
        // in-progress set) would otherwise wedge the scanner forever. Restart
        // and re-feed this frame as the start of a fresh capture.
        _decoder = URPsbt.decoder();
        try {
          _decoder.receive(raw);
          if (mounted) setState(() => _error = 'Different PSBT detected, restarting');
        } catch (_) {
          continue;
        }
        continue;
      }
      if (_decoder.isComplete) {
        _done = true;
        final psbt = _decoder.resultBase64();
        widget.onComplete(psbt);
        return;
      }
      if (mounted) setState(() => _error = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!urCameraScanSupported) {
      return SailText.secondary13(
        'Camera scanning is not available on this platform. Use file or text import instead.',
      );
    }

    final received = _decoder.receivedCount;
    final expected = _decoder.expectedCount;

    return SailColumn(
      spacing: SailStyleValues.padding08,
      mainAxisSize: MainAxisSize.min,
      children: [
        SailCard(
          padding: true,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              errorBuilder: (context, error) => Center(
                child: SailText.secondary13('Camera error: ${error.errorCode.name}'),
              ),
            ),
          ),
        ),
        if (expected != null)
          SailText.secondary12('Scanned $received of $expected parts')
        else
          SailText.secondary12('Point camera at the animated QR'),
        if (_error != null) SailText.secondary12(_error!),
      ],
    );
  }
}
