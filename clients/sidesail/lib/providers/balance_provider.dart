import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidesail/rpc/rpc_mainchain.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';

class BalanceProvider extends ChangeNotifier {
  MainchainRPC get _mainRPC => GetIt.I.get<MainchainRPC>();
  SidechainContainer get sidechain => GetIt.I.get<SidechainContainer>();
  Logger log = GetIt.I.get<Logger>();

  // because the class extends ChangeNotifier, any subscribers
  // to this class will be notified of changes to these
  // variables.
  double balance = 0;
  double pendingBalance = 0;
  bool initialized = false;

  bool _isFetching = false;

  BalanceProvider() {
    fetch();
    sidechain.rpc.addListener(fetch);
    _mainRPC.addListener(fetch);
  }

  // call this function from anywhere to refresh the balance
  Future<void> fetch() async {
    // Explicitly ignoring errors here. RPC connection issues are handled
    // elsewhere!
    try {
      if (_isFetching) {
        return;
      }
      _isFetching = true;

      final (newBalance, newPendingBalance) = await sidechain.rpc.getBalance();
      const newInitialized = true;

      if (_dataHasChanged(newBalance, newPendingBalance, newInitialized)) {
        balance = newBalance;
        pendingBalance = newPendingBalance;
        initialized = newInitialized;
        notifyListeners();
      }
    } catch (err) {
      // Swallow the error, becomes incredibly noisy
    } finally {
      _isFetching = false;
    }
  }

  bool _dataHasChanged(
    double newBalance,
    double newPendingBalance,
    bool newInitialized,
  ) {
    if (initialized != newInitialized) {
      return true;
    }

    if (balance != newBalance) {
      return true;
    }
    if (pendingBalance != newPendingBalance) {
      return true;
    }

    return false;
  }

  @override
  void dispose() {
    super.dispose();
    sidechain.removeListener(fetch);
    _mainRPC.removeListener(fetch);
  }
}
