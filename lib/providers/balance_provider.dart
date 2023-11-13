import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';

class BalanceProvider extends ChangeNotifier {
  SidechainContainer get sidechain => GetIt.I.get<SidechainContainer>();

  // because the class extends ChangeNotifier, any subscribers
  // to this class will be notified of changes to these
  // variables.
  double balance = 0;
  double pendingBalance = 0;
  bool initialized = false;

  // used for polling
  late Timer _timer;

  BalanceProvider() {
    fetch();
    _startPolling();
    sidechain.addListener(fetch);
  }

  // call this function from anywhere to refresh the balance
  Future<void> fetch() async {
    final (bal, pendingBal) = await sidechain.rpc.getBalance();
    // TODO: Handle error?
    balance = bal;
    pendingBalance = pendingBal;

    initialized = true;
    notifyListeners();
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        await fetch();
      } catch (error) {
        // do nothing with it, just don't spam the console
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    super.dispose();
    // Cancel timer when provider is disposed (never?)
    _timer.cancel();
    sidechain.removeListener(notifyListeners);
  }
}
