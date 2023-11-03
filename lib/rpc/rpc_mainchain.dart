import 'dart:async';

import 'package:dart_coin_rpc/dart_coin_rpc.dart';
import 'package:dio/dio.dart';
import 'package:sidesail/pages/tabs/settings_tab.dart';
import 'package:sidesail/rpc/rpc.dart';
import 'package:sidesail/rpc/rpc_config.dart';

/// RPC connection to the mainchain node.
abstract class MainchainRPC extends RPCConnection {
  Future<double> estimateFee();
}

class MainchainRPCLive extends MainchainRPC {
  RPCClient? _client;

  // responsible for pinging the node every x seconds,
  // so we can update the UI immediately when the values change
  Timer? _connectionTimer;

  // hacky way to create an async class
  // https://stackoverflow.com/a/59304510
  MainchainRPCLive._create();

  static Future<MainchainRPCLive> create() async {
    final rpc = MainchainRPCLive._create();
    await rpc._init();
    return rpc;
  }

  Future<void> _init() async {
    final config = await readRpcConfig(mainchainDatadir(), 'drivechain.conf');
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

    // could connect, aaand we start polling!
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
  Future<void> ping() async {
    await _client?.call('ping') as Map<String, dynamic>?;
  }

  @override
  void dispose() {
    _connectionTimer?.cancel();
    super.dispose();
  }
}
