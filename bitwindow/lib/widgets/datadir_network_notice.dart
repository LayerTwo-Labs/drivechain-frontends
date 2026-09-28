import 'dart:async';

import 'package:bitwindow/pages/settings/settings_network.dart';
import 'package:bitwindow/widgets/datadir_network_dialog.dart';
import 'package:bitwindow/widgets/ecash_migration_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

/// Action key the notification carries; see NotificationActions.
const datadirNetworkAction = 'datadir_network';

/// The one stored notice this watcher owns. Its text carries the state, so a
/// state that changes replaces the entry rather than key a second one.
const datadirNoticeId = 'datadir-network';

/// Raises a modal, and then a banner, when the blocks on disk belong to another
/// network than the app runs. The blocks name the chain, and a start on the
/// wrong one rolls the chain back below the wrong fork, which empties the
/// balance until the user reconnects the branch.
class DatadirNetworkWatcher {
  DatadirNetworkWatcher() {
    if (GetIt.I.isRegistered<BitcoinConfProvider>()) {
      _conf = GetIt.I.get<BitcoinConfProvider>();
      _conf!.addListener(_onStateChanged);
    }
    unawaited(_checkUntilAnswered());
  }

  /// How long the watcher waits for the daemon at start before it gives up.
  static const _attempts = 12;
  static const _between = Duration(seconds: 5);

  /// How often the watcher looks again while a warning stands. A conversion
  /// rewrites the block files without a config change, so nothing else tells the
  /// app that the warning moved or went away.
  static const _whileWarned = Duration(seconds: 30);

  Timer? _retry;

  /// The wait a loop stands in, and null while no loop waits.
  Completer<void>? _waking;
  bool _stopped = false;
  bool _asking = false;
  BitcoinConfProvider? _conf;
  NodeModeProvider? _nodeMode;

  /// The watch key of the last answer. A change of the key asks again, so a
  /// config change reaches the check between two polls.
  String _checked = '';

  /// True while the last answer reported a warning. The watcher asks again
  /// until the blocks and the app agree.
  bool _warned = false;

  /// True when a state change arrives while a check runs. That answer describes
  /// the state before the change, so the loop asks again at once.
  bool _stale = false;

  @visibleForTesting
  String get watchedKey => _checked;

  void dispose() {
    _stopped = true;
    _wake();
    _conf?.removeListener(_onStateChanged);
    _nodeMode?.removeListener(_onStateChanged);
  }

  /// A change of the network, of a block path, or of the node mode puts another
  /// answer under the app, so the watcher asks again. Both providers notify
  /// often, and the key keeps that down to one check per real change.
  void _onStateChanged() {
    if (_stopped || _conf == null || datadirWatchKey(_conf!, _nodeMode) == _checked) {
      return;
    }
    // A wait holds the loop for half a minute, and a request holds it for the
    // round trip. Both end with this change, and the loop asks again.
    if (_asking) {
      _stale = true;
      _wake();
      return;
    }
    _wake();
    unawaited(_checkUntilAnswered());
  }

  /// Asks until the answer is current and quiet: the daemon answered, the blocks
  /// and the app agree, and no state change waits. Anything else asks again, so a
  /// quiet app holds no request open while it shuts down.
  Future<void> _checkUntilAnswered() async {
    if (_asking) {
      return;
    }
    _asking = true;
    try {
      var misses = 0;
      while (!_stopped) {
        _stale = false;
        final answered = await check();
        if (answered && !_warned && !_stale) {
          return;
        }
        if (!answered && !_warned && ++misses >= _attempts) {
          // The daemon says nothing at start. A config change asks again, so the
          // watcher holds no request open while the app shuts down.
          return;
        }
        if (_stale) {
          continue;
        }
        // A warning earns the long wait, and a silent daemon the short one.
        await _wait(answered ? _whileWarned : _between);
      }
    } finally {
      _asking = false;
    }
  }

  Future<void> _wait(Duration duration) async {
    final done = Completer<void>();
    _waking = done;
    _retry = Timer(duration, _wake);
    await done.future;
  }

  /// Ends a wait, from the timer or from a state change. The stop path calls it
  /// too, so no loop waits for a timer this watcher already cancelled.
  void _wake() {
    _retry?.cancel();
    _retry = null;
    final done = _waking;
    _waking = null;
    if (done != null && !done.isCompleted) {
      done.complete();
    }
  }

