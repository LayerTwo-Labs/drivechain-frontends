import 'dart:io';

import 'package:dart_coin_rpc/dart_coin_rpc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sidesail/bitcoin.dart';
import 'package:sidesail/config/runtime_args.dart';
import 'package:sidesail/config/sidechains.dart';
import 'package:sidesail/pages/tabs/settings/node_settings_tab.dart';
import 'package:sidesail/providers/proc_provider.dart';
import 'package:sidesail/rpc/models/core_transaction.dart';
import 'package:sidesail/rpc/models/zcash_utxos.dart';
import 'package:sidesail/rpc/rpc_config.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';

abstract class ZCashRPC extends SidechainRPC {
  @override
  Future<List<String>> binaryArgs(SingleNodeConnectionSettings mainchainConf) async {
    final baseArgs = bitcoinCoreBinaryArgs(
      conf,
    );
    final paramsDir = filePath([
      (await RuntimeArgs.datadir()).path,
      'zcash-params',
    ]);
    final sidechainArgs = [
      '-paramsdir=$paramsDir',
      '-mainchainrpcport=${mainchainConf.port}',
      '-mainchainrpchost=${mainchainConf.host}',
      '-mainchainrpcuser=${mainchainConf.username}',
      '-mainchainrpcpassword=${mainchainConf.password}',
    ];
    return [...baseArgs, ...sidechainArgs];
  }

  // Make sure the ZCash params are present when starting the binary.
  @override
  Future<void> preInitBinary(BuildContext context) async {
    // TODO: we're doing a crude tranfer of files here. In a better
    // setup we should be checking the hash sums of the files, to
    // ensure integrity.
    final files = ['sapling-output.params', 'sapling-spend.params', 'sprout-groth16.params'];

    final datadir = await RuntimeArgs.datadir();
    final zcashParamsDir = filePath([datadir.path, 'zcash-params']);

    await Directory(zcashParamsDir).create(recursive: true);

    log.i('transferring zcash parameter files $files to parameter datadir $zcashParamsDir');

    if (!context.mounted) {
      return;
    }

    for (final file in files) {
      await readAssetToFile(
        context,
        filePath([zcashParamsDir, file]),
        'assets/zcash-params/$file',
      );
    }

    log.d('transferred all zcash parameter files');
  }

  ZCashRPC({
    required super.conf,
  }) : super(chain: ZCashSidechain());

  /// There's no account in the wallet out of the box. Calling this
  /// either creates a new one, or returns an already existing one
  /// if we created one earlier.
  Future<int> account();

  Future<List<OperationStatus>> listOperations();
  Future<List<ShieldedUTXO>> listShieldedCoins();
  Future<List<UnshieldedUTXO>> listUnshieldedCoins();

  Future<String> shield(UnshieldedUTXO utxo, double amount);
  Future<String> deshield(ShieldedUTXO utxo, double amount);
  Future<String> melt(List<UnshieldedUTXO> utxos);
}

class ZcashRPCLive extends ZCashRPC {
  ZcashRPCLive({required super.conf});

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

  @override
  Future<dynamic> callRAW(String method, [params]) async {
    return await _client().call(method, params);
  }

  @override
  Future<void> ping() async {
    await _client().call('ping');
  }

  Future<double> _balanceForAccount(int account, int confirmations) async {
    return await _client.call().call('z_getbalanceforaccount', [account, confirmations]).then(
      (res) {
        final pools = res.pools;
        return pools.transparent.valueZat + pools.sapling.valueZat + pools.orchard.valueZat;
      },
    );
  }

  @override
  Future<(double, double)> getBalance() async {
    final acc = await account();

    final confirmed = await _balanceForAccount(acc, 1);
    final confirmedAndUnconfirmed = await _balanceForAccount(acc, 0);

    return (confirmed, confirmedAndUnconfirmed - confirmed);
  }

