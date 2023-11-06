import 'dart:async';
import 'dart:convert';

import 'package:dart_coin_rpc/dart_coin_rpc.dart';
import 'package:dio/dio.dart';
import 'package:sidesail/config/sidechains.dart';
import 'package:sidesail/logger.dart';
import 'package:sidesail/pages/tabs/settings_tab.dart';
import 'package:sidesail/rpc/rpc.dart';
import 'package:sidesail/rpc/rpc_config.dart';
import 'package:sidesail/rpc/rpc_rawtx.dart';
import 'package:sidesail/rpc/rpc_withdrawal_bundle.dart';

/// RPC connection the sidechain node.
abstract class SidechainRPC extends RPCConnection {
  Future<(double, double)> getBalance();
  Future<BmmResult> refreshBMM(int bidSatoshis);
  Future<String> generatePegInAddress();
  Future<String> pegOut(
    String address,
    double amount,
    double sidechainFee,
    double mainchainFee,
  );
  Future<String> generateSidechainAddress();
  Future<String> getRefundAddress();
  Future<String> sidechainSend(
    String address,
    double amount,
    bool subtractFeeFromAmount,
  );
  Future<List<Transaction>> listTransactions();

  Future<double> estimateFee();
  Future<int> mainchainBlockCount();
  Future<int> blockCount();

  Future<WithdrawalBundle> currentWithdrawalBundle();
  Future<FutureWithdrawalBundle> nextWithdrawalBundle();

  Future<dynamic> callRAW(String method, [dynamic params]);

  late Sidechain chain;
  void setChain(Sidechain newChain) {
    chain = newChain;
    notifyListeners();
  }
}

class SidechainRPCLive extends SidechainRPC {
  RPCClient? _client;

  // responsible for pinging the node every x seconds,
  // so we can update the UI immediately when the values change
  Timer? _connectionTimer;

  // hacky way to create an async class
  // https://stackoverflow.com/a/59304510
  SidechainRPCLive._create() {
    chain = TestSidechain();
  }

  static Future<SidechainRPCLive> create() async {
    final rpc = SidechainRPCLive._create();
    await rpc._init();
    return rpc;
  }

