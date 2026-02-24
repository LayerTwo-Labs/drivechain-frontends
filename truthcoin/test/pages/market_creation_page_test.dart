import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/mocks/mocks.dart';
import 'package:sail_ui/rpcs/mainchain_rpc.dart';
import 'package:sail_ui/rpcs/rpc_sidechain.dart';
import 'package:sail_ui/rpcs/truthcoin_rpc.dart';
import 'package:sail_ui/providers/balance_provider.dart';
import 'package:truthcoin/pages/market_creation_page.dart';
import 'package:truthcoin/providers/market_provider.dart';

import '../mocks/mock_truthcoin_rpc.dart';
import '../test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized({
    'flutter.test.automatic_wait_for_timers': 'false',
  });

  late TestTruthcoinRPC mockRpc;

  setUpAll(() async {
    mockRpc = TestTruthcoinRPC();

    GetIt.I.registerLazySingleton<SidechainRPC>(() => mockRpc);
    GetIt.I.registerLazySingleton<TruthcoinRPC>(() => mockRpc);
    GetIt.I.registerLazySingleton<MainchainRPC>(() => MockMainchainRPC());
    GetIt.I.registerLazySingleton<Logger>(() => Logger(level: Level.off));

    final marketProvider = MarketProvider();
    GetIt.I.registerLazySingleton<MarketProvider>(() => marketProvider);

    final balanceProvider = BalanceProvider(connections: [mockRpc]);
    GetIt.I.registerLazySingleton<BalanceProvider>(() => balanceProvider);
    await balanceProvider.fetch();
  });

  tearDownAll(() async {
    await GetIt.I.reset();
  });

  group('MarketCreationPage', () {
    testWidgets('renders market creation page', (WidgetTester tester) async {
      await tester.pumpSailPage(const MarketCreationPage());
      await tester.pumpAndSettle();

      expect(find.byType(MarketCreationPage), findsOneWidget);
    });

    testWidgets('shows page title', (WidgetTester tester) async {
      await tester.pumpSailPage(const MarketCreationPage());
      await tester.pumpAndSettle();

      expect(find.textContaining('Create'), findsWidgets);
    });

    testWidgets('shows stepper with steps', (WidgetTester tester) async {
      await tester.pumpSailPage(const MarketCreationPage());
      await tester.pumpAndSettle();

      // Step labels
      expect(find.textContaining('Info'), findsWidgets);
    });

    testWidgets('shows navigation buttons', (WidgetTester tester) async {
      await tester.pumpSailPage(const MarketCreationPage());
      await tester.pumpAndSettle();

      // Continue button on first step
      expect(find.text('Continue'), findsWidgets);
    });

    testWidgets('shows back button', (WidgetTester tester) async {
      await tester.pumpSailPage(const MarketCreationPage());
      await tester.pumpAndSettle();

      // Back button with text label
      expect(find.textContaining('Back'), findsWidgets);
    });
  });
}
