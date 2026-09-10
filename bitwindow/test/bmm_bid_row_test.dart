import 'package:bitwindow/pages/wallet/wallet_overview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart';

WalletTransaction _tx({int height = 0, BmmBid? bid}) {
  return WalletTransaction(
    txid: 'abc',
    confirmationTime: Confirmation(height: height),
    bmmBid: bid,
  );
}

BmmBid _bid({required bool lost, int slot = 9}) {
  return BmmBid(slot: slot, criticalHash: 'aa', prevMainHash: 'bb', lost: lost);
}

void main() {
  group('transactionStatus', () {
    test('a plain transaction keeps the two words it always had', () {
      expect(transactionStatus(_tx()), 'Unconfirmed');
      expect(transactionStatus(_tx(height: 3)), 'Confirmed');
    });

    test('a live bid names the slot it bids for', () {
      expect(transactionStatus(_tx(bid: _bid(lost: false, slot: 4))), 'BMM bid · slot 4');
    });

    test('a stranded bid says it lost', () {
      expect(transactionStatus(_tx(bid: _bid(lost: true))), 'BMM bid · lost');
    });
  });

  group('canCancelBid', () {
    test('only a lost bid offers the cancel', () {
      expect(canCancelBid(_tx(bid: _bid(lost: true))), isTrue);
      expect(canCancelBid(_tx(bid: _bid(lost: false))), isFalse);
      expect(canCancelBid(_tx()), isFalse);
    });
  });

  group('canBumpFee', () {
    // A raise rebuilds the M8 for a live round. A lost bid has no round left,
    // so the row offers the cancel in its place.
    test('a lost bid offers the cancel rather than the bump', () {
      expect(canBumpFee(_tx(bid: _bid(lost: true))), isFalse);
      expect(canBumpFee(_tx(bid: _bid(lost: false))), isTrue);
    });
  });
}
