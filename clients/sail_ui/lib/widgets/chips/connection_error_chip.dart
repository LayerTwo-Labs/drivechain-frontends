import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class ConnectionErrorChip extends StatelessWidget {
  final String chain;
  final Future<void> Function() onPressed;

  const ConnectionErrorChip({
    super.key,
    required this.chain,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailScaleButton(
      onPressed: onPressed,
      child: SailErrorShadow(
        enabled: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            color: theme.colors.error,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: SailStyleValues.padding04,
              horizontal: SailStyleValues.padding10,
            ),
            child: SailRow(
              spacing: SailStyleValues.padding08,
              children: [
                SailSVG.fromAsset(
                  SailSVGAsset.iconGlobe,
                  color: Colors.white,
                ),
                SailText.primary12(
                  'Not connected to $chain',
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
