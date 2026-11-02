import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sidechain_core/mocks/mocks.dart';
import 'package:sidechain_core/sidechain_core.dart';

class _Conf extends ChangeNotifier implements BitcoinConfProvider {
  @override
  BitcoinNetwork network = BitcoinNetwork.BITCOIN_NETWORK_SIGNET;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<int?> _fetch(MockClient client) =>
    http.runWithClient(() => MockThunderRPC().fetchExplorerHeaders(), () => client);

void main() {
  setUp(() => GetIt.I.registerSingleton<BitcoinConfProvider>(_Conf()));
  tearDown(() => GetIt.I.reset());

  test('posts an empty JSON body to the chain tips route and reads the height', () async {
    late http.Request sent;
    final height = await _fetch(
      MockClient((request) async {
        sent = request;
        return http.Response(
          jsonEncode({
            'thunder': {'height': 4321},
          }),
          200,
        );
      }),
    );

    expect(height, 4321);
    expect(sent.method, 'POST');
    expect(sent.url.toString(), 'https://node.signet.drivechain.info/api/explorer.v1.ExplorerService/GetChainTips');
    expect(sent.headers['Content-Type'], startsWith('application/json'));
    expect(sent.body, '{}');
  });

  test('reads a height sent as a string', () async {
    final height = await _fetch(MockClient((_) async => http.Response('{"thunder":{"height":"77"}}', 200)));
    expect(height, 77);
  });

  test('gives null when the chain is not in the reply', () async {
    final height = await _fetch(MockClient((_) async => http.Response('{"bitnames":{"height":5}}', 200)));
    expect(height, isNull);
  });

  test('gives null for a status outside 2xx', () async {
    final height = await _fetch(MockClient((_) async => http.Response('{"thunder":{"height":5}}', 503)));
    expect(height, isNull);
  });

  test('gives null for a body that is not JSON', () async {
    final height = await _fetch(MockClient((_) async => http.Response('<html>', 200)));
    expect(height, isNull);
  });

  test('gives null when the request fails', () async {
    final height = await _fetch(MockClient((_) async => throw http.ClientException('offline')));
    expect(height, isNull);
  });
}
