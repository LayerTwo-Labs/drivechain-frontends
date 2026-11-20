import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/env.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:sidechain_core/gen/orchestrator/v1/orchestrator.pb.dart' as orch_pb;
import 'package:sidechain_core/rpcs/stream_or_poll.dart';
import 'package:sidechain_core/sidechain_core.dart';

/// One bitwindowd sync poll: the reply, or the reason it failed.
typedef _BitwindowSync = ({GetSyncInfoResponse? info, String? error});

/// Detailed sync info for one chain. progressCurrent / progressGoal are
/// chain heights — download progress lives in [DownloadProvider], not here.
class SyncInfo {
  final double progressCurrent;
  final double progressGoal;
  final Timestamp? lastBlockAt;

  /// Height Core verified from genesis, 0 when it loaded no UTXO snapshot.
  /// Behind a snapshot, progressCurrent reaches the tip long before this does.
  final int verifiedBlocks;

  /// Height [verifiedBlocks] counts towards: the block the snapshot commits
  /// to, not the chain tip. 0 when no snapshot is loaded.
  final int verifiedGoal;

  /// True while this daemon holds its own block scan until Bitcoin Core leaves
  /// initial block download. The heights stand still for as long as it is set.
  final bool waitsForCore;

  /// The mainchain step a sidechain node takes before it syncs its own blocks.
  /// While set, progressCurrent / progressGoal are that step's done / total.
  final orch_pb.MainchainSyncPhase mainchainSyncPhase;

  /// Mainchain height [mainchainSyncPhase] moves to, 0 when unset.
  final int mainchainTipHeight;

  bool get mainchainSyncing => mainchainSyncPhase != orch_pb.MainchainSyncPhase.MAINCHAIN_SYNC_PHASE_UNSPECIFIED;

  double get progress => progressGoal == 0 ? 0 : progressCurrent / progressGoal;

  /// A node that passed the tip its index reports holds everything anyone
  /// knows of, so an index one block behind must not read as unsynced.
  bool get isSynced => !mainchainSyncing && progressGoal > 0 && progressCurrent >= progressGoal;

  /// True when every height this daemon reports reached the goal. A snapshot
  /// node hits the tip in blocks hours before it verifies the rest, so a card
  /// that hides on [isSynced] hides the one bar the reader wants.
  bool get allSyncsComplete => isSynced && (verifiedGoal == 0 || verifiedBlocks >= verifiedGoal);

  SyncInfo({
    required this.progressCurrent,
    required this.progressGoal,
    required this.lastBlockAt,
    this.verifiedBlocks = 0,
    this.verifiedGoal = 0,
    this.waitsForCore = false,
    this.mainchainSyncPhase = orch_pb.MainchainSyncPhase.MAINCHAIN_SYNC_PHASE_UNSPECIFIED,
    this.mainchainTipHeight = 0,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is SyncInfo &&
        other.progressCurrent == progressCurrent &&
        other.progressGoal == progressGoal &&
        other.lastBlockAt == lastBlockAt &&
        other.verifiedBlocks == verifiedBlocks &&
        other.verifiedGoal == verifiedGoal &&
        other.waitsForCore == waitsForCore &&
        other.mainchainSyncPhase == mainchainSyncPhase &&
        other.mainchainTipHeight == mainchainTipHeight;
  }

  @override
  int get hashCode => Object.hash(
    progressCurrent,
    progressGoal,
    lastBlockAt,
    verifiedBlocks,
    verifiedGoal,
    waitsForCore,
    mainchainSyncPhase,
    mainchainTipHeight,
  );
}

/// Tells a [SyncProvider] listener when a synced node reaches a new tip, so
/// it refetches once per block and not on each sync poll.
class SyncedTipWatch {
  Object? _last;

  /// True when [synced] holds and the mainchain, enforcer or bitwindowd tip
  /// moved since the last call that returned true. A tip with a new block
  /// time at the same height counts as a move.
  bool moved(SyncProvider sync, {required bool synced}) {
    if (!synced) {
      _last = null;
      return false;
    }
    final tip = (_tipOf(sync.mainchainSyncInfo), _tipOf(sync.enforcerSyncInfo), _tipOf(sync.bitwindowdSyncInfo));
    if (tip == _last) {
      return false;
    }
    _last = tip;
    return true;
  }

