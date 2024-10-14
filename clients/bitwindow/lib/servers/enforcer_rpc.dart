import 'package:sail_ui/classes/node_connection_settings.dart';
import 'package:sail_ui/classes/rpc_connection.dart';

class EnforcerRPC extends RPCConnection {
  EnforcerRPC({required super.conf});

  @override
  List<String> binaryArgs(NodeConnectionSettings mainchainConf) {
    return [
      '--node-rpc-pass=${mainchainConf.password}',
      '--node-rpc-user=${mainchainConf.username}',
      '--node-rpc-addr=${mainchainConf.host}:${mainchainConf.port}',
      '--node-zmq-addr-sequence=tcp://0.0.0.0:29000',
    ];
  }

  @override
  Future<int> ping() async {
    // return anything other than 0 to indicate success
    return 1;
  }

  @override
  Future<void> stop() async {
    // TODO: not implemented
  }
}
