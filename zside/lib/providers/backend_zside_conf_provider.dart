import 'dart:async';

import 'package:connectrpc/http2.dart';
import 'package:connectrpc/protobuf.dart';
import 'package:connectrpc/protocol/connect.dart' as connect;
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/env.dart';
import 'package:sail_ui/gen/orchestrator/v1/zside_conf.connect.client.dart';
import 'package:sail_ui/gen/orchestrator/v1/zside_conf.pb.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:zside/providers/zside_conf_provider.dart';

/// RPC-backed ZSide configuration provider.
/// Calls ZSideConfService on zsided instead of reading/writing files.
/// No file watching, no file writing — all through RPC.
class BackendZSideConfProvider extends ZSideConfProvider {
  final Logger _logger = GetIt.I.get<Logger>();
  late ZSideConfServiceClient _client;
  Timer? _pollTimer;

  BackendZSideConfProvider._() : super.protected();

  static Future<BackendZSideConfProvider> create() async {
    final instance = BackendZSideConfProvider._();
    instance._initClient();
    await instance._loadFromBackend();
    instance._startPolling();
    return instance;
  }

  void _initClient() {
    final transport = connect.Transport(
      baseUrl: 'http://localhost:30303',
      codec: const ProtoCodec(),
      httpClient: createHttpClient(),
    );
    _client = ZSideConfServiceClient(transport);
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
      final resp = await _client.getZSideConfig(GetZSideConfigRequest());

      configPath = resp.configPath.isEmpty ? null : resp.configPath;

      if (resp.configContent.isNotEmpty) {
        currentConfig = GenericAppConfig.parse(resp.configContent, appName: appName);
      }

      notifyListeners();
    } catch (e) {
      _logger.e('BackendZSideConfProvider: failed to load config: $e');
      if (_isConnectionError(e)) {
        _logger.i('BackendZSideConfProvider: recreating connection');
        _initClient();
      }
    }
  }

  @override
  Future<void> writeConfig(String content) async {
    try {
      await _client.writeZSideConfig(WriteZSideConfigRequest(configContent: content));
      await _loadFromBackend();
    } catch (e) {
      _logger.e('BackendZSideConfProvider: failed to write config: $e');
      rethrow;
    }
  }

  @override
  Future<void> syncNetworkFromBitcoinConf() async {
    try {
      await _client.syncNetworkFromBitcoinConf(ZSideSyncNetworkFromBitcoinConfRequest());
      await _loadFromBackend();
    } catch (e) {
      _logger.e('BackendZSideConfProvider: failed to sync network: $e');
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}
