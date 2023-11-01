import 'dart:async';

import 'package:dart_coin_rpc/dart_coin_rpc.dart';
import 'package:dio/dio.dart';
import 'package:sidesail/logger.dart';
import 'package:sidesail/rpc/rpc_config.dart';

abstract class RPC {
  Future<(double, double)> getBalance();
  Future<Map<String, dynamic>> refreshBMM(int bidSatoshis);
  Future<String> generatePegInAddress();
  Future<String> generateSidechainAddress();
  Future<String> getRefundAddress();
  Future<double> estimateSidechainFee();
  Future<String> fetchWithdrawalBundleStatus();
  Future<dynamic> callRAW(String method, [dynamic params]);
}

class RPCLive implements RPC {
  late RPCClient _client;

  RPCLive(Config config) {
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
  Future<(double, double)> getBalance() async {
    final confirmed = await _client.call('getbalance') as double;
    final unconfirmed = await _client.call('getunconfirmedbalance') as double;

    return (confirmed, unconfirmed);
  }

  @override
  Future<Map<String, dynamic>> refreshBMM(int bidSatoshis) async {
    final res = await _client.call('refreshbmm', [bidSatoshis / 100000000]);

    return res;
  }

  @override
  Future<String> generatePegInAddress() async {
    var address = await _client.call('getnewaddress', ['Sidechain Peg In', 'legacy']);

    // This is actually just rather simple stuff. Should be able to
    // do this client side! Just needs the sidechain number, and we're
    // off to the races.
    var formatted = await _client.call('formatdepositaddress', [address as String]);

    return formatted as String;
  }

  @override
  Future<String> generateSidechainAddress() async {
    var address = await _client.call('getnewaddress', ['Sidechain Deposit']);
    return address as String;
  }

  @override
  Future<String> getRefundAddress() async {
    var address = await _client.call('getnewaddress', ['Sidechain Deposit', 'legacy']) as String;
    return address;
  }

  @override
  Future<double> estimateSidechainFee() async {
    final estimate = await _client.call('estimatesmartfee', [6]) as Map<String, dynamic>;
    if (estimate.containsKey('errors')) {
      log.w("could not estimate fee: ${estimate["errors"]}");
      return 0.001;
    }

    final btcPerKb = estimate.containsKey('feerate') ? estimate['feerate'] as double : 0.0001; // 10 sats/byte

    // who knows!
    const kbyteInWithdrawal = 5;
    return btcPerKb * kbyteInWithdrawal;
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
