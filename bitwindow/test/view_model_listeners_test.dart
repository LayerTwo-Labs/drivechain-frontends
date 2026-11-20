import 'package:bitwindow/pages/overview_page.dart';
import 'package:bitwindow/providers/blockchain_provider.dart';
import 'package:bitwindow/providers/news_provider.dart';
import 'package:bitwindow/widgets/coinnews.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

mixin _Counted on ChangeNotifier {
  int listeners = 0;

  @override
  void addListener(VoidCallback listener) {
    listeners++;
    super.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    listeners--;
    super.removeListener(listener);
  }
}

class _Balance extends ChangeNotifier with _Counted implements BalanceProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Blockchain extends ChangeNotifier with _Counted implements BlockchainProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _News extends ChangeNotifier with _Counted implements NewsProvider {
  @override
  List<Topic> get topics => [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<BalanceProvider>(_Balance());
    GetIt.I.registerSingleton<BlockchainProvider>(_Blockchain());
    GetIt.I.registerSingleton<NewsProvider>(_News());
    await registerTestDependencies();
  });

  tearDown(() => GetIt.I.reset());

  int listeners<T extends Object>() => (GetIt.I.get<T>() as _Counted).listeners;

  test('a disposed transactions model stops listening', () {
    TransactionsViewModel().dispose();
    expect(listeners<BalanceProvider>(), 0);
    expect(listeners<BlockchainProvider>(), 0);
  });

  test('a disposed news model stops listening', () async {
    CoinNewsViewModel().dispose();
    await pumpEventQueue();
    expect(listeners<NewsProvider>(), 0);
  });
}
