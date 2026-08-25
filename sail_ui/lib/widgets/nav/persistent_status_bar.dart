import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

/// An error-only banner that surfaces orchestratord / bitwindowd outages on
/// pre-auth screens where the richer [BottomNav] is not mounted.
///
/// Renders [SizedBox.shrink] while everything is booting or running — the
/// banner only appears when a monitored daemon reports a terminal failure
/// (`connectionError != null` and no longer initializing). Tapping Restart
/// re-invokes [BinaryProvider.start] for each failed daemon, and Send Logs To
/// Devs shows the shared log file in the file manager.
class PersistentStatusBar extends StatelessWidget {
  /// Binary types to monitor. Bitwindow wires up `orchestratord` +
  /// `bitWindow` here; other clients can pass their own pair.
  final List<BinaryType> monitored;

  const PersistentStatusBar({
    super.key,
    this.monitored = const [BinaryType.BINARY_TYPE_ORCHESTRATORD, BinaryType.BINARY_TYPE_BITWINDOWD],
  });

  /// orchestratord maps to no RPCConnection, so its outage reads from the
  /// poll that already watches it.
  static bool _orchestratorDown() {
    if (!GetIt.I.isRegistered<BackendStateProvider>()) {
      return false;
    }
    return !GetIt.I.get<BackendStateProvider>().orchestratorReachable;
  }

  static bool _isDown(BinaryProvider binaryProvider, Binary binary) {
    if (binaryProvider.isConnected(binary) ||
        binaryProvider.isInitializing(binary) ||
        binaryProvider.isStopping(binary)) {
      return false;
    }
    final err = binaryProvider.connectionError(binary);
    if (err != null && err.isNotEmpty) {
      return true;
    }
    return binary.type == BinaryType.BINARY_TYPE_ORCHESTRATORD && _orchestratorDown();
  }

  @override
  Widget build(BuildContext context) {
    final binaryProvider = GetIt.I.get<BinaryProvider>();
    final backendState = GetIt.I.isRegistered<BackendStateProvider>() ? GetIt.I.get<BackendStateProvider>() : null;

    return ListenableBuilder(
      listenable: backendState == null ? binaryProvider : Listenable.merge([binaryProvider, backendState]),
      builder: (context, _) {
        final broken = <Binary>[];
        for (final type in monitored) {
          final binary = binaryProvider.binaries.where((b) => b.type == type).firstOrNull;
          if (binary == null) {
            continue;
          }
          if (!_isDown(binaryProvider, binary)) {
            continue;
          }
          broken.add(binary);
        }

        if (broken.isEmpty) {
          return const SizedBox.shrink();
        }

        final label = broken.length == 1
            ? '${broken.first.name} is down'
            : '${broken.map((b) => b.name).join(' + ')} are down';

        return Material(
          color: SailColorScheme.red.withValues(alpha: 0.15),
          child: SizedBox(
            height: 36,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: SailColorScheme.red.withValues(alpha: 0.5)),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, size: 16, color: SailColorScheme.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SailText.primary12(label, color: SailColorScheme.red),
                    ),
                    SailButton(
                      label: 'Send Logs To Devs',
                      small: true,
                      variant: ButtonVariant.outline,
                      onPressed: openLogs,
                    ),
                    const SizedBox(width: 8),
                    SailButton(
                      label: 'Restart',
                      small: true,
                      variant: ButtonVariant.ghost,
                      onPressed: () async {
                        for (final binary in broken) {
                          await binaryProvider.restart(binary);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
