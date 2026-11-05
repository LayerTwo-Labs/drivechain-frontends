import 'package:bitwindow/pages/wallet/wallet_send.dart';
import 'package:bitwindow/utils/coin_selection.dart';
import 'package:bitwindow/widgets/tx_flow_diagram.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart' hide CoinSelectionStrategy;

void main() {
  group('sendTotalSats', () {
    test('adds the fee on top of the amounts', () {
      expect(sendTotalSats(amountSats: 40_000_000, feeSats: 226, subtractFee: false), 40_000_226);
    });

    test('a recipient who pays the fee leaves the total at the amount', () {
      expect(sendTotalSats(amountSats: 40_000_000, feeSats: 226, subtractFee: true), 40_000_000);
    });

    test('a BIP47 notification adds its cost also when the recipient pays the fee', () {
      expect(
        sendTotalSats(amountSats: 40_000_000, feeSats: 226, subtractFee: true, notificationSats: 300 + 546),
        40_000_846,
      );
    });
  });

  group('feeTargetLabel', () {
    test('names each menu target', () {
      expect(sendFeeTargets.map(feeTargetLabel), ['Next block', '3 blocks', '6 blocks']);
    });

    test('a typed fee reads Custom', () {
      expect(feeTargetLabel(null), 'Custom');
    });
  });

  group('payFromLabel', () {
    test('no coins picked shows the strategy', () {
      expect(
        payFromLabel(CoinSelectionStrategy.largestFirst, const []),
        CoinSelectionStrategy.largestFirst.displayName,
      );
    });

    test('coins picked by hand show the count and the total', () {
      final coins = [
        UnspentOutput(output: 'a:0', valueSats: Int64(100_000_000)),
        UnspentOutput(output: 'b:1', valueSats: Int64(25_000_000)),
      ];
      expect(payFromLabel(CoinSelectionStrategy.largestFirst, coins), startsWith('2 UTXOs · 1.2500,0000'));
    });
  });

  group('sendGraphCreates', () {
    const payments = [(address: 'ecash:a', sats: 25_000_000), (address: 'ecash:b', sats: 10_000_000)];

    test('the coins above the payments and the fee go back as change', () {
      final lines = sendGraphCreates(payments: payments, inputSats: 100_000_000, feeSats: 226, subtractFee: false);

      expect(lines.map((l) => l.kind), [FlowKind.payment, FlowKind.payment, FlowKind.change, FlowKind.fee]);
      expect(lines.map((l) => l.sats), [25_000_000, 10_000_000, 64_999_774, 226]);
    });

    test('a send of every coin has no change', () {
      final lines = sendGraphCreates(
        payments: const [(address: 'ecash:a', sats: 99_999_774)],
        inputSats: 100_000_000,
        feeSats: 226,
        subtractFee: false,
      );

      expect(lines.map((l) => l.kind), [FlowKind.payment, FlowKind.fee]);
    });

    test('a recipient who pays the fee keeps change below dust', () {
      final lines = sendGraphCreates(
        payments: const [(address: 'ecash:a', sats: 99_999_800)],
        inputSats: 100_000_000,
        feeSats: 426,
        subtractFee: true,
      );

      expect(lines.map((l) => l.kind), [FlowKind.payment, FlowKind.fee]);
      expect(lines.map((l) => l.sats), [99_999_574, 426]);
    });

    test('small change above the segwit dust limit stays an output', () {
      final lines = sendGraphCreates(
        payments: const [(address: 'ecash:a', sats: 99_999_400)],
        inputSats: 100_000_000,
        feeSats: 226,
        subtractFee: false,
      );

      expect(lines.map((l) => l.kind), [FlowKind.payment, FlowKind.change, FlowKind.fee]);
      expect(lines.map((l) => l.sats), [99_999_400, 374, 226]);
    });

    test('a recipient who pays the fee gets the amount less the fee', () {
      final lines = sendGraphCreates(
        payments: const [(address: 'ecash:a', sats: 100_000_000)],
        inputSats: 100_000_000,
        feeSats: 226,
        subtractFee: true,
      );

      expect(lines.map((l) => l.sats), [99_999_774, 226]);
    });
  });
}
