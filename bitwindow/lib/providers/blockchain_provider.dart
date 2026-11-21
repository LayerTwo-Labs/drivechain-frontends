import 'dart:async';

import 'package:bitwindow/providers/peers_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/env.dart';
import 'package:sidechain_core/gen/bitcoin/bitcoind/v1alpha/bitcoin.pb.dart';
import 'package:sidechain_core/rpcs/stream_supervisor.dart';
import 'package:sidechain_core/sidechain_core.dart';
import 'package:sail_ui/sail_ui.dart';

class BlockchainProvider extends ChangeNotifier implements NetworkScoped {
  @override
  Future<void> onNetworkChanged() async {
    clear();
  }

  Logger get log => GetIt.I.get<Logger>();
  BitwindowRPC get bitwindowd => GetIt.I.get<BitwindowRPC>();
  OrchestratorRPC get _orchestrator => GetIt.I.get<OrchestratorRPC>();
  BitcoindConnection get mainchain => GetIt.I.get<BitcoindConnection>();
  EnforcerRPC get enforcer => GetIt.I.get<EnforcerRPC>();
  SyncProvider get syncProvider => GetIt.I.get<SyncProvider>();

  // raw data go here
  int peerCount = 0;
  List<Block> blocks = [];
  List<RecentTransaction> recentTransactions = [];

  List<String> errors = [];
  bool hasMoreBlocks = true;
  bool isLoadingMoreBlocks = false;
  Set<int> loadedBlockHeights = {};

  static const _fetchInterval = Duration(seconds: 5);
  bool _isFetching = false;

  /// Last error text printed. A daemon that boots fails the same way on every
  /// tick, and the console holds one copy of it.
  String? _loggedError;
  Timer? _fetchTimer;

  StreamSupervisor<WatchRecentTransactionsResponse>? _recentWatch;

  /// Fires when [recentTransactions] changes. That change does not notify the
  /// listeners of the provider, so a new mempool tx rebuilds only what shows it.
  Listenable get recentChanged => _recentChanged;
  final _recentChanged = _Signal();

  /// The newest streamed list. A clear drops it, so the poll reads until the
  /// next frame.
  List<RecentTransaction>? _streamedRecent;
  int _recentFrames = 0;

  /// True while the stream, and not the poll, gives [recentTransactions].
  bool get _streamsRecent => (_recentWatch?.isHealthy ?? false) && _streamedRecent != null;

  final bool _streamRecent;

  BlockchainProvider({bool? streamRecent}) : _streamRecent = streamRecent ?? !Environment.isInTest {
    _startFetchTimer();
    mainchain.addListener(fetch);
    bitwindowd.addListener(fetch);
    enforcer.addListener(fetch);
    syncProvider.addListener(_onSyncChanged);
  }

  /// The mainchain sync fields that listeners read through [syncProvider].
  (bool?, double?, Timestamp?) _mainchainSync = (null, null, null);

  /// The mainchain tip that [blocks] were read at. The list changes only with the tip.
  (double, Timestamp?)? _blocksTip;

  (double, Timestamp?)? get _mainchainTip {
    final info = syncProvider.mainchainSyncInfo;
    return info == null ? null : (info.progressCurrent, info.lastBlockAt);
  }

  /// Runs the stream only while the poll would read the list.
  void _syncRecentWatch(bool want) {
    if (want) {
      _recentWatch ??= StreamSupervisor<WatchRecentTransactionsResponse>(
        // A recreated connection replaces bitwindowd.bitwindowd, so resolve it per call.
        subscribe: () => bitwindowd.bitwindowd.watchRecentTransactions(),
        onEvent: applyRecentFrame,
        onTransportDeath: () {},
        logger: log,
        tag: 'BlockchainProvider.recent',
      )..start();
      return;
    }
    unawaited(_recentWatch?.dispose());
    _recentWatch = null;
    _streamedRecent = null;
  }

