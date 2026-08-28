import 'package:bitwindow/pages/wallet/bump_fee_choices.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

wmpb.BumpFeeOutput _output({
  required int vout,
  String address = 'tb1qpayment',
  bool isMine = false,
  bool isChange = false,
}) {
  return wmpb.BumpFeeOutput(vout: vout, address: address, isMine: isMine, isChange: isChange);
}

wmpb.PreviewBumpFeeResponse _preview({
  required bool canReplace,
  bool hasChild = false,
  bool addsInputs = false,
  String reason = '',
  wmpb.BumpFeePlan? plan,
  List<wmpb.BumpFeeOutput>? outputs,
}) {
  return wmpb.PreviewBumpFeeResponse(
    canReplace: canReplace,
    hasChild: hasChild,
    addsInputs: addsInputs,
    reason: reason,
    plan: plan,
    outputs:
        outputs ??
        [
          _output(vout: 0),
          _output(vout: 1, address: 'tb1qchange', isMine: true, isChange: true),
        ],
  );
}

void main() {
  group('BumpFeeChoices', () {
    test('a plan offers Replace alone', () {
      final choices = BumpFeeChoices.of(
        _preview(canReplace: true, plan: wmpb.BumpFeePlan(feeFromVout: 1)),
        pickOutput: false,
      );
      expect(choices.showReplace, isTrue);
      expect(choices.showAccelerate, isFalse);
      expect(choices.showOverride, isFalse);
      expect(choices.reason, isEmpty);
    });

    test('a fee rate that is too low keeps Replace, and never points at CPFP', () {
      final choices = BumpFeeChoices.of(
        _preview(canReplace: true, reason: 'fee rate 2 sat/vB does not replace it; use 5 sat/vB or more'),
        pickOutput: false,
      );
      expect(choices.showReplace, isTrue, reason: 'a typed rate must not remove the button');
      expect(choices.showAccelerate, isFalse);
      expect(choices.reason, isNot(contains('CPFP')));
    });

    test('no change output offers the override, and CPFP while the wallet owns an output', () {
      final choices = BumpFeeChoices.of(
        _preview(
          canReplace: true,
          reason: 'transaction has no change output',
          outputs: [
            _output(vout: 0),
            _output(vout: 1, address: 'tb1qmine', isMine: true),
          ],
        ),
        pickOutput: false,
      );
      expect(choices.showOverride, isTrue);
      expect(choices.showAccelerate, isTrue);
      expect(choices.reason, contains('We suggest CPFP instead'));
    });

    test('the override stays available after the picker opens, and CPFP does too', () {
      final choices = BumpFeeChoices.of(
        _preview(
          canReplace: true,
          reason: 'transaction has no change output',
          outputs: [
            _output(vout: 0),
            _output(vout: 1, address: 'tb1qmine', isMine: true),
          ],
        ),
        pickOutput: true,
      );
      expect(choices.showOverride, isFalse, reason: 'the picker is already open');
      expect(choices.showAccelerate, isTrue, reason: 'the picker must not hide the only other action');
    });

    test('a wallet that cannot sign it offers CPFP alone', () {
      final choices = BumpFeeChoices.of(
        _preview(
          canReplace: false,
          reason: 'this wallet signs none of the inputs',
          outputs: [_output(vout: 0, address: 'tb1qmine', isMine: true)],
        ),
        pickOutput: false,
      );
      expect(choices.showReplace, isFalse);
      expect(choices.showOverride, isFalse);
      expect(choices.showAccelerate, isTrue);
      expect(choices.reason, contains('We suggest CPFP instead'));
    });

    test('a transaction the wallet owns no output of offers neither, and says so', () {
      final choices = BumpFeeChoices.of(
        _preview(
          canReplace: false,
          reason: 'this wallet signs none of the inputs',
          outputs: [_output(vout: 0)],
        ),
        pickOutput: false,
      );
      expect(choices.showReplace, isFalse);
      expect(choices.showAccelerate, isFalse);
      expect(choices.reason, contains('CPFP cannot speed it up either'));
    });

    test('a transaction with a child offers neither, and points at the child', () {
      final choices = BumpFeeChoices.of(
        _preview(
          canReplace: false,
          hasChild: true,
          reason: 'another transaction already spends this one',
          outputs: [_output(vout: 0, address: 'tb1qmine', isMine: true)],
        ),
        pickOutput: false,
      );
      expect(choices.showReplace, isFalse);
      expect(choices.showAccelerate, isFalse, reason: 'the child already spent that output');
      expect(choices.reason, contains('Bump the fee of that transaction instead'));
      expect(choices.reason, isNot(contains('We suggest CPFP')));
    });

    test('a change output too small to pay keeps Replace alive on Core', () {
      // Core adds a coin of its own, so the user presses Replace and it works.
      final choices = BumpFeeChoices.of(
        _preview(
          canReplace: true,
          addsInputs: true,
          reason: 'output 1 holds 850 sats, and the higher fee takes 2850 sats',
        ),
        pickOutput: false,
      );
      expect(choices.showReplace, isTrue);
      expect(choices.replaceWithoutPlan, isTrue);
    });

    test('a backend that cannot add a coin leaves Replace disabled', () {
      final choices = BumpFeeChoices.of(
        _preview(canReplace: true, reason: 'output 1 holds 850 sats, and the higher fee takes 2850 sats'),
        pickOutput: false,
      );
      expect(choices.showReplace, isTrue);
      expect(choices.replaceWithoutPlan, isFalse);
    });

    test('every reason the dialog prints matches a button it draws', () {
      for (final preview in [
        _preview(canReplace: true, reason: 'rate too low'),
        _preview(canReplace: false, reason: 'not ours'),
        _preview(canReplace: false, hasChild: true, reason: 'has a child'),
        _preview(canReplace: false, reason: 'not ours', outputs: [_output(vout: 0)]),
      ]) {
        final choices = BumpFeeChoices.of(preview, pickOutput: false);
        if (choices.reason.contains('We suggest CPFP')) {
          expect(choices.showAccelerate, isTrue, reason: 'the text names a button the dialog hides');
        }
      }
    });
  });
}