  static (double, Timestamp?)? _tipOf(SyncInfo? info) => info == null ? null : (info.progressCurrent, info.lastBlockAt);
}

/// Represents a binary that has some sort of sync-status
class SyncConnection {
  final RPCConnection rpc;
  final String name;

  SyncConnection({required this.rpc, required this.name});
}

/// Reads the orchestrator `WatchSyncStatus` stream for an atomic snapshot of
/// mainchain + enforcer + every known sidechain, and the bitwindowd
/// `WatchSyncInfo` stream for its own card. Each polls while its stream is
/// down.
/// Carries chain-tip state only — download progress is owned by the
/// [DownloadProvider] which polls its own RPC on a separate cadence.
class SyncProvider extends ChangeNotifier implements NetworkScoped {
  @override
  Future<void> onNetworkChanged() async {
    reset();
  }

  Logger get log => GetIt.I.get<Logger>();

  OrchestratorRPC get _orchestrator => GetIt.I.get<OrchestratorRPC>();

  // Kept for callers that want the typed RPC handle. SyncProvider itself
  // doesn't dial these — it polls the orchestrator only.
  BitcoindConnection get mainchainRPC => GetIt.I.get<BitcoindConnection>();
  EnforcerRPC get enforcerRPC => GetIt.I.get<EnforcerRPC>();

  SyncConnection get mainchain => SyncConnection(rpc: mainchainRPC, name: BitcoinCore().name);
  SyncConnection get enforcer => SyncConnection(rpc: enforcerRPC, name: Enforcer().name);
  final SyncConnection? additionalConnection;

  /// Returns true when bitcoind and enforcer are fully synced. Per-app
  /// "is everything ready" checks should also confirm their own additional
  /// daemon (read [bitwindowdSyncInfo] or [sidechains] directly).
  bool get isSynced => (mainchainSyncInfo?.isSynced ?? false) && (enforcerSyncInfo?.isSynced ?? false);

  /// True while bitcoind is still pulling its initial header set. False in
  /// light mode, which runs no bitcoind.
  bool get inHeaderSync {
    if (!NodeModeProvider.runsLocalBackends) {
      return false;
    }
    final m = mainchainSyncInfo;
    if (m == null) {
      return true;
    }
    return m.progressGoal < 10;
  }

  static const Duration POLL_INTERVAL = Duration(seconds: 1);

  SyncInfo? mainchainSyncInfo;
  String? mainchainError;

  SyncInfo? enforcerSyncInfo;
  String? enforcerError;

  /// Tip the wallet chain source reports (esplora or electrum). An electrum
  /// wallet runs no local node, so this is the only height it has.
  SyncInfo? chainSourceSyncInfo;
  String? chainSourceError;

  /// Per-sidechain sync state, keyed by [SidechainType]. Populated from
  /// `GetSyncStatusResponse.sidechains` on every poll. Includes every L2
  /// chain the orchestrator manages — entries that aren't running yet
  /// carry `error="not running"`.
  ///
  /// bitwindowd is NOT in here. The orchestrator doesn't know bitwindowd
  /// exists — bitwindow's own daemon card reads [bitwindowdSyncInfo]
  /// instead, populated by polling bitwindowd's GetSyncInfo directly.
  Map<orch_pb.SidechainType, SyncInfo> sidechains = const {};
  Map<orch_pb.SidechainType, String?> sidechainErrors = const {};

  /// The sync state of [chain], or null for a binary that is not a sidechain.
  SyncInfo? sidechainSyncInfo(Binary chain) {
    final type = _sidechainType(chain);
    return type == null ? null : sidechains[type];
  }

