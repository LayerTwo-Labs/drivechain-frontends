import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sail_ui/sail_ui.dart';

/// Renders a PSBT as an animated UR `crypto-psbt` QR: cycles through the UR
/// frames at [fps], showing progress. A single small PSBT renders as one static
/// frame.
class AnimatedURQR extends StatefulWidget {
  final Uint8List psbt;
  final double size;
  final int fps;
  final int maxFragmentLen;

  const AnimatedURQR({
    super.key,
    required this.psbt,
    this.size = 280,
    this.fps = 6,
    this.maxFragmentLen = 200,
  });

  @override
  State<AnimatedURQR> createState() => _AnimatedURQRState();
}

class _AnimatedURQRState extends State<AnimatedURQR> {
  late List<String> _frames;
  int _index = 0;
  Timer? _timer;
  final Map<int, QrPainter> _painters = {};
  Color? _paintersColor;

  @override
  void initState() {
    super.initState();
    _buildFrames();
  }

  @override
  void didUpdateWidget(AnimatedURQR oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.psbt != widget.psbt || oldWidget.maxFragmentLen != widget.maxFragmentLen) {
      _timer?.cancel();
      _buildFrames();
    }
  }

  void _buildFrames() {
    _frames = URPsbt.encode(widget.psbt, maxFragmentLen: widget.maxFragmentLen);
    _painters.clear();
    _index = 0;
    if (_frames.length > 1) {
      _timer = Timer.periodic(Duration(milliseconds: (1000 / widget.fps).round()), (_) {
        if (!mounted) {
          return;
        }
        setState(() => _index = (_index + 1) % _frames.length);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// One painter per frame, so a frame computes its QR matrix one time.
  QrPainter _painter(Color color) {
    if (color != _paintersColor) {
      _painters.clear();
      _paintersColor = color;
    }
    return _painters.putIfAbsent(
      _index,
      () => QrPainter(
        data: _frames[_index].toUpperCase(),
        version: QrVersions.auto,
        gapless: true,
        eyeStyle: QrEyeStyle(color: color, eyeShape: QrEyeShape.square),
        dataModuleStyle: QrDataModuleStyle(color: color),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.sailTheme;
    return SailColumn(
      spacing: SailStyleValues.padding08,
      mainAxisSize: MainAxisSize.min,
      children: [
        SailCard(
          padding: true,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Semantics(
              label: 'qr code',
              child: CustomPaint(painter: _painter(theme.colors.text)),
            ),
          ),
        ),
        if (_frames.length > 1)
          SailText.secondary12('Frame ${_index + 1} of ${_frames.length}')
        else
          SailText.secondary12('Single frame'),
      ],
    );
  }
}
