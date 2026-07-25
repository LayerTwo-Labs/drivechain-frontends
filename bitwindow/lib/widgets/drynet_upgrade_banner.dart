import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

/// Action key the banner notification carries; see NotificationActions.
const drynetUpgradeAction = 'drynet_upgrade';

/// Raises a banner notification when a newer drynet generation is published.
/// Polls because the backend records it from a detached goroutine after boot.
class DrynetUpgradeWatcher {
  DrynetUpgradeWatcher() {
    unawaited(_check());
    _poll = Timer.periodic(const Duration(seconds: 15), (_) => unawaited(_check()));
  }

  Timer? _poll;

  void dispose() => _poll?.cancel();

  Future<void> _check() async {
    if (!GetIt.I.isRegistered<NotificationProvider>()) return;
    final GetPendingNetworkGenerationResponse pending;
    try {
      pending = await GetIt.I.get<OrchestratorRPC>().getPendingNetworkGeneration();
    } catch (e) {
      return; // Orchestrator not up yet; the next tick retries.
    }
    if (pending.pendingGeneration.isEmpty) return;

    GetIt.I.get<NotificationProvider>().add(
      id: 'drynet-upgrade-${pending.pendingGeneration}',
      title: '${pending.pendingGeneration} is out',
      content: 'Switch over →',
      dialogType: DialogType.info,
      style: NotificationStyle.banner,
      action: drynetUpgradeAction,
    );
  }
}

/// Opens the upgrade flow. Wired to [drynetUpgradeAction] in main.dart.
Future<void> openDrynetUpgrade(BuildContext context) async {
  final GetPendingNetworkGenerationResponse pending;
  try {
    pending = await GetIt.I.get<OrchestratorRPC>().getPendingNetworkGeneration();
  } catch (e) {
    return;
  }
  if (pending.pendingGeneration.isEmpty || !context.mounted) return;

  final onDrynet = GetIt.I.get<BitcoinConfProvider>().network == BitcoinNetwork.BITCOIN_NETWORK_DRYNET;
  await showThemedDialog<bool>(
    context: context,
    builder: (context) => DrynetUpgradeDialog(pending: pending, onDrynet: onDrynet),
  );
}

/// Runs the upgrade flow when a newer generation is published, so entering
/// drynet never lands on a retired one. True means carry on with the swap.
Future<bool> confirmPendingDrynetUpgrade(BuildContext context) async {
  final GetPendingNetworkGenerationResponse pending;
  try {
    pending = await GetIt.I.get<OrchestratorRPC>().getPendingNetworkGeneration();
  } catch (e) {
    return true; // Orchestrator not reachable; the swap itself will report it.
  }
  if (pending.pendingGeneration.isEmpty) return true;

  if (!context.mounted) return false;
  final applied = await showThemedDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => DrynetUpgradeDialog(pending: pending, onDrynet: false),
  );
  return applied == true;
}

/// Spells out what switching generations costs before running it.
class DrynetUpgradeDialog extends StatefulWidget {
  const DrynetUpgradeDialog({super.key, required this.pending, required this.onDrynet});
  final GetPendingNetworkGenerationResponse pending;

  /// Whether drynet is the active network. The snapshot loads into the running
  /// Bitcoin Core, so it is only on offer when that Core is drynet's.
  final bool onDrynet;

  @override
  State<DrynetUpgradeDialog> createState() => _DrynetUpgradeDialogState();
}

class _DrynetUpgradeDialogState extends State<DrynetUpgradeDialog> {
  OrchestratorRPC get _orchestrator => GetIt.I.get<OrchestratorRPC>();

  late bool _useSnapshot = _hasSnapshot;
  String? _error;
  String _progress = '';

  bool get _hasSnapshot => widget.onDrynet && widget.pending.snapshotUrl.isNotEmpty;

  String get _snapshotSize {
    final gb = widget.pending.snapshotSizeBytes.toInt() / (1000 * 1000 * 1000);
    return '${gb.toStringAsFixed(1)} GB';
  }

  Future<void> _upgrade() async {
    setState(() {
      _error = null;
      _progress = widget.onDrynet ? 'Stopping Bitcoin Core and the enforcer...' : 'Switching over...';
    });
    try {
      await _orchestrator.applyPendingNetworkGeneration();
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not switch over: $e');
      return;
    }

    if (_useSnapshot && _hasSnapshot) {
      try {
        await for (final p in _orchestrator.applyUTXOSnapshot(
          url: widget.pending.snapshotUrl,
          sha256: widget.pending.snapshotSha256,
        )) {
          if (!mounted) return;
          setState(() => _progress = p.message);
          if (p.done) break;
        }
      } catch (e) {
        // The generation switch already succeeded, so the upgrade stands;
        // only the fast-sync shortcut failed.
        if (mounted) setState(() => _error = 'Switched over, but the snapshot failed: $e');
        return;
      }
    }

    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final p = widget.pending;
    final busy = _progress.isNotEmpty && _error == null;

    return SailDialog(
      title: 'Switch to ${p.pendingGeneration}',
      subtitle: 'A new drynet is live. ${p.currentGeneration} is being retired.',
      error: _error,
      actions: [
        SailButton(
          label: 'Cancel',
          variant: ButtonVariant.secondary,
          onPressed: () async => Navigator.of(context).pop(false),
        ),
        SailButton(
          label: 'Switch to ${p.pendingGeneration}',
          loading: busy,
          onPressed: _upgrade,
        ),
      ],
      child: SailColumn(
        spacing: SailStyleValues.padding12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailText.primary13(
            '${p.pendingGeneration} is a separate chain, not a continuation of '
            '${p.currentGeneration}. Switching means:',
          ),
          SailText.secondary13(
            '• The ${p.currentGeneration} chain is deleted; ${p.pendingGeneration} syncs from scratch.',
          ),
          SailText.secondary13('• Coins and transactions you had on ${p.currentGeneration} are gone for good.'),
          SailText.secondary13('• Your wallets, addresses and keys are kept.'),
          if (_hasSnapshot)
            SailCheckbox(
              value: _useSnapshot,
              onChanged: busy ? null : (v) => setState(() => _useSnapshot = v),
              label: 'Fast sync from a UTXO snapshot at block ${p.snapshotHeight} ($_snapshotSize download)',
            ),
          if (busy) SailText.secondary12(_progress, color: theme.colors.textSecondary),
        ],
      ),
    );
  }
}
