import 'dart:async';

import 'package:dart_coin_rpc/dart_coin_rpc.dart';
import 'package:dio/dio.dart';
import 'package:sidesail/bitcoin.dart';
import 'package:sidesail/config/sidechains.dart';
import 'package:sidesail/logger.dart';
import 'package:sidesail/rpc/models/bmm_result.dart';
import 'package:sidesail/rpc/models/bundle_info.dart';
import 'package:sidesail/rpc/models/core_transaction.dart';
import 'package:sidesail/rpc/models/raw_transaction.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
import 'package:sidesail/rpc/rpc_withdrawal_bundle.dart';

/// RPC connection the sidechain node.
abstract class TestchainRPC extends SidechainRPC {
  TestchainRPC({
    required super.conf,
  }) : super(chain: TestSidechain());

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

  Future<BmmResult> refreshBMM(int bidSatoshis);

  /// Returns null if there's no current bundle
  Future<WithdrawalBundle?> mainCurrentWithdrawalBundle();

  // TODO: such a mess that this takes in a status...
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

  // responsible for pinging the node every x seconds,
  // so we can update the UI immediately when the values change
  Timer? _connectionTimer;

  TestchainRPCLive({required super.conf});

  @override
  Future<(double, double)> getBalance() async {
    final confirmed = await _client().call('getbalance') as double;
    final unconfirmed = await _client().call('getunconfirmedbalance') as double;

    return (confirmed, unconfirmed);
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

    log.d('created peg-out: ${withdrawalTxid['txid']}');

    return withdrawalTxid['txid'];
  }

  @override
  Future<String> mainGenerateAddress() async {
    var address = await _client().call('getnewaddress', ['Sidechain Peg In', 'legacy']);

    // This is actually just rather simple stuff. Should be able to
    // do this client side! Just needs the sidechain number, and we're
    // off to the races.
    var formatted = await _client().call('formatdepositaddress', [address as String]);

    return formatted as String;
  }

  @override
  Future<String> sideGenerateAddress() async {
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
    ]) as List<dynamic>;

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
  Future<int> sideBlockCount() async {
    return await _client().call('getblockcount');
  }

  @override
  Future<void> ping() async {
    await _client().call('ping');
  }

  @override
  void dispose() {
    _connectionTimer?.cancel();
    super.dispose();
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
      cumulativeWeight: 0, // TODO: not sure how to obtain this
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
