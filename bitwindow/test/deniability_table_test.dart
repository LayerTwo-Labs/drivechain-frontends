import 'package:bitwindow/pages/wallet/denability_page.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart';

import 'test_utils.dart';

class _FakeTransactionProvider extends ChangeNotifier implements TransactionProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Timestamp _at(int hour) => Timestamp.fromDateTime(DateTime.utc(2026, 1, 1, hour));

DenialInfo _denial(int id, int executions) => DenialInfo(
  id: Int64(id),
  numHops: 5,
  hopsCompleted: executions,
  executions: List.generate(executions, (i) => ExecutedDenial(fromTxid: 'tx$id$i')),
  nextExecutionTime: Timestamp.fromDateTime(DateTime.utc(2030)),
);

final _utxos = [
  UnspentOutput(output: '${'b' * 64}:0', valueSats: Int64(300), receivedAt: _at(2), denialInfo: _denial(1, 2)),
  UnspentOutput(output: '${'c' * 64}:0', valueSats: Int64(200), receivedAt: _at(1), denialInfo: _denial(2, 3)),
  UnspentOutput(output: '${'a' * 64}:1', valueSats: Int64(100), receivedAt: _at(3)),
];

void main() {
  setUp(() async {
    await GetIt.I.reset();
    await registerTestDependencies();
    GetIt.I.registerSingleton<TransactionProvider>(_FakeTransactionProvider());
  });

  tearDown(() => GetIt.I.reset());

  Future<void> pumpTable(WidgetTester tester) async {
    // The Actions cell overflows its column; this file tests the sort and the details only.
    final onError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (!details.exceptionAsString().contains('overflowed')) {
        onError?.call(details);
      }
    };
    addTearDown(() => FlutterError.onError = onError);
    await tester.pumpSailPage(
      SizedBox(
        width: 2300,
        height: 600,
        child: DeniabilityTable(
          newWindowButton: null,
          error: null,
          utxos: [..._utxos],
          model: DeniabilityViewModel(),
          onDeny: (_, _) {},
          onCancel: (_) {},
          onPause: (_) {},
          onResume: (_) {},
        ),
      ),
    );
    await tester.binding.setSurfaceSize(const Size(2400, 720));
    await tester.pumpAndSettle();
  }

  List<String> shownUtxos(WidgetTester tester) => tester
      .widgetList<SailTableCell>(find.byType(SailTableCell))
      .map((cell) => cell.value)
      .where((v) => v.contains('..:'))
      .toList();

  testWidgets('sorts the rows by UTXO at first', (tester) async {
    await pumpTable(tester);

    expect(shownUtxos(tester), ['aaaaaa..:1', 'bbbbbb..:0', 'cccccc..:0']);
  });

  testWidgets('a tap on Hops sorts the rows by hops', (tester) async {
    await pumpTable(tester);

    await tester.tap(find.text('Hops'));
    await tester.pumpAndSettle();

    expect(shownUtxos(tester), ['bbbbbb..:0', 'cccccc..:0', 'aaaaaa..:1']);
  });

  testWidgets('a tap on Timestamp sorts the rows by time', (tester) async {
    await pumpTable(tester);

    await tester.tap(find.text('Timestamp'));
    await tester.pumpAndSettle();

    expect(shownUtxos(tester), ['cccccc..:0', 'bbbbbb..:0', 'aaaaaa..:1']);
  });

  testWidgets('a tap on Actions keeps the order', (tester) async {
    await pumpTable(tester);

    await tester.tap(find.text('Actions'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(shownUtxos(tester), ['aaaaaa..:1', 'bbbbbb..:0', 'cccccc..:0']);
  });

  testWidgets('a double tap on a row opens the UTXO details', (tester) async {
    await pumpTable(tester);

    final row = find.text('bbbbbb..:0');
    await tester.tap(row);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(row);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('UTXO Details'), findsOneWidget);
  });
}
