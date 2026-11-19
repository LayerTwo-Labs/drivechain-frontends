import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

final _deposit = 'd' * 64;
final _payment = 'e' * 64;

wmpb.TransactionEntry _entry(String txid, int vout, int amountSats, {double fee = 0, String address = ''}) =>
    wmpb.TransactionEntry(
      txid: txid,
      vout: vout,
      address: address,
      category: amountSats < 0 ? 'send' : 'receive',
      amountSats: Int64(amountSats),
      fee: fee,
      confirmations: 1,
      blockTime: Int64(1700000000),
    );

void main() {
  test('a deposit with two outputs gives one row', () {
    final deposit = wmpb.SidechainDeposit(txid: _deposit, slot: 9, destination: 'QAdeposit1');
    final rows = walletTransactionsFromEntries([
      _entry(_deposit, 0, -150000000, fee: -0.00000374)..sidechainDeposit = deposit,
      _entry(_deposit, 1, 0, fee: -0.00000374)..sidechainDeposit = deposit,
    ], {});

    expect(rows, hasLength(1));
    expect(rows.single.sentSatoshi, Int64(150000000));
    expect(rows.single.receivedSatoshi, Int64.ZERO);
    expect(rows.single.feeSats, Int64(374));
    expect(rows.single.address, 'QAdeposit1');
    expect(rows.single.depositRequest.slot, 9);
  });

  test('a payment to two addresses gives one row with the sum', () {
    final rows = walletTransactionsFromEntries(
      [
        _entry(_payment, 0, -1000, fee: -0.00000200, address: 'first'),
        _entry(_payment, 1, -2000, fee: -0.00000200, address: 'second'),
      ],
      {_payment: 'rent'},
    );

    expect(rows, hasLength(1));
    expect(rows.single.sentSatoshi, Int64(3000));
    expect(rows.single.feeSats, Int64(200));
    expect(rows.single.address, 'first');
    expect(rows.single.note, 'rent');
  });

  test('each txid keeps its own row', () {
    final rows = walletTransactionsFromEntries([
      _entry(_deposit, 0, 5000),
      _entry(_payment, 0, -1000),
    ], {});

    expect(rows.map((tx) => tx.txid), unorderedEquals([_deposit, _payment]));
  });
}
