import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/loaders/progress.dart';
import 'package:sail_ui/widgets/modals/daemon_settings_modal.dart';

class DaemonConnectionCard extends StatelessWidget {
  final void Function(String name, String logPath)? navigateToLogs;
  final RPCConnection connection;
  final SyncInfo? syncInfo;
  final Future<void> Function() restartDaemon;
  final Future<void> Function()? deleteFunction;

  final String? infoMessage;

  const DaemonConnectionCard({
    super.key,
    required this.connection,
    required this.syncInfo,
    required this.infoMessage,
    required this.restartDaemon,
    this.deleteFunction,
    this.navigateToLogs,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailCard(
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
                variant: ButtonVariant.ghost,
                onPressed: () async => navigateToLogs!(connection.binary.binary, connection.logPath),
                label: 'View logs',
              ),
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
                icon: SailSVGAsset.tabSettings,
              ),
              Tooltip(
                message: 'Restart ${connection.binary.name}',
                child: SailButton(
                  variant: ButtonVariant.icon,
                  onPressed: restartDaemon,
                  loading: connection.initializingBinary,
                  icon: SailSVGAsset.iconRestart,
                ),
              ),
              if (deleteFunction != null)
                SailButton(
                  variant: ButtonVariant.icon,
                  onPressed: deleteFunction,
                  icon: SailSVGAsset.iconDelete,
                ),
            ],
          ),
          if (syncInfo != null)
            SizedBox(
              width: 350,
              child: BlockStatus(
                name: connection.binary.name,
                syncInfo: syncInfo!,
              ),
            ),
          SailColumn(
            spacing: SailStyleValues.padding12,
            children: [
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
    );
  }
}

class BlockStatus extends StatelessWidget {
  final String name;
  final SyncInfo syncInfo;

  const BlockStatus({
    super.key,
    required this.name,
    required this.syncInfo,
  });

  @override
  Widget build(BuildContext context) {
    return SailRow(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Tooltip(
            message: '$name\nCurrent height ${syncInfo.blocks}\nHeader height ${syncInfo.headers}',
            child: SailRow(
              spacing: SailStyleValues.padding08,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!syncInfo.isSynced)
                  Expanded(
                    child: ProgressBar(
                      progress: syncInfo.verificationProgress,
                      current: syncInfo.blocks,
                      goal: syncInfo.headers,
                    ),
                  )
                else
                  SailText.secondary12(
                    '${formatWithThousandSpacers(syncInfo.blocks)} sync height',
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
