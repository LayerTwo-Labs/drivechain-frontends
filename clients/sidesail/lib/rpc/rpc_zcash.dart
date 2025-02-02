// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:dart_coin_rpc/dart_coin_rpc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidesail/rpc/models/zcash_utxos.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';

const zcashFee = 0.0001;

Future<void> copyIfNotExists(Logger log, BuildContext context, File file, String binPath) async {
  if (await file.exists()) {
    // if the file already exists, don't do anything
    log.d('file already exists in app directory, not copying');
    return;
  }

  if (!context.mounted) {
    log.d('writeIfNotExists: context not mounted, exiting');
    return;
  }

  // we can only bundle assets in the assets folder, but
  // it's very hard to get an absolute path there
  final binResource = await DefaultAssetBundle.of(context).load(
    'assets/bin/$binPath',
  );

  log.d('writeIfNotExists: writing file to app directory');
  // so we load the asset, and write it to a place we CAN get
  // an absolute path for
  await file.writeAsBytes(binResource.buffer.asUint8List());
}

Future<void> writeConfFileIfNotExists(Logger log) async {
  final appDataDir = ZCashSidechain().datadir();
  final zcashDataDir = Directory(appDataDir);

  if (!await zcashDataDir.exists()) {
    log.i('zcash data dir does not exist, creating');
    await zcashDataDir.create(recursive: true);
  }

  final confFile = ZCashSidechain().confFile();

  final file = File('${zcashDataDir.path}/$confFile');

  if (!await file.exists()) {
    log.i('$confFile does not exist, creating');
    // zcash needs conf file to run
    await file.create();
    // so let's write some default values to it
    await file.writeAsString('''rpcuser=user
rpcpassword=password
server=1
regtest=1
addnode=172.105.148.135
rpcport=8232
nuparams=76b809bb:1
nuparams=f5b9230b:5
walletrequirebackup=false
txindex=1
rpcworkqueue=200
''');
  }
}

abstract class ZCashRPC extends SidechainRPC {
  final saplingOutputPath = 'sapling-output.params';
  final saplingSpendPath = 'sapling-spend.params';
  final sproutGrothPath = 'sprout-groth16.params';

  ZCashRPC({
    required super.conf,
    required super.binary,
    required super.logPath,
  }) : super(chain: ZCashSidechain());

  @override
  Future<List<String>> binaryArgs(NodeConnectionSettings mainchainConf) async {
    final sidechainArgs = [
      '-mainport=${mainchainConf.port}',
      '-mainhost=${mainchainConf.host}',
    ];

    return cleanArgs(conf, sidechainArgs);
  }

  @override
  Future<void> initBinary(
    BuildContext context, {
    List<String>? arg,
  }) async {
    final args = await binaryArgs(conf);
    args.addAll(arg ?? []);

    try {
      final appDir = await getApplicationSupportDirectory();
      // first, figure out whether a folder exists
      final saplingOutput = File('${appDir.path}/$saplingOutputPath');
      final saplingSpend = File('${appDir.path}/$saplingSpendPath');
      final sproutGroth = File('${appDir.path}/$sproutGrothPath');

      log.i('got application support dir, copying params to dir ${appDir.path}');

      await Future.wait([
        copyIfNotExists(log, context, saplingOutput, saplingOutputPath),
        copyIfNotExists(log, context, saplingSpend, saplingSpendPath),
        copyIfNotExists(log, context, sproutGroth, sproutGrothPath),
        writeConfFileIfNotExists(log),
      ]);

      // if paramsdir not already specified, add the one we just
      // created!
      addEntryIfNotSet(args, 'paramsdir', appDir.path);
    } catch (error) {
      log.e('could not write Zcash files to local directory $error');
    }

    // after all assets are loaded properly, THEN init the zcash-binary
    await super.initBinary(context, arg: args);
  }

  /// There's no account in the wallet out of the box. Calling this
  /// either creates a new one, or returns an already existing one
  /// if we created one earlier.
  Future<int> account();

  Future<List<OperationStatus>> listOperations();
  Future<List<ShieldedUTXO>> listShieldedCoins();
  Future<List<UnshieldedUTXO>> listUnshieldedCoins();
  Future<List<ShieldedUTXO>> listPrivateTransactions();

  Future<String> shield(UnshieldedUTXO utxo, double amount);
  Future<(String, String)> deshield(ShieldedUTXO utxo, double amount);

  Future<String> sendTransparent(String address, double amount, bool subtractFeeFromAmount);
  Future<String> getPrivateAddress();

