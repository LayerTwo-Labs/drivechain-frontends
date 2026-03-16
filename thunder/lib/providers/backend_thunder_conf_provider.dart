import 'dart:async';

import 'package:connectrpc/http2.dart';
import 'package:connectrpc/protobuf.dart';
import 'package:connectrpc/protocol/connect.dart' as connect;
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/env.dart';
import 'package:sail_ui/gen/orchestrator/v1/thunder_conf.connect.client.dart';
import 'package:sail_ui/gen/orchestrator/v1/thunder_conf.pb.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:thunder/providers/thunder_conf_provider.dart';

/// RPC-backed Thunder configuration provider.
/// Calls ThunderConfService on thunderd instead of reading/writing files.
/// No file watching, no file writing — all through RPC.
class BackendThunderConfProvider extends ThunderConfProvider {
  final Logger _logger = GetIt.I.get<Logger>();
  late ThunderConfServiceClient _client;
  Timer? _pollTimer;

  BackendThunderConfProvider._() : super.protected();

  static Future<BackendThunderConfProvider> create() async {
    final instance = BackendThunderConfProvider._();
    instance._initClient();
    await instance._loadFromBackend();
    instance._startPolling();
    return instance;
  }

  void _initClient() {
    final transport = connect.Transport(
      baseUrl: 'http://localhost:30302',
      codec: const ProtoCodec(),
      httpClient: createHttpClient(),
    );
    _client = ThunderConfServiceClient(transport);
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
      final resp = await _client.getThunderConfig(GetThunderConfigRequest());

      configPath = resp.configPath.isEmpty ? null : resp.configPath;

      if (resp.configContent.isNotEmpty) {
        currentConfig = GenericAppConfig.parse(resp.configContent, appName: appName);
      }

      notifyListeners();
    } catch (e) {
      _logger.e('BackendThunderConfProvider: failed to load config: $e');
      if (_isConnectionError(e)) {
        _logger.i('BackendThunderConfProvider: recreating connection');
        _initClient();
      }
    }
  }

  @override
  Future<void> writeConfig(String content) async {
    try {
      await _client.writeThunderConfig(WriteThunderConfigRequest(configContent: content));
      await _loadFromBackend();
    } catch (e) {
      _logger.e('BackendThunderConfProvider: failed to write config: $e');
      rethrow;
    }
  }

  @override
  Future<void> syncNetworkFromBitcoinConf() async {
    try {
      await _client.syncNetworkFromBitcoinConf(SyncNetworkFromBitcoinConfRequest());
      await _loadFromBackend();
    } catch (e) {
      _logger.e('BackendThunderConfProvider: failed to sync network: $e');
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}
