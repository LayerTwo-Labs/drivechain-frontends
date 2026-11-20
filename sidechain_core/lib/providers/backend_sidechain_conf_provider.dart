import 'dart:async';

import 'package:connectrpc/protobuf.dart';
import 'package:connectrpc/protocol/connect.dart' as connect;
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:sidechain_core/env.dart';
import 'package:sidechain_core/gen/orchestrator/v1/sidechain_conf.connect.client.dart';
import 'package:sidechain_core/gen/orchestrator/v1/sidechain_conf.pb.dart';
import 'package:sidechain_core/rpcs/stream_or_poll.dart';
import 'package:sidechain_core/sidechain_core.dart';

/// RPC-backed sidechain configuration provider.
/// Calls SidechainConfService on the drivechaind instead of reading/writing files.
/// Generic replacement for BackendThunderConfProvider, BackendZSideConfProvider, etc.
class BackendSidechainConfProvider extends GenericSidechainConfProvider {
  final Logger _logger = GetIt.I.get<Logger>();
  final String sidechainName;
  final String _appNameValue;
  final String _configFileNameValue;
  final String Function() _getDataDir;
  final Map<String, String> Function(String network) _getNetworkPorts;
  final String Function() _getDefaultConfig;
  final List<String> _skippedCliKeysValue;

  late SidechainConfServiceClient _client;
  StreamOrPoll<WatchSidechainConfigResponse, GetSidechainConfigResponse>? _watch;
  GetSidechainConfigResponse? _last;
  String _network = 'signet';

  BackendSidechainConfProvider._({
    required this.sidechainName,
    required String appName,
    required String configFileName,
    required this._getDataDir,
    required this._getNetworkPorts,
    required this._getDefaultConfig,
    required List<String> skippedCliKeys,
  }) : _appNameValue = appName,
       _configFileNameValue = configFileName,
       _skippedCliKeysValue = skippedCliKeys;

  /// Create a BackendSidechainConfProvider from an existing GenericSidechainConfProvider
  /// subclass, reusing its configuration methods.
  static Future<BackendSidechainConfProvider> fromProvider(
    GenericSidechainConfProvider source, {
    required String sidechainName,
  }) async {
    final instance = BackendSidechainConfProvider._(
      sidechainName: sidechainName,
      appName: source.appName,
      configFileName: source.configFileName,
      getDataDir: source.getDataDir,
      getNetworkPorts: source.getNetworkPorts,
      getDefaultConfig: source.getDefaultConfig,
      skippedCliKeys: source.skippedCliKeys,
    );
    instance._initClient();
    await instance._loadFromBackend();
    if (!Environment.isInTest) {
      instance._startWatch();
    }
    return instance;
  }

  void _initClient() {
    final transport = connect.Transport(
      baseUrl: OrchestratorEndpoint.url,
      codec: const ProtoCodec(),
      httpClient: keepaliveHttpClient(),
      interceptors: [LocalAuth.interceptor()],
    );
    _client = SidechainConfServiceClient(transport);
  }

  void _startWatch() {
    _watch ??= StreamOrPoll<WatchSidechainConfigResponse, GetSidechainConfigResponse>(
      // A recreated client replaces _client, so resolve it per call.
      subscribe: () => _client.watchSidechainConfig(GetSidechainConfigRequest(sidechainName: sidechainName)),
      onFrame: applyWatchFrame,
      isHeartbeat: (frame) => frame.heartbeat,
      fetch: () => _client.getSidechainConfig(GetSidechainConfigRequest(sidechainName: sidechainName)),
      onPoll: _apply,
      onPollError: _onLoadError,
      pollInterval: const Duration(seconds: 5),
      onTransportDeath: _initClient,
      logger: _logger,
      tag: 'BackendSidechainConfProvider($sidechainName)',
    )..start();
  }

  /// Applies one WatchSidechainConfig frame.
  @visibleForTesting
  void applyWatchFrame(WatchSidechainConfigResponse frame) {
    if (!frame.heartbeat) {
      _apply(frame.config);
    }
  }

  bool _isConnectionError(Object e) {
    final msg = e.toString();
    return msg.contains('http/2 connection is finishing') ||
        msg.contains('Connection refused') ||
        msg.contains('Connection reset') ||
        msg.contains('Connection terminated');
  }

  Future<void> _loadFromBackend() async {
    try {
      _apply(await _client.getSidechainConfig(GetSidechainConfigRequest(sidechainName: sidechainName)));
    } catch (e) {
      _onLoadError(e);
    }
  }

  /// Reads the config after a write. The stream sends the same change, and a
  /// frame that arrives first wins.
  Future<void> _reload() => _watch?.refresh() ?? _loadFromBackend();

  void _apply(GetSidechainConfigResponse resp) {
    if (resp == _last) {
      return;
    }
    _last = resp;
    configPath = resp.configPath.isEmpty ? null : resp.configPath;
    if (resp.configContent.isNotEmpty) {
      currentConfig = GenericAppConfig.parse(resp.configContent, appName: appName);
    }
    if (resp.network.isNotEmpty) {
      _network = resp.network;
    }
    notifyListeners();
  }

  void _onLoadError(Object e) {
    _logger.e('BackendSidechainConfProvider($sidechainName): failed to load config: $e');
    if (_isConnectionError(e)) {
      _logger.i('BackendSidechainConfProvider($sidechainName): recreating connection');
      _initClient();
    }
  }

  @override
  String get network => _network;

  @override
  String get appName => _appNameValue;

  @override
  String get configFileName => _configFileNameValue;

  @override
  String getDataDir() => _getDataDir();

  @override
  Map<String, String> getNetworkPorts(String network) => _getNetworkPorts(network);

  @override
  String getDefaultConfig() => _getDefaultConfig();

  @override
  List<String> get skippedCliKeys => _skippedCliKeysValue;

  @override
  Future<void> writeConfig(String content) async {
    try {
      await _client.writeSidechainConfig(
        WriteSidechainConfigRequest(sidechainName: sidechainName, configContent: content),
      );
      await _reload();
    } catch (e) {
      _logger.e('BackendSidechainConfProvider($sidechainName): failed to write config: $e');
      rethrow;
    }
  }

  @override
  Future<void> syncNetworkFromBitcoinConf() async {
    try {
      await _client.syncSidechainNetworkFromBitcoinConf(
        SyncSidechainNetworkFromBitcoinConfRequest(sidechainName: sidechainName),
      );
      await _reload();
    } catch (e) {
      _logger.e('BackendSidechainConfProvider($sidechainName): failed to sync network: $e');
    }
  }

  @override
  void dispose() {
    unawaited(_watch?.dispose());
    _watch = null;
    super.dispose();
  }
}
