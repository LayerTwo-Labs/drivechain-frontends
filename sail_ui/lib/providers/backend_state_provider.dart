import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/classes/rpc_connection.dart';
import 'package:sail_ui/gen/orchestrator/v1/orchestrator.pb.dart';
import 'package:sail_ui/providers/binaries/binary_provider.dart';
import 'package:sail_ui/rpcs/bitassets_rpc.dart';
import 'package:sail_ui/rpcs/bitnames_rpc.dart';
import 'package:sail_ui/rpcs/coinshift_rpc.dart';
import 'package:sail_ui/rpcs/enforcer_rpc.dart';
import 'package:sail_ui/rpcs/bitcoind_connection.dart';
import 'package:sail_ui/env.dart';
import 'package:sail_ui/rpcs/orchestrator_rpc.dart';
import 'package:sail_ui/rpcs/photon_rpc.dart';
import 'package:sail_ui/rpcs/thunder_rpc.dart';
import 'package:sail_ui/rpcs/truthcoin_rpc.dart';
import 'package:sail_ui/rpcs/zside_rpc.dart';

/// Syncs binary state from the Go backend to the Flutter frontend by polling
/// the orchestrator's `ListBinaries` RPC every 1s. Updates RPCConnection
/// flags (connected/startup/error) and BinaryProvider's binary paths.
///
/// No streaming — sync state and download progress now both come from
/// `SyncProvider` (polled `GetSyncStatus`). This provider only mirrors the
/// orchestrator's per-binary connection metadata onto the matching
/// RPCConnection objects.
class BackendStateProvider extends ChangeNotifier {
  final OrchestratorRPC _orchestrator;
  final Logger _log = GetIt.I.get<Logger>();

  /// Live binary status from the backend.
  Map<String, BinaryStatusMsg> binaries = {};

  Timer? _pollTimer;
  bool _polling = false;

  static const Duration _pollInterval = Duration(seconds: 1);

  BackendStateProvider(this._orchestrator);

  /// Start polling `listBinaries()` once per second. Call this after the
  /// daemon process is running and serving gRPC. Idempotent.
  void startWatching() {
    if (Environment.isInTest) return;
    _pollTimer?.cancel();
    // Kick a poll immediately so the UI gets a snapshot without waiting a
    // full tick on first connect.
    unawaited(_poll());
    _pollTimer = Timer.periodic(_pollInterval, (_) => _poll());
  }

  Future<void> _poll() async {
    if (_polling) return;
    _polling = true;
    try {
      final resp = await _orchestrator.listBinaries();
      _apply(resp.binaries);
    } catch (e) {
      // Transport blip — keep last-known state on screen, try again next
      // tick. The orchestrator-process keepalive watchdog (separate code
      // path) will recreate the underlying HTTP/2 transport if it's truly
      // dead.
      _log.d('BackendStateProvider: listBinaries failed: $e');
    } finally {
      _polling = false;
    }
  }

  void _apply(List<BinaryStatusMsg> statuses) {
    final changedRpcs = <RPCConnection>{};
    for (final status in statuses) {
      binaries[status.name] = status;
      final rpc = _syncConnectionState(status);
      if (rpc != null) changedRpcs.add(rpc);
      _syncBinaryPath(status);
    }
    for (final rpc in changedRpcs) {
      rpc.notifyListeners();
    }
    notifyListeners();
  }

  /// Sync all connection state from the Go backend to the Flutter RPCConnection.
  /// The Go ConnectionMonitor is the single source of truth — just assign all fields.
  /// Returns the RPC if state changed (caller batches notifyListeners), null otherwise.
  RPCConnection? _syncConnectionState(BinaryStatusMsg status) {
    final rpc = _rpcForBinaryName(status.name);
    if (rpc == null) return null;

    // Always derive from the current status. When the orchestrator stops reporting
    // a startup_error (empty string), null it out so the UI doesn't keep rendering
    // a stale warmup message. Same for connectionError.
    final startupError = status.startupError.isEmpty ? null : status.startupError;
    final connectionError = status.connectionError.isEmpty ? null : status.connectionError;

    // Check if anything actually changed to avoid unnecessary rebuilds
    if (rpc.connected == status.connected &&
        rpc.stoppingBinary == status.stopping &&
        rpc.initializingBinary == status.initializing &&
        rpc.connectModeOnly == status.connectModeOnly &&
        rpc.startupError == startupError &&
        rpc.connectionError == connectionError) {
      return null;
    }

    rpc.connected = status.connected;
    rpc.stoppingBinary = status.stopping;
    rpc.initializingBinary = status.initializing;
    rpc.connectModeOnly = status.connectModeOnly;
    rpc.startupError = startupError;
    rpc.connectionError = connectionError;
    return rpc;
  }

