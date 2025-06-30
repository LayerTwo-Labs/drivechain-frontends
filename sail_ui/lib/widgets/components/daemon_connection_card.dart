import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

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
                color: _getConnectionColor(theme),
              ),
              Expanded(child: Container()),
              SailButton(
                variant: ButtonVariant.ghost,
                onPressed: () async => navigateToLogs!(connection.binary.binary, connection.binary.logPath()),
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
            spacing: 0,
            children: [
              SailSpacing(SailStyleValues.padding04),
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

  Color _getConnectionColor(SailThemeData theme) {
    if (syncInfo != null && syncInfo!.downloadInfo.isDownloading) {
      return theme.colors.orangeLight;
    } else if (infoMessage != null) {
      return theme.colors.info;
    } else if (connection.initializingBinary) {
      return theme.colors.orangeLight;
    } else if (connection.connected) {
      return theme.colors.success;
    } else {
      return theme.colors.error;
    }
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
    final currentProgress = formatProgress(syncInfo.progressCurrent);

    return SailRow(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Tooltip(
            message: syncInfo.downloadInfo.isDownloading
                ? 'Downloading $name\nProgress: $currentProgress MB\nSize: ${formatProgress(syncInfo.progressGoal)} MB'
                : '$name\nCurrent height $currentProgress\nHeader height ${formatProgress(syncInfo.progressGoal)}',
            child: SailRow(
              spacing: SailStyleValues.padding08,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!syncInfo.isSynced)
                  Expanded(
                    child: ProgressBar(
                      current: syncInfo.progressCurrent,
                      goal: syncInfo.progressGoal,
                    ),
                  )
                else
                  SailText.secondary12(
                    syncInfo.downloadInfo.isDownloading
                        ? '${formatWithThousandSpacers(syncInfo.progressCurrent)} MB'
                        : '${formatWithThousandSpacers(currentProgress)} sync height',
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

String formatProgress(double progress) {
  // if progress is a whole number, return it as an integer
  if (progress == progress.toInt()) {
    return progress.toInt().toString();
  }
  // otherwise return with appropriate decimal places
  return progress.toStringAsFixed(1);
}
