import 'package:bitassets/pages/tabs/auction_browser_page.dart';
import 'package:bitassets/providers/asset_analytics_provider.dart';
import 'package:bitassets/providers/bitassets_provider.dart';
import 'package:bitassets/providers/favorites_provider.dart';
import 'package:bitassets/providers/price_alert_provider.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

import 'mocks/rpc_mock_bitassets.dart';
import 'test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuctionRPC rpc;

  setUpAll(() async {
    final inter = FontLoader(SailFonts.inter);
    for (final weight in ['Regular', 'Bold']) {
      inter.addFont(rootBundle.load('packages/sail_ui/assets/fonts/Inter-$weight.ttf'));
    }
    await inter.load();
  });

  setUp(() async {
    await GetIt.I.reset();
    await registerTestDependencies();
    rpc = AuctionRPC();
    GetIt.I.registerSingleton<BitAssetsRPC>(rpc);
    GetIt.I.registerLazySingleton<NotificationProvider>(() => NotificationProvider());
    GetIt.I.registerLazySingleton<BitAssetsProvider>(
      () => BitAssetsProvider(),
      dispose: (provider) => provider.dispose(),
    );
    GetIt.I.registerLazySingleton<AssetAnalyticsProvider>(
      () => AssetAnalyticsProvider(),
      dispose: (provider) => provider.dispose(),
    );
    GetIt.I.registerLazySingleton<FavoritesProvider>(
      () => FavoritesProvider(),
      dispose: (provider) => provider.dispose(),
    );
    GetIt.I.registerLazySingleton<PriceAlertProvider>(
      () => PriceAlertProvider(),
      dispose: (provider) => provider.dispose(),
    );
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  for (final sort in [AuctionSort.priceAsc, AuctionSort.priceDesc]) {
    testWidgets('provider refresh updates prices and ${sort.name} order', (tester) async {
      GetIt.I.get<AssetAnalyticsProvider>().setAuctionSort(sort);
      await tester.pumpSailPage(const AuctionBrowserTabPage());
      await tester.pumpAndSettle();

      expect(find.text('Current Block: 101'), findsOneWidget);
      expect(find.text('90'), findsOneWidget);
      expect(find.text('79'), findsOneWidget);
      final firstAuction = find.text('aaaaaaaaaaaaaaaa...');
      final secondAuction = find.text('bbbbbbbbbbbbbbbb...');
      expect(
        tester.getTopLeft(firstAuction).dy < tester.getTopLeft(secondAuction).dy,
        sort == AuctionSort.priceDesc,
      );

      rpc.height = 105;
      await GetIt.I.get<BitAssetsProvider>().fetch();
      await tester.pumpAndSettle();

      expect(find.text('Current Block: 105'), findsOneWidget);
      expect(find.text('50'), findsOneWidget);
      expect(find.text('75'), findsOneWidget);
      expect(find.text('90'), findsNothing);
      expect(find.text('79'), findsNothing);
      expect(
        tester.getTopLeft(firstAuction).dy < tester.getTopLeft(secondAuction).dy,
        sort == AuctionSort.priceAsc,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await GetIt.I.reset();
    });
  }

  testWidgets('the Upcoming badge fits its column on one line', (tester) async {
    rpc.upcoming = true;
    await tester.pumpSailPage(const AuctionBrowserTabPage());
    await tester.pumpAndSettle();

    final paragraphs = tester
        .renderObjectList<RenderParagraph>(find.descendant(of: find.text('Upcoming'), matching: find.byType(RichText)))
        .toList();
    expect(paragraphs, hasLength(2));
    for (final paragraph in paragraphs) {
      final oneLine = TextPainter(
        text: paragraph.text,
        textDirection: TextDirection.ltr,
        textScaler: paragraph.textScaler,
      )..layout();
      expect(paragraph.size.height, oneLine.height);
    }
    await tester.pumpWidget(const SizedBox.shrink());
    await GetIt.I.reset();
  });
}

class AuctionRPC extends MockBitAssetsRPC {
  int height = 101;
  bool upcoming = false;

  @override
  Future<int> getBlockCount() async => height;

  @override
  Future<List<DutchAuctionEntry>> dutchAuctions() async => [
    DutchAuctionEntry(
      id: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      baseAsset: '11111111111111111111111111111111',
      quoteAsset: 'btc',
      baseAmount: 1,
      initialPrice: 100,
      finalPrice: 0,
      startBlock: 100,
      duration: 10,
      status: 'Active',
    ),
    DutchAuctionEntry(
      id: 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
      baseAsset: '22222222222222222222222222222222',
      quoteAsset: 'btc',
      baseAmount: 1,
      initialPrice: 80,
      finalPrice: 70,
      startBlock: upcoming ? 200 : 100,
      duration: 10,
      status: 'Active',
    ),
  ];
}
