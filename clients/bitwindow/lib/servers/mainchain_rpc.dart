import 'dart:async';

import 'package:dart_coin_rpc/dart_coin_rpc.dart';
import 'package:dio/dio.dart';
import 'package:sail_ui/sail_ui.dart';

/// RPC connection to the mainchain node. Only really used
/// to set correct conf, and start the binary
abstract class MainchainRPC extends RPCConnection {
  MainchainRPC({required super.conf});

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
  MainchainRPCLive._create({required super.conf});
  static Future<MainchainRPCLive> create(NodeConnectionSettings conf) async {
    final container = MainchainRPCLive._create(conf: conf);
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
    while (inIBD) {
      try {
        final info = await getBlockchainInfo();
        // if block height is 0, the node might have not synced headers yet, and believe
        // height 1 is the current best height
        inIBD = info.initialBlockDownload || info.blockHeight <= 1;
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
    while (inIBD) {
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  @override
  List<String> binaryArgs(
    NodeConnectionSettings mainchainConf,
  ) {
    final baseArgs = bitcoinCoreBinaryArgs(
      conf,
    );
    final sidechainArgs = [
      '-conf=${mainchainConf.confPath}',
    ];
    return [...baseArgs, ...sidechainArgs];
  }

  @override
  Future<void> stopNode() async {
    await _client().call('stop');
  }

  @override
  Future<int> getBlockCount() async {
    final blockHeight = await _client().call('getblockcount') as int;
    return blockHeight;
  }

  @override
  Future<BlockchainInfo> getBlockchainInfo() async {
    final confirmedFut = await _client().call('getblockchaininfo');
    return BlockchainInfo.fromMap(confirmedFut);
  }
}
