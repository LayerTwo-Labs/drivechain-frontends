import 'package:bitwindow/pages/wallet/widgets/transaction_graph_card.dart';
import 'package:bitwindow/widgets/tx_flow_diagram.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void main() {
  group('graphLabelTops', () {
    test('a row sits at its band center', () {
      expect(graphLabelTops([50, 150], 20, 200), [40, 140]);
    });

    test('rows of thin bands do not overlap', () {
      expect(graphLabelTops([100, 104, 108], 20, 300), [90, 110, 130]);
    });

    test('rows that run past the bottom move up', () {
      expect(graphLabelTops([190, 196, 199], 20, 200), [140, 160, 180]);
    });
  });

  testWidgets('the card labels every coin, output and the fee', (tester) async {
    await tester.pumpSailPage(
      const SizedBox(
        width: 1000,
        child: TransactionGraphCard(
          walletName: 'wallet1',
          spends: [GraphLine(sats: 100_000_000, address: 'ecash:qzx8abcdefghm4n7', kind: FlowKind.input)],
          creates: [
            GraphLine(sats: 25_000_000, address: 'ecash:qp3wabcdefghypyy', kind: FlowKind.payment),
            GraphLine(sats: 74_999_774, address: '', kind: FlowKind.change),
            GraphLine(sats: 226, address: '', kind: FlowKind.fee),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Transaction graph'), findsOneWidget);
    expect(find.textContaining('SPENDS · 1 coin'), findsOneWidget);
    expect(find.textContaining('CREATES · 2 outputs + fee'), findsOneWidget);
    expect(find.text('payment'), findsOneWidget);
    expect(find.text('change'), findsOneWidget);
    expect(find.text('back to wallet1'), findsOneWidget);
    expect(find.text('fee, paid to the miner'), findsOneWidget);
    expect(find.byType(TxFlowPlot), findsOneWidget);
  });

  testWidgets('an empty send asks for an address and an amount', (tester) async {
    await tester.pumpSailPage(
      const SizedBox(
        width: 1000,
        child: TransactionGraphCard(walletName: 'wallet1', spends: [], creates: []),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Enter an address and an amount to see the graph.'), findsOneWidget);
    expect(find.byType(TxFlowPlot), findsNothing);
  });
}
