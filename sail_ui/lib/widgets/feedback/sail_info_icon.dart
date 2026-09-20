import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

/// A small info icon. A hover opens a tooltip that says what the value means
/// in plain words.
class SailInfoIcon extends StatelessWidget {
  final String title;
  final String message;
  final double size;

  const SailInfoIcon({
    super.key,
    required this.title,
    required this.message,
    this.size = 14,
  });

  @override
  Widget build(BuildContext context) {
    return SailTooltip(
      title: title,
      message: message,
      maxWidth: 360,
      showDuration: null,
      child: SailSVG.fromAsset(
        SailSVGAsset.iconInfo,
        color: SailTheme.of(context).colors.inactiveNavText,
        width: size,
      ),
    );
  }
}
