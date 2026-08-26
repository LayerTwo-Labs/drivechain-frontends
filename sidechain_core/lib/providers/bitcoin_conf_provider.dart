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
  String? ecashDatadir;

  /// Live eCash network id ("alphanet"), from the orchestrator.
  String ecashNetworkId = '';

  /// The networks the user can pick, from the published catalog plus regtest.
  /// Empty until the first load; callers fall back to [network] alone.
  List<NetworkOption> networks = [];

  /// Esplora base URL the catalog publishes for the live eCash network.
  String ecashEsploraUrl = '';

  /// Explorer host the catalog publishes for the live eCash network.
  String ecashExplorerHost = '';
  BitcoinConfig? currentConfig;
  late final RootStackRouter router;

  /// The datadir for the currently active network — same as
  /// [dataDirFor]([network]).
  String? get detectedDataDir => dataDirFor(network);

  /// Returns the datadir recorded for [n]'s datadir group, or null if
  /// none is configured. Forknet and eCash each have their own group;
  /// everything else shares the default group (Bitcoin Core auto-partitions
  /// via chain subdirs).
  String? dataDirFor(BitcoinNetwork n) {
    if (n == BitcoinNetwork.BITCOIN_NETWORK_FORKNET) {
      return forknetDatadir;
    }
    if (n == BitcoinNetwork.BITCOIN_NETWORK_ECASH) {
      return ecashDatadir;
    }
    return defaultDatadir;
  }

  bool get networkSupportsSidechains {
    return network == BitcoinNetwork.BITCOIN_NETWORK_FORKNET ||
        network == BitcoinNetwork.BITCOIN_NETWORK_ECASH ||
        network == BitcoinNetwork.BITCOIN_NETWORK_SIGNET ||
        network == BitcoinNetwork.BITCOIN_NETWORK_REGTEST;
  }

  /// Whether the drivechain tier (sidechains, deposits, BMM, two-way-peg) has a
  /// backend on this network. Mainnet runs a wallet-only electrum mode with no
  /// enforcer/orchestrator, so it returns false there.
  bool get drivechainFeaturesAvailable => networkSupportsSidechains;

  /// Whether the running network derives keys under Bitcoin mainnet
  /// parameters. Forknet and eCash fork mainnet, so they share its coin type
  /// and address prefixes; the orchestrator maps all three to MainNetParams.
  bool get usesMainnetParams {
    return network == BitcoinNetwork.BITCOIN_NETWORK_MAINNET ||
        network == BitcoinNetwork.BITCOIN_NETWORK_FORKNET ||
        network == BitcoinNetwork.BITCOIN_NETWORK_ECASH;
  }

  int rpcPort = 38332;

  /// True when the active network and wallet backend need a datadir the user
  /// has not chosen. Computed by the backend, polled with the rest of the config.
  bool mustSelectDatadir = false;

  /// bitwindow applies swaps through bitwindowd, which recycles its per-network
  /// database; sidechain apps leave this null and reach drivechaind directly.
  /// Planning always goes straight to drivechaind — it holds the facts.
  Future<void> Function(String network, String dataDir, String networkId)? networkSwapper;

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
      final oldECashNetworkId = ecashNetworkId;

      hasPrivateBitcoinConf = resp.hasPrivateConf;
      configPath = resp.configPath.isEmpty ? null : resp.configPath;
      defaultDatadir = resp.defaultDatadir.isEmpty ? null : resp.defaultDatadir;
      forknetDatadir = resp.forknetDatadir.isEmpty ? null : resp.forknetDatadir;
      ecashDatadir = resp.ecashDatadir.isEmpty ? null : resp.ecashDatadir;
      ecashNetworkId = resp.ecashNetworkId;
      ecashEsploraUrl = resp.ecashEsploraUrl;
      ecashExplorerHost = resp.ecashExplorerHost;
      networks = (await _client.listNetworks(ListNetworksRequest())).networks;
      rpcPort = resp.rpcPort;
      mustSelectDatadir = resp.mustSelectDatadir;

      network = _parseNetwork(resp.network);

      if (resp.configContent.isNotEmpty) {
        currentConfig = BitcoinConfig.parse(resp.configContent);
      }

      // Only a real user switch refreshes per-network state; the 5s poll must
      // not, or the boot network reconciliation flashes balances.
      //
      // The eCash rows share one BitcoinNetwork, so the id has to count as a
      // change too. Without it the outgoing fork's blocks and balances stay on
      // screen, and BlockchainProvider only fills an empty list — so they never
      // go away.
      final movedChain =
          oldNetwork != network ||
          (network == BitcoinNetwork.BITCOIN_NETWORK_ECASH &&
              oldECashNetworkId.isNotEmpty &&
              oldECashNetworkId != ecashNetworkId);
      if (!isFirst && userInitiated && movedChain) {
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
  /// [networkId] is the catalog id the user picked. The backend takes it in
  /// place of the slot name: the eCash rows share a slot, so only the id says
  /// the chain moves.
  Future<NetworkChangePlan> prepareNetworkChange({
    BitcoinNetwork? targetNetwork,
    String walletId = '',
    String networkId = '',
  }) async {
    final target = networkId.isNotEmpty
        ? networkId
        : targetNetwork == null
        ? ''
        : _networkToString(targetNetwork);
    final request = PrepareNetworkChangeRequest(network: target, walletId: walletId);
    return _client.prepareNetworkChange(request);
  }

  /// [networkId] is the catalog id the user picked. The eCash entries share one
  /// [BitcoinNetwork] slot, so the id is the only thing that names the fork.
  Future<void> updateNetwork(BitcoinNetwork newNetwork, {String dataDir = '', String networkId = ''}) async {
    try {
      if (networkSwapper != null) {
        // bitwindowd keys its own runtime on the network, and forwards the id
        // to the orchestrator. Sending it the id alone makes it reject the row.
        await networkSwapper!(_networkToString(newNetwork), dataDir, networkId);
      } else {
        final target = networkId.isEmpty ? _networkToString(newNetwork) : networkId;
        await _client.setBitcoinConfigNetwork(
          SetBitcoinConfigNetworkRequest(network: target, dataDir: dataDir),
        );
      }
      await loadConfig(userInitiated: true);
    } catch (e) {
      log.e('BitcoinConfProvider: failed to update network: $e');
      rethrow;
    }
  }

  Future<void> swapNetwork(BuildContext context, BitcoinNetwork newNetwork, {String networkId = ''}) async {
    if (hasPrivateBitcoinConf) {
      return;
    }
    // An eCash id change keeps the slot, so compare the id too or a switch
    // from one eCash fork to another reads as a no-op.
    if (network == newNetwork && (networkId.isEmpty || networkId == ecashNetworkId)) {
      return;
    }

    final plan = await prepareNetworkChange(targetNetwork: newNetwork, networkId: networkId);
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

    await updateNetwork(newNetwork, dataDir: dataDir, networkId: networkId);
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

  /// The picker rows: every catalog entry the app can run, plus regtest. Before
  /// the first load lands it is the running network alone, so a dropdown always
  /// holds its own current value and never asserts.
  List<NetworkOption> get networkOptions {
    final active = _activeNetworkOption;
    if (networks.isEmpty) {
      return [active];
    }
    // The catalog lists no forknet and no testnet, and an install can run
    // either. A dropdown whose value is missing from its items asserts.
    if (networks.any((o) => o.isCurrent)) {
      return networks;
    }
    return [...networks, active];
  }

  NetworkOption get _activeNetworkOption => NetworkOption(
    id: _networkToString(network),
    displayName: network.toDisplayName(),
    network: _networkToString(network),
    isCurrent: true,
  );

  /// The id of the row this install runs, for a dropdown's current value.
  String get currentNetworkOptionId {
    final options = networkOptions;
    return options.firstWhere((o) => o.isCurrent, orElse: () => options.first).id;
  }

  /// Picker rows that carry sidechains. Mainnet is real Bitcoin and testnet
  /// runs no drivechain, so neither belongs here: offering one gives the user a
  /// row that switches to nothing and leaves the guard still blocking.
  List<NetworkOption> get drivechainNetworkOptions =>
      networkOptions.where((o) => o.network != 'mainnet' && o.network != 'testnet').toList();

  /// The row a sidechain selector shows. The running network may carry no
  /// sidechains and so appear in no row, and a dropdown whose value is missing
  /// from its items asserts.
  String get currentDrivechainOptionId {
    final options = drivechainNetworkOptions;
    if (options.isEmpty) {
      return currentNetworkOptionId;
    }
    final current = currentNetworkOptionId;
    return options.any((o) => o.id == current) ? current : options.first.id;
  }

  /// The networks the catalog added since the last call. The backend reports
  /// each one once, so a caller that polls never repeats a notice.
  Future<List<NetworkOption>> takeNewNetworks() async {
    final resp = await _client.takeNewNetworks(TakeNewNetworksRequest());
    return resp.networks;
  }

  /// What a move to another eCash network costs. Both fork mainnet, so the
  /// blocks below the lower fork height are shared: the move resets the chain
  /// to that block instead of downloading it again.
  Future<PlanECashSwitchResponse> planECashSwitch(String networkId) =>
      _client.planECashSwitch(PlanECashSwitchRequest(networkId: networkId));

  /// The picker row with this catalog id, or null when the list has none.
  NetworkOption? optionById(String id) {
    for (final option in networkOptions) {
      if (option.id == id) {
        return option;
      }
    }
    return null;
  }

  /// The slot a picker row runs in.
  BitcoinNetwork networkFromOption(NetworkOption option) => _parseNetwork(option.network);

  /// Switch to a picker row by its catalog id. The eCash rows share one
  /// [BitcoinNetwork], so the id decides which fork boots.
  Future<void> swapNetworkById(BuildContext context, String id) async {
    final option = networkOptions.firstWhere((o) => o.id == id, orElse: () => NetworkOption());
    if (option.id.isEmpty) {
      return;
    }
    await swapNetwork(context, _parseNetwork(option.network), networkId: option.id);
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
      'ecash' => BitcoinNetwork.BITCOIN_NETWORK_ECASH,
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
      BitcoinNetwork.BITCOIN_NETWORK_ECASH => 'ecash',
      BitcoinNetwork.BITCOIN_NETWORK_TESTNET => 'testnet',
      BitcoinNetwork.BITCOIN_NETWORK_SIGNET => 'signet',
      BitcoinNetwork.BITCOIN_NETWORK_REGTEST => 'regtest',
      _ => 'signet',
    };
  }
}

/// The live eCash network id, as the orchestrator resolved it from the
/// published catalog. Falls back to the network this build shipped with, which
/// is what the backend also falls back to before its catalog loads.
String ecashNetworkId() => _resolved((p) => p.ecashNetworkId, _fallbackECashNetworkId);

/// The live eCash network's esplora base URL, from the published catalog.
String ecashEsploraUrl() => _resolved((p) => p.ecashEsploraUrl, _fallbackECashEsploraUrl);

/// The live eCash network's explorer host, from the published catalog.
String ecashExplorerHost() => _resolved((p) => p.ecashExplorerHost, _fallbackECashExplorerHost);

String _resolved(String Function(BitcoinConfProvider) read, String fallback) {
  if (!GetIt.I.isRegistered<BitcoinConfProvider>()) {
    return fallback;
  }
  final value = read(GetIt.I.get<BitcoinConfProvider>());
  return value.isEmpty ? fallback : value;
}

const String _fallbackECashNetworkId = 'alphanet';
const String _fallbackECashEsploraUrl = 'https://esplora.alpha.ecash.ninja';
const String _fallbackECashExplorerHost = 'explorer.alpha.ecash.ninja';