  static orch_pb.SidechainType? _sidechainType(Binary chain) {
    return switch (chain) {
      Thunder() => orch_pb.SidechainType.SIDECHAIN_TYPE_THUNDER,
      ZSide() => orch_pb.SidechainType.SIDECHAIN_TYPE_ZSIDE,
      BitNames() => orch_pb.SidechainType.SIDECHAIN_TYPE_BITNAMES,
      BitAssets() => orch_pb.SidechainType.SIDECHAIN_TYPE_BITASSETS,
      Truthcoin() => orch_pb.SidechainType.SIDECHAIN_TYPE_TRUTHCOIN,
      Photon() => orch_pb.SidechainType.SIDECHAIN_TYPE_PHOTON,
      CoinShift() => orch_pb.SidechainType.SIDECHAIN_TYPE_COINSHIFT,
      _ => null,
    };
  }

  /// bitwindow's own daemon state, populated by polling bitwindowd
  /// directly each tick. Stays null when no [BitwindowRPC] is registered
  /// (every non-bitwindow app).
  SyncInfo? bitwindowdSyncInfo;
  String? bitwindowdError;

  /// Non-empty while the active electrum wallet is scanning, e.g.
  /// "Scanning external addresses — 12 checked, 3 used". Shown in the bottom nav.
  String walletSyncStatus = '';

  bool _isFetching = false;

  /// Last seen mainchain block height. Drives the new-block broadcast — every
  /// _fetch() compares this against the freshly-polled value and, on a strict
  /// increment, fires [_newBlockListeners] so dependent providers (balance,
  /// transactions, blocks list) can refetch (#1766).
  int _lastMainchainBlocks = 0;
  final Set<void Function(int)> _newBlockListeners = <void Function(int)>{};

  /// Register a callback to fire whenever a new mainchain block arrives.
  /// The new height is passed to [cb]. Caller is responsible for calling
  /// [offNewBlock] in dispose. Fire-and-forget — exceptions are swallowed
  /// so one bad listener can't kill the whole broadcast.
  void onNewBlock(void Function(int newHeight) cb) {
    _newBlockListeners.add(cb);
  }

  void offNewBlock(void Function(int newHeight) cb) {
    _newBlockListeners.remove(cb);
  }

  final Map<orch_pb.SidechainType, int> _lastSidechainBlocks = {};
  final Map<orch_pb.SidechainType, Set<void Function(int)>> _newSidechainBlockListeners = {};

  /// Register [cb] to fire on each new block of [chain], with the new height.
  void onNewSidechainBlock(Binary chain, void Function(int newHeight) cb) {
    final type = _sidechainType(chain);
    if (type == null) {
      throw ArgumentError('${chain.name} is not a sidechain');
    }
    _newSidechainBlockListeners.putIfAbsent(type, () => {}).add(cb);
  }

  void offNewSidechainBlock(Binary chain, void Function(int newHeight) cb) {
    _newSidechainBlockListeners[_sidechainType(chain)]?.remove(cb);
  }

  /// Fires the listeners of [type] when [sync] is above the last seen height.
  @visibleForTesting
  void maybeFireNewSidechainBlock(orch_pb.SidechainType type, SyncInfo sync) {
    // During a mainchain sync the blocks count the mainchain phase, not the sidechain.
    if (sync.mainchainSyncing) {
      return;
    }
    final newBlocks = sync.progressCurrent.toInt();
    if (newBlocks <= (_lastSidechainBlocks[type] ?? 0)) {
      return;
    }
    _lastSidechainBlocks[type] = newBlocks;
    for (final cb in (_newSidechainBlockListeners[type] ?? const {}).toList(growable: false)) {
      try {
        cb(newBlocks);
      } catch (e) {
        log.w('SyncProvider: new-sidechain-block listener threw: $e');
      }
    }
  }

  /// Apply the dedupe-and-broadcast logic for a freshly-polled mainchain
  /// block height. Fires registered listeners only when [newBlocks] is a
  /// strict increment over the last seen value. Public so tests can drive
  /// the broadcast without standing up a mocked orchestrator transport;
  /// production callers should go through [_fetch].
  @visibleForTesting
  void maybeFireNewBlock(int newBlocks) {
    if (newBlocks <= _lastMainchainBlocks) {
      return;
    }
    _lastMainchainBlocks = newBlocks;
    for (final cb in _newBlockListeners.toList(growable: false)) {
      try {
        cb(newBlocks);
      } catch (e) {
        log.w('SyncProvider: new-block listener threw: $e');
      }
    }
  }

