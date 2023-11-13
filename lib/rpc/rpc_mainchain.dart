import 'dart:async';

import 'package:dart_coin_rpc/dart_coin_rpc.dart';
import 'package:dio/dio.dart';
import 'package:sidesail/rpc/models/core_transaction.dart';
import 'package:sidesail/rpc/rpc.dart';

/// RPC connection to the mainchain node.
abstract class MainchainRPC extends RPCConnection {
  MainchainRPC({required super.conf});

  Future<double> estimateFee();
  Future<int> getWithdrawalBundleWorkScore(int sidechain, String hash);
  Future<List<CoreTransaction>> listTransactions();
  Future<List<MainchainWithdrawal>> listSpentWithdrawals();
  Future<List<MainchainWithdrawal>> listFailedWithdrawals();
  Future<List<MainchainWithdrawalStatus>> listWithdrawalStatus(int slot);
}

class MainchainRPCLive extends MainchainRPC {
  RPCClient _client() {
    final client = RPCClient(
      host: conf.host,
      port: conf.port,
      username: conf.username,
      password: conf.password,
      useSSL: false,
    );

    // Completely empty client, with no retry logic.
    client.dioClient = Dio();
    return client;
  }

  // responsible for pinging the node every x seconds,
  // so we can update the UI immediately when the values change
  Timer? _connectionTimer;

  MainchainRPCLive({required super.conf}) {
    // Wait for the initial setup to be done, then start a timer
    initDone.then((value) {
      _connectionTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
        await testConnection();
      });
    });
  }

  @override
  Future<double> estimateFee() async {
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
  Future<List<CoreTransaction>> listTransactions() async {
    // first list
    final transactionsJSON = await _client().call('listtransactions', [
      '',
      100, // how many txs to list. We have not implemented pagination, so we list all
    ]) as List<dynamic>;

    // then convert to something other than json
    List<CoreTransaction> transactions = transactionsJSON.map((jsonItem) => CoreTransaction.fromMap(jsonItem)).toList();
    return transactions;
  }

  @override
  Future<int> getWithdrawalBundleWorkScore(int sidechain, String hash) async {
    try {
      final workscore = await _client().call('getworkscore', [sidechain, hash]);
      return workscore;
    } on RPCException {
      // This exception can be thrown if the bundle hasn't been added to the
      // Sidechain DB yet. Avoid erroring here, and instead return 0.
      return 0;
    }
  }

  @override
  Future<List<MainchainWithdrawal>> listSpentWithdrawals() async {
    final withdrawals = await _client().call('listspentwithdrawals') as List<dynamic>;
    return withdrawals.map((w) => MainchainWithdrawal.fromJson(w)).toList();
  }

  @override
  Future<List<MainchainWithdrawal>> listFailedWithdrawals() async {
    final withdrawals = await _client().call('listfailedwithdrawals') as List<dynamic>;
    return withdrawals.map((w) => MainchainWithdrawal.fromJson(w)).toList();
  }

  @override
  Future<List<MainchainWithdrawalStatus>> listWithdrawalStatus(int slot) async {
    final statuses = await _client().call('listwithdrawalstatus', [slot]) as List<dynamic>;
    return statuses.map((e) => MainchainWithdrawalStatus.fromJson(e)).toList();
  }

  @override
  Future<void> ping() async {
    await _client().call('ping') as Map<String, dynamic>?;
  }

  @override
  void dispose() {
    _connectionTimer?.cancel();
    super.dispose();
  }
}

class MainchainWithdrawalStatus {
  /// Blocks left until this withdrawal times out.
  int blocksLeft;

  /// Hash of withdrawal
  String hash;

  // Amount of votes this withdrawal has received.
  int score;

  MainchainWithdrawalStatus({
    required this.blocksLeft,
    required this.hash,
    required this.score,
  });

  factory MainchainWithdrawalStatus.fromJson(Map<String, dynamic> json) => MainchainWithdrawalStatus(
        blocksLeft: json['nblocksleft'] as int,
        hash: json['hash'] as String,
        score: json['nworkscore'] as int,
      );

  Map<String, dynamic> toJson() => {
        'nblocksleft': blocksLeft,
        'hash': hash,
        'nworkscore': score,
      };
}

class MainchainWithdrawal {
  /// Sidechain this withdrawal happened from
  int sidechain;

  /// Hash of withdrawal
  String hash;

  /// If this is a successful, hash of block Withdrawal was spent in.
  /// Otherwise, null.
  /// Can be fed into `drivechain-cli getblock`
  String? blockHash;

  MainchainWithdrawal({
    required this.sidechain,
    required this.hash,
    required this.blockHash,
  });

  factory MainchainWithdrawal.fromJson(Map<String, dynamic> json) => MainchainWithdrawal(
        sidechain: json['nsidechain'] as int,
        hash: json['hash'] as String,
        blockHash: json['hashblock'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'nsidechain': sidechain,
        'hash': hash,
        'hashblock': blockHash,
      };
}
