import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:protobuf/protobuf.dart';
import 'package:sidechain_core/gen/bitassets/v1/bitassets.pb.dart' as bitassets;
import 'package:sidechain_core/gen/bitnames/v1/bitnames.pb.dart' as bitnames;
import 'package:sidechain_core/gen/coinshift/v1/coinshift.pb.dart' as coinshift;
import 'package:sidechain_core/gen/photon/v1/photon.pb.dart' as photon;
import 'package:sidechain_core/gen/thunder/v1/thunder.pb.dart' as thunder;
import 'package:sidechain_core/gen/truthcoin/v1/truthcoin.pb.dart' as truthcoin;
import 'package:sidechain_core/rpcs/bitassets_rpc.dart';
import 'package:sidechain_core/rpcs/bitnames_rpc.dart';
import 'package:sidechain_core/rpcs/coinshift_rpc.dart';
import 'package:sidechain_core/rpcs/photon_rpc.dart';
import 'package:sidechain_core/rpcs/rpc_sidechain.dart';
import 'package:sidechain_core/rpcs/thunder_rpc.dart';
import 'package:sidechain_core/rpcs/truthcoin_rpc.dart';
import 'package:sidechain_core/settings/client_settings.dart';
import 'package:sidechain_core/settings/secure_store.dart';

class _Store implements KeyValueStore {
  @override
  Future<String?> getString(String key) async => null;

  @override
  Future<void> setString(String key, String value) async {}

  @override
  Future<void> delete(String key) async {}

  @override
  Future<void> update(String key, String Function(String? current) change) async {
    await setString(key, change(await getString(key)));
  }
}

Future<PendingWithdrawalBundle?> _readBundle(
  GeneratedMessage response,
  Future<PendingWithdrawalBundle?> Function() read,
) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  addTearDown(() => server.close(force: true));
  server.listen((request) async {
    await request.drain<void>();
    request.response.headers.contentType = ContentType('application', 'proto');
    request.response.add(response.writeToBuffer());
    await request.response.close();
  });
  final client = HttpClient()..findProxy = (_) => 'PROXY 127.0.0.1:${server.port}';
  addTearDown(() => client.close(force: true));

  return HttpOverrides.runZoned(read, createHttpClient: (_) => client);
}

void main() {
  setUp(() {
    final log = Logger(level: Level.off);
    GetIt.I.registerSingleton<Logger>(log);
    GetIt.I.registerSingleton<ClientSettings>(ClientSettings(store: _Store(), log: log));
    GetIt.I.registerSingleton<BitwindowClientSettings>(BitwindowClientSettings(store: _Store(), log: log));
  });

  tearDown(GetIt.I.reset);

  test('thunder reads a null pending withdrawal bundle', () async {
    final bundle = await _readBundle(
      thunder.GetPendingWithdrawalBundleResponse(bundleJson: 'null'),
      () => ThunderLive().getPendingWithdrawalBundle(),
    );
    expect(bundle, isNull);
  });

  test('bitnames reads a null pending withdrawal bundle', () async {
    final bundle = await _readBundle(
      bitnames.GetPendingWithdrawalBundleResponse(bundleJson: 'null'),
      () => BitnamesLive().getPendingWithdrawalBundle(),
    );
    expect(bundle, isNull);
  });

  test('bitassets reads a null pending withdrawal bundle', () async {
    final bundle = await _readBundle(
      bitassets.GetPendingWithdrawalBundleResponse(bundleJson: 'null'),
      () => BitAssetsLive().getPendingWithdrawalBundle(),
    );
    expect(bundle, isNull);
  });

  test('photon reads a null pending withdrawal bundle', () async {
    final bundle = await _readBundle(
      photon.GetPendingWithdrawalBundleResponse(bundleJson: 'null'),
      () => PhotonLive().getPendingWithdrawalBundle(),
    );
    expect(bundle, isNull);
  });

  test('coinshift reads a null pending withdrawal bundle', () async {
    final bundle = await _readBundle(
      coinshift.GetPendingWithdrawalBundleResponse(bundleJson: 'null'),
      () => CoinShiftLive().getPendingWithdrawalBundle(),
    );
    expect(bundle, isNull);
  });

  test('truthcoin reads a null pending withdrawal bundle', () async {
    final bundle = await _readBundle(
      truthcoin.GetPendingWithdrawalBundleResponse(bundleJson: 'null'),
      () => TruthcoinLive().getPendingWithdrawalBundle(),
    );
    expect(bundle, isNull);
  });
}
