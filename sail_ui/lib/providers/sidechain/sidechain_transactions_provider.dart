import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

class SidechainTransactionsProvider extends ChangeNotifier {
  SidechainRPC get rpc => GetIt.I.get<SidechainRPC>();
  Logger get log => GetIt.I.get<Logger>();

  List<CoreTransaction> sidechainTransactions = [];
  List<SidechainUTXO> utxos = [];
  bool initialized = false;

  SidechainTransactionsProvider() {
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

    var newSidechainTransactions = sidechainTransactions;
    var newUTXOs = utxos;
    final newInitialized = true;

    try {
      newSidechainTransactions = (await rpc.listTransactions()).reversed.toList();
    } catch (e) {
      log.e('could not fetch sidechain transactions: $e');
    }

    try {
      newUTXOs = await rpc.listUTXOs();
    } catch (e) {
      log.e('could not fetch UTXOs: $e');
    }

    if (_dataHasChanged(newSidechainTransactions, newUTXOs, newInitialized)) {
      sidechainTransactions = newSidechainTransactions;
      utxos = newUTXOs;
      initialized = newInitialized;
      notifyListeners();
    }

    _isFetching = false;
  }

  bool _dataHasChanged(
    List<CoreTransaction> newSidechainTransactions,
    List<SidechainUTXO> newUTXOs,
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