  /// Drops every stored warning of ours. An older build wrote one id per state,
  /// so a user who upgrades carries entries this build no longer words.
  Future<void> _forgetNotices(NotificationProvider provider) async {
    for (final stale
        in provider.history.where((n) => n.id == datadirNoticeId || n.id.startsWith('$datadirNoticeId-')).toList()) {
      await provider.forget(stale.id);
    }
  }

  /// Takes the node mode provider at the first check that finds it. bitwindow
  /// builds this watcher before it registers that provider, so a read in the
  /// constructor finds nothing. The mode decides whether any process reads these
  /// blocks, so a change of it asks again.
  void _attachNodeMode() {
    if (_nodeMode != null || !GetIt.I.isRegistered<NodeModeProvider>()) {
      return;
    }
    _nodeMode = GetIt.I.get<NodeModeProvider>();
    _nodeMode!.addListener(_onStateChanged);
  }

  /// True once the daemon answers, whatever it says.
  Future<bool> check() async {
    if (!GetIt.I.isRegistered<NotificationProvider>() ||
        !GetIt.I.isRegistered<OrchestratorRPC>() ||
        !GetIt.I.isRegistered<BitcoinConfProvider>()) {
      return false;
    }
    final provider = GetIt.I.get<NotificationProvider>();
    final conf = GetIt.I.get<BitcoinConfProvider>();
    _attachNodeMode();
    // The stored notices load in the background. A run over an empty list
    // clears nothing, and the load then puts the stale banner back.
    await provider.ready;
    if (_stopped) {
      return false;
    }
    final key = datadirWatchKey(conf, _nodeMode);

    final GetDatadirNetworkResponse answer;
    try {
      answer = await GetIt.I.get<OrchestratorRPC>().getDatadirNetwork();
    } catch (_) {
      // The daemon answers nothing while it boots. The key stays unrecorded,
      // so a later change of the config asks again.
      return false;
    }
    if (answer.detectedId.isEmpty && answer.magic.isNotEmpty ||
        answer.firstId.isEmpty && answer.firstMagic.isNotEmpty) {
      // An end of the directory carries a magic that no network in hand names.
      // The published catalog names the networks that came after this build, and
      // it lands after the start, so the watcher asks again. Both ends count: a
      // directory the daemon cannot describe holds a warning it cannot word.
      return false;
    }
    _checked = key;

    _warned = answer.mismatch;

    if (!answer.mismatch) {
      await _forgetNotices(provider);
      return true;
    }

    final text = datadirNoticeText(answer, conf);
    final stored = provider.history.where((n) => n.id == datadirNoticeId).firstOrNull;
    if (stored != null && stored.title == text.title && stored.content == text.content) {
      // The same warning stands. A ✕ the user pressed keeps the banner down, and
      // the modal stays shut.
      return true;
    }
    // Whatever stands says something else, so it goes. The replacement earns a
    // fresh banner and a fresh modal.
    await _forgetNotices(provider);
    provider.add(
      id: datadirNoticeId,
      title: text.title,
      content: text.content,
      dialogType: DialogType.error,
      style: NotificationStyle.modalThenBanner,
      action: datadirNetworkAction,
    );
    return true;
  }
}

/// Names the answer the app reads. Core takes the blocks from the blocksdir
/// setting, and from the datadir when the conf names no blocksdir, so a change of
/// either one puts another chain under the app. The key holds the node mode too:
/// light mode reads no blocks, and a move to full mode makes them count again.
String datadirWatchKey(BitcoinConfProvider conf, [NodeModeProvider? nodeMode]) {
  final blocks = conf.currentConfig?.getEffectiveSetting('blocksdir', conf.network.toCoreNetwork()) ?? '';
  return [
    conf.network.name,
    conf.ecashNetworkId,
    conf.detectedDataDir ?? '',
    blocks,
    nodeMode?.mode.name ?? '',
  ].join('\u0000');
}

