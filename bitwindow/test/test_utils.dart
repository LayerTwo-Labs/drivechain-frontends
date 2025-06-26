import 'dart:io';

import 'package:bitwindow/providers/blockchain_provider.dart';
import 'package:bitwindow/providers/news_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

import 'mocks/api_mock.dart';
import 'mocks/store_mock.dart';

Future<void> _setDeviceSize() async {
  final TestWidgetsFlutterBinding binding = TestWidgetsFlutterBinding.ensureInitialized();
  await binding.setSurfaceSize(const Size(1200, 720));
}

extension TestExtension on WidgetTester {
  Future<void> pumpSailPage(
    Widget child,
  ) async {
    await _setDeviceSize();
    await registerTestDependencies();

    await pumpWidget(
      SailApp(
        dense: false,
        builder: (context) {
          return MaterialApp(home: SailTestPage(child: child));
        },
        initMethod: (_) async => (),
        accentColor: SailColorScheme.black,
        log: GetIt.I.get<Logger>(),
      ),
      duration: const Duration(seconds: 10),
    );
    await pump();
  }
}

Future<void> registerTestDependencies() async {
  final log = Logger();
  if (!GetIt.I.isRegistered<Logger>()) {
    GetIt.I.registerLazySingleton<Logger>(() => log);
  }

  if (!GetIt.I.isRegistered<ClientSettings>()) {
    GetIt.I.registerLazySingleton<ClientSettings>(
      () => ClientSettings(store: MockStore(), log: log),
    );
  }

  if (!GetIt.I.isRegistered<NewsProvider>()) {
    GetIt.I.registerLazySingleton<NewsProvider>(
      () => NewsProvider(),
    );
  }

  if (!GetIt.I.isRegistered<MainchainRPC>()) {
    GetIt.I.registerLazySingleton<MainchainRPC>(
      () => MockMainchainRPC(),
    );
  }

  if (!GetIt.I.isRegistered<EnforcerRPC>()) {
    GetIt.I.registerLazySingleton<EnforcerRPC>(
      () => MockEnforcerRPC(),
    );
  }

  if (!GetIt.I.isRegistered<BinaryProvider>()) {
    GetIt.I.registerLazySingleton<BinaryProvider>(
      () => BinaryProvider(appDir: Directory('/'), initialBinaries: []),
    );
  }

  if (!GetIt.I.isRegistered<SyncProvider>()) {
    GetIt.I.registerLazySingleton<SyncProvider>(
      () => SyncProvider(),
    );
  }

  if (!GetIt.I.isRegistered<BitwindowRPC>()) {
    GetIt.I.registerLazySingleton<BitwindowRPC>(
      () => MockAPI(
        conf: NodeConnectionSettings.empty(),
        binary: MockBinary(),
        restartOnFailure: true,
      ),
    );
  }

  final balanceProvider = BalanceProvider(
    connections: [
      MockAPI(
        conf: NodeConnectionSettings.empty(),
        binary: MockBinary(),
        restartOnFailure: true,
      ),
    ],
  );
  GetIt.I.registerLazySingleton<BalanceProvider>(
    () => balanceProvider,
  );

  if (!GetIt.I.isRegistered<BlockchainProvider>()) {
    GetIt.I.registerLazySingleton<BlockchainProvider>(
      () => BlockchainProvider(),
    );
  }
}

class SailTestPage extends StatelessWidget {
  final Widget child;
  const SailTestPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class MockBinary extends Binary {
  MockBinary()
      : super(
          name: 'Mocktown',
          version: '0.0.0',
          description: 'Mock Binary',
          repoUrl: 'https://mock.test',
          directories: DirectoryConfig(
            base: {
              OS.linux: '.mock',
              OS.macos: 'Mock',
              OS.windows: 'Mock',
            },
          ),
          metadata: MetadataConfig(
            baseUrl: 'https://mock.test',
            files: {
              OS.linux: 'mock',
              OS.macos: 'mock',
              OS.windows: 'mock',
            },
            remoteTimestamp: null,
            downloadedTimestamp: null,
            binaryPath: null,
            updateable: false,
          ),
          binary: 'mock',
          port: 8272,
          chainLayer: 0,
        );

  @override
  Color get color => SailColorScheme.orange;

  @override
  Binary copyWith({
    String? version,
    String? description,
    String? repoUrl,
    DirectoryConfig? directories,
    MetadataConfig? metadata,
    String? binary,
    int? port,
    int? chainLayer,
    String? walletFile,
    DownloadInfo? downloadInfo,
  }) {
    return MockBinary();
  }
}
