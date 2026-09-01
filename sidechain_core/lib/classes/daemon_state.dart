import 'package:flutter/foundation.dart';
import 'package:sidechain_core/config/binaries.dart';

/// What a daemon status card reads. [RPCConnection] satisfies it, and so does a
/// daemon that answers through the orchestrator poll rather than its own RPC.
abstract interface class DaemonState implements Listenable {
  Binary get binary;
  bool get connected;
  bool get initializingBinary;
  bool get stoppingBinary;
  String? get connectionError;
  String? get startupError;
}