  /// Wipe cached per-chain sync state. Called on network swap so stale
  /// progress from the previous network doesn't linger in the UI.
  void reset() {
    mainchainSyncInfo = null;
    mainchainError = null;
    chainSourceSyncInfo = null;
    chainSourceError = null;
    enforcerSyncInfo = null;
    enforcerError = null;
    sidechains = const {};
    sidechainErrors = const {};
    bitwindowdSyncInfo = null;
    bitwindowdError = null;
    // Reset the new-block dedupe baseline so the first block on the new
    // network fires onNewBlock callbacks. Without this a network swap from
    // mainnet (height 800k) → regtest (height 0) would never fire again
    // until regtest passed 800k.
    _lastMainchainBlocks = 0;
    _lastSidechainBlocks.clear();
    notifyListeners();
    _refreshWatches();
  }

  // The streams send only changes, so a value equal across the wipe would
  // stay empty.
  void _refreshWatches() {
    unawaited(_orchWatch?.refresh());
    unawaited(_bitwindowdWatch?.refresh());
  }

  SyncProvider({this.additionalConnection, bool startTimer = true}) {
    if (startTimer && !Environment.isInTest) {
      _orchWatch = StreamOrPoll<orch_pb.WatchSyncStatusResponse, orch_pb.GetSyncStatusResponse>(
        subscribe: _orchestrator.watchSyncStatus,
        onFrame: applyWatchFrame,
        isHeartbeat: (frame) => frame.heartbeat,
        fetch: _orchestrator.getSyncStatus,
        onPoll: (resp) => _notifyIf(_applyOrchestrator(resp)),
        onPollError: (e) => _notifyIf(_applyOrchestratorError(extractConnectException(e))),
        pollInterval: POLL_INTERVAL,
        onTransportDeath: _orchestrator.recreateConnection,
        logger: log,
        tag: 'SyncProvider',
      )..start();
      _bitwindowdModeTimer = Timer.periodic(POLL_INTERVAL, (_) => _syncBitwindowdWatch());
      _syncBitwindowdWatch();
    }
  }

  StreamOrPoll<orch_pb.WatchSyncStatusResponse, orch_pb.GetSyncStatusResponse>? _orchWatch;
  Timer? _bitwindowdModeTimer;
  StreamOrPoll<WatchSyncInfoResponse, GetSyncInfoResponse>? _bitwindowdWatch;

  /// Applies one WatchSyncStatus frame.
  @visibleForTesting
  void applyWatchFrame(orch_pb.WatchSyncStatusResponse frame) {
    if (frame.heartbeat) {
      return;
    }
    _notifyIf(_applyOrchestrator(frame.status));
  }

  void _notifyIf(bool changed) {
    if (changed) {
      notifyListeners();
    }
  }

  /// Light mode runs no local Bitcoin Core, so the bitwindowd card reads a
  /// daemon that is not there. Every non-bitwindow app has no BitwindowRPC.
  BitwindowRPC? get _bitwindowRpc =>
      GetIt.I.isRegistered<BitwindowRPC>() && NodeModeProvider.runsLocalBackends ? GetIt.I.get<BitwindowRPC>() : null;

  /// Runs the bitwindowd watch only while [_bitwindowRpc] has a daemon to read.
  void _syncBitwindowdWatch() {
    final rpc = _bitwindowRpc;
    if (rpc == null) {
      unawaited(_bitwindowdWatch?.dispose());
      _bitwindowdWatch = null;
      _notifyIf(_clearBitwindowd());
      return;
    }
    _bitwindowdWatch ??= StreamOrPoll<WatchSyncInfoResponse, GetSyncInfoResponse>(
      // A recreated connection replaces rpc.bitwindowd, so resolve it per call.
      subscribe: () => rpc.bitwindowd.watchSyncInfo(),
      onFrame: applyBitwindowdFrame,
      isHeartbeat: (frame) => frame.heartbeat,
      fetch: () => rpc.bitwindowd.getSyncInfo(),
      onPoll: (info) => _notifyIf(_applyBitwindowd(info)),
      onPollError: (e) => _notifyIf(_applyBitwindowdError(extractConnectException(e))),
      pollInterval: POLL_INTERVAL,
      onTransportDeath: () {},
      logger: log,
      tag: 'SyncProvider.bitwindowd',
    )..start();
  }

