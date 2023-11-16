import 'package:dart_coin_rpc/dart_coin_rpc.dart';
import 'package:dio/dio.dart';
import 'package:sidesail/config/sidechains.dart';
import 'package:sidesail/pages/tabs/settings/node_settings_tab.dart';
import 'package:sidesail/rpc/models/core_transaction.dart';
import 'package:sidesail/rpc/models/zcash_utxos.dart';
import 'package:sidesail/rpc/rpc_config.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';

abstract class ZCashRPC extends SidechainRPC {
  ZCashRPC({
    required super.conf,
  }) : super(chain: ZCashSidechain());

  String? address = 'regtestsapling13gh808131h6x3fd9legOargk0q03ugkkjrhptermv7gnz62kc7u20cp5rtxmize219crk5veq6q';

  Future<List<OperationStatus>> listOperations();
  Future<List<ShieldedUTXO>> listShieldedCoins();
  Future<List<UnshieldedUTXO>> listUnshieldedCoins();

  Future<String> shield(UnshieldedUTXO utxo, double amount);
  Future<String> deshield(ShieldedUTXO utxo, double amount);
  Future<String> melt(List<UnshieldedUTXO> utxos);
}

class ZCashRPCLive extends ZCashRPC {
  RPCClient _client() {
    final client = RPCClient(
      host: conf.host,
      port: conf.port,
      username: conf.username,
      password: conf.password,
      useSSL: false,
    );

    // no retry logic!
    client.dioClient = Dio();
    return client;
  }

  ZCashRPCLive({required super.conf});

  @override
  Future<dynamic> callRAW(String method, [params]) async {
    return;
  }

  @override
  Future<void> ping() async {
    return;
  }

  @override
  Future<(double, double)> getBalance() async {
    return (123.0, 0.0);
  }

  @override
  Future<List<CoreTransaction>> listTransactions() async {
    return List.empty();
  }

  @override
  Future<List<OperationStatus>> listOperations() async {
    return [
      OperationStatus(
        id: 'opid-7c484106 409a-47dc-b853-3c641beaf166',
        confirmations: 0,
        time: DateTime.now(),
        raw: '''  {
    "account": "",
    "address": "3CUZ683astRsmACdRKyx7eFb1y9yvMRzGi",
    "category": "send",
    "amount": -1.00000000,
    "label": "Sidechain Deposit",
    "vout": 0,
    "fee": -0.00002250,
    "confirmations": 0,
    "txid": "c80870f301d288294cdf79ecc9d9dd8a96f57bf4725210475eb662ec82b96acd",
    "time": 1699362312,
    "timereceived": 1699362312
  }''',
      ),
      OperationStatus(
        id: 'opid-7c484106 409a-47dc-b853-3c641beaf166',
        confirmations: 1,
        time: DateTime.now(),
        raw: '''  {
    "account": "",
    "address": "3CUZ683astRsmACdRKyx7eFb1y9yvMRzGi",
    "category": "send",
    "amount": -1.00000000,
    "label": "Sidechain Deposit",
    "vout": 0,
    "fee": -0.00002250,
    "confirmations": 0,
    "txid": "c80870f301d288294cdf79ecc9d9dd8a96f57bf4725210475eb662ec82b96acd",
    "time": 1699362312,
    "timereceived": 1699362312
  }''',
      ),
      OperationStatus(
        id: 'opid-7c484106 409a-47dc-b853-3c641beaf166',
        confirmations: 29,
        time: DateTime.now(),
        raw: '''  {
    "account": "",
    "address": "3CUZ683astRsmACdRKyx7eFb1y9yvMRzGi",
    "category": "send",
    "amount": -1.00000000,
    "label": "Sidechain Deposit",
    "vout": 0,
    "fee": -0.00002250,
    "confirmations": 0,
    "txid": "c80870f301d288294cdf79ecc9d9dd8a96f57bf4725210475eb662ec82b96acd",
    "time": 1699362312,
    "timereceived": 1699362312
  }''',
      ),
    ];
  }

  @override
  Future<List<UnshieldedUTXO>> listUnshieldedCoins() async {
    return [
      UnshieldedUTXO(
        address: 'tmBd8jBt7FGDjN8KL9Wh4s925R6EopAGacu',
        amount: 859.0,
        confirmations: 0,
        time: DateTime.now(),
        raw: '''  {
    "account": "",
    "address": "3CUZ683astRsmACdRKyx7eFb1y9yvMRzGi",
    "category": "send",
    "amount": -859.00000000,
    "label": "Sidechain Deposit",
    "vout": 0,
    "fee": -0.00010000,
    "confirmations": 0,
    "txid": "c80870f301d288294cdf79ecc9d9dd8a96f57bf4725210475eb662ec82b96acd",
    "time": 1699362312,
    "timereceived": 1699362312
  }''',
      ),
      UnshieldedUTXO(
        address: 'tmBd8jBt7FGDjN8KL9Wh4s925R6EopAGacu',
        amount: 859.0,
        confirmations: 0,
        time: DateTime.now(),
        raw: '''  {
    "account": "",
    "address": "3CUZ683astRsmACdRKyx7eFb1y9yvMRzGi",
    "category": "send",
    "amount": -859.00000000,
    "label": "Sidechain Deposit",
    "vout": 0,
    "fee": -0.00010000,
    "confirmations": 0,
    "txid": "c80870f301d288294cdf79ecc9d9dd8a96f57bf4725210475eb662ec82b96acd",
    "time": 1699362312,
    "timereceived": 1699362312
  }''',
      ),
      UnshieldedUTXO(
        address: 'tmBd8jBt7FGDjN8KL9Wh4s925R6EopAGacu',
        amount: 0.00010000,
        confirmations: 0,
        time: DateTime.now(),
        raw: '''  {
    "account": "",
    "address": "3CUZ683astRsmACdRKyx7eFb1y9yvMRzGi",
    "category": "send",
    "amount": 0.0001000,
    "label": "Sidechain Deposit",
    "vout": 0,
    "fee": -0.00000000,
    "confirmations": 0,
    "txid": "c80870f301d288294cdf79ecc9d9dd8a96f57bf4725210475eb662ec82b96acd",
    "time": 1699362312,
    "timereceived": 1699362312
  }''',
      ),
      UnshieldedUTXO(
        address: 'tmBd8jBt7FGDjN8KL9Wh4s925R6EopAGacu',
        amount: 859.0,
        confirmations: 0,
        time: DateTime.now(),
        raw: '''  {
    "account": "",
    "address": "3CUZ683astRsmACdRKyx7eFb1y9yvMRzGi",
    "category": "send",
    "amount": -859.00000000,
    "label": "Sidechain Deposit",
    "vout": 0,
    "fee": -0.00001000,
    "confirmations": 0,
    "txid": "c80870f301d288294cdf79ecc9d9dd8a96f57bf4725210475eb662ec82b96acd",
    "time": 1699362312,
    "timereceived": 1699362312
  }''',
      ),
    ];
  }

