import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

import '../../api/api.dart';

class TransactionsProvider extends ChangeNotifier {
  API get api => GetIt.I.get<API>();

  List<UTXO> claims = [];
  bool initialized = false;

  bool _isFetching = false;

  TransactionsProvider() {
    poll();
  }

  // call this function from anywhere to refetch transaction list
  Future<void> fetch() async {
    if (_isFetching) {
      return;
    }
    _isFetching = true;

    try {
      final newClaims = (await api.listClaims()).reversed.take(20).toList();
      const newInitialized = true;

      if (_dataHasChanged(newClaims, newInitialized)) {
        claims = newClaims;

        initialized = newInitialized;
        notifyListeners();
      }
    } finally {
      _isFetching = false;
    }
  }

  bool _dataHasChanged(
    List<UTXO> newClaims,
    bool newInitialized,
  ) {
    if (newInitialized != initialized) {
      return true;
    }

    if (!listEquals(claims, newClaims)) {
      return true;
    }

    return false;
  }

  Timer? _connectionTimer;
  void poll() {
    fetch();

    _connectionTimer?.cancel();
    _connectionTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await fetch();
    });
  }
}
