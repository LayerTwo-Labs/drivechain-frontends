import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
        child: _picture() ?? _generated(),
      ),
    );
  }

  /// The picture the user chose. A file they moved or deleted falls back to
  /// the generated avatar instead of an error box.
  Widget? _picture() {
    final path = gradient.picturePath;
    if (path == null || path.isEmpty) {
      return null;
    }
    final file = File(path);
    if (!file.existsSync()) {
      return null;
    }
    return Image.file(
      file,
      fit: BoxFit.cover,
      width: size,
      height: size,
      errorBuilder: (context, error, stack) => _generated(),
    );
  }

  Widget _generated() => SvgPicture.asset(
    'packages/sail_ui/assets/svgs/${gradient.backgroundSvg}',
    fit: BoxFit.cover,
  );
}
