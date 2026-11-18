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

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadBundledFonts();
  });

  setUp(() async {
    await GetIt.I.reset();
    await registerTestDependencies();
    GetIt.I.registerSingleton<TransactionProvider>(_FakeTransactionProvider());
  });

  tearDown(() => GetIt.I.reset());

  testWidgets('the Pause and Cancel buttons fit in the Actions column', (tester) async {
    await tester.pumpSailPage(
      SizedBox(
        width: 1100,
        height: 600,
        child: DeniabilityTable(
          newWindowButton: null,
          error: null,
          utxos: [
            UnspentOutput(
              output: '${'a' * 64}:0',
              valueSats: Int64(1000),
              denialInfo: DenialInfo(
                id: Int64(1),
                numHops: 3,
                nextExecutionTime: Timestamp.fromDateTime(DateTime.utc(2030)),
              ),
            ),
            UnspentOutput(output: '${'b' * 64}:0', valueSats: Int64(2000)),
          ],
          model: DeniabilityViewModel(),
          onDeny: (_, _) {},
          onCancel: (_) {},
          onPause: (_) {},
          onResume: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pause'), findsWidgets);
    expect(find.text('Cancel'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
