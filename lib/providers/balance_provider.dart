import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sidesail/rpc/rpc.dart';

class BalanceProvider extends ChangeNotifier {
  RPC get _rpc => GetIt.I.get<RPC>();

  // because the class extends ChangeNotifier, any subscribers
  // to this class will be notified of changes to this
  // variable.
  double balance = 0;
  bool initialized = false;

  // used for polling
  late Timer _timer;

  BalanceProvider() {
    fetch();
    _startPolling();
  }

  // call this function from anywhere to refresh the balance
  Future<void> fetch() async {
    balance = await _rpc.getBalance();
    // TODO: Handle error?

    initialized = true;
    notifyListeners();
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await fetch();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    super.dispose();
    // Cancel timer when provider is disposed (never?)
    _timer.cancel();
  }
}
