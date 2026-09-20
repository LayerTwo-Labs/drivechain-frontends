import 'dart:convert';

import 'package:http/http.dart' as http;

/// The hosted Solana RPC of the SOL drivechain.
///
/// The host names the eCash generation that the chain pegs to, the way every
/// other seed host does. BitWindow starts no SOL daemon, so it reads the
/// chain from this server.
const String solRpcUrl = 'https://seed.beta.ecash.eu.com/sol/';

class SolRpcException implements Exception {
  SolRpcException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// A read-only client of the SOL drivechain.
///
/// It signs nothing and it holds no key. A peg out, a send and a transaction
/// history belong to a Solana wallet, not to BitWindow.
class SolRPC {
  SolRPC({http.Client? client, this.url = solRpcUrl}) : _client = client ?? http.Client();

  final http.Client _client;
  final String url;

  /// The lamport count of one address.
  Future<int> getBalanceLamports(String address) async {
    final result = await _call('getBalance', [address]);
    if (result is! Map || result['value'] is! int) {
      throw SolRpcException('getBalance gave no lamport count');
    }
    return result['value'] as int;
  }

  /// The height of the chain.
  Future<int> getBlockHeight() async {
    final result = await _call('getBlockHeight', []);
    if (result is! int) {
      throw SolRpcException('getBlockHeight gave no number');
    }
    return result;
  }

  void close() => _client.close();

  Future<Object?> _call(String method, List<Object?> params) async {
    final http.Response response;
    try {
      response = await _client.post(
        Uri.parse(url),
        headers: const {'content-type': 'application/json'},
        body: jsonEncode({'jsonrpc': '2.0', 'id': 1, 'method': method, 'params': params}),
      );
    } catch (e) {
      throw SolRpcException('could not reach the SOL rpc: $e');
    }

    if (response.statusCode != 200) {
      throw SolRpcException('the SOL rpc answered ${response.statusCode}');
    }

    final Object? body;
    try {
      body = jsonDecode(response.body);
    } catch (e) {
      throw SolRpcException('the SOL rpc answered no JSON: $e');
    }

    if (body is! Map<String, dynamic>) {
      throw SolRpcException('the SOL rpc answered no JSON-RPC object');
    }
    final error = body['error'];
    if (error != null) {
      throw SolRpcException('$method failed: ${error is Map ? error['message'] : error}');
    }
    if (!body.containsKey('result')) {
      throw SolRpcException('$method gave no result');
    }
    return body['result'];
  }
}
