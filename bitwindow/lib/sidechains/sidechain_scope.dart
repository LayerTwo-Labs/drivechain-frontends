import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/shell/shell.dart';

// GetIt refuses a scope change while another scope is still in its async init.
final _scopeOps = SerialQueue();

String sidechainScopeName(SidechainModule module) => 'sidechain-${module.chain.registryKey}';

/// Registers what the pages of [module] read, in a GetIt scope of its own.
/// BitWindow keeps its own instances of the shared types, so its chrome does not change.
Future<void> enterSidechainScope(
  SidechainModule module, {
  required ChainNavigator navigator,
  required Directory applicationDir,
  required Logger log,
}) {
  return _scopeOps.add(
    () => GetIt.I.pushNewScopeAsync(
      scopeName: sidechainScopeName(module),
      init: (getIt) async {
        final rpc = module.registerRPC(getIt);
        getIt.registerSingleton<SidechainModule>(module);
        getIt.registerSingleton<SidechainRPC>(rpc);
        getIt.registerSingleton<ChainNavigator>(navigator);
        getIt.registerLazySingleton<SidechainBalanceProvider>(
          () => SidechainBalanceProvider(sidechain: rpc),
          dispose: (provider) => provider.dispose(),
        );
        getIt.registerLazySingleton<SidechainBMMProvider>(
          () => SidechainBMMProvider(sidechainRPC: rpc),
          dispose: (provider) => provider.dispose(),
        );
        getIt.registerLazySingleton<AddressProvider>(
          () => AddressProvider(),
          dispose: (provider) => provider.dispose(),
        );
        getIt.registerLazySingleton<SidechainTransactionsProvider>(
          () => SidechainTransactionsProvider(),
          dispose: (provider) => provider.dispose(),
        );
        final confProvider = await SidechainConfProvider.backed(sidechainConfProvider(module));
        getIt.registerSingleton<GenericSidechainConfProvider>(
          confProvider,
          dispose: (provider) => provider.dispose(),
        );
        await module.registerChainProviders(getIt, applicationDir, log);
        getIt.registerLazySingleton<SidechainHomepageProvider>(
          () => SidechainHomepageProvider(module),
          dispose: (provider) => provider.dispose(),
        );
      },
    ),
  );
}

/// Drops the scope of [module] and disposes the providers in it.
Future<void> exitSidechainScope(SidechainModule module) {
  return _scopeOps.add(() async {
    // A scope whose init failed is already gone.
    if (GetIt.I.hasScope(sidechainScopeName(module))) {
      await GetIt.I.dropScope(sidechainScopeName(module));
    }
  });
}
