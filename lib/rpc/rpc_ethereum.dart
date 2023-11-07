import 'dart:async';

import 'package:sidesail/config/sidechains.dart';
import 'package:sidesail/rpc/models/core_transaction.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';

/// RPC connection the sidechain node.
abstract class EthereumRPC extends SidechainRPC {}

class EthereumRPCLive extends EthereumRPC {
  // hacky way to create an async class
  // https://stackoverflow.com/a/59304510
  EthereumRPCLive._create() {
    chain = EthereumSidechain();
  }

  static Future<EthereumRPCLive> create() async {
    final rpc = EthereumRPCLive._create();
    await rpc._init();
    return rpc;
  }

  Future<void> _init() async {
    // TODO: Create connection, get inspo from rpc_testchain.dart
  }

  @override
  Future callRAW(String method, [params]) {
    // TODO: implement callRAW
    throw UnimplementedError();
  }

  @override
  Future<void> createClient() {
    // TODO: implement createClient
    throw UnimplementedError();
  }

  @override
  Future<(double, double)> getBalance() {
    // TODO: implement getBalance
    throw UnimplementedError();
  }

  @override
  Future<int> mainBlockCount() {
    // TODO: implement mainBlockCount
    throw UnimplementedError();
  }

  @override
  Future<String> mainGenerateAddress() {
    // TODO: implement mainGenerateAddress
    throw UnimplementedError();
  }

  @override
  Future<String> mainSend(String address, double amount, double sidechainFee, double mainchainFee) {
    // TODO: implement mainSend
    throw UnimplementedError();
  }

  @override
  Future<void> ping() {
    // TODO: implement ping
    throw UnimplementedError();
  }

  @override
  Future<int> sideBlockCount() {
    // TODO: implement sideBlockCount
    throw UnimplementedError();
  }

  @override
  Future<String> sideGenerateAddress() {
    // TODO: implement sideGenerateAddress
    throw UnimplementedError();
  }

  @override
  Future<String> sideSend(String address, double amount, bool subtractFeeFromAmount) {
    // TODO: implement sideSend
    throw UnimplementedError();
  }

  @override
  Future<double> sideEstimateFee() {
    // TODO: implement sideEstimateFee
    throw UnimplementedError();
  }

  @override
  Future<List<CoreTransaction>> listTransactions() {
    // TODO: implement listTransactions
    throw UnimplementedError();
  }
}
