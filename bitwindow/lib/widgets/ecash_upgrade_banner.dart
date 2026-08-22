import 'dart:async';

import 'package:bitwindow/main.dart' show rebootBitwindowBackend;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

/// What a move between two eCash networks does to the chain on disk. The
/// backend rewinds to the block both networks share, so the blocks below it
/// stay and only the new fork downloads. It never deletes chain data.
String ecashChainCostLine(PlanECashSwitchResponse? plan, String fromId, String toId, {bool manualConf = false}) {
  if (plan != null && plan.blocked) {
    return '\u2022 This switch cannot run: neither network publishes the fork height '
        'that says where the chains part.';
  }
  // A manual switch has no backend to rewind for it: the steps below tell the
  // user to move the chain themselves.
  if (!manualConf && plan != null && plan.needsRollback) {
    return '\u2022 The chain rewinds to block ${plan.rewindHeight}. Blocks below it are kept, '
        'so only $toId\u2019s own blocks download.';
  }
  return '\u2022 $toId syncs from the block it shares with $fromId.';
}

/// Asks before a move between two eCash networks and states what it costs.
/// Returns false when the user backs out.
Future<bool> confirmECashSwitch(BuildContext context, String toId) async {
  if (toId.isEmpty) {
    return true;
  }
  // A plan we could not read is not a plan we may skip: the switch itself still
  // runs, and it can be the one that deletes the chain. Ask with the worst case
  // named instead.
  PlanECashSwitchResponse? plan;
  try {
    plan = await GetIt.I.get<BitcoinConfProvider>().planECashSwitch(toId);
  } catch (e) {
    plan = null;
  }
  if (plan != null && (plan.fromId.isEmpty || plan.fromId == plan.toId)) {
    return true;
  }
  if (!context.mounted) {
    return false;
  }
  final fromId = plan?.fromId ?? 'the current network';
  // The backend refuses a blocked switch, so the dialog states it and offers
  // no button that would fail.
  final blocked = plan?.blocked ?? false;
  final go = await showThemedDialog<bool>(
    context: context,
    builder: (context) => SailDialog(
      title: 'Switch to $toId',
      subtitle: '$toId is a separate chain, not a continuation of $fromId.',
      actions: [
        SailButton(
          label: blocked ? 'Close' : 'Cancel',
          variant: blocked ? ButtonVariant.primary : ButtonVariant.secondary,
          onPressed: () async => Navigator.of(context).pop(false),
        ),
        if (!blocked) SailButton(label: 'Switch to $toId', onPressed: () async => Navigator.of(context).pop(true)),
      ],
      child: SailColumn(
        spacing: SailStyleValues.padding12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailText.secondary13(ecashChainCostLine(plan, fromId, toId)),
          SailText.secondary13('\u2022 Coins and transactions you had on $fromId are gone for good.'),
          SailText.secondary13('\u2022 Your wallets, addresses and keys are kept.'),
        ],
      ),
    ),
  );
  return go == true;
}

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
/// What the pending-upgrade prompt did, which decides whether a pick the user
/// started with is still the one to act on.
enum ECashUpgradeOutcome {
  /// Nothing was pending. The caller carries on with its own pick.
  none,

  /// The prompt switched networks. That move supersedes the caller's pick: the
  /// row it started from is the one the user just left.
  applied,

  /// The user backed out.
  cancelled,
}

Future<ECashUpgradeOutcome> confirmPendingECashUpgrade(BuildContext context) async {
  final GetPendingNetworkGenerationResponse pending;
  try {
    pending = await GetIt.I.get<OrchestratorRPC>().getPendingNetworkGeneration();
  } catch (e) {
    // Orchestrator not reachable; the swap itself will report it.
    return ECashUpgradeOutcome.none;
  }
  if (pending.pendingNetworkId.isEmpty) {
    return ECashUpgradeOutcome.none;
  }

  if (!context.mounted) {
    return ECashUpgradeOutcome.cancelled;
  }
  final applied = await showThemedDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => ECashUpgradeDialog(pending: pending),
  );
  return applied == true ? ECashUpgradeOutcome.applied : ECashUpgradeOutcome.cancelled;
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

  /// The backend's plan for this move, which says whether the chain rewinds to
  /// the fork or resyncs. Null until it answers.
  PlanECashSwitchResponse? _plan;

  /// True when the backend reports the switch cannot run, so the dialog offers
  /// no button that would fail.
  bool get _blocked => _plan?.blocked ?? false;

  @override
  void initState() {
    super.initState();
    unawaited(_readPlan());
    _refresh = Timer.periodic(const Duration(seconds: 5), (_) => unawaited(_reload()));
  }

  Future<void> _readPlan() async {
    final id = _pending.pendingNetworkId;
    if (id.isEmpty) {
      return;
    }
    try {
      final plan = await GetIt.I.get<BitcoinConfProvider>().planECashSwitch(id);
      // A refresh can publish another network while this is in flight. The
      // late answer prices the network the dialog no longer names, and the
      // user would confirm a resync after a rewind was promised.
      if (mounted && id == _pending.pendingNetworkId) {
        setState(() => _plan = plan);
      }
    } catch (e) {
      _log.w('ECashUpgradeDialog: could not plan the switch: $e');
    }
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
    // The plan belongs to the network on screen, so it goes stale with it.
    setState(() {
      _pending = fresh;
      _plan = null;
    });
    unawaited(_readPlan());
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
    // The backend refuses a blocked switch, so offering the button would send
    // the user into a failure it already knows about.
    final blocked = _blocked;

    return SailDialog(
      title: 'Switch to ${p.pendingNetworkId}',
      subtitle: 'A new eCash is live. ${p.currentNetworkId} is being retired.',
      error: _error,
      actions: [
        SailButton(
          label: p.userManagedConf || blocked ? 'Close' : 'Cancel',
          variant: p.userManagedConf || blocked ? ButtonVariant.primary : ButtonVariant.secondary,
          onPressed: () async => Navigator.of(context).pop(false),
        ),
        if (!p.userManagedConf && !blocked)
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
            ecashChainCostLine(_plan, p.currentNetworkId, p.pendingNetworkId, manualConf: p.userManagedConf),
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
    if (_plan != null && _plan!.rewindHeight > 0)
      SailText.secondary13(
        '• Roll the chain back to block ${_plan!.rewindHeight} from the Chain tab. Keep blocks/ and '
        'chainstate/ — every block below that one is shared with ${p.pendingNetworkId}.',
      ),
    SailText.secondary13('• Restart BitWindow.'),
  ];
}
