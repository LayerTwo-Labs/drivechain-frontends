import 'package:sidesail/bitcoin.dart';
import 'package:sidesail/rpc/models/core_transaction.dart';
import 'package:sidesail/rpc/models/zcash_utxos.dart';
import 'package:sidesail/rpc/rpc_zcash.dart';

class MockZCashRPC extends ZCashRPC {
  MockZCashRPC({required super.conf});

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
    "confirmations": 1,
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
    "confirmations": 29,
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
        txid: 'db5566c1d4072b1652156faa8461f6cae68d8cc4b3249589c70efb1175b17502',
        address: 'tmBd8jBt7FGDjN8KL9Wh4s925R6EopAGacu',
        amount: 859.0,
        confirmations: 1,
        raw: '''  {
    "account": "",
    "address": "3CUZ683astRsmACdRKyx7eFb1y9yvMRzGi",
    "category": "send",
    "amount": -859.00000000,
    "label": "Sidechain Deposit",
    "vout": 0,
    "fee": -0.00010000,
    "confirmations": 1,
    "txid": "c80870f301d288294cdf79ecc9d9dd8a96f57bf4725210475eb662ec82b96acd",
    "time": 1699362312,
    "timereceived": 1699362312
  }''',
      ),
      UnshieldedUTXO(
        txid: 'db5566c1d4072b1652156faa8461f6cae68d8cc4b3249589c70efb1175b17502',
        address: 'tmBd8jBt7FGDjN8KL9Wh4s925R6EopAGacu',
        amount: 859.0,
        confirmations: 5,
        raw: '''  {
    "account": "",
    "address": "3CUZ683astRsmACdRKyx7eFb1y9yvMRzGi",
    "category": "send",
    "amount": -859.00000000,
    "label": "Sidechain Deposit",
    "vout": 0,
    "fee": -0.00010000,
    "confirmations": 5,
    "txid": "c80870f301d288294cdf79ecc9d9dd8a96f57bf4725210475eb662ec82b96acd",
    "time": 1699362312,
    "timereceived": 1699362312
  }''',
      ),
      UnshieldedUTXO(
        txid: 'db5566c1d4072b1652156faa8461f6cae68d8cc4b3249589c70efb1175b17502',
        address: 'tmBd8jBt7FGDjN8KL9Wh4s925R6EopAGacu',
        amount: 0.00010000,
        confirmations: 10,
        raw: '''  {
    "account": "",
    "address": "3CUZ683astRsmACdRKyx7eFb1y9yvMRzGi",
    "category": "send",
    "amount": 0.0001000,
    "label": "Sidechain Deposit",
    "vout": 0,
    "fee": -0.00000000,
    "confirmations": 10,
    "txid": "c80870f301d288294cdf79ecc9d9dd8a96f57bf4725210475eb662ec82b96acd",
    "time": 1699362312,
    "timereceived": 1699362312
  }''',
      ),
      UnshieldedUTXO(
        txid: 'db5566c1d4072b1652156faa8461f6cae68d8cc4b3249589c70efb1175b17502',
        address: 'tmBd8jBt7FGDjN8KL9Wh4s925R6EopAGacu',
        amount: 859.0,
        confirmations: 35,
        raw: '''  {
    "account": "",
    "address": "3CUZ683astRsmACdRKyx7eFb1y9yvMRzGi",
    "category": "send",
    "amount": -859.00000000,
    "label": "Sidechain Deposit",
    "vout": 0,
    "fee": -0.00001000,
    "confirmations": 35,
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
        txid: 'adebce6c27ed4be5641a9a0d0f1656c9626093d3cc00f5461bf3ca74e26db3c0',
        pool: 'sapling',
        type: 'sapling',
        outindex: 0,
        confirmations: 9,
        spendable: true,
        address: 'zregtestsapling1jycyv0plj8g2pf660hwawlvc8s8deqwxnqlrrwcuycyc2fsuevkw2zznka02kq446grtw4jk7xg',
        amount: 299.99999000,
        amountZat: 29999999000,
        memo: 'f600...',
        change: false,
        raw:
            '{"txid": "adebce6c27ed4be5641a9a0d0f1656c9626093d3cc00f5461bf3ca74e26db3c0", "pool": "sapling", "type": "sapling", "outindex": 0, "confirmations": 9, "spendable": true, "address": "zregtestsapling1jycyv0plj8g2pf660hwawlvc8s8deqwxnqlrrwcuycyc2fsuevkw2zznka02kq446grtw4jk7xg", "amount": 299.99999000, "amountZat": 29999999000, "memo": "f600...", "change": false}',
      ),
      ShieldedUTXO(
        txid: 'c80870f301d288294cdf79ecc9d9dd8a96f57bf4725210475eb662ec82b96acd',
        pool: 'sapling',
        type: 'sapling',
        outindex: 0,
        confirmations: 54,
        spendable: false,
        address: 'zregtestsapling1jycyv0plj8g2pf660hwawlvc8s8deqwxnqlrrwcuycyc2fsuevkw2zznka02kq446grtw4jk7xg',
        amount: 859.0,
        amountZat: 85900000000,
        memo: '',
        change: false,
        raw:
            '{"txid": "c80870f301d288294cdf79ecc9d9dd8a96f57bf4725210475eb662ec82b96acd", "confirmations": 54, "address": "zregtestsapling1jycyv0plj8g2pf660hwawlvc8s8deqwxnqlrrwcuycyc2fsuevkw2zznka02kq446grtw4jk7xg", "amount": 859.0, "vout": 0}',
      ),
      ShieldedUTXO(
        txid: 'c80870f301d288294cdf79ecc9d9dd8a96f57bf4725210475eb662ec82b96acd',
        pool: 'sapling',
        type: 'sapling',
        outindex: 0,
        confirmations: 98,
        spendable: false,
        address: 'zregtestsapling1jycyv0plj8g2pf660hwawlvc8s8deqwxnqlrrwcuycyc2fsuevkw2zznka02kq446grtw4jk7xg',
        amount: 0.0001000,
        amountZat: 10000,
        memo: '',
        change: false,
        raw:
            '{"txid": "c80870f301d288294cdf79ecc9d9dd8a96f57bf4725210475eb662ec82b96acd", "confirmations": 98, "address": "zregtestsapling1jycyv0plj8g2pf660hwawlvc8s8deqwxnqlrrwcuycyc2fsuevkw2zznka02kq446grtw4jk7xg", "amount": 0.0001000, "vout": 0}',
      ),
      ShieldedUTXO(
        txid: 'c80870f301d288294cdf79ecc9d9dd8a96f57bf4725210475eb662ec82b96acd',
        pool: 'sapling',
        type: 'sapling',
        outindex: 0,
        confirmations: 99,
        spendable: false,
        address: 'zregtestsapling1jycyv0plj8g2pf660hwawlvc8s8deqwxnqlrrwcuycyc2fsuevkw2zznka02kq446grtw4jk7xg',
        amount: 859.0,
        amountZat: 85900000000,
        memo: '',
        change: false,
        raw:
            '{"txid": "c80870f301d288294cdf79ecc9d9dd8a96f57bf4725210475eb662ec82b96acd", "confirmations": 99, "address": "zregtestsapling1jycyv0plj8g2pf660hwawlvc8s8deqwxnqlrrwcuycyc2fsuevkw2zznka02kq446grtw4jk7xg", "amount": 859.0, "vout": 0}',
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
  Future<String> melt(List<UnshieldedUTXO> utxos) async {
    return 'opid-7c484106 409a-47dc-b853-3c641beaf166';
  }

  @override
  Future<String> mainGenerateAddress() async {
    return formatDepositAddress('3CUZ683astRsmACdRKyx7eFb1y9yvMRzGi', chain.slot);
  }

  @override
  Future<String> mainSend(String address, double amount, double sidechainFee, double mainchainFee) async {
    return 'some-sidechain-txid';
  }

  @override
  Future<double> sideEstimateFee() async {
    return 0.0001;
  }

  @override
  Future<int> account() async {
    return 0;
  }

  @override
  Future<String> sideGenerateAddress() async {
    return 'regtestsapling13gh808131h6x3fd9legOargk0q03ugkkjrhptermv7gnz62kc7u20cp5rtxmize219crk5veq6q';
  }

  @override
  Future<int> sideBlockCount() async {
    return 100;
  }

  @override
  Future<String> sideSend(String address, double amount, bool subtractFeeFromAmount) async {
    return 'txiddeadbeef';
  }
}
