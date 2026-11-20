import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bitwindow/main.dart';
import 'package:bitwindow/providers/address_book_provider.dart';
import 'package:bitwindow/providers/blockchain_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

class _FakeBalance implements BalanceProvider {
  int fetches = 0;

  @override
  Future<void> fetch() async => fetches++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeBlockchain implements BlockchainProvider {
  int fetches = 0;

  @override
  Future<void> fetch() async => fetches++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeTransactions implements TransactionProvider {
  int fetches = 0;

  @override
  Future<void> fetch() async => fetches++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAddressBook implements AddressBookProvider {
  int fetches = 0;

  @override
  Future<void> fetch() async => fetches++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a new block refetches only the providers that the window built', () async {
    addTearDown(GetIt.I.reset);
    final balance = _FakeBalance();
    final blockchain = _FakeBlockchain();
    final transactions = _FakeTransactions();
    GetIt.I.registerLazySingleton<BalanceProvider>(() => balance);
    GetIt.I.registerLazySingleton<BlockchainProvider>(() => blockchain);
    GetIt.I.registerLazySingleton<TransactionProvider>(() => transactions);
    GetIt.I.get<BlockchainProvider>();

    refetchBuiltOnNewBlock();

    expect(blockchain.fetches, 1);
    expect(balance.fetches, 0);
    expect(transactions.fetches, 0);
    expect(GetIt.I.checkLazySingletonInstanceExists<BalanceProvider>(), isFalse);
  });

  test('an open refetches the address book that an earlier page built', () async {
    addTearDown(GetIt.I.reset);
    final book = _FakeAddressBook();
    GetIt.I.registerLazySingleton<AddressBookProvider>(() => book);

    refetchBuiltOnOpen();
    expect(book.fetches, 0);
    expect(GetIt.I.checkLazySingletonInstanceExists<AddressBookProvider>(), isFalse);

    GetIt.I.get<AddressBookProvider>();
    refetchBuiltOnOpen();
    expect(book.fetches, 1);
  });

  test('a sub-window init builds no polling provider', () async {
    final dir = await Directory.systemTemp.createTemp('subwindow_init');
    addTearDown(() async {
      await GetIt.I.reset();
      await dir.delete(recursive: true);
    });
    final polls = <Duration>[];

    await runZoned(
      () => init(jsonEncode({'application_dir': dir.path, 'log_file': '${dir.path}/bitwindow.log'})),
      zoneSpecification: ZoneSpecification(
        createPeriodicTimer: (self, parent, zone, period, f) {
          polls.add(period);
          return parent.createPeriodicTimer(zone, period, f);
        },
      ),
    );

    // Only the binary provider, which each RPC client reads, polls.
    expect(polls, unorderedEquals(const [Duration(seconds: 10), Duration(minutes: 5)]));
    expect(GetIt.I.isRegistered<BlockchainProvider>(), isTrue);
    expect(GetIt.I.checkLazySingletonInstanceExists<BlockchainProvider>(), isFalse);
    expect(GetIt.I.checkLazySingletonInstanceExists<StratumProvider>(), isFalse);
    expect(GetIt.I.checkLazySingletonInstanceExists<UpdateProvider>(), isFalse);
  });
}
