import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

class DaemonConnectionCard extends StatelessWidget {
  BinaryProvider get _binaryProvider => GetIt.I.get<BinaryProvider>();
  LogProvider get _logProvider => GetIt.I.get<LogProvider>();

  final void Function(String name, String logPath, BinaryType type)? navigateToLogs;
  final RPCConnection connection;
  final SyncInfo? syncInfo;
  final Future<void> Function() restartDaemon;
  final Future<void> Function() stopDaemon;
  final Future<void> Function()? deleteFunction;
  final VoidCallback? onOpenConfConfigurator;

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
    this.onOpenConfConfigurator,
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
              Builder(
                builder: (context) {
                  final hasLogFile = File(connection.binary.logPath()).existsSync();
                  final hasProcessLogs = _logProvider.hasLogsForBinary(connection.binary.type);
                  final hasLogs = hasLogFile || hasProcessLogs;
                  return Tooltip(
                    message: hasLogs ? 'View logs' : 'No logs available yet',
                    child: SailButton(
                      variant: ButtonVariant.ghost,
                      onPressed: () async => navigateToLogs!(
                        connection.binary.binary,
                        connection.binary.logPath(),
                        connection.binary.type,
                      ),
                      disabled: !hasLogs,
                      label: 'View logs',
                    ),
                  );
                },
              ),
              SailButton(
                variant: ButtonVariant.icon,
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (context) => ChainSettingsModal(
                      connection: connection,
                      onOpenConfConfigurator: onOpenConfConfigurator,
                    ),
                  );
                },
                icon: SailSVGAsset.tabSettings,
              ),
              _RestartStopButton(
                binaryName: connection.binary.name,
                isInitializing: connection.initializingBinary || (syncInfo?.downloadInfo.isDownloading ?? false),
                isConnected: connection.connected,
                isStopping: connection.stoppingBinary,
                onRestart: restartDaemon,
                onStop: stopDaemon,
                errorColor: theme.colors.error,
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
          if (infoMessage != null ||
              connection.connectionError != null ||
              connection.startupError != null ||
              connection.initializingBinary ||
              !connection.connected)
            Padding(
              padding: const EdgeInsets.only(top: SailStyleValues.padding04),
              child: SailText.secondary12(
                prettifyLogMessage(
                  infoMessage ??
                      // During initialization, show startup logs instead of connection errors
                      (connection.initializingBinary
                          ? (providerBinary?.startupLogs.lastOrNull?.message ?? 'Initializing...')
                          : connection.connectionError) ??
                      connection.startupError ??
                      (!connection.connected ? 'Not connected' : ''),
                ),
                monospace: true,
              ),
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
    final currentProgress = formatProgress(syncInfo.progressCurrent, syncInfo.downloadInfo.isDownloading);
    final goalProgress = formatProgress(syncInfo.progressGoal, syncInfo.downloadInfo.isDownloading);

    // Check if download just finished but blockchain sync hasn't started yet
    // This happens when progressCurrent is very low (download progress was 0-1)
    // but we're no longer downloading
    final downloadJustFinished = !syncInfo.downloadInfo.isDownloading &&
        syncInfo.downloadInfo.progressPercent >= 1 &&
        syncInfo.progressCurrent <= 1;

    return SailRow(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Tooltip(
            message: syncInfo.downloadInfo.isDownloading
                ? 'Downloading $name\nProgress: $currentProgress MB\nSize: $goalProgress MB'
                : downloadJustFinished
                    ? 'Starting $name...'
                    : '$name\nCurrent height $currentProgress\nHeader height $goalProgress',
            child: SailRow(
              spacing: SailStyleValues.padding08,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!syncInfo.isSynced)
                  Expanded(
                    child: ProgressBar(current: syncInfo.progressCurrent, goal: syncInfo.progressGoal),
                  )
                else if (downloadJustFinished)
                  SailText.secondary12('Finishing up...')
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

String formatProgress(double progress, bool withDecimal) {
  // otherwise return with appropriate decimal places
  return progress.toStringAsFixed(withDecimal ? 1 : 0);
}

class _RestartStopButton extends StatefulWidget {
  final String binaryName;
  final bool isInitializing;
  final bool isConnected;
  final bool isStopping;
  final Future<void> Function() onRestart;
  final Future<void> Function() onStop;
  final Color errorColor;

  const _RestartStopButton({
    required this.binaryName,
    required this.isInitializing,
    required this.isConnected,
    required this.isStopping,
    required this.onRestart,
    required this.onStop,
    required this.errorColor,
  });

  @override
  State<_RestartStopButton> createState() => _RestartStopButtonState();
}

class _RestartStopButtonState extends State<_RestartStopButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    // When initializing and hovering, show stop button instead of spinner
    final showStopOnHover = widget.isInitializing && _isHovering;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showStopOnHover)
            // Show stop button when hovering during initialization
            Tooltip(
              message: 'Stop ${widget.binaryName}',
              child: SailButton(
                variant: ButtonVariant.icon,
                onPressed: widget.onStop,
                loading: widget.isStopping,
                icon: SailSVGAsset.square,
                textColor: widget.errorColor,
              ),
            )
          else ...[
            // Normal restart button
            Tooltip(
              message: 'Restart ${widget.binaryName}',
              child: SailButton(
                variant: ButtonVariant.icon,
                onPressed: widget.onRestart,
                loading: widget.isInitializing,
                icon: SailSVGAsset.iconRestart,
              ),
            ),
            // Show stop button when connected (and not initializing)
            if (widget.isConnected && !widget.isInitializing)
              Tooltip(
                message: 'Stop ${widget.binaryName}',
                child: SailButton(
                  variant: ButtonVariant.icon,
                  onPressed: widget.onStop,
                  loading: widget.isStopping,
                  icon: SailSVGAsset.square,
                  textColor: widget.errorColor,
                ),
              ),
          ],
        ],
      ),
    );
  }
}
