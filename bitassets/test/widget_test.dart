import 'package:bitassets/providers/asset_analytics_provider.dart';
import 'package:bitassets/providers/bitassets_provider.dart';
import 'package:bitassets/providers/favorites_provider.dart';
import 'package:bitassets/providers/price_alert_provider.dart';
import 'package:bitassets/widgets/transaction_history.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

import 'mocks/rpc_mock_bitassets.dart';
import 'mocks/storage_mock.dart';
import 'test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized({
    'flutter.test.automatic_wait_for_timers': 'false',
  });

  setUpAll(() async {
    await GetIt.I.reset();

    final mockStore = MockStore();
    final log = Logger(printer: PrettyPrinter(methodCount: 0));

    GetIt.I.registerLazySingleton<Logger>(() => log);
    GetIt.I.registerLazySingleton<ClientSettings>(
      () => ClientSettings(store: mockStore, log: log),
    );
    GetIt.I.registerLazySingleton<NotificationProvider>(
      () => NotificationProvider(),
    );
    GetIt.I.registerLazySingleton<BitAssetsRPC>(
      () => MockBitAssetsRPC(),
    );
    GetIt.I.registerLazySingleton<BitAssetsProvider>(
      () => BitAssetsProvider(),
    );
    GetIt.I.registerLazySingleton<AssetAnalyticsProvider>(
      () => AssetAnalyticsProvider(),
    );
    GetIt.I.registerLazySingleton<FavoritesProvider>(
      () => FavoritesProvider(),
    );
    GetIt.I.registerLazySingleton<PriceAlertProvider>(
      () => PriceAlertProvider(),
    );
  });

  group('TransactionHistoryCard', () {
    testWidgets('renders empty state correctly', (WidgetTester tester) async {
      await tester.pumpSailPage(
        const TransactionHistoryCard(),
      );

      expect(find.text('Recent Activity'), findsOneWidget);
      expect(find.text('No recent activity'), findsOneWidget);
      expect(find.text('Your transactions will appear here'), findsOneWidget);
    });

    testWidgets('shows title and subtitle', (WidgetTester tester) async {
      await tester.pumpSailPage(
        const TransactionHistoryCard(),
      );

      expect(find.text('Recent Activity'), findsOneWidget);
      expect(find.text('Your recent BitAssets transactions'), findsOneWidget);
    });
  });

  group('BitAssetsTransaction', () {
    test('typeIcon returns correct values', () {
      final swapTx = BitAssetsTransaction(
        id: 'tx1',
        type: TransactionType.swap,
        title: 'Swap',
        subtitle: 'BTC to Asset',
        amount: 1000,
        assetId: 'asset1',
        timestamp: DateTime.now(),
        isIncoming: true,
      );
      expect(swapTx.typeIcon, 'Swap');

      final bidTx = BitAssetsTransaction(
        id: 'tx2',
        type: TransactionType.auctionBid,
        title: 'Bid',
        subtitle: 'Auction',
        amount: 2000,
        assetId: 'asset2',
        timestamp: DateTime.now(),
        isIncoming: false,
      );
      expect(bidTx.typeIcon, 'Bid');

      final addLpTx = BitAssetsTransaction(
        id: 'tx3',
        type: TransactionType.liquidityAdd,
        title: 'Add LP',
        subtitle: 'Pool',
        amount: 3000,
        assetId: 'asset3',
        timestamp: DateTime.now(),
        isIncoming: false,
      );
      expect(addLpTx.typeIcon, 'LP+');

      final removeLpTx = BitAssetsTransaction(
        id: 'tx4',
        type: TransactionType.liquidityRemove,
        title: 'Remove LP',
        subtitle: 'Pool',
        amount: 4000,
        assetId: 'asset4',
        timestamp: DateTime.now(),
        isIncoming: true,
      );
      expect(removeLpTx.typeIcon, 'LP-');

      final sendTx = BitAssetsTransaction(
        id: 'tx5',
        type: TransactionType.assetTransfer,
        title: 'Send',
        subtitle: 'Transfer',
        amount: 5000,
        assetId: 'asset5',
        timestamp: DateTime.now(),
        isIncoming: false,
      );
      expect(sendTx.typeIcon, 'Send');

      final recvTx = BitAssetsTransaction(
        id: 'tx6',
        type: TransactionType.assetReceive,
        title: 'Receive',
        subtitle: 'Transfer',
        amount: 6000,
        assetId: 'asset6',
        timestamp: DateTime.now(),
        isIncoming: true,
      );
      expect(recvTx.typeIcon, 'Recv');
    });
  });
}
