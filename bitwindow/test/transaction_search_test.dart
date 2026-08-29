import 'package:bitwindow/utils/transaction_search.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart';

WalletTransaction _tx({
  String txid = 'a1b2c3d4e5f60718293a4b5c6d7e8f90a1b2c3d4e5f60718293a4b5c6d7e8f90',
  String address = 'bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq',
  int received = 0,
  int sent = 0,
}) {
  return WalletTransaction(
    txid: txid,
    address: address,
    receivedSatoshi: Int64(received),
    sentSatoshi: Int64(sent),
  );
}

void main() {
  group('transactionMatchesSearch', () {
    test('an empty query keeps every transaction', () {
      expect(transactionMatchesSearch(_tx(), ''), isTrue);
      expect(transactionMatchesSearch(_tx(), '   '), isTrue);
    });

    test('a txid part matches', () {
      expect(transactionMatchesSearch(_tx(), 'e5f60718'), isTrue);
      expect(transactionMatchesSearch(_tx(), 'ffffffff'), isFalse);
    });

    test('a txid matches in upper case', () {
      expect(transactionMatchesSearch(_tx(), 'A1B2C3D4'), isTrue);
    });

    test('an address part matches', () {
      expect(transactionMatchesSearch(_tx(), 'ar0srrr7'), isTrue);
      expect(transactionMatchesSearch(_tx(address: 'bc1qother'), 'ar0srrr7'), isFalse);
    });

    test('the satoshi amount matches', () {
      expect(transactionMatchesSearch(_tx(received: 100000), '100000'), isTrue);
      expect(transactionMatchesSearch(_tx(received: 100000), '250000'), isFalse);
    });

    test('the amount in bitcoin matches', () {
      expect(transactionMatchesSearch(_tx(received: 100000), '0.001'), isTrue);
      expect(transactionMatchesSearch(_tx(received: 100000), '0.00100000'), isTrue);
      expect(transactionMatchesSearch(_tx(received: 100000), '0.002'), isFalse);
    });

    test('a grouped amount from the table matches', () {
      expect(transactionMatchesSearch(_tx(received: 100000), '0.0010,0000'), isTrue);
      expect(transactionMatchesSearch(_tx(received: 100000), '100 000'), isTrue);
      expect(transactionMatchesSearch(_tx(received: 100000), '+0.0010,0000'), isTrue);
    });

    test('a send keeps the minus sign', () {
      final send = _tx(sent: 100000);
      expect(transactionMatchesSearch(send, '-0.001'), isTrue);
      expect(transactionMatchesSearch(send, '-100000'), isTrue);
      expect(transactionMatchesSearch(send, '100000'), isTrue);
    });

    test('a query does not match across two fields', () {
      final tx = _tx(txid: 'abcd', address: 'efgh');
      expect(transactionMatchesSearch(tx, 'cdef'), isFalse);
    });
  });
}
