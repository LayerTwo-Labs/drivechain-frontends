import 'dart:async';

import 'package:bitwindow/main.dart' show rebootBitwindowBackend;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

/// Action key the banner notification carries; see NotificationActions.
const ecashUpgradeAction = 'ecash_upgrade';

/// Id prefix for the upgrade banner, so a fulfilled one can be found again.
const _bannerIdPrefix = 'ecash-upgrade-';

/// Id prefix for the "a new network is published" banner.
const _newNetworkBannerIdPrefix = 'network-available-';

/// Raises a banner notification when a newer eCash network is published.
/// Polls because the backend records it from a detached goroutine after boot.
class ECashUpgradeWatcher {
  ECashUpgradeWatcher() {
    unawaited(_check());
    _poll = Timer.periodic(const Duration(seconds: 15), (_) => unawaited(_check()));
  }

  Timer? _poll;

  void dispose() => _poll?.cancel();

  Future<void> _check() async {
    if (!GetIt.I.isRegistered<NotificationProvider>()) {
      return;
    }
    await _announceNewNetworks();
    final GetPendingNetworkGenerationResponse pending;
    try {
      pending = await GetIt.I.get<OrchestratorRPC>().getPendingNetworkGeneration();
    } catch (e) {
      return; // Orchestrator not up yet; the next tick retries.
    }
    final provider = GetIt.I.get<NotificationProvider>();
    if (pending.pendingNetworkId.isEmpty) {
      // Upgraded some other way, e.g. the settings network selector. Retire the
      // banner rather than keep advertising a network already installed.
      for (final stale in provider.history.where((n) => n.id.startsWith(_bannerIdPrefix) && !n.read).toList()) {
        await provider.markRead(stale.id);
      }
      return;
    }

    provider.add(
      id: '$_bannerIdPrefix${pending.pendingNetworkId}',
      title: '${pending.pendingNetworkId} is out',
      content: 'Switch over →',
      dialogType: DialogType.info,
      style: NotificationStyle.banner,
      action: ecashUpgradeAction,
    );
  }
}

/// Raises one banner per network the catalog added since the last check. The
/// backend only reports a network once, so a poll never repeats a notice.
Future<void> _announceNewNetworks() async {
  final List<NetworkOption> fresh;
  try {
    fresh = await GetIt.I.get<BitcoinConfProvider>().takeNewNetworks();
  } catch (e) {
    return; // Orchestrator not up yet; the next tick retries.
  }
  final provider = GetIt.I.get<NotificationProvider>();
  for (final network in fresh) {
    provider.add(
      id: '$_newNetworkBannerIdPrefix${network.id}',
      title: '${network.displayName} is now available',
      content: 'Pick it in the network selector →',
      dialogType: DialogType.info,
      style: NotificationStyle.banner,
    );
  }
}

/// Opens the upgrade flow. Wired to [ecashUpgradeAction] in main.dart.
/// True once the switch is recorded.
Future<bool> openECashUpgrade(BuildContext context) async {
  final GetPendingNetworkGenerationResponse pending;
  try {
    pending = await GetIt.I.get<OrchestratorRPC>().getPendingNetworkGeneration();
  } catch (e) {
    return false;
  }
  if (pending.pendingNetworkId.isEmpty) {
    return true;
  }
  if (!context.mounted) {
    return false;
  }

  final switched = await showThemedDialog<bool>(
    context: context,
    builder: (context) => ECashUpgradeDialog(pending: pending),
  );
  return switched == true;
}

/// Runs the upgrade flow when a newer network is published, so entering
/// eCash never lands on a retired one. True means carry on with the swap.
Future<bool> confirmPendingECashUpgrade(BuildContext context) async {
  final GetPendingNetworkGenerationResponse pending;
  try {
    pending = await GetIt.I.get<OrchestratorRPC>().getPendingNetworkGeneration();
  } catch (e) {
    return true; // Orchestrator not reachable; the swap itself will report it.
  }
  if (pending.pendingNetworkId.isEmpty) {
    return true;
  }

  if (!context.mounted) {
    return false;
  }
  final applied = await showThemedDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => ECashUpgradeDialog(pending: pending),
  );
  return applied == true;
}

/// Spells out what switching networks costs before running it.
class ECashUpgradeDialog extends StatefulWidget {
  const ECashUpgradeDialog({super.key, required this.pending});
  final GetPendingNetworkGenerationResponse pending;

