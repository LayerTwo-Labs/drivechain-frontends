import 'package:dart_coin_rpc/dart_coin_rpc.dart';
import 'package:dio/dio.dart';
import 'package:sail_ui/classes/node_connection_settings.dart';
import 'package:sail_ui/classes/rpc_connection.dart';
import 'package:sail_ui/config/binaries.dart';

/// API to the thunder server.
abstract class ThunderRPC extends RPCConnection {
  ThunderRPC({
    required super.conf,
    required super.binary,
    required super.logPath,
  });
}

class ThunderLive extends ThunderRPC {
  RPCClient _client() {
    final client = RPCClient(
      host: 'localhost',
      port: binary.port,
      username: conf.username,
      password: conf.password,
      useSSL: false,
    );

    // Completely empty client, with no retry logic.
    client.dioClient = Dio();
    return client;
  }

  // Private constructor
  ThunderLive._create({
    required super.conf,
    required super.binary,
    required super.logPath,
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
    );

    await instance._init();
    return instance;
  }

  Future<void> _init() async {
    await testConnection();
  }

  @override
  Future<List<String>> binaryArgs(NodeConnectionSettings mainchainConf) async {
    return [];
  }

  @override
  Future<int> ping() async {
    final balanceSat = await _client().call('balance') as int;
    return balanceSat;
  }

  @override
  Future<void> stop() async {
    await _client().call('stop');
  }
}
