import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/modals/daemon_settings_modal.dart';

class DaemonConnectionCard extends StatelessWidget {
  final void Function(String name, String logPath)? navigateToLogs;
  final RPCConnection connection;
  final Future<void> Function() restartDaemon;
  final Future<void> Function()? deleteFunction;

  final String? infoMessage;

  const DaemonConnectionCard({
    super.key,
    required this.connection,
    required this.infoMessage,
    required this.restartDaemon,
    this.deleteFunction,
    this.navigateToLogs,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SelectionArea(
      child: SailShadow(
        child: Material(
          borderRadius: SailStyleValues.borderRadius,
          clipBehavior: Clip.hardEdge,
          child: SailColumn(
            children: [
              SailRow(
                spacing: SailStyleValues.padding08,
                children: [
                  SailText.primary15(
                    '${connection.binary.name} daemon',
                    bold: true,
                  ),
                  SailSVG.fromAsset(
                    SailSVGAsset.iconConnectionStatus,
                    color: infoMessage != null
                        ? theme.colors.info
                        : connection.initializingBinary
                            ? theme.colors.orangeLight
                            : connection.connected
                                ? theme.colors.success
                                : theme.colors.error,
                  ),
                  Expanded(child: Container()),
                  SailButton(
                    variant: ButtonVariant.icon,
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (context) => DaemonConnectionDetailsModal(
                          connection: connection,
                        ),
                      );
                    },
                    loading: connection.initializingBinary,
                    icon: SailSVGAsset.iconTabSettings,
                  ),
                  SailButton(
                    variant: ButtonVariant.icon,
                    onPressed: restartDaemon,
                    loading: connection.initializingBinary,
                    icon: SailSVGAsset.iconRestart,
                  ),
                  if (deleteFunction != null)
                    SailButton(
                      variant: ButtonVariant.icon,
                      onPressed: deleteFunction,
                      icon: SailSVGAsset.iconDelete,
                    ),
                ],
              ),
              SailColumn(
                spacing: SailStyleValues.padding12,
                children: [
                  SelectionContainer.disabled(
                    child: MouseRegion(
                      cursor: navigateToLogs == null ? MouseCursor.defer : SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: navigateToLogs == null
                            ? null
                            : () => navigateToLogs!(connection.binary.binary, connection.logPath),
                        child: SailText.primary10(
                          'View logs',
                          color: theme.colors.textSecondary,
                          underline: true,
                        ),
                      ),
                    ),
                  ),
                  if (infoMessage != null || connection.connectionError != null)
                    SailText.secondary12(
                      infoMessage ??
                          connection.connectionError ??
                          (connection.initializingBinary
                              ? 'Initializing...'
                              : connection.connected
                                  ? ''
                                  : 'Unknown error occured'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
