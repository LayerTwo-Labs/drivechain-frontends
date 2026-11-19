import 'package:bitwindow/pages/wallet/denial_dialog.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

class _FakeTransactionProvider extends ChangeNotifier implements TransactionProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeOrchestratorWallet implements OrchestratorWalletRPC {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeOrchestrator implements OrchestratorRPC {
  @override
  OrchestratorWalletRPC wallet = _FakeOrchestratorWallet();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadBundledFonts();
  });

  setUp(() async {
    await GetIt.I.reset();
    await registerTestDependencies();
    GetIt.I.registerSingleton<TransactionProvider>(_FakeTransactionProvider());
    GetIt.I.registerSingleton<OrchestratorRPC>(_FakeOrchestrator());
  });

  tearDown(() => GetIt.I.reset());

  testWidgets('the dialog allows one target size per hop', (tester) async {
    await tester.pumpSailPage(
      Theme(
        data: ThemeData(fontFamily: SailFonts.inter),
        child: DenialDialog(output: '${'a' * 64}:0', valueSats: 100000000),
      ),
    );
    await tester.pumpAndSettle();

    final fields = find.descendant(of: find.byType(DenialDialog), matching: find.byType(SailTextField));
    final hops = tester.widget<SailTextField>(fields.at(3)).controller;
    hops.text = '2';
    await tester.pump();

    await tester.tap(find.text('+ Add target size'));
    await tester.pumpAndSettle();
    for (var i = 0; i < 5 && find.text('+').evaluate().isNotEmpty; i++) {
      await tester.tap(find.text('+'));
      await tester.pumpAndSettle();
    }

    expect(fields.evaluate().length - 4, 2);
    expect(find.text('+'), findsNothing);
  });
}