  /// Mirror the orchestrator's `binary_path` field onto the matching
  /// `Binary.metadata.binaryPath`. Orchestrator owns the truth — it knows
  /// where it extracted the file (variant-aware, .app-resolved on macOS),
  /// so the frontend stops trying to second-guess from a list of guessed
  /// paths and just uses what was reported.
  void _syncBinaryPath(BinaryStatusMsg status) {
    if (!GetIt.I.isRegistered<BinaryProvider>()) return;
    final type = _binaryTypeFromName(status.name);
    if (type == null) return;

    final reported = status.binaryPath;
    final next = reported.isEmpty ? null : File(reported);

    final binaryProvider = GetIt.I.get<BinaryProvider>();
    binaryProvider.updateBinary(type, (b) {
      if (b.metadata.binaryPath?.path == next?.path) return b;
      return b.copyWith(
        metadata: b.metadata.copyWith(
          remoteTimestamp: b.metadata.remoteTimestamp,
          downloadedTimestamp: b.metadata.downloadedTimestamp,
          binaryPath: next,
          updateable: b.metadata.updateable,
        ),
      );
    });
  }

  /// Get the RPCConnection for a backend binary name, or null.
  RPCConnection? _rpcForBinaryName(String name) {
    return switch (name) {
      'bitcoind' => GetIt.I.isRegistered<BitcoindConnection>() ? GetIt.I.get<BitcoindConnection>() : null,
      'enforcer' => GetIt.I.isRegistered<EnforcerRPC>() ? GetIt.I.get<EnforcerRPC>() : null,
      // bitwindowd state is managed by BinaryProvider (daemon binary), not the orchestrator stream.
      'thunder' => GetIt.I.isRegistered<ThunderRPC>() ? GetIt.I.get<ThunderRPC>() : null,
      'zside' => GetIt.I.isRegistered<ZSideRPC>() ? GetIt.I.get<ZSideRPC>() : null,
      'bitnames' => GetIt.I.isRegistered<BitnamesRPC>() ? GetIt.I.get<BitnamesRPC>() : null,
      'bitassets' => GetIt.I.isRegistered<BitAssetsRPC>() ? GetIt.I.get<BitAssetsRPC>() : null,
      'truthcoin' => GetIt.I.isRegistered<TruthcoinRPC>() ? GetIt.I.get<TruthcoinRPC>() : null,
      'photon' => GetIt.I.isRegistered<PhotonRPC>() ? GetIt.I.get<PhotonRPC>() : null,
      'coinshift' => GetIt.I.isRegistered<CoinShiftRPC>() ? GetIt.I.get<CoinShiftRPC>() : null,
      _ => null,
    };
  }

  BinaryType? _binaryTypeFromName(String name) {
    switch (name) {
      case 'bitcoind':
        return BinaryType.BINARY_TYPE_BITCOIND;
      case 'enforcer':
        return BinaryType.BINARY_TYPE_ENFORCER;
      case 'thunder':
        return BinaryType.BINARY_TYPE_THUNDER;
      case 'zside':
        return BinaryType.BINARY_TYPE_ZSIDE;
      case 'bitwindow':
      case 'bitwindowd':
        return BinaryType.BINARY_TYPE_BITWINDOWD;
      case 'bitnames':
        return BinaryType.BINARY_TYPE_BITNAMES;
      case 'bitassets':
        return BinaryType.BINARY_TYPE_BITASSETS;
      case 'truthcoin':
        return BinaryType.BINARY_TYPE_TRUTHCOIN;
      case 'photon':
        return BinaryType.BINARY_TYPE_PHOTON;
      case 'coinshift':
        return BinaryType.BINARY_TYPE_COINSHIFT;
      default:
        return null;
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _pollTimer = null;
    super.dispose();
  }
}
