import 'dart:async';
import 'dart:io';

import 'package:dart_coin_rpc/dart_coin_rpc.dart';
import 'package:dio/dio.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/sail_ui.dart';

/// RPC connection to the mainchain node. Only really used
/// to set correct conf, and start the binary
abstract class MainchainRPC extends RPCConnection {
  MainchainRPC({
    required super.conf,
    required super.binary,
    required super.logPath,
  });

  Future<void> waitForIBD();

  final chain = ParentChain();

  bool inIBD = true;
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
  });
  static Future<MainchainRPCLive> create(
    NodeConnectionSettings conf,
    Binary binary,
  ) async {
    final mainchainLogDir = [ParentChain().datadir(), 'signet', 'debug.log'].join(Platform.pathSeparator);
    NodeConnectionSettings mainchainConf = NodeConnectionSettings.empty();

    final container = MainchainRPCLive._create(
      conf: mainchainConf,
      binary: binary,
      logPath: mainchainLogDir,
    );
    await container.init();
    return container;
  }

  Future<void> init() async {
    await testConnection();
    pollIBDStatus();
  }

  void pollIBDStatus() async {
    // start off with the assumption that the parent chain is in IBD
    inIBD = true;
    log.i('mainchain init: waiting for initial block download to finish');
    DateTime lastLogTime = DateTime.now();
    while (inIBD) {
      try {
        final info = await getBlockchainInfo();
        // if block height is small, the node have probably not synced headers yet
        inIBD = info.blocks <= 10;

        // Log height every 10 seconds
        if (DateTime.now().difference(lastLogTime).inSeconds >= 10) {
          log.i('Current block height: ${info.blocks}');
          lastLogTime = DateTime.now();
        }
      } catch (error) {
        // probably just cant connect, and is in bootup-phase, which is okay
      } finally {
        // retry querying blockchain info until chain is finished syncing
        await Future.delayed(const Duration(seconds: 1));
      }
    }

    log.i('mainchain init: initial block download finished');

    notifyListeners();

    // ibd is done, and mainchain has successfully started
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
  Future<List<String>> binaryArgs(
    NodeConnectionSettings mainchainConf,
  ) async {
    var baseArgs = bitcoinCoreBinaryArgs(
      conf,
    );
    if (conf.confPath.isNotEmpty) {
      var parts = conf.splitPath(conf.confPath);
      final dataDir = parts.$1;
      // Ensure the directory exists
      Directory(dataDir).createSync(recursive: true);
      baseArgs.add('-datadir=$dataDir');
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

    // Only add sidechain args that aren't already in baseArgs
    final extraArgs = sidechainArgs.where((arg) {
      final paramName = arg.split('=')[0];
      return !baseArgs.any((baseArg) => baseArg.startsWith(paramName));
    }).toList();

    return [...baseArgs, ...extraArgs];
  }

  @override
  Future<void> stop() async {
    await _client().call('stop');
  }

  @override
  Future<int> ping() async {
    final blockHeight = await _client().call('getblockcount') as int;
    return blockHeight;
  }

  Future<BlockchainInfo> getBlockchainInfo() async {
    final confirmedFut = await _client().call('getblockchaininfo');
    return BlockchainInfo.fromMap(confirmedFut);
  }
}
