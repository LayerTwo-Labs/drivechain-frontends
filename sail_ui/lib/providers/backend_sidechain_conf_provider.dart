import 'dart:async';

import 'package:connectrpc/protobuf.dart';
import 'package:connectrpc/protocol/connect.dart' as connect;
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/env.dart';
import 'package:sail_ui/gen/orchestrator/v1/sidechain_conf.connect.client.dart';
import 'package:sail_ui/gen/orchestrator/v1/sidechain_conf.pb.dart';
import 'package:sail_ui/sail_ui.dart';

/// RPC-backed sidechain configuration provider.
/// Calls SidechainConfService on the orchestratord instead of reading/writing files.
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
  Timer? _pollTimer;

  BackendSidechainConfProvider._({
    required this.sidechainName,
    required String appName,
    required String configFileName,
    required String Function() getDataDir,
    required Map<String, String> Function(String network) getNetworkPorts,
    required String Function() getDefaultConfig,
    required List<String> skippedCliKeys,
  }) : _appNameValue = appName,
       _configFileNameValue = configFileName,
       _getDataDir = getDataDir,
       _getNetworkPorts = getNetworkPorts,
       _getDefaultConfig = getDefaultConfig,
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
    instance._startPolling();
    return instance;
  }

  void _initClient() {
    final transport = connect.Transport(
      baseUrl: 'http://localhost:30400',
      codec: const ProtoCodec(),
      httpClient: keepaliveHttpClient(),
    );
    _client = SidechainConfServiceClient(transport);
  }

  void _startPolling() {
    if (Environment.isInTest) return;
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _loadFromBackend());
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
      final resp = await _client.getSidechainConfig(
        GetSidechainConfigRequest(sidechainName: sidechainName),
      );

      configPath = resp.configPath.isEmpty ? null : resp.configPath;

      if (resp.configContent.isNotEmpty) {
        currentConfig = GenericAppConfig.parse(resp.configContent, appName: appName);
      }

      notifyListeners();
    } catch (e) {
      _logger.e('BackendSidechainConfProvider($sidechainName): failed to load config: $e');
      if (_isConnectionError(e)) {
        _logger.i('BackendSidechainConfProvider($sidechainName): recreating connection');
        _initClient();
      }
    }
  }

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
      await _loadFromBackend();
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
      await _loadFromBackend();
    } catch (e) {
      _logger.e('BackendSidechainConfProvider($sidechainName): failed to sync network: $e');
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}
