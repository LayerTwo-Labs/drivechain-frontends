import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:truthcoin/providers/price_history_provider.dart';

void main() {
  group('PriceHistoryProvider', () {
    test('records one point per reading', () {
      final history = PriceHistoryProvider();

      history.record('m:1', 0.5);

      expect(history.seriesFor('m:1'), hasLength(1));
      expect(history.seriesFor('m:1').single.price, 0.5);
    });

    test('drops a repeat of the same price', () {
      final history = PriceHistoryProvider();

      history.record('m:1', 0.5);
      history.record('m:1', 0.5);

      expect(history.seriesFor('m:1'), hasLength(1));
    });

    test('keeps both sides of a move inside the gap', () {
      final history = PriceHistoryProvider();

      history.record('m:1', 0.5);
      history.record('m:1', 0.7);

      expect(history.seriesFor('m:1').map((point) => point.price), [0.5, 0.7]);
    });

    test('keeps one series per outcome', () {
      final history = PriceHistoryProvider();

      history.record('m:0', 0.4);
      history.record('m:1', 0.6);

      expect(history.seriesFor('m:0').single.price, 0.4);
      expect(history.seriesFor('m:1').single.price, 0.6);
    });

    test('a market with no reading holds an empty series', () {
      expect(PriceHistoryProvider().seriesFor('none'), isEmpty);
    });

    test('answers no day change below two points', () {
      final history = PriceHistoryProvider();
      history.record('m:1', 0.5);

      expect(history.dayChangePoints('m:1'), isNull);
    });

    test('reads a saved cache file', () async {
      final dir = await Directory.systemTemp.createTemp('price-history');
      final file = File('${dir.path}/market_prices.json');
      await file.writeAsString(
        jsonEncode({
          'm:1': [
            {'t': DateTime.now().millisecondsSinceEpoch - 1000, 'p': 0.3},
            {'t': DateTime.now().millisecondsSinceEpoch, 'p': 0.8},
          ],
        }),
      );

      final history = PriceHistoryProvider(file: file);
      await history.load();

      expect(history.seriesFor('m:1'), hasLength(2));
      expect(history.dayChangePoints('m:1')!.round(), 50);
      await dir.delete(recursive: true);
    });

    test('a broken cache file leaves the provider empty', () async {
      final dir = await Directory.systemTemp.createTemp('price-history');
      final file = File('${dir.path}/market_prices.json');
      await file.writeAsString('not json');

      final history = PriceHistoryProvider(file: file);
      await history.load();

      expect(history.seriesFor('m:1'), isEmpty);
      await dir.delete(recursive: true);
    });

    test('the range filter drops an old point', () async {
      final dir = await Directory.systemTemp.createTemp('price-history');
      final file = File('${dir.path}/market_prices.json');
      final old = DateTime.now().subtract(const Duration(days: 3)).millisecondsSinceEpoch;
      await file.writeAsString(
        jsonEncode({
          'm:1': [
            {'t': old, 'p': 0.2},
            {'t': DateTime.now().millisecondsSinceEpoch, 'p': 0.9},
          ],
        }),
      );

      final history = PriceHistoryProvider(file: file);
      await history.load();

      expect(history.seriesFor('m:1', range: PriceRange.all), hasLength(2));
      expect(history.seriesFor('m:1', range: PriceRange.day), hasLength(1));
      await dir.delete(recursive: true);
    });

    test('many readings write one valid file', () async {
      final dir = await Directory.systemTemp.createTemp('price-history');
      final file = File('${dir.path}/market_prices.json');
      final history = PriceHistoryProvider(file: file);

      for (var i = 0; i < 20; i++) {
        history.record('m:$i', i / 20);
      }
      await history.save();

      final raw = jsonDecode(await file.readAsString());
      expect(raw, isA<Map>());
      expect((raw as Map).length, 20);
      await dir.delete(recursive: true);
    });

    test('a saved file reads back with the same points', () async {
      final dir = await Directory.systemTemp.createTemp('price-history');
      final file = File('${dir.path}/market_prices.json');
      final first = PriceHistoryProvider(file: file);
      first.record('m:1', 0.25);
      await first.save();

      final second = PriceHistoryProvider(file: file);
      await second.load();

      expect(second.seriesFor('m:1').single.price, 0.25);
      await dir.delete(recursive: true);
    });

    test('an unreadable cache leaves the provider empty', () async {
      final dir = await Directory.systemTemp.createTemp('price-history');
      // A directory where the file belongs: the read fails, the app lives.
      final asDirectory = Directory('${dir.path}/market_prices.json');
      await asDirectory.create();

      final history = PriceHistoryProvider(file: File(asDirectory.path));
      await history.load();

      expect(history.seriesFor('m:1'), isEmpty);
      await dir.delete(recursive: true);
    });

    test('a failed write leaves later saves alive', () async {
      final dir = await Directory.systemTemp.createTemp('price-history');
      final asDirectory = Directory('${dir.path}/market_prices.json');
      await asDirectory.create();
      final history = PriceHistoryProvider(file: File(asDirectory.path));

      history.record('m:1', 0.4);
      await history.save();
      history.record('m:2', 0.6);
      await history.save();

      expect(history.seriesFor('m:2').single.price, 0.6);
      await dir.delete(recursive: true);
    });

    test('the day change reads the point at the cutoff, not the newest', () async {
      final dir = await Directory.systemTemp.createTemp('price-history');
      final file = File('${dir.path}/market_prices.json');
      final now = DateTime.now().millisecondsSinceEpoch;
      await file.writeAsString(
        jsonEncode({
          'm:1': [
            {'t': now - const Duration(days: 3).inMilliseconds, 'p': 0.2},
            {'t': now - const Duration(days: 2).inMilliseconds, 'p': 0.3},
            {'t': now, 'p': 0.9},
          ],
        }),
      );

      final history = PriceHistoryProvider(file: file);
      await history.load();

      // The base is the two-day-old point, not the newest one.
      expect(history.dayChangePoints('m:1')!.round(), 60);
      await dir.delete(recursive: true);
    });

    test('answers no day change when every point is older than a day', () async {
      final dir = await Directory.systemTemp.createTemp('price-history');
      final file = File('${dir.path}/market_prices.json');
      final old = DateTime.now().subtract(const Duration(days: 4)).millisecondsSinceEpoch;
      await file.writeAsString(
        jsonEncode({
          'm:1': [
            {'t': old, 'p': 0.2},
            {'t': old + 1000, 'p': 0.5},
          ],
        }),
      );

      final history = PriceHistoryProvider(file: file);
      await history.load();

      expect(history.dayChangePoints('m:1'), isNull);
      await dir.delete(recursive: true);
    });
  });
}
