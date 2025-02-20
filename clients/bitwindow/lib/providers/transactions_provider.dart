import 'dart:async';

import 'package:bitwindow/providers/blockchain_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/env.dart';
import 'package:sail_ui/gen/wallet/v1/wallet.pb.dart';
import 'package:sail_ui/providers/balance_provider.dart';
import 'package:sail_ui/rpcs/bitwindow_api.dart';

// because the class extends ChangeNotifier, any subscribers
// to this class will be notified of changes to new transactions
class TransactionProvider extends ChangeNotifier {
  BitwindowRPC get api => GetIt.I.get<BitwindowRPC>();
  BalanceProvider get balanceProvider => GetIt.I.get<BalanceProvider>();
  BlockchainProvider get blockchainProvider => GetIt.I.get<BlockchainProvider>();

  String address = '';
  List<WalletTransaction> walletTransactions = [];
  bool initialized = false;
  String? error;

  bool _isFetching = false;
  Timer? _fetchTimer; // Timer to periodically fetch transactions

  TransactionProvider() {
    balanceProvider.addListener(fetch);
    blockchainProvider.addListener(fetch);
    _startFetchingTimer();
  }

  // Fetch transactions every 5 seconds, just in case something happens
  // automatically behind the scenes
  void _startFetchingTimer() {
    if (Environment.isInTest) {
      return;
    }

    _fetchTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      fetch();
    });
  }

  // call this function from anywhere to refetch transaction list
  Future<void> fetch() async {
    if (_isFetching) {
      return;
    }
    _isFetching = true;
    error = null;

    try {
      final newTXs = await api.wallet.listTransactions();
      final newAddress = await api.wallet.getNewAddress();

      if (_dataHasChanged(newTXs, newAddress)) {
        walletTransactions = newTXs;
        address = newAddress;
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
    List<WalletTransaction> newTXs,
    String newAddress,
  ) {
    if (newTXs.length != walletTransactions.length) {
      return true;
    }

    for (int i = 0; i < newTXs.length; i++) {
      if (!walletTransactions[i].isEqual(newTXs[i])) {
        return true;
      }
    }

    return address != newAddress;
  }

  @override
  void dispose() {
    balanceProvider.removeListener(fetch);
    blockchainProvider.removeListener(fetch);
    _fetchTimer?.cancel();
    super.dispose();
  }
}

extension WalletTransactionExtensions on WalletTransaction {
  bool isEqual(WalletTransaction other) {
    return toDebugString() == other.toDebugString();
  }
}
