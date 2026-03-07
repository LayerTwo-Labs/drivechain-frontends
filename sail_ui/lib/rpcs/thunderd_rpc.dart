import 'package:connectrpc/http2.dart';
import 'package:connectrpc/protobuf.dart';
import 'package:connectrpc/protocol/connect.dart' as connect;
import 'package:sail_ui/sail_ui.dart';

/// RPC connection for the thunderd Go backend daemon.
/// Wired into the connection polling system so the UI can track
/// whether thunderd is alive, initializing, or dead.
abstract class ThunderdRPC extends RPCConnection {
  ThunderdRPC({
    required super.binaryType,
    required super.restartOnFailure,
  });
}

class ThunderdLive extends ThunderdRPC {
  late OrchestratorServiceClient _client;
  final String host;
  final int port;

  ThunderdLive({this.host = 'localhost', this.port = 30302})
      : super(binaryType: BinaryType.thunderd, restartOnFailure: false) {
    _initializeConnection();
    startConnectionTimer();
  }

  void _initializeConnection() {
    final httpClient = createHttpClient();
    final baseUrl = 'http://$host:$port';
    final transport = connect.Transport(
      baseUrl: baseUrl,
      codec: const ProtoCodec(),
      httpClient: httpClient,
    );
    _client = OrchestratorServiceClient(transport);
  }

  @override
  Future<List<String>> binaryArgs() async {
    return binary.extraBootArgs;
  }

  @override
  Future<int> ping() async {
    final res = await _client.listBinaries(ListBinariesRequest());
    return res.binaries.length;
  }

  @override
  List<String> startupErrors() {
    return [];
  }

  @override
  Future<(double, double)> balance() async {
    return (0.0, 0.0);
  }

  @override
  Future<void> stopRPC() async {
    // thunderd is managed by the Dart process manager, not via RPC stop
  }

  @override
  Future<BlockchainInfo> getBlockchainInfo() async {
    return BlockchainInfo.empty();
  }
}
