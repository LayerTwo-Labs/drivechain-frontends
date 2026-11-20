import 'package:fixnum/fixnum.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart';

class _Store implements KeyValueStore {
  final _values = <String, String>{};

  @override
  Future<String?> getString(String key) async => _values[key];

  @override
  Future<void> setString(String key, String value) async => _values[key] = value;

  @override
  Future<void> delete(String key) async => _values.remove(key);

  @override
  Future<void> update(String key, String Function(String? current) change) async {
    await setString(key, change(await getString(key)));
  }
}

final _details = GetTransactionDetailsResponse(
  feeSats: Int64(226),
  inputs: [
    TransactionInput(valueSats: Int64(75000000), address: 'ecash:qz8f3m2abcdefghijklmnopv0k9e'),
    TransactionInput(valueSats: Int64(25000226), address: 'ecash:qr4p0x7abcdefghijklmnopd2h6s'),
  ],
  outputs: [
    TransactionOutput(valueSats: Int64(90000000), address: 'ecash:qp9k2d1abcdefghijklmnm3x8r'),
    TransactionOutput(valueSats: Int64(10000000), address: 'ecash:qz7c5n4abcdefghijklmnt1w0a'),
  ],
);

Widget _diagram(double width) {
  return SailTheme(
    data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: width,
          child: TransactionDiagram(details: _details, changeAddresses: const {'ecash:qz7c5n4abcdefghijklmnt1w0a'}),
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() async {
    final log = Logger();
    GetIt.I.registerSingleton<Logger>(log);
    GetIt.I.registerSingleton<ClientSettings>(ClientSettings(store: _Store(), log: log));
    GetIt.I.registerSingleton<BitwindowClientSettings>(BitwindowClientSettings(store: _Store(), log: log));
    final settings = await SettingsProvider.create();
    GetIt.I.registerSingleton<SettingsProvider>(settings);
    GetIt.I.registerSingleton<FormatterProvider>(FormatterProvider(settings));
  });

  tearDownAll(() => GetIt.I.reset());

  tearDown(() => SailStyleValues.phoneLayoutOverride = null);

  String sats(int value) => GetIt.I.get<FormatterProvider>().formatSats(value);

  testWidgets('on a phone the diagram stacks inputs, the fee and outputs', (tester) async {
    SailStyleValues.phoneLayoutOverride = true;
    await tester.pumpWidget(_diagram(358));

    final inputs = tester.getRect(find.text('Inputs (2)'));
    final lastInput = tester.getRect(find.text(sats(25000226)));
    final fee = tester.getRect(find.text('Fee'));
    final feeAmount = tester.getRect(find.text(sats(226)));
    final outputs = tester.getRect(find.text('Outputs (2)'));
    final firstOutput = tester.getRect(find.text(sats(90000000)));

    expect(lastInput.top, greaterThan(inputs.bottom));
    expect(fee.top, greaterThan(lastInput.bottom));
    expect(feeAmount.top, closeTo(fee.top, 2));
    expect(feeAmount.left, greaterThan(fee.right));
    expect(outputs.top, greaterThan(fee.bottom));
    expect(firstOutput.top, greaterThan(outputs.bottom));
    expect(firstOutput.left, closeTo(lastInput.left, 4));
    expect(tester.getSize(find.text(sats(90000000))).height, tester.getSize(find.text('Fee')).height);
    expect(find.text('change'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('on the desktop the inputs and outputs sit side by side', (tester) async {
    SailStyleValues.phoneLayoutOverride = false;
    await tester.pumpWidget(_diagram(800));

    final input = tester.getRect(find.text(sats(75000000)));
    final output = tester.getRect(find.text(sats(90000000)));
    expect(output.left, greaterThan(input.right));
    expect(tester.getRect(find.text(sats(226))).top, greaterThan(tester.getRect(find.text('Fee')).bottom - 1));
  });
}
