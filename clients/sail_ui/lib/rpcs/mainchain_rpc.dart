import 'dart:async';
import 'dart:io';

import 'package:dart_coin_rpc/dart_coin_rpc.dart';
import 'package:dio/dio.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/env.dart';
import 'package:sail_ui/sail_ui.dart';

/// RPC connection to the mainchain node. Only really used
/// to set correct conf, and start the binary
abstract class MainchainRPC extends RPCConnection {
  MainchainRPC({
    required super.conf,
    required super.binary,
    required super.logPath,
    required super.restartOnFailure,
  });

  final chain = ParentChain();

  bool inIBD = true;
  bool inHeaderSync = true;

  Future<void> waitForIBD();
  Future<void> waitForHeaderSync();
  Future<dynamic> callRAW(String method, [List<dynamic>? params]);
  List<String> getMethods();
  Future<List<PeerInfo>> getPeerInfo();
}

class MainchainRPCLive extends MainchainRPC {
  RPCClient _client() {
    final client = RPCClient(
      host: conf.host,
      port: conf.port,
      username: conf.username,
      password: conf.password,
      useSSL: false,
    );

    // Completely empty client, with no retry logic.
    client.dioClient = Dio();
    return client;
  }

  // hacky way to create an async class
  // https://stackoverflow.com/a/59304510
  MainchainRPCLive._create({
    required super.conf,
    required super.binary,
    required super.logPath,
    required super.restartOnFailure,
  });
  static Future<MainchainRPCLive> create(
    Binary binary,
  ) async {
    final mainchainLogDir = [ParentChain().datadir(), 'signet', 'debug.log'].join(Platform.pathSeparator);
    final conf = await getMainchainConf();

    final container = MainchainRPCLive._create(
      conf: conf,
      binary: binary,
      logPath: mainchainLogDir,
      restartOnFailure: false,
    );
    await container.init();
    return container;
  }

  Future<void> init() async {
    if (Environment.isInTest) {
      return;
    }
    pollIBDStatus();
    await startConnectionTimer();
  }

  void pollIBDStatus() {
    // start off with the assumption that the parent chain is in IBD
    inIBD = true;
    inHeaderSync = true;
    log.i('mainchain init: starting IBD status polling');

    Timer.periodic(const Duration(seconds: 1), (timer) async {
      try {
        final info = await getBlockchainInfo();

        // Update header sync status
        final wasInHeaderSync = inHeaderSync;
        inHeaderSync = info.blocks < 10;

        // Update IBD status
        final wasInIBD = inIBD;
        inIBD = inHeaderSync || info.initialBlockDownload;

        // Only notify if status changed
        if (wasInHeaderSync != inHeaderSync || wasInIBD != inIBD) {
          log.i('IBD status changed - inHeaderSync: $inHeaderSync, inIBD: $inIBD');
          notifyListeners();
        }
      } catch (error) {
        // probably just cant connect, and is in bootup-phase, which is okay
      }
    });
  }

