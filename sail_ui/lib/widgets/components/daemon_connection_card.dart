import 'dart:io';
import 'dart:math' as math;

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
    final downloadProvider = GetIt.I.isRegistered<DownloadProvider>() ? GetIt.I.get<DownloadProvider>() : null;
    if (downloadProvider == null) {
      return _buildCard(context, downloadProgress: null);
    }
    return ListenableBuilder(
      listenable: downloadProvider,
      builder: (context, _) {
        final progress = downloadProvider.statusFor(connection.binary.type);
        return _buildCard(context, downloadProgress: progress);
      },
    );
  }

  Widget _buildCard(BuildContext context, {required DownloadProgress? downloadProgress}) {
    final theme = SailTheme.of(context);
    final providerBinary = _binaryProvider.binaries.firstWhereOrNull(
      (b) => b.name == connection.binary.name,
    );
    final isDownloading = downloadProgress != null;

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
                color: _getConnectionColor(theme, isDownloading: isDownloading),
              ),
              Expanded(child: Container()),
              if (providerBinary != null && providerBinary.updateAvailable)
                SailButton(
                  label: 'Update',
                  onPressed: () async {
                    try {
                      await _binaryProvider.update(providerBinary);
                    } catch (_) {
                      // Errors are visible via the daemon card's connection state.
                    }
                  },
                ),
              Builder(
                builder: (context) {
                  final hasLogFile = File(
                    connection.binary.logPath(),
                  ).existsSync();
                  final hasProcessLogs = _logProvider.hasLogsForBinary(
                    connection.binary.type,
                  );
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
              _StartStopButton(
                binaryName: connection.binary.name,
                isInitializing: connection.initializingBinary || isDownloading,
                isConnected: connection.connected,
                isStopping: connection.stoppingBinary,
                onStart: restartDaemon,
                onStop: stopDaemon,
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
              if (deleteFunction != null)
                SailButton(
                  variant: ButtonVariant.icon,
                  onPressed: deleteFunction,
                  icon: SailSVGAsset.iconDelete,
                ),
            ],
          ),
          // The row stays even with nothing to report, so a card that gains
          // sync info or a download does not grow.
          SizedBox(
            width: 350,
            height: progressRowHeight(context),
            child: downloadProgress != null
                ? DownloadStatusRow(
                    name: connection.binary.name,
                    download: downloadProgress,
                  )
                : syncInfo != null
                ? BlockStatus(
                    name: connection.binary.name,
                    syncInfo: syncInfo!,
                  )
                : null,
          ),
          Padding(
            padding: const EdgeInsets.only(top: SailStyleValues.padding04),
            child: DaemonStatusBlock(
              message: infoMessage != null || connection.connectionError != null || !connection.connected
                  ? prettifyLogMessage(
                      resolveDaemonStatusMessage(
                        connectionError: connection.connectionError,
                        startupError: connection.startupError,
                        infoMessage: infoMessage,
                        initializingBinary: connection.initializingBinary,
                        initializingFallback: providerBinary?.startupLogs.lastOrNull?.message,
                      ),
                    )
                  : '',
            ),
          ),
        ],
      ),
    );
  }

  Color _getConnectionColor(SailThemeData theme, {required bool isDownloading}) => resolveDaemonStatusColor(
    theme: theme,
    connectionError: connection.connectionError,
    startupError: connection.startupError,
    initializingBinary: connection.initializingBinary,
    connected: connection.connected,
    isDownloading: isDownloading,
    hasInfoMessage: infoMessage != null,
  );
}

/// Height of the progress bar itself.
const double progressBarHeight = 16;

/// The style the daemon status text renders in. One style measures and renders,
/// or a block reserves a height the reader never gets.
TextStyle daemonStatusStyle(BuildContext context) {
  final theme = SailTheme.of(context);
  return SailStyleValues.twelve.copyWith(
    color: theme.colors.textSecondary,
    fontFamily: theme.chrome.fontFamily ?? 'IBMPlexMono',
  );
}

/// One rendered row of daemon status text, at the reader's text scale.
double daemonStatusRowHeight(BuildContext context) {
  final painter = TextPainter(
    text: TextSpan(text: ' ', style: daemonStatusStyle(context)),
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.of(context).textScaler.clamp(maxScaleFactor: 2),
  )..layout();
  return painter.preferredLineHeight;
}

