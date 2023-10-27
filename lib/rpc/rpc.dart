import 'dart:async';

import 'package:dart_coin_rpc/dart_coin_rpc.dart';
import 'package:dio/dio.dart';
import 'package:sidesail/logger.dart';

abstract class RPCBase {}

class RPC implements RPCBase {
  late RPCClient _client;

  RPC() {
    _client = RPCClient(
      host: 'localhost',
      port: 19000,
      username: 'user',
      password: 'password',
      useSSL: false,
    );

    // Completely empty client, with no retry logic.
    _client.dioClient = Dio();
  }

  Future<String> generateDepositAddress() async {
    var address =
        await _client.call('getnewaddress', ['Sidechain Deposit', 'legacy']);

    // This is actually just rather simple stuff. Should be able to
    // do this client side! Just needs the sidechain number, and we're
    // off to the races.
    var formatted =
        await _client.call('formatdepositaddress', [address as String]);

    return formatted as String;
  }

  Future<String> fetchWithdrawalBundleStatus() async {
    try {
      final status = await _client.call('getwithdrawalbundle', []);

      log.i(
        'fetched withdrawal bundle status: no clue what happens now',
        error: status,
      );
      return status.toString();
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

  Future<dynamic> callRAW(String method, [dynamic params]) async {
    return _client.call(method, params).catchError((err) {
      log.t('rpc: $method threw exception: $err');
      throw err;
    });
  }
}

abstract class RPCError {
  static const errNoWithdrawalBundle = -100;
  static const errWithdrawalNotFound = -101;
}
