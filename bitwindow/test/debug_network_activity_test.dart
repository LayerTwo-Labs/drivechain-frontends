import 'package:bitwindow/pages/debug_window.dart';
import 'package:connectrpc/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/bitcoin/bitcoind/v1alpha/bitcoin.connect.client.dart';
import 'package:sidechain_core/gen/bitcoin/bitcoind/v1alpha/bitcoin.connect.spec.dart';
import 'package:sidechain_core/gen/bitcoin/bitcoind/v1alpha/bitcoin.pb.dart';

import 'test_utils.dart';

class _Orchestrator implements OrchestratorRPC {
  _Orchestrator({required bool networkActive, required bool initialBlockDownload})
    : _ibd = initialBlockDownload,
      bitcoind = BitcoinServiceClient(
        FakeTransportBuilder()
            .unary(BitcoinService.getNetworkInfo, (_, _) => GetNetworkInfoResponse(networkActive: networkActive))
            .build(),
      );

  final bool _ibd;

  @override
  final BitcoinServiceClient bitcoind;

  @override
  Future<GetMainchainBlockchainInfoResponse> getMainchainBlockchainInfo() async =>
      GetMainchainBlockchainInfoResponse(chain: 'regtest', initialBlockDownload: _ibd);

  @override
  Future<GetCoreMempoolInfoResponse> getCoreMempoolInfo() async => GetCoreMempoolInfoResponse();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Conf extends ChangeNotifier implements BitcoinConfProvider {
  @override
  BitcoinNetwork network = BitcoinNetwork.BITCOIN_NETWORK_REGTEST;

  @override
  String ecashNetworkId = '';

  @override
  String? get detectedDataDir => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  tearDown(() => GetIt.I.reset());

  Future<String> networkActivity(WidgetTester tester, {required bool active, required bool ibd}) async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<OrchestratorRPC>(_Orchestrator(networkActive: active, initialBlockDownload: ibd));
    GetIt.I.registerSingleton<BitcoinConfProvider>(_Conf());
    await tester.pumpSailPage(const InformationTab());
    await tester.pump();
    final row = find.ancestor(of: find.text('Network Activity'), matching: find.byType(Row)).first;
    final value = find.descendant(of: row, matching: find.byType(Expanded));
    return tester.widget<Text>(find.descendant(of: value, matching: find.byType(Text)).first).data!;
  }

  testWidgets('a node with the network off reads as disabled', (tester) async {
    expect(await networkActivity(tester, active: false, ibd: false), 'Disabled');
  });

  testWidgets('a node in its initial block download reads as enabled', (tester) async {
    expect(await networkActivity(tester, active: true, ibd: true), 'Enabled');
  });
}
