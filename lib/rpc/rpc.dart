import 'dart:async';

import 'package:dart_coin_rpc/dart_coin_rpc.dart';
import 'package:dio/dio.dart';
import 'package:sidesail/logger.dart';

abstract class RPC {
  Future<double> getBalance();
  Future<Map<String, dynamic>> refreshBMM(int bidSatoshis);
  Future<String> generateDepositAddress();
  Future<String> fetchWithdrawalBundleStatus();
  Future<dynamic> callRAW(String method, [dynamic params]);
}

class RPCLive implements RPC {
  late RPCClient _client;

  RPCLive() {
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

  @override
  Future<double> getBalance() async {
    return await _client.call('getbalance') as double;
  }

  @override
  Future<Map<String, dynamic>> refreshBMM(int bidSatoshis) async {
    final res = await _client.call('refreshbmm', [bidSatoshis / 100000000]);

    return res;
  }

  @override
  Future<String> generateDepositAddress() async {
    var address = await _client.call('getnewaddress', ['Sidechain Deposit', 'legacy']);

    // This is actually just rather simple stuff. Should be able to
    // do this client side! Just needs the sidechain number, and we're
    // off to the races.
    var formatted = await _client.call('formatdepositaddress', [address as String]);

    return formatted as String;
  }

  @override
  Future<String> fetchWithdrawalBundleStatus() async {
    try {
      // TODO: do something meaningful with this, we would need it decoded
      // with bitcoin core.
      // BtcTransaction.fromRaw crashes...
      final bundleHex = await _client.call('getwithdrawalbundle', []);

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
