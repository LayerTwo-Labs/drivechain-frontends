import 'package:dart_coin_rpc/dart_coin_rpc.dart';
import 'package:dio/dio.dart';
import 'package:sidesail/rpc/rpc_config.dart';

/// RPC connection to the mainchain node.
abstract class MainchainRPC {
  Future<double> estimateFee();
}

class MainchainRPCLive implements MainchainRPC {
  late RPCClient _client;
  MainchainRPCLive(Config config) {
    _client = RPCClient(
      host: config.host,
      port: config.port,
      username: config.username,
      password: config.password,
      useSSL: false,
    );

    // Completely empty client, with no retry logic.
    _client.dioClient = Dio();
  }

  @override
  Future<double> estimateFee() async {
    final estimate = await _client.call('estimatesmartfee', [6]) as Map<String, dynamic>;
    if (estimate.containsKey('errors')) {
      // 10 sats/byte
      return 0.001;
    }

    final btcPerKb = estimate['feerate'] as double;

    // who knows!
    const kbyteInTx = 5;
    return btcPerKb * kbyteInTx;
  }
}
