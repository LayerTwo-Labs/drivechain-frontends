import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/pages/sidechains/sidechain_overview_page.dart';
import 'package:sail_ui/sail_ui.dart';

class _FakeTransactionsProvider extends ChangeNotifier implements SidechainTransactionsProvider {
  @override
  List<CoreTransaction> sidechainTransactions = [];

  @override
  Future<void> fetch() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(Widget child) {
  return MaterialApp(
    home: SailTheme(
      data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
      child: Scaffold(body: SizedBox(width: 390, height: 600, child: child)),
    ),
  );
}

void main() {
  tearDown(() {
    SailStyleValues.phoneLayoutOverride = null;
    GetIt.I.reset();
  });

  testWidgets('the balance rows show total, available and pending in one column', (tester) async {
    await tester.pumpWidget(
      _app(
        const Align(
          alignment: Alignment.topLeft,
          child: SidechainBalanceRows(total: '1.10000000', available: '1.00000000', pending: '0.10000000'),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    final total = tester.getRect(find.text('Total'));
    final available = tester.getRect(find.text('Available'));
    final pending = tester.getRect(find.text('Pending'));
    expect(available.top, greaterThan(total.bottom));
    expect(pending.top, greaterThan(available.bottom));
    expect(tester.getRect(find.text('1.10000000')).right, closeTo(390, 1));
  });

  for (final (phone, header) in [(true, 'Conf.'), (false, 'Confirmations')]) {
    testWidgets('the history header reads $header when phoneLayout is $phone', (tester) async {
      SailStyleValues.phoneLayoutOverride = phone;
      GetIt.I.registerSingleton<SidechainTransactionsProvider>(_FakeTransactionsProvider());

      await tester.pumpWidget(
        _app(TransactionTable(model: LatestWalletTransactionsViewModel(), searchWidget: const SizedBox())),
      );
      await tester.pumpAndSettle();

      expect(find.text(header), findsOneWidget);
    });
  }
}
