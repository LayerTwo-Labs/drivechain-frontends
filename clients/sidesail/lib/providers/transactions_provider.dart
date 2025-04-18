import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

class TransactionsProvider extends ChangeNotifier {
  SidechainContainer get sidechain => GetIt.I.get<SidechainContainer>();
  Logger get log => GetIt.I.get<Logger>();

  // because the class extends ChangeNotifier, any subscribers
  // to this class will be notified of changes to these
  // variables.
  List<UTXO> unspentMainchainUTXOs = [];
  List<CoreTransaction> sidechainTransactions = [];
  bool initialized = false;

  bool _isFetching = false;

  TransactionsProvider() {
    sidechain.rpc.addListener(fetch);
    fetch();
  }

  // call this function from anywhere to refetch transaction list
  Future<void> fetch() async {
    if (_isFetching) {
      return;
    }
    _isFetching = true;

    try {
      final newSidechainTransactions = (await sidechain.rpc.listTransactions()).reversed.toList();
      const newInitialized = true;

      if (_dataHasChanged(newSidechainTransactions, newInitialized)) {
        sidechainTransactions = newSidechainTransactions;
        initialized = newInitialized;
        notifyListeners();
      }
    } finally {
      _isFetching = false;
    }
  }

  bool _dataHasChanged(
    List<CoreTransaction> newSidechainTransactions,
    bool newInitialized,
  ) {
    if (newInitialized != initialized) {
      return true;
    }

    if (!listEquals(sidechainTransactions, newSidechainTransactions)) {
      return true;
    }

    return false;
  }
}
