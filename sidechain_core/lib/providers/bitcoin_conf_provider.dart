import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:connectrpc/protobuf.dart';
import 'package:connectrpc/protocol/connect.dart' as connect;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/env.dart';
import 'package:sidechain_core/sidechain_core.dart';

/// Thrown when the user declines a requirement the backend reported, so the
/// change is abandoned rather than applied half-way.
class NetworkChangeDeclined implements Exception {
  final BitcoinNetwork network;
  NetworkChangeDeclined(this.network);

  @override
  String toString() => 'network change to $network declined';
}

/// Bitcoin Core configuration provider backed by orchestrator's BitcoinConfService.
/// All reads/writes go through the backend — no local file access.
class BitcoinConfProvider extends ChangeNotifier {
  /// UI hook for picking a bitcoin datadir; assigned by the app layer.
  static Future<String?> Function(BuildContext, BitcoinNetwork)? promptForDataDir;

  final Logger log = GetIt.I.get<Logger>();
  late BitcoinConfServiceClient _client;
  Timer? _pollTimer;

  bool hasPrivateBitcoinConf = false;
  String? configPath;
  BitcoinNetwork network = BitcoinNetwork.BITCOIN_NETWORK_SIGNET;
  String? defaultDatadir;
  String? forknetDatadir;
  String? drynetDatadir;

  /// Live drynet generation ("drynet2"), from the orchestrator. Drynet
  /// hostnames are built from it, so it moves with the network.
  String drynetGeneration = '';
  BitcoinConfig? currentConfig;
  late final RootStackRouter router;

  /// The datadir for the currently active network — same as
  /// [dataDirFor]([network]).
  String? get detectedDataDir => dataDirFor(network);

  /// Returns the datadir recorded for [n]'s datadir group, or null if
  /// none is configured. Forknet and drynet each have their own group;
  /// everything else shares the default group (Bitcoin Core auto-partitions
  /// via chain subdirs).
  String? dataDirFor(BitcoinNetwork n) {
    if (n == BitcoinNetwork.BITCOIN_NETWORK_FORKNET) {
      return forknetDatadir;
    }
    if (n == BitcoinNetwork.BITCOIN_NETWORK_DRYNET) {
      return drynetDatadir;
    }
    return defaultDatadir;
  }

  bool get networkSupportsSidechains {
    return network == BitcoinNetwork.BITCOIN_NETWORK_FORKNET ||
        network == BitcoinNetwork.BITCOIN_NETWORK_DRYNET ||
        network == BitcoinNetwork.BITCOIN_NETWORK_SIGNET ||
        network == BitcoinNetwork.BITCOIN_NETWORK_REGTEST;
  }

  /// Whether the drivechain tier (sidechains, deposits, BMM, two-way-peg) has a
  /// backend on this network. Mainnet runs a wallet-only electrum mode with no
  /// enforcer/orchestrator, so it returns false there.
  bool get drivechainFeaturesAvailable => networkSupportsSidechains;

  int rpcPort = 38332;

  /// True when the active network and wallet backend need a datadir the user
  /// has not chosen. Computed by the backend, polled with the rest of the config.
  bool mustSelectDatadir = false;

