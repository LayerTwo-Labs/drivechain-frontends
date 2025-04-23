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
  Future<MempoolInfo> getMempoolInfo();
  Future<TxOutsetInfo> getTxOutsetInfo();
  Future<NetworkInfo> getNetworkInfo();
  Future<MiningInfo> getMiningInfo();
  Future<String> getDataDir();
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
    final conf = await readConf();

    final container = MainchainRPCLive._create(
      conf: conf,
      binary: binary,
      logPath: mainchainLogDir,
      restartOnFailure: false,
    );
    container.init();
    return container;
  }

  void init() {
    if (Environment.isInTest) {
      return;
    }
    pollIBDStatus();
    startConnectionTimer();
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
  }

  @override
  Future<int> ping() async {
    final blockHeight = await _client().call('getblockcount') as int;
    return blockHeight;
  }

  @override
  List<String> startupErrors() {
    return [
      'Loading block index',
    ];
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

  @override
  Future<MempoolInfo> getMempoolInfo() async {
    final info = await _client().call('getmempoolinfo');
    return MempoolInfo.fromMap(info);
  }

  @override
  Future<TxOutsetInfo> getTxOutsetInfo() async {
    final info = await _client().call('gettxoutsetinfo');
    return TxOutsetInfo.fromMap(info);
  }

  @override
  Future<NetworkInfo> getNetworkInfo() async {
    final info = await _client().call('getnetworkinfo');
    return NetworkInfo.fromMap(info);
  }

  @override
  Future<MiningInfo> getMiningInfo() async {
    final info = await _client().call('getmininginfo');
    return MiningInfo.fromMap(info);
  }

  @override
  Future<String> getDataDir() async {
    final info = await _client().call('getrpcinfo');
    final logPath = info['logpath'] as String;
    // Remove debug.log from path
    return logPath.replaceAll('/debug.log', '');
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

class MempoolInfo {
  final bool loaded;
  final int size;
  final int bytes;
  final int usage;
  final double totalFee;
  final int maxMempool;
  final double mempoolMinFee;
  final double minRelayTxFee;
  final double incrementalRelayFee;
  final int unbroadcastCount;
  final bool fullRBF;

  MempoolInfo({
    required this.loaded,
    required this.size,
    required this.bytes,
    required this.usage,
    required this.totalFee,
    required this.maxMempool,
    required this.mempoolMinFee,
    required this.minRelayTxFee,
    required this.incrementalRelayFee,
    required this.unbroadcastCount,
    required this.fullRBF,
  });

  factory MempoolInfo.fromMap(Map<String, dynamic> map) {
    return MempoolInfo(
      loaded: map['loaded'] ?? false,
      size: map['size'] ?? 0,
      bytes: map['bytes'] ?? 0,
      usage: map['usage'] ?? 0,
      totalFee: (map['total_fee'] ?? 0.0).toDouble(),
      maxMempool: map['maxmempool'] ?? 0,
      mempoolMinFee: (map['mempoolminfee'] ?? 0.0).toDouble(),
      minRelayTxFee: (map['minrelaytxfee'] ?? 0.0).toDouble(),
      incrementalRelayFee: (map['incrementalrelayfee'] ?? 0.0).toDouble(),
      unbroadcastCount: map['unbroadcastcount'] ?? 0,
      fullRBF: map['fullrbf'] ?? false,
    );
  }
}

class TxOutsetInfo {
  final int height;
  final String bestBlock;
  final int txOuts;
  final int bogoSize;
  final String hashSerialized;
  final double totalAmount;
  final int transactions;
  final int diskSize;

  TxOutsetInfo({
    required this.height,
    required this.bestBlock,
    required this.txOuts,
    required this.bogoSize,
    required this.hashSerialized,
    required this.totalAmount,
    required this.transactions,
    required this.diskSize,
  });

  factory TxOutsetInfo.fromMap(Map<String, dynamic> map) {
    return TxOutsetInfo(
      height: map['height'] ?? 0,
      bestBlock: map['bestblock'] ?? '',
      txOuts: map['txouts'] ?? 0,
      bogoSize: map['bogosize'] ?? 0,
      hashSerialized: map['hash_serialized_3'] ?? '',
      totalAmount: (map['total_amount'] ?? 0.0).toDouble(),
      transactions: map['transactions'] ?? 0,
      diskSize: map['disk_size'] ?? 0,
    );
  }
}

class NetworkInfo {
  final int version;
  final String subversion;
  final int protocolVersion;
  final String localServices;

  NetworkInfo({
    required this.version,
    required this.subversion,
    required this.protocolVersion,
    required this.localServices,
  });

  factory NetworkInfo.fromMap(Map<String, dynamic> map) {
    return NetworkInfo(
      version: map['version'] ?? 0,
      subversion: map['subversion'] ?? '',
      protocolVersion: map['protocolversion'] ?? 0,
      localServices: map['localservices'] ?? '',
    );
  }
}

class MiningInfo {
  final int blocks;
  final int currentBlockWeight;
  final int currentBlockTx;
  final double difficulty;
  final double networkHashPs;
  final int pooledTx;
  final String chain;
  final List<String> warnings;

  MiningInfo({
    required this.blocks,
    required this.currentBlockWeight,
    required this.currentBlockTx,
    required this.difficulty,
    required this.networkHashPs,
    required this.pooledTx,
    required this.chain,
    required this.warnings,
  });

  factory MiningInfo.fromMap(Map<String, dynamic> map) {
    return MiningInfo(
      blocks: map['blocks'] ?? 0,
      currentBlockWeight: map['currentblockweight'] ?? 0,
      currentBlockTx: map['currentblocktx'] ?? 0,
      difficulty: (map['difficulty'] ?? 0.0).toDouble(),
      networkHashPs: (map['networkhashps'] ?? 0.0).toDouble(),
      pooledTx: map['pooledtx'] ?? 0,
      chain: map['chain'] ?? '',
      warnings: List<String>.from(map['warnings'] ?? []),
    );
  }
}