  Future<void> _init() async {
    final config = await readRpcConfig(testchainDatadir(), 'testchain.conf');
    connectionSettings = SingleNodeConnectionSettings(
      config.path,
      config.host,
      config.port,
      config.username,
      config.password,
    );
    await createClient();
    await testConnection();
    _connectionTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      await testConnection();
    });
  }

  @override
  Future<void> createClient() async {
    _client = RPCClient(
      host: connectionSettings.host,
      port: connectionSettings.port,
      username: connectionSettings.username,
      password: connectionSettings.password,
      useSSL: connectionSettings.ssl,
    );

    // Completely empty client, with no retry logic.
    _client!.dioClient = Dio();

    log.i('created client');
  }

  @override
  Future<(double, double)> getBalance() async {
    final confirmed = await _client?.call('getbalance') as double;
    final unconfirmed = await _client?.call('getunconfirmedbalance') as double;

    return (confirmed, unconfirmed);
  }

  @override
  Future<BmmResult> refreshBMM(int bidSatoshis) async {
    final res = await _client?.call('refreshbmm', [bidSatoshis / 100000000]) as Map<String, dynamic>;

    return BmmResult.fromJson(res);
  }

  @override
  Future<String> pegOut(
    String address,
    double amount,
    double sidechainFee,
    double mainchainFee,
  ) async {
    // 1. Get refund address for the sidechain withdrawal. This can be any address we control on the SC.
    final refund = await getRefundAddress();
    log.d('got refund address: $refund');

    final withdrawalTxid = await _client?.call('createwithdrawal', [
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
  Future<String> generatePegInAddress() async {
    var address = await _client?.call('getnewaddress', ['Sidechain Peg In', 'legacy']);

    // This is actually just rather simple stuff. Should be able to
    // do this client side! Just needs the sidechain number, and we're
    // off to the races.
    var formatted = await _client?.call('formatdepositaddress', [address as String]);

    return formatted as String;
  }

  @override
  Future<String> generateSidechainAddress() async {
    var address = await _client?.call('getnewaddress', ['Sidechain Deposit']);
    return address as String;
  }

  @override
  Future<String> getRefundAddress() async {
    var address = await _client?.call('getnewaddress', ['Sidechain Deposit', 'legacy']) as String;
    return address;
  }

  @override
  Future<double> estimateFee() async {
    final estimate = await _client?.call('estimatesmartfee', [6]) as Map<String, dynamic>;
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
    return _client?.call(method, params).catchError((err) {
      log.t('rpc: $method threw exception: $err');
      throw err;
    });
  }

  @override
  Future<String> sidechainSend(String address, double amount, bool subtractFeeFromAmount) async {
    final withdrawalTxid = await _client?.call('sendtoaddress', [
      address,
      amount,
      '',
      '',
      subtractFeeFromAmount,
    ]);

    return withdrawalTxid;
  }

  @override
  Future<List<Transaction>> listTransactions() async {
    // first list
    final transactionsJSON = await _client?.call('listtransactions', [
      '',
      9999, // how many txs to list. We have not implemented pagination, so we list all
    ]) as List<dynamic>;

    // then convert to something other than json
    List<Transaction> transactions = transactionsJSON.map((jsonItem) => Transaction.fromMap(jsonItem)).toList();
    transactions.removeWhere((t) => t.amount == 0);
    return transactions;
  }

  @override
  Future<int> mainchainBlockCount() async {
    final cached = await _client?.call('updatemainblockcache') as Map<String, dynamic>;

    return cached['cachesize'];
  }

  @override
  Future<int> blockCount() async {
    return await _client?.call('getblockcount');
  }

  @override
  Future<void> ping() async {
    await _client?.call('ping') as Map<String, dynamic>?;
  }

  @override
  void dispose() {
    _connectionTimer?.cancel();
    super.dispose();
  }

  @override
  Future<WithdrawalBundle> currentWithdrawalBundle() async {
    final rawWithdrawalBundle = await _client?.call('getwithdrawalbundle');

    final decoded = await _client?.call('decoderawtransaction', [rawWithdrawalBundle]);
    final tx = RawTransaction.fromJson(decoded);

    final info = await _client?.call(
      'getwithdrawalbundleinfo',
      [tx.hash],
    );

    final withdrawalIDs = info['withdrawals'] as List<dynamic>;

    final withdrawals = await Future.wait(
      withdrawalIDs.map(
        (id) => _client!.call(
          'getwithdrawal',
          [id],
        ).then((json) => Withdrawal.fromJson(json)),
      ),
    );

    return WithdrawalBundle.fromRawTransaction(
      tx,
      BundleInfo.fromJson(info),
      withdrawals,
    );
  }

  @override
  Future<FutureWithdrawalBundle> nextWithdrawalBundle() async {
    final rawNextBundle = await _client?.call('listnextbundlewithdrawals') as List<dynamic>;

    return FutureWithdrawalBundle(
      cumulativeWeight: 0, // TODO: not sure how to obtain this
      withdrawals: rawNextBundle
          .map(
            (withdrawal) => Withdrawal(
              mainchainFeesSatoshi: withdrawal['amountmainchainfee'],
              amountSatoshi: withdrawal['amount'],
              address: withdrawal['destination'],
              hashBlindTx: '', // TODO
              refundDestination: '', // TODO
              status: '', // TODO
            ),
          )
          .toList(),
    );
  }
}

class RPCError {
  static const errMisc = -3;
  static const errNoWithdrawalBundle = -100;
  static const errWithdrawalNotFound = -101;
}

class Transaction {
  final String address;
  final String category;
  final double amount;
  final String label;
  final int vout;
  final double fee;
  final int confirmations;
  final bool trusted;
  final String blockhash;
  final int blockindex;
  final int blocktime;
  final String txid;
  final DateTime time;
  final DateTime timereceived;
  final String comment;
  final String bip125Replaceable;
  final bool abandoned;
  final String raw;

  Transaction({
    required this.address,
    required this.category,
    required this.amount,
    required this.label,
    required this.vout,
    required this.fee,
    required this.confirmations,
    required this.trusted,
    required this.blockhash,
    required this.blockindex,
    required this.blocktime,
    required this.txid,
    required this.time,
    required this.timereceived,
    required this.comment,
    required this.bip125Replaceable,
    required this.abandoned,
    required this.raw,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      address: map['address'] ?? '',
      category: map['category'] ?? '',
      amount: map['amount'] ?? 0.0,
      label: map['label'] ?? '',
      vout: map['vout'] ?? 0,
      fee: map['fee'] ?? 0.0,
      confirmations: map['confirmations'] ?? 0,
      trusted: map['trusted'] ?? false,
      blockhash: map['blockhash'] ?? '',
      blockindex: map['blockindex'] ?? 0,
      blocktime: map['blocktime'] ?? 0,
      txid: map['txid'] ?? '',
      time: DateTime.fromMillisecondsSinceEpoch((map['time'] ?? 0) * 1000),
      timereceived: DateTime.fromMillisecondsSinceEpoch((map['timereceived'] ?? 0) * 1000),
      comment: map['comment'] ?? '',
      bip125Replaceable: map['bip125-replaceable'] ?? 'unknown',
      abandoned: map['abandoned'] ?? false,
      raw: jsonEncode(map),
    );
  }

  static Transaction fromJson(String json) => Transaction.fromMap(jsonDecode(json));
  String toJson() => jsonEncode(toMap());

  Map<String, dynamic> toMap() => {
        'address': address,
        'category': category,
        'amount': amount,
        'label': label,
        'vout': vout,
        'fee': fee,
        'confirmations': confirmations,
        'trusted': trusted,
        'blockhash': blockhash,
        'blockindex': blockindex,
        'blocktime': blocktime,
        'txid': txid,
        'time': time.millisecondsSinceEpoch ~/ 1000,
        'timereceived': timereceived.millisecondsSinceEpoch ~/ 1000,
        'comment': comment,
        'bip125-replaceable': bip125Replaceable,
        'abandoned': abandoned,
      };
}

class BmmResult {
  final String hashLastMainBlock;

  // hashCreatedMerkleRoot/hashCreated in the testchain codebase
  final String? bmmBlockCreated;

  // hashConnected in the testchain codebase
  final String? bmmBlockSubmitted;

  // hashMerkleRoot/hashConnectedBlind in the testchain codebase
  final String? bmmBlockSubmittedBlind;

  final int ntxn; // number of transactions
  final int nfees; // total fees
  final String txid; // transaction ID
  final String? error; // error message, if any
  final String raw; // raw JSON string

  BmmResult({
    required this.hashLastMainBlock,
    required this.bmmBlockCreated,
    required this.bmmBlockSubmitted,
    required this.bmmBlockSubmittedBlind,
    required this.ntxn,
    required this.nfees,
    required this.txid,
    this.error,
    required this.raw,
  });

  factory BmmResult.fromMap(Map<String, dynamic> map) {
    return BmmResult(
      hashLastMainBlock: map['hash_last_main_block'] ?? '',
      bmmBlockCreated: ifNonEmpty(map['bmm_block_created']),
      bmmBlockSubmitted: ifNonEmpty(map['bmm_block_submitted']),
      bmmBlockSubmittedBlind: ifNonEmpty(map['bmm_block_submitted_blind']),
      ntxn: map['ntxn'] ?? 0,
      nfees: map['nfees'] ?? 0,
      txid: map['txid'] ?? '',
      error: ifNonEmpty(map['error']),
      raw: jsonEncode(map),
    );
  }

  static BmmResult fromJson(Map<String, dynamic> json) => BmmResult.fromMap(json);
  String toJson() => jsonEncode(toMap());

  Map<String, dynamic> toMap() => {
        'hash_last_main_block': hashLastMainBlock,
        'bmm_block_created': bmmBlockCreated,
        'bmm_block_submitted': bmmBlockSubmitted,
        'bmm_block_submitted_blind': bmmBlockSubmittedBlind,
        'ntxn': ntxn,
        'nfees': nfees,
        'txid': txid,
        'error': error,
      };
}

String? ifNonEmpty(String input) {
  if (input.isEmpty || input.split('').every((element) => element == '0')) {
    return null;
  }

  return input;
}

class BundleInfo {
  final int amountSatoshi;
  final int feesSatoshi;
  final int weight;
  final int height;

  BundleInfo({
    required this.amountSatoshi,
    required this.feesSatoshi,
    required this.weight,
    required this.height,
  });

  factory BundleInfo.fromJson(Map<String, dynamic> json) {
    return BundleInfo(
      amountSatoshi: json['amount'],
      feesSatoshi: json['fees'],
      weight: json['weight'],
      height: json['height'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amountSatoshi,
      'fees': feesSatoshi,
      'weight': weight,
      'height': height,
    };
  }
}
