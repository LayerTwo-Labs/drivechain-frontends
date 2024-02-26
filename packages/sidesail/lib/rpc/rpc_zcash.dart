import 'package:dart_coin_rpc/dart_coin_rpc.dart';
import 'package:dio/dio.dart';
import 'package:sidesail/bitcoin.dart';
import 'package:sidesail/config/sidechains.dart';
import 'package:sidesail/pages/tabs/settings/node_settings_tab.dart';
import 'package:sidesail/rpc/models/core_transaction.dart';
import 'package:sidesail/rpc/models/zcash_utxos.dart';
import 'package:sidesail/rpc/rpc.dart';
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
      // always regtest for zcash
      '-regtest',
      // activates specific zcash-features necessary to make
      // the sidechain usable
      '-nuparams=76b809bb:1',
      '-nuparams=f5b9230b:5',
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

  Future<String> sendTransparent(String address, double amount, bool subtractFeeFromAmount);
  Future<String> getTransparentAddress();

  // how many UTXOs each cast will be split into when deshielding them
  double numUTXOsPerCast = 4;
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

  Future<double> _balanceForAccount(int account, int confirmations) async {
    final saplingBalance = await _client.call().call('z_getbalanceforaccount', [account, confirmations]).then(
      (res) {
        final pools = res['pools'];
        num zBalanceSat = 0;
        if (pools.containsKey('transparent')) {
          zBalanceSat += pools['transparent']['valueZat'];
        }
        if (pools.containsKey('sapling')) {
          zBalanceSat += pools['sapling']['valueZat'];
        }
        if (pools.containsKey('orchard')) {
          zBalanceSat += pools['orchard']['valueZat'];
        }

        return satoshiToBTC(zBalanceSat.toInt());
      },
    );

    var balance = saplingBalance;

    // sometimes we end up with multiple z_addresses. Maybe it's a change-
    // address, maybe it's something else, who knows!
    // Balance in those addresses does not show up when calling
    // z_getbalanceforaccount.
    // To get the correct balance, we must supplement the sapling balance
    // from above with the balance of each of the addresses returned from
    // z_listaddresses.
    final addresses = await _client().call('z_listaddresses') as List<dynamic>;
    for (final address in addresses) {
      final addressBalance = await _client.call().call('z_getbalance', [address, confirmations]);
      balance += addressBalance;
    }

    return balance;
  }

  Future<(double, double)> _transparentBalance(int account) async {
    final confirmedFut = _client().call('getbalance');
    final unconfirmedFut = _client().call('getunconfirmedbalance');

    return (await confirmedFut as double, await unconfirmedFut as double);
  }

  @override
  Future<(double, double)> getBalance() async {
    final acc = await account();

    final (transparentConfirmed, transparentUnconfirmed) = await _transparentBalance(acc);

    final confirmed = await _balanceForAccount(acc, 1);
    final confirmedAndUnconfirmed = await _balanceForAccount(acc, 0);

    return (confirmed + transparentConfirmed, transparentUnconfirmed + confirmedAndUnconfirmed - confirmed);
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
  Future<String> deshield(ShieldedUTXO utxo, double amount) async {
    amount = cleanAmount(amount);

    final regularAddress = await getTransparentAddress();
    final operationID = await _client().call('z_sendmany', [
      utxo.address,
      [
        {
          'address': regularAddress,
          'amount': amount,
        }
      ],
      1,
    ]);

    return operationID as String;
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
    final unspent = await _client().call('listunspent') as List<dynamic>;
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
  Future<String> mainGenerateAddress() async {
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

    final zAddress = await sideGenerateAddress();

    final operationID = await _client().call('z_sendmany', [
      utxo.address,
      [
        {
          'address': zAddress,
          'amount': amount,
        }
      ],
      1,
    ]);

    return operationID as String;
  }

  @override
  Future<double> sideEstimateFee() async {
    return 0.0001;
  }

  Future<String> _getNewShieldedAddress() async {
    return await _client().call('z_getnewaddress');
  }

  @override
  Future<String> sideGenerateAddress() async {
    final addresses = await _client().call('z_listaddresses') as List<dynamic>;
    if (addresses.isEmpty) {
      return _getNewShieldedAddress();
    }

    return addresses.first as String;
  }

  @override
  Future<int> fetchBlockCount() async {
    final blockHeight = await _client().call('getblockcount') as int;
    return blockHeight;
  }

  @override
  Future<String> sideSend(String address, double amount, bool subtractFeeFromAmount) async {
    var fee = await sideEstimateFee();

    amount = cleanAmount(amount);
    fee = cleanAmount(fee);

    final zAddress = await sideGenerateAddress();
    final txid = await _client().call('z_sendmany', [
      zAddress,
      [
        {
          'address': address,
          'amount': double.parse(amount.toStringAsFixed(8)),
        }
      ],
      1,
      fee,
    ]);

    return txid;
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
  Future<String> getTransparentAddress() async {
    return await _client().call('getnewaddress');
  }

  @override
  Future<void> stopNode() async {
    return await _client().call('stop');
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
