import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

class DaemonConnectionCard extends StatelessWidget {
  BinaryProvider get _binaryProvider => GetIt.I.get<BinaryProvider>();

  final void Function(String name, String logPath)? navigateToLogs;
  final RPCConnection connection;
  final SyncInfo? syncInfo;
  final Future<void> Function() restartDaemon;
  final Future<void> Function() stopDaemon;
  final Future<void> Function()? deleteFunction;

  final String? infoMessage;

  const DaemonConnectionCard({
    super.key,
    required this.connection,
    required this.syncInfo,
    required this.infoMessage,
    required this.restartDaemon,
    required this.stopDaemon,
    this.deleteFunction,
    this.navigateToLogs,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final providerBinary = _binaryProvider.binaries.firstWhereOrNull((b) => b.name == connection.binary.name);

    return SailCard(
      child: SailColumn(
        children: [
          SailRow(
            spacing: SailStyleValues.padding08,
            children: [
              SailText.primary15('${connection.binary.name} daemon', bold: true),
              SailSVG.fromAsset(SailSVGAsset.iconConnectionStatus, color: _getConnectionColor(theme)),
              Expanded(child: Container()),
              if (providerBinary != null && providerBinary.updateAvailable)
                SailButton(
                  label: 'Update',
                  onPressed: () async {
                    try {
                      // 1. Download the updated binary
                      await _binaryProvider.download(providerBinary, shouldUpdate: true);

                      // 2. Stop the binary
                      await _binaryProvider.stop(providerBinary);

                      // 3. Start the binary with retry logic (3 attempts, 5 second wait)
                      bool started = false;
                      int attempts = 0;
                      const maxAttempts = 3;
                      const retryDelay = Duration(seconds: 5);

                      while (!started && attempts < maxAttempts) {
                        attempts++;
                        try {
                          await _binaryProvider.start(providerBinary);
                          started = true;
                        } catch (e) {
                          if (attempts < maxAttempts) {
                            // Wait before retry
                            await Future.delayed(retryDelay);
                          } else {
                            // Re-throw the error on final attempt
                            rethrow;
                          }
                        }
                      }
                    } catch (e) {
                      // Handle any errors during the update process
                      // You might want to show a snackbar or dialog here
                    }
                  },
                ),
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
                    builder: (context) => DaemonConnectionDetailsModal(connection: connection),
                  );
                },
                icon: SailSVGAsset.tabSettings,
              ),
              Tooltip(
                message: 'Restart ${connection.binary.name}',
                child: SailButton(
                  variant: ButtonVariant.icon,
                  onPressed: restartDaemon,
                  loading: connection.initializingBinary || (syncInfo?.downloadInfo.isDownloading ?? false),
                  icon: SailSVGAsset.iconRestart,
                ),
              ),
              if (connection.connected)
                Tooltip(
                  message: 'Stop ${connection.binary.name}',
                  child: SailButton(
                    variant: ButtonVariant.icon,
                    onPressed: stopDaemon,
                    loading: connection.stoppingBinary,
                    icon: SailSVGAsset.square,
                    textColor: theme.colors.error,
                  ),
                ),
              if (deleteFunction != null)
                SailButton(variant: ButtonVariant.icon, onPressed: deleteFunction, icon: SailSVGAsset.iconDelete),
            ],
          ),
          if (syncInfo != null)
            SizedBox(
              width: 350,
              child: BlockStatus(name: connection.binary.name, syncInfo: syncInfo!),
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

  const BlockStatus({super.key, required this.name, required this.syncInfo});

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
                    child: ProgressBar(current: syncInfo.progressCurrent, goal: syncInfo.progressGoal),
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
