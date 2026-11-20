import 'package:bitwindow/pages/wallet/denability_page.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart';

import 'test_utils.dart';

class _FakeTransactionProvider extends ChangeNotifier implements TransactionProvider {
  @override
  List<UnspentOutput> utxos = [
    UnspentOutput(
      output: '${'a' * 64}:0',
      valueSats: Int64(1000),
      denialInfo: DenialInfo(id: Int64(4), numHops: 3, nextExecutionTime: Timestamp.fromDateTime(DateTime.utc(2030))),
    ),
    UnspentOutput(output: '${'b' * 64}:0', valueSats: Int64(2000)),
  ];

  @override
  Future<void> fetch() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Future<void> _pump(WidgetTester tester, {required bool phone}) async {
  SailStyleValues.phoneLayoutOverride = phone;
  await tester.pumpSailPage(const DeniabilityTab(newWindowButton: null));
  if (phone) {
    await tester.binding.setSurfaceSize(const Size(390, 844));
  }
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadBundledFonts);

  setUp(() async {
    await GetIt.I.reset();
    await registerTestDependencies();
    GetIt.I.registerSingleton<TransactionProvider>(_FakeTransactionProvider());
  });

  tearDown(() async {
    SailStyleValues.phoneLayoutOverride = null;
    await GetIt.I.reset();
  });

  testWidgets('on a phone a small Deny All sits in the card head in place of the large button', (tester) async {
    await _pump(tester, phone: true);

    expect(tester.takeException(), isNull);
    expect(find.byType(DenyAllButton), findsNothing);
    final denyAll = find.widgetWithText(SailButton, 'Deny All');
    expect(denyAll, findsOneWidget);
    expect(tester.widget<SailButton>(denyAll).small, isTrue);
    final title = tester.getRect(find.text('Your UTXOs with denial info'));
    expect(tester.getRect(denyAll).top, lessThan(title.bottom));
  });

  testWidgets('on a phone each UTXO is a two-line row with the amount over the denial ID', (tester) async {
    await _pump(tester, phone: true);

    expect(find.byType(SailTable), findsNothing);
    final formatter = GetIt.I<FormatterProvider>();
    final amount = tester.getRect(find.text(formatter.formatSats(1000)));
    final id = tester.getRect(find.text('Denial ID 4'));
    expect(id.top, greaterThan(amount.bottom - 1));
    expect(id.left, amount.left);
    expect(find.text('Denial ID -'), findsOneWidget);

    expect(tester.getRect(find.text('Pause')).left, greaterThan(amount.right));
    for (final label in ['Pause', 'Cancel', 'Deny']) {
      expect(tester.widget<SailButton>(find.widgetWithText(SailButton, label)).variant, ButtonVariant.outline);
    }
  });

  testWidgets('the desktop keeps the large Deny All button and the table', (tester) async {
    await _pump(tester, phone: false);

    expect(find.byType(DenyAllButton), findsOneWidget);
    expect(find.byType(SailTable), findsOneWidget);
    expect(find.text('Denial ID 4'), findsNothing);
  });
}
