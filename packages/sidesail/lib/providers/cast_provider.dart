import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidesail/bitcoin.dart';
import 'package:sidesail/rpc/models/zcash_utxos.dart';
import 'package:sidesail/rpc/rpc_zcash.dart';

const lowestCastValueSats = 1048576;
const maxCastFactor = 14;

class CastBundle {
  int powerOf;
  VoidCallback executeAction;
  late DateTime executeTime;
  late Timer executeTimer;

  num get castAmount => satoshiToBTC(lowestCastValueSats << (powerOf - 1));

  List<PendingCast> pendingCasts = [];

  CastBundle({
    required this.powerOf,
    required this.executeAction,
  }) {
    // Lowest one (0.00016384) will be done every 14 minutes,
    // highest one every minute
    final executeIn = Duration(seconds: (maxCastFactor - powerOf + 1));

    executeTime = DateTime.now().add(executeIn);
    executeTimer = Timer(executeIn, executeAction);
  }

  void addPendingCast(PendingCast newPending) {
    Logger log = GetIt.I.get<Logger>();
    log.i('added pending cast to bundle amount=${newPending.perUTXOAmount} powerOf=$powerOf executedAt=$executeTime');

    pendingCasts.add(newPending);
  }
}

class PendingCast {
  ShieldedUTXO fromUTXO;
  List<String> toAddresses;
  double perUTXOAmount;

  PendingCast({
    required this.fromUTXO,
    required this.toAddresses,
    required this.perUTXOAmount,
  });
}

class CastProvider extends ChangeNotifier {
  ZCashRPC get _rpc => GetIt.I.get<ZCashRPC>();
  Logger get log => GetIt.I.get<Logger>();

  List<CastBundle> futureCasts = List.filled(maxCastFactor + 1, CastBundle(powerOf: 0, executeAction: () => {}));

  CastProvider() {
    for (int i = 1; i <= maxCastFactor; i++) {
      final newBundle = CastBundle(powerOf: i, executeAction: () => executeCast(i));

      log.i(
        'created new bundle executeTime=${newBundle.executeTime} powerOf=${newBundle.powerOf} amountSats=${newBundle.castAmount}',
      );

      futureCasts[i] = newBundle;
    }
  }

  void executeCast(int powerOf) async {
    final bundle = futureCasts.elementAt(powerOf);
    log.d('executing powerOf=${bundle.powerOf} with amount=${bundle.castAmount}');

    for (final pending in bundle.pendingCasts) {
      final opid = await _rpc.cast(pending.fromUTXO, pending.perUTXOAmount, pending.toAddresses);
      log.i('casted utxo=${pending.fromUTXO.amount} perUTXOAmount=${pending.perUTXOAmount} opid=$opid');
    }

    final newBundle = CastBundle(powerOf: bundle.powerOf, executeAction: () => executeCast(powerOf));
    futureCasts[bundle.powerOf] = newBundle;
    log.d('recreated next bundle to be executed at ${newBundle.executeTime} arraySize=${futureCasts.length}');
  }

  CastBundle? findBundleForAmount(double amount) {
    for (int i = maxCastFactor; i >= 1; i--) {
      final bundle = futureCasts[i];

      final factor = amount / bundle.castAmount.toInt();
      if (factor >= 4) {
        // the amount fit in 4 utxos! This is the bundle we're looking for
        log.d(
          'found fitting bundle bundleAmount=${bundle.castAmount} factor=$factor shallExecuteAt=${bundle.executeTime} powerOf=${bundle.powerOf}',
        );
        return bundle;
      }
    }

    log.i('did not find fitting bundle');
    return null;
  }

  void addPendingCast(CastBundle toBundle, PendingCast newPending) {
    final bundle = futureCasts[toBundle.powerOf];
    bundle.addPendingCast(newPending);
    futureCasts[toBundle.powerOf] = bundle;
  }
}