  /// bitwindow applies swaps through bitwindowd, which recycles its per-network
  /// database; sidechain apps leave this null and reach orchestratord directly.
  /// Planning always goes straight to orchestratord — it holds the facts.
  Future<void> Function(String network, String dataDir)? networkSwapper;

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
      baseUrl: OrchestratorEndpoint.url,
      codec: const ProtoCodec(),
      httpClient: keepaliveHttpClient(),
      interceptors: [LocalAuth.interceptor()],
    );
    _client = BitcoinConfServiceClient(transport);
  }

  void _startPolling() {
    if (Environment.isInTest) {
      return;
    }
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => loadConfig());
  }

  bool _isConnectionError(Object e) {
    final msg = e.toString();
    return msg.contains('http/2 connection is finishing') ||
        msg.contains('Connection refused') ||
        msg.contains('Connection reset') ||
        msg.contains('Connection terminated');
  }

  Future<void> loadConfig({bool isFirst = false, bool userInitiated = false}) async {
    try {
      final resp = await _client.getBitcoinConfig(GetBitcoinConfigRequest());
      final oldNetwork = network;

      hasPrivateBitcoinConf = resp.hasPrivateConf;
      configPath = resp.configPath.isEmpty ? null : resp.configPath;
      defaultDatadir = resp.defaultDatadir.isEmpty ? null : resp.defaultDatadir;
      forknetDatadir = resp.forknetDatadir.isEmpty ? null : resp.forknetDatadir;
      drynetDatadir = resp.drynetDatadir.isEmpty ? null : resp.drynetDatadir;
      drynetGeneration = resp.drynetGeneration;
      rpcPort = resp.rpcPort;
      mustSelectDatadir = resp.mustSelectDatadir;

      network = _parseNetwork(resp.network);

      if (resp.configContent.isNotEmpty) {
        currentConfig = BitcoinConfig.parse(resp.configContent);
      }

      // Only a real user switch refreshes per-network state; the 5s poll must
      // not, or the boot network reconciliation flashes balances.
      if (!isFirst && userInitiated && oldNetwork != network) {
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
    unawaited(NetworkScopedRegistry.clearAll());
  }

  /// Asks the backend what a change would require. It knows the wallet backend,
  /// the datadirs and the binaries; the frontend knows none of that.
  Future<NetworkChangePlan> prepareNetworkChange({
    BitcoinNetwork? targetNetwork,
    String walletId = '',
  }) async {
    final request = PrepareNetworkChangeRequest(
      network: targetNetwork == null ? '' : _networkToString(targetNetwork),
      walletId: walletId,
    );
    return _client.prepareNetworkChange(request);
  }

  Future<void> updateNetwork(BitcoinNetwork newNetwork, {String dataDir = ''}) async {
    try {
      if (networkSwapper != null) {
        await networkSwapper!(_networkToString(newNetwork), dataDir);
      } else {
        await _client.setBitcoinConfigNetwork(
          SetBitcoinConfigNetworkRequest(network: _networkToString(newNetwork), dataDir: dataDir),
        );
      }
      await loadConfig(userInitiated: true);
    } catch (e) {
      log.e('BitcoinConfProvider: failed to update network: $e');
      rethrow;
    }
  }

  Future<void> swapNetwork(BuildContext context, BitcoinNetwork newNetwork) async {
    if (hasPrivateBitcoinConf) {
      return;
    }
    if (network == newNetwork) {
      return;
    }

    final plan = await prepareNetworkChange(targetNetwork: newNetwork);
    if (plan.noOp) {
      return;
    }

    if (!context.mounted) {
      throw NetworkChangeDeclined(newNetwork);
    }
    final dataDir = await resolveNetworkChangePlan(context, plan, newNetwork);
    if (dataDir == null) {
      throw NetworkChangeDeclined(newNetwork);
    }

    await updateNetwork(newNetwork, dataDir: dataDir);
  }

  /// Walks the requirements the backend reported, returning the datadir to
  /// apply with (empty when none was needed) or null if the user backed out.
  Future<String?> resolveNetworkChangePlan(
    BuildContext context,
    NetworkChangePlan plan,
    BitcoinNetwork targetNetwork,
  ) async {
    if (!plan.mustSelectDatadir) {
      return '';
    }

    final selected = await promptForDataDir?.call(context, targetNetwork);
    if (selected == null || selected.isEmpty) {
      return null;
    }
    return selected;
  }

  bool hasDataDirFor(BitcoinNetwork network) {
    final dataDir = dataDirFor(network);
    return dataDir != null && dataDir.isNotEmpty;
  }

  Future<void> updateDataDir(String? dataDir, {required BitcoinNetwork forNetwork}) async {
    try {
      await _client.setBitcoinConfigDataDir(
        SetBitcoinConfigDataDirRequest(
          dataDir: dataDir ?? '',
          network: _networkToString(forNetwork),
        ),
      );
      await loadConfig();
    } catch (e) {
      log.e('BitcoinConfProvider: failed to update datadir: $e');
      rethrow;
    }
  }

  Future<void> commitNetworkChange(BitcoinNetwork newNetwork) async {
    if (hasPrivateBitcoinConf) {
      return;
    }
    if (network == newNetwork) {
      return;
    }
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
      await _client.writeBitcoinConfig(WriteBitcoinConfigRequest(configContent: content));
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
      'drynet' => BitcoinNetwork.BITCOIN_NETWORK_DRYNET,
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
      BitcoinNetwork.BITCOIN_NETWORK_DRYNET => 'drynet',
      BitcoinNetwork.BITCOIN_NETWORK_TESTNET => 'testnet',
      BitcoinNetwork.BITCOIN_NETWORK_SIGNET => 'signet',
      BitcoinNetwork.BITCOIN_NETWORK_REGTEST => 'regtest',
      _ => 'signet',
    };
  }
}

/// Every drynet hostname carries the generation, so read the one the
/// orchestrator resolved rather than pinning a generation in the frontend.
/// Falls back to the generation this build shipped with, which is what the
/// backend also falls back to before its catalog loads.
String drynetGeneration() {
  if (!GetIt.I.isRegistered<BitcoinConfProvider>()) {
    return _fallbackDrynetGeneration;
  }
  final gen = GetIt.I.get<BitcoinConfProvider>().drynetGeneration;
  return gen.isEmpty ? _fallbackDrynetGeneration : gen;
}

const String _fallbackDrynetGeneration = 'drynet2';
