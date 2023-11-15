import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';

class DaemonConnectionCard extends StatelessWidget {
  final String chainName;
  final String? errorMessage;
  final bool initializing;
  final bool connected;
  final VoidCallback restartDaemon;

  const DaemonConnectionCard({
    super.key,
    required this.chainName,
    required this.initializing,
    required this.connected,
    required this.errorMessage,
    required this.restartDaemon,
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
          spacing: SailStyleValues.padding12,
          children: [
            SailRow(
              spacing: SailStyleValues.padding08,
              children: [
                SailSVG.fromAsset(
                  SailSVGAsset.iconGlobe,
                  color: initializing
                      ? theme.colors.yellow
                      : connected
                          ? theme.colors.success
                          : theme.colors.error,
                ),
                SailText.primary13('$chainName daemon'),
                Expanded(child: Container()),
                SailScaleButton(
                  onPressed: restartDaemon,
                  child: InitializingDaemonSVG(
                    animate: initializing,
                  ),
                ),
              ],
            ),
            SailText.secondary12(
              errorMessage ??
                  (initializing
                      ? 'Initializing...'
                      : connected
                          ? 'Connected'
                          : 'Unknown error occured'),
            ),
          ],
        ),
      ),
    );
  }
}
