import 'dart:async';

import 'package:drivechain_client/api.dart';
import 'package:drivechain_client/gen/wallet/v1/wallet.pbgrpc.dart';
import 'package:drivechain_client/providers/balance_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

// because the class extends ChangeNotifier, any subscribers
// to this class will be notified of changes to new transactions
class TransactionProvider extends ChangeNotifier {
  API get api => GetIt.I.get<API>();
  BalanceProvider get balanceProvider => GetIt.I.get<BalanceProvider>();

  List<Transaction> walletTransactions = [];
  bool initialized = false;

  bool _isFetching = false;

  TransactionProvider() {
    balanceProvider.addListener(fetch);
  }

  // call this function from anywhere to refetch transaction list
  Future<void> fetch() async {
    if (_isFetching) {
      return;
    }
    _isFetching = true;

    try {
      final newTXs = await api.listWalletTransactions();

      if (_dataHasChanged(newTXs)) {
        walletTransactions = newTXs;
        notifyListeners();
      }
    } finally {
      _isFetching = false;
    }
  }

  bool _dataHasChanged(
    List<Transaction> newTXs,
  ) {
    if (!listEquals(walletTransactions, newTXs)) {
      return true;
    }

    return false;
  }

  @override
  void dispose() {
    balanceProvider.removeListener(fetch);
    super.dispose();
  }
}
