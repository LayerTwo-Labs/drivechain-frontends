import 'package:bitwindow/pages/wallet/wallet_overview.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart';

WalletTransaction _tx({required int height, required int sent, required int received}) {
  return WalletTransaction(
    txid: 'abc',
    sentSatoshi: Int64(sent),
    receivedSatoshi: Int64(received),
    confirmationTime: Confirmation(height: height),
  );
}

void main() {
  group('canBumpFee', () {
    test('a transaction the wallet sent, with no block yet, can be replaced', () {
      expect(canBumpFee(_tx(height: 0, sent: 100000, received: 0)), isTrue);
    });

    test('a confirmed transaction cannot be replaced', () {
      expect(canBumpFee(_tx(height: 3, sent: 100000, received: 0)), isFalse);
    });

    test('a consolidation reads as amount zero, and still offers the bump', () {
      // Electrum reports a self-send with no payment row, so both amounts are
      // zero. The wallet still signs every input of it.
      expect(canBumpFee(_tx(height: 0, sent: 0, received: 0)), isTrue);
    });

    test('an incoming payment offers the bump, and the preview says it cannot replace it', () {
      expect(canBumpFee(_tx(height: 0, sent: 0, received: 100000)), isTrue);
    });
  });

  group('transactionColumns', () {
    test('holds one key per column, and the action column sorts nothing', () {
      expect(transactionColumns, ['date', 'txid', 'address', 'note', 'status', 'amount', '']);
      expect(transactionColumns.last, isEmpty);
    });

    test('every sortable key is unique', () {
      final sortable = transactionColumns.where((c) => c.isNotEmpty).toList();
      expect(sortable.toSet().length, sortable.length);
    });
  });
}
