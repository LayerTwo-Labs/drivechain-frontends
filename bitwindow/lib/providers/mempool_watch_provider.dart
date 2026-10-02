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

enum MempoolWatchTab { pending, history }

/// The pending view ranks locally, so it loads every candidate up to this many.
const maxPendingRows = 2000;

/// Block stats are kept for this many blocks behind the tip, which covers the
/// watcher's own history retention.
const blockStatsWindow = 1500;

const _pendingPageSize = 500;
const _historyPageSize = 200;

const _serverSorts = {
  MempoolWatchSort.feeRate: MempoolTxSort.MEMPOOL_TX_SORT_FEE_RATE,
  MempoolWatchSort.fee: MempoolTxSort.MEMPOOL_TX_SORT_FEE,
  MempoolWatchSort.vsize: MempoolTxSort.MEMPOOL_TX_SORT_VSIZE,
  MempoolWatchSort.firstSeen: MempoolTxSort.MEMPOOL_TX_SORT_FIRST_SEEN,
};

/// Polls the backend mempool watcher while a page is listening. The backend
/// only records what it saw; blocks waited, eligibility, F*, the score and
/// the alarm are all derived here.
class MempoolWatchProvider extends ChangeNotifier implements NetworkScoped {
  Logger get log => GetIt.I.get<Logger>();
  BitwindowRPC get api => GetIt.I.get<BitwindowRPC>();

  GetMempoolWatchStatusResponse status = GetMempoolWatchStatusResponse();
  BlockStatsByHeight blockStats = {};
  List<MempoolTransaction> rows = [];
  int total = 0;
  int tipHeight = 0;
  String? error;

  MempoolWatchTab tab = MempoolWatchTab.pending;
  String txidSearch = '';
  bool showAll = false;
  double minScore = 0;
  MempoolWatchSort sortBy = MempoolWatchSort.score;
  bool sortDescending = true;

  bool isFetching = false;
  Timer? _timer;
  List<MempoolTransaction> _pending = [];

  MempoolWatchProvider() {
    if (!Environment.isInTest) {
      _timer = Timer.periodic(const Duration(seconds: 5), (_) => fetch());
    }
  }

  /// F* at the tip, or null before any block with fees was recorded.
  double? get referenceFeeRate => referenceFeeRateAt(blockStats, tipHeight);
  int get alarmCount => _pending.where(alarmed).length;
  bool get alarm => alarmCount > 0;
  bool get truncated => tab == MempoolWatchTab.pending && total > _pending.length;

  int waited(MempoolTransaction tx) => blocksWaited(tx, tipHeight);
  int eligible(MempoolTransaction tx) => blocksEligible(tx, blockStats, tipHeight);
  double? score(MempoolTransaction tx) => scoreOf(tx, blockStats, tipHeight);
  bool alarmed(MempoolTransaction tx) => isAlarmed(tx, blockStats, tipHeight);

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    unawaited(fetch());
  }

  @override
  Future<void> onNetworkChanged() async {
    status = GetMempoolWatchStatusResponse();
    blockStats = {};
    rows = [];
    _pending = [];
    total = 0;
    tipHeight = 0;
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
      tipHeight = status.tipHeight;
      final from = tipHeight > blockStatsWindow ? tipHeight - blockStatsWindow : 0;
      blockStats = {for (final b in await api.bitwindowd.listBlockStats(from, tipHeight)) b.height: b};
      final pending = await _fetchPending();
      _pending = pending.rows;
      if (tab == MempoolWatchTab.pending) {
        total = pending.total;
        rows = _rankPending();
      } else {
        final list = await api.bitwindowd.listMempoolTransactions(_historyRequest(offset: 0));
        total = list.total.toInt();
        rows = _sortHistory(list.transactions);
      }
      error = null;
    } catch (e) {
      error = e.toString();
      log.e('mempool watch fetch: $e');
    } finally {
      isFetching = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (tab != MempoolWatchTab.history || isFetching || rows.length >= total) {
      return;
    }
    isFetching = true;
    try {
      final list = await api.bitwindowd.listMempoolTransactions(_historyRequest(offset: rows.length));
      rows = _sortHistory([...rows, ...list.transactions]);
      total = list.total.toInt();
    } catch (e) {
      error = e.toString();
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

  void setTab(MempoolWatchTab value) => _update(() => tab = value);
  void setTxidSearch(String value) => _update(() => txidSearch = value.trim());
  void setShowAll(bool value) => _update(() => showAll = value);
  void setMinScore(double value) => _update(() => minScore = value);
  void setSort(MempoolWatchSort field, bool descending) => _update(() {
    sortBy = field;
    sortDescending = descending;
  });

  void _update(void Function() change) {
    change();
    rows = [];
    notifyListeners();
    unawaited(fetch());
  }

  /// Every pending transaction that can score above zero: those paying more
  /// than F*. With no F* yet, or when showing all, every pending one.
  Future<({List<MempoolTransaction> rows, int total})> _fetchPending() async {
    final minFeeRate = showAll ? 0.0 : (referenceFeeRate ?? 0.0);
    final out = <MempoolTransaction>[];
    var total = 0;
    do {
      final list = await api.bitwindowd.listMempoolTransactions(
        ListMempoolTransactionsRequest(
          status: MempoolTxStatus.MEMPOOL_TX_STATUS_PENDING,
          minFeeRate: minFeeRate,
          limit: _pendingPageSize,
          offset: out.length,
          sortBy: MempoolTxSort.MEMPOOL_TX_SORT_FIRST_SEEN,
          sortDescending: false,
          txid: txidSearch,
        ),
      );
      out.addAll(list.transactions);
      total = list.total.toInt();
      if (list.transactions.isEmpty) {
        break;
      }
    } while (out.length < total && out.length < maxPendingRows);
    return (rows: out, total: total);
  }

  List<MempoolTransaction> _rankPending() {
    final now = DateTime.now();
    final kept = showAll ? _pending : _pending.where((tx) => (score(tx) ?? double.negativeInfinity) > minScore);
    return kept.toList()..sort((a, b) => compareMempoolTx(sortBy, sortDescending, blockStats, tipHeight, now, a, b));
  }

  List<MempoolTransaction> _sortHistory(List<MempoolTransaction> list) {
    if (_serverSorts.containsKey(sortBy)) {
      return list;
    }
    final now = DateTime.now();
    return list..sort((a, b) => compareMempoolTx(sortBy, sortDescending, blockStats, tipHeight, now, a, b));
  }

  ListMempoolTransactionsRequest _historyRequest({required int offset}) {
    return ListMempoolTransactionsRequest(
      status: MempoolTxStatus.MEMPOOL_TX_STATUS_UNSPECIFIED,
      limit: _historyPageSize,
      offset: offset,
      sortBy: _serverSorts[sortBy] ?? MempoolTxSort.MEMPOOL_TX_SORT_FIRST_SEEN,
      sortDescending: sortDescending,
      txid: txidSearch,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}
