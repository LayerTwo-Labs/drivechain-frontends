import 'package:bitwindow/pages/wallet/wallet_receive.dart';
import 'package:bitwindow/providers/address_book_provider.dart';
import 'package:bitwindow/providers/hd_wallet_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

class _FakeBitwindow extends ChangeNotifier implements BitwindowRPC {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAddressBook extends ChangeNotifier implements AddressBookProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHDWallet extends ChangeNotifier implements HDWalletProvider {
  @override
  bool get isInitialized => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeTransactions extends ChangeNotifier implements TransactionProvider {
  int fetches = 0;

  @override
  Future<void> fetch() async => fetches++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeBitwindow bitwindow;
  late _FakeTransactions transactions;

  setUp(() async {
    await GetIt.I.reset();
    bitwindow = _FakeBitwindow();
    transactions = _FakeTransactions();
    GetIt.I.registerSingleton<BitwindowRPC>(bitwindow);
    GetIt.I.registerSingleton<AddressBookProvider>(_FakeAddressBook());
    GetIt.I.registerSingleton<HDWalletProvider>(_FakeHDWallet());
    GetIt.I.registerSingleton<TransactionProvider>(transactions);
  });

  tearDown(() => GetIt.I.reset());

  test('a closed receive tab does not fetch on a backend change', () {
    ReceivePageViewModel()
      ..init()
      ..dispose();
    expect(transactions.fetches, 1);

    bitwindow.notifyListeners();

    expect(transactions.fetches, 1);
  });
}
