import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

import 'package:dart_coin_rpc/dart_coin_rpc.dart';

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
  }

  Future<dynamic> call(String method, [dynamic params]) async {
    var fut = _client.call(method, params).then(
      (value) {
        switch (value.runtimeType) {
          case String:
            return value as String;

          case Double:
            return value.toString();

          default:
            print("rpc call: $method: idk: ${value.runtimeType}");
            return value;
        }
      },
    );

    // By default there's retry logic in place for the HTTP client (Dio) used
    // by the library. This logic is not configurable. Ideally we should open a
    // PR in the lib/fork it. Workaround is to wrap this is in a future that
    // times out after a reasonable time.
    // TODO: make this configurable per rpc.
    return _withTimeout(method, fut, const Duration(seconds: 1));
  }
}

Future<T> _withTimeout<T>(String method, Future<T> future, Duration timeout) {
  return future.timeout(
    timeout,
    onTimeout: () => throw TimeoutException('$method timed out', timeout),
  );
}
