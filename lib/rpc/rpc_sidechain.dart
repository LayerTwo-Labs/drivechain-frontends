import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sidesail/config/sidechains.dart';
import 'package:sidesail/rpc/models/core_transaction.dart';
import 'package:sidesail/rpc/rpc.dart';

/// RPC connection for all sidechain nodes
abstract class SidechainRPC extends RPCConnection {
  SidechainRPC({required super.conf, required this.chain});

  Future<dynamic> callRAW(String method, [List<dynamic>? params]);

  Future<(double, double)> getBalance();
  Future<List<CoreTransaction>> listTransactions();

  Sidechain chain;
}

// Wraps a sidechain, with logic for notifying listeners when the underlying
// RPC connection changes.
class SidechainContainer extends ChangeNotifier {
  SidechainContainer(SidechainRPC rpc) : _rpc = rpc {
    rpc.addListener(notifyListeners);
    rpc.initDone.then(
      (_) => _startConnectionTimer(),
    );
  }

  // responsible for pinging the node every x seconds,
  // so we can update the UI immediately when the values change
  Timer? _connectionTimer;
  void _startConnectionTimer() {
    _connectionTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      await _rpc.testConnection();
    });
  }

  @override
  void dispose() {
    _connectionTimer?.cancel();
    _rpc.removeListener(notifyListeners);
    super.dispose();
  }

  SidechainRPC _rpc;
  SidechainRPC get rpc => _rpc;
  set rpc(SidechainRPC r) {
    // remove the old listener
    _rpc.removeListener(notifyListeners);

    // assign the new var
    _rpc = r;

    // add the new listener
    _rpc.addListener(notifyListeners);

    _connectionTimer?.cancel();
    _startConnectionTimer();

    unawaited(r.testConnection());

    notifyListeners();
  }
}

class RPCError {
  static const errMisc = -3;
  static const errNoWithdrawalBundle = -100;
  static const errWithdrawalNotFound = -101;
}
