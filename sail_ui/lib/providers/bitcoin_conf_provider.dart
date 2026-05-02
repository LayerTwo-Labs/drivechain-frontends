import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:connectrpc/connect.dart' as crpc;
import 'package:connectrpc/protobuf.dart';
import 'package:connectrpc/protocol/connect.dart' as connect;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/env.dart';
import 'package:sail_ui/sail_ui.dart';

/// Thrown when the user tries to switch to a network that requires a datadir
/// (mainnet/forknet) but none is configured. Callers should prompt for a
/// directory, persist it via [BitcoinConfProvider.updateDataDir], then retry.
class MissingDatadirException implements Exception {
  final BitcoinNetwork network;
  MissingDatadirException(this.network);

  @override
  String toString() => 'datadir not configured for $network';
}

/// Bitcoin Core configuration provider backed by orchestrator's BitcoinConfService.
/// All reads/writes go through the backend — no local file access.
class BitcoinConfProvider extends ChangeNotifier {
  final Logger log = GetIt.I.get<Logger>();
  late BitcoinConfServiceClient _client;
  Timer? _pollTimer;

  bool hasPrivateBitcoinConf = false;
  String? configPath;
  BitcoinNetwork network = BitcoinNetwork.BITCOIN_NETWORK_SIGNET;
  String? detectedDataDir;
  BitcoinConfig? currentConfig;
  late final RootStackRouter router;

  bool get networkSupportsSidechains {
    return network == BitcoinNetwork.BITCOIN_NETWORK_FORKNET ||
        network == BitcoinNetwork.BITCOIN_NETWORK_SIGNET ||
        network == BitcoinNetwork.BITCOIN_NETWORK_REGTEST;
  }

  bool get isDemoMode => network == BitcoinNetwork.BITCOIN_NETWORK_MAINNET;

  int rpcPort = 38332;

  BitcoinConfProvider._create(this.router);

  static Future<BitcoinConfProvider> create(RootStackRouter router) async {
    final instance = BitcoinConfProvider._create(router);
    instance._initClient();
    await instance.loadConfig(isFirst: true);
    instance._startPolling();
    return instance;
  }

  void _initClient() {
    final transport = connect.Transport(
      baseUrl: 'http://localhost:30400',
      codec: const ProtoCodec(),
      httpClient: keepaliveHttpClient(),
    );
    _client = BitcoinConfServiceClient(transport);
  }

  void _startPolling() {
    if (Environment.isInTest) return;
    _pollTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => loadConfig(),
    );
  }

  bool _isConnectionError(Object e) {
    final msg = e.toString();
    return msg.contains('http/2 connection is finishing') ||
        msg.contains('Connection refused') ||
        msg.contains('Connection reset') ||
        msg.contains('Connection terminated');
  }

  Future<void> loadConfig({bool isFirst = false}) async {
    try {
      final resp = await _client.getBitcoinConfig(GetBitcoinConfigRequest());
      final oldNetwork = network;

      hasPrivateBitcoinConf = resp.hasPrivateConf;
      configPath = resp.configPath.isEmpty ? null : resp.configPath;
      detectedDataDir = resp.detectedDataDir.isEmpty ? null : resp.detectedDataDir;
      rpcPort = resp.rpcPort;

      network = _parseNetwork(resp.network);

      if (resp.configContent.isNotEmpty) {
        currentConfig = BitcoinConfig.parse(resp.configContent);
      }

      if (!isFirst && oldNetwork != network) {
        _onNetworkChanged();
      }

      notifyListeners();
    } catch (e) {
      if (!isExpectedBootError(e)) {
        log.e('BitcoinConfProvider: failed to load config: $e');
      }
      if (_isConnectionError(e)) {
        _initClient();
      }
    }
  }

  void _onNetworkChanged() {
    try {
      final syncProvider = GetIt.I.get<SyncProvider>();
      syncProvider.clearState();
    } catch (_) {}
  }

  Future<void> updateNetwork(BitcoinNetwork newNetwork) async {
    try {
      await _client.setBitcoinConfigNetwork(
        SetBitcoinConfigNetworkRequest(network: _networkToString(newNetwork)),
      );
      await loadConfig();
    } on crpc.ConnectException catch (e) {
      if (e.code == crpc.Code.failedPrecondition && e.message.contains('datadir not configured')) {
        throw MissingDatadirException(newNetwork);
      }
      log.e('BitcoinConfProvider: failed to update network: $e');
      rethrow;
    } catch (e) {
      log.e('BitcoinConfProvider: failed to update network: $e');
      rethrow;
    }
  }

  Future<void> swapNetwork(
    BuildContext context,
    BitcoinNetwork newNetwork,
  ) async {
    if (hasPrivateBitcoinConf) return;
    if (network == newNetwork) return;
    await updateNetwork(newNetwork);
  }

  Future<void> updateDataDir(
    String? dataDir, {
    BitcoinNetwork? forNetwork,
  }) async {
    try {
      await _client.setBitcoinConfigDataDir(
        SetBitcoinConfigDataDirRequest(
          dataDir: dataDir ?? '',
          network: forNetwork != null ? _networkToString(forNetwork) : '',
        ),
      );
      await loadConfig();
    } catch (e) {
      log.e('BitcoinConfProvider: failed to update datadir: $e');
    }
  }

  Future<void> commitNetworkChange(BitcoinNetwork newNetwork) async {
    if (hasPrivateBitcoinConf) return;
    if (network == newNetwork) return;
    await updateNetwork(newNetwork);
  }

  String getDefaultConfig() {
    return currentConfig?.serialize() ?? '';
  }

  String getCurrentConfigContent() {
    return currentConfig?.serialize() ?? '';
  }

  Future<void> writeConfig(String content) async {
    try {
      await _client.writeBitcoinConfig(
        WriteBitcoinConfigRequest(configContent: content),
      );
      await loadConfig();
    } catch (e) {
      log.e('BitcoinConfProvider: failed to write config: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  static BitcoinNetwork _parseNetwork(String network) {
    return switch (network.toLowerCase()) {
      'mainnet' || 'main' => BitcoinNetwork.BITCOIN_NETWORK_MAINNET,
      'forknet' => BitcoinNetwork.BITCOIN_NETWORK_FORKNET,
      'testnet' || 'test' => BitcoinNetwork.BITCOIN_NETWORK_TESTNET,
      'signet' => BitcoinNetwork.BITCOIN_NETWORK_SIGNET,
      'regtest' => BitcoinNetwork.BITCOIN_NETWORK_REGTEST,
      _ => BitcoinNetwork.BITCOIN_NETWORK_SIGNET,
    };
  }

  static String _networkToString(BitcoinNetwork network) {
    return switch (network) {
      BitcoinNetwork.BITCOIN_NETWORK_MAINNET => 'mainnet',
      BitcoinNetwork.BITCOIN_NETWORK_FORKNET => 'forknet',
      BitcoinNetwork.BITCOIN_NETWORK_TESTNET => 'testnet',
      BitcoinNetwork.BITCOIN_NETWORK_SIGNET => 'signet',
      BitcoinNetwork.BITCOIN_NETWORK_REGTEST => 'regtest',
      _ => 'signet',
    };
  }
}
