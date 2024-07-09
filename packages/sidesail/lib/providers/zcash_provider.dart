import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidesail/providers/notification_provider.dart';
import 'package:sidesail/rpc/models/zcash_utxos.dart';
import 'package:sidesail/rpc/rpc_mainchain.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
import 'package:sidesail/rpc/rpc_zcash.dart';

class ZCashProvider extends ChangeNotifier {
  ZCashRPC get rpc => GetIt.I.get<ZCashRPC>();
  Logger get log => GetIt.I.get<Logger>();

  MainchainRPC get _mainchainRPC => GetIt.I.get<MainchainRPC>();
  SidechainContainer get _sidechain => GetIt.I.get<SidechainContainer>();
  NotificationProvider get _notificationProvider => GetIt.I.get<NotificationProvider>();

  String zcashAddress = '';
  List<OperationStatus> operations = [];
  List<ShieldedUTXO> shieldedUTXOs = [];
  List<UnshieldedUTXO> unshieldedUTXOs = [];
  List<CoreTransaction> transparentTransactions = [];
  List<ShieldedUTXO> privateTransactions = [];

  double sideFee = zcashFee;

  bool _isFetching = false;

  ZCashProvider() {
    // fetch on launch
    fetch();

    // then refetch every time the block count is updated
    _mainchainRPC.addListener(fetch);
    _sidechain.rpc.addListener(fetch);
  }

  Future<void> fetch() async {
    try {
      if (_isFetching) {
        return;
      }
      _isFetching = true;

      var newZcashAddress = await rpc.generateZAddress();
      var newOperations = await rpc.listOperations();
      var newShieldedUTXOs = (await rpc.listShieldedCoins()).reversed.toList();
      var newUnshieldedUTXOs = (await rpc.listUnshieldedCoins()).reversed.toList();
      var newTransparentTXs = (await rpc.listTransactions()).reversed.toList();
      var newPrivateTXs = (await rpc.listPrivateTransactions()).reversed.toList();
      var newSideFee = await rpc.sideEstimateFee();

      if (_dataHasChanged(
        newZcashAddress,
        newOperations,
        newShieldedUTXOs,
        newUnshieldedUTXOs,
        newTransparentTXs,
        newPrivateTXs,
        newSideFee,
      )) {
        zcashAddress = newZcashAddress;
        operations.addAll(newOperations);
        for (final newOp in newOperations) {
          _notifyNewOperation(newOp);
        }
        shieldedUTXOs = newShieldedUTXOs;
        unshieldedUTXOs = newUnshieldedUTXOs;
        transparentTransactions = newTransparentTXs;
        privateTransactions = newPrivateTXs;
        sideFee = newSideFee;
        notifyListeners();
      }
    } catch (error) {
      // Swallow the error, makes for noisy logs
    } finally {
      _isFetching = false;
    }
  }

  bool _dataHasChanged(
    String newZcashAddress,
    List<OperationStatus> newOperations,
    List<ShieldedUTXO> newShieldedUTXOs,
    List<UnshieldedUTXO> newUnshieldedUTXOs,
    List<CoreTransaction> newTransparentTXs,
    List<ShieldedUTXO> newPrivateTXs,
    double newSideFee,
  ) {
    if (newZcashAddress != zcashAddress) {
      return true;
    }

    if (newOperations.isNotEmpty) {
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

  void _notifyNewOperation(OperationStatus operation) {
    _notificationProvider.add(
      title: '${operation.method} ${operation.status == 'success' ? 'succeeded' : 'failed'}',
      content: operation.id,
      dialogType: operation.status == 'success' ? DialogType.success : DialogType.error,
    );
  }

  // From here on out, MELT CODE BBY
  List<PendingShield> utxosToMelt = [];
  // One timer is added to this list per UTXO the user wants to melt
  // Each timer is given a random duration between 0 and the max minutes
  // the user wants all utxos shielded by
  final List<Timer> _timers = [];

  Future<List<int>> melt(List<UnshieldedUTXO> utxos, double completedInMinutes) async {
    final List<int> meltsWillHappenAt = [];

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
      meltsWillHappenAt.add(pending.executeIn.inSeconds);
    }

    meltsWillHappenAt.sort((a, b) => a.compareTo(b));
    notifyListeners();
    return meltsWillHappenAt;
  }

  @override
  void dispose() {
    super.dispose();
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
