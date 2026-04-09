import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/bitcoin.dart';
import 'package:sail_ui/rpcs/zside_rpc.dart';
import 'package:zside/providers/zside_provider.dart';

const lowestCastValueSats = 1;
const maxCastFactor = 42;

class PendingCastBill {
  int powerOf;

  VoidCallback executeAction;
  late DateTime executeTime;
  late Duration executeIn;

  num get castAmount => satoshiToBTC(lowestCastValueSats << (powerOf - 1));
  List<PendingDeshield> pendingShields = [];

  PendingCastBill({
    required this.powerOf,
    required this.executeAction,
  }) {
    DateTime now = DateTime.now().toUtc();
    executeTime = DateTime.utc(now.year, now.month, now.day + 1);

    int weekday;

    switch (powerOf % 7) {
      case 1:
        weekday = DateTime.sunday;
        break;
      case 2:
        weekday = DateTime.monday;
        break;
      case 3:
        weekday = DateTime.tuesday;
        break;
      case 4:
        weekday = DateTime.wednesday;
        break;
      case 5:
        weekday = DateTime.thursday;
        break;
      case 6:
        weekday = DateTime.friday;
        break;
      case 0:
        weekday = DateTime.saturday;
        break;
      default:
        throw Exception('Invalid powerOf value');
    }

    while (executeTime.weekday != weekday) {
      executeTime = executeTime.add(const Duration(days: 1));
    }

    executeIn = now.durationUntil(executeTime);

    Timer(executeIn, executeAction);
  }

  void addPendingShield(PendingDeshield newPending) {
    Logger log = GetIt.I.get<Logger>();
    log.i('added pending cast amount=${newPending.amount} powerOf=$powerOf executedAt=$executeTime');

    pendingShields.add(newPending);
  }
}

class PendingDeshield {
  int pow;
  ShieldedUTXO fromUTXO;

  double get amount {
    var amountSats = 1;

    for (int i = 1; i < pow; i++) {
      amountSats = amountSats * 2;
    }

    return satoshiToBTC(amountSats);
  }

  PendingDeshield({
    required this.pow,
    required this.fromUTXO,
  });
}

class CastProvider extends ChangeNotifier {
  ZSideProvider get _zsideProvider => GetIt.I.get<ZSideProvider>();
  ZSideRPC get _rpc => GetIt.I.get<ZSideRPC>();
  Logger get log => GetIt.I.get<Logger>();
  double get castFee => _zsideProvider.sideFee * _rpc.numUTXOsPerCast;

  double autoMeltUTXOsOfSize = 0.0;

  List<PendingCastBill> futureCasts = List.filled(
    maxCastFactor + 1,
    PendingCastBill(
      powerOf: 1,
      executeAction: () => {},
    ),
  );

  CastProvider() {
    for (int i = 1; i <= maxCastFactor; i++) {
      final newBill = PendingCastBill(
        powerOf: i,
        executeAction: () => _executeCast(i, 0),
      );

      futureCasts[i] = newBill;
    }

    _zsideProvider.addListener(_checkAutoMelt);
  }

  void _checkAutoMelt() {
    final privateUTXOs = _zsideProvider.privateTransactions;

    for (final utxo in privateUTXOs) {
      if (utxo.amount == 0) {
        continue;
      }

      if (utxo.confirmations >= 1 && utxo.amount == autoMeltUTXOsOfSize) {
        // the user is in auto mode, and their melted utxos finally
        // got confirmed, we should cast it!

        final bills = findBillsForAmount(utxo);
        if (bills == null) {
          // too small or iconsequential to be casted
          autoMeltUTXOsOfSize = 0.0;
          continue;
        }

        addPendingUTXO(bills, utxo: utxo);
        // reset, so newer utxos are not casted
        autoMeltUTXOsOfSize = 0.0;
      }
    }
  }

  void _executeCast(int powerOf, int iteration) async {
    try {
      final bill = futureCasts.elementAt(powerOf);
      log.t('executing powerOf=${bill.powerOf} with amount=${bill.castAmount}');

      for (final pending in bill.pendingShields) {
        final opid = await _rpc.deshield(pending.fromUTXO, pending.amount);
        log.i('casted utxo=${pending.fromUTXO.amount} pow=$powerOf opid=$opid');
      }

      final newBill = PendingCastBill(
        powerOf: bill.powerOf,
        executeAction: () => _executeCast(powerOf, iteration + 1),
      );
      futureCasts[bill.powerOf] = newBill;

      await _zsideProvider.fetch();
    } catch (error) {
      log.e('could not cast ${error.toString()}');
    }
  }

  void castWhenMeltCompleted(double meltAmount) {
    autoMeltUTXOsOfSize = meltAmount;
  }

  List<PendingDeshield>? findBillsForAmount(ShieldedUTXO utxo) {
    final amount = utxo.amount - castFee;
    if (amount <= 0) {
      return null;
    }

    List<PendingDeshield> pendingShields = [];
    var nextAmountSats = btcToSatoshi(amount);

    for (int i = 0; i < 4; i++) {
      // we want to find 4 bills!
      final (billAmount, powerOf) = findMaxBill(nextAmountSats, 1, 1);

      nextAmountSats = nextAmountSats - billAmount;

      final pending = PendingDeshield(
        fromUTXO: utxo,
        pow: powerOf,
      );

      log.d(
        'found fitting bill amount=$billAmount powerOf=$powerOf',
      );

      pendingShields.add(pending);
    }
    return pendingShields;
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
    List<PendingDeshield> newPendingBills, {
    required ShieldedUTXO utxo,
  }) {
    for (final newPending in newPendingBills) {
      // extract current bills
      final bill = futureCasts[newPending.pow];

      // create new pending deshield
      final deshield = PendingDeshield(
        fromUTXO: utxo,
        pow: newPending.pow,
      );
      bill.addPendingShield(deshield);

      // add existing+new bundle to future casts
      futureCasts[newPending.pow] = bill;
    }

    notifyListeners();
  }
}

extension DateTimeExtensions on DateTime {
  Duration durationUntil(DateTime futureTime) {
    return futureTime.difference(this);
  }
}
