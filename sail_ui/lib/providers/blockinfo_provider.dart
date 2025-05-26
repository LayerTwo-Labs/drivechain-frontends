import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/env.dart';
import 'package:sail_ui/gen/google/protobuf/timestamp.pb.dart';
import 'package:sail_ui/rpcs/enforcer_rpc.dart';
import 'package:sail_ui/rpcs/mainchain_rpc.dart';
import 'package:sail_ui/sail_ui.dart';

/// Represents detailed information about a blockchain
class SyncInfo {
  final int blocks;
  final int headers;
  final Timestamp? lastBlockAt;

  double get verificationProgress => headers == 0 ? 0 : blocks / headers;
  bool get isSynced => headers > 0 && blocks == headers;

  SyncInfo({
    required this.blocks,
    required this.headers,
    required this.lastBlockAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SyncInfo && other.blocks == blocks && other.headers == headers && other.lastBlockAt == lastBlockAt;
  }

  @override
  int get hashCode => Object.hash(blocks, headers, lastBlockAt);
}

/// Represents a binary that has some sort of sync-status
class BlockSyncConnection {
  final RPCConnection rpc;
  final String name;

  BlockSyncConnection({
    required this.rpc,
    required this.name,
  });
}

class BlockInfoProvider extends ChangeNotifier {
  Logger get log => GetIt.I.get<Logger>();

  MainchainRPC get mainchainRPC => GetIt.I.get<MainchainRPC>();
  EnforcerRPC get enforcerRPC => GetIt.I.get<EnforcerRPC>();

  BlockSyncConnection get mainchain => BlockSyncConnection(rpc: mainchainRPC, name: ParentChain().name);
  BlockSyncConnection get enforcer => BlockSyncConnection(rpc: enforcerRPC, name: Enforcer().name);
  final BlockSyncConnection? additionalConnection;

  static const Duration AGGRESSIVE_INTERVAL = Duration(milliseconds: 100);
  static const Duration PASSIVE_INTERVAL = Duration(seconds: 5);

  // Mainchain state
  SyncInfo? mainchainSyncInfo;
  String? mainchainError;
  Timer? _mainchainTimer;
  bool _isFetchingMainchain = false;

  // Enforcer state
  SyncInfo? enforcerSyncInfo;
  String? enforcerError;
  Timer? _enforcerTimer;
  bool _isFetchingEnforcer = false;

  // Additional connection state
  SyncInfo? additionalSyncInfo;
  String? additionalError;
  Timer? _additionalTimer;
  bool _isFetchingAdditional = false;

  BlockInfoProvider({
    this.additionalConnection,
    bool startTimer = true,
  }) {
    if (startTimer && !Environment.isInTest) {
      _startAllTimers();
    }
  }

  void _startAllTimers() {
    _startMainchainTimer();
    _startEnforcerTimer();
    if (additionalConnection != null) {
      _startAdditionalTimer();
    }
  }

  void _startMainchainTimer() {
    _mainchainTimer?.cancel();
    void tick() async {
      if (_isFetchingMainchain) return;
      _isFetchingMainchain = true;

      try {
        bool wasSynced = mainchainSyncInfo?.isSynced ?? false;
        await _fetchMainchain();
        bool isSynced = mainchainSyncInfo?.isSynced ?? false;

        if (wasSynced != isSynced) {
          // changed sync status, so we must apply the correct timer
          _mainchainTimer?.cancel();
          _mainchainTimer = Timer.periodic(
            isSynced ? PASSIVE_INTERVAL : AGGRESSIVE_INTERVAL,
            (_) => tick(),
          );
        }
      } catch (e) {
        // swallow
      } finally {
        _isFetchingMainchain = false;
      }
    }

    _mainchainTimer = Timer.periodic(AGGRESSIVE_INTERVAL, (_) => tick());
  }

  void _startEnforcerTimer() {
    _enforcerTimer?.cancel();
    void tick() async {
      if (_isFetchingEnforcer) return;
      _isFetchingEnforcer = true;

      try {
        bool wasSynced = enforcerSyncInfo?.isSynced ?? false;
        await _fetchEnforcer();
        bool isSynced = enforcerSyncInfo?.isSynced ?? false;

        if (wasSynced != isSynced) {
          // changed sync status, so we must apply the correct timer
          _enforcerTimer?.cancel();
          _enforcerTimer = Timer.periodic(
            isSynced ? PASSIVE_INTERVAL : AGGRESSIVE_INTERVAL,
            (_) => tick(),
          );
        }
      } catch (e) {
        // swallow
      } finally {
        _isFetchingEnforcer = false;
      }
    }

    _enforcerTimer = Timer.periodic(AGGRESSIVE_INTERVAL, (_) => tick());
  }