  @override
  Future<List<ShieldedUTXO>> listShieldedCoins() async {
    return [
      ShieldedUTXO(
        address: 'regtestsapling13gh808131h6x3fd9legOargk0q03ugkkjrhptermv7gnz62kc7u20cp5rtxmize219crk5veq6q',
        amount: 859.0,
        confirmations: 0,
        time: DateTime.now(),
        raw: '''  {
    "account": "",
    "address": "3CUZ683astRsmACdRKyx7eFb1y9yvMRzGi",
    "category": "send",
    "amount": -859.00000000,
    "label": "Sidechain Deposit",
    "vout": 0,
    "fee": -0.00001000,
    "confirmations": 0,
    "txid": "c80870f301d288294cdf79ecc9d9dd8a96f57bf4725210475eb662ec82b96acd",
    "time": 1699362312,
    "timereceived": 1699362312
  }''',
      ),
      ShieldedUTXO(
        address: 'regtestsapling13gh808131h6x3fd9legOargk0q03ugkkjrhptermv7gnz62kc7u20cp5rtxmize219crk5veq6q',
        amount: 859.0,
        confirmations: 0,
        time: DateTime.now(),
        raw: '''  {
    "account": "",
    "address": "3CUZ683astRsmACdRKyx7eFb1y9yvMRzGi",
    "category": "send",
    "amount": -859.00000000,
    "label": "Sidechain Deposit",
    "vout": 0,
    "fee": -0.00001000,
    "confirmations": 0,
    "txid": "c80870f301d288294cdf79ecc9d9dd8a96f57bf4725210475eb662ec82b96acd",
    "time": 1699362312,
    "timereceived": 1699362312
  }''',
      ),
      ShieldedUTXO(
        address: 'regtestsapling13gh808131h6x3fd9legOargk0q03ugkkjrhptermv7gnz62kc7u20cp5rtxmize219crk5veq6q',
        amount: 0.0001000,
        confirmations: 0,
        time: DateTime.now(),
        raw: '''  {
    "account": "",
    "address": "3CUZ683astRsmACdRKyx7eFb1y9yvMRzGi",
    "category": "send",
    "amount": -859.00000000,
    "label": "Sidechain Deposit",
    "vout": 0,
    "fee": -0.00001000,
    "confirmations": 0,
    "txid": "c80870f301d288294cdf79ecc9d9dd8a96f57bf4725210475eb662ec82b96acd",
    "time": 1699362312,
    "timereceived": 1699362312
  }''',
      ),
      ShieldedUTXO(
        address: 'regtestsapling13gh808131h6x3fd9legOargk0q03ugkkjrhptermv7gnz62kc7u20cp5rtxmize219crk5veq6q',
        amount: 859.0,
        confirmations: 0,
        time: DateTime.now(),
        raw: '''  {
    "account": "",
    "address": "3CUZ683astRsmACdRKyx7eFb1y9yvMRzGi",
    "category": "send",
    "amount": -859.00000000,
    "label": "Sidechain Deposit",
    "vout": 0,
    "fee": -0.00001000,
    "confirmations": 0,
    "txid": "c80870f301d288294cdf79ecc9d9dd8a96f57bf4725210475eb662ec82b96acd",
    "time": 1699362312,
    "timereceived": 1699362312
  }''',
      ),
    ];
  }

  @override
  Future<String> deshield(ShieldedUTXO utxo, double amount) async {
    return 'opid-7c484106 409a-47dc-b853-3c641beaf166';
  }

  @override
  Future<String> shield(UnshieldedUTXO utxo, double amount) async {
    return 'opid-7c484106 409a-47dc-b853-3c641beaf166';
  }

  @override
  List<String> binaryArgs(SingleNodeConnectionSettings mainchainConf) {
    final baseArgs = bitcoinCoreBinaryArgs(
      conf,
    );
    final sidechainArgs = [
      '-mainchainrpcport=${mainchainConf.port}',
      '-mainchainrpchost=${mainchainConf.host}',
      '-mainchainrpcuser=${mainchainConf.username}',
      '-mainchainrpcpassword=${mainchainConf.password}',
    ];
    return [...baseArgs, ...sidechainArgs];
  }

  @override
  Future<String> melt(List<UnshieldedUTXO> utxos) async {
    return 'opid-7c484106 409a-47dc-b853-3c641beaf166';
  }
}

/// List of all known RPC methods available /
final zcashRPCMethods = [];
