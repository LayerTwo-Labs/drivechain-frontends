import 'package:bitwindow/pages/wallet/wallet_multisig_lounge.dart';
import 'package:bitwindow/providers/hd_wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'test_utils.dart';

class _FakeHd extends ChangeNotifier implements HDWalletProvider {
  @override
  bool get isInitialized => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(loadBundledFonts);

  setUp(() async {
    await GetIt.I.reset();
    await registerTestDependencies();
    GetIt.I.registerSingleton<HDWalletProvider>(_FakeHd());
  });

  tearDown(() => GetIt.I.reset());

  testWidgets('leaving the Multisig Lounge disposes its model once', (tester) async {
    await tester.pumpSailPage(const MultisigLoungeTab());
    await tester.pump();

    await tester.pumpWidget(const SizedBox());

    expect(tester.takeException(), isNull);
  });
}
