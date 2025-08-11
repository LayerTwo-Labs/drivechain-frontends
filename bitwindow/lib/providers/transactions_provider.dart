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
  BitwindowRPC get bitwindowd => GetIt.I.get<BitwindowRPC>();
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
    fetch();

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
          () async {
            final fetchedTransactions = await bitwindowd.wallet.listTransactions();
            // Sort by confirmation time, newest first
            fetchedTransactions.sort((a, b) {
              final aTime = a.confirmationTime.timestamp.seconds;
              final bTime = b.confirmationTime.timestamp.seconds;
              // If timestamps are equal, use txid as secondary sort
              if (aTime == bTime) {
                return b.txid.compareTo(a.txid);
              }
              return bTime.compareTo(aTime); // Newest first
            });
            return fetchedTransactions;
          },
          (v) => walletTransactions = v,
          equals: const DeepCollectionEquality().equals,
        ),
        update<String>(
          address,
          bitwindowd.wallet.getNewAddress,
          (v) => address = v,
        ),
        update<List<UnspentOutput>>(
          utxos,
          () async {
            final fetchedUtxos = await bitwindowd.wallet.listUnspent();
            // Sort by date received, newest first
            fetchedUtxos.sort((a, b) {
              final aTime = a.receivedAt.seconds;
              final bTime = b.receivedAt.seconds;
              // If timestamps are equal, use output as secondary sort
              if (aTime == bTime) {
                return b.output.compareTo(a.output);
              }
              return bTime.compareTo(aTime); // Newest first
            });
            return fetchedUtxos;
          },
          (v) => utxos = v,
          equals: const DeepCollectionEquality().equals,
        ),
        update<List<ReceiveAddress>>(
          receiveAddresses,
          () async {
            final fetchedAddresses = await bitwindowd.wallet.listReceiveAddresses();
            // Sort by creation time if available, or by address alphabetically
            fetchedAddresses.sort((a, b) {
              // Assuming addresses have some timestamp or index, otherwise sort alphabetically
              return a.address.compareTo(b.address);
            });
            return fetchedAddresses;
          },
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
      if (e.toString() != error) {
        error = e.toString();
        notifyListeners();
      }
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
    await bitwindowd.bitwindowd.setTransactionNote(txid, note);
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
