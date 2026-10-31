import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sidechain_core/providers/balance_provider.dart';
import 'package:sidechain_core/providers/sidechain/sidechain_transactions_provider.dart';
import 'package:sidechain_core/rpcs/rpc_sidechain.dart';
import 'package:sidechain_core/rpcs/zside_rpc.dart';
import 'package:zside/providers/transactions_provider.dart';
import 'package:zside/widgets/containers/tabs/dashboard_tab_widgets.dart';

import 'mocks/rpc_mock_sidechain.dart';
import 'mocks/rpc_mock_zside.dart';
import 'test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final sidechainRPC = MockSidechainRPC();
    GetIt.I.registerLazySingleton<SidechainRPC>(() => sidechainRPC);
    GetIt.I.registerLazySingleton<ZSideRPC>(() => MockZSideRPC());
    GetIt.I.registerLazySingleton<SidechainTransactionsProvider>(
      () => SidechainTransactionsProvider(),
    );
    GetIt.I.registerLazySingleton<TransactionsProvider>(
      () => TransactionsProvider(),
    );
    GetIt.I.registerLazySingleton<SidechainBalanceProvider>(
      () => SidechainBalanceProvider(sidechain: sidechainRPC),
    );
  });

  testWidgets(
    'a second tap on execute send during a send does not send again',
    (tester) async {
      final sendDone = Completer<String>();
      var sendCalls = 0;

      await tester.pumpSailPage(
        SendOnSidechainAction(
          customSendAction: (address, amount) {
            sendCalls++;
            return sendDone.future;
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField).at(0),
        'some-sidechain-address',
      );
      await tester.enterText(find.byType(TextField).at(1), '0.1');
      await tester.pump();

      final executeSend = tester.getCenter(find.text('Execute send').first);
      await tester.tapAt(executeSend);
      await tester.pump();
      expect(sendCalls, 1);

      await tester.tapAt(executeSend);
      await tester.pump();
      expect(sendCalls, 1);

      sendDone.complete('some-txid');
      await tester.pump();
      await tester.pump();
      expect(sendCalls, 1);
    },
  );
}
