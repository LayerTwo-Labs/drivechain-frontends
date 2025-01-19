import 'dart:async';

import 'package:dart_coin_rpc/dart_coin_rpc.dart';
import 'package:dio/dio.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidesail/rpc/models/bmm_result.dart';
import 'package:sidesail/rpc/models/bundle_info.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
import 'package:sidesail/rpc/rpc_withdrawal_bundle.dart';

/// RPC connection the sidechain node.
abstract class TestchainRPC extends SidechainRPC {
  TestchainRPC({
    required super.conf,
    required super.binary,
    required super.logPath,
  }) : super(chain: TestSidechain());

  Future<int> mainBlockCount();

  Future<BmmResult> refreshBMM(int bidSatoshis);

  /// Returns null if there's no current bundle
  Future<WithdrawalBundle?> mainCurrentWithdrawalBundle();

  // such a mess that this takes in a status...
  // This is because the status isn't explicitly returned anywhere, but rather
  // deduced by where you got the bundle hash from.
  // testchain-cli getwithdrawalbundleinfo => pending
  // drivechain-cli listfailedwithdrawals  => failed
  // drivechain-cli listspentwithdrawals   => success
  Future<WithdrawalBundle> lookupWithdrawalBundle(String hash, BundleStatus status);

  Future<FutureWithdrawalBundle> mainNextWithdrawalBundle();
}

class TestchainRPCLive extends TestchainRPC {
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

  TestchainRPCLive({
    required super.conf,
    required super.binary,
    required super.logPath,
  });

  @override
  Future<(double, double)> balance() async {
    final walletInfo = await _client().call('getwalletinfo');
    final confirmed = walletInfo['balance'] as double;
    final unconfirmed = walletInfo['unconfirmed_balance'] as double;
    final immature = walletInfo['immature_balance'] as double;

    return (confirmed, unconfirmed + immature);
  }

  @override
  Future<BmmResult> refreshBMM(int bidSatoshis) async {
    final res = await _client().call('refreshbmm', [satoshiToBTC(bidSatoshis)]) as Map<String, dynamic>;

    return BmmResult.fromJson(res);
  }

  @override
  Future<String> mainSend(
    String address,
    double amount,
    double sidechainFee,
    double mainchainFee,
  ) async {
    amount = cleanAmount(amount);

    // 1. Get refund address for the sidechain withdrawal. This can be any address we control on the SC.
    final refund = await _getRefundAddress();
    log.d('got refund address: $refund');

    final withdrawalTxid = await _client().call('createwithdrawal', [
      address,
      refund,
      amount,
      sidechainFee,
      mainchainFee,
    ]);

    log.d('created withdraw: ${withdrawalTxid['txid']}');

    return withdrawalTxid['txid'];
  }

  @override
  Future<String> getDepositAddress() async {
    var address = await _client().call('getnewaddress', ['Sidechain Peg In', 'legacy']);
    return formatDepositAddress(address, chain.slot);
  }

  @override
  Future<String> getSideAddress() async {
    var address = await _client().call('getnewaddress', ['Sidechain Deposit']);
    return address as String;
  }

  Future<String> _getRefundAddress() async {
    var address = await _client().call('getnewaddress', ['Sidechain Deposit', 'legacy']) as String;
    return address;
  }

  @override
  Future<double> sideEstimateFee() async {
    final estimate = await _client().call('estimatesmartfee', [6]) as Map<String, dynamic>;
    if (estimate.containsKey('errors')) {
      // 10 sats/byte
      return 0.001;
    }

    final btcPerKb = estimate['feerate'] as double;

    // who knows!
    const kbyteInTx = 5;
    return btcPerKb * kbyteInTx;
  }

  @override
  Future<dynamic> callRAW(String method, [dynamic params]) async {
    return await _client().call(method, params).catchError((err) {
      log.t('rpc: $method threw exception: $err');
      throw err;
    });
  }

  @override
  Future<String> sideSend(String address, double amount, bool subtractFeeFromAmount) async {
    amount = cleanAmount(amount);

    final withdrawalTxid = await _client().call('sendtoaddress', [
      address,
      amount,
      '',
      '',
      subtractFeeFromAmount,
    ]);

    return withdrawalTxid;
  }

