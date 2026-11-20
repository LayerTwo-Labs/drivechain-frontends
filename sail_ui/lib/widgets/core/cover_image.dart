import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

/// Decodes [image] at the smallest size that still covers [width] x [height]
/// device pixels, as [BoxFit.cover] draws it. A smaller image decodes as is.
@immutable
class CoverResizeImage extends ImageProvider<CoverResizeImageKey> {
  const CoverResizeImage(
    this.image, {
    required this.width,
    required this.height,
  });

  final ImageProvider image;
  final int width;
  final int height;

  /// The decode size of a [source] image that covers [width] x [height].
  static ui.TargetImageSize targetSize(
    int sourceWidth,
    int sourceHeight,
    int width,
    int height,
  ) {
    final scale = math.max(width / sourceWidth, height / sourceHeight);
    if (scale >= 1) {
      return ui.TargetImageSize(width: sourceWidth, height: sourceHeight);
    }
    return ui.TargetImageSize(
      width: (sourceWidth * scale).ceil(),
      height: (sourceHeight * scale).ceil(),
    );
  }

  @override
  Future<CoverResizeImageKey> obtainKey(ImageConfiguration configuration) {
    return image.obtainKey(configuration).then((key) => CoverResizeImageKey(key, width, height));
  }

  @override
  ImageStreamCompleter loadImage(
    CoverResizeImageKey key,
    ImageDecoderCallback decode,
  ) {
    Future<ui.Codec> decodeCover(
      ui.ImmutableBuffer buffer, {
      ui.TargetImageSizeCallback? getTargetSize,
    }) {
      return decode(
        buffer,
        getTargetSize: (w, h) => targetSize(w, h, width, height),
      );
    }

    return image.loadImage(key.inner, decodeCover);
  }

  @override
  bool operator ==(Object other) =>
      other is CoverResizeImage && other.image == image && other.width == width && other.height == height;

  @override
  int get hashCode => Object.hash(image, width, height);
}

/// The cache key of a [CoverResizeImage].
@immutable
class CoverResizeImageKey {
  const CoverResizeImageKey(this.inner, this.width, this.height);

  final Object inner;
  final int width;
  final int height;

  @override
  bool operator ==(Object other) =>
      other is CoverResizeImageKey && other.inner == inner && other.width == width && other.height == height;

  @override
  int get hashCode => Object.hash(inner, width, height);
}

/// An [Image] that fills its box as [BoxFit.cover] and decodes at the box size.
class CoverImage extends StatelessWidget {
  const CoverImage(this.image, {super.key});

  final ImageProvider image;

  @override
  Widget build(BuildContext context) {
    final ratio = MediaQuery.devicePixelRatioOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        if (!width.isFinite || !height.isFinite) {
          return Image(image: image, fit: BoxFit.cover);
        }
        return Image(
          image: CoverResizeImage(
            image,
            width: math.max(1, (width * ratio).ceil()),
            height: math.max(1, (height * ratio).ceil()),
          ),
          width: width,
          height: height,
          fit: BoxFit.cover,
        );
      },
    );
  }
}
