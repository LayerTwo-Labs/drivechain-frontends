import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:truthcoin/providers/price_history_provider.dart';

import '../mocks/mock_truthcoin_rpc.dart';
import '../test_utils.dart';

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

  group('PriceHistoryProvider node history', () {
    late TestTruthcoinRPC rpc;

    setUp(() async {
      rpc = await setupMarketVotingTests();
    });

    tearDown(() async {
      await resetGetIt();
    });

    int secondsAgo(Duration age) => DateTime.now().subtract(age).millisecondsSinceEpoch ~/ 1000;

    test('maps each node point to the series of each outcome', () async {
      final created = secondsAgo(const Duration(days: 3));
      final traded = secondsAgo(const Duration(hours: 2));
      rpc.marketPriceHistoryResponse = [
        {
          'height': 410,
          'block_hash': 'aa',
          'timestamp': created,
          'prices': [0.5, 0.5],
        },
        {
          'height': 416,
          'block_hash': 'bb',
          'timestamp': traded,
          'prices': [0.635, 0.365],
        },
      ];
      final history = PriceHistoryProvider();

      await history.loadFromNode(rpc, 'm');

      expect(history.lastTradeHeight('m'), 416);
      final yes = history.seriesFor('m:1');
      expect(yes.first.at.millisecondsSinceEpoch, created * 1000);
      // The price holds until the trade, then steps and runs on to now.
      expect(yes.map((point) => point.price), [0.5, 0.5, 0.365, 0.365]);
      expect(yes[1].at.millisecondsSinceEpoch, traded * 1000);
      expect(history.seriesFor('m:0').last.price, 0.635);
      expect(history.dayChangePoints('m:1')!.round(), -14);
    });

    test('a range starts at the price that held at its start', () async {
      rpc.marketPriceHistoryResponse = [
        {
          'height': 410,
          'block_hash': 'aa',
          'timestamp': secondsAgo(const Duration(days: 3)),
          'prices': [0.15, 0.85],
        },
      ];
      final history = PriceHistoryProvider();

      await history.loadFromNode(rpc, 'm');

      final day = history.seriesFor('m:1', range: PriceRange.day);
      expect(day.map((point) => point.price), [0.85, 0.85]);
      expect(history.lastTradeHeight('m'), isNull);
    });

    test('the node series wins over the recorded one', () async {
      rpc.marketPriceHistoryResponse = [
        {
          'height': 410,
          'block_hash': 'aa',
          'timestamp': secondsAgo(const Duration(hours: 1)),
          'prices': [0.4, 0.6],
        },
      ];
      final history = PriceHistoryProvider();
      history.record('m:1', 0.9);

      await history.loadFromNode(rpc, 'm');

      expect(history.seriesFor('m:1').map((point) => point.price), [0.6, 0.6]);
    });

    test('a node without the method drops an earlier node series', () async {
      rpc.marketPriceHistoryResponse = [
        {
          'height': 410,
          'block_hash': 'aa',
          'timestamp': secondsAgo(const Duration(hours: 1)),
          'prices': [0.4, 0.6],
        },
      ];
      final history = PriceHistoryProvider();
      history.record('m:1', 0.9);
      await history.loadFromNode(rpc, 'm');

      rpc.marketPriceHistoryResponse = null;
      await history.loadFromNode(rpc, 'm');

      expect(history.seriesFor('m:1').single.price, 0.9);
    });

    test('a late node answer never replaces a newer one', () async {
      final slow = Completer<List<Map<String, dynamic>>?>();
      final answers = [
        slow.future,
        Future.value(<Map<String, dynamic>>[
          {
            'height': 410,
            'block_hash': 'aa',
            'timestamp': secondsAgo(const Duration(hours: 2)),
            'prices': [0.5, 0.5],
          },
          {
            'height': 416,
            'block_hash': 'bb',
            'timestamp': secondsAgo(const Duration(hours: 1)),
            'prices': [0.6, 0.4],
          },
        ]),
      ];
      rpc.marketPriceHistoryAnswer = () => answers.removeAt(0);
      final history = PriceHistoryProvider();

      final first = history.loadFromNode(rpc, 'm');
      await history.loadFromNode(rpc, 'm');
      slow.complete([
        {
          'height': 410,
          'block_hash': 'aa',
          'timestamp': secondsAgo(const Duration(hours: 2)),
          'prices': [0.5, 0.5],
        },
      ]);
      await first;

      expect(history.lastTradeHeight('m'), 416);
    });

    test('a node without the method keeps the recorded series', () async {
      rpc.marketPriceHistoryResponse = null;
      final history = PriceHistoryProvider();
      history.record('m:1', 0.3);
      history.record('m:1', 0.7);

      await history.loadFromNode(rpc, 'm');

      expect(history.seriesFor('m:1').map((point) => point.price), [0.3, 0.7]);
      expect(history.lastTradeHeight('m'), isNull);
    });
  });
}