  @override
  Future<void> waitForIBD() async {
    int lastLoggedThousand = 0;
    while (inIBD) {
      try {
        final info = await getBlockchainInfo();
        int currentThousand = (info.blocks / 1000).floor();
        if (currentThousand > lastLoggedThousand) {
          log.w('Synced ${info.blocks} blocks');
          lastLoggedThousand = currentThousand;
        }
      } finally {
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  @override
  Future<void> waitForHeaderSync() async {
    while (inHeaderSync) {
      // pollIBDStatus() is responsible for updating the syncedHeaders
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  @override
  Future<List<String>> binaryArgs(
    NodeConnectionSettings mainchainConf,
  ) async {
    log.i('Getting binary args for mainchain');
    var baseArgs = bitcoinCoreBinaryArgs(
      conf,
    );
    log.d('Base bitcoin core args: $baseArgs');

    if (conf.confPath.isNotEmpty) {
      log.d('Config path is not empty: ${conf.confPath}');
      var parts = conf.splitPath(conf.confPath);
      final dataDir = parts.$1;
      log.d('Data directory path: $dataDir');

      // Ensure the directory exists
      Directory(dataDir).createSync(recursive: true);
      log.i('Created data directory at: $dataDir');

      baseArgs.add('-datadir=$dataDir');
      log.d('Added datadir arg: -datadir=$dataDir');
    }

    final sidechainArgs = [
      '-signet',
      '-server',
      '-addnode=172.105.148.135:38333',
      '-signetblocktime=60',
      '-signetchallenge=00141551188e5153533b4fdd555449e640d9cc129456',
      '-acceptnonstdtxn',
      '-listen',
      '-rpcbind=0.0.0.0',
      '-rpcallowip=0.0.0.0/0',
      '-txindex',
      '-fallbackfee=0.00021',
      '-zmqpubsequence=tcp://0.0.0.0:29000',
    ];
    log.d('Sidechain specific args: $sidechainArgs');

    final finalArgs = cleanArgs(conf, sidechainArgs);
    log.i('Final binary args: $finalArgs');
    return finalArgs;
  }

  @override
  Future<dynamic> callRAW(String method, [dynamic params]) async {
    return await _client().call(method, params).catchError((err) {
      log.t('rpc: $method threw exception: $err');
      throw err;
    });
  }

  @override
  Future<void> stopRPC() async {
    await _client().call('stop');
    // can't trust the rpc, give it a moment to stop
    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  Future<int> ping() async {
    final blockHeight = await _client().call('getblockcount') as int;
    return blockHeight;
  }

  @override
  Future<(double, double)> balance() async {
    final confirmedFut = _client().call('getbalance');
    final unconfirmedFut = _client().call('getunconfirmedbalance');

    return (await confirmedFut as double, await unconfirmedFut as double);
  }

  @override
  Future<BlockchainInfo> getBlockchainInfo() async {
    final info = await _client().call('getblockchaininfo');
    return BlockchainInfo.fromMap(info);
  }

  @override
  Future<List<PeerInfo>> getPeerInfo() async {
    final info = await _client().call('getpeerinfo') as List;
    return info.map((peer) => PeerInfo.fromMap(peer)).toList();
  }

  @override
  List<String> getMethods() {
    return [
      'dumptxoutset',
      'getbestblockhash',
      'getblock',
      'getblockchaininfo',
      'getblockcount',
      'getblockfilter',
      'getblockfrompeer',
      'getblockhash',
      'getblockheader',
      'getblockstats',
      'getchainstates',
      'getchaintips',
      'getchaintxstats',
      'getdeploymentinfo',
      'getdifficulty',
      'getmempoolancestors',
      'getmempooldescendants',
      'getmempoolentry',
      'getmempoolinfo',
      'getrawmempool',
      'gettxout',
      'gettxoutproof',
      'gettxoutsetinfo',
      'gettxspendingprevout',
      'importmempool',
      'loadtxoutset',
      'preciousblock',
      'pruneblockchain',
      'savemempool',
      'scanblocks',
      'scantxoutset',
      'verifychain',
      'verifytxoutproof',
      'getmemoryinfo',
      'getrpcinfo',
      'help',
      'logging',
      'stop',
      'uptime',
      'getblocktemplate',
      'getmininginfo',
      'getnetworkhashps',
      'getprioritisedtransactions',
      'prioritisetransaction',
      'submitblock',
      'submitheader',
      'addnode',
      'clearbanned',
      'disconnectnode',
      'getaddednodeinfo',
      'getaddrmaninfo',
      'getconnectioncount',
      'getnettotals',
      'getnetworkinfo',
      'getnodeaddresses',
      'getpeerinfo',
      'listbanned',
      'ping',
      'setban',
      'setnetworkactive',
      'analyzepsbt',
      'combinepsbt',
      'combinerawtransaction',
      'converttopsbt',
      'createpsbt',
      'createrawtransaction',
      'decodepsbt',
      'decoderawtransaction',
      'decodescript',
      'descriptorprocesspsbt',
      'finalizepsbt',
      'fundrawtransaction',
      'getrawtransaction',
      'joinpsbts',
      'sendrawtransaction',
      'signrawtransactionwithkey',
      'submitpackage',
      'testmempoolaccept',
      'utxoupdatepsbt',
      'abandontransaction',
      'abortrescan',
      'addmultisigaddress',
      'backupwallet',
      'bumpfee',
      'createwallet',
      'dumpprivkey',
      'dumpwallet',
      'encryptwallet',
      'getaddressesbylabel',
      'getaddressinfo',
      'getbalance',
      'getbalances',
      'getnewaddress',
      'getrawchangeaddress',
      'getreceivedbyaddress',
      'getreceivedbylabel',
      'gettransaction',
      'getunconfirmedbalance',
      'getwalletinfo',
      'importaddress',
      'importdescriptors',
      'importmulti',
      'importprivkey',
      'importprunedfunds',
      'importpubkey',
      'importwallet',
      'keypoolrefill',
      'listaddressgroupings',
      'listdescriptors',
      'listlabels',
      'listlockunspent',
      'listreceivedbyaddress',
      'listreceivedbylabel',
      'listsinceblock',
      'listtransactions',
      'listunspent',
      'listwalletdir',
      'listwallets',
      'loadwallet',
      'lockunspent',
      'newkeypool',
      'psbtbumpfee',
      'removeprunedfunds',
      'rescanblockchain',
      'send',
      'sendall',
      'sendmany',
      'sendtoaddress',
      'sethdseed',
      'setlabel',
      'settxfee',
      'setwalletflag',
      'signmessage',
      'signrawtransactionwithwallet',
      'unloadwallet',
      'upgradewallet',
      'walletcreatefundedpsbt',
      'walletdisplayaddress',
      'walletlock',
      'walletpassphrase',
      'walletpassphrasechange',
      'walletprocesspsbt',
    ];
  }
}

class PeerInfo {
  final int id;
  final String addr;
  final String addrBind;
  final String addrLocal;
  final String network;
  final String services;
  final List<String> serviceNames;
  final bool relayTxes;
  final int lastSend;
  final int lastRecv;
  final int lastTransaction;
  final int lastBlock;
  final int bytesSent;
  final int bytesRecv;
  final int connTime;
  final int timeOffset;
  final double pingTime;
  final double minPing;
  final int version;
  final String subVer;
  final bool inbound;
  final bool bip152HbTo;
  final bool bip152HbFrom;
  final int startingHeight;
  final int presyncedHeaders;
  final int syncedHeaders;
  final int syncedBlocks;
  final List<String> inflight;
  final bool addrRelayEnabled;
  final int addrProcessed;
  final int addrRateLimited;
  final List<String> permissions;
  final double minFeeFilter;
  final Map<String, int> bytesSentPerMsg;
  final Map<String, int> bytesRecvPerMsg;
  final String connectionType;
  final String transportProtocolType;
  final String sessionId;

  PeerInfo({
    required this.id,
    required this.addr,
    required this.addrBind,
    required this.addrLocal,
    required this.network,
    required this.services,
    required this.serviceNames,
    required this.relayTxes,
    required this.lastSend,
    required this.lastRecv,
    required this.lastTransaction,
    required this.lastBlock,
    required this.bytesSent,
    required this.bytesRecv,
    required this.connTime,
    required this.timeOffset,
    required this.pingTime,
    required this.minPing,
    required this.version,
    required this.subVer,
    required this.inbound,
    required this.bip152HbTo,
    required this.bip152HbFrom,
    required this.startingHeight,
    required this.presyncedHeaders,
    required this.syncedHeaders,
    required this.syncedBlocks,
    required this.inflight,
    required this.addrRelayEnabled,
    required this.addrProcessed,
    required this.addrRateLimited,
    required this.permissions,
    required this.minFeeFilter,
    required this.bytesSentPerMsg,
    required this.bytesRecvPerMsg,
    required this.connectionType,
    required this.transportProtocolType,
    required this.sessionId,
  });

  factory PeerInfo.fromMap(Map<String, dynamic> map) {
    return PeerInfo(
      id: map['id'] ?? 0,
      addr: map['addr'] ?? '',
      addrBind: map['addrbind'] ?? '',
      addrLocal: map['addrlocal'] ?? '',
      network: map['network'] ?? '',
      services: map['services'] ?? '',
      serviceNames: List<String>.from(map['servicesnames'] ?? []),
      relayTxes: map['relaytxes'] ?? false,
      lastSend: map['lastsend'] ?? 0,
      lastRecv: map['lastrecv'] ?? 0,
      lastTransaction: map['last_transaction'] ?? 0,
      lastBlock: map['last_block'] ?? 0,
      bytesSent: map['bytessent'] ?? 0,
      bytesRecv: map['bytesrecv'] ?? 0,
      connTime: map['conntime'] ?? 0,
      timeOffset: map['timeoffset'] ?? 0,
      pingTime: (map['pingtime'] ?? 0.0).toDouble(),
      minPing: (map['minping'] ?? 0.0).toDouble(),
      version: map['version'] ?? 0,
      subVer: map['subver'] ?? '',
      inbound: map['inbound'] ?? false,
      bip152HbTo: map['bip152_hb_to'] ?? false,
      bip152HbFrom: map['bip152_hb_from'] ?? false,
      startingHeight: map['startingheight'] ?? 0,
      presyncedHeaders: map['presynced_headers'] ?? -1,
      syncedHeaders: map['synced_headers'] ?? 0,
      syncedBlocks: map['synced_blocks'] ?? 0,
      inflight: List<String>.from(map['inflight'] ?? []),
      addrRelayEnabled: map['addr_relay_enabled'] ?? false,
      addrProcessed: map['addr_processed'] ?? 0,
      addrRateLimited: map['addr_rate_limited'] ?? 0,
      permissions: List<String>.from(map['permissions'] ?? []),
      minFeeFilter: (map['minfeefilter'] ?? 0.0).toDouble(),
      bytesSentPerMsg: Map<String, int>.from(map['bytessent_per_msg'] ?? {}),
      bytesRecvPerMsg: Map<String, int>.from(map['bytesrecv_per_msg'] ?? {}),
      connectionType: map['connection_type'] ?? '',
      transportProtocolType: map['transport_protocol_type'] ?? '',
      sessionId: map['session_id'] ?? '',
    );
  }

  @override
  String toString() {
    return 'PeerInfo{id: $id, addr: $addr, network: $network, version: $version, subVer: $subVer}';
  }
}
