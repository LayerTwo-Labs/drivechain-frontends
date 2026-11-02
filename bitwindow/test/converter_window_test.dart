import 'dart:async';

import 'package:bitwindow/widgets/converter_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

import 'mocks/api_mock.dart';
import 'test_utils.dart';

class _Utils extends MockUtilsAPI {
  final gates = <String, Completer<void>>{};

  @override
  Future<ConvertResponse> convert(String input, ConvertFormat format) async {
    await gates[input]?.future;
    return ConvertResponse(
      detected: ConvertFormat.CONVERT_FORMAT_ASCII,
      encodings: [ConvertRow(label: 'ASCII', value: 'value of $input')],
    );
  }
}

class _Bitwindow extends MockAPI {
  _Bitwindow() : super(binaryType: BinaryType.BINARY_TYPE_BITWINDOWD);

  final _utils = _Utils();

  @override
  _Utils get utils => _utils;
}

class _Conf extends ChangeNotifier implements BitcoinConfProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _Bitwindow bitwindow;

  setUp(() async {
    await GetIt.I.reset();
    bitwindow = _Bitwindow();
    GetIt.I.registerSingleton<BitwindowRPC>(bitwindow);
    GetIt.I.registerSingleton<BitcoinConfProvider>(_Conf());
    await registerTestDependencies();
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  testWidgets('a slow answer for an old input does not replace the new one', (tester) async {
    final slow = Completer<void>();
    bitwindow.utils.gates['first'] = slow;

    await tester.pumpSailPage(const ConverterWindow());
    await tester.enterText(find.byType(SailTextField).first, 'first');
    await tester.pump(const Duration(milliseconds: 200));
    await tester.enterText(find.byType(SailTextField).first, 'second');
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();

    expect(find.text('value of second'), findsOneWidget);

    slow.complete();
    await tester.pump();
    await tester.pump();

    expect(find.text('value of second'), findsOneWidget);
    expect(find.text('value of first'), findsNothing);
  });
}
