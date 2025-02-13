// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/mocks/mocks.dart';
import 'package:sail_ui/providers/balance_provider.dart';
import 'package:sail_ui/providers/process_provider.dart';
import 'package:sail_ui/rpcs/mainchain_rpc.dart';
import 'package:sidesail/pages/tabs/sidechain_send_page.dart';
import 'package:sidesail/providers/cast_provider.dart';
import 'package:sidesail/providers/transactions_provider.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';

import 'mocks/rpc_mock_sidechain.dart';
import 'test_utils.dart';

final txProvider = TransactionsProvider();

void main() {
  // there's timers in sidechainrpc and mainchainrpc, that
  // will get shut off when they're disposed. However, they're
  // not disposed per test!
  TestWidgetsFlutterBinding.ensureInitialized({
    'flutter.test.automatic_wait_for_timers': 'false',
  });

  setUpAll(() async {
    GetIt.I.registerLazySingleton<ProcessProvider>(() => ProcessProvider());
    final sidechainRPC = MockSidechainRPC();
    final sidechain = await SidechainContainer.create(sidechainRPC);
    GetIt.I.registerLazySingleton<SidechainRPC>(() => sidechainRPC);
    GetIt.I.registerLazySingleton<SidechainContainer>(() => sidechain);
    GetIt.I.registerLazySingleton<MainchainRPC>(() => MockMainchainRPC());
    GetIt.I.registerLazySingleton<CastProvider>(() => CastProvider());
    GetIt.I.registerLazySingleton<Logger>(() => Logger());

    GetIt.I.registerLazySingleton<TransactionsProvider>(() => txProvider);
    final balanceProvider = BalanceProvider(connections: [sidechainRPC]);
    GetIt.I.registerLazySingleton<BalanceProvider>(() => balanceProvider);
    // don't start test until balance is fetched
    await balanceProvider.fetch();
  });

  testWidgets('can render and show balance', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpSailPage(
      const SidechainSendPage(),
    );
    await tester.pumpAndSettle();

    // Verify that there's a submit button.
    expect(find.text('Actions'), findsOneWidget);
    expect(find.text('Send'), findsOneWidget);
    expect(find.text('Receive'), findsOneWidget);
    expect(find.text('Transactions'), findsOneWidget);
  });
}
