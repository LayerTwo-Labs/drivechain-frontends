// The card asserts its way out of a debug build when a button carries an icon
// on a variant that demands a label. Nothing built the card before, so that
// crash reached review instead of the suite.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

class _FakeConnection extends RPCConnection {
  _FakeConnection({required super.binaryType});

  @override
  Future<List<String>> binaryArgs() async => [];

  @override
  Future<void> stopRPC() async {}

  @override
  Future<(double, double)> balance() async => (0.0, 0.0);

  @override
  Future<BlockchainInfo> getBlockchainInfo() async => BlockchainInfo(
    chain: 'signet',
    blocks: 0,
    headers: 0,
    bestBlockHash: '',
    difficulty: 0,
    time: 0,
    medianTime: 0,
    verificationProgress: 0,
    initialBlockDownload: false,
    chainWork: '',
    sizeOnDisk: 0,
    pruned: false,
    warnings: const [],
  );
}

class _FakeConf extends ChangeNotifier implements BitcoinConfProvider {
  @override
  BitcoinNetwork network = BitcoinNetwork.BITCOIN_NETWORK_SIGNET;

  @override
  Future<void> loadConfig({bool isFirst = false, bool userInitiated = false}) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _Store implements KeyValueStore {
  final _db = <String, String>{};

  @override
  Future<String?> getString(String key) async => _db[key];

  @override
  Future<void> setString(String key, String value) async => _db[key] = value;

  @override
  Future<void> delete(String key) async => _db.remove(key);
}

void main() {
  late _FakeConnection connection;

  setUpAll(() => TestWidgetsFlutterBinding.ensureInitialized());

  setUp(() async {
    final getIt = GetIt.instance;
    await getIt.reset();

    final log = Logger(level: Level.off);
    getIt.registerSingleton<Logger>(log);
    getIt.registerSingleton<ClientSettings>(ClientSettings(store: _Store(), log: log));
    getIt.registerSingleton<BitwindowClientSettings>(BitwindowClientSettings(store: _Store(), log: log));
    getIt.registerSingleton<SettingsProvider>(await SettingsProvider.create());
    getIt.registerSingleton<BinaryProvider>(
      BinaryProvider.test(appDir: Directory.systemTemp, binaries: [BitcoinCore(), Enforcer()]),
    );
    getIt.registerSingleton<LogProvider>(LogProvider());
    getIt.registerSingleton<BitcoinConfProvider>(_FakeConf());

    connection = _FakeConnection(binaryType: BinaryType.BINARY_TYPE_BITCOIND);
  });

  tearDown(() async => GetIt.instance.reset());

  Widget wrap(Widget child) => MaterialApp(
    home: SailTheme(
      data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
      child: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: 900, child: child),
        ),
      ),
    ),
  );

  Widget card() => DaemonConnectionCard(
    connection: connection,
    syncInfo: null,
    infoMessage: null,
    restartDaemon: () async {},
    stopDaemon: () async {},
    navigateToLogs: (_, _, _) {},
  );

  testWidgets('a stopped daemon builds with no assert', (tester) async {
    await tester.pumpWidget(wrap(card()));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Start'), findsWidgets);
  });

  testWidgets('a connected daemon builds and offers Stop', (tester) async {
    connection.connected = true;

    await tester.pumpWidget(wrap(card()));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Stop'), findsWidgets);
  });

  testWidgets('a daemon that errors builds and keeps its height', (tester) async {
    await tester.pumpWidget(wrap(card()));
    await tester.pump();
    final quiet = tester.getSize(find.byType(DaemonConnectionCard));

    connection.connectionError = 'Error:  × block producer mempool task failed\n  └─▶ mempool initial sync error';
    connection.markStateChanged();
    await tester.pumpWidget(wrap(card()));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(DaemonConnectionCard)).height, quiet.height);
  });
}