  @override
  State<ECashUpgradeDialog> createState() => _ECashUpgradeDialogState();
}

class _ECashUpgradeDialogState extends State<ECashUpgradeDialog> {
  OrchestratorRPC get _orchestrator => GetIt.I.get<OrchestratorRPC>();
  Logger get _log => GetIt.I.get<Logger>();

  late GetPendingNetworkGenerationResponse _pending = widget.pending;
  Timer? _refresh;
  String? _error;
  String _progress = '';

  @override
  void initState() {
    super.initState();
    _refresh = Timer.periodic(const Duration(seconds: 5), (_) => unawaited(_reload()));
  }

  @override
  void dispose() {
    _refresh?.cancel();
    super.dispose();
  }

  /// Keeps the dialog on the network that is actually published: the catalog
  /// refresh runs detached and can supersede the one the banner opened with.
  Future<void> _reload() async {
    if (_progress.isNotEmpty) {
      return;
    }
    final GetPendingNetworkGenerationResponse fresh;
    try {
      fresh = await _orchestrator.getPendingNetworkGeneration();
    } catch (e) {
      return;
    }
    if (!mounted || fresh.pendingNetworkId == _pending.pendingNetworkId) {
      return;
    }
    if (fresh.pendingNetworkId.isEmpty) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() => _pending = fresh);
  }

  bool get _hasSnapshot => _pending.snapshotHeight > 0;

  String get _snapshotSize {
    final gb = _pending.snapshotSizeBytes.toInt() / (1000 * 1000 * 1000);
    return '${gb.toStringAsFixed(1)} GB';
  }

  Future<void> _upgrade() async {
    setState(() {
      _error = null;
      _progress = 'Confirming the switch...';
    });
    try {
      await _orchestrator.confirmPendingNetworkGeneration();
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Could not switch over: $e');
      }
      return;
    }

    if (mounted) {
      setState(() => _progress = 'Restarting the backends on ${_pending.pendingNetworkId}...');
    }
    try {
      await rebootBitwindowBackend(_log);
      await NetworkScopedRegistry.clearAll();
    } catch (e) {
      // The switch is recorded and applies on any later start, so this is a
      // restart that needs retrying, not an upgrade that failed.
      if (mounted) {
        setState(() => _error = 'Switched over — restart BitWindow to finish: $e');
      }
      return;
    }

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final p = _pending;
    final busy = _progress.isNotEmpty && _error == null;

    return SailDialog(
      title: 'Switch to ${p.pendingNetworkId}',
      subtitle: 'A new eCash is live. ${p.currentNetworkId} is being retired.',
      error: _error,
      actions: [
        SailButton(
          label: p.userManagedConf ? 'Close' : 'Cancel',
          variant: p.userManagedConf ? ButtonVariant.primary : ButtonVariant.secondary,
          onPressed: () async => Navigator.of(context).pop(false),
        ),
        if (!p.userManagedConf)
          SailButton(
            label: 'Switch to ${p.pendingNetworkId}',
            loading: busy,
            onPressed: _upgrade,
          ),
      ],
      child: SailColumn(
        spacing: SailStyleValues.padding12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailText.primary13(
            '${p.pendingNetworkId} is a separate chain, not a continuation of '
            '${p.currentNetworkId}. Switching means:',
          ),
          SailText.secondary13(
            '• The ${p.currentNetworkId} chain is deleted; ${p.pendingNetworkId} syncs from scratch.',
          ),
          SailText.secondary13('• Coins and transactions you had on ${p.currentNetworkId} are gone for good.'),
          SailText.secondary13('• Your wallets, addresses and keys are kept.'),
          if (_hasSnapshot)
            SailText.secondary13(
              '• The sync starts from a UTXO snapshot at block ${p.snapshotHeight} ($_snapshotSize download).',
            ),
          if (p.userManagedConf) ..._manualSteps(p),
          if (busy) SailText.secondary12(_progress, color: theme.colors.textSecondary),
        ],
      ),
    );
  }

  List<Widget> _manualSteps(GetPendingNetworkGenerationResponse p) => [
    SailText.primary13(
      'Your own bitcoin.conf decides which eCash network this node runs, so the switch is yours to make:',
    ),
    SailText.secondary13('• Set uacomment=ecash-${p.pendingNetworkId} and addnode=${p.pendingPeer} under [main].'),
    SailText.secondary13('• Delete blocks/ and chainstate/ from your eCash datadir.'),
    SailText.secondary13('• Restart BitWindow.'),
  ];
}
