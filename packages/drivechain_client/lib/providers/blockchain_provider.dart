import 'dart:async';

import 'package:drivechain_client/api.dart';
import 'package:drivechain_client/gen/drivechain/v1/drivechain.pbgrpc.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

class BlockchainProvider extends ChangeNotifier {
  API get api => GetIt.I.get<API>();

  List<UnconfirmedTransaction> walletTransactions = [];
  bool initialized = false;

  bool _isFetching = false;

  BlockchainProvider();

  // call this function from anywhere to refetch transaction list
  Future<void> fetch() async {
    if (_isFetching) {
      return;
    }
    _isFetching = true;

    try {
      final newTXs = await api.drivechain.listUnconfirmedTransactions();

      if (_dataHasChanged(newTXs)) {
        walletTransactions = newTXs;
        notifyListeners();
      }
    } finally {
      _isFetching = false;
    }
  }

  bool _dataHasChanged(
    List<UnconfirmedTransaction> newTXs,
  ) {
    if (!listEquals(walletTransactions, newTXs)) {
      return true;
    }

    return false;
  }
}
