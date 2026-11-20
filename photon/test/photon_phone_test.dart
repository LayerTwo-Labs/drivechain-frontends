import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:photon/pages/tabs/mempool_explorer_page.dart';
import 'package:photon/pages/tabs/withdrawals_page.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

class _Rpc implements PhotonRPC {
  @override
  Future<List<SidechainUTXO>> listAllUTXOs() async => [];

  @override
  Future<PendingWithdrawalBundle?> getPendingWithdrawalBundle() async => null;

  @override
  Future<int?> getLatestFailedWithdrawalBundleHeight() async => 1262;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pump(WidgetTester tester, Widget child, {required bool phone}) async {
  SailStyleValues.phoneLayoutOverride = phone;
  await tester.binding.setSurfaceSize(Size(phone ? 390 : 1200, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      home: SailTheme(
        data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
        child: Scaffold(body: child),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
  addTearDown(() => tester.pumpWidget(const SizedBox()));
}

Finder _header(String name) => find.byWidgetPredicate((w) => w is SailTableHeaderCell && w.name == name);

BoxDecoration _bannerDecoration(WidgetTester tester) {
  final banner = find
      .ancestor(
        of: find.text('No pending withdrawal bundle'),
        matching: find.byWidgetPredicate((w) => w is Container && w.decoration is BoxDecoration),
      )
      .first;
  return tester.widget<Container>(banner).decoration! as BoxDecoration;
}

void main() {
  setUp(() async {
    await registerTestDependencies();
    GetIt.I.registerSingleton<PhotonRPC>(_Rpc());
  });

  tearDown(() async {
    SailStyleValues.phoneLayoutOverride = null;
    await GetIt.I.reset();
  });

  testWidgets('a phone lists the mempool totals in one panel', (tester) async {
    await _pump(tester, const MempoolExplorerPage(), phone: true);

    expect(tester.takeException(), isNull);
    expect(find.byType(SailStatList), findsOneWidget);
    expect(_header('Outpoint'), findsNothing);
    final value = tester.widget<SailTableHeaderCell>(find.widgetWithText(SailTableHeaderCell, 'Value'));
    expect(value.alignment, Alignment.centerRight);
  });

  testWidgets('a phone shows the withdrawal status on a neutral card with the red failure line', (tester) async {
    await _pump(tester, const WithdrawalsPage(), phone: true);

    expect(tester.takeException(), isNull);
    final theme = SailTheme.of(tester.element(find.text('No pending withdrawal bundle')));
    expect(_bannerDecoration(tester).color, theme.chrome.panel(theme.colors).color);
    final failure = tester.widget<Text>(find.text('Last failed bundle at height: 1262'));
    expect(failure.style!.color, theme.colors.error);
  });

  testWidgets('the desktop keeps the tinted withdrawal banner', (tester) async {
    await _pump(tester, const WithdrawalsPage(), phone: false);

    final theme = SailTheme.of(tester.element(find.text('No pending withdrawal bundle')));
    expect(_bannerDecoration(tester).color, theme.colors.orange.withValues(alpha: 0.1));
  });
}
