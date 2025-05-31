import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class ShutdownCard extends StatelessWidget {
  final Binary chain;
  final String message;
  final bool initializing;
  final Future<void> Function() forceCleanup;

  const ShutdownCard({
    super.key,
    required this.chain,
    required this.initializing,
    required this.message,
    required this.forceCleanup,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SizedBox(
      width: 250,
      child: SailBorder(
        padding: const EdgeInsets.symmetric(
          horizontal: SailStyleValues.padding12,
          vertical: SailStyleValues.padding08,
        ),
        child: SailColumn(
          spacing: 0,
          children: [
            SailRow(
              spacing: SailStyleValues.padding08,
              children: [
                SailSVG.fromAsset(SailSVGAsset.iconGlobe, color: theme.colors.orangeLight),
                SailText.primary13('${chain.name} daemon'),
                Expanded(child: Container()),
                SailButton(
                  variant: ButtonVariant.icon,
                  icon: SailSVGAsset.iconRestart,
                  onPressed: forceCleanup,
                  loading: initializing,
                ),
              ],
            ),
            const SailSpacing(SailStyleValues.padding12),
            SailText.secondary12(
              message,
            ),
          ],
        ),
      ),
    );
  }
}
