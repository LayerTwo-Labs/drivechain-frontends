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
    zcashAddress = await rpc.sideGenerateAddress();
    operations.addAll(await rpc.listOperations());
    shieldedUTXOs = await rpc.listShieldedCoins();
    unshieldedUTXOs = await rpc.listUnshieldedCoins();
    sideFee = await rpc.sideEstimateFee();

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
  List<UnshieldedUTXO> utxosToMelt = [];
  // One timer is added to this list per UTXO the user wants to melt
  // Each timer is given a random duration between 0 and the max minutes
  // the user wants all utxos shielded by
  final List<Timer> _timers = [];

  Future<List<double>> melt(List<UnshieldedUTXO> utxos, double completedInMinutes) async {
    Random random = Random();
    final List<double> meltsWillHappenAt = [];

    for (final utxo in utxos) {
      // Multiply function arg by 60 to get seconds. More precise
      // if the user wants it done in a few minutes, or sub-minutes
      final maxCompletionSeconds = (completedInMinutes * 60).toInt();
      final secondsForThisUTXO = random.nextInt(maxCompletionSeconds) + 1;

      // shield the utxo after x seconds have passed
      final timer = Timer(
        Duration(seconds: secondsForThisUTXO),
        () => rpc.shield(utxo, utxo.amount - sideFee),
      );

      meltsWillHappenAt.add(secondsForThisUTXO / 60);

      _timers.add(timer);
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
