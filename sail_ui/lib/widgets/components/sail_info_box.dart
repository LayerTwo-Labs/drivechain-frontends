import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

enum InfoType { info, warn, error }

class SailInfoBox extends StatelessWidget {
  final String text;
  final bool secondary;
  final InfoType type;
  final Future<void> Function()? onPressed;
  final bool withoutPadding;

  const SailInfoBox({
    super.key,
    required this.text,
    required this.type,
    this.onPressed,
    this.secondary = false,
    this.withoutPadding = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final content = SailRow(
      spacing: SailStyleValues.padding12,
      children: [
        iconFromType(type, context),
        Expanded(child: onPressed != null ? SailText.primary15(text) : SailText.primary13(text)),
        if (onPressed != null) SailSVG.fromAsset(SailSVGAsset.arrowRight, color: theme.colors.text),
      ],
    );

    return Container(
      padding: withoutPadding ? EdgeInsets.zero : const EdgeInsets.all(SailStyleValues.padding20),
      decoration: BoxDecoration(
        color: secondary ? theme.colors.background : theme.colors.backgroundSecondary,
        borderRadius: SailStyleValues.borderRadius,
      ),
      child: onPressed != null ? SailButton(onPressed: onPressed, label: text, variant: ButtonVariant.icon) : content,
    );
  }

  static Widget iconFromType(InfoType type, BuildContext context) {
    switch (type) {
      case InfoType.info:
        return SailSVG.fromAsset(SailSVGAsset.info, color: SailColorScheme.blue, width: 15);
      case InfoType.warn:
        return SailSVG.fromAsset(SailSVGAsset.messageCircleWarning, color: SailColorScheme.orange, width: 15);
      case InfoType.error:
        return SailSVG.fromAsset(SailSVGAsset.x, color: SailColorScheme.red, width: 15);
    }
  }
}
