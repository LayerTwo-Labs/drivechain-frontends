import 'dart:io';

import 'package:connectrpc/connect.dart';
import 'package:sail_ui/classes/node_connection_settings.dart';
import 'package:sail_ui/classes/rpc_connection.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/gen/cusf/mainchain/v1/validator.connect.client.dart';
import 'package:sail_ui/gen/cusf/mainchain/v1/validator.pb.dart';

/// API to the enforcer server
abstract class EnforcerRPC extends RPCConnection {
  EnforcerRPC({
    required super.conf,
    required super.binary,
    required super.logPath,
  });

  ValidatorServiceClient get validator;
}

class EnforcerLive extends EnforcerRPC {
  @override
  late final ValidatorServiceClient validator;

  // Private constructor
  EnforcerLive._create({
    required super.conf,
    required super.binary,
    required super.logPath,
  });

  // Async factory
  static Future<EnforcerLive> create({
    required Binary binary,
    required String logPath,
    required Transport transport,
  }) async {
    final conf = await getMainchainConf();

    final instance = EnforcerLive._create(
      conf: conf,
      binary: binary,
      logPath: logPath,
    );

    await instance._init(transport);
    return instance;
  }

  Future<void> _init(Transport transport) async {
    validator = ValidatorServiceClient(transport);
    await startConnectionTimer();
  }

  @override
  Future<List<String>> binaryArgs(NodeConnectionSettings mainchainConf) async {
    var host = mainchainConf.host;
    if (host == 'localhost' && !Platform.isWindows) {
      host = '0.0.0.0';
    }

    return [
      '--node-rpc-pass=${mainchainConf.password}',
      '--node-rpc-user=${mainchainConf.username}',
      '--node-rpc-addr=$host:${mainchainConf.port}',
      '--node-zmq-addr-sequence=tcp://$host:29000',
      '--enable-wallet',
      '--wallet-auto-create',
    ];
  }

  @override
  Future<int> ping() async {
    final res = await validator.getChainTip(GetChainTipRequest());
    return res.blockHeaderInfo.height;
  }

  @override
  Future<(double, double)> balance() async {
    return (0.0, 0.0);
  }

  @override
  Future<void> stopRPC() async {
    throw Exception('stop not implemented');
  }

  @override
  Future<BlockchainInfo> getBlockchainInfo() async {
    throw Exception('getBlockchainInfo not implemented');
  }
}
