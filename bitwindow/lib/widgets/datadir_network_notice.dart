import 'dart:async';

import 'package:bitwindow/pages/settings/settings_network.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

/// Action key the notification carries; see NotificationActions.
const datadirNetworkAction = 'datadir_network';

const _noticeIdPrefix = 'datadir-network-';

/// Raises a modal, and then a banner, when the blocks on disk belong to another
/// network than the app runs. The blocks name the chain, and a start on the
/// wrong one rolls the chain back below the wrong fork, which empties the
/// balance until the user reconnects the branch.
class DatadirNetworkWatcher {
  DatadirNetworkWatcher() {
    if (GetIt.I.isRegistered<BitcoinConfProvider>()) {
      _conf = GetIt.I.get<BitcoinConfProvider>();
      _conf!.addListener(_onConfChanged);
    }
    unawaited(_checkUntilAnswered());
  }

  /// How long the watcher waits for the daemon at start before it gives up.
  static const _attempts = 12;
  static const _between = Duration(seconds: 5);

  Timer? _retry;
  bool _stopped = false;
  bool _asking = false;
  BitcoinConfProvider? _conf;

  /// The watch key of the last answer. A standing poll would hold a request
  /// open while the app shuts down, so a change of the key asks again instead.
  String _checked = '';

  @visibleForTesting
  String get watchedKey => _checked;

  void dispose() {
    _stopped = true;
    _retry?.cancel();
    _conf?.removeListener(_onConfChanged);
  }

  /// A change of the network or of a block path makes the blocks on disk
  /// another set, so the watcher asks again. The conf provider notifies often,
  /// and the key keeps that down to one check per real change.
  void _onConfChanged() {
    if (_stopped || _conf == null || datadirWatchKey(_conf!) == _checked) {
      return;
    }
    unawaited(_checkUntilAnswered());
  }

  /// Asks until the daemon answers, then stops. A standing timer would hold a
  /// request open while the app shuts down.
  Future<void> _checkUntilAnswered() async {
    if (_asking) {
      return;
    }
    _asking = true;
    try {
      for (var attempt = 0; attempt < _attempts && !_stopped; attempt++) {
        if (await check()) {
          return;
        }
        final wait = Completer<void>();
        _retry = Timer(_between, wait.complete);
        await wait.future;
      }
    } finally {
      _asking = false;
    }
  }

  /// True once the daemon answers, whatever it says.
  Future<bool> check() async {
    if (!GetIt.I.isRegistered<NotificationProvider>() || !GetIt.I.isRegistered<OrchestratorRPC>()) {
      return false;
    }
    final provider = GetIt.I.get<NotificationProvider>();
    // The stored notices load in the background. A run over an empty list
    // clears nothing, and the load then puts the stale banner back.
    await provider.ready;
    if (_stopped) {
      return false;
    }
    final key = _conf == null ? '' : datadirWatchKey(_conf!);

    final GetDatadirNetworkResponse answer;
    try {
      answer = await GetIt.I.get<OrchestratorRPC>().getDatadirNetwork();
    } catch (_) {
      // The daemon answers nothing while it boots. The key stays unrecorded,
      // so a later change of the config asks again.
      return false;
    }
    if (answer.detectedId.isEmpty && answer.magic.isNotEmpty) {
      // The blocks carry a magic that no network in hand names. The published
      // catalog names the networks that came after this build, and it lands
      // after the start, so the watcher asks again.
      return false;
    }
    _checked = key;

    if (!answer.mismatch) {
      await _clear(provider);
      return true;
    }
    await _retireOtherPairs(provider, answer);

    final detected = _name(answer.detectedName, answer.detectedId);
    final selected = _name(answer.selectedName, answer.selectedId);
    provider.add(
      id: datadirNoticeId(provider.history, answer.detectedId, answer.selectedId, DateTime.now()),
      title: 'The blocks on disk are from $detected',
      content: 'You selected $selected. Switch to $detected?',
      dialogType: DialogType.error,
      style: NotificationStyle.modalThenBanner,
      action: datadirNetworkAction,
      data: {'detected': answer.detectedId, 'selected': answer.selectedId},
    );
    return true;
  }

