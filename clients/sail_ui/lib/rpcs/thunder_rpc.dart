import 'package:dart_coin_rpc/dart_coin_rpc.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/bitcoin.dart';
import 'package:sail_ui/classes/node_connection_settings.dart';
import 'package:sail_ui/classes/rpc_connection.dart';
import 'package:sail_ui/config/binaries.dart';

final log = GetIt.I.get<Logger>();

/// API to the thunder server.
abstract class ThunderRPC extends RPCConnection {
  ThunderRPC({
    required super.conf,
    required super.binary,
    required super.logPath,
    required super.restartOnFailure,
  });
}

class ThunderLive extends ThunderRPC {
  RPCClient _client() {
    final client = RPCClient(
      host: '127.0.0.1',
      port: binary.port,
      username: conf.username,
      password: conf.password,
      useSSL: false,
    );

    client.dioClient = Dio();
    return client;
  }

  // Private constructor
  ThunderLive._create({
    required super.conf,
    required super.binary,
    required super.logPath,
    required super.restartOnFailure,
  });

  // Async factory
  static Future<ThunderLive> create({
    required Binary binary,
    required String logPath,
  }) async {
    final conf = await getMainchainConf();

    final instance = ThunderLive._create(
      conf: conf,
      binary: binary,
      logPath: logPath,
      restartOnFailure: false,
    );

    await instance._init();
    return instance;
  }

  Future<void> _init() async {
    await startConnectionTimer();
  }

  @override
  Future<List<String>> binaryArgs(NodeConnectionSettings mainchainConf) async {
    final args = <String>[];

    if (binary.mnemonicSeedPhrasePath != null) {
      args.addAll(['--mnemonic-seed-phrase-path', binary.mnemonicSeedPhrasePath!]);
    }

    return args;
  }

  @override
  Future<int> ping() async {
    final response = await _client().call('balance') as Map<String, dynamic>;
    return response['total_sats'] as int;
  }

  @override
  Future<(double, double)> balance() async {
    final response = await _client().call('balance') as Map<String, dynamic>;
    final totalSats = response['total_sats'] as int;
    final availableSats = response['available_sats'] as int;

    // Convert from sats to BTC
    final confirmed = satoshiToBTC(availableSats);
    final unconfirmed = satoshiToBTC(totalSats - availableSats);

    return (confirmed, unconfirmed);
  }

  @override
  Future<void> stopRPC() async {
    await _client().call('stop');
    // can't trust the rpc, give it a moment to stop
    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  Future<BlockchainInfo> getBlockchainInfo() async {
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
}
