import 'dart:convert';

import 'package:bitwindow/sol/sol_rpc.dart';
import 'package:bitwindow/sol/sol_wallet.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

SolRPC rpcThatAnswers(Object? body, {int status = 200, List<Map<String, Object?>>? seen}) {
  final client = MockClient((request) async {
    seen?.add(jsonDecode(request.body) as Map<String, Object?>);
    return http.Response(body is String ? body : jsonEncode(body), status);
  });
  return SolRPC(client: client, url: 'http://example.invalid/sol/');
}

/// The host prefix that each eCash generation serves from.
const generationHost = {'alphanet': 'seed.alpha.', 'betanet': 'seed.beta.', 'ecash': 'seed.ecash.'};

void main() {
  group('solRpcUrl', () {
    test('the host names the generation that the chain pegs to', () {
      expect(solRpcUrl, contains(generationHost[solEcashNetworkId]!));
    });

    test('the url names the sol path', () {
      expect(solRpcUrl, endsWith('/sol/'));
    });
  });

  group('getBalanceLamports', () {
    test('reads the lamport count', () async {
      final rpc = rpcThatAnswers({
        'jsonrpc': '2.0',
        'id': 1,
        'result': {
          'context': {'slot': 42},
          'value': 50000000,
        },
      });
      expect(await rpc.getBalanceLamports('HAgk'), 50000000);
    });

    test('sends the address as the one parameter', () async {
      final seen = <Map<String, Object?>>[];
      final rpc = rpcThatAnswers({
        'jsonrpc': '2.0',
        'id': 1,
        'result': {'value': 0},
      }, seen: seen);
      await rpc.getBalanceLamports('HAgk');
      expect(seen.single['method'], 'getBalance');
      expect(seen.single['params'], ['HAgk']);
    });

    test('an rpc error becomes an exception', () async {
      final rpc = rpcThatAnswers({
        'jsonrpc': '2.0',
        'id': 1,
        'error': {'code': -32602, 'message': 'Invalid param'},
      });
      expect(
        () => rpc.getBalanceLamports('nope'),
        throwsA(isA<SolRpcException>().having((e) => e.message, 'message', contains('Invalid param'))),
      );
    });

    test('a result without a value becomes an exception', () async {
      final rpc = rpcThatAnswers({'jsonrpc': '2.0', 'id': 1, 'result': {}});
      expect(() => rpc.getBalanceLamports('HAgk'), throwsA(isA<SolRpcException>()));
    });

    test('a non-200 answer becomes an exception', () async {
      final rpc = rpcThatAnswers('nope', status: 502);
      expect(
        () => rpc.getBalanceLamports('HAgk'),
        throwsA(isA<SolRpcException>().having((e) => e.message, 'message', contains('502'))),
      );
    });

    test('a body that is no JSON becomes an exception', () async {
      final rpc = rpcThatAnswers('<html>down</html>');
      expect(() => rpc.getBalanceLamports('HAgk'), throwsA(isA<SolRpcException>()));
    });
  });

  group('getBlockHeight', () {
    test('reads the height', () async {
      final rpc = rpcThatAnswers({'jsonrpc': '2.0', 'id': 1, 'result': 1234});
      expect(await rpc.getBlockHeight(), 1234);
    });

    test('a missing result becomes an exception', () async {
      final rpc = rpcThatAnswers({'jsonrpc': '2.0', 'id': 1});
      expect(() => rpc.getBlockHeight(), throwsA(isA<SolRpcException>()));
    });
  });
}