  /// Drops every notice about another pair, read or not. The networks can move
  /// from one mismatch to another and back, so a pair this run retires leaves
  /// no entry, and its return earns a new warning.
  Future<void> _retireOtherPairs(NotificationProvider provider, GetDatadirNetworkResponse answer) async {
    for (final stale
        in provider.history
            .where(
              (n) =>
                  n.id.startsWith(_noticeIdPrefix) &&
                  !(n.data['detected'] == answer.detectedId && n.data['selected'] == answer.selectedId),
            )
            .toList()) {
      await provider.forget(stale.id);
    }
  }

  /// The blocks and the app agree, so every notice of ours describes a state
  /// that no longer holds. The entry goes, and the same mismatch warns again
  /// when it comes back, on this run or on the next start.
  Future<void> _clear(NotificationProvider provider) async {
    for (final stale in provider.history.where((n) => n.id.startsWith(_noticeIdPrefix)).toList()) {
      await provider.forget(stale.id);
    }
  }
}

/// Names the blocks the app reads. Core takes the blocks from the blocksdir
/// setting, and from the datadir when the conf names no blocksdir, so a change
/// of either one puts another chain under the app.
String datadirWatchKey(BitcoinConfProvider conf) {
  final blocks = conf.currentConfig?.getEffectiveSetting('blocksdir', conf.network.toCoreNetwork()) ?? '';
  return [conf.network.name, conf.ecashNetworkId, conf.detectedDataDir ?? '', blocks].join('\u0000');
}

String _name(String displayName, String id) => displayName.isNotEmpty ? displayName : id;

/// The id of the notice for one pair of networks. A mismatch that stands keeps
/// one id, whether the user crossed the banner out or restarted the app, so the
/// modal opens one time. A pair with no entry takes a fresh id, which is how a
/// mismatch that went away and came back earns a new warning.
///
/// The pair lives in the item data, never in the id: a catalog id is free text,
/// and two ids joined by a mark can read as another pair.
String datadirNoticeId(Iterable<NotificationItem> history, String detectedId, String selectedId, DateTime now) {
  final open = history
      .where(
        (n) => n.id.startsWith(_noticeIdPrefix) && n.data['detected'] == detectedId && n.data['selected'] == selectedId,
      )
      .firstOrNull;
  return open?.id ?? '$_noticeIdPrefix${now.microsecondsSinceEpoch}';
}

/// Switches the app to the network the blocks belong to. False leaves the
/// banner on screen, so a cancelled or failed switch stays visible.
Future<bool> openDatadirNetworkSwitch(BuildContext context, NotificationItem notice) async {
  final conf = GetIt.I.get<BitcoinConfProvider>();
  if (conf.hasPrivateBitcoinConf) {
    if (context.mounted) {
      showSailToast(
        context,
        'Your own bitcoin.conf names the network. Change it there, then restart.',
        variant: SailToastVariant.info,
      );
    }
    return false;
  }

  final GetDatadirNetworkResponse answer;
  try {
    answer = await GetIt.I.get<OrchestratorRPC>().getDatadirNetwork();
  } catch (e) {
    if (context.mounted) {
      showSailToast(context, 'Could not read the network of your blocks: $e', variant: SailToastVariant.destructive);
    }
    return false;
  }
  if (!answer.mismatch) {
    return true;
  }
  // The networks can move while the user reads the text, and a switch must go
  // where the text says, never where a later answer points.
  if (notice.data['detected'] != answer.detectedId || notice.data['selected'] != answer.selectedId) {
    if (context.mounted) {
      showSailToast(context, 'The networks moved. Read the new notice.', variant: SailToastVariant.info);
    }
    return false;
  }

  final option = conf.networkOptions.where((o) => o.id == answer.detectedId).firstOrNull;
  if (option == null) {
    if (context.mounted) {
      showSailToast(
        context,
        'This build lists no network named ${answer.detectedId}',
        variant: SailToastVariant.destructive,
      );
    }
    return false;
  }

  if (!context.mounted) {
    return false;
  }
  await swapNetworkWithDatadirPrompt(context, conf, conf.networkFromOption(option), networkId: option.id);

  // The prompt and the swap page both return nothing, so the chain itself says
  // whether the switch happened. A cancel leaves the notice on screen, and so
  // does a daemon that answers nothing.
  return await datadirNetworkMismatches() == false;
}

/// True while the blocks on disk belong to another network than the app runs,
/// false while the two agree, and null when nothing answers.
Future<bool?> datadirNetworkMismatches() async {
  try {
    return (await GetIt.I.get<OrchestratorRPC>().getDatadirNetwork()).mismatch;
  } catch (_) {
    return null;
  }
}
