import 'package:bitwindow/providers/fast_withdrawal_provider.dart';
import 'package:bitwindow/widgets/fast_withdrawal_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

class _Conf extends ChangeNotifier implements BitcoinConfProvider {
  @override
  bool get networkSupportsSidechains => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() {
    GetIt.I.registerSingleton<BitcoinConfProvider>(_Conf());
    GetIt.I.registerSingleton<FastWithdrawalProvider>(
      FastWithdrawalProvider()
        ..stage = FastWithdrawalStage.done
        ..l1Txid = 'a' * 64
        ..l2Txid = 'b' * 64,
    );
  });

  tearDown(() async {
    SailStyleValues.phoneLayoutOverride = null;
    await GetIt.I.reset();
  });

  Future<void> pumpForm(WidgetTester tester, double width) async {
    await tester.binding.setSurfaceSize(Size(width, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: SailTheme(
          data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
          child: const Scaffold(body: SingleChildScrollView(child: FastWithdrawalForm())),
        ),
      ),
    );
  }

  testWidgets('a phone shows a 16 px title at the left and the txids as rows', (tester) async {
    SailStyleValues.phoneLayoutOverride = true;
    await loadBundledFonts();
    await pumpForm(tester, 390);

    expect(tester.takeException(), isNull);
    final title = find.text('Withdrawal Completed');
    expect(tester.widget<Text>(title).style!.fontSize, 16);
    expect(tester.getRect(title).left, lessThan(80));
    expect(find.text('L1 TXID'), findsOneWidget);
    expect(find.text('L2 TXID'), findsOneWidget);
    expect(find.textContaining('L1 TXID:'), findsNothing);
    expect(find.byType(SailCard), findsOneWidget);
  });

  testWidgets('the desktop keeps the 24 px title and the txid lines', (tester) async {
    SailStyleValues.phoneLayoutOverride = false;
    await pumpForm(tester, 1000);

    expect(tester.widget<Text>(find.text('Withdrawal Completed')).style!.fontSize, 24);
    expect(find.text('L1 TXID: ${'a' * 64}'), findsOneWidget);
  });
}
