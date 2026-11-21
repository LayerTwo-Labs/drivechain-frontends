import 'dart:async';

import 'package:bitwindow/pages/wallet/check_detail_page.dart';
import 'package:bitwindow/providers/check_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart' as bwpb;

import 'test_utils.dart';

const _address = 'bcrt1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq';

class _FakeCheckProvider extends ChangeNotifier implements CheckProvider {
  final reply = Completer<bwpb.Cheque?>();

  @override
  List<bwpb.Cheque> checks = [
    bwpb.Cheque(id: Int64(1), derivationIndex: 1, address: _address, expectedAmountSats: Int64(100000)),
  ];

  @override
  Future<bwpb.Cheque?> getCheck(int id) => reply.future;

  @override
  void startPolling(int checkId, {Duration interval = const Duration(seconds: 5)}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeTransactions extends ChangeNotifier implements TransactionProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeWalletReader extends ChangeNotifier implements WalletReaderProvider {
  @override
  String? activeWalletId = 'wallet-1';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeOrchestratorWallet implements OrchestratorWalletRPC {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeOrchestrator implements OrchestratorRPC {
  @override
  OrchestratorWalletRPC wallet = _FakeOrchestratorWallet();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() async {
    await GetIt.I.reset();
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  testWidgets('a check the provider holds shows before its fetch ends', (tester) async {
    GetIt.I.registerSingleton<CheckProvider>(_FakeCheckProvider());
    GetIt.I.registerSingleton<TransactionProvider>(_FakeTransactions());
    GetIt.I.registerSingleton<WalletReaderProvider>(_FakeWalletReader());
    GetIt.I.registerSingleton<OrchestratorRPC>(_FakeOrchestrator());

    await tester.pumpSailPage(const CheckDetailPage(checkId: 1));
    await tester.pump();

    expect(find.byType(LoadingIndicator), findsNothing);
    expect(find.textContaining('Check for 0.00100000'), findsOneWidget);
  });

  testWidgets('the check QR in the dark theme draws light modules', (tester) async {
    GetIt.I.registerSingleton<CheckProvider>(_FakeCheckProvider());
    GetIt.I.registerSingleton<TransactionProvider>(_FakeTransactions());
    GetIt.I.registerSingleton<WalletReaderProvider>(_FakeWalletReader());
    GetIt.I.registerSingleton<OrchestratorRPC>(_FakeOrchestrator());
    final dark = SailThemeData.darkTheme(
      SailColorScheme.orange,
      false,
      SailFontValues.inter,
      SailThemeStyle.bitwindowV2,
    );

    await tester.pumpSailPage(SailTheme(data: dark, child: const CheckDetailPage(checkId: 1)));
    await tester.pump();

    final qr = tester.widget<QrImageView>(find.byType(QrImageView));
    expect(qr.backgroundColor, dark.colors.backgroundSecondary);
    expect(qr.dataModuleStyle.color, dark.colors.text);
    expect(qr.eyeStyle.color, dark.colors.text);
    expect(qr.dataModuleStyle.dataModuleShape, QrDataModuleShape.square);
  });
}
