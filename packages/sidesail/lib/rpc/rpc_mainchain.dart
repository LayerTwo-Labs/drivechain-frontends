import 'dart:async';

import 'package:dart_coin_rpc/dart_coin_rpc.dart';
import 'package:dio/dio.dart';
import 'package:sidesail/pages/tabs/settings/node_settings_tab.dart';
import 'package:sidesail/rpc/models/active_sidechains.dart';
import 'package:sidesail/rpc/models/utxo.dart';
import 'package:sidesail/rpc/rpc.dart';

/// RPC connection to the mainchain node.
abstract class MainchainRPC extends RPCConnection {
  MainchainRPC({required super.conf});

  Future<List<String>> generate(int blocks);
  Future<List<ActiveSidechain>> listActiveSidechains();
  Future<ActiveSidechain> createSidechainProposal(int slot, String title);
  Future<double> estimateFee();
  Future<int> getWithdrawalBundleWorkScore(int sidechain, String hash);
  Future<List<UTXO>> listUnspent();
  Future<List<MainchainWithdrawal>> listSpentWithdrawals();
  Future<List<MainchainWithdrawal>> listFailedWithdrawals();
  Future<List<MainchainWithdrawalStatus>> listWithdrawalStatus(int slot);

  final binary = 'drivechaind';
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

  // hacky way to create an async class
  // https://stackoverflow.com/a/59304510
  MainchainRPCLive._create({required super.conf});
  static Future<MainchainRPCLive> create(SingleNodeConnectionSettings conf) async {
    final container = MainchainRPCLive._create(conf: conf);
    await container.init();
    return container;
  }

  Future<void> init() async {
    await testConnection();
    startConnectionTimer();
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
  Future<List<UTXO>> listUnspent() async {
    // first list
    final transactionsJSON = await _client().call('listunspent').catchError(
          (
            err, // can happen on startup
          ) =>
              List.empty(),
        ) as List<dynamic>;

    // then convert to something other than json
    List<UTXO> transactions = transactionsJSON.map((jsonItem) => UTXO.fromMap(jsonItem)).toList();
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
    await _client().call('ping');
  }

  @override
  Future<List<ActiveSidechain>> listActiveSidechains() async {
    final res = await _client().call('listactivesidechains') as List<dynamic>;

    return res.map((s) => ActiveSidechain.fromJson(s)).toList();
  }

  @override
  Future<ActiveSidechain> createSidechainProposal(int slot, String title) async {
    final res = await _client().call('createsidechainproposal', [slot, title]);
    return ActiveSidechain.fromJson(res);
  }

  @override
  Future<List<String>> generate(int blocks) async {
    final res = await _client().call('generate', [blocks]) as List<dynamic>;
    return res.map((e) => e.toString()).toList();
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
