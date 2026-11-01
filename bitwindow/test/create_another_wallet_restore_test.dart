import 'package:bitwindow/pages/welcome/create_another_wallet_page.dart';
import 'package:bitwindow/pages/welcome/multisig_config_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

class _FakeWallet implements OrchestratorWalletRPC {
  @override
  Future<wmpb.ListDerivationPathsResponse> listDerivationPaths({
    required String scriptType,
    required bool multisig,
    int account = 0,
  }) async => wmpb.ListDerivationPathsResponse(defaultPath: "m/84'/1'/0'");

  @override
  Future<List<wmpb.HardwareDevice>> enumerateHardwareDevices({String? passphrase}) async => [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeOrchestrator implements OrchestratorRPC {
  @override
  final OrchestratorWalletRPC wallet = _FakeWallet();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    GetIt.I.registerSingleton<OrchestratorRPC>(_FakeOrchestrator());
  });

  tearDown(() async => GetIt.I.reset());

  testWidgets('a finished restore closes setup', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      SailTheme(
        data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
        child: MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute<void>(builder: (_) => const CreateAnotherWalletPage())),
              child: const Text('Open setup'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open setup'));
    await tester.pumpAndSettle();
    expect(find.byType(CreateAnotherWalletPage), findsOneWidget);

    final step = tester.widget<MultisigConfigStep>(find.byType(MultisigConfigStep));
    step.onRestoringChanged!(true);
    await tester.pump();
    final restored = step.onRestored!();
    await tester.pumpAndSettle();
    await restored;

    expect(find.byType(CreateAnotherWalletPage), findsNothing);
    expect(find.text('Open setup'), findsOneWidget);
  });
}
