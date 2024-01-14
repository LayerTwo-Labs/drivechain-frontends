import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidesail/bitcoin.dart';
import 'package:sidesail/providers/zcash_provider.dart';
import 'package:sidesail/rpc/models/zcash_utxos.dart';
import 'package:sidesail/rpc/rpc_zcash.dart';

const lowestCastValueSats = 1;
const maxCastFactor = 50;

class PendingCastBill {
  int powerOf;
  double castFee;

  VoidCallback executeAction;
  late DateTime executeTime;
  late Duration executeIn;

  num get castAmount => satoshiToBTC(lowestCastValueSats << (powerOf - 1));
  List<PendingShield> pendingShields = [];

  PendingCastBill({
    required this.powerOf,
    required this.castFee,
    required this.executeAction,
  }) {
    // Lowest one (0.00000001) will be done every second,
    // highest one every minute
    executeIn = Duration(seconds: (powerOf + 1));
    executeTime = DateTime.now().add(executeIn);
    Timer(executeIn, executeAction);
  }

  void addPendingShield(PendingShield newPending) {
    Logger log = GetIt.I.get<Logger>();
    log.i('added pending cast amount=${newPending.amount} powerOf=$powerOf executedAt=$executeTime');

    pendingShields.add(newPending);
  }
}

class PendingShield {
  int pow;
  ShieldedUTXO fromUTXO;

  double get amount {
    var amountSats = 1;

    for (int i = 1; i < pow; i++) {
      amountSats = amountSats * 2;
    }

    return satoshiToBTC(amountSats);
  }

  PendingShield({
    required this.pow,
    required this.fromUTXO,
  });
}

class CastProvider extends ChangeNotifier {
  ZCashProvider get _zcashProvider => GetIt.I.get<ZCashProvider>();
  ZCashRPC get _rpc => GetIt.I.get<ZCashRPC>();
  Logger get log => GetIt.I.get<Logger>();
  double get castFee => _zcashProvider.sideFee * _rpc.numUTXOsPerCast;

  List<PendingCastBill> futureCasts = List.filled(
    maxCastFactor + 1,
    PendingCastBill(
      powerOf: 0,
      executeAction: () => {},
      castFee: 0,
    ),
  );

  CastProvider() {
    for (int i = 1; i <= maxCastFactor; i++) {
      final newBundle = PendingCastBill(
        powerOf: i,
        executeAction: () => _executeCast(i),
        castFee: castFee,
      );

      log.i(
        'created new bundle executeTime=${newBundle.executeTime} powerOf=${newBundle.powerOf} amountSats=${newBundle.castAmount}',
      );

      futureCasts[i] = newBundle;
    }
  }

  void _executeCast(int powerOf) async {
    final bundle = futureCasts.elementAt(powerOf);
    log.d('executing powerOf=${bundle.powerOf} with amount=${bundle.castAmount}');

    for (final pending in bundle.pendingShields) {
      final opid = await _rpc.deshield(pending.fromUTXO, pending.amount);
      log.i('casted utxo=${pending.fromUTXO.amount} pow=$powerOf opid=$opid');
    }

    final newBill = PendingCastBill(
      powerOf: bundle.powerOf,
      executeAction: () => _executeCast(powerOf),
      castFee: castFee,
    );
    futureCasts[bundle.powerOf] = newBill;
    log.d('recreated next bundle to be executed at ${newBill.executeTime} arraySize=${futureCasts.length}');

    await _zcashProvider.fetch();
  }

  List<PendingCastBill>? findBillsForAmount(double amount) {
    if (amount <= 0) {
      return null;
    }

    List<PendingCastBill> bills = [];
    var nextAmountSats = btcToSatoshi(amount);

    for (int i = 0; i < 4; i++) {
      // we want to find 4 bills!
      final (billAmount, powerOf) = findMaxBill(nextAmountSats, 1, 1);

      nextAmountSats = nextAmountSats - billAmount;

      final bundle = PendingCastBill(
        powerOf: powerOf,
        executeAction: () => _executeCast(powerOf),
        castFee: castFee,
      );

      log.d(
        'found fitting bundle billAmount=$billAmount powerOf=$powerOf executeTime=${bundle.executeTime}',
      );

      bills.add(bundle);
    }
    return bills;
  }

  // finds the next highest factor of two that does not exceed maxAmountSats
  (int, int) findMaxBill(int maxAmountSats, int currentAmountSats, int currentMultiple) {
    final newAmountSats = currentAmountSats * 2;

    if (newAmountSats >= maxAmountSats) {
      return (currentAmountSats, currentMultiple);
    }

    return findMaxBill(maxAmountSats, newAmountSats, currentMultiple + 1);
  }

  void addPendingUTXO(
    List<PendingCastBill> newPendingBills, {
    required ShieldedUTXO utxo,
  }) {
    for (final newPending in newPendingBills) {
      // extract current bundles
      final bundle = futureCasts[newPending.powerOf];

      // create new bundle
      final shield = PendingShield(
        fromUTXO: utxo,
        pow: newPending.powerOf,
      );
      bundle.addPendingShield(shield);

      // add existing+new bundle to future casts
      futureCasts[newPending.powerOf] = bundle;
    }
  }
}
