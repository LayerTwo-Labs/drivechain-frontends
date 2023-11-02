// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sidesail/pages/tabs/dashboard_tab_page.dart';
import 'package:sidesail/providers/balance_provider.dart';
import 'package:sidesail/providers/transactions_provider.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';

import 'mocks/rpc_mock_sidechain.dart';
import 'test_utils.dart';

final txProvider = TransactionsProvider();

void main() {
  setUpAll(() async {
    GetIt.I.registerLazySingleton<SidechainRPC>(() => MockSidechainRPC());

    GetIt.I.registerLazySingleton<TransactionsProvider>(() => txProvider);
    final balanceProvider = BalanceProvider();
    GetIt.I.registerLazySingleton<BalanceProvider>(() => balanceProvider);
    // don't start test until balance is fetched
    await balanceProvider.fetch();
  });
  testWidgets('can render and show balance', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpSailPage(
      const DashboardTabPage(),
    );
    await tester.pumpAndSettle();

    // Verify that there's a submit button.
    expect(find.text('Actions'), findsOneWidget);
    expect(find.text('Peg-out to mainchain'), findsOneWidget);
    expect(find.text('Peg-in from mainchain'), findsOneWidget);
    expect(find.text('Send on sidechain'), findsOneWidget);
    expect(find.text('Transactions'), findsOneWidget);
    expect(find.text('Balance: 1.12345678 SBTC'), findsOneWidget);
    expect(find.text('Unconfirmed balance: 2.24680000 SBTC'), findsOneWidget);

    txProvider.stopPolling();
  });
}
