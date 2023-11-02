import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';

class TransactionsProvider extends ChangeNotifier {
  SidechainRPC get _rpc => GetIt.I.get<SidechainRPC>();

  // because the class extends ChangeNotifier, any subscribers
  // to this class will be notified of changes to these
  // variables.
  List<Transaction> transactions = [];
  bool initialized = false;

  // used for polling
  late Timer _timer;

  TransactionsProvider() {
    fetch();
    _startPolling();
  }

  // call this function from anywhere to refetch transaction list
  Future<void> fetch() async {
    transactions = await _rpc.listTransactions();
    initialized = true;
    notifyListeners();
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await fetch();
      notifyListeners();
    });
  }

  void stopPolling() {
    // Cancel timer when provider is disposed (never?)
    _timer.cancel();
  }

  @override
  void dispose() {
    super.dispose();
    stopPolling();
  }
}