  // how many UTXOs each cast will be split into when deshielding them
  double numUTXOsPerCast = 4;
}

class ZcashRPCLive extends ZCashRPC {
  ZcashRPCLive({
    required super.conf,
    required super.binary,
    required super.logPath,
  });

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
  Future<(double, double)> balance() async {
    final confirmedFut = _client().call('getbalance');
    final unconfirmedFut = _client().call('getunconfirmedbalance');

    return (await confirmedFut as double, await unconfirmedFut as double);
  }

  int? cachedAccount;

  @override
  Future<(String, String)> deshield(ShieldedUTXO utxo, double amount) async {
    amount = cleanAmount(amount);

    final to = await getDepositAddress();

    return (await sendTransparent(to, amount, false), to);
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
    final shieldedCoins = await _client().call('z_listunspent', [0]) as List<dynamic>;
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
      '*',
      9999, // how many txs to list. We have not implemented pagination, so we list all
      0,
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
    final unspent = await _client().call('listunspent', [0]) as List<dynamic>;
    if (unspent.isEmpty) {
      return List.empty();
    }

    List<UnshieldedUTXO> unspentUTXOs = unspent.map(
      (jsonItem) {
        return UnshieldedUTXO.fromMap(jsonItem);
      },
    ).toList();

    unspentUTXOs.removeWhere((t) => t.amount == 0);
    return unspentUTXOs;
  }

  @override
  Future<List<ShieldedUTXO>> listPrivateTransactions() async {
    List<ShieldedUTXO> txs = [];
    return txs;
  }

  @override
  Future<String> getDepositAddress() async {
    final address = await _client().call('getnewaddress');
    return formatDepositAddress(address, chain.slot);
  }

  @override
  Future<String> mainSend(String address, double amount, double sidechainFee, double mainchainFee) async {
    amount = cleanAmount(amount);

    return await _client().call('withdraw', [address, amount, false]);
  }

  @override
  Future<String> shield(UnshieldedUTXO utxo, double amount) async {
    amount = cleanAmount(amount);

    log.i(
      'shielding $amount ${chain.ticker} from address=${utxo.address} amount=${utxo.amount} ${chain.ticker} confs=${utxo.confirmations}',
    );

    if (utxo.generated && (amount + zcashFee) != utxo.amount) {
      throw Exception('must shield full amount for coinbase outputs');
    }

    return await sendTransparent(utxo.address, amount, false);
  }

  @override
  Future<double> sideEstimateFee() async {
    return zcashFee;
  }

  @override
  Future<String> getPrivateAddress() async {
    return await getDepositAddress();
  }

  @override
  Future<int> ping() async {
    final oldBlockHeight = blockCount;
    final newBlockHeight = await _client().call('getblockcount') as int;

    if (oldBlockHeight != newBlockHeight) {
      await clearBanned();
    }

    return newBlockHeight;
  }

  Future<void> clearBanned() async {
    await _client().call('clearbanned');
  }

  @override
  Future<String> sideSend(String address, double amount, bool subtractFeeFromAmount) async {
    return sendTransparent(address, amount, subtractFeeFromAmount);
  }

  @override
  Future<String> sendTransparent(String address, double amount, bool subtractFeeFromAmount) async {
    amount = cleanAmount(amount);

    final txid = await _client().call(
      'sendtoaddress',
      [
        address,
        double.parse(amount.toStringAsFixed(8)),
        '',
        '',
        subtractFeeFromAmount,
      ],
    );

    return txid;
  }

  @override
  Future<String> getSideAddress() async {
    return await _client().call('getnewaddress');
  }

  @override
  Future<void> stopRPC() async {
    await _client().call('stop');
    // can't trust the rpc, give it a moment to stop
    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  Future<BlockchainInfo> getBlockchainInfo() async {
    // TODO!
    final blocks = await _client().call('get-blockcount') as int;
    // can't trust the rpc, give it a moment to stop
    await Future.delayed(const Duration(seconds: 5));
    return BlockchainInfo(
      chain: 'signet',
      blocks: blocks,
      headers: blocks,
      bestBlockHash: '',
      difficulty: 0,
      time: 0,
      medianTime: 0,
      verificationProgress: 100.0,
      initialBlockDownload: false,
      chainWork: '',
      sizeOnDisk: 0,
      pruned: false,
      warnings: [],
    );
  }

  @override
  Future<int> account() {
    return Future.value(0);
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
  'zcrawjoinsplit', // deprecated,
  'zcrawkeygen', // deprecated
  'zcrawreceive', // deprecated
  'zcsamplejoinsplit',
];
