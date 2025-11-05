import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sail_ui/models/wallet_gradient.dart';

/// SVG-based avatar for wallet visualization
class WalletBlobAvatar extends StatelessWidget {
  final WalletGradient gradient;
  final double size;

  const WalletBlobAvatar({
    super.key,
    required this.gradient,
    this.size = 50,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: SvgPicture.asset(
          'packages/sail_ui/assets/svgs/${gradient.backgroundSvg}',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
