import 'dart:async';

import 'package:bitassets/providers/asset_analytics_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

import 'mocks/rpc_mock_bitassets.dart';
import 'mocks/storage_mock.dart';

void main() {
  late AssetAnalyticsProvider provider;

  setUp(() async {
    await GetIt.I.reset();
    final log = Logger(printer: PrettyPrinter(methodCount: 0));
    GetIt.I.registerSingleton<Logger>(log);
    GetIt.I.registerSingleton<ClientSettings>(ClientSettings(store: MockStore(), log: log));
    GetIt.I.registerSingleton<BitAssetsRPC>(MockBitAssetsRPC());
    provider = AssetAnalyticsProvider();
    final loaded = Completer<void>();
    provider.addListener(loaded.complete);
    await loaded.future;
    provider.removeListener(loaded.complete);
  });

  tearDown(() async {
    provider.dispose();
    await GetIt.I.reset();
  });

  final auctions = [
    auction('a', initialPrice: 100, finalPrice: 0),
    auction('b', initialPrice: 80, finalPrice: 70),
  ];

  for (final block in [99, 100, 101, 105, 110, 111]) {
    test('lowest price order uses block $block', () {
      provider.setAuctionSort(AuctionSort.priceAsc);

      final result = provider.getFilteredAuctions(auctions, block);

      expect(result.map((auction) => auction.id), block < 103 ? ['b', 'a'] : ['a', 'b']);
      expect(
        provider.calculateCurrentPrice(result.first, block),
        lessThan(provider.calculateCurrentPrice(result.last, block)),
      );
      expect(auctions.map((auction) => auction.id), ['a', 'b']);
    });

    test('highest price order uses block $block', () {
      provider.setAuctionSort(AuctionSort.priceDesc);

      final result = provider.getFilteredAuctions(auctions, block);

      expect(result.map((auction) => auction.id), block < 103 ? ['a', 'b'] : ['b', 'a']);
      expect(
        provider.calculateCurrentPrice(result.first, block),
        greaterThan(provider.calculateCurrentPrice(result.last, block)),
      );
      expect(auctions.map((auction) => auction.id), ['a', 'b']);
    });
  }
}

DutchAuctionEntry auction(String id, {required int initialPrice, required int finalPrice}) {
  return DutchAuctionEntry(
    id: id,
    baseAsset: 'asset',
    quoteAsset: 'btc',
    baseAmount: 1,
    initialPrice: initialPrice,
    finalPrice: finalPrice,
    startBlock: 100,
    duration: 10,
    status: 'Active',
  );
}
