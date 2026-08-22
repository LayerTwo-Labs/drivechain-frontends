import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sidechain_core/sidechain_core.dart';

/// Regtest and testnet serve no remote chain, so the backend narrows light mode
/// to full there. A provider that keeps the old answer hides the daemons the
/// server just started.
void main() {
  setUp(() async {
    await GetIt.I.reset();
    NetworkScopedRegistry.clearRegistrations();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
  });

  tearDown(() async {
    NetworkScopedRegistry.clearRegistrations();
    await GetIt.I.reset();
  });

  test('a network change re-reads the node mode', () async {
    GetIt.I.registerLazySingleton<NodeModeProvider>(() => NodeModeProvider());
    NetworkScopedRegistry.enrolLazy<NodeModeProvider>();

    final provider = GetIt.I.get<NodeModeProvider>();
    provider.mode = wmpb.NodeMode.NODE_MODE_LIGHT;
    provider.lightModeAvailable = true;

    await NetworkScopedRegistry.clearAll();

    expect(provider.mode, wmpb.NodeMode.NODE_MODE_UNSPECIFIED, reason: 'the stale light answer must not survive');
  });
}