/// Height the progress row holds whether or not a daemon reports progress. A
/// synced daemon puts text there instead of a bar, so the row fits both.
double progressRowHeight(BuildContext context) => math.max(progressBarHeight, daemonStatusRowHeight(context));

/// Daemon status in a block that always holds the same height, so a card never
/// resizes as errors come and go. A message taller than the block hides behind
/// "Show more", which the reader opens.
class DaemonStatusBlock extends StatefulWidget {
  /// Rows the block reserves. Three fits the enforcer's error and its two
  /// causes, which is the tallest message the daemons produce.
  static const int rows = 3;

  /// Width the toggle holds. The slot stays even with nothing to open, so the
  /// text wraps at the same point whether or not the toggle is there.
  static const double toggleWidth = 96;

  final String message;

  const DaemonStatusBlock({super.key, required this.message});

  @override
  State<DaemonStatusBlock> createState() => _DaemonStatusBlockState();
}

class _DaemonStatusBlockState extends State<DaemonStatusBlock> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final style = daemonStatusStyle(context);
    final scaler = MediaQuery.of(context).textScaler.clamp(maxScaleFactor: 2);
    final body = widget.message.trim().isEmpty ? null : widget.message.trimRight();

    return LayoutBuilder(
      builder: (context, constraints) {
        final textWidth = (constraints.maxWidth - DaemonStatusBlock.toggleWidth).clamp(1.0, double.infinity);
        final painter = TextPainter(
          text: TextSpan(text: body ?? ' ', style: style),
          maxLines: DaemonStatusBlock.rows,
          textDirection: Directionality.of(context),
          textScaler: scaler,
        )..layout(maxWidth: textWidth);

        final hasMore = body != null && painter.didExceedMaxLines;
        final open = hasMore && _open;
        final text = Text(
          body ?? ' ',
          style: style,
          textScaler: scaler,
          maxLines: open ? null : DaemonStatusBlock.rows,
          overflow: open ? TextOverflow.clip : TextOverflow.ellipsis,
        );

        return SizedBox(
          height: open ? null : daemonStatusRowHeight(context) * DaemonStatusBlock.rows,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: body == null ? text : Tooltip(message: body, child: text),
              ),
              SizedBox(
                width: DaemonStatusBlock.toggleWidth,
                child: hasMore
                    ? Align(
                        alignment: Alignment.topRight,
                        child: SailButton(
                          variant: ButtonVariant.ghost,
                          small: true,
                          padding: EdgeInsets.zero,
                          label: open ? 'Show less' : 'Show more',
                          onPressed: () async => setState(() => _open = !_open),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Renders the in-flight download progress for a daemon. Shown by the
/// DaemonConnectionCard whenever the DownloadProvider has a live entry for
/// this binary — sync state is suppressed because the binary isn't running
/// yet anyway.
class DownloadStatusRow extends StatelessWidget {
  final String name;
  final DownloadProgress download;

  const DownloadStatusRow({
    super.key,
    required this.name,
    required this.download,
  });

  @override
  Widget build(BuildContext context) {
    // A message names work that isn't a plain binary fetch, e.g. the UTXO snapshot.
    final what = download.message.isNotEmpty ? download.message : 'Downloading $name';
    final tooltip = download.mbTotal > 0
        ? '$what\nProgress: ${formatDataSizeFromMB(download.mbDownloaded.toDouble())}\nSize: ${formatDataSizeFromMB(download.mbTotal.toDouble())}'
        : '$what\n${formatDataSizeFromMB(download.mbDownloaded.toDouble())} so far (size unknown)';

    return SailRow(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Tooltip(
            message: tooltip,
            child: SailRow(
              spacing: SailStyleValues.padding08,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ProgressBar(
                    current: download.mbDownloaded.toDouble(),
                    goal: download.mbTotal > 0 ? download.mbTotal.toDouble() : 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Pure function for the daemon-status text precedence. Exposed for testing.
///
/// Real failure signals beat informational hints: a fatal `connectionError`
/// (e.g. enforcer "ZMQ address not reachable") must NOT be masked by a stale
/// `infoMessage` like "Waiting for L1 to sync headers". Order:
///
///  1. connectionError      — explicit RPC/transport failure
///  2. startupError         — warmup message ("Loading block index…")
///  3. infoMessage          — caller-provided hint
///  4. initializing fallback — most recent startup log line, else "Initializing..."
///  5. "Not connected"      — last resort when no other signal exists
@visibleForTesting
String resolveDaemonStatusMessage({
  required String? connectionError,
  required String? startupError,
  required String? infoMessage,
  required bool initializingBinary,
  required String? initializingFallback,
}) {
  if (connectionError != null) {
    return connectionError;
  }
  if (startupError != null) {
    return startupError;
  }
  if (infoMessage != null) {
    return infoMessage;
  }
  if (initializingBinary) {
    return initializingFallback ?? 'Initializing...';
  }
  return 'Not connected';
}

/// Pure function for the daemon-status color precedence. Exposed for testing.
///
/// Precedence (top wins):
///  1. connectionError           -> red    (explicit RPC/transport failure)
///  2. connected                 -> green  (startupError/initializing are ignored once
///                                          the daemon is on the wire — they'd be stale);
///                                  except isDownloading still amber, infoMessage still info
///  3. startupError              -> amber  (warmup message surfaced while !connected)
///  4. initializingBinary        -> amber
///  5. isDownloading             -> amber
///  6. hasInfoMessage            -> info
///  7. !connected, no other info -> amber  (booting, no news — used to flash red)
Color resolveDaemonStatusColor({
  required SailThemeData theme,
  required String? connectionError,
  required String? startupError,
  required bool initializingBinary,
  required bool connected,
  required bool isDownloading,
  required bool hasInfoMessage,
}) {
  if (connectionError != null) {
    return theme.colors.error;
  }
  if (connected) {
    if (isDownloading) {
      return theme.colors.orangeLight;
    }
    if (hasInfoMessage) {
      return theme.colors.info;
    }
    return theme.colors.success;
  }
  if (startupError != null) {
    return theme.colors.orangeLight;
  }
  if (initializingBinary) {
    return theme.colors.orangeLight;
  }
  if (isDownloading) {
    return theme.colors.orangeLight;
  }
  if (hasInfoMessage) {
    return theme.colors.info;
  }
  return theme.colors.orangeLight;
}

class BlockStatus extends StatelessWidget {
  final String name;
  final SyncInfo syncInfo;

  const BlockStatus({super.key, required this.name, required this.syncInfo});

  @override
  Widget build(BuildContext context) {
    final currentProgress = formatProgress(syncInfo.progressCurrent, false);
    final goalProgress = formatProgress(syncInfo.progressGoal, false);

    return SailRow(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Tooltip(
            message:
                '$name\nCurrent height ${formatWithThousandSpacers(currentProgress)}\nHeader height ${formatWithThousandSpacers(goalProgress)}',
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
                  SailText.secondary12('${formatWithThousandSpacers(currentProgress)} sync height'),
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

/// Start or stop one daemon. A reader who wants to bounce a daemon stops it and
/// starts it again, so the head holds one button, not two.
class _StartStopButton extends StatefulWidget {
  final String binaryName;
  final bool isInitializing;
  final bool isConnected;
  final bool isStopping;
  final Future<void> Function() onStart;
  final Future<void> Function() onStop;

  const _StartStopButton({
    required this.binaryName,
    required this.isInitializing,
    required this.isConnected,
    required this.isStopping,
    required this.onStart,
    required this.onStop,
  });

  @override
  State<_StartStopButton> createState() => _StartStopButtonState();
}

class _StartStopButtonState extends State<_StartStopButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    // A daemon that boots offers a way out, so hover swaps the spinner for stop.
    final stops = widget.isConnected || (widget.isInitializing && _hovering);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Tooltip(
        message: stops ? 'Stop ${widget.binaryName}' : 'Start ${widget.binaryName}',
        child: SailButton(
          label: stops ? 'Stop' : 'Start',
          loading: stops ? widget.isStopping : widget.isInitializing,
          onPressed: stops ? widget.onStop : widget.onStart,
        ),
      ),
    );
  }
}
