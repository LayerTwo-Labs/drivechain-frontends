import 'dart:async';

import 'package:faucet/api/api_base.dart';
import 'package:faucet/gen/bitcoin/bitcoind/v1alpha/bitcoin.pb.dart';
import 'package:faucet/gen/faucet/v1/faucet.pb.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

class TransactionsProvider extends ChangeNotifier {
  API get api => GetIt.I.get<API>();

  List<GetTransactionResponse> claims = [];
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
      final newClaims =
          (await api.clients.faucet.listClaims(ListClaimsRequest())).transactions.reversed.take(100).toList();
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
    List<GetTransactionResponse> newClaims,
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
    _connectionTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      await fetch();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _connectionTimer?.cancel();
  }
}