  void _startAdditionalTimer() {
    _additionalTimer?.cancel();
    void tick() async {
      if (_isFetchingAdditional) return;
      _isFetchingAdditional = true;

      try {
        bool wasSynced = additionalSyncInfo?.isSynced ?? false;
        await _fetchAdditional();
        bool isSynced = additionalSyncInfo?.isSynced ?? false;
        if (additionalConnection!.name == Thunder().name || additionalConnection!.name == Bitnames().name) {
          // We can't check whether we're in IBD for thunder, so
          // we stay aggressive forever...
          isSynced = false;
        }

        if (wasSynced != isSynced) {
          // changed sync status, so we must apply the correct timer
          _additionalTimer?.cancel();
          _additionalTimer = Timer.periodic(
            isSynced ? PASSIVE_INTERVAL : AGGRESSIVE_INTERVAL,
            (_) => tick(),
          );
        }
      } catch (e) {
        // swallow
      } finally {
        _isFetchingAdditional = false;
      }
    }

    _additionalTimer = Timer.periodic(AGGRESSIVE_INTERVAL, (_) => tick());
  }

  Future<void> _fetchMainchain() async {
    bool hasChanges = false;
    try {
      if (!mainchain.rpc.connected) return;

      final newBlockchainInfo = await mainchain.rpc.getBlockchainInfo();
      final newSyncInfo = SyncInfo(
        blocks: newBlockchainInfo.blocks,
        headers: newBlockchainInfo.headers,
        lastBlockAt: newBlockchainInfo.time != 0 ? Timestamp(seconds: Int64(newBlockchainInfo.time)) : null,
      );

      if (_syncInfoHasChanged(mainchainSyncInfo, newSyncInfo) || mainchainError != null) {
        mainchainSyncInfo = newSyncInfo;
        mainchainError = null;
        hasChanges = true;
      }
    } catch (e) {
      final newError = extractConnectException(e);
      if (mainchainError != newError) {
        mainchainError = newError;
        hasChanges = true;
      }
    } finally {
      _isFetchingMainchain = false;
      if (hasChanges) {
        notifyListeners();
      }
    }
  }

  Future<void> _fetchEnforcer() async {
    bool hasChanges = false;
    try {
      if (!enforcer.rpc.connected) return;

      final newBlockchainInfo = await enforcer.rpc.getBlockchainInfo();
      final newSyncInfo = SyncInfo(
        blocks: newBlockchainInfo.blocks,
        headers: mainchainSyncInfo?.headers ?? 0,
        lastBlockAt: newBlockchainInfo.time != 0 ? Timestamp(seconds: Int64(newBlockchainInfo.time)) : null,
      );

      if (_syncInfoHasChanged(enforcerSyncInfo, newSyncInfo) || enforcerError != null) {
        enforcerSyncInfo = newSyncInfo;
        enforcerError = null;
        hasChanges = true;
      }
    } catch (e) {
      final newError = extractConnectException(e);
      if (enforcerError != newError) {
        enforcerError = newError;
        hasChanges = true;
      }
    } finally {
      _isFetchingEnforcer = false;
      if (hasChanges) {
        notifyListeners();
      }
    }
  }

  Future<void> _fetchAdditional() async {
    if (additionalConnection == null) return;

    bool hasChanges = false;
    try {
      if (!additionalConnection!.rpc.connected) return;

      final newBlockchainInfo = await additionalConnection!.rpc.getBlockchainInfo();
      final newSyncInfo = SyncInfo(
        blocks: newBlockchainInfo.blocks,
        headers: newBlockchainInfo.headers,
        lastBlockAt: newBlockchainInfo.time != 0 ? Timestamp(seconds: Int64(newBlockchainInfo.time)) : null,
      );

      if (_syncInfoHasChanged(additionalSyncInfo, newSyncInfo) || additionalError != null) {
        additionalSyncInfo = newSyncInfo;
        additionalError = null;
        hasChanges = true;
      }
    } catch (e) {
      final newError = extractConnectException(e);
      if (additionalError != newError) {
        additionalError = newError;
        hasChanges = true;
      }
    } finally {
      _isFetchingAdditional = false;
      if (hasChanges) {
        notifyListeners();
      }
    }
  }

  bool _syncInfoHasChanged(SyncInfo? oldInfo, SyncInfo? newInfo) {
    if (oldInfo == null || newInfo == null) return true;
    return oldInfo != newInfo;
  }

  // For manual fetching of all connections
  Future<void> fetch() async {
    await Future.wait([
      _fetchMainchain(),
      _fetchEnforcer(),
      if (additionalConnection != null) _fetchAdditional(),
    ]);
  }

  @override
  void dispose() {
    _mainchainTimer?.cancel();
    _enforcerTimer?.cancel();
    _additionalTimer?.cancel();
    super.dispose();
  }
}