/// The notice text for one answer. It names the network the app runs either way,
/// because the network on disk alone says nothing about the repair. The banner
/// asks the dialog's own rules, so it never offers a repair the dialog withholds.
({String title, String content}) datadirNoticeText(GetDatadirNetworkResponse answer, BitcoinConfProvider conf) {
  final canSwitch = canSwitchToDetected(conf, answer);
  final canConvert = canConvertBlocks(conf, answer);
  final detected = networkLabel(answer.detectedName, answer.detectedId);
  final selected = networkLabel(answer.selectedName, answer.selectedId);
  final target = networkLabel(answer.convertToName, answer.convertToId);
  if (!answer.mixed) {
    final fix = switch ((canSwitch, canConvert)) {
      (true, true) => 'Switch to $detected, or convert the blocks to $target.',
      (true, false) => 'Switch to $detected.',
      (false, true) => 'Convert the blocks to $target.',
      (false, false) => 'Open this notice to read what to do.',
    };
    return (title: 'The blocks on disk are from $detected', content: 'But you are on $selected. $fix');
  }
  // Either network reads one half of a mixed directory only, so no switch repairs
  // it. The conversion finishes what stopped. The text names both halves: two
  // directories with the same repair are still two states.
  final first = networkLabel(answer.firstName, answer.firstId);
  final halves = '$first and $detected records sit in one directory';
  return (
    title: 'The block files hold two networks',
    content: canConvert ? '$halves. Finish the conversion to $target.' : '$halves, and you are on $selected.',
  );
}

/// Offers the two repairs for a datadir on another network, and runs the one the
/// user picks. False leaves the banner on screen, so a cancelled or failed
/// repair stays visible.
Future<bool> openDatadirNetworkSwitch(BuildContext context, NotificationItem notice) async {
  final conf = GetIt.I.get<BitcoinConfProvider>();

  final answer = await _readDatadirNetwork(context);
  if (answer == null || !context.mounted) {
    return false;
  }
  if (!answer.mismatch) {
    return true;
  }
  // The state can move while the user reads the text, and a repair must go where
  // the text says, never where a later answer points. The text is what the user
  // read, so it is the thing to compare.
  final promise = datadirNoticeText(answer, conf);
  if (promise.title != notice.title || promise.content != notice.content) {
    return _sayTheStateMoved(context);
  }

  final repair = await showThemedDialog<DatadirNetworkRepair>(
    context: context,
    builder: (context) => DatadirNetworkDialog(answer: answer),
  );
  if (repair == null || !context.mounted) {
    return false;
  }

  // The state can also move while the dialog stands open, so the repair asks once
  // more and acts on the answer the user picked from.
  final latest = await _readDatadirNetwork(context);
  if (latest == null || !context.mounted) {
    return false;
  }
  if (!latest.mismatch) {
    return true;
  }
  if (datadirNoticeText(latest, conf) != promise) {
    return _sayTheStateMoved(context);
  }
  if (repair == DatadirNetworkRepair.switchNetwork) {
    return _switchToDetected(context, conf, latest);
  }
  return _convertBlocksToSelected(context, latest);
}

/// Reads what the daemon says about the blocks, and null once it says nothing.
Future<GetDatadirNetworkResponse?> _readDatadirNetwork(BuildContext context) async {
  try {
    return await GetIt.I.get<OrchestratorRPC>().getDatadirNetwork();
  } catch (e) {
    if (context.mounted) {
      showSailToast(
        context,
        'The app could not read the network of your blocks: $e',
        variant: SailToastVariant.destructive,
      );
    }
    return null;
  }
}

/// Tells the user that the answer moved, and leaves the banner on screen.
bool _sayTheStateMoved(BuildContext context) {
  if (context.mounted) {
    showSailToast(context, 'The state moved. Read the new notice.', variant: SailToastVariant.info);
  }
  return false;
}

/// Runs the network the blocks belong to.
Future<bool> _switchToDetected(
  BuildContext context,
  BitcoinConfProvider conf,
  GetDatadirNetworkResponse answer,
) async {
  final option = conf.networkOptions.where((o) => o.id == answer.detectedId).firstOrNull;
  if (option == null) {
    return false;
  }
  await swapNetworkWithDatadirPrompt(context, conf, conf.networkFromOption(option), networkId: option.id);

  // The prompt and the swap page both return nothing, so the chain itself says
  // whether the switch happened. A cancel leaves the notice on screen, and so
  // does a daemon that answers nothing.
  return await datadirNetworkMismatches() == false;
}

/// Rewrites the blocks for the network the app runs. The conversion carries on
/// in the daemon, so the notice stays until the two agree.
Future<bool> _convertBlocksToSelected(BuildContext context, GetDatadirNetworkResponse answer) async {
  if (!await openECashMigration(context, fromId: answer.convertFromId, toId: answer.convertToId)) {
    return false;
  }
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
