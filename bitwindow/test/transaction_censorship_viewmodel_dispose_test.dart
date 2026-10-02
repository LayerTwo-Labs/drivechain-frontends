import 'package:bitwindow/pages/wallet/transaction_censorship_page.dart';
import 'package:bitwindow/providers/mempool_watch_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'test_utils.dart';

class _FakeMempoolWatchProvider extends ChangeNotifier implements MempoolWatchProvider {
  void fire() => notifyListeners();

  @override
  double get minScore => 0;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  testWidgets('TransactionCensorshipViewModel unsubscribes from the provider on dispose', (tester) async {
    await registerTestDependencies();

    final fakeProvider = _FakeMempoolWatchProvider();
    if (GetIt.I.isRegistered<MempoolWatchProvider>()) {
      await GetIt.I.unregister<MempoolWatchProvider>();
    }
    GetIt.I.registerSingleton<MempoolWatchProvider>(fakeProvider);

    final vm = TransactionCensorshipViewModel();
    vm.dispose();

    expect(fakeProvider.fire, returnsNormally);
  });
}
