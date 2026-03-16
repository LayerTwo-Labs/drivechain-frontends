import 'dart:async';

import 'package:connectrpc/http2.dart';
import 'package:connectrpc/protobuf.dart';
import 'package:connectrpc/protocol/connect.dart' as connect;
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/env.dart';
import 'package:sail_ui/sail_ui.dart';

/// RPC-backed implementation of EnforcerConfProvider.
/// Used by Thunder where the Go backend manages enforcer config files.
/// All reads/writes go through EnforcerConfService on thunderd.
class BackendEnforcerConfProvider extends EnforcerConfProvider {
  final Logger log = GetIt.I.get<Logger>();
  late EnforcerConfServiceClient _client;
  Timer? _pollTimer;

  @override
  EnforcerConfig? currentConfig;
  @override
  String? configPath;

  BackendEnforcerConfProvider._create();

  static Future<BackendEnforcerConfProvider> create() async {
    final instance = BackendEnforcerConfProvider._create();
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
    _client = EnforcerConfServiceClient(transport);
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
      final resp = await _client.getEnforcerConfig(GetEnforcerConfigRequest());

      configPath = resp.configPath.isEmpty ? null : resp.configPath;

      if (resp.configContent.isNotEmpty) {
        currentConfig = EnforcerConfig.parse(resp.configContent);
      }

      notifyListeners();
    } catch (e) {
      log.e('BackendEnforcerConfProvider: failed to load config: $e');
      if (_isConnectionError(e)) {
        log.i('BackendEnforcerConfProvider: recreating connection');
        _initClient();
      }
    }
  }

  @override
  bool get nodeRpcDiffers {
    if (currentConfig == null) return false;
    // The backend handles syncing, so just check current state
    final expected = getExpectedNodeRpcSettings();
    final localUser = currentConfig!.getSetting('node-rpc-user') ?? '';
    final localPass = currentConfig!.getSetting('node-rpc-pass') ?? '';
    final localAddr = currentConfig!.getSetting('node-rpc-addr') ?? '';

    return localUser != expected['node-rpc-user'] ||
        localPass != expected['node-rpc-pass'] ||
        localAddr != expected['node-rpc-addr'];
  }

  @override
  Map<String, String> getExpectedNodeRpcSettings() {
    // Derive from BitcoinConfProvider (same logic as frontend)
    const host = '127.0.0.1';
    const defaultZmqSequence = 'tcp://127.0.0.1:29000';
    final bitcoinConfProvider = GetIt.I.get<BitcoinConfProvider>();
    final port = bitcoinConfProvider.rpcPort;

    if (bitcoinConfProvider.currentConfig == null) {
      return {
        'node-rpc-user': 'user',
        'node-rpc-pass': 'password',
        'node-rpc-addr': '$host:$port',
        'node-zmq-addr-sequence': defaultZmqSequence,
      };
    }

    final config = bitcoinConfProvider.currentConfig!;
    final networkSection = (bitcoinConfProvider.network).toCoreNetwork();

    final username = config.getEffectiveSetting('rpcuser', networkSection) ?? 'user';
    final password = config.getEffectiveSetting('rpcpassword', networkSection) ?? 'password';
    final zmqSequence = config.getEffectiveSetting('zmqpubsequence', networkSection) ?? defaultZmqSequence;

    return {
      'node-rpc-user': username,
      'node-rpc-pass': password,
      'node-rpc-addr': '$host:$port',
      'node-zmq-addr-sequence': zmqSequence,
    };
  }

  @override
  Future<void> syncNodeRpcFromBitcoinConf() async {
    try {
      await _client.syncNodeRpcFromBitcoinConf(SyncNodeRpcFromBitcoinConfRequest());
      await _loadFromBackend();
    } catch (e) {
      log.e('BackendEnforcerConfProvider: failed to sync: $e');
    }
  }

  @override
  String? getEsploraUrlForNetwork(BitcoinNetwork network) {
    switch (network) {
      case BitcoinNetwork.BITCOIN_NETWORK_REGTEST:
        return 'http://localhost:3003';
      case BitcoinNetwork.BITCOIN_NETWORK_TESTNET:
        return null;
      case BitcoinNetwork.BITCOIN_NETWORK_SIGNET:
        return 'https://explorer.signet.drivechain.info/api';
      case BitcoinNetwork.BITCOIN_NETWORK_MAINNET:
        return 'https://mempool.space/api';
      case BitcoinNetwork.BITCOIN_NETWORK_FORKNET:
        return 'https://explorer.forknet.drivechain.info/api';
      default:
        return null;
    }
  }

  @override
  List<String> getCliArgs(BitcoinNetwork network) {
    // CLI args are built by the Go backend, not the frontend
    final args = <String>[];
    if (currentConfig == null) return args;

    for (final entry in currentConfig!.settings.entries) {
      final key = entry.key;
      final value = entry.value;
      if (value == 'true') {
        args.add('--$key');
      } else if (value == 'false') {
        continue;
      } else if (value.isNotEmpty) {
        args.add('--$key=$value');
      }
    }
    return args;
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
      await _client.writeEnforcerConfig(WriteEnforcerConfigRequest(configContent: content));
      await _loadFromBackend();
    } catch (e) {
      log.e('BackendEnforcerConfProvider: failed to write config: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}
