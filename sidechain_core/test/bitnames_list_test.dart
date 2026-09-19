import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/gen/bitnames/v1/bitnames.pb.dart';
import 'package:sidechain_core/rpcs/bitnames_rpc.dart';
import 'package:sidechain_core/settings/client_settings.dart';
import 'package:sidechain_core/settings/secure_store.dart';

class _Store implements KeyValueStore {
  @override
  Future<String?> getString(String key) async => null;

  @override
  Future<void> setString(String key, String value) async {}

  @override
  Future<void> delete(String key) async {}
}

void main() {
  test('the live client reads the alphanet list response', () async {
    final log = Logger();
    GetIt.I.registerSingleton<Logger>(log);
    GetIt.I.registerSingleton<ClientSettings>(ClientSettings(store: _Store(), log: log));
    GetIt.I.registerSingleton<BitwindowClientSettings>(BitwindowClientSettings(store: _Store(), log: log));
    addTearDown(GetIt.I.reset);

    final fixture = jsonDecode(await File('test/fixtures/alphanet_bitnames.json').readAsString());
    final response = ListBitNamesResponse(bitnamesJson: fixture['bitnamesJson'] as String);
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    final paths = <String>[];
    server.listen((request) async {
      paths.add(request.uri.path);
      await request.drain<void>();
      request.response.headers.contentType = ContentType('application', 'proto');
      request.response.add(response.writeToBuffer());
      await request.response.close();
    });
    final client = HttpClient()..findProxy = (_) => 'PROXY 127.0.0.1:${server.port}';
    addTearDown(() => client.close(force: true));

    final entries = await HttpOverrides.runZoned(
      () => BitnamesLive().listBitNames(),
      createHttpClient: (_) => client,
    );

    expect(paths, ['/bitnames.v1.BitnamesService/ListBitNames']);
    expect(entries, hasLength(3));
    expect(entries[0].details.seqId, '1739-0029');
    expect(entries[0].details.commitment, isNull);
    expect(entries[1].details.commitment, '34cc446b27c0fd42d572bb1d30e00beb3e74c19edea2c6f2c0241da40637196e');
    expect(entries[1].details.socketAddrV4, '204.168.254.113:6002');
    expect(entries[1].details.paymailFeeSats, 1000);
    expect(entries[2].details.seqId, '1739-0129');
  });
}
