import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

/// Daemon-status entry for the CPU miner. Shaped like [DaemonConnectionCard],
/// but the miner is in-process and carries no RPCConnection or BinaryType.
class MiningStatusCard extends StatelessWidget {
  final MiningProvider mining;
  final VoidCallback? onViewLogs;
  final VoidCallback? onOpenSettings;

  const MiningStatusCard({
    super.key,
    required this.mining,
    this.onViewLogs,
    this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return ListenableBuilder(
      listenable: mining,
      builder: (context, _) {
        final statusColor = resolveDaemonStatusColor(
          theme: theme,
          connectionError: mining.error,
          startupError: null,
          initializingBinary: false,
          connected: mining.isMining,
          isDownloading: false,
          hasInfoMessage: false,
        );

        return SailCard(
          child: SailColumn(
            children: [
              SailRow(
                spacing: SailStyleValues.padding08,
                children: [
                  SailText.primary15('CPU Mining', bold: true),
                  SailSVG.fromAsset(SailSVGAsset.iconConnectionStatus, color: statusColor),
                  Expanded(child: Container()),
                  Tooltip(
                    message: 'View logs',
                    child: SailButton(
                      variant: ButtonVariant.ghost,
                      onPressed: () async => onViewLogs?.call(),
                      disabled: onViewLogs == null,
                      label: 'View logs',
                    ),
                  ),
                  SailButton(
                    variant: ButtonVariant.icon,
                    onPressed: () async => onOpenSettings?.call(),
                    disabled: onOpenSettings == null,
                    icon: SailSVGAsset.tabSettings,
                  ),
                  _StartStopButton(mining: mining),
                ],
              ),
              SizedBox(
                width: 350,
                child: MiningRateStatus(mining: mining),
              ),
              if (mining.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: SailStyleValues.padding04),
                  child: SailText.secondary12(prettifyLogMessage(mining.error!), monospace: true),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Occupies the slot where [BlockStatus] sits on binary-backed cards: a miner
/// has no chain height, so it reports hash rate and blocks found.
class MiningRateStatus extends StatelessWidget {
  final MiningProvider mining;

  const MiningRateStatus({super.key, required this.mining});

  @override
  Widget build(BuildContext context) {
    if (!mining.isMining) {
      return SailText.secondary12('Not mining');
    }

    final blocks = mining.blocksFound;
    return Tooltip(
      message: 'CPU Mining\nHash rate ${mining.formattedHashRate}\nBlocks found $blocks',
      child: SailRow(
        spacing: SailStyleValues.padding08,
        children: [
          SailText.secondary12(mining.formattedHashRate),
          SailText.secondary12(blocks == 1 ? '1 block found' : '$blocks blocks found'),
        ],
      ),
    );
  }
}

class _StartStopButton extends StatefulWidget {
  final MiningProvider mining;

  const _StartStopButton({required this.mining});

  @override
  State<_StartStopButton> createState() => _StartStopButtonState();
}

class _StartStopButtonState extends State<_StartStopButton> {
  bool _busy = false;

  Future<void> _toggle() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      if (widget.mining.isMining) {
        await widget.mining.stopMining();
      } else {
        await widget.mining.startMining();
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_busy) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: SailStyleValues.padding08),
        child: SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    final isMining = widget.mining.isMining;
    return Tooltip(
      message: isMining ? 'Stop mining' : 'Start mining',
      child: SailButton(
        variant: ButtonVariant.icon,
        onPressed: _toggle,
        icon: isMining ? SailSVGAsset.square : SailSVGAsset.pickaxe,
      ),
    );
  }
}
