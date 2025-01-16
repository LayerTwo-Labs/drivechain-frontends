import 'package:bitwindow/gen/cusf/mainchain/v1/validator.pbgrpc.dart';
import 'package:grpc/grpc.dart';
import 'package:sail_ui/classes/node_connection_settings.dart';
import 'package:sail_ui/classes/rpc_connection.dart';

/// API to the drivechain server.
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

  EnforcerLive({
    required super.conf,
    required super.binary,
    required super.logPath,
  }) {
    final channel = ClientChannel(
      'localhost',
      port: binary.port,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
      ),
    );

    validator = ValidatorServiceClient(channel);
  }

  @override
  Future<List<String>> binaryArgs(NodeConnectionSettings mainchainConf) async {
    var host = mainchainConf.host;
    if (host == 'localhost') {
      host = '0.0.0.0';
    }

    return [
      '--node-rpc-pass=${mainchainConf.password}',
      '--node-rpc-user=${mainchainConf.username}',
      '--node-rpc-addr=$host:${mainchainConf.port}',
      '--node-zmq-addr-sequence=tcp://0.0.0.0:29000',
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
  Future<void> stop() async {
    // TODO: not implemented!
  }
}
