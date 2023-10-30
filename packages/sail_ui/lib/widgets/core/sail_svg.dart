import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sail_ui/style/style.dart';
import 'package:sail_ui/theme/theme.dart';

enum SailSVGAsset {
  iconDashboardTab,

  iconCopy,
}

/// If you don't want to overwrite the color of the svg, put it in here!
// useful for svgs that already have a color like red or blue, that are
// not supposed to be the same color of the text, or ones that have
// multiple colors
const coloredAssets = [];

class SailSVG {
  static Widget icon(
    SailSVGAsset asset, {
    bool isHighlighted = false,
  }) {
    return Builder(
      builder: (context) {
        final colors = SailTheme.of(context).colors;

        return SailSVG._fromAsset(
          asset,
          color: coloredAssets.contains(asset) ? null : (isHighlighted ? colors.orange : colors.icon),
          height: SailStyleValues.iconSizePrimary,
        );
      },
    );
  }

  static SvgPicture _fromAsset(
    SailSVGAsset asset, {
    double? height,
    double? width,
    Color? color,
  }) {
    return SvgPicture.asset(
      asset.toAssetPath(),
      package: 'sail_ui',
      width: width,
      color: color,
      height: height,
    );
  }
}

extension AsAssetPath on SailSVGAsset {
  String toAssetPath() {
    switch (this) {
      case SailSVGAsset.iconDashboardTab:
        return 'assets/svgs/icon_dashboard_tab.svg';

      case SailSVGAsset.iconCopy:
        return 'assets/svgs/icon_copy.svg';
    }
  }
}
