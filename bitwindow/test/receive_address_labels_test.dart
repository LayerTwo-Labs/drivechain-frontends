import 'package:bitwindow/pages/wallet/wallet_receive.dart';
import 'package:bitwindow/providers/address_book_provider.dart';
import 'package:bitwindow/providers/hd_wallet_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart';

const _labeled = 'bcrt1qc862dcz4ellepph35s0lmjg0nn5tt84zte54lw';
const _coreLabeled = 'bcrt1qpdt5szmvzf6km2302v987zxtt8ks4m07j66gar';
const _sendOnly = 'bcrt1pyqpchpyyrj0t6wf9e2c45krcnjpuj43a6tyffqdktw09x7qy3h9spxp6kz';

class _FakeBitwindow extends ChangeNotifier implements BitwindowRPC {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAddressBook extends ChangeNotifier implements AddressBookProvider {
  @override
  final List<AddressBookEntry> entries = [
    AddressBookEntry(id: Int64(1), label: 'savings', address: _labeled, direction: Direction.DIRECTION_RECEIVE),
    AddressBookEntry(id: Int64(2), label: '', address: _coreLabeled, direction: Direction.DIRECTION_RECEIVE),
    AddressBookEntry(id: Int64(3), label: 'landlord', address: _sendOnly, direction: Direction.DIRECTION_SEND),
  ];

  @override
  List<AddressBookEntry> get receiveEntries =>
      entries.where((entry) => entry.direction == Direction.DIRECTION_RECEIVE).toList();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHDWallet extends ChangeNotifier implements HDWalletProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeTransactions extends ChangeNotifier implements TransactionProvider {
  @override
  List<ReceiveAddress> receiveAddresses = [
    ReceiveAddress(address: _labeled),
    ReceiveAddress(address: _coreLabeled, label: 'core label'),
    ReceiveAddress(address: _sendOnly),
  ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeTransactions transactions;

  setUp(() async {
    await GetIt.I.reset();
    transactions = _FakeTransactions();
    GetIt.I.registerSingleton<BitwindowRPC>(_FakeBitwindow());
    GetIt.I.registerSingleton<AddressBookProvider>(_FakeAddressBook());
    GetIt.I.registerSingleton<HDWalletProvider>(_FakeHDWallet());
    GetIt.I.registerSingleton<TransactionProvider>(transactions);
  });

  tearDown(() => GetIt.I.reset());

  test('the receive addresses carry the label saved in the address book', () {
    final labels = {for (final a in ReceivePageViewModel().receiveAddresses) a.address: a.label};

    expect(labels, {_labeled: 'savings', _coreLabeled: 'core label', _sendOnly: ''});
  });

  test('the address book label leaves the provider list unchanged', () {
    ReceivePageViewModel().receiveAddresses;

    expect(transactions.receiveAddresses.first.label, isEmpty);
  });
}
