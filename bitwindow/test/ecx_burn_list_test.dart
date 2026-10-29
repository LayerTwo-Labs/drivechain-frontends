import 'dart:async';

import 'package:bitwindow/widgets/ecx_burn_list.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

import 'test_utils.dart';

class _FakeRpc implements OrchestratorWalletRPC {
  final responses = <Future<wmpb.ListEcxBurnsResponse> Function()>[];
  int calls = 0;

  final requests = <({String networkId, String coreUrl, String coreCookiePath})>[];

  @override
  Future<wmpb.ListEcxBurnsResponse> listEcxBurns({
    String networkId = '',
    String coreUrl = '',
    String coreCookiePath = '',
  }) {
    requests.add((networkId: networkId, coreUrl: coreUrl, coreCookiePath: coreCookiePath));
    return responses[calls++]();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeOrchestrator implements OrchestratorRPC {
  @override
  final OrchestratorWalletRPC wallet;

  _FakeOrchestrator(this.wallet);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

wmpb.ListEcxBurnsResponse _response() => wmpb.ListEcxBurnsResponse(
  burns: [
    wmpb.EcxBurn(
      txid: 'bd85f724c6adfa7eaa41b22e6a752eb77bcf8408f8438f48cd5bc51d0cf876bc',
      burnSats: Int64(1388900019620),
      payoutAddress: 'bc1q09fs5766lx954ezwr2fd0xhg2605fcatjzlnvg',
      payoutSats: Int64(27778000393),
    ),
    wmpb.EcxBurn(
      txid: '60756af0e7e5bf05797c352706cff2fb5d45664f1105a420fcc6f104cb4d5fe6',
      height: Int64(974041),
      burnSats: Int64(700000000000),
      payoutAddress: 'bc1qgkavkjygu5d952s7kspkyp3q2vrgg99rsuz2z5',
      payoutSats: Int64(14000000000),
    ),
  ],
  totalBurnSats: Int64(2088900019620),
  totalPayoutSats: Int64(41778000393),
  payoutAddressCount: Int64(2),
  csv: 'burn_amount,payout_address,payout_amount\n',
);

void main() {
  late _FakeRpc rpc;

  setUp(() async {
    await GetIt.I.reset();
    rpc = _FakeRpc();
    GetIt.I.registerSingleton<OrchestratorRPC>(_FakeOrchestrator(rpc));
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  Future<void> pumpList(WidgetTester tester) async {
    await tester.pumpSailPage(
      const SizedBox(
        width: 1200,
        height: 900,
        child: EcxBurnList(networkName: 'Betanet', networkId: 'betanet'),
      ),
    );
  }

  testWidgets('shows every burn with its payout and the totals', (tester) async {
    rpc.responses.add(() async => _response());
    await pumpList(tester);
    await tester.pumpAndSettle();

    expect(find.text('Betanet burns'), findsOneWidget);
    expect(find.text('20,889.00019620 ${activeTicker.symbol}'), findsOneWidget);
    expect(find.text('417.78000393 ECX'), findsOneWidget);
    expect(find.text('2 burns · newest first'), findsOneWidget);
    expect(find.text('bc1q09fs5766lx954ezwr2fd0xhg2605fcatjzlnvg'), findsOneWidget);
    expect(find.text('13,889.00019620 ${activeTicker.symbol}'), findsOneWidget);
    expect(find.text('277.78000393 ECX'), findsOneWidget);
    expect(find.text('Unconfirmed'), findsOneWidget);
    expect(find.text('974041'), findsOneWidget);
    expect(find.text('140.00000000 ECX'), findsOneWidget);
    final download = tester.widget<SailButton>(
      find.byWidgetPredicate((widget) => widget is SailButton && widget.label == 'Download CSV'),
    );
    expect(download.disabled, isFalse);
  });

  testWidgets('shows the error and loads again on a retry', (tester) async {
    rpc.responses.add(() async => throw Exception('esplora is down'));
    rpc.responses.add(() async => _response());
    await pumpList(tester);
    await tester.pumpAndSettle();

    expect(find.textContaining('The burn list did not load'), findsOneWidget);
    await tester.tap(find.byWidgetPredicate((widget) => widget is SailButton && widget.label == 'Try again'));
    await tester.pumpAndSettle();

    expect(rpc.calls, 2);
    expect(find.textContaining('The burn list did not load'), findsNothing);
    expect(find.text('2 burns · newest first'), findsOneWidget);
  });

  testWidgets('turns the download off when no burn exists', (tester) async {
    rpc.responses.add(() async => wmpb.ListEcxBurnsResponse(csv: 'burn_amount,payout_address,payout_amount\n'));
    await pumpList(tester);
    await tester.pumpAndSettle();

    expect(find.text('No burns'), findsOneWidget);
    final download = tester.widget<SailButton>(
      find.byWidgetPredicate((widget) => widget is SailButton && widget.label == 'Download CSV'),
    );
    expect(download.disabled, isTrue);
  });

  testWidgets('shows a loading state until the list arrives', (tester) async {
    final pending = Completer<wmpb.ListEcxBurnsResponse>();
    rpc.responses.add(() => pending.future);
    await pumpList(tester);
    await tester.pump();

    expect(find.byType(LoadingIndicator), findsOneWidget);
    pending.complete(_response());
    await tester.pumpAndSettle();
    expect(find.byType(LoadingIndicator), findsNothing);
  });

  testWidgets('reads alphanet burns from the node the user names', (tester) async {
    rpc.responses.add(() async => _response());
    await tester.pumpSailPage(
      const SizedBox(
        width: 1200,
        height: 900,
        child: EcxBurnList(networkName: 'Alphanet', networkId: 'alphanet'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Alphanet burns'), findsOneWidget);
    expect(rpc.calls, 0, reason: 'nothing loads before the user names a node');

    await tester.enterText(find.byType(TextField).at(1), '/data/alphanet/.cookie');
    await tester.tap(find.byWidgetPredicate((widget) => widget is SailButton && widget.label == 'Load'));
    await tester.pumpAndSettle();

    expect(rpc.requests.single, (
      networkId: 'alphanet',
      coreUrl: 'http://127.0.0.1:18302',
      coreCookiePath: '/data/alphanet/.cookie',
    ));
    expect(find.text('2 burns · newest first'), findsOneWidget);
  });

  testWidgets('lists the running network without a node', (tester) async {
    rpc.responses.add(() async => _response());
    await pumpList(tester);
    await tester.pumpAndSettle();

    expect(rpc.requests.single, (networkId: '', coreUrl: '', coreCookiePath: ''));
    expect(find.text('Node RPC URL'), findsNothing);
  });
}
