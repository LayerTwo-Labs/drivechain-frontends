import 'package:bitwindow/pages/wallet/bitdrive_page.dart';
import 'package:bitwindow/providers/bitdrive_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

import 'mocks/api_mock.dart';
import 'test_utils.dart';

class _RecordingBitDrive extends MockBitDriveAPI {
  final storedFeeRates = <int?>[];

  @override
  Future<StoreFileResponse> storeFile({
    required List<int> content,
    String? filename,
    String? mimeType,
    bool encrypt = false,
    int? feeSatPerVbyte,
  }) async {
    storedFeeRates.add(feeSatPerVbyte);
    return StoreFileResponse();
  }
}

class _Api extends MockAPI {
  _Api() : super(binaryType: BinaryType.BINARY_TYPE_BITWINDOWD);

  final recorder = _RecordingBitDrive();

  @override
  BitDriveAPI get bitdrive => recorder;
}

class _WalletReader extends ChangeNotifier implements WalletReaderProvider {
  @override
  String? get activeWalletId => 'qa';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Finder fieldWithHint(String hint) => find.descendant(
  of: find.byWidgetPredicate((w) => w is SailTextField && w.hintText == hint),
  matching: find.byType(EditableText),
);

void main() {
  late _Api api;

  setUp(() async {
    await GetIt.I.reset();
    api = _Api();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    GetIt.I.registerSingleton<BitwindowRPC>(api);
    GetIt.I.registerSingleton<WalletReaderProvider>(_WalletReader());
    await registerTestDependencies();
    GetIt.I.registerSingleton<BitDriveProvider>(BitDriveProvider());
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  Future<void> openStoreForm(WidgetTester tester) async {
    addTearDown(() => tester.pumpWidget(const SizedBox()));
    await tester.pumpSailPage(const BitDriveTab());
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Advanced settings'));
    await tester.pump();
    await tester.enterText(
      fieldWithHint('Write anything here...'),
      'hello',
    );
    await tester.pump();
  }

  Finder feeField() => fieldWithHint('1');

  Future<void> store(WidgetTester tester) async {
    final button = find.byWidgetPredicate((w) => w is SailButton && w.label == 'Store on Bitcoin');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 10));
  }

  testWidgets('a typed fee rate goes to the server in sat/vB', (tester) async {
    await openStoreForm(tester);
    expect(find.text('Fee rate (sat/vB)'), findsOneWidget);

    await tester.enterText(feeField(), '7');
    await tester.pump();
    await store(tester);

    expect(api.recorder.storedFeeRates, [7]);
  });

  testWidgets('the up arrow adds 1 sat/vB', (tester) async {
    await openStoreForm(tester);

    final up = find.byWidgetPredicate((w) => w is SailButton && w.icon == SailSVGAsset.arrowUp);
    await tester.ensureVisible(up);
    await tester.tap(up);
    await tester.pump();
    await store(tester);

    expect(api.recorder.storedFeeRates, [2]);
  });

  testWidgets('the down arrow stops at 1 sat/vB', (tester) async {
    await openStoreForm(tester);

    final down = find.byWidgetPredicate((w) => w is SailButton && w.icon == SailSVGAsset.arrowDown);
    await tester.ensureVisible(down);
    await tester.tap(down);
    await tester.pump();
    await store(tester);

    expect(api.recorder.storedFeeRates, [1]);
  });

  testWidgets('a fee rate below 1 disables Store', (tester) async {
    await openStoreForm(tester);

    await tester.enterText(feeField(), '0');
    await tester.pump();
    await store(tester);

    expect(api.recorder.storedFeeRates, isEmpty);
  });
}