  /// Applies one WatchRecentTransactions frame.
  @visibleForTesting
  void applyRecentFrame(WatchRecentTransactionsResponse frame) {
    if (frame.heartbeat) {
      return;
    }
    _recentFrames++;
    _streamedRecent = frame.transactions;
    if (!NodeModeProvider.runsLocalBackends || (syncProvider.bitwindowdSyncInfo?.waitsForCore ?? false)) {
      return;
    }
    if (recentTransactions.updateWith(frame.transactions)) {
      _recentChanged.notify();
    }
  }

  void _onSyncChanged() {
    final info = syncProvider.mainchainSyncInfo;
    final next = (info?.isSynced, info?.progressCurrent, info?.lastBlockAt);
    if (next == _mainchainSync) {
      return;
    }
    _mainchainSync = next;
    notifyListeners();
  }

  // call this function from anywhere to refetch blockchain info
  Future<void> fetch() async {
    // Light mode runs no local Bitcoin Core, and blocks, transactions and peers read it.
    if (!NodeModeProvider.runsLocalBackends) {
      _syncRecentWatch(false);
      if (blocks.isNotEmpty || recentTransactions.isNotEmpty || peerCount != 0 || errors.isNotEmpty) {
        clear();
      }
      return;
    }
    if (!bitwindowd.connected || _isFetching) {
      return;
    }
    // bitwindowd answers both list calls with nothing while it waits for Core,
    // and each one still costs Core an RPC under cs_main. A node that re-enters
    // IBD holds rows from the chain it left, so drop them.
    if (syncProvider.bitwindowdSyncInfo?.waitsForCore ?? false) {
      _syncRecentWatch(false);
      if (blocks.isNotEmpty || recentTransactions.isNotEmpty || peerCount != 0 || errors.isNotEmpty) {
        clear();
      }
      return;
    }
    _syncRecentWatch(_streamRecent);
    _isFetching = true;

    try {
      errors = [];
      final tip = _mainchainTip;
      final readBlocks = blocks.isEmpty || tip == null || tip != _blocksTip;
      var blocksFailed = false;
      final streamed = _streamedRecent;
      final frames = _recentFrames;
      final polled = !_streamsRecent || streamed == null;
      var recentFailed = false;
      final tReq = polled
          ? bitwindowd.bitwindowd.listRecentTransactions().onError((e, st) {
              recentFailed = true;
              return _return(recentTransactions)(e, st);
            })
          : Future.value(streamed);
      final bReq = readBlocks
          ? bitwindowd.bitwindowd.listBlocks().onError((e, st) {
              blocksFailed = true;
              return _return((blocks, false))(e, st);
            })
          : null;
      // A shown peer list polls getpeerinfo, so the count reads no more.
      final peerList = GetIt.I.get<PeersProvider>();
      final nReq = peerList.polling
          ? Future.value(peerList.peers.length)
          : _orchestrator.bitcoind
                .getNetworkInfo(GetNetworkInfoRequest())
                .then((r) => r.connections)
                .onError(_return(peerCount));

      final newTXs = await tReq;
      // bitwindowd answers, so a stream that waits out its backoff can subscribe now.
      if (polled && !recentFailed) {
        _recentWatch?.retryNow();
      }
      final newPeerCount = await nReq;

      // A frame that came during the read is newer.
      final recentChanged = _recentFrames == frames && recentTransactions.updateWith(newTXs);
      var hasChanges = false;
      if (newPeerCount != peerCount) {
        peerCount = newPeerCount;
        hasChanges = true;
      }
      if (bReq != null) {
        final (newBlocks, hasMore) = await bReq;
        if (!blocksFailed) {
          _blocksTip = tip;
        }
        final connects =
            hasMore && newBlocks.isNotEmpty && blocks.any((b) => b.hash == newBlocks.last.previousBlockHash);
        final olderBlocks = [
          if (connects)
            for (final b in blocks.where((b) => b.height < newBlocks.last.height))
              b.deepCopy()
                ..confirmations = newBlocks.first.height - b.height + 1
                ..nextBlockHash = b.hash == newBlocks.last.previousBlockHash ? newBlocks.last.hash : b.nextBlockHash,
        ];
        final mergedBlocks = [...newBlocks, ...olderBlocks];
        hasChanges =
            hasChanges |
            blocks.updateWith(
              mergedBlocks,
              afterUpdate: () {
                if (olderBlocks.isEmpty) {
                  hasMoreBlocks = hasMore;
                }
                loadedBlockHeights = mergedBlocks.map((b) => b.height).toSet();
              },
            );
      }
      if (hasChanges) {
        notifyListeners();
      }
      if (recentChanged) {
        _recentChanged.notify();
      }
      // The three calls run at the same time, so the list holds them in
      // completion order. One sort keeps the text the same on every tick.
      _report(([...errors]..sort()).join('\n'));
    } catch (e) {
      if (!isExpectedBootError(e)) {
        _report(e.toString());
      }
    } finally {
      _isFetching = false;
    }
  }

