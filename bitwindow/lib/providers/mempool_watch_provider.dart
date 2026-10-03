import 'dart:async';

import 'package:bitwindow/providers/mempool_watch_math.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/env.dart';
import 'package:sidechain_core/gen/bitwindowd/v1/bitwindowd.pb.dart';
import 'package:sidechain_core/providers/network_scoped.dart';
import 'package:sidechain_core/rpcs/bitwindow_api.dart';

export 'package:bitwindow/providers/mempool_watch_math.dart';

/// The view ranks locally, so it loads the mempool up to this many rows.
const maxPendingRows = 2000;

/// Block stats reach back one difficulty period.
const _blockStatsWindow = 2016;

/// Polls the backend mempool watcher while a page is listening. The backend
/// only records what it saw; blocks waited, eligibility, F*, the score and
/// the alarm are all derived here.
class MempoolWatchProvider extends ChangeNotifier implements NetworkScoped {
  Logger get log => GetIt.I.get<Logger>();
  BitwindowRPC get api => GetIt.I.get<BitwindowRPC>();

  /// True once the first fetch answered; before that [status] is a default.
  bool initialized = false;
  GetMempoolWatchStatusResponse status = GetMempoolWatchStatusResponse();

  /// F* at the tip, or null before any block with fees was recorded.
  double? referenceFeeRate;
  List<MempoolTransaction> rows = [];
  int total = 0;
  String? error;

  String txidSearch = '';
  MempoolWatchSort sortBy = MempoolWatchSort.score;
  bool sortDescending = true;

  bool isFetching = false;
  Timer? _timer;
  BlockStatsByHeight _blockStats = {};
  int _tipHeight = 0;
  List<MempoolTransaction> _pending = [];
  Map<String, int> _eligible = {};

  MempoolWatchProvider() {
    if (!Environment.isInTest) {
      _timer = Timer.periodic(const Duration(seconds: 5), (_) => fetch());
    }
  }

  int get alarmCount => _pending.where(alarmed).length;
  bool get alarm => alarmCount > 0;
  bool get alerting => status.enabled && status.running && alarm;
  bool get truncated => total > _pending.length;

  int waited(MempoolTransaction tx) => blocksWaited(tx, _tipHeight);
  int eligible(MempoolTransaction tx) => _eligible[tx.txid] ?? 0;
  double? score(MempoolTransaction tx) => scoreOf(tx, referenceFeeRate, _tipHeight);
  bool alarmed(MempoolTransaction tx) => isAlarmed(tx, referenceFeeRate, _tipHeight);

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    unawaited(fetch());
  }

  @override
  Future<void> onNetworkChanged() async {
    initialized = false;
    status = GetMempoolWatchStatusResponse();
    _blockStats = {};
    referenceFeeRate = null;
    rows = [];
    _pending = [];
    _eligible = {};
    total = 0;
    _tipHeight = 0;
    error = null;
    notifyListeners();
  }

  Future<void> fetch() async {
    if (!hasListeners || !api.connected || isFetching) {
      return;
    }
    isFetching = true;
    try {
      status = await api.bitwindowd.getMempoolWatchStatus();
      _tipHeight = status.tipHeight;
      final from = _tipHeight > _blockStatsWindow ? _tipHeight - _blockStatsWindow : 0;
      _blockStats = {for (final b in await api.bitwindowd.listBlockStats(from, _tipHeight)) b.height: b};
      referenceFeeRate = referenceFeeRateAt(_blockStats, _tipHeight);
      final pending = await _fetchPending();
      _pending = pending.rows;
      total = pending.total;
      _eligible = {for (final tx in _pending) tx.txid: blocksEligible(tx, _blockStats, _tipHeight)};
      rows = _rankPending();
      initialized = true;
      error = null;
    } catch (e) {
      error = e.toString();
      log.e('mempool watch fetch: $e');
    } finally {
      isFetching = false;
      notifyListeners();
    }
  }

  Future<void> setEnabled(bool enabled) async {
    try {
      await api.bitwindowd.setMempoolWatch(enabled);
      error = null;
    } catch (e) {
      error = e.toString();
    }
    await fetch();
  }

  /// Forgets everything recorded and starts over from the current mempool.
  Future<void> reset() async {
    try {
      await api.bitwindowd.resetMempoolWatch();
      error = null;
    } catch (e) {
      error = e.toString();
    }
    await fetch();
  }

  void setTxidSearch(String value) {
    txidSearch = value.trim();
    rows = [];
    notifyListeners();
    unawaited(fetch());
  }

  /// Re-ranks what is loaded; the server plays no part in the order.
  void setSort(MempoolWatchSort field, bool descending) {
    sortBy = field;
    sortDescending = descending;
    rows = _rankPending();
    notifyListeners();
  }

  /// Every transaction in the mempool, up to [maxPendingRows], in one request.
  Future<({List<MempoolTransaction> rows, int total})> _fetchPending() async {
    final list = await api.bitwindowd.listMempoolTransactions(
      ListMempoolTransactionsRequest(limit: maxPendingRows, txid: txidSearch),
    );
    return (rows: list.transactions, total: list.total.toInt());
  }

  List<MempoolTransaction> _rankPending() {
    final now = DateTime.now();
    return [..._pending]
      ..sort((a, b) => compareMempoolTx(sortBy, sortDescending, referenceFeeRate, _eligible, _tipHeight, now, a, b));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}
