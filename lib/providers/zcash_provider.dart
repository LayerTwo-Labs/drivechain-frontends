import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sidesail/logger.dart';
import 'package:sidesail/rpc/models/zcash_utxos.dart';
import 'package:sidesail/rpc/rpc_zcash.dart';

class ZCashProvider extends ChangeNotifier {
  ZCashRPC get rpc => GetIt.I.get<ZCashRPC>();

  // because the class extends ChangeNotifier, any subscribers
  // to this class will be notified of changes to these
  // variables.
  String get zcashAddress => rpc.address;
  List<OperationStatus> operations = [];
  List<ShieldedUTXO> shieldedUTXOs = [];
  List<UnshieldedUTXO> unshieldedUTXOs = [];
  bool initialized = false;

  // used for polling
  late Timer _timer;

  ZCashProvider() {
    fetch();
    _startPolling();
  }

  // call this function from anywhere to refetch transaction list
  Future<void> fetch() async {
    operations = await rpc.listOperations();
    shieldedUTXOs = await rpc.listShieldedCoins();
    unshieldedUTXOs = await rpc.listUnshieldedCoins();

    initialized = true;

    notifyListeners();
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        await fetch();
        notifyListeners();
      } catch (error) {
        log.t('could not fetch transactions: $error');
      }
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
