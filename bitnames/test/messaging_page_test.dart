import 'package:bitnames/pages/tabs/messaging_page.dart';
import 'package:bitnames/providers/bitnames_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:thirds/blake3.dart';

import 'test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized({
    'flutter.test.automatic_wait_for_timers': 'false',
  });

  late _MessagingRpc rpc;
  late BitnamesProvider provider;

  setUp(() async {
    await GetIt.I.reset();
    await registerTestDependencies();
    rpc = _MessagingRpc();
    GetIt.I.registerSingleton<BitnamesRPC>(rpc);
    provider = BitnamesProvider();
    GetIt.I.registerSingleton<BitnamesProvider>(provider);
  });

  tearDown(() async {
    provider.dispose();
    await GetIt.I.reset();
  });

  testWidgets('uses clear identity labels and preserves plaintext whitespace', (
    tester,
  ) async {
    await tester.pumpSailPage(const MessagingTabPage());
    await tester.pump();

    expect(
      find.text('Your BitName or encryption pubkey (Bech32m)'),
      findsOneWidget,
    );
    await tester.enterText(find.byType(TextField).at(0), 'recipient-key');
    await tester.enterText(find.byType(TextField).at(1), '  exact message  ');
    await tester.tap(find.byType(SailButton).first);
    await tester.pump();

    expect(rpc.encryptedPlaintext, '  exact message  ');
    expect(find.widgetWithText(ResultRow, 'Ciphertext'), findsOneWidget);
  });

  testWidgets('explains when a known BitName has no encryption key', (
    tester,
  ) async {
    rpc.entries = [
      BitnameEntry(
        hash: blake3Hex('legacy'.codeUnits),
        plaintextName: 'legacy',
        details: BitnameDetails(seqId: '1'),
      ),
    ];
    await provider.fetch();
    await tester.pumpSailPage(const MessagingTabPage());
    await tester.pump();

    await tester.enterText(find.byType(TextField).at(0), 'legacy');
    await tester.enterText(find.byType(TextField).at(1), 'hello');
    await tester.tap(find.byType(SailButton).first);
    await tester.pump();

    expect(find.textContaining('has no encryption key'), findsOneWidget);
    expect(rpc.encryptCalls, 0);
  });

  testWidgets('stacks cards at narrow width', (tester) async {
    await tester.pumpSailPage(const MessagingTabPage());
    await tester.binding.setSurfaceSize(const Size(700, 900));
    await tester.pump();

    final encrypt = tester.getTopLeft(find.text('Encrypt').first);
    final decrypt = tester.getTopLeft(find.text('Decrypt').first);
    expect(decrypt.dy, greaterThan(encrypt.dy));
  });
}

class _MessagingRpc extends MockBitnamesRPC {
  List<BitnameEntry> entries = [];
  int encryptCalls = 0;
  String? encryptedPlaintext;

  @override
  Future<List<BitnameEntry>> listBitNames() async => entries;

  @override
  Future<String> encryptMsg({
    required String msg,
    required String encryptionPubkey,
  }) async {
    encryptCalls++;
    encryptedPlaintext = msg;
    return 'ciphertext';
  }
}
