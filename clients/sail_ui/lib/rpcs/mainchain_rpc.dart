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
  });

  final chain = ParentChain();

  bool inIBD = true;
  bool inHeaderSync = true;

  Future<void> waitForIBD();
  Future<void> waitForHeaderSync();
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
    Binary binary,
  ) async {
    final mainchainLogDir = [ParentChain().datadir(), 'signet', 'debug.log'].join(Platform.pathSeparator);
    final conf = await getMainchainConf();

    final container = MainchainRPCLive._create(
      conf: conf,
      binary: binary,
      logPath: mainchainLogDir,
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
}
