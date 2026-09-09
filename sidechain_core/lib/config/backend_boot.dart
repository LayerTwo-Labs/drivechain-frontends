import 'package:get_it/get_it.dart';
import 'package:sidechain_core/providers/network_scoped.dart';
import 'package:sidechain_core/providers/node_mode_provider.dart';

/// What an install boots, from the node mode the user picked. Every app reads
/// this one answer, so bitwindow and a sidechain app cannot drift apart.
enum BackendBoot {
  /// The user never picked. Nothing boots until the mode gate asks.
  awaitChoice,

  /// Light mode uses local sidechains and a remote enforcer.
  remoteEnforcer,

  /// Light mode uses the Bitcoin wallet without a remote enforcer.
  walletOnly,

  /// Full mode. Bitcoin Core and the enforcer boot on this machine.
  localBackends;

  /// True when this install starts its own Bitcoin backends.
  bool get startsLocalBackends => this == BackendBoot.localBackends;

  bool get startsBackends => this == BackendBoot.localBackends || this == BackendBoot.remoteEnforcer;

  /// Why the boot took this branch. Both apps log it.
  String get reason => switch (this) {
    BackendBoot.awaitChoice => 'no node mode picked yet; the mode gate asks before any boot',
    BackendBoot.remoteEnforcer => 'light mode; local sidechains use the remote enforcer',
    BackendBoot.walletOnly => 'light mode; the Bitcoin wallet uses Electrum',
    BackendBoot.localBackends => 'full mode; start the local Bitcoin backends',
  };
}

/// Registers the node mode provider. Every app calls this in its dependency
/// setup, so the daemon cards and the boot read the same provider.
void registerNodeMode() {
  if (GetIt.I.isRegistered<NodeModeProvider>()) {
    return;
  }
  GetIt.I.registerLazySingleton<NodeModeProvider>(() => NodeModeProvider());
  NetworkScopedRegistry.enrolLazy<NodeModeProvider>();
}

/// Reads the saved mode and returns what this install boots. A read that never
/// reaches the orchestrator leaves the mode unset, which boots nothing.
Future<BackendBoot> readBackendBoot({required bool orchestratorReady}) async {
  final mode = GetIt.I.get<NodeModeProvider>();
  if (orchestratorReady) {
    await mode.load();
  }
  if (mode.needsChoice) {
    return BackendBoot.awaitChoice;
  }
  if (mode.isFull) {
    return BackendBoot.localBackends;
  }
  return mode.usesEnforcer ? BackendBoot.remoteEnforcer : BackendBoot.walletOnly;
}
