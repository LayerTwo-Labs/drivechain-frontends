import 'package:bitwindow/providers/check_provider.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/gen/google/protobuf/timestamp.pb.dart';
import 'package:sail_ui/gen/wallet/v1/wallet.pb.dart';

Cheque _mkCheck({required int id, String address = 'tb1qabc'}) => Cheque(
  id: Int64(id),
  derivationIndex: id,
  address: address,
  expectedAmountSats: Int64(210000000),
  createdAt: Timestamp(seconds: Int64(1768523696)),
);

void main() {
  group('applyFundingResponse — polling state machine', () {
    test('empty fundedTxids leaves the list untouched', () {
      // First poll after the user taps Fund Check: bitcoind hasn't seen the
      // broadcast yet, so the server returns an empty response. The local
      // state must NOT be wiped — that would lose the existing cheque row.
      final checks = [_mkCheck(id: 1)];
      final resp = CheckChequeFundingResponse();
      final original = checks.first;

      final mutated = applyFundingResponse(checks, 1, resp);

      expect(mutated, isFalse);
      expect(identical(checks.first, original), isTrue);
    });

    test('non-empty fundedTxids flips the cheque to funded and persists txid', () {
      // Second poll: bitcoind now sees the broadcast and the server reports
      // the funding. The local row must be replaced so the UI flips from
      // "Unfunded" to "Funded" and `View Details` shows the txid.
      final checks = [_mkCheck(id: 1)];
      final fundedAt = Timestamp(seconds: Int64(1768523700));
      final resp = CheckChequeFundingResponse(
        funded: true,
        fundedTxids: ['deadbeef'],
        actualAmountSats: Int64(210000000),
        fundedAt: fundedAt,
      );

      final mutated = applyFundingResponse(checks, 1, resp);

      expect(mutated, isTrue);
      expect(checks.first.funded, isTrue);
      expect(checks.first.fundedTxids, ['deadbeef']);
      expect(checks.first.actualAmountSats, Int64(210000000));
      expect(checks.first.fundedAt, fundedAt);
      // Preserved fields from the original row.
      expect(checks.first.address, 'tb1qabc');
      expect(checks.first.derivationIndex, 1);
    });

    test('unknown id leaves the list untouched', () {
      final checks = [_mkCheck(id: 1)];
      final resp = CheckChequeFundingResponse(
        funded: true,
        fundedTxids: ['deadbeef'],
      );

      final mutated = applyFundingResponse(checks, 999, resp);

      expect(mutated, isFalse);
      expect(checks.first.funded, isFalse);
    });

    test('partial funding (txid present, funded=false) still records the txid', () {
      // The user sent less than expected. Server returns funded=false but
      // fundedTxids is non-empty so the row can show "Partially Funded" and
      // the actual amount.
      final checks = [_mkCheck(id: 1)];
      final resp = CheckChequeFundingResponse(
        funded: false,
        fundedTxids: ['partialtx'],
        actualAmountSats: Int64(100000000),
      );

      final mutated = applyFundingResponse(checks, 1, resp);

      expect(mutated, isTrue);
      expect(checks.first.funded, isFalse);
      expect(checks.first.fundedTxids, ['partialtx']);
      expect(checks.first.actualAmountSats, Int64(100000000));
    });

    test('createdAt is preserved across a funding update', () {
      // Regression: the funding update must not zero out the existing
      // createdAt timestamp — otherwise the row's "Created" cell will flip
      // to "-" the moment funding is detected.
      final original = _mkCheck(id: 1);
      final checks = [original];
      final resp = CheckChequeFundingResponse(
        funded: true,
        fundedTxids: ['deadbeef'],
        actualAmountSats: Int64(210000000),
      );

      applyFundingResponse(checks, 1, resp);

      expect(checks.first.createdAt, original.createdAt);
      expect(checks.first.createdAt.seconds, Int64(1768523696));
    });
  });
}
