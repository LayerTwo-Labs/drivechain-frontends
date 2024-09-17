import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidesail/config/chains.dart';
import 'package:sidesail/pages/tabs/settings/settings_tab.dart';
import 'package:sidesail/rpc/rpc.dart';

/// RPC connection for all sidechain nodes
abstract class SidechainRPC extends RPCConnection {
  SidechainRPC({
    required super.conf,
    required this.chain,
  });

  /// Args to pass to the binary on startup.
  List<String> binaryArgs(
    SingleNodeConnectionSettings mainchainConf,
  );

  Future<dynamic> callRAW(String method, [List<dynamic>? params]);

  /// Returns confirmed and unconfirmed balance.
  Future<(double, double)> getBalance();
  Future<List<CoreTransaction>> listTransactions();

  Future<String> mainSend(
    String address,
    double amount,
    double sidechainFee,
    double mainchainFee,
  );
  Future<String> getDepositAddress();

  Future<String> sideSend(
    String address,
    double amount,
    bool subtractFeeFromAmount,
  );
  Future<String> getSideAddress();
  Future<double> sideEstimateFee();

  Sidechain chain;
}

// Wraps a sidechain, with logic for notifying listeners when the underlying
// RPC connection changes.
// tests the connection on launch, and correctly set connection params
// based on the result
class SidechainContainer extends ChangeNotifier {
  SidechainRPC _rpc;

  // hacky way to create an async class
  // https://stackoverflow.com/a/59304510
  SidechainContainer._create(this._rpc);
  static Future<SidechainContainer> create(SidechainRPC initRPC) async {
    final container = SidechainContainer._create(initRPC);
    await container.init();
    return container;
  }

  Future<void> init() async {
    await _rpc.testConnection();

    // assigning here calls the set-method, adding listeners
    rpc = _rpc;
  }

  SidechainRPC get rpc => _rpc;
  set rpc(SidechainRPC r) {
    // remove the old listener
    _rpc.removeListener(notifyListeners);

    // assign the new var
    _rpc = r;

    // add the new listener
    _rpc.addListener(notifyListeners);

    notifyListeners();
  }

  @override
  void dispose() {
    _rpc.removeListener(notifyListeners);
    super.dispose();
  }
}

class RPCError {
  static const errMisc = -3;
  static const errNoWithdrawalBundle = -100;
  static const errWithdrawalNotFound = -101;
}
