import 'package:bitwindow/pages/explorer/widgets/output_owner.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart';

void main() {
  group('outputOwnerLabel', () {
    test('an output the wallet does not own carries no label', () {
      expect(outputOwnerLabel(TransactionOutput(address: 'stranger')), isNull);
    });

    test('the change output of a send says it comes back', () {
      expect(
        outputOwnerLabel(TransactionOutput(address: 'change', isMine: true, isChange: true)),
        'Your change',
      );
    });

    test('a decoded PSBT marks change without an ownership flag', () {
      expect(outputOwnerLabel(TransactionOutput(address: 'change', isChange: true)), 'Your change');
    });

    test('a receive output names the wallet without calling it change', () {
      expect(outputOwnerLabel(TransactionOutput(address: 'receive', isMine: true)), 'Your address');
    });
  });
}
