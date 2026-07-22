import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/rpcs/bitnames_rpc.dart';

void main() {
  test('only a valid non-null txin confirms a transaction', () {
    expect(transactionInfoStatus(null), BitnamesTransactionStatus.absent);
    expect(transactionInfoStatus({'fee_sats': 100, 'txin': null}), BitnamesTransactionStatus.pending);
    expect(transactionInfoIsConfirmed(null), isFalse);
    expect(transactionInfoIsConfirmed({'fee_sats': 100, 'txin': null}), isFalse);
    expect(
      transactionInfoIsConfirmed({
        'fee_sats': 100,
        'txin': {'block_hash': 'block-hash', 'idx': 7},
      }),
      isTrue,
    );
  });

  test('malformed transaction info cannot confirm', () {
    expect(() => transactionInfoIsConfirmed('invalid'), throwsFormatException);
    expect(() => transactionInfoIsConfirmed({'txin': true}), throwsFormatException);
  });
}
