import 'package:dart_coin_rpc/dart_coin_rpc.dart';
import 'package:dio/dio.dart';
import 'package:sail_ui/bitcoin.dart';
import 'package:sail_ui/classes/node_connection_settings.dart';
import 'package:sail_ui/classes/rpc_connection.dart';
import 'package:sail_ui/config/binaries.dart';

/// API to the bitnames server.
abstract class BitnamesRPC extends RPCConnection {
  BitnamesRPC({
    required super.conf,
    required super.binary,
    required super.logPath,
  });
}

class BitnamesLive extends BitnamesRPC {
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
  BitnamesLive._create({
    required super.conf,
    required super.binary,
    required super.logPath,
  });

  // Async factory
  static Future<BitnamesLive> create({
    required Binary binary,
    required String logPath,
  }) async {
    final conf = await getMainchainConf();

    final instance = BitnamesLive._create(
      conf: conf,
      binary: binary,
      logPath: logPath,
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
  Future<(double confirmed, double unconfirmed)> balance() async {
    final response = await _client().call('balance') as Map<String, dynamic>;
    final totalSats = response['total_sats'] as int;
    final availableSats = response['available_sats'] as int;

    final confirmed = satoshiToBTC(availableSats);
    final unconfirmed = satoshiToBTC(totalSats - availableSats);

    return (confirmed, unconfirmed);
  }

  @override
  Future<void> stopRPC() async {
    await _client().call('stop');
    // can't trust the rpc, give it a moment to stop
    await Future.delayed(const Duration(seconds: 5));
  }
}
