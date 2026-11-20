import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sail_ui/widgets/core/cover_image.dart';
import 'package:sidechain_core/models/wallet_gradient.dart';

/// SVG-based avatar for wallet visualization
class WalletBlobAvatar extends StatelessWidget {
  final WalletGradient gradient;
  final double size;

  const WalletBlobAvatar({super.key, required this.gradient, this.size = 50});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: _picture(context) ?? _GeneratedAvatar(svg: gradient.backgroundSvg, size: size),
      ),
    );
  }

  /// The picture the user chose. A file they moved or deleted falls back to
  /// the generated avatar instead of an error box.
  Widget? _picture(BuildContext context) {
    final path = gradient.picturePath;
    if (path == null || path.isEmpty) {
      return null;
    }
    final file = File(path);
    if (!file.existsSync()) {
      return null;
    }
    final pixels = math.max(1, (size * MediaQuery.devicePixelRatioOf(context)).ceil());
    return Image(
      image: CoverResizeImage(FileImage(file), width: pixels, height: pixels),
      fit: BoxFit.cover,
      width: size,
      height: size,
      errorBuilder: (context, error, stack) => _GeneratedAvatar(svg: gradient.backgroundSvg, size: size),
    );
  }
}

/// The background SVGs hold one large embedded picture, so the avatar draws a
/// copy rendered at its own pixel size.
class _GeneratedAvatar extends StatefulWidget {
  const _GeneratedAvatar({required this.svg, required this.size});

  final String? svg;
  final double size;

  @override
  State<_GeneratedAvatar> createState() => _GeneratedAvatarState();
}

class _GeneratedAvatarState extends State<_GeneratedAvatar> {
  ui.Image? _image;
  Object? _error;
  AvatarRasterKey? _key;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
  }

  @override
  void didUpdateWidget(_GeneratedAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _resolve();
  }

  void _resolve() {
    final key = AvatarRasterKey(
      asset: 'packages/sail_ui/assets/svgs/${widget.svg}',
      pixels: math.max(1, (widget.size * MediaQuery.devicePixelRatioOf(context)).ceil()),
    );
    if (key == _key) {
      return;
    }
    _key = key;
    _error = null;
    _image = AvatarRasterCache.instance.done(key);
    if (_image != null) {
      return;
    }
    AvatarRasterCache.instance
        .load(key)
        .then(
          (image) {
            if (mounted && _key == key) {
              setState(() => _image = image);
            }
          },
          onError: (Object error) {
            if (mounted && _key == key) {
              setState(() => _error = error);
            }
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return SvgPicture.asset(_key!.asset, fit: BoxFit.cover);
    }
    return RawImage(image: _image, width: widget.size, height: widget.size, fit: BoxFit.fill);
  }
}

/// One avatar SVG at one square pixel size.
@immutable
class AvatarRasterKey {
  const AvatarRasterKey({required this.asset, required this.pixels});

  final String asset;
  final int pixels;

  @override
  bool operator ==(Object other) => other is AvatarRasterKey && other.asset == asset && other.pixels == pixels;

  @override
  int get hashCode => Object.hash(asset, pixels);
}

/// Avatar SVGs rendered once per pixel size, as [BoxFit.cover] draws them.
class AvatarRasterCache {
  AvatarRasterCache._();

  static final instance = AvatarRasterCache._();

  final _loads = <AvatarRasterKey, Future<ui.Image>>{};
  final _done = <AvatarRasterKey, ui.Image>{};

  /// The rendered image of [key], if it is ready.
  ui.Image? done(AvatarRasterKey key) => _done[key];

  /// Renders [key] one time. A failed render tries again on the next call.
  Future<ui.Image> load(AvatarRasterKey key) {
    return _loads.putIfAbsent(key, () async {
      try {
        final image = await _render(key);
        _done[key] = image;
        return image;
      } catch (_) {
        _loads.removeWhere((k, _) => k == key);
        rethrow;
      }
    });
  }

  static Future<ui.Image> _render(AvatarRasterKey key) async {
    final info = await vg.loadPicture(SvgAssetLoader(key.asset), null);
    try {
      final px = key.pixels.toDouble();
      final scale = math.max(px / info.size.width, px / info.size.height);
      final recorder = ui.PictureRecorder();
      Canvas(recorder)
        ..translate((px - info.size.width * scale) / 2, (px - info.size.height * scale) / 2)
        ..scale(scale)
        ..drawPicture(info.picture);
      final picture = recorder.endRecording();
      try {
        return await picture.toImage(key.pixels, key.pixels);
      } finally {
        picture.dispose();
      }
    } finally {
      info.picture.dispose();
    }
  }
}
