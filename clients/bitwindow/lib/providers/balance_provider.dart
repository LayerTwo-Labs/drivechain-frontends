import 'dart:async';

import 'package:bitwindow/api.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class BalanceProvider extends ChangeNotifier {
  API get api => GetIt.I.get<API>();

  // because the class extends ChangeNotifier, any subscribers
  // to this class will be notified of changes to these
  // variables.
  int balance = 0;
  int pendingBalance = 0;

  bool _isFetching = false;
  Timer? _fetchTimer;

  String? error;

  BalanceProvider() {
    _startFetchTimer();
  }

  Future<void> fetch() async {
    try {
      if (_isFetching) {
        return;
      }
      _isFetching = true;

      final res = await api.wallet.getBalance();

      if (_dataHasChanged(res.confirmedSatoshi.toInt(), res.pendingSatoshi.toInt())) {
        balance = res.confirmedSatoshi.toInt();
        pendingBalance = res.pendingSatoshi.toInt();
        error = null;
        notifyListeners();
      }
    } catch (err) {
      // Swallow the error, becomes incredibly noisy
      error = err.toString();
    } finally {
      _isFetching = false;
    }
  }

  bool _dataHasChanged(
    int newBalance,
    int newPendingBalance,
  ) {
    if (balance != newBalance) {
      return true;
    }
    if (pendingBalance != newPendingBalance) {
      return true;
    }

    return false;
  }

  void _startFetchTimer() {
    _fetchTimer = Timer.periodic(const Duration(seconds: 1), (_) => fetch());
  }

  @override
  void dispose() {
    _fetchTimer?.cancel();
    _fetchTimer = null;
    super.dispose();
  }
}
