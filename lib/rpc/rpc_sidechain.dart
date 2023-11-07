import 'dart:async';

import 'package:sidesail/config/sidechains.dart';
import 'package:sidesail/rpc/models/core_transaction.dart';
import 'package:sidesail/rpc/rpc.dart';

/// RPC connection for all sidechain nodes
abstract class SidechainRPC extends RPCConnection {
  Future<(double, double)> getBalance();

  Future<String> mainSend(
    String address,
    double amount,
    double sidechainFee,
    double mainchainFee,
  );
  Future<String> mainGenerateAddress();
  Future<int> mainBlockCount();

  Future<String> sideSend(
    String address,
    double amount,
    bool subtractFeeFromAmount,
  );
  Future<String> sideGenerateAddress();
  Future<int> sideBlockCount();
  Future<double> sideEstimateFee();

  // TODO: Don't do a CoreTransaction here
  Future<List<CoreTransaction>> listTransactions();

  Future<dynamic> callRAW(String method, [dynamic params]);

  late Sidechain chain;
  void setChain(Sidechain newChain) {
    chain = newChain;
    notifyListeners();
  }
}

class RPCError {
  static const errMisc = -3;
  static const errNoWithdrawalBundle = -100;
  static const errWithdrawalNotFound = -101;
}
