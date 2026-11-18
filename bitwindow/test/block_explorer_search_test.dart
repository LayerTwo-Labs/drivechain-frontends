import 'package:bitwindow/pages/explorer/block_explorer_dialog.dart';
import 'package:connectrpc/connect.dart' as connect;
import 'package:connectrpc/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/bitcoin/bitcoind/v1alpha/bitcoin.connect.client.dart';
import 'package:sidechain_core/gen/bitcoin/bitcoind/v1alpha/bitcoin.connect.spec.dart';
import 'package:sidechain_core/gen/bitcoin/bitcoind/v1alpha/bitcoin.pb.dart';

import 'test_utils.dart';

class _Bitcoind {
  final requests = <GetBlockRequest>[];

  late final BitcoinServiceClient client = BitcoinServiceClient(
    FakeTransportBuilder().unary(BitcoinService.getBlock, (req, _) {
      requests.add(req);
      if (req.height == 7) {
        return GetBlockResponse(height: 7, hash: 'ab' * 32);
      }
      throw connect.ConnectException(connect.Code.unknown, 'Block height out of range');
    }).build(),
  );
}

class _Orchestrator implements OrchestratorRPC {
  final fake = _Bitcoind();

  @override
  BitcoinServiceClient get bitcoind => fake.client;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _Orchestrator orchestrator;

  setUp(() async {
    await GetIt.I.reset();
    orchestrator = _Orchestrator();
    GetIt.I.registerSingleton<OrchestratorRPC>(orchestrator);
  });

  tearDown(() => GetIt.I.reset());

  Future<void> search(WidgetTester tester, String query) async {
    await tester.enterText(find.byType(TextField), query);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.pump();
  }

  testWidgets('the Enter key searches, and a missing block shows an error', (tester) async {
    await tester.pumpSailPage(const BlockExplorerDialog());
    await tester.pump();

    await search(tester, '99999999');

    expect(orchestrator.fake.requests.single.height, 99999999);
    expect(find.text('No block at height 99999999.'), findsOneWidget);
  });

  testWidgets('a found block clears the error and opens the details', (tester) async {
    await tester.pumpSailPage(const BlockExplorerDialog());
    await tester.pump();

    await search(tester, '99999999');
    await search(tester, '7');

    expect(find.text('No block at height 99999999.'), findsNothing);
    expect(find.text('Block Details'), findsOneWidget);
  });

  test('blockSearchError names the missing height or hash', () {
    expect(
      blockSearchError('12', Exception('get block hash from height: -8: Block height out of range')),
      'No block at height 12.',
    );
    expect(blockSearchError('nothex', Exception("encoding/hex: invalid byte: U+006E 'n'")), 'No block with this hash.');
    expect(blockSearchError('abc', Exception('encoding/hex: odd length hex string')), 'No block with this hash.');
    expect(blockSearchError('ab' * 32, Exception('Block not found')), 'No block with this hash.');
    expect(
      blockSearchError('12', Exception('connection refused')),
      'Could not load the block. Make sure the node runs, and try again.',
    );
  });
}