  /// Prints text one time. An empty text clears the record, so the next
  /// failure prints again.
  void _report(String text) {
    if (text.isEmpty) {
      _loggedError = null;
      return;
    }
    if (_loggedError == text) {
      return;
    }
    _loggedError = text;
    log.e(text);
  }

  FutureOr<T> Function(Object? e, StackTrace stt) _return<T>(T previous) {
    return (e, stt) {
      // A daemon that boots answers every call the same way, and its stack
      // trace names this file, not the cause.
      if (e != null && !isExpectedBootError(e)) {
        errors.add(e.toString());
      }
      return previous;
    };
  }

  void _startFetchTimer() {
    fetch();

    if (Environment.isInTest) {
      return;
    }

    _fetchTimer = Timer.periodic(_fetchInterval, (_) => fetch());
  }

  /// Wipe cached state on network swap so the UI stops showing the previous
  /// network's data while the next fetch repopulates from new bitwindowd.
  void clear() {
    _blocksTip = null;
    _streamedRecent = null;
    peerCount = 0;
    blocks = [];
    recentTransactions = [];
    loadedBlockHeights = {};
    hasMoreBlocks = true;
    isLoadingMoreBlocks = false;
    errors.clear();
    _loggedError = null;
    notifyListeners();
    _recentChanged.notify();
  }

  Future<void> loadMoreBlocks() async {
    if (!hasMoreBlocks || isLoadingMoreBlocks) {
      return;
    }

    isLoadingMoreBlocks = true;
    try {
      final lastBlock = blocks.last;
      final (moreBlocks, hasMore) = await bitwindowd.bitwindowd.listBlocks(
        startHeight: lastBlock.height - 1,
      );

      // Filter out blocks we've already loaded
      final newBlocks = moreBlocks.where((b) => !loadedBlockHeights.contains(b.height)).toList();
      if (newBlocks.isEmpty) {
        hasMoreBlocks = false;
        return;
      }

      // Add new block heights to our set
      loadedBlockHeights.addAll(newBlocks.map((b) => b.height));

      // Sort all blocks by height in descending order (newest to oldest)
      blocks = [...blocks, ...newBlocks]..sort((a, b) => b.height.compareTo(a.height));
      hasMoreBlocks = hasMore;
      notifyListeners();
    } finally {
      isLoadingMoreBlocks = false;
    }
  }

  @override
  void dispose() {
    _fetchTimer?.cancel();
    _fetchTimer = null;
    _syncRecentWatch(false);
    mainchain.removeListener(fetch);
    syncProvider.removeListener(_onSyncChanged);
    _recentChanged.dispose();
    super.dispose();
  }
}

class _Signal extends ChangeNotifier {
  void notify() => notifyListeners();
}

extension on List {
  bool updateWith<T>(List<T> newest, {void Function()? afterUpdate}) {
    if (listEquals(this, newest)) {
      return false;
    }
    this
      ..clear()
      ..addAll(newest);
    afterUpdate?.call();
    return true;
  }
}
