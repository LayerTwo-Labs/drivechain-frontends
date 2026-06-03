import 'package:bitwindow/pages/wallet/denability_page.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'test_utils.dart';

/// Stand-in for TransactionProvider whose real constructor pulls in half a
/// dozen providers. We only need its ChangeNotifier behaviour to exercise the
/// view model's listen/unlisten lifecycle.
class _FakeTransactionProvider extends ChangeNotifier implements TransactionProvider {
  void fire() => notifyListeners();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  // Regression for the macOS bug: "opening external deniability throws an error
  // and the Sidechains tab stops working". DeniabilityViewModel subscribes to
  // TransactionProvider but used to never unsubscribe, so after the page was
  // disposed the provider kept invoking the dead view model — which throws
  // "used after being disposed". dispose() now removes both listeners.
  testWidgets('DeniabilityViewModel unsubscribes from TransactionProvider on dispose', (tester) async {
    await registerTestDependencies();

    final fakeProvider = _FakeTransactionProvider();
    if (GetIt.I.isRegistered<TransactionProvider>()) {
      await GetIt.I.unregister<TransactionProvider>();
    }
    GetIt.I.registerSingleton<TransactionProvider>(fakeProvider);

    final vm = DeniabilityViewModel();
    vm.dispose();

    // With dispose() correctly removing the listeners, firing the provider does
    // nothing. Without the fix it would invoke the disposed view model and throw.
    expect(fakeProvider.fire, returnsNormally);
  });
}
