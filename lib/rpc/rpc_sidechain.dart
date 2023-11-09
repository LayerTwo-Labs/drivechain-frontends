import 'dart:async';

import 'package:sidesail/config/dependencies.dart';
import 'package:sidesail/config/sidechains.dart';
import 'package:sidesail/rpc/models/core_transaction.dart';
import 'package:sidesail/rpc/rpc.dart';

/// RPC connection for all sidechain nodes
abstract class SidechainRPC extends RPCConnection {
  Future<dynamic> callRAW(String method, [List<dynamic>? params]);

  Future<(double, double)> getBalance();
  Future<List<CoreTransaction>> listTransactions();

  late Sidechain chain;
  void setChain(Sidechain newChain) {
    chain = newChain;
    setSidechainRPC(newChain);
    notifyListeners();
  }
}

class RPCError {
  static const errMisc = -3;
  static const errNoWithdrawalBundle = -100;
  static const errWithdrawalNotFound = -101;
}
