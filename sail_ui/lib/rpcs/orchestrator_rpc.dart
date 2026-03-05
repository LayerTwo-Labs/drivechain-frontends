import 'package:connectrpc/http2.dart';
import 'package:connectrpc/protobuf.dart';
import 'package:connectrpc/protocol/connect.dart' as connect;
import 'package:sail_ui/gen/orchestrator/v1/orchestrator.connect.client.dart';
import 'package:sail_ui/gen/orchestrator/v1/orchestrator.pb.dart';

/// RPC client for the orchestrator daemon (thunderd).
/// Wraps the generated OrchestratorServiceClient for binary management.
class OrchestratorRPC {
  late OrchestratorServiceClient _client;

  OrchestratorRPC({required String host, required int port}) {
    final transport = connect.Transport(
      baseUrl: 'http://$host:$port',
      codec: const ProtoCodec(),
      httpClient: createHttpClient(),
    );
    _client = OrchestratorServiceClient(transport);
  }

  Future<ListBinariesResponse> listBinaries() {
    return _client.listBinaries(ListBinariesRequest());
  }

  Future<GetBinaryStatusResponse> getBinaryStatus(String name) {
    return _client.getBinaryStatus(GetBinaryStatusRequest(name: name));
  }

  Stream<DownloadBinaryResponse> downloadBinary(String name, {bool force = false}) {
    return _client.downloadBinary(DownloadBinaryRequest(name: name, force: force));
  }

  Future<StartBinaryResponse> startBinary(String name, {List<String>? extraArgs, Map<String, String>? env}) {
    return _client.startBinary(StartBinaryRequest(name: name, extraArgs: extraArgs ?? [], env: env ?? {}));
  }

  Future<StopBinaryResponse> stopBinary(String name, {bool force = false}) {
    return _client.stopBinary(StopBinaryRequest(name: name, force: force));
  }

  Stream<WatchBinariesResponse> watchBinaries() {
    return _client.watchBinaries(WatchBinariesRequest());
  }

  Stream<StreamLogsResponse> streamLogs(String name, {int tail = 0}) {
    return _client.streamLogs(StreamLogsRequest(name: name, tail: tail));
  }

  Stream<StartWithDepsResponse> startWithDeps(
    String target, {
    List<String>? targetArgs,
    Map<String, String>? targetEnv,
    List<String>? coreArgs,
    List<String>? enforcerArgs,
    bool immediate = false,
  }) {
    return _client.startWithDeps(
      StartWithDepsRequest(
        target: target,
        targetArgs: targetArgs ?? [],
        targetEnv: targetEnv ?? {},
        coreArgs: coreArgs ?? [],
        enforcerArgs: enforcerArgs ?? [],
        immediate: immediate,
      ),
    );
  }

  Stream<ShutdownAllResponse> shutdownAll({bool force = false}) {
    return _client.shutdownAll(ShutdownAllRequest(force: force));
  }
}
