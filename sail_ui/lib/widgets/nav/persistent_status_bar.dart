import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

/// An error-only banner that surfaces orchestratord / bitwindowd outages on
/// pre-auth screens where the richer [BottomNav] is not mounted.
///
/// Renders [SizedBox.shrink] while everything is booting or running — the
/// banner only appears when a monitored daemon reports a terminal failure
/// (`connectionError != null` and no longer initializing). Tapping Restart
/// re-invokes [BinaryProvider.start] for each failed daemon.
class PersistentStatusBar extends StatelessWidget {
  /// Binary types to monitor. Bitwindow wires up `orchestratord` +
  /// `bitWindow` here; other clients can pass their own pair.
  final List<BinaryType> monitored;

  const PersistentStatusBar({
    super.key,
    this.monitored = const [BinaryType.orchestratord, BinaryType.bitWindow],
  });

  @override
  Widget build(BuildContext context) {
    final binaryProvider = GetIt.I.get<BinaryProvider>();

    return ListenableBuilder(
      listenable: binaryProvider,
      builder: (context, _) {
        final broken = <Binary>[];
        for (final type in monitored) {
          final binary = binaryProvider.binaries.where((b) => b.type == type).firstOrNull;
          if (binary == null) continue;
          if (binaryProvider.isConnected(binary)) continue;
          if (binaryProvider.isInitializing(binary)) continue;
          if (binaryProvider.isStopping(binary)) continue;
          final err = binaryProvider.connectionError(binary);
          if (err == null || err.isEmpty) continue;
          broken.add(binary);
        }

        if (broken.isEmpty) return const SizedBox.shrink();

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
