import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

class ZSideProvider extends ChangeNotifier {
  ZSideRPC get rpc => GetIt.I.get<ZSideRPC>();
  Logger get log => GetIt.I.get<Logger>();

  BitcoindConnection get _mainchainRPC => GetIt.I.get<BitcoindConnection>();
  ZSideRPC get _rpc => GetIt.I.get<ZSideRPC>();

  String zsideAddress = '';
  int shieldedSats = 0;
  int transparentSats = 0;
  List<ShieldedUTXO> shieldedUTXOs = [];
  List<UnshieldedUTXO> unshieldedUTXOs = [];
  List<CoreTransaction> transparentTransactions = [];
  List<ShieldedUTXO> privateTransactions = [];

  double sideFee = zsideFee;
  String? error;

  bool _isFetching = false;

  ZSideProvider() {
    // fetch on launch
    fetch();

    // then refetch every time the block count is updated
    _mainchainRPC.addListener(fetch);
    _rpc.addListener(fetch);
  }

  Future<void> fetch() async {
    try {
      if (_isFetching) {
        return;
      }
      _isFetching = true;

      final ownedAddresses = await rpc.getShieldedWalletAddresses();
      var newZcashAddress = ownedAddresses.contains(zsideAddress)
          ? zsideAddress
          : ownedAddresses.firstOrNull ?? await rpc.getNewShieldedAddress();
      final breakdown = await rpc.getBalanceBreakdown();
      var newShieldedUTXOs = (await rpc.listShieldedUTXOs()).reversed.toList();
      var newUnshieldedUTXOs = (await rpc.listUnshieldedUTXOs()).reversed.toList();
      var newTransparentTXs = (await rpc.listTransactions()).reversed.toList();
      var newPrivateTXs = (await rpc.listPrivateTransactions()).reversed.toList();
      var newSideFee = await rpc.sideEstimateFee();

      if (breakdown.availableShieldedSats != shieldedSats || breakdown.availableTransparentSats != transparentSats) {
        shieldedSats = breakdown.availableShieldedSats;
        transparentSats = breakdown.availableTransparentSats;
        notifyListeners();
      }
      if (_dataHasChanged(
        newZcashAddress,
        newShieldedUTXOs,
        newUnshieldedUTXOs,
        newTransparentTXs,
        newPrivateTXs,
        newSideFee,
      )) {
        zsideAddress = newZcashAddress;
        shieldedUTXOs = newShieldedUTXOs;
        unshieldedUTXOs = newUnshieldedUTXOs;
        transparentTransactions = newTransparentTXs;
        privateTransactions = newPrivateTXs;
        sideFee = newSideFee;
        notifyListeners();
      }
      if (error != null) {
        error = null;
        notifyListeners();
      }
    } catch (err) {
      final message = 'Could not load the zSide wallet: $err';
      if (error != message) {
        error = message;
        notifyListeners();
      }
    } finally {
      _isFetching = false;
    }
  }

  bool _dataHasChanged(
    String newZcashAddress,
    List<ShieldedUTXO> newShieldedUTXOs,
    List<UnshieldedUTXO> newUnshieldedUTXOs,
    List<CoreTransaction> newTransparentTXs,
    List<ShieldedUTXO> newPrivateTXs,
    double newSideFee,
  ) {
    if (newZcashAddress != zsideAddress) {
      return true;
    }

    if (!listEquals(shieldedUTXOs, newShieldedUTXOs)) {
      return true;
    }

    if (!listEquals(unshieldedUTXOs, newUnshieldedUTXOs)) {
      return true;
    }

    if (!listEquals(transparentTransactions, newTransparentTXs)) {
      return true;
    }

    if (!listEquals(privateTransactions, newPrivateTXs)) {
      return true;
    }

    if (sideFee != newSideFee) {
      return true;
    }

    return false;
  }

  // From here on out, MELT CODE BBY
  List<PendingShield> utxosToMelt = [];
  // One timer is added to this list per UTXO the user wants to melt
  // Each timer is given a random duration between 0 and the max minutes
  // the user wants all utxos shielded by
  final List<Timer> _timers = [];

  final StreamController<CompletedMelt> _meltsCompleted = StreamController<CompletedMelt>.broadcast();

  /// One event per call of [melt], after its last UTXO is shielded or failed.
  Stream<CompletedMelt> get meltsCompleted => _meltsCompleted.stream;

  Future<List<int>> melt(List<UnshieldedUTXO> utxos, double completedInMinutes) async {
    final List<int> meltsWillHappenAt = [];
    final startedAt = DateTime.now();
    var remaining = utxos.length;
    var shielded = 0;
    var shieldedAmount = 0.0;

    for (final utxo in utxos) {
      final pending = PendingShield(
        utxo: utxo,
        maxMinutes: completedInMinutes,
        executeAction: () async {
          try {
            await rpc.shield(utxo, utxo.amount - sideFee);
            shielded++;
            shieldedAmount += utxo.amount - sideFee;
          } catch (err) {
            log.e('could not shield utxo ${utxo.txid}: $err');
          }
          await fetch();
          utxosToMelt.removeWhere((u) => u.utxo.txid == utxo.txid && u.utxo.address == utxo.address);
          notifyListeners();
          remaining--;
          if (remaining == 0 && !_meltsCompleted.isClosed) {
            _meltsCompleted.add(
              CompletedMelt(
                startedAt: startedAt,
                shielded: shielded,
                failed: utxos.length - shielded,
                amount: shieldedAmount,
              ),
            );
          }
        },
      );

      utxosToMelt.add(pending);
      _timers.add(pending.timer);
      meltsWillHappenAt.add(pending.executeIn.inSeconds);
    }

    meltsWillHappenAt.sort((a, b) => a.compareTo(b));
    notifyListeners();
    return meltsWillHappenAt;
  }

  @override
  void dispose() {
    _mainchainRPC.removeListener(fetch);
    _rpc.removeListener(fetch);
    for (final timer in _timers) {
      timer.cancel();
    }
    unawaited(_meltsCompleted.close());
    super.dispose();
  }
}

/// The result of one call of [ZSideProvider.melt].
class CompletedMelt {
  final DateTime startedAt;
  final int shielded;
  final int failed;

  /// The BTC that the shielded UTXOs moved into the shielded pool.
  final double amount;

  const CompletedMelt({required this.startedAt, required this.shielded, required this.failed, required this.amount});
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
