import 'dart:async';

import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/gen/bitwindowd/v1/bitwindowd.pb.dart';
import 'package:sail_ui/rpcs/bitwindow_api.dart';

// because the class extends ChangeNotifier, any subscribers
// to this class will be notified of changes to new transactions
class DenialProvider extends ChangeNotifier {
  BitwindowRPC get api => GetIt.I.get<BitwindowRPC>();
  TransactionProvider get transactionProvider => GetIt.I.get<TransactionProvider>();

  List<UnspentOutput> utxos = [];
  bool initialized = false;
  String? error;

  bool _isFetching = false;

  DenialProvider() {
    transactionProvider.addListener(fetch);
  }

  // call this function from anywhere to refetch denial list
  Future<void> fetch() async {
    if (_isFetching) {
      return;
    }
    _isFetching = true;
    error = null;

    try {
      final newDenials = await api.bitwindowd.listDenials();

      if (_dataHasChanged(newDenials)) {
        utxos = newDenials;
        initialized = true;
        error = null;
        notifyListeners();
      }
    } catch (e) {
      error = e.toString();
      notifyListeners();
    } finally {
      _isFetching = false;
    }
  }

  bool _dataHasChanged(
    List<UnspentOutput> newDenials,
  ) {
    return !listEquals(utxos, newDenials);
  }

  @override
  void dispose() {
    transactionProvider.removeListener(fetch);
    super.dispose();
  }
}
