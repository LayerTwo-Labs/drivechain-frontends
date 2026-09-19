import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:sidechain_core/gen/stratum/v1/stratum.pb.dart';
import 'package:sidechain_core/rpcs/orchestrator_rpc.dart';
import 'package:sidechain_core/rpcs/orchestrator_stratum_rpc.dart';

/// Status of the orchestrator's Stratum server, read every two seconds.
class StratumProvider extends ChangeNotifier {
  /// Called one time for each block the miners find.
  final void Function(FoundBlock block)? onBlockFound;

  StratumProvider({this.onBlockFound});

  OrchestratorStratumRPC get _rpc => GetIt.I.get<OrchestratorRPC>().stratum;

  GetStratumStatusResponse status = GetStratumStatusResponse();
  List<CatalogPool> pools = [];

  /// Why the last read of the status failed. Null after a read that worked.
  String? error;

  final Set<String> _announced = {};
  Timer? _timer;
  Future<void> _reads = Future.value();
  int _pendingReads = 0;

  bool get running => status.running;
  bool get poolTarget =>
      status.target.kind == TargetKind.TARGET_KIND_POOL || status.target.kind == TargetKind.TARGET_KIND_CUSTOM;

  /// Reads run one after another, so an older read never overwrites a newer one.
  Future<void> refresh() {
    _pendingReads++;
    _reads = _reads.then((_) => _read()).whenComplete(() => _pendingReads--);
    return _reads;
  }

  Future<void> _read() async {
    try {
      final next = await _rpc.status();
      final nextPools = await _rpc.listPools();
      for (final block in next.blocksFound.reversed) {
        if (_announced.add(block.hash)) {
          onBlockFound?.call(block);
        }
      }
      status = next;
      pools = nextPools;
      error = null;
    } catch (e) {
      error = e.toString();
    }
    notifyListeners();
  }

  void startPolling() {
    _timer ??= Timer.periodic(const Duration(seconds: 2), (_) {
      if (_pendingReads == 0) {
        unawaited(refresh());
      }
    });
    unawaited(refresh());
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
