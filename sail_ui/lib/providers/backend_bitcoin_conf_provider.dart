import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:connectrpc/http2.dart';
import 'package:connectrpc/protobuf.dart';
import 'package:connectrpc/protocol/connect.dart' as connect;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/env.dart';
import 'package:sail_ui/sail_ui.dart';

/// RPC-backed implementation of BitcoinConfProvider.
/// Used by Thunder (and future sidechain apps) where the Go backend
/// manages config files. All reads/writes go through BitcoinConfService.
class BackendBitcoinConfProvider extends BitcoinConfProvider {
  final Logger log = GetIt.I.get<Logger>();
  late BitcoinConfServiceClient _client;
  Timer? _pollTimer;

  @override
  bool hasPrivateBitcoinConf = false;
  @override
  String? configPath;
  @override
  BitcoinNetwork network = BitcoinNetwork.BITCOIN_NETWORK_SIGNET;
  @override
  String? detectedDataDir;
  @override
  BitcoinConfig? currentConfig;
  @override
  late final RootStackRouter router;

  @override
  bool get networkSupportsSidechains {
    return network == BitcoinNetwork.BITCOIN_NETWORK_FORKNET ||
        network == BitcoinNetwork.BITCOIN_NETWORK_SIGNET ||
        network == BitcoinNetwork.BITCOIN_NETWORK_REGTEST;
  }

  @override
  bool get isDemoMode => network == BitcoinNetwork.BITCOIN_NETWORK_MAINNET;

  @override
  int rpcPort = 38332;

  BackendBitcoinConfProvider._create(this.router);

  static Future<BackendBitcoinConfProvider> create(
    RootStackRouter router,
  ) async {
    final instance = BackendBitcoinConfProvider._create(router);
    instance._initClient();
    await instance.loadConfig(isFirst: true);
    instance._startPolling();
    return instance;
  }

  void _initClient() {
    final transport = connect.Transport(
      baseUrl: 'http://localhost:30302',
      codec: const ProtoCodec(),
      httpClient: createHttpClient(),
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

  @override
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
      log.e('BackendBitcoinConfProvider: failed to load config: $e');
      if (_isConnectionError(e)) {
        log.i('BackendBitcoinConfProvider: recreating connection');
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

  @override
  Future<void> updateNetwork(BitcoinNetwork newNetwork) async {
    try {
      await _client.setBitcoinConfigNetwork(
        SetBitcoinConfigNetworkRequest(network: _networkToString(newNetwork)),
      );
      await loadConfig();
    } catch (e) {
      log.e('BackendBitcoinConfProvider: failed to update network: $e');
    }
  }

  @override
  Future<void> swapNetwork(
    BuildContext context,
    BitcoinNetwork newNetwork,
  ) async {
    if (hasPrivateBitcoinConf) return;
    if (network == newNetwork) return;
    await updateNetwork(newNetwork);
  }

  @override
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
      log.e('BackendBitcoinConfProvider: failed to update datadir: $e');
    }
  }

  @override
  Future<void> commitNetworkChange(BitcoinNetwork newNetwork) async {
    if (hasPrivateBitcoinConf) return;
    if (network == newNetwork) return;
    await updateNetwork(newNetwork);
  }

  @override
  String getDefaultConfig() {
    return currentConfig?.serialize() ?? '';
  }

  @override
  String getCurrentConfigContent() {
    return currentConfig?.serialize() ?? '';
  }

  @override
  Future<void> writeConfig(String content) async {
    try {
      await _client.writeBitcoinConfig(
        WriteBitcoinConfigRequest(configContent: content),
      );
      await loadConfig();
    } catch (e) {
      log.e('BackendBitcoinConfProvider: failed to write config: $e');
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
