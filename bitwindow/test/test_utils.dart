import 'dart:io';

import 'package:bitwindow/providers/blockchain_provider.dart';
import 'package:bitwindow/providers/news_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/providers/binaries/download_manager.dart';
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

  if (!GetIt.I.isRegistered<BitwindowClientSettings>()) {
    GetIt.I.registerLazySingleton<BitwindowClientSettings>(
      () => BitwindowClientSettings(store: MockStore(), log: log),
    );
  }

  if (!GetIt.I.isRegistered<SettingsProvider>()) {
    final settingsProvider = await SettingsProvider.create();
    GetIt.I.registerLazySingleton<SettingsProvider>(
      () => settingsProvider,
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
      () => MockBinaryProvider(),
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
        binaryType: BinaryType.bitWindow,
        restartOnFailure: true,
      ),
    );
  }

  final balanceProvider = BalanceProvider(
    connections: [
      MockAPI(
        binaryType: BinaryType.bitWindow,
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
          binary: {
            OS.linux: '.mock',
            OS.macos: 'Mock',
            OS.windows: 'Mock',
          },
          flutterFrontend: {
            OS.linux: '',
            OS.macos: '',
            OS.windows: '',
          },
        ),
        metadata: MetadataConfig(
          downloadConfig: DownloadConfig(
            binary: 'mock',
            baseUrl: 'https://mock.test',
            files: {
              OS.linux: 'mock',
              OS.macos: 'mock',
              OS.windows: 'mock',
            },
          ),
          remoteTimestamp: null,
          downloadedTimestamp: null,
          binaryPath: null,
          updateable: false,
        ),
        port: 8272,
        chainLayer: 0,
      );

  @override
  BinaryType get type => BinaryType.testSidechain;

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

class MockBinaryProvider extends BinaryProvider {
  MockBinaryProvider()
    : super.test(
        appDir: Directory('/tmp'),
        downloadManager: MockDownloadManager(),
        processManager: MockProcessManager(),
      );

  @override
  List<Binary> get binaries => [MockBinary()];

  @override
  Directory get appDir => Directory('/tmp');

  @override
  bool get mainchainConnected => true;

  @override
  bool get enforcerConnected => true;

  @override
  bool get bitwindowConnected => true;

  @override
  bool get thunderConnected => false;

  @override
  bool get bitnamesConnected => false;

  @override
  bool get bitassetsConnected => false;

  @override
  bool get zsideConnected => false;

  @override
  bool get mainchainInitializing => false;

  @override
  bool get enforcerInitializing => false;

  @override
  bool get bitwindowInitializing => false;

  @override
  bool get thunderInitializing => false;

  @override
  bool get bitnamesInitializing => false;

  @override
  bool get bitassetsInitializing => false;

  @override
  bool get zsideInitializing => false;

  @override
  bool get mainchainStopping => false;

  @override
  bool get enforcerStopping => false;

  @override
  bool get bitwindowStopping => false;

  @override
  bool get thunderStopping => false;

  @override
  bool get bitnamesStopping => false;

  @override
  bool get bitassetsStopping => false;

  @override
  bool get zsideStopping => false;

  @override
  String? get mainchainError => null;

  @override
  String? get enforcerError => null;

  @override
  String? get bitwindowError => null;

  @override
  String? get thunderError => null;

  @override
  String? get bitnamesError => null;

  @override
  String? get bitassetsError => null;

  @override
  String? get zsideError => null;

  @override
  String? get mainchainStartupError => null;

  @override
  String? get enforcerStartupError => null;

  @override
  String? get bitwindowStartupError => null;

  @override
  String? get thunderStartupError => null;

  @override
  String? get bitnamesStartupError => null;

  @override
  String? get bitassetsStartupError => null;

  @override
  String? get zsideStartupError => null;

  @override
  ExitTuple? exited(Binary binary) => null;

  @override
  Stream<String> stderr(Binary binary) => Stream.empty();

  @override
  void setUseStarter(Binary binary, bool value) {}

  @override
  void addListener(listener) {}

  @override
  void removeListener(listener) {}

  @override
  void notifyListeners() {}

  @override
  bool get hasListeners => false;
}

class MockDownloadManager extends DownloadManager {
  MockDownloadManager()
    : super.test(
        appDir: Directory('/tmp'),
        binaries: [MockBinary()],
      );
}

class MockProcessManager extends ProcessManager {
  MockProcessManager() : super(appDir: Directory('/tmp'));
}