  @override
  Future<List<CoreTransaction>> listTransactions() async {
    // first list
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
  Future<int> mainBlockCount() async {
    final cached = await _client().call('updatemainblockcache') as Map<String, dynamic>;

    return cached['cachesize'];
  }

  @override
  Future<int> ping() async {
    final blockHeight = await _client().call('getblockcount') as int;
    return blockHeight;
  }

  @override
  Future<WithdrawalBundle> lookupWithdrawalBundle(String hash, BundleStatus status) async {
    final info = await _client().call(
      'getwithdrawalbundleinfo',
      [hash],
    );

    final withdrawalIDs = info['withdrawals'] as List<dynamic>;

    final withdrawals = await Future.wait(
      withdrawalIDs.map(
        (id) => _client().call(
          'getwithdrawal',
          [id],
        ).then((json) => Withdrawal.fromJson(json)),
      ),
    );

    return WithdrawalBundle.fromWithdrawals(
      hash,
      status,
      BundleInfo.fromJson(info),
      withdrawals,
    );
  }

  @override
  Future<WithdrawalBundle?> mainCurrentWithdrawalBundle() async {
    dynamic rawWithdrawalBundle;
    try {
      rawWithdrawalBundle = await _client().call('getwithdrawalbundle');
    } on RPCException catch (err) {
      if (err.errorCode == RPCError.errNoWithdrawalBundle) {
        return null;
      }
      rethrow;
    }

    final decoded = await _client().call('decoderawtransaction', [rawWithdrawalBundle]);
    final tx = RawTransaction.fromJson(decoded);
    return lookupWithdrawalBundle(tx.hash, BundleStatus.pending);
  }

  @override
  Future<FutureWithdrawalBundle> mainNextWithdrawalBundle() async {
    final rawNextBundle = await _client().call('listnextbundlewithdrawals') as List<dynamic>;

    return FutureWithdrawalBundle(
      cumulativeWeight: 0,
      withdrawals: rawNextBundle
          .map(
            (withdrawal) => Withdrawal(
              mainchainFeesSatoshi: withdrawal['amountmainchainfee'],
              amountSatoshi: withdrawal['amount'],
              address: withdrawal['destination'],
              hashBlindTx: withdrawal['hashblindtx'],
              refundDestination: withdrawal['refunddestination'],
              status: withdrawal['status'],
            ),
          )
          .toList(),
    );
  }

  @override
  Future<List<String>> binaryArgs(
    NodeConnectionSettings mainchainConf,
  ) async {
    final sidechainArgs = [
      '-mainchainrpcport=${mainchainConf.port}',
      '-mainchainrpchost=${mainchainConf.host}',
      '-mainchainrpcuser=${mainchainConf.username}',
      '-mainchainrpcpassword=${mainchainConf.password}',
    ];

    return cleanArgs(conf, sidechainArgs);
  }

  @override
  Future<void> stop() async {
    await _client().call('stop');
  }

  Future<BlockchainInfo> getBlockchainInfo() async {
    final confirmedFut = await _client().call('getblockchaininfo');
    return BlockchainInfo.fromMap(confirmedFut);
  }
}

class TestchainRPCError {
  static const errNoWithdrawalBundle = -100;
  static const errWithdrawalNotFound = -101;
}

class RPCError {
  static const errMisc = -3;
  static const errNoWithdrawalBundle = -100;
  static const errWithdrawalNotFound = -101;
}

/// List of all known RPC methods available
final testRPCMethods = [
  // == Sidechain ==
  'createwithdrawal',
  'createwithdrawalrefundrequest',
  'formatdepositaddress',
  'getaveragemainchainfees',
  'getmainchainblockcount',
  'getmainchainblockhash',
  'getwithdrawal',
  'getwithdrawalbundle',
  'listmywithdrawals',
  'listnextbundlewithdrawals',
  'listunspentwithdrawals',
  'rebroadcastwithdrawalbundle',
  'refreshbmm',
  'refundallwithdrawals',
  'updatemainblockcache',
  'verifymainblockcache',

  // == Blockchain ==
  'getbestblockhash',
  'getblock',
  'getblockchaininfo',
  'getblockcount',
  'getblockhash',
  'getblockheader',
  'getchainheaders',
  'getchaintips',
  'getchaintxstats',
  'getmempoolancestors',
  'getmempooldescendants',
  'getmempoolentry',
  'getmempoolinfo',
  'getrawmempool',
  'gettxout',
  'gettxoutproof',
  'gettxoutsetinfo',
  'preciousblock',
  'pruneblockchain',
  'savemempool',
  'verifychain',
  'verifytxoutproof',

  // == Control ==
  'getmemoryinfo',
  'help',
  'logging',
  'stop',
  'uptime',

  // == Mining ==
  'getmininginfo',
  'prioritisetransaction',

  // == Network ==
  'addnode',
  'clearbanned',
  'disconnectnode',
  'getaddednodeinfo',
  'getconnectioncount',
  'getnettotals',
  'getnetworkinfo',
  'getpeerinfo',
  'listbanned',
  'ping',
  'setban',
  'setnetworkactive',

  // == Rawtransactions ==
  'combinerawtransaction',
  'createrawtransaction',
  'decoderawtransaction',
  'decodescript',
  'fundrawtransaction',
  'getrawtransaction',
  'sendrawtransaction',
  'signrawtransaction',
  'signrawtransactionwithkey',

  // == Util ==
  'createmultisig',
  'estimatesmartfee',
  'signmessagewithprivkey',
  'validateaddress',
  'verifymessage',

  // == Wallet ==
  'abandontransaction',
  'abortrescan',
  'addmultisigaddress',
  'backupwallet',
  'bumpfee',
  'dumpprivkey',
  'dumpwallet',
  'encryptwallet',
  'getaccount',
  'getaccountaddress',
  'getaddressesbyaccount',
  'getaddressinfo',
  'getbalance',
  'getdepositaddress',
  'getnewaddress',
  'getrawchangeaddress',
  'getreceivedbyaccount',
  'getreceivedbyaddress',
  'gettransaction',
  'getunconfirmedbalance',
  'getwalletinfo',
  'importaddress',
  'importmulti',
  'importprivkey',
  'importprunedfunds',
  'importpubkey',
  'importwallet',
  'keypoolrefill',
  'listaccounts',
  'listaddressgroupings',
  'listlockunspent',
  'listreceivedbyaccount',
  'listreceivedbyaddress',
  'listsinceblock',
  'listtransactions',
  'listunspent',
  'listwallets',
  'lockunspent',
  'move',
  'removeprunedfunds',
  'rescanblockchain',
  'sendfrom',
  'sendmany',
  'sendtoaddress',
  'setaccount',
  'settxfee',
  'signmessage',
  'signrawtransactionwithwallet',
  'walletlock',
  'walletpassphrase',
  'walletpassphrasechange',
];
