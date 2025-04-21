// Manually created mock class
import 'dart:async';

import 'package:faucet/providers/transactions_provider.dart';

class MockTransactionsProvider extends TransactionsProvider {
  @override
  Future<void> fetch() async {}

  @override
  void poll() {
    fetch();
  }
}
