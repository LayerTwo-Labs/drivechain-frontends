import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/pages/sidechains/sidechain_overview_page.dart' show SidechainBalanceRows;
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/mocks/mocks.dart';
import 'package:thunder/widgets/homepage_widget_catalog.dart';

import 'mocks/rpc_mock_sidechain.dart';
import 'test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final sidechainRPC = MockSidechainRPC();
    GetIt.I.registerLazySingleton<SidechainRPC>(() => sidechainRPC);
    GetIt.I.registerLazySingleton<BitcoindConnection>(() => MockBitcoindConnection());
    GetIt.I.registerLazySingleton<Logger>(() => Logger());
    GetIt.I.registerLazySingleton<SidechainTransactionsProvider>(() => SidechainTransactionsProvider());
    GetIt.I.registerLazySingleton<AddressProvider>(() => AddressProvider());
    final balanceProvider = SidechainBalanceProvider(sidechain: sidechainRPC);
    GetIt.I.registerLazySingleton<SidechainBalanceProvider>(() => balanceProvider);
    await balanceProvider.fetch();
  });

  tearDown(() => SailStyleValues.phoneLayoutOverride = null);

  Widget card() => ThunderWidgetCatalog.getCatalogMap()['balance_card']!.builder(WidgetSize.half);

  testWidgets('a phone shows the balance as total, available and pending rows', (tester) async {
    SailStyleValues.phoneLayoutOverride = true;
    await tester.pumpSailPage(card());
    await tester.pumpAndSettle();

    expect(find.byType(SidechainBalanceRows), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
  });

  testWidgets('the desktop keeps the big total over the available and pending lines', (tester) async {
    SailStyleValues.phoneLayoutOverride = false;
    await tester.pumpSailPage(card());
    await tester.pumpAndSettle();

    expect(find.byType(SidechainBalanceRows), findsNothing);
    expect(find.byType(BalanceRow), findsNWidgets(2));
  });
}
