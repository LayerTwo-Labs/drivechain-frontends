import 'package:bitwindow/dialogs/paper_check_dialog.dart';
import 'package:bitwindow/dialogs/paper_wallet_dialog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

import 'mocks/api_mock.dart';
import 'test_utils.dart';

const _address = '1BgGZ9tcN4rm9KBzDn7KprQz87SZ26SAMH';

class _Utils extends MockUtilsAPI {
  Object? error;
  int calls = 0;

  @override
  Future<GeneratePaperWalletResponse> generatePaperWallet() async {
    calls++;
    if (error != null) {
      throw error!;
    }
    return GeneratePaperWalletResponse(
      publicAddress: _address,
      privateKeyWif: 'KwDiBf89QgGbjEhKnhXJuH7LrciVrZi3qYjgd9M7rFU73sVHnoWn',
      privateKeyHex: '0000000000000000000000000000000000000000000000000000000000000001',
    );
  }
}

class _Bitwindow extends MockAPI {
  _Bitwindow() : super(binaryType: BinaryType.BINARY_TYPE_BITWINDOWD);

  final _utils = _Utils();

  @override
  _Utils get utils => _utils;
}

void main() {
  late _Bitwindow bitwindow;

  setUp(() async {
    await GetIt.I.reset();
    bitwindow = _Bitwindow();
    GetIt.I.registerSingleton<BitwindowRPC>(bitwindow);
    await registerTestDependencies();
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  testWidgets('shows the address that bitwindowd generates', (tester) async {
    await tester.pumpSailPage(const PaperWalletDialog());
    await tester.pumpAndSettle();

    expect(bitwindow.utils.calls, 1);
    expect(find.text(_address), findsWidgets);
  });

  testWidgets('shows the reason when bitwindowd cannot generate a key', (tester) async {
    bitwindow.utils.error = Exception('bitwindowd is not running');

    await tester.pumpSailPage(const PaperWalletDialog());
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('bitwindowd is not running'), findsOneWidget);
    expect(find.text(_address), findsNothing);
    await tester.pump(const Duration(seconds: 10));
  });

  testWidgets('a failed new address drops the key of the previous check', (tester) async {
    await tester.pumpSailPage(const PaperCheckDialog());
    await tester.pumpAndSettle();
    expect(find.text(_address), findsWidgets);

    bitwindow.utils.error = Exception('bitwindowd is not running');
    await tester.tap(find.text('Generate New Address').first);
    await tester.pump();
    await tester.pump();

    expect(bitwindow.utils.calls, 2);
    expect(find.text(_address), findsNothing);
    final createCheck = tester.widget<SailButton>(find.widgetWithText(SailButton, 'Create Check').first);
    expect(createCheck.disabled, isTrue);
    await tester.pump(const Duration(seconds: 10));
  });
}
