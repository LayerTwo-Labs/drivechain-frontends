import 'dart:async';

import 'package:bitwindow/providers/blockchain_provider.dart';
import 'package:collection/collection.dart';
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
  List<UnspentOutput> utxos = [];
  List<ReceiveAddress> receiveAddresses = [];
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
      // Run all updates in parallel
      final results = await Future.wait([
        update<List<WalletTransaction>>(
          walletTransactions,
          api.wallet.listTransactions,
          (v) => walletTransactions = v,
          equals: const DeepCollectionEquality().equals,
        ),
        update<String>(
          address,
          api.wallet.getNewAddress,
          (v) => address = v,
        ),
        update<List<UnspentOutput>>(
          utxos,
          api.wallet.listUnspent,
          (v) => utxos = v,
          equals: const DeepCollectionEquality().equals,
        ),
        update<List<ReceiveAddress>>(
          receiveAddresses,
          api.wallet.listReceiveAddresses,
          (v) => receiveAddresses = v,
          equals: const DeepCollectionEquality().equals,
        ),
      ]);

      // If any update returned true, notify listeners
      if (results.any((changed) => changed)) {
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

  Future<bool> update<T>(
    T currentValue,
    Future<T> Function() fetch,
    void Function(T) setValue, {
    bool Function(T a, T b)? equals,
  }) async {
    final newValue = await fetch();
    final isEqual = equals != null ? equals(currentValue, newValue) : currentValue == newValue;

    if (!isEqual) {
      setValue(newValue);
      return true;
    }
    return false;
  }

  Future<void> saveNote(String txid, String note) async {
    await api.bitwindowd.setTransactionNote(txid, note);
    await fetch();
  }

  @override
  void dispose() {
    balanceProvider.removeListener(fetch);
    blockchainProvider.removeListener(fetch);
    _fetchTimer?.cancel();
    super.dispose();
  }
}
