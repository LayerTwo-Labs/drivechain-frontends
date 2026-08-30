import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sail_ui/sail_ui.dart';

/// Asks the user to place a picture inside a round window, and returns the
/// cropped PNG. Returns null when the user backs out.
Future<Uint8List?> showPlacePictureDialog(BuildContext context, File source) {
  return showThemedDialog<Uint8List>(
    context: context,
    builder: (context) => _PlacePictureDialog(source: source),
  );
}

/// Largest side the round window takes. A smaller window shrinks it.
const double _pictureLargestSide = 432;

/// Smallest side worth placing a picture in.
const double _pictureSmallestSide = 120;

/// Height the card header, the help line, the buttons and the gaps take
/// around the window.
const double _pictureChrome = 260;

/// Keeps the picture over the whole window. A drag past this leaves empty
/// space in the saved picture.
Offset clampPictureOffset(Offset offset, Size scaled, double side) {
  final maxX = scaled.width > side ? (scaled.width - side) / 2 : 0.0;
  final maxY = scaled.height > side ? (scaled.height - side) / 2 : 0.0;
  return Offset(offset.dx.clamp(-maxX, maxX), offset.dy.clamp(-maxY, maxY));
}

/// The zoom after one scroll step. 1 covers the window, and the top stops the
/// picture from breaking apart.
double zoomFactorAfter(double factor, double scrollDelta) {
  return (factor * (scrollDelta > 0 ? 0.95 : 1.05)).clamp(1.0, 8.0);
}

/// The side the window takes in a window of [size].
double pictureSideFor(Size size) {
  final byWidth = size.width - 96;
  final byHeight = size.height - _pictureChrome;
  final side = byWidth < byHeight ? byWidth : byHeight;
  return side.clamp(_pictureSmallestSide, _pictureLargestSide);
}

class _PlacePictureDialog extends StatefulWidget {
  final File source;

  const _PlacePictureDialog({required this.source});

  @override
  State<_PlacePictureDialog> createState() => _PlacePictureDialogState();
}

class _PlacePictureDialogState extends State<_PlacePictureDialog> {
  final GlobalKey _viewport = GlobalKey();
  Offset _offset = Offset.zero;

  /// Zoom the user asked for, as a factor of the scale that covers the window.
  /// 1 covers the window, so a smaller value would show empty corners.
  double _zoomFactor = 1;
  ui.Image? _source;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// The picture lays out at its own size so every part of it can reach the
  /// window. A camera photo decodes at a smaller size, since the window keeps
  /// at most a few hundred pixels and a full decode can take hundreds of
  /// megabytes.
  Future<void> _load() async {
    try {
      await _decode();
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'That file is not a picture this app can read.');
      }
    }
  }

  Future<void> _decode() async {
    final bytes = await widget.source.readAsBytes();
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    final descriptor = await ui.ImageDescriptor.encoded(buffer);

    final short = descriptor.width < descriptor.height ? descriptor.width : descriptor.height;
    final target = _pictureLargestSide * 2;
    final factor = short > target ? target / short : 1.0;

    final codec = await descriptor.instantiateCodec(
      targetWidth: (descriptor.width * factor).round(),
      targetHeight: (descriptor.height * factor).round(),
    );
    final frame = await codec.getNextFrame();
    descriptor.dispose();

    if (!mounted) {
      frame.image.dispose();
      return;
    }
    setState(() {
      _source = frame.image;
      _zoomFactor = 1;
    });
  }

  /// The scale that covers the window with the picture's short side. It reads
  /// the window every build, so a resize keeps the window covered.
  double get _coverScale {
    final image = _source;
    if (image == null) {
      return 1;
    }
    return _side / (image.width < image.height ? image.width : image.height);
  }

  double get _scale => _coverScale * _zoomFactor;

  Size get _scaledSize {
    final image = _source;
    if (image == null) {
      return Size.zero;
    }
    return Size(image.width * _scale, image.height * _scale);
  }

  void _zoom(double delta) {
    setState(() {
      _zoomFactor = zoomFactorAfter(_zoomFactor, delta);
      _offset = clampPictureOffset(_offset, _scaledSize, _side);
    });
  }

  void _drag(Offset delta) {
    setState(() => _offset = clampPictureOffset(_offset + delta, _scaledSize, _side));
  }

  double get _side => pictureSideFor(MediaQuery.sizeOf(context));

  Future<void> _use() async {
    final boundary = _viewport.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      return;
    }
    final image = await boundary.toImage(pixelRatio: 1);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    if (!mounted || data == null) {
      return;
    }
    Navigator.of(context).pop(data.buffer.asUint8List());
  }

  @override
  Widget build(BuildContext context) {
    final side = _side;
    // The window decides how far the picture may travel, so a resize brings
    // the offset back inside its new bounds.
    _offset = clampPictureOffset(_offset, _scaledSize, side);

    return SailModal(
      constraints: const BoxConstraints(maxWidth: 480),
      child: SailCard(
        title: 'Place the picture',
        child: SailColumn(
          mainAxisSize: MainAxisSize.min,
          spacing: SailStyleValues.padding16,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Listener(
              onPointerSignal: (event) {
                if (event is PointerScrollEvent) {
                  _zoom(event.scrollDelta.dy);
                }
              },
              child: GestureDetector(
                onPanUpdate: (details) => _drag(details.delta),
                child: ClipOval(
                  child: RepaintBoundary(
                    key: _viewport,
                    child: SizedBox(
                      width: side,
                      height: side,
                      child: ClipRect(
                        child: OverflowBox(
                          maxWidth: double.infinity,
                          maxHeight: double.infinity,
                          child: Transform.translate(
                            offset: _offset,
                            child: Transform.scale(
                              scale: _scale,
                              child: _source == null
                                  ? const SizedBox.shrink()
                                  : RawImage(image: _source, width: _source!.width.toDouble()),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SailText.secondary13(_error ?? 'Drag the picture. Scroll to zoom.'),
            SailRow(
              spacing: SailStyleValues.padding08,
              children: [
                SailButton(
                  label: 'Cancel',
                  variant: ButtonVariant.outline,
                  onPressed: () async => Navigator.of(context).pop(),
                ),
                SailButton(
                  label: 'Use the picture',
                  // A click before the decode lands would write an empty
                  // picture, which reads as a real one.
                  disabled: _source == null,
                  onPressed: _use,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
