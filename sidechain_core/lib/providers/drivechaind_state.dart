import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:sidechain_core/classes/daemon_state.dart';
import 'package:sidechain_core/config/binaries.dart';
import 'package:sidechain_core/providers/backend_state_provider.dart';
import 'package:sidechain_core/providers/binaries/binary_provider.dart';

/// The orchestrator's own daemon. It serves no chain RPC, so its state comes
/// from the poll that already watches the backend.
class DrivechaindState extends ChangeNotifier implements DaemonState {
  final BinaryProvider _binaries;
  final BackendStateProvider _backend;

  DrivechaindState({BinaryProvider? binaries, BackendStateProvider? backend})
    : _binaries = binaries ?? GetIt.I.get<BinaryProvider>(),
      _backend = backend ?? GetIt.I.get<BackendStateProvider>() {
    _binaries.addListener(notifyListeners);
    _backend.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _binaries.removeListener(notifyListeners);
    _backend.removeListener(notifyListeners);
    super.dispose();
  }

  @override
  Binary get binary => _binaries.binaries.firstWhere(
    (b) => b.type == BinaryType.BINARY_TYPE_DRIVECHAIND,
  );

  /// A poll that lands is the only proof. A boot that never reached the
  /// orchestrator must not read as connected.
  @override
  bool get connected => _backend.orchestratorAnswered && _backend.orchestratorReachable;

  @override
  bool get initializingBinary => !connected && _binaries.isInitializing(binary);

  @override
  bool get stoppingBinary => _binaries.isStopping(binary);

  @override
  String? get connectionError {
    if (connected || initializingBinary) {
      return null;
    }
    return 'The orchestrator does not answer';
  }

  @override
  String? get startupError => _binaries.connectionError(binary);
}
