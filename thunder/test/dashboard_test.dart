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
import 'package:sail_ui/rpcs/rpc_sidechain.dart';
import 'package:sail_ui/rpcs/thunder_rpc.dart';
import 'package:thunder/pages/tabs/testchain/mainchain/deposit_withdraw_tab_route.dart';
import 'package:thunder/providers/address_provider.dart';
import 'package:thunder/providers/transactions_provider.dart';

import 'mocks/rpc_mock_sidechain.dart';
import 'test_utils.dart';

final txProvider = TransactionProvider();

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
    final thunderRPC = MockThunderRPC();
    GetIt.I.registerLazySingleton<SidechainRPC>(() => sidechainRPC);
    GetIt.I.registerLazySingleton<ThunderRPC>(() => thunderRPC);
    GetIt.I.registerLazySingleton<MainchainRPC>(() => MockMainchainRPC());
    GetIt.I.registerLazySingleton<Logger>(() => Logger());

    GetIt.I.registerLazySingleton<TransactionProvider>(() => txProvider);
    GetIt.I.registerLazySingleton<AddressProvider>(() => AddressProvider());
    final balanceProvider = BalanceProvider(connections: [sidechainRPC]);
    GetIt.I.registerLazySingleton<BalanceProvider>(() => balanceProvider);
    // don't start test until balance is fetched
    await balanceProvider.fetch();
  });

  testWidgets('can render and show balance', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpSailPage(
      const DepositWithdrawTabPage(),
    );
    await tester.pumpAndSettle();
  });
}
