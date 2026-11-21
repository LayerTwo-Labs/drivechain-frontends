import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:logger/logger.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sidechain_core/sidechain_core.dart';

const _version = 1;

/// The state that the first frame of the root page needs, from the last session.
class BootSnapshot {
  final GetBitcoinConfigResponse config;
  final List<NetworkOption> networks;
  final wmpb.GetNodeModeResponse nodeMode;
  final List<WalletMetadata> wallets;
  final String? activeWalletId;
  final bool encrypted;

  BootSnapshot({
    required this.config,
    required this.networks,
    required this.nodeMode,
    required this.wallets,
    required this.activeWalletId,
    required this.encrypted,
  });

  /// True when the root page can show before the backend answers: the user
  /// picked a node mode, and a wallet with no password exists.
  bool get showsRootAtOnce => nodeMode.mode != wmpb.NodeMode.NODE_MODE_UNSPECIFIED && wallets.isNotEmpty && !encrypted;

  static File file(Directory appDir) => File('${appDir.path}${Platform.pathSeparator}boot_state.json');

  /// Reads the snapshot of the last session. Null when no snapshot of this version exists.
  static BootSnapshot? read(Directory appDir) {
    final f = file(appDir);
    if (!f.existsSync()) {
      return null;
    }
    final json = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
    if (json['v'] != _version) {
      return null;
    }
    return BootSnapshot(
      config: GetBitcoinConfigResponse.fromBuffer(base64Decode(json['config'] as String)),
      networks: [
        for (final n in json['networks'] as List<dynamic>) NetworkOption.fromBuffer(base64Decode(n as String)),
      ],
      nodeMode: wmpb.GetNodeModeResponse.fromBuffer(base64Decode(json['node_mode'] as String)),
      wallets: [
        for (final w in json['wallets'] as List<dynamic>)
          WalletMetadata(
            id: w['id'] as String,
            name: w['name'] as String,
            gradient: WalletGradient.fromJson(w['gradient'] as Map<String, dynamic>),
            createdAt: DateTime.parse(w['created_at'] as String),
            lastUsed: DateTime.parse(w['created_at'] as String),
          ),
      ],
      activeWalletId: json['active_wallet_id'] as String?,
      encrypted: json['encrypted'] as bool,
    );
  }

  String encode() => jsonEncode({
    'v': _version,
    'config': base64Encode(_shown(config).writeToBuffer()),
    'networks': [for (final n in networks) base64Encode(n.writeToBuffer())],
    'node_mode': base64Encode(nodeMode.writeToBuffer()),
    'wallets': [
      for (final w in wallets)
        {'id': w.id, 'name': w.name, 'gradient': w.gradient.toJson(), 'created_at': w.createdAt.toIso8601String()},
    ],
    'active_wallet_id': activeWalletId,
    'encrypted': encrypted,
  });

  /// Gives the providers the state of the last session.
  void restore({required NodeModeProvider nodeMode, required WalletReaderProvider walletReader}) {
    nodeMode.restore(this.nodeMode);
    if (!encrypted) {
      walletReader.restore(wallets: wallets, activeWalletId: activeWalletId);
    }
  }

  RestoredBitcoinConfig get restoredConfig => (config: config, networks: networks);
}

/// Writes a [BootSnapshot] each time the backend state of the three providers changes.
class BootSnapshotWriter {
  final Directory appDir;
  final BitcoinConfProvider conf;
  final NodeModeProvider nodeMode;
  final WalletReaderProvider walletReader;
  final Logger log;

  /// The snapshot on disk.
  String? written;
  Future<void> _writes = Future.value();

  BootSnapshotWriter({
    required this.appDir,
    required this.conf,
    required this.nodeMode,
    required this.walletReader,
    required this.log,
    this.written,
  });

  void start() {
    conf.addListener(_onChange);
    nodeMode.addListener(_onChange);
    walletReader.addListener(_onChange);
  }

  /// The snapshot of the backend state, or null until each provider read the backend.
  BootSnapshot? current() {
    final config = conf.backendConfig;
    if (config == null || !nodeMode.loaded || !walletReader.walletStateKnown) {
      return null;
    }
    return BootSnapshot(
      config: config,
      networks: conf.networks,
      nodeMode: nodeMode.state,
      wallets: walletReader.availableWallets,
      activeWalletId: walletReader.activeWalletId,
      encrypted: walletReader.encrypted,
    );
  }

  /// Completes when each write that started is on disk.
  Future<void> flush() => _writes;

  void _onChange() {
    final encoded = current()?.encode();
    if (encoded == null || encoded == written) {
      return;
    }
    written = encoded;
    _writes = _writes.then((_) => _write(encoded)).catchError((Object e) {
      log.e('BootSnapshotWriter: could not write ${BootSnapshot.file(appDir).path}: $e');
    });
  }

  Future<void> _write(String encoded) async {
    final target = BootSnapshot.file(appDir);
    final temp = File('${target.path}.$pid.tmp');
    await temp.writeAsString(encoded, flush: true);
    await temp.rename(target.path);
  }
}

/// The fields the app shows. The file keeps no conf text and no RPC credentials.
GetBitcoinConfigResponse _shown(GetBitcoinConfigResponse c) => GetBitcoinConfigResponse(
  network: c.network,
  rpcPort: c.rpcPort,
  hasPrivateConf: c.hasPrivateConf,
  configPath: c.configPath,
  detectedDataDir: c.detectedDataDir,
  networkSupportsSidechains: c.networkSupportsSidechains,
  isDemoMode: c.isDemoMode,
  defaultDatadir: c.defaultDatadir,
  ecashDatadir: c.ecashDatadir,
  ecashNetworkId: c.ecashNetworkId,
  mustSelectDatadir: c.mustSelectDatadir,
  ecashEsploraUrl: c.ecashEsploraUrl,
  ecashExplorerHost: c.ecashExplorerHost,
);
