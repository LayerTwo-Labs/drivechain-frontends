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
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeConf extends ChangeNotifier implements BitcoinConfProvider {
  @override
  BitcoinNetwork network = BitcoinNetwork.BITCOIN_NETWORK_SIGNET;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeEnforcerConf extends ChangeNotifier implements EnforcerConfProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  setUp(() async {
    final getIt = GetIt.instance;
    await getIt.reset();
    getIt.registerSingleton<Logger>(Logger(level: Level.off));
    getIt.registerSingleton<BitcoinConfProvider>(_FakeConf());
    getIt.registerSingleton<EnforcerConfProvider>(_FakeEnforcerConf());
    getIt.registerSingleton<BinaryProvider>(
      BinaryProvider.test(appDir: Directory.systemTemp, binaries: [BitcoinCore(), Enforcer()]),
    );
  });

  tearDown(() async => GetIt.instance.reset());

  testWidgets('the footer offers to open the configurator', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: SailTheme(
          data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
          child: Scaffold(
            body: ChainSettingsModal(
              connection: _FakeConnection(binaryType: BinaryType.BINARY_TYPE_BITCOIND),
              onOpenConfConfigurator: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Open configurator'), findsWidgets);
    expect(find.text('Open conf configurator'), findsNothing);
  });

  Future<void> pumpEnforcer(WidgetTester tester, {required bool remote}) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: SailTheme(
          data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
          child: Scaffold(
            body: ChainSettingsModal(
              connection: _FakeConnection(binaryType: BinaryType.BINARY_TYPE_ENFORCER),
              remote: remote,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('a remote enforcer shows no local binary', (tester) async {
    await pumpEnforcer(tester, remote: true);

    expect(find.text('Remote validator'), findsOneWidget);
    expect(find.text('Repository'), findsOneWidget);
    expect(find.text('Version'), findsNothing);
    expect(find.text('Installed at'), findsNothing);
    expect(find.text('Download file'), findsNothing);
    expect(find.text('Paths'), findsNothing);
    expect(find.text('Wipe and reinstall'), findsNothing);
  });

  testWidgets('a local enforcer shows its binary', (tester) async {
    await pumpEnforcer(tester, remote: false);

    expect(find.text('Remote validator'), findsNothing);
    expect(find.text('Version'), findsOneWidget);
    expect(find.text('Installed at'), findsOneWidget);
    expect(find.text('Paths'), findsOneWidget);
    expect(find.text('Wipe and reinstall'), findsWidgets);
  });
}
