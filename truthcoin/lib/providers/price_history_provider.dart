import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

/// One price reading of one outcome.
class PricePoint {
  final DateTime at;
  final double price;

  const PricePoint(this.at, this.price);

  Map<String, dynamic> toJson() => {'t': at.millisecondsSinceEpoch, 'p': price};

  static PricePoint? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final t = raw['t'];
    final price = raw['p'];
    if (t is! int || price is! num) return null;
    return PricePoint(DateTime.fromMillisecondsSinceEpoch(t), price.toDouble());
  }
}

/// The ranges the market page offers above the chart.
enum PriceRange {
  hour('1H', Duration(hours: 1)),
  sixHours('6H', Duration(hours: 6)),
  day('1D', Duration(days: 1)),
  week('1W', Duration(days: 7)),
  all('ALL', null);

  final String label;
  final Duration? window;

  const PriceRange(this.label, this.window);
}

/// Keeps the price the node reports for each market, so the chart draws a real
/// series. The node serves no price history, so the app records its own.
class PriceHistoryProvider extends ChangeNotifier {
  static const int _maxPoints = 2000;
  static const Duration _minGap = Duration(seconds: 30);

  final Map<String, List<PricePoint>> _series = {};
  final File? file;

  /// Every save joins this chain, so two readings never write at the same
  /// time and leave a half-written file.
  Future<void> _writes = Future<void>.value();

  /// True while a write waits in the chain. One wait covers every reading
  /// that arrives before it starts, so a refresh writes the file once.
  bool _savePending = false;

  PriceHistoryProvider({this.file});

  factory PriceHistoryProvider.inDirectory(Directory appDir) {
    return PriceHistoryProvider(file: File(p.join(appDir.path, 'market_prices.json')));
  }

  List<PricePoint> seriesFor(String marketId, {PriceRange range = PriceRange.all}) {
    final points = _series[marketId] ?? const <PricePoint>[];
    final window = range.window;
    if (window == null) return List.unmodifiable(points);
    final from = DateTime.now().subtract(window);
    return List.unmodifiable(points.where((point) => point.at.isAfter(from)));
  }

  /// The price change over the last day, in points of a percent. The base is
  /// the newest reading at or before the cutoff, so the newest reading never
  /// stands against itself.
  double? dayChangePoints(String marketId) {
    final points = _series[marketId] ?? const <PricePoint>[];
    if (points.length < 2) return null;
    final cutoff = DateTime.now().subtract(const Duration(days: 1));
    var earlier = points.first;
    for (final point in points) {
      if (point.at.isAfter(cutoff)) break;
      earlier = point;
    }
    if (identical(earlier, points.last)) return null;
    return (points.last.price - earlier.price) * 100;
  }

  /// Writes one reading. A price that moves always adds a point, so a trade
  /// right after a page load keeps both sides of the move. A price that holds
  /// adds a point only after the gap, which keeps the series small.
  void record(String marketId, double price) {
    final points = _series.putIfAbsent(marketId, () => <PricePoint>[]);
    final now = DateTime.now();
    if (points.isNotEmpty) {
      final last = points.last;
      if (last.price == price && now.difference(last.at) < _minGap) return;
    }
    points.add(PricePoint(now, price));
    if (points.length > _maxPoints) points.removeRange(0, points.length - _maxPoints);
    notifyListeners();
    unawaited(save());
  }

  Future<void> load() async {
    final file = this.file;
    if (file == null || !file.existsSync()) return;
    try {
      final raw = jsonDecode(await file.readAsString());
      if (raw is! Map) return;
      _series.clear();
      for (final entry in raw.entries) {
        final points = entry.value;
        if (points is! List) continue;
        _series[entry.key.toString()] = [
          for (final point in points) ?PricePoint.fromJson(point),
        ];
      }
      notifyListeners();
    } catch (_) {
      // A broken or unreadable cache costs nothing; the app records the
      // series again. A startup must never stop for it.
    }
  }

  Future<void> save() {
    if (_savePending) return _writes;
    _savePending = true;
    // A failed write must not break the chain, or every later save stops.
    _writes = _writes
        .then((_) async {
          _savePending = false;
          await _write();
        })
        .catchError((Object _) {
          _savePending = false;
        });
    return _writes;
  }

  Future<void> _write() async {
    final file = this.file;
    if (file == null) return;
    final payload = {
      for (final entry in _series.entries) entry.key: [for (final point in entry.value) point.toJson()],
    };
    await file.writeAsString(jsonEncode(payload));
  }
}
