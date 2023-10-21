import 'dart:async';

import 'package:dart_coin_rpc/dart_coin_rpc.dart';
import 'package:dio/dio.dart';
import 'package:sidesail/logger.dart';

final rpc = _Rpc();

class _Rpc {
  late RPCClient _client;

  _Rpc() {
    _client = RPCClient(
      host: "localhost",
      port: 19000,
      username: "user",
      password: "password",
      useSSL: false,
    );

    // Completely empty client, with no retry logic.
    _client.dioClient = Dio();
  }

  Future<dynamic> call(String method, [dynamic params]) async {
    return _client.call(method, params).catchError((err) {
      log.e("rpc: $method threw exception: $err");
      throw err;
    });
  }
}

const errNoWithdrawalBundle = -100;