  /// Applies one bitwindowd WatchSyncInfo frame.
  @visibleForTesting
  void applyBitwindowdFrame(WatchSyncInfoResponse frame) {
    if (frame.heartbeat || _bitwindowRpc == null) {
      return;
    }
    _notifyIf(_applyBitwindowd(frame.info));
  }

  // A skipped poll leaves the last snapshot behind, and the daemon card
  // keeps full-mode progress that no longer moves.
  bool _clearBitwindowd() {
    if (bitwindowdSyncInfo == null && bitwindowdError == null) {
      return false;
    }
    bitwindowdSyncInfo = null;
    bitwindowdError = null;
    return true;
  }

  bool _applyBitwindowdError(String? error) {
    if (bitwindowdError == error) {
      return false;
    }
    bitwindowdError = error;
    return true;
  }

  bool _applyBitwindowd(GetSyncInfoResponse info) {
    final next = SyncInfo(
      progressCurrent: info.tipBlockHeight.toDouble(),
      progressGoal: info.headerHeight.toDouble(),
      lastBlockAt: info.tipBlockTime != Int64(0) ? Timestamp(seconds: info.tipBlockTime) : null,
      waitsForCore: info.waitsForCore,
    );
    if (!_diff(bitwindowdSyncInfo, next) && bitwindowdError == null) {
      return false;
    }
    bitwindowdSyncInfo = next;
    bitwindowdError = null;
    return true;
  }

  Future<bool> _fetchBitwindowd() async {
    final rpc = _bitwindowRpc;
    if (rpc == null) {
      return _clearBitwindowd();
    }
    // The stream holds the newest info, and an older reply would win.
    if (_bitwindowdWatch?.streaming ?? false) {
      return false;
    }
    final _BitwindowSync result = await rpc.bitwindowd.getSyncInfo().then<_BitwindowSync>(
      (info) => (info: info, error: null),
      onError: (Object e) => (info: null, error: extractConnectException(e)),
    );
    final info = result.info;
    return info == null ? _applyBitwindowdError(result.error) : _applyBitwindowd(info);
  }

  bool _applyOrchestrator(orch_pb.GetSyncStatusResponse resp) {
    var changed = false;
    final newMainchain = _toSyncInfo(resp.mainchain);
    if (_diff(mainchainSyncInfo, newMainchain) || mainchainError != _errOrNull(resp.mainchain)) {
      mainchainSyncInfo = newMainchain;
      mainchainError = _errOrNull(resp.mainchain);
      changed = true;
    }
    // Fire the new-block broadcast on strict block-height increment. The
    // SyncInfo equality check above includes progressGoal/lastBlockAt
    // changes too, so we re-check the blocks delta independently to avoid
    // false positives when only the header height moved.
    maybeFireNewBlock(newMainchain.progressCurrent.toInt());

    final newEnforcer = _toSyncInfo(resp.enforcer);
    if (_diff(enforcerSyncInfo, newEnforcer) || enforcerError != _errOrNull(resp.enforcer)) {
      enforcerSyncInfo = newEnforcer;
      enforcerError = _errOrNull(resp.enforcer);
      changed = true;
    }

    final newChainSource = _toSyncInfo(resp.chainSource);
    if (_diff(chainSourceSyncInfo, newChainSource) || chainSourceError != _errOrNull(resp.chainSource)) {
      chainSourceSyncInfo = newChainSource;
      chainSourceError = _errOrNull(resp.chainSource);
      changed = true;
    }

    final newSidechains = <orch_pb.SidechainType, SyncInfo>{};
    final newSidechainErrors = <orch_pb.SidechainType, String?>{};
    for (final entry in resp.sidechains) {
      newSidechains[entry.type] = _toSyncInfo(entry.sync);
      newSidechainErrors[entry.type] = _errOrNull(entry.sync);
      maybeFireNewSidechainBlock(entry.type, newSidechains[entry.type]!);
    }
    if (!_sidechainMapEquals(sidechains, newSidechains) || !_sidechainMapEquals(sidechainErrors, newSidechainErrors)) {
      sidechains = newSidechains;
      sidechainErrors = newSidechainErrors;
      changed = true;
    }

    if (walletSyncStatus != resp.walletSyncStatus) {
      walletSyncStatus = resp.walletSyncStatus;
      changed = true;
    }
    return changed;
  }

