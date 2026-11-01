import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/sidechain_core.dart';

class SidechainTransactionsProvider extends ChangeNotifier {
  final SidechainRPC rpc;
  Logger get log => GetIt.I.get<Logger>();

  List<CoreTransaction> sidechainTransactions = [];
  List<SidechainUTXO> utxos = [];
  bool initialized = false;

  /// True once the node listed the UTXOs one time. [utxos] stays empty before that.
  bool utxosLoaded = false;

  /// [rpc] defaults to the sidechain RPC in GetIt.
  SidechainTransactionsProvider({SidechainRPC? rpc}) : rpc = rpc ?? GetIt.I.get<SidechainRPC>() {
    this.rpc.addListener(fetch);
    fetch();
  }

  bool _isFetching = false;
  // call this function from anywhere to refetch transaction list
  Future<void> fetch() async {
    if (_isFetching) {
      return;
    }
    _isFetching = true;

    var newSidechainTransactions = sidechainTransactions;
    var newUTXOs = utxos;
    final newInitialized = true;

    try {
      newSidechainTransactions = (await rpc.listTransactions()).reversed.toList();
    } catch (e) {
      log.e('could not fetch sidechain transactions: $e');
    }

    var newUTXOsLoaded = utxosLoaded;
    try {
      newUTXOs = await rpc.listUTXOs();
      newUTXOsLoaded = true;
    } catch (e) {
      log.e('could not fetch UTXOs: $e');
    }

    if (_dataHasChanged(newSidechainTransactions, newUTXOs, newInitialized) || newUTXOsLoaded != utxosLoaded) {
      sidechainTransactions = newSidechainTransactions;
      utxos = newUTXOs;
      initialized = newInitialized;
      utxosLoaded = newUTXOsLoaded;
      notifyListeners();
    }

    _isFetching = false;
  }

  bool _dataHasChanged(
    List<CoreTransaction> newSidechainTransactions,
    List<SidechainUTXO> newUTXOs,
    bool newInitialized,
  ) {
    if (newInitialized != initialized) {
      return true;
    }

    if (!listEquals(sidechainTransactions, newSidechainTransactions)) {
      return true;
    }

    if (!listEquals(utxos, newUTXOs)) {
      return true;
    }

    return false;
  }

  @override
  void dispose() {
    rpc.removeListener(fetch);
    super.dispose();
  }
}
