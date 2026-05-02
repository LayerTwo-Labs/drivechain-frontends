import 'dart:convert';

import 'package:connectrpc/connect.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

/// Base class for RPC connections to binaries.
///
/// Connection state (connected, errors, etc.) is managed by
/// BackendStateProvider, which polls the orchestrator's listBinaries RPC
/// once per second and writes the snapshot onto each RPCConnection.
/// This class is primarily a state container + data provider for
/// balance/blockchain queries.
abstract class RPCConnection extends ChangeNotifier {
  Logger get log => GetIt.I.get<Logger>();
  Binary get binary => GetIt.I.get<BinaryProvider>().binaries.firstWhere(
    (b) => b.type == binaryType,
  );

  BinaryType binaryType;

  RPCConnection({required this.binaryType});

  // =========================================================================
  // Abstract methods — implemented by subclasses
  // =========================================================================

  /// Args to pass to the binary on startup.
  Future<List<String>> binaryArgs();

  /// Attempt to stop the binary gracefully via RPC.
  Future<void> stopRPC();

  /// Returns confirmed and unconfirmed balance.
  Future<(double, double)> balance();

  /// Fetches the latest blockchain info.
  Future<BlockchainInfo> getBlockchainInfo();

  // =========================================================================
  // Connection state — written by BackendStateProvider, read by UI
  // =========================================================================

  bool connected = false;
  bool initializingBinary = false;
  bool stoppingBinary = false;
  bool connectModeOnly = false;
  String? connectionError;
  String? startupError;

  /// Override to react to connection state changes.
  void onConnectionStateChanged(bool isConnected) {}

  /// Notify listeners that connection state has changed.
  void markStateChanged() {
    notifyListeners();
  }
}

// ============================================================================
// Supporting types
// ============================================================================

class BlockchainInfo {
  final String chain;
  final int blocks;
  final int headers;
  final String bestBlockHash;
  final double difficulty;
  final int time;
  final int medianTime;
  final double verificationProgress;
  final bool initialBlockDownload;
  final String chainWork;
  final int sizeOnDisk;
  final bool pruned;
  final List<String> warnings;
  // Non-empty while bitcoind is in a startup phase (Verifying blocks…,
  // Rescanning…, Loading wallet). When set, blocks/headers will be 0/0
  // and the UI should render the message instead of the numeric heights.
  final String startupMessage;

  BlockchainInfo({
    required this.chain,
    required this.blocks,
    required this.headers,
    required this.bestBlockHash,
    required this.difficulty,
    required this.time,
    required this.medianTime,
    required this.verificationProgress,
    required this.initialBlockDownload,
    required this.chainWork,
    required this.sizeOnDisk,
    required this.pruned,
    required this.warnings,
    this.startupMessage = '',
  });

  factory BlockchainInfo.fromMap(Map<String, dynamic> map) {
    final initialBlockDownload = map['initialblockdownload'] ?? false;
    final fullySyncedToHeaders = map['blocks'] > 10 && map['headers'] == map['blocks'];

    return BlockchainInfo(
      chain: map['chain'] ?? '',
      blocks: map['blocks'] ?? 0,
      headers: map['headers'] ?? 0,
      bestBlockHash: map['bestblockhash'] ?? '',
      difficulty: (map['difficulty'] ?? 0.0).toDouble(),
      time: map['time'] ?? 0,
      medianTime: map['mediantime'] ?? 0,
      verificationProgress: (map['verificationprogress'] ?? 0.0).toDouble(),
      initialBlockDownload: initialBlockDownload && !fullySyncedToHeaders,
      chainWork: map['chainwork'] ?? '',
      sizeOnDisk: map['size_on_disk'] ?? 0,
      pruned: map['pruned'] ?? false,
      warnings: List<String>.from(map['warnings'] ?? []),
      startupMessage: map['startup_message'] ?? '',
    );
  }

  static BlockchainInfo fromJson(String json) => BlockchainInfo.fromMap(jsonDecode(json));
  String toJson() => jsonEncode(toMap());

  Map<String, dynamic> toMap() => {
    'chain': chain,
    'blocks': blocks,
    'headers': headers,
    'bestblockhash': bestBlockHash,
    'difficulty': difficulty,
    'time': time,
    'mediantime': medianTime,
    'verificationprogress': verificationProgress,
    'initialblockdownload': initialBlockDownload,
    'chainwork': chainWork,
    'size_on_disk': sizeOnDisk,
    'pruned': pruned,
    'warnings': warnings,
    'startup_message': startupMessage,
  };

  static BlockchainInfo empty() => BlockchainInfo(
    chain: '',
    blocks: 0,
    headers: 0,
    bestBlockHash: '',
    difficulty: 0,
    time: 0,
    medianTime: 0,
    verificationProgress: 0,
    initialBlockDownload: true,
    chainWork: '',
    sizeOnDisk: 0,
    pruned: false,
    warnings: [],
  );
}

String extractConnectException(Object error) {
  if (error is ConnectException) {
    return error.message.isEmpty ? error.toString() : error.message;
  }
  return error.toString();
}

/// Errors that are expected during boot and don't deserve a stack-trace in
/// the console. Polling providers spam these every 100ms while daemons are
/// still coming up — collapse them to a single debug line.
bool isExpectedBootError(Object error) {
  final s = error.toString().toLowerCase();
  return s.contains('connection refused') ||
      s.contains('connection reset') ||
      s.contains('connection closed') ||
      s.contains('connection is being forcefully terminated') ||
      s.contains('protocol_error') ||
      s.contains('http/2 connection is finishing') ||
      // ConnectRPC / gRPC error codes surfaced when daemons are down
      s.contains('[unavailable]') ||
      s.contains('unable to connect to bitcoin core') ||
      s.contains('unable to connect to enforcer') ||
      s.contains('dial tcp') ||
      // bitcoind / Core warmup RPC errors during cold start
      s.contains('rpc error -28') ||
      s.contains('loading block index') ||
      s.contains('loading banlist') ||
      s.contains('verifying blocks') ||
      s.contains('loading wallet') ||
      s.contains('rescanning') ||
      s.contains('loading p2p addresses');
}

/// Extracts just the message from log lines like:
/// `2025-11-26T06:16:51.195731Z INFO bip300301_enforcer: app/main.rs:376: Listening for JSON-RPC`
String prettifyLogMessage(String message) {
  var cleaned = message.replaceAll(RegExp(r'\x1B\[[0-9;]*m'), '');

  final logPattern = RegExp(
    r'^\d{2,4}-\d{2}-\d{2}T[\d:.]+Z\s+\w+\s+.*?:\d+:\s*(.+)$',
  );
  final match = logPattern.firstMatch(cleaned);
  if (match != null) {
    var extracted = match.group(1)!.trim();
    if (extracted.startsWith("'") && extracted.endsWith("'")) {
      extracted = extracted.substring(1, extracted.length - 1);
    }
    return extracted;
  }
  return cleaned;
}
