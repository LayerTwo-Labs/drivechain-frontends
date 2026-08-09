import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders a background SVG from sail_ui's bundled assets by filename,
/// e.g. one of [WalletGradient.allBackgrounds].
class BackgroundSvg extends StatelessWidget {
  final String filename;
  final BoxFit fit;

  const BackgroundSvg(this.filename, {super.key, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset('packages/sail_ui/assets/svgs/$filename', fit: fit);
  }
}
