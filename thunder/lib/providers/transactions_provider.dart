import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/rpcs/thunder_rpc.dart';
import 'package:sail_ui/rpcs/thunder_utxo.dart';
import 'package:sail_ui/sail_ui.dart';

class TransactionProvider extends ChangeNotifier {
  ThunderRPC get rpc => GetIt.I.get<ThunderRPC>();
  Logger get log => GetIt.I.get<Logger>();

  List<CoreTransaction> sidechainTransactions = [];
  List<ThunderUTXO> utxos = [];
  bool initialized = false;

  TransactionProvider() {
    rpc.addListener(fetch);
    fetch();
  }

  bool _isFetching = false;
  // call this function from anywhere to refetch transaction list
  Future<void> fetch() async {
    if (_isFetching) {
      return;
    }
    _isFetching = true;

    try {
      final newSidechainTransactions = (await rpc.listTransactions()).reversed.toList();
      final newUTXOs = await rpc.listUTXOs();
      const newInitialized = true;

      if (_dataHasChanged(newSidechainTransactions, newUTXOs, newInitialized)) {
        sidechainTransactions = newSidechainTransactions;
        utxos = newUTXOs;
        initialized = newInitialized;
        notifyListeners();
      }
    } finally {
      _isFetching = false;
    }
  }

  bool _dataHasChanged(
    List<CoreTransaction> newSidechainTransactions,
    List<ThunderUTXO> newUTXOs,
    bool newInitialized,
  ) {
    if (newInitialized != initialized) {
      return true;
    }

    if (!listEquals(sidechainTransactions, newSidechainTransactions)) {
      return true;
    }

    if (!listEquals(utxos, newUTXOs)) {
      return true;
    }

    return false;
  }
}
