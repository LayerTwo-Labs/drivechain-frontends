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

  Future<void> setSeedFromMnemonic(String mnemonic);
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
    return [];
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
  }

  @override
  Future<void> setSeedFromMnemonic(String mnemonic) async {
    try {
      await binary.wipeWallet(); // Use the built-in wipeWallet function

      // Try to set the seed multiple times
      int setSeedRetries = 0;
      const maxSetSeedRetries = 5;
      const setSeedRetryDelay = Duration(milliseconds: 500);
      Exception? lastError;

      while (setSeedRetries < maxSetSeedRetries) {
        try {
          await _client().call('set_seed_from_mnemonic', [mnemonic]);
          break;
        } catch (e) {
          lastError = Exception(e.toString());
          setSeedRetries++;
          if (setSeedRetries == maxSetSeedRetries) {
            throw lastError;
          }
          await Future.delayed(setSeedRetryDelay);
        }
      }

      // Verify the seed was set by checking if we can get a balance
      int retries = 0;
      const maxRetries = 20;
      const retryDelay = Duration(seconds: 2);

      while (retries < maxRetries) {
        try {
          await _client().call('balance');
          return;
        } catch (e) {
          if (e.toString().contains("wallet doesn't have a seed")) {
            retries++;
            await Future.delayed(retryDelay);
            continue;
          }
          rethrow;
        }
      }
      throw Exception('Failed to verify wallet was ready after $maxRetries attempts');
    } catch (e) {
      log.e('Error setting Bitnames seed', error: e);
      rethrow;
    }
  }
}
