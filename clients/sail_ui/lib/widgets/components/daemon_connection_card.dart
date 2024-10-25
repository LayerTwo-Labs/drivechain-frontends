import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class DaemonConnectionCard extends StatelessWidget {
  final void Function(String name, String logPath)? navigateToLogs;
  final RPCConnection connection;
  final VoidCallback restartDaemon;

  final String? infoMessage;

  const DaemonConnectionCard({
    super.key,
    required this.connection,
    required this.infoMessage,
    required this.restartDaemon,
    this.navigateToLogs,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailScaleButton(
      onPressed: navigateToLogs == null ? null : () => navigateToLogs!(connection.binary, connection.logPath),
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
                SailSVG.fromAsset(
                  SailSVGAsset.iconGlobe,
                  color: infoMessage != null
                      ? theme.colors.info
                      : connection.initializingBinary
                          ? theme.colors.orangeLight
                          : connection.connected
                              ? theme.colors.success
                              : theme.colors.error,
                ),
                SailText.primary13('${connection.binary} daemon'),
                Expanded(child: Container()),
                SailScaleButton(
                  onPressed: restartDaemon,
                  child: InitializingDaemonSVG(
                    animate: connection.initializingBinary,
                  ),
                ),
              ],
            ),
            SailText.primary10('View logs', color: theme.colors.textSecondary),
            const SailSpacing(SailStyleValues.padding12),
            SailText.secondary12(
              infoMessage ??
                  connection.connectionError ??
                  (connection.initializingBinary
                      ? 'Initializing...'
                      : connection.connected
                          ? 'Connected'
                          : 'Unknown error occured'),
            ),
          ],
        ),
      ),
    );
  }
}
