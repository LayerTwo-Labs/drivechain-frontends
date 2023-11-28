import 'package:dart_coin_rpc/dart_coin_rpc.dart';
import 'package:dio/dio.dart';
import 'package:sidesail/bitcoin.dart';
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

class MockZCashRPC extends ZCashRPC {
  MockZCashRPC({required super.conf});

  @override
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
    return await _client().call('z_getoperationresult');
  }

  @override
  Future<List<ShieldedUTXO>> listShieldedCoins() async {
    return await _client().call('z_listunspent');
  }

  @override
  Future<List<CoreTransaction>> listTransactions() {
    // TODO: implement listTransactions
    throw UnimplementedError();
  }

  @override
  Future<List<UnshieldedUTXO>> listUnshieldedCoins() async {
    // TODO: verify this just returns unshielded coins. might have to
    // diff z_listunspent and listunspent?
    return await _client().call('listunspent');
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
  Future<String> melt(List<UnshieldedUTXO> utxos) {
    // TODO: implement melt
    throw UnimplementedError();
  }

  @override
  Future<String> shield(UnshieldedUTXO utxo, double amount) {
    // TODO: implement shield
    throw UnimplementedError();
  }

  @override
  Future<double> sideEstimateFee() {
    // TODO: implement sideEstimateFee
    throw UnimplementedError();
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
