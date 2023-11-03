import 'dart:async';
import 'dart:convert';

import 'package:dart_coin_rpc/dart_coin_rpc.dart';
import 'package:dio/dio.dart';
import 'package:sidesail/logger.dart';
import 'package:sidesail/pages/tabs/settings_tab.dart';
import 'package:sidesail/rpc/rpc.dart';
import 'package:sidesail/rpc/rpc_config.dart';

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
  Future<String> fetchWithdrawalBundleStatus();
  Future<dynamic> callRAW(String method, [dynamic params]);
}

class SidechainRPCLive extends SidechainRPC {
  RPCClient? _client;

  // responsible for pinging the node every x seconds,
  // so we can update the UI immediately when the values change
  Timer? _connectionTimer;

  // hacky way to create an async class
  // https://stackoverflow.com/a/59304510
  SidechainRPCLive._create();

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
  Future<String> fetchWithdrawalBundleStatus() async {
    try {
      // TODO: do something meaningful with this, we would need it decoded
      // with bitcoin core.
      // BtcTransaction.fromRaw crashes...
      final bundleHex = await _client?.call('getwithdrawalbundle', []);

      return 'something: ${(bundleHex as String).substring(0, 20)}...';
    } on RPCException catch (e) {
      if (e.errorCode != RPCError.errNoWithdrawalBundle) {
        return 'unexpected withdrawal bundle status: $e';
      }

      return 'no withdrawal bundle yet';
    } catch (e) {
      log.e('could not fetch withdrawal bundle: $e', error: e);
      rethrow;
    }
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
    final transactionsJSON = await _client?.call('listtransactions', []) as List<dynamic>;

    // then convert to something other than json
    List<Transaction> transactions = transactionsJSON.map((jsonItem) => Transaction.fromMap(jsonItem)).toList();
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
}

abstract class RPCError {
  static const errNoWithdrawalBundle = -100;
  static const errWithdrawalNotFound = -101;
}

class Transaction {
  final String account;
  final String address;
  final String category;
  final double amount;
  final String label;
  final int vout;
  final double fee;
  final int confirmations;
  final bool trusted;
  final String txid;
  final List<dynamic> walletconflicts;
  final DateTime time;
  final int timereceived;
  final String bip125Replaceable;
  final bool abandoned;
  final bool generated;
  final String blockhash;
  final int blockindex;
  final int blocktime;
  final String raw;

  Transaction({
    required this.account,
    required this.address,
    required this.category,
    required this.amount,
    required this.label,
    required this.vout,
    required this.fee,
    required this.confirmations,
    required this.trusted,
    required this.txid,
    required this.walletconflicts,
    required this.time,
    required this.timereceived,
    required this.bip125Replaceable,
    required this.abandoned,
    required this.generated,
    required this.blockhash,
    required this.blockindex,
    required this.blocktime,
    required this.raw,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      account: map['account'] ?? '',
      address: map['address'] ?? '',
      category: map['category'] ?? '',
      amount: map['amount'] ?? 0.0,
      label: map['label'] ?? '',
      vout: map['vout'] ?? 0,
      fee: map['fee'] ?? 0.0,
      confirmations: map['confirmations'] ?? 0,
      trusted: map['trusted'] ?? false,
      txid: map['txid'] ?? '',
      walletconflicts: map['walletconflicts'] ?? [],
      time: DateTime.fromMillisecondsSinceEpoch((map['time'] ?? 0) * 1000),
      timereceived: map['timereceived'] ?? 0,
      bip125Replaceable: map['bip125-replaceable'] ?? 'no',
      abandoned: map['abandoned'] ?? false,
      generated: map['generated'] ?? false,
      blockhash: map['blockhash'] ?? '',
      blockindex: map['blockindex'] ?? 0,
      blocktime: map['blocktime'] ?? 0,
      raw: jsonEncode(map),
    );
  }

  static Transaction fromJson(String json) => Transaction.fromMap(jsonDecode(json));
  String toJson() => jsonEncode(toMap());

  Map<String, dynamic> toMap() => {
        'account': account,
        'address': address,
        'category': category,
        'amount': amount,
        'label': label,
        'vout': vout,
        'fee': fee,
        'confirmations': confirmations,
        'trusted': trusted,
        'txid': txid,
        'walletconflicts': walletconflicts,
        'time': time.millisecondsSinceEpoch ~/ 1000,
        'timereceived': timereceived,
        'bip125-replaceable': bip125Replaceable,
        'abandoned': abandoned,
      };
}

class BmmResult {
  final String hashLastMainBlock;

  /// hashCreatedMerkleRoot/hashCreated in the testchain codebase
  final String? bmmBlockCreated;

  /// hashConnected in the testchain codebase
  final String? bmmBlockSubmitted;

  /// hashMerkleRoot/hashConnectedBlind in the testchain codebase
  final String? bmmBlockSubmittedBlind;

  final int ntxn;
  final int nfees;
  final String txid;
  final String? error;

  BmmResult({
    required this.hashLastMainBlock,
    required this.bmmBlockCreated,
    required this.bmmBlockSubmitted,
    required this.bmmBlockSubmittedBlind,
    required this.ntxn,
    required this.nfees,
    required this.txid,
    this.error,
  });

  factory BmmResult.fromJson(Map<String, dynamic> json) {
    return BmmResult(
      hashLastMainBlock: json['hash_last_main_block'],
      bmmBlockCreated: ifNonEmpty(json['bmm_block_created']),
      bmmBlockSubmitted: ifNonEmpty(json['bmm_block_submitted']),
      bmmBlockSubmittedBlind: ifNonEmpty(json['bmm_block_submitted_blind']),
      ntxn: json['ntxn'],
      nfees: json['nfees'],
      txid: json['txid'],
      error: ifNonEmpty(json['error']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
}

String? ifNonEmpty(String input) {
  if (input.isEmpty || input.split('').every((element) => element == '0')) {
    return null;
  }

  return input;
}
