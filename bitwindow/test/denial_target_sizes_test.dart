import 'package:bitwindow/pages/wallet/denial_dialog.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

import 'mocks/api_mock.dart';
import 'test_utils.dart';

class _FakeTransactionProvider extends ChangeNotifier implements TransactionProvider {
  @override
  Future<void> fetch() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeWallet implements OrchestratorWalletRPC {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeOrchestrator implements OrchestratorRPC {
  @override
  final OrchestratorWalletRPC wallet = _FakeWallet();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _RecordingBitwindowd extends MockBitwindowdAPI {
  final List<List<int>?> targetSizes = [];

  @override
  Future<void> createDenial({
    required String txid,
    required int vout,
    required int numHops,
    required int delaySeconds,
    List<int>? targetUtxoSizes,
  }) async {
    targetSizes.add(targetUtxoSizes);
  }
}

class _RecordingAPI extends MockAPI {
  _RecordingAPI() : super(binaryType: BinaryType.BINARY_TYPE_BITWINDOWD);

  final recorder = _RecordingBitwindowd();

  @override
  BitwindowAPI get bitwindowd => recorder;
}

Finder _dialogFields() => find.descendant(of: find.byType(DenialDialog), matching: find.byType(EditableText));

Finder _hopsField() => _dialogFields().at(3);

Future<void> _addTargetSizes(WidgetTester tester, int taps) async {
  await tester.tap(find.text('+ Add target size'));
  await tester.pumpAndSettle();
  for (var i = 0; i < taps; i++) {
    final plus = find.text('+');
    if (plus.evaluate().isEmpty) {
      return;
    }
    await tester.tap(plus);
    await tester.pumpAndSettle();
  }
}

void main() {
  late _RecordingAPI api;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadBundledFonts();
  });

  setUp(() async {
    await GetIt.I.reset();
    api = _RecordingAPI();
    GetIt.I.registerSingleton<BitwindowRPC>(api);
    GetIt.I.registerSingleton<OrchestratorRPC>(_FakeOrchestrator());
    GetIt.I.registerSingleton<TransactionProvider>(_FakeTransactionProvider());
  });

  tearDown(() => GetIt.I.reset());

  Future<void> pumpDialog(WidgetTester tester) async {
    // The test font draws the delay row wider than the app font; this file tests the target sizes only.
    final onError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (!details.exceptionAsString().contains('overflowed')) {
        onError?.call(details);
      }
    };
    addTearDown(() => FlutterError.onError = onError);
    await tester.pumpSailPage(
      SizedBox(
        width: 900,
        height: 700,
        child: DenialDialog(output: '${'a' * 64}:0', valueSats: 100000000),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the dialog offers one target size per hop', (tester) async {
    await pumpDialog(tester);

    await _addTargetSizes(tester, 10);

    expect(_dialogFields(), findsNWidgets(4 + 3));
    expect(find.text('+'), findsNothing);
  });

  testWidgets('a lower hop count hides the target sizes above it and keeps them', (tester) async {
    await pumpDialog(tester);
    await _addTargetSizes(tester, 2);

    await tester.enterText(_hopsField(), '1');
    await tester.pumpAndSettle();
    expect(_dialogFields(), findsNWidgets(4 + 1));

    await tester.enterText(_hopsField(), '5');
    await tester.pumpAndSettle();
    expect(_dialogFields(), findsNWidgets(4 + 3));
    expect(find.text('+'), findsOneWidget);
  });

  testWidgets('each target size that shows reaches the server', (tester) async {
    await pumpDialog(tester);
    await _addTargetSizes(tester, 10);
    for (var i = 4; i < 7; i++) {
      await tester.enterText(_dialogFields().at(i), '0.0$i');
    }
    await tester.enterText(_hopsField(), '2');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    expect(api.recorder.targetSizes, hasLength(1));
    final sent = api.recorder.targetSizes.single!;
    expect(sent, hasLength(2));
    expect(sent.toSet(), {4000000, 5000000});
  });
}