  @override
  Future<int> account() async {
    final existing = await _client().call('z_listaccounts') as List<dynamic>;

    if (existing.isNotEmpty) {
      return existing.first['account'];
    }

    final newAccount = await _client().call('z_getnewaccount');

    return newAccount['account'];
  }

  @override
  Future<String> deshield(ShieldedUTXO utxo, double amount) {
    // TODO: implement deshield
    throw UnimplementedError();
  }

  @override
  Future<List<OperationStatus>> listOperations() async {
    // Can also pass specific IDs here. When not passing any, all
    // known results are returned.
    final operationResults = await _client().call('z_getoperationresult') as List<dynamic>;
    // then convert to something other than pure json
    if (operationResults.isEmpty) {
      return List.empty();
    }
    List<OperationStatus> operations = operationResults
        .map(
          (jsonItem) => OperationStatus.fromMap(jsonItem),
        )
        .toList();
    return operations;
  }

  @override
  Future<List<ShieldedUTXO>> listShieldedCoins() async {
    final shieldedCoins = await _client().call('z_listunspent') as List<dynamic>;
    if (shieldedCoins.isEmpty) {
      return List.empty();
    }

    List<ShieldedUTXO> utxos = shieldedCoins
        .map(
          (jsonItem) => ShieldedUTXO.fromMap(jsonItem),
        )
        .toList();

    return utxos;
  }

  @override
  Future<List<CoreTransaction>> listTransactions() async {
    final transactionsJSON = await _client().call('listtransactions', [
      '',
      9999, // how many txs to list. We have not implemented pagination, so we list all
    ]).catchError(
      (err) => List.empty(), // might be connection issues, don't error
    ) as List<dynamic>;

    // then convert to something other than json
    List<CoreTransaction> transactions = transactionsJSON.map((jsonItem) => CoreTransaction.fromMap(jsonItem)).toList();
    transactions.removeWhere((t) => t.amount == 0);
    return transactions;
  }

  @override
  Future<List<UnshieldedUTXO>> listUnshieldedCoins() async {
    // TODO: verify this just returns unshielded coins. might have to
    // diff z_listunspent and listunspent?
    final unspent = await _client().call('listunspent');
    if (unspent.isEmpty) {
      return List.empty();
    }

    List<UnshieldedUTXO> unspentUTXOs = unspent
        .map(
          (jsonItem) => UnshieldedUTXO.fromMap(jsonItem),
        )
        .toList();

    return unspentUTXOs;
  }

  @override
  Future<String> mainGenerateAddress() async {
    final address = await _client().call('getnewaddress');
    return formatDepositAddress(address, chain.slot);
  }

  @override
  Future<String> mainSend(String address, double amount, double sidechainFee, double mainchainFee) async {
    return await _client().call('withdraw', [address, amount, false]);
  }

  @override
  Future<String> melt(List<UnshieldedUTXO> utxos) async {
    // TODO: implement melt
    throw UnimplementedError();
  }

  @override
  Future<String> shield(UnshieldedUTXO utxo, double amount) async {
    // TODO: implement shield
    throw UnimplementedError();
  }

  @override
  Future<double> sideEstimateFee() async {
    return 0.0001;
  }

  Future<String> _getNewAddress() async {
    return await _client().call('z_getnewaddress');
  }

  @override
  Future<String> sideGenerateAddress() async {
    final addresses = await _client().call('z_listaddresses') as List<dynamic>;
    if (addresses.isEmpty) {
      return _getNewAddress();
    }

    return addresses.first as String;
  }

  @override
  Future<int> sideBlockCount() async {
    return await _client().call('getblockcount');
  }

  @override
  Future<String> sideSend(String address, double amount, bool subtractFeeFromAmount) async {
    final withdrawalTxid = await _client().call('sendtoaddress', [
      address,
      amount,
      '',
      '',
      subtractFeeFromAmount,
    ]);

    return withdrawalTxid;
  }
}

