import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:sidechain_core/gen/stratum/v1/stratum.pb.dart';
import 'package:sidechain_core/rpcs/orchestrator_rpc.dart';
import 'package:sidechain_core/rpcs/orchestrator_stratum_rpc.dart';

/// Status of the orchestrator's Stratum server, read every two seconds while
/// a widget listens or the server runs.
class StratumProvider extends ChangeNotifier {
  /// Called one time for each block the miners find.
  final void Function(FoundBlock block)? onBlockFound;

  StratumProvider({this.onBlockFound});

  OrchestratorStratumRPC get _rpc => GetIt.I.get<OrchestratorRPC>().stratum;

  GetStratumStatusResponse status = GetStratumStatusResponse();
  List<CatalogPool> pools = [];

  /// The hashrate chart of [range], read with the status.
  GetHashrateHistoryResponse history = GetHashrateHistoryResponse();
  HashrateRange range = HashrateRange.HASHRATE_RANGE_DAY;

  /// The blocks the upstream pool found. Empty for a solo target.
  ListPoolBlocksResponse poolBlocks = ListPoolBlocksResponse();

  /// Why the last read of the status failed. Null after a read that worked.
  String? error;

  final Set<String> _announced = {};
  Timer? _timer;
  Future<void> _reads = Future.value();
  int _pendingReads = 0;
  int _idleTicks = 0;

  /// Ticks between two status reads while no widget listens and the server is off.
  static const _idleReadTicks = 5;

  bool get running => status.running;
  bool get poolTarget =>
      status.target.kind == TargetKind.TARGET_KIND_POOL || status.target.kind == TargetKind.TARGET_KIND_CUSTOM;

  /// Reads run one after another, so an older read never overwrites a newer one.
  Future<void> refresh() => _queue(full: true);

  Future<void> _queue({required bool full}) {
    _pendingReads++;
    _reads = _reads.then((_) => _read(full: full)).whenComplete(() => _pendingReads--);
    return _reads;
  }

  /// Reads the status, and with [full] also the pools, chart and pool blocks.
  Future<void> _read({required bool full}) async {
    final shown = (status, pools, history, poolBlocks, error);
    try {
      final next = await _rpc.status();
      if (full) {
        final nextPools = await _rpc.listPools();
        history = await _rpc.hashrateHistory(range);
        poolBlocks = next.target.kind == TargetKind.TARGET_KIND_SOLO
            ? ListPoolBlocksResponse()
            : await _rpc.listPoolBlocks();
        pools = nextPools;
      }
      for (final block in next.blocksFound.reversed) {
        if (_announced.add(block.hash)) {
          onBlockFound?.call(block);
        }
      }
      status = next;
      error = null;
    } catch (e) {
      error = e.toString();
    }
    final (oldStatus, oldPools, oldHistory, oldPoolBlocks, oldError) = shown;
    if (oldStatus != status ||
        !listEquals(oldPools, pools) ||
        oldHistory != history ||
        oldPoolBlocks != poolBlocks ||
        oldError != error) {
      notifyListeners();
    }
  }

  void startPolling() {
    _timer ??= Timer.periodic(const Duration(seconds: 2), (_) => tick());
    unawaited(refresh());
  }

  @visibleForTesting
  void tick() {
    if (_pendingReads > 0) {
      return;
    }
    if (hasListeners) {
      unawaited(refresh());
      return;
    }
    if (!running && ++_idleTicks < _idleReadTicks) {
      return;
    }
    _idleTicks = 0;
    unawaited(_queue(full: false));
  }

  @override
  void addListener(VoidCallback listener) {
    final first = !hasListeners;
    super.addListener(listener);
    if (first && _timer != null && _pendingReads == 0) {
      unawaited(refresh());
    }
  }

  void stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> start(int port) async {
    await _rpc.start(port: port);
    await refresh();
  }

  Future<void> stop() async {
    await _rpc.stop();
    await refresh();
  }

  Future<void> setTarget(Target target) async {
    await _rpc.setTarget(target);
    await refresh();
  }

  Future<void> setWorkMode(String address, WorkMode mode) async {
    await _rpc.setWorkMode(address, mode);
    await refresh();
  }

  Future<void> setRange(HashrateRange next) async {
    range = next;
    await refresh();
  }

  Future<void> setMiningSettings({
    int? port,
    bool? cpuMining,
    int? cpuThreads,
    bool? keepMiningOnClose,
    double? minDifficulty,
  }) async {
    await _rpc.setMiningSettings(
      port: port,
      cpuMining: cpuMining,
      cpuThreads: cpuThreads,
      keepMiningOnClose: keepMiningOnClose,
      minDifficulty: minDifficulty,
    );
    await refresh();
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}

const _hashrateUnits = ['H/s', 'KH/s', 'MH/s', 'GH/s', 'TH/s', 'PH/s', 'EH/s'];

/// A hashrate with a unit, such as `6.02 TH/s`.
String formatHashrate(double hashesPerSecond) {
  var rate = hashesPerSecond;
  var unit = 0;
  while (rate >= 999.5 && unit < _hashrateUnits.length - 1) {
    rate /= 1000;
    unit++;
  }
  return '${unit == 0 ? rate.toStringAsFixed(0) : rate.toStringAsPrecision(3)} ${_hashrateUnits[unit]}';
}

const _difficultySuffixes = ['', 'K', 'M', 'G', 'T', 'P', 'E'];

/// A difficulty or share with a K/M/G/T suffix, such as `1.23M`.
String formatDifficulty(double difficulty) {
  if (difficulty <= 0) {
    return '0';
  }
  if (difficulty < 1) {
    return difficulty.toStringAsPrecision(3);
  }
  var value = difficulty;
  var suffix = 0;
  while (value >= 1000 && suffix < _difficultySuffixes.length - 1) {
    value /= 1000;
    suffix++;
  }
  return suffix == 0 ? value.toStringAsFixed(0) : '${value.toStringAsFixed(2)}${_difficultySuffixes[suffix]}';
}

/// A past time relative to now, such as `3 s ago`.
String formatAgo(DateTime time, DateTime now) {
  final seconds = max(0, now.difference(time).inSeconds);
  if (seconds < 60) {
    return '$seconds s ago';
  }
  if (seconds < 3600) {
    return '${seconds ~/ 60} min ago';
  }
  if (seconds < 86400) {
    return '${seconds ~/ 3600} h ago';
  }
  return '${seconds ~/ 86400} d ago';
}

/// The time the hashrate needs on average to find a block, or null at zero
/// hashrate.
Duration? expectedTimeToBlock(double networkDifficulty, double hashesPerSecond) {
  if (hashesPerSecond <= 0 || networkDifficulty <= 0) {
    return null;
  }
  const longest = Duration(days: 365 * 100000);
  final seconds = networkDifficulty * pow(2, 32) / hashesPerSecond;
  if (seconds >= longest.inSeconds) {
    return longest;
  }
  return Duration(seconds: seconds.round());
}

/// A long duration in its largest unit, such as `3 days`.
String formatLongDuration(Duration d) {
  final seconds = d.inSeconds;
  String unit(int n, String name) => '$n $name${n == 1 ? '' : 's'}';
  if (seconds < 60) {
    return unit(seconds, 'second');
  }
  if (seconds < 3600) {
    return unit(seconds ~/ 60, 'minute');
  }
  if (seconds < 86400) {
    return unit(seconds ~/ 3600, 'hour');
  }
  if (seconds < 86400 * 365) {
    return unit(seconds ~/ 86400, 'day');
  }
  return unit(seconds ~/ (86400 * 365), 'year');
}
