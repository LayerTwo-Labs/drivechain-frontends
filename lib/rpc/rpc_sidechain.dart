import 'dart:async';

import 'package:sidesail/config/sidechains.dart';
import 'package:sidesail/pages/tabs/settings/node_settings_tab.dart';
import 'package:sidesail/rpc/models/core_transaction.dart';
import 'package:sidesail/rpc/rpc.dart';

/// RPC connection for all sidechain nodes
abstract class SidechainSubRPC extends RPCConnection {
  Future<dynamic> callRAW(String method, [List<dynamic>? params]);

  Future<(double, double)> getBalance();
  Future<List<CoreTransaction>> listTransactions();

  late Sidechain chain;
}

/// RPC connection for all sidechain nodes
class SidechainRPC extends SidechainSubRPC {
  SidechainSubRPC subRPC;

  SidechainRPC({
    required this.subRPC,
  }) {
    chain = subRPC.chain;
  }

  // values for tracking connection state, and error (if any)
  @override
  SingleNodeConnectionSettings get connectionSettings => subRPC.connectionSettings;
  @override
  bool get connected => subRPC.connected;
  @override
  String? get connectionError => subRPC.connectionError;

  void setSubRPC(SidechainSubRPC newSubRPC) {
    subRPC = newSubRPC;
    chain = subRPC.chain;
    notifyListeners();
  }

  @override
  Future<dynamic> callRAW(String method, [List<dynamic>? params]) async {
    return await subRPC.callRAW(method, params);
  }

  @override
  Future<(double, double)> getBalance() async {
    return subRPC.getBalance();
  }

  @override
  Future<List<CoreTransaction>> listTransactions() {
    return subRPC.listTransactions();
  }

  @override
  Future<void> createClient() async {
    return subRPC.createClient();
  }

  @override
  Future<void> ping() async {
    return subRPC.ping();
  }
}

class RPCError {
  static const errMisc = -3;
  static const errNoWithdrawalBundle = -100;
  static const errWithdrawalNotFound = -101;
}