/// List of all known RPC methods available /
final zcashRPCMethods = [
  // address index methods
  'getaddressbalance',
  'getaddressdeltas',
  'getaddressmempool',
  'getaddresstxids',
  'getaddressutxos',

// blockchain methods
  'getbestblockhash',
  'getblock',
  'getblockchaininfo',
  'getblockcount',
  'getblockdeltas',
  'getblockhash',
  'getblockhashes',
  'getblockheader',
  'getchaintips',
  'getdifficulty',
  'getmempoolinfo',
  'getrawmempool',
  'getspentinfo',
  'gettxout',
  'gettxoutproof',
  'gettxoutsetinfo',
  'verifychain',
  'verifytxoutproof',
  'z_gettreestate',

// control methods
  'getexperimentalfeatures',
  'getinfo',
  'getmemoryinfo',
  'help',
  'setlogfilter',
  'stop',

// disclosure methods
  'z_getpaymentdisclosure',
  'z_validatepaymentdisclosure',

// generating methods
  'generate',
  'getgenerate',
  'setgenerate',

// mining methods
  'getblocksubsidy',
  'getblocktemplate',
  'getlocalsolps',
  'getmininginfo',
  'getnetworkhashps',
  'getnetworksolps',
  'prioritisetransaction',
  'refreshbmm',
  'submitblock',

// network methods
  'addnode',
  'clearbanned',
  'disconnectnode',
  'getaddednodeinfo',
  'getconnectioncount',
  'getdeprecationinfo',
  'getnettotals',
  'getnetworkinfo',
  'getpeerinfo',
  'listbanned',
  'ping',
  'setban',

// raw TXs
  'createrawtransaction',
  'decoderawtransaction',
  'decodescript',
  'fundrawtransaction',
  'getrawtransaction',
  'sendrawtransaction',
  'signrawtransaction',

// util methods
  'createmultisig',
  'estimatefee',
  'estimatepriority',
  'validateaddress',
  'verifymessage',
  'z_validateaddress',

// wallet methods
  'addmultisigaddress',
  'backupwallet',
  'deposit',
  'dumpprivkey',
  'dumpwallet',
  'encryptwallet',
  'getbalance',
  'getnewaddress',
  'getrawchangeaddress',
  'getreceivedbyaddress',
  'getrefund',
  'gettransaction',
  'getunconfirmedbalance',
  'getwalletinfo',
  'importaddress',
  'importprivkey',
  'importpubkey',
  'importwallet',
  'keypoolrefill',
  'listaddresses',
  'listaddressgroupings',
  'listlockunspent',
  'listreceivedbyaddress',
  'listsinceblock',
  'listtransactions',
  'listunspent',
  'lockunspent',
  'refund',
  'sendmany',
  'sendtoaddress',
  'settxfee',
  'signmessage',
  'walletconfirmbackup',
  'withdraw',
  'z_exportkey',
  'z_exportviewingkey',
  'z_exportwallet',
  'z_getaddressforaccount',
  'z_getbalance',
  'z_getbalanceforaccount',
  'z_getbalanceforviewingkey',
  'z_getmigrationstatus',
  'z_getnewaccount',
  'z_getnewaddress',
  'z_getnotescount',
  'z_getoperationresult',
  'z_getoperationstatus',
  'z_gettotalbalance',
  'z_importkey',
  'z_importviewingkey',
  'z_importwallet',
  'z_listaccounts',
  'z_listaddresses',
  'z_listoperationids',
  'z_listreceivedbyaddress',
  'z_listunifiedreceivers',
  'z_listunspent',
  'z_mergetoaddress',
  'z_sendmany',
  'z_setmigration',
  'z_shieldcoinbase',
  'z_viewtransaction',
  'zcbenchmark',
  'zcrawjoinsplit' // deprecated,
      'zcrawkeygen', // deprecated
  'zcrawreceive', // deprecated
  'zcsamplejoinsplit',
];
