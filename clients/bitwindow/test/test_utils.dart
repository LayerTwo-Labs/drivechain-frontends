import 'package:bitwindow/providers/balance_provider.dart';
import 'package:bitwindow/providers/blockchain_provider.dart';
import 'package:bitwindow/servers/api.dart';
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
    );
    await pumpAndSettle();
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

  if (!GetIt.I.isRegistered<API>()) {
    GetIt.I.registerLazySingleton<API>(
      () => MockAPI(conf: NodeConnectionSettings.empty()),
    );
  }

  if (!GetIt.I.isRegistered<BalanceProvider>()) {
    GetIt.I.registerLazySingleton<BalanceProvider>(
      () => BalanceProvider(),
    );
  }

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
