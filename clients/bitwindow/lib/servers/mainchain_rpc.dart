import 'dart:async';
import 'dart:io';

import 'package:dart_coin_rpc/dart_coin_rpc.dart';
import 'package:dio/dio.dart';
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

  Future<List<UTXO>> listUnspent();
  Future<String> signMessage(String address, String message);
  Future<bool> verifyMessage(String address, String signature, String message);

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
    String binary,
    String logPath,
  ) async {
    final container = MainchainRPCLive._create(
      conf: conf,
      binary: binary,
      logPath: logPath,
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

        if (inIBD) {
          final now = DateTime.now();
          if (now.difference(lastLogTime).inSeconds >= 5) {
            log.i('mainchain init: still in IBD, block height: ${info.blocks}');
            lastLogTime = now;
          }
        }
      } catch (e) {
        log.e('mainchain init: could not get blockchain info', error: e);
      }

      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  @override
  Future<void> waitForIBD() async {
    while (inIBD) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  @override
  Future<List<UTXO>> listUnspent() async {
    final response = await _client().call('listunspent');
    return (response as List).map((utxo) => UTXO.fromMap(utxo)).toList();
  }

  @override
  Future<String> signMessage(String address, String message) async {
    final response = await _client().call('signmessage', [address, message]);
    return response as String;
  }

  @override
  Future<bool> verifyMessage(String address, String signature, String message) async {
    final response = await _client().call('verifymessage', [address, signature, message]);
    return response as bool;
  }

  @override
  Future<int> ping() async {
    final info = await getBlockchainInfo();
    return info.blocks;
  }

  Future<BlockchainInfo> getBlockchainInfo() async {
    final response = await _client().call('getblockchaininfo');
    return BlockchainInfo.fromMap(response);
  }

  @override
  Future<List<String>> binaryArgs(
    NodeConnectionSettings mainchainConf,
  ) async {
    final baseArgs = bitcoinCoreBinaryArgs(
      conf,
    );
    var parts = conf.splitPath(conf.confPath);
    final dataDir = parts.$1;
    // Ensure the directory exists
    Directory(dataDir).createSync(recursive: true);

    final sidechainArgs = [
      '-datadir=$dataDir',
      '-signet',
      '-server',
      '-addnode=drivechain.live:8383',
      '-signetblocktime=60',
      '-signetchallenge=00141f61d57873d70d28bd28b3c9f9d6bf818b5a0d6a',
      '-listen',
      '-rpcbind=0.0.0.0',
      '-rpcallowip=0.0.0.0/0',
      '-debug=rpc',
      '-debug=net',
      '-txindex',
      '-fallbackfee=0.00021',
      '-zmqpubsequence=tcp://0.0.0.0:29000',
    ];

    // Check if the data directory exists before starting the node
    if (!await Directory(dataDir).exists()) {
      log.e('Data directory "$dataDir" does not exist. Please create it manually.');
    }

    return [...baseArgs, ...sidechainArgs];
  }

  @override
  Future<void> stop() async {
    await _client().call('stop');
  }
}
