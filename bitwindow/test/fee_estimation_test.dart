import 'package:bitwindow/utils/fee_estimation.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void main() {
  group('btcPerKvbToSatPerVByte', () {
    test('converts BTC/kvB to sat/vB', () {
      // 0.00001 BTC/kvB = 1000 sat/kvB = 1 sat/vB
      expect(btcPerKvbToSatPerVByte(0.00001), closeTo(1.0, 1e-9));
      // 0.0001 BTC/kvB = 10 sat/vB
      expect(btcPerKvbToSatPerVByte(0.0001), closeTo(10.0, 1e-9));
    });
  });

  group('estimateTxVBytes', () {
    test('base + inputs + outputs', () {
      expect(estimateTxVBytes(numInputs: 1, numOutputs: 2), 10 + 148 + 68);
      expect(estimateTxVBytes(numInputs: 2, numOutputs: 2), 10 + 296 + 68);
    });
  });

  group('feeSatsForRate', () {
    test('rounds up', () {
      expect(feeSatsForRate(satPerVByte: 1.0, txVBytes: 226), 226);
      expect(feeSatsForRate(satPerVByte: 1.5, txVBytes: 226), 339);
      // ceil applies on any fractional sat
      expect(feeSatsForRate(satPerVByte: 2.5, txVBytes: 101), 253);
      expect(feeSatsForRate(satPerVByte: 0.25, txVBytes: 226), 57);
    });
  });

  group('sendFee', () {
    test('an estimate goes as a rate, so the backend sizes the fee to its inputs', () {
      final fee = sendFee(estimatedSatPerVByte: 2.005, typedFeeSats: 750);
      expect(fee.feeRateSatPerVbyte, 3);
      expect(fee.fixedFeeSats, isNull);
    });

    test('a typed fee goes as a fixed fee', () {
      final fee = sendFee(estimatedSatPerVByte: null, typedFeeSats: 5000);
      expect(fee.feeRateSatPerVbyte, isNull);
      expect(fee.fixedFeeSats, 5000);
    });
  });

  group('sendDestinations', () {
    test('sums the sats of a repeated address', () {
      expect(
        sendDestinations([(address: 'a', sats: 1000), (address: 'b', sats: 2000), (address: 'a', sats: 500)]),
        {'a': 1500, 'b': 2000},
      );
    });

    test('a recipient without an address gives no send to price', () {
      expect(sendDestinations([(address: 'a', sats: 1000), (address: '', sats: 2000)]), isNull);
    });

    test('a recipient without an amount gives no send to price', () {
      expect(sendDestinations([(address: 'a', sats: 0)]), isNull);
    });

    test('no recipients give no send to price', () {
      expect(sendDestinations([]), isNull);
    });
  });

  group('feePreviewKey', () {
    String key({
      Map<String, int> destinations = const {'a': 1000, 'b': 2000},
      int rate = 3,
      bool subtract = false,
      List<String> outpoints = const ['x:0', 'y:1'],
      List<String> frozen = const ['z:2'],
      List<String> wallet = const ['x:0', 'y:1', 'z:2'],
    }) => feePreviewKey(
      walletId: 'w',
      destinations: destinations,
      feeRateSatPerVbyte: rate,
      subtractFeeFromAmount: subtract,
      requiredOutpoints: outpoints,
      frozenOutpoints: frozen,
      walletOutpoints: wallet,
    );

    test('the same send in another order asks for no new preview', () {
      expect(key(destinations: {'b': 2000, 'a': 1000}, outpoints: ['y:1', 'x:0']), key());
    });

    test('a new amount, rate, fee mode, coin, frozen coin or wallet coin asks for a new preview', () {
      expect(key(destinations: {'a': 1001, 'b': 2000}), isNot(key()));
      expect(key(rate: 4), isNot(key()));
      expect(key(subtract: true), isNot(key()));
      expect(key(outpoints: ['x:0']), isNot(key()));
      expect(key(frozen: ['z:2', 'w:3']), isNot(key()));
      expect(key(wallet: ['x:0', 'z:2']), isNot(key()));
    });
  });

  group('sendInputs', () {
    test('a send pins the coins of the preview that priced the form', () {
      expect(sendInputs(selected: <String>[], currentKey: 'k', pricedKey: 'k', pricedInputs: ['a:0']), ['a:0']);
    });

    test('a form changed after the preview pins no coins', () {
      expect(sendInputs(selected: <String>[], currentKey: 'k2', pricedKey: 'k', pricedInputs: ['a:0']), isEmpty);
    });

    test('a typed fee pins no coins', () {
      expect(sendInputs(selected: <String>[], currentKey: null, pricedKey: null, pricedInputs: <String>[]), isEmpty);
    });

    test('the coins the user selected win', () {
      expect(sendInputs(selected: ['b:1'], currentKey: 'k', pricedKey: 'k', pricedInputs: ['a:0']), ['b:1']);
    });
  });

  group('previewFeeSats', () {
    test('a first BIP47 payment shows the fees of the notification and the payment', () {
      final preview = PreviewSendResponse(feeSats: Int64(700), notificationFeeSats: Int64(520));
      expect(previewFeeSats(preview), 1220);
    });

    test('a send without a notification shows the payment fee', () {
      expect(previewFeeSats(PreviewSendResponse(feeSats: Int64(700))), 700);
    });
  });

  group('approximateFeePrefix', () {
    Future<void> pumpFeeField(WidgetTester tester, {required bool feeIsEstimate}) async {
      await tester.pumpSailPage(
        SailTextField(
          controller: TextEditingController(text: '0.00001220'),
          hintText: 'Fee',
          prefix: approximateFeePrefix(feeIsEstimate),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('an estimated fee shows the approximate mark', (tester) async {
      await pumpFeeField(tester, feeIsEstimate: true);
      expect(find.textContaining('≈'), findsOneWidget);
    });

    testWidgets('an exact fee shows no mark', (tester) async {
      await pumpFeeField(tester, feeIsEstimate: false);
      expect(find.textContaining('≈'), findsNothing);
    });
  });

  group('notificationKeepBack', () {
    test('pinned coins keep back the whole notification coin', () {
      final probe = PreviewSendResponse(
        notificationFeeSats: Int64(520),
        notificationInput: UnspentOutput(amountSats: Int64(100_000)),
      );
      expect(notificationKeepBack(probe, coinsSelected: false), 100_000);
    });

    test('a one-coin payment keeps back the notification fee and dust', () {
      final probe = PreviewSendResponse(notificationFeeSats: Int64(520), feeIsEstimate: true);
      expect(notificationKeepBack(probe, coinsSelected: false), 520 + dustSats);
    });

    test('selected coins never fund the notification', () {
      final probe = PreviewSendResponse(
        notificationFeeSats: Int64(520),
        notificationInput: UnspentOutput(amountSats: Int64(100_000)),
      );
      expect(notificationKeepBack(probe, coinsSelected: true), 0);
    });

    test('a send without a notification keeps back nothing', () {
      expect(notificationKeepBack(PreviewSendResponse(), coinsSelected: false), 0);
    });
  });

  group('maxSendAmountSats', () {
    test('a first BIP47 payment keeps back the payment fee and the notification coin', () {
      const notificationFee = 520;
      const notificationCoin = 100_000;
      final amount = maxSendAmountSats(
        availableSats: 1_000_000,
        otherRecipientsSats: 50_000,
        paymentFeeSats: 700,
        notificationKeepBackSats: notificationCoin,
      );
      expect(amount, 849_300);
      expect(amount + 50_000 + 700 + notificationFee + 2 * dustSats, lessThanOrEqualTo(1_000_000));
    });

    test('a send without a notification keeps back the payment fee', () {
      expect(
        maxSendAmountSats(
          availableSats: 1_000_000,
          otherRecipientsSats: 0,
          paymentFeeSats: 700,
          notificationKeepBackSats: 0,
        ),
        999_300,
      );
    });
  });

  test('feeRateConfTargets is ascending', () {
    for (var i = 1; i < feeRateConfTargets.length; i++) {
      expect(feeRateConfTargets[i] > feeRateConfTargets[i - 1], isTrue);
    }
  });
}
