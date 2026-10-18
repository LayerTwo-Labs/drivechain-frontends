import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sidechain_core/providers/balance_provider.dart';
import 'package:sidechain_core/providers/sidechain/sidechain_transactions_provider.dart';
import 'package:sidechain_core/rpcs/rpc_sidechain.dart';
import 'package:sidechain_core/rpcs/zside_rpc.dart';
import 'package:zside/providers/transactions_provider.dart';
import 'package:zside/widgets/homepage_widget_catalog.dart';

import 'mocks/rpc_mock_sidechain.dart';
import 'mocks/rpc_mock_zside.dart';
import 'test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await registerTestDependencies();
    final sidechainRPC = MockSidechainRPC();
    GetIt.I.registerLazySingleton<SidechainRPC>(() => sidechainRPC);
    GetIt.I.registerLazySingleton<ZSideRPC>(() => MockZSideRPC());
    GetIt.I.registerLazySingleton<SidechainTransactionsProvider>(() => SidechainTransactionsProvider());
    GetIt.I.registerLazySingleton<TransactionsProvider>(() => TransactionsProvider());
    GetIt.I.registerLazySingleton<BalanceProvider>(() => BalanceProvider(connections: [sidechainRPC]));
  });

  test('a transparent send is capped at the spendable transparent coins', () {
    final model = OverviewTabViewModel()
      ..sidechainFee = 0.001
      ..balanceBreakdown = ZSideBalanceBreakdown(
        availableShieldedSats: 200000000,
        availableTransparentSats: 50000000,
        totalShieldedSats: 200000000,
        totalTransparentSats: 60000000,
      );
    model.bitcoinAddressController.text = 'tmBd8jBt7FGDjN8KL9Wh4s925R6EopAGacu';

    expect(model.isShieldedAddress, isFalse);
    expect(model.maxAmount, closeTo(0.499, 1e-9));
  });

  test('a switch to a transparent address caps an amount already entered', () {
    GetIt.I<BalanceProvider>().setBalance(GetIt.I<SidechainRPC>(), 2.5, 0);
    final model = OverviewTabViewModel()
      ..sidechainFee = 0.001
      ..balanceBreakdown = ZSideBalanceBreakdown(
        availableShieldedSats: 200000000,
        availableTransparentSats: 50000000,
        totalShieldedSats: 200000000,
        totalTransparentSats: 60000000,
      );
    model.bitcoinAddressController.text = 'zs1notatransparentaddress';
    model.bitcoinAmountController.text = '1.0';
    expect(model.bitcoinAmountController.text, '1.0');

    model.bitcoinAddressController.text = 'tmBd8jBt7FGDjN8KL9Wh4s925R6EopAGacu';

    expect(double.parse(model.bitcoinAmountController.text), closeTo(0.499, 1e-9));
  });
}
