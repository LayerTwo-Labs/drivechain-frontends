import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidesail/rpc/models/zcash_utxos.dart';
import 'package:sidesail/rpc/rpc_zcash.dart';

class ZCashProvider extends ChangeNotifier {
  ZCashRPC get rpc => GetIt.I.get<ZCashRPC>();
  Logger get log => GetIt.I.get<Logger>();

  String zcashAddress = '';
  List<OperationStatus> operations = [];
  List<ShieldedUTXO> shieldedUTXOs = [];
  List<UnshieldedUTXO> unshieldedUTXOs = [];
  double sideFee = 0.00001;

  // used for polling
  late Timer _timer;

  ZCashProvider() {
    fetch();
    _startPolling();
  }

  // call this function from anywhere to refetch transaction list
  Future<void> fetch() async {
    try {
      zcashAddress = await rpc.sideGenerateAddress();
      operations.addAll(await rpc.listOperations());
      shieldedUTXOs = await rpc.listShieldedCoins();
      unshieldedUTXOs = await rpc.listUnshieldedCoins();
      sideFee = await rpc.sideEstimateFee();
    } catch (error) {
      log.e('zcash_provider could not fetch: $error');
    }

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

  // From here on out, MELT CODE BBY
  List<PendingShield> utxosToMelt = [];
  // One timer is added to this list per UTXO the user wants to melt
  // Each timer is given a random duration between 0 and the max minutes
  // the user wants all utxos shielded by
  final List<Timer> _timers = [];

  Future<List<double>> melt(List<UnshieldedUTXO> utxos, double completedInMinutes) async {
    final List<double> meltsWillHappenAt = [];

    for (final utxo in utxos) {
      final pending = PendingShield(
        utxo: utxo,
        maxMinutes: completedInMinutes,
        executeAction: () async {
          // shield, fetch, notify listeners, then delete from array
          await rpc.shield(utxo, utxo.amount - sideFee);
          await fetch();
          utxosToMelt.removeWhere((u) => u.utxo.txid == utxo.txid && u.utxo.address == utxo.address);
          notifyListeners();
        },
      );

      utxosToMelt.add(pending);
      _timers.add(pending.timer);
    }

    meltsWillHappenAt.sort((a, b) => a.compareTo(b));
    return meltsWillHappenAt;
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
    for (final timer in _timers) {
      timer.cancel();
    }
  }
}

class PendingShield {
  UnshieldedUTXO utxo;
  double maxMinutes;
  VoidCallback executeAction;

  late Timer timer;
  late DateTime executeTime;
  late Duration executeIn;

  PendingShield({
    required this.utxo,
    required this.maxMinutes,
    required this.executeAction,
  }) {
    Random random = Random();
    // Multiply function arg by 60 to get seconds. More precise
    // if the user wants it done in a few minutes, or sub-minutes
    final maxCompletionSeconds = (maxMinutes * 60).toInt();
    final secondsForThisUTXO = random.nextInt(maxCompletionSeconds) + 1;

    executeIn = Duration(seconds: secondsForThisUTXO);
    executeTime = DateTime.now().add(executeIn);
    // timer responsible for shielding the utxo after x seconds have passed
    timer = Timer(
      executeIn,
      executeAction,
    );
  }
}
