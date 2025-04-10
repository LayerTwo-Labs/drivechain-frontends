import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
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
}

/// Represents a binary that has some sort of sync-status
class BlockSyncConnection {
  final RPCConnection rpc;
  final String name;

  BlockSyncConnection({
    required this.rpc,
    required this.name,
  });

  double verificationProgress = 0;
  Timestamp? lastBlockAt;
}

class BlockInfoProvider extends ChangeNotifier {
  Logger get log => GetIt.I.get<Logger>();

  MainchainRPC get mainchainRPC => GetIt.I.get<MainchainRPC>();
  EnforcerRPC get enforcerRPC => GetIt.I.get<EnforcerRPC>();

  BlockSyncConnection get mainchain => BlockSyncConnection(rpc: mainchainRPC, name: 'Parent Chain');
  BlockSyncConnection get enforcer => BlockSyncConnection(rpc: enforcerRPC, name: 'Enforcer');
  // additional connection we should monitor for sync-status
  final BlockSyncConnection? additionalConnection;

  // computed fields for mainchain
  SyncInfo? mainchainSyncInfo;
  String? mainchainError;

  // computed fields for enforcer
  SyncInfo? enforcerSyncInfo;
  String? enforcerError;

  // computed fields for additional connection
  SyncInfo? additionalSyncInfo;
  String? additionalError;

  bool _isFetching = false;
  Timer? _fetchTimer;

  BlockInfoProvider({
    this.additionalConnection,
    bool startTimer = true,
  }) {
    if (startTimer) {
      if (Environment.isInTest) {
        return;
      }
      _startFetchTimer();
    }
  }

  // call this function from anywhere to refetch verification progress
  Future<void> fetch() async {
    if (_isFetching) {
      return;
    }
    _isFetching = true;

    List<Future<void>> fetchTasks = [
      _fetchBlockchainInfo(mainchain, (info) {
        mainchainSyncInfo = info;
      }),
      _fetchBlockchainInfo(enforcer, (info) {
        enforcerSyncInfo = info;
      }),
    ];

    if (additionalConnection != null) {
      fetchTasks.add(
        _fetchBlockchainInfo(additionalConnection!, (info) {
          additionalSyncInfo = info;
        }),
      );
    }

    await Future.wait(fetchTasks);

    _isFetching = false;
  }

  Future<void> _fetchBlockchainInfo(BlockSyncConnection connection, Function(SyncInfo) updateFields) async {
    try {
      if (!connection.rpc.connected) {
        // skip unconnected connections
        return;
      }

      final newBlockchainInfo = await connection.rpc.getBlockchainInfo();
      updateFields(
        SyncInfo(
          blocks: newBlockchainInfo.blocks,
          headers: connection.name == 'Parent Chain' ? newBlockchainInfo.headers : newBlockchainInfo.headers,
          lastBlockAt: newBlockchainInfo.time != 0 ? Timestamp(seconds: Int64(newBlockchainInfo.time)) : null,
        ),
      );
    } catch (e) {
      log.e('Error fetching blockchain info for ${connection.name}: $e');
      if (connection.name == 'Parent Chain') {
        mainchainError = e.toString();
      } else if (connection.name == 'Enforcer') {
        enforcerError = e.toString();
      } else {
        additionalError = e.toString();
      }
    } finally {
      notifyListeners();
    }
  }

  void _startFetchTimer() {
    void tick() async {
      try {
        await fetch();
      } catch (e) {
        // do nothing, swallow!
      }
    }

    final Duration interval = const Duration(seconds: 5);
    _fetchTimer = Timer.periodic(interval, (_) => tick());
  }

  @override
  void dispose() {
    _fetchTimer?.cancel();
    _fetchTimer = null;
    super.dispose();
  }
}