  bool _applyOrchestratorError(String? orchErr) {
    var changed = false;
    if (mainchainError != orchErr) {
      mainchainError = orchErr;
      changed = true;
    }
    if (enforcerError != orchErr) {
      enforcerError = orchErr;
      changed = true;
    }
    if (sidechainErrors.values.any((e) => e != orchErr)) {
      sidechainErrors = {for (final k in sidechainErrors.keys) k: orchErr};
      changed = true;
    }
    return changed;
  }

  Future<void> _fetch() async {
    // The handler goes on at creation. Attaching it after the orchestrator
    // await lets a failure land while nothing listens, and the zone then
    // reports it as an unhandled error.
    final bitwindowFuture = _fetchBitwindowd();
    var changed = false;
    // The stream holds the newest snapshot, and an older reply would win.
    if (_orchWatch?.streaming ?? false) {
      _notifyIf(await bitwindowFuture);
      return;
    }
    try {
      changed = _applyOrchestrator(await _orchestrator.getSyncStatus());
    } catch (e) {
      changed = _applyOrchestratorError(extractConnectException(e));
    }
    changed |= await bitwindowFuture;
    _notifyIf(changed);
  }

  /// Builds a SyncInfo from the proto.
  SyncInfo _toSyncInfo(orch_pb.ChainSync? cs) {
    final blocks = (cs?.blocks ?? 0).toDouble();
    final headers = (cs?.headers ?? 0).toDouble();
    return SyncInfo(
      progressCurrent: blocks,
      progressGoal: headers,
      lastBlockAt: (cs?.time ?? Int64(0)) != Int64(0) ? Timestamp(seconds: cs!.time) : null,
      verifiedBlocks: cs?.verifiedBlocks ?? 0,
      verifiedGoal: cs?.verifiedGoal ?? 0,
      mainchainSyncPhase: cs?.mainchainSyncPhase ?? orch_pb.MainchainSyncPhase.MAINCHAIN_SYNC_PHASE_UNSPECIFIED,
      mainchainTipHeight: cs?.mainchainTipHeight ?? 0,
    );
  }

  String? _errOrNull(orch_pb.ChainSync? cs) {
    final e = cs?.error ?? '';
    return e.isEmpty ? null : e;
  }

  bool _diff(SyncInfo? a, SyncInfo? b) {
    if (a == null || b == null) {
      return true;
    }
    return a != b;
  }

  bool _sidechainMapEquals<V>(Map<orch_pb.SidechainType, V> a, Map<orch_pb.SidechainType, V> b) {
    if (a.length != b.length) {
      return false;
    }
    for (final k in a.keys) {
      if (!b.containsKey(k) || a[k] != b[k]) {
        return false;
      }
    }
    return true;
  }

  /// Manual one-shot fetch — same as a single tick but without rescheduling.
  Future<void> fetch() async {
    if (_isFetching) {
      return;
    }
    _isFetching = true;
    try {
      await _fetch();
    } finally {
      _isFetching = false;
    }
  }

  /// Clear all sync state — useful when network changes or services restart.
  void clearState() {
    mainchainSyncInfo = null;
    mainchainError = null;
    chainSourceSyncInfo = null;
    chainSourceError = null;
    enforcerSyncInfo = null;
    enforcerError = null;
    bitwindowdSyncInfo = null;
    bitwindowdError = null;
    sidechains = const {};
    sidechainErrors = const {};
    notifyListeners();
    _refreshWatches();
  }

  @override
  void dispose() {
    unawaited(_orchWatch?.dispose());
    unawaited(_bitwindowdWatch?.dispose());
    _bitwindowdModeTimer?.cancel();
    super.dispose();
  }
}
