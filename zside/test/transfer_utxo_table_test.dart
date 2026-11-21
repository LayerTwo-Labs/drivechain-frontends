import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:zside/pages/tabs/zside/zside_transfer_page.dart';

import 'test_utils.dart';

UnshieldedUTXO transparent(int i) => UnshieldedUTXO(
  txid: 'transparent$i',
  address: 'address$i',
  amount: 0.5,
  confirmations: i + 1,
  generated: false,
  raw: 'raw$i',
);

ShieldedUTXO private(int i) => ShieldedUTXO(
  txid: 'private$i',
  pool: 'sapling',
  type: 'sapling',
  outindex: 0,
  confirmations: i + 1,
  spendable: true,
  address: 'zaddress$i',
  amount: 0.25,
  amountZat: 25000000,
  memo: '',
  change: false,
  raw: 'raw$i',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final count in [0, 1, 50]) {
    testWidgets('transfer UTXO tables lay out in a scrollable page with $count rows', (tester) async {
      await tester.pumpSailPage(
        SingleChildScrollView(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: TransparentUTXOTable(
                  entries: List.generate(count, transparent),
                  searchWidget: const SizedBox(height: 40),
                ),
              ),
              Flexible(
                child: PrivateUTXOTable(
                  entries: List.generate(count, private),
                  searchWidget: const SizedBox(height: 40),
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Confirmations'), findsNWidgets(2));
      if (count > 0) {
        expect(find.text('transp'), findsWidgets);
        expect(find.text('privat'), findsWidgets);
      }
    });
  }
}
