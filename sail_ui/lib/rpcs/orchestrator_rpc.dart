import 'package:connectrpc/protobuf.dart';
import 'package:sail_ui/rpcs/keepalive_http_client.dart';
import 'package:connectrpc/protocol/connect.dart' as connect;
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/gen/orchestrator/v1/orchestrator.connect.client.dart';
import 'package:sail_ui/gen/orchestrator/v1/orchestrator.pb.dart';
import 'package:sail_ui/rpcs/orchestrator_wallet_rpc.dart';

/// RPC client for the orchestrator daemon.
/// Wraps the generated OrchestratorServiceClient for binary management.
class OrchestratorRPC {
  late OrchestratorServiceClient _client;
  late OrchestratorWalletRPC wallet;
  final String _host;
  final int _port;

  OrchestratorRPC({required String host, required int port}) : _host = host, _port = port {
    _initializeConnection();
  }

  void _initializeConnection() {
    final transport = connect.Transport(
      baseUrl: 'http://$_host:$_port',
      codec: const ProtoCodec(),
      httpClient: keepaliveHttpClient(),
    );
    _client = OrchestratorServiceClient(transport);
    wallet = OrchestratorWalletRPC.fromTransport(transport);
  }

  /// Drop the dead HTTP/2 connection and rebuild the transport. The Dart
  /// connectrpc client doesn't auto-recover from a `GOAWAY`/connection-reset,
  /// so a single transport failure poisons every subsequent call (including
  /// the WatchWalletData stream's reconnect). Callers can pair this with
  /// [recreateIfHttp2Error] to retry once on the rebuilt transport.
  void recreateConnection() {
    final logger = GetIt.I.isRegistered<Logger>() ? GetIt.I.get<Logger>() : null;
    logger?.w('OrchestratorRPC: recreating HTTP/2 connection');
    _initializeConnection();
  }

  static bool isHttp2ConnectionError(Object e) {
    final s = e.toString().toLowerCase();
    return s.contains('http/2 connection is finishing') ||
        s.contains('connection closed') ||
        s.contains('stream closed') ||
        s.contains('connection is being forcefully terminated') ||
        s.contains('_cancreatenewstream');
  }

  /// Rebuild the transport iff [e] looks like an HTTP/2 connection failure.
  /// Returns true when the connection was recreated, so callers can decide
  /// whether to retry the operation.
  bool recreateIfHttp2Error(Object e) {
    if (!isHttp2ConnectionError(e)) return false;
    recreateConnection();
    return true;
  }

  Future<ListBinariesResponse> listBinaries() {
    return _client.listBinaries(ListBinariesRequest());
  }

  Future<GetBinaryStatusResponse> getBinaryStatus(String name) {
    return _client.getBinaryStatus(GetBinaryStatusRequest(name: name));
  }

  Stream<DownloadBinaryResponse> downloadBinary(
    String name, {
    bool force = false,
  }) {
    return _client.downloadBinary(
      DownloadBinaryRequest(name: name, force: force),
    );
  }

  Future<StartBinaryResponse> startBinary(
    String name, {
    List<String>? extraArgs,
    Map<String, String>? env,
  }) {
    return _client.startBinary(
      StartBinaryRequest(
        name: name,
        extraArgs: extraArgs ?? [],
        env: env ?? {},
      ),
    );
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

  Stream<StartWithL1Response> startWithL1(
    String target, {
    List<String>? targetArgs,
    Map<String, String>? targetEnv,
    List<String>? coreArgs,
    List<String>? enforcerArgs,
    bool immediate = false,
  }) {
    return _client.startWithL1(
      StartWithL1Request(
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

  Future<GetBTCPriceResponse> getBTCPrice() {
    return _client.getBTCPrice(GetBTCPriceRequest());
  }

  Future<GetMainchainBlockchainInfoResponse> getMainchainBlockchainInfo() {
    return _client.getMainchainBlockchainInfo(
      GetMainchainBlockchainInfoRequest(),
    );
  }

  Future<GetEnforcerBlockchainInfoResponse> getEnforcerBlockchainInfo() {
    return _client.getEnforcerBlockchainInfo(
      GetEnforcerBlockchainInfoRequest(),
    );
  }

  Future<GetMainchainBalanceResponse> getMainchainBalance() {
    return _client.getMainchainBalance(GetMainchainBalanceRequest());
  }

  Future<PreviewResetDataResponse> previewResetData({
    bool deleteBlockchainData = false,
    bool deleteNodeSoftware = false,
    bool deleteLogs = false,
    bool deleteSettings = false,
    bool deleteWalletFiles = false,
    bool alsoResetSidechains = false,
  }) {
    return _client.previewResetData(
      PreviewResetDataRequest(
        deleteBlockchainData: deleteBlockchainData,
        deleteNodeSoftware: deleteNodeSoftware,
        deleteLogs: deleteLogs,
        deleteSettings: deleteSettings,
        deleteWalletFiles: deleteWalletFiles,
        alsoResetSidechains: alsoResetSidechains,
      ),
    );
  }

  Stream<StreamResetDataResponse> streamResetData({
    bool deleteBlockchainData = false,
    bool deleteNodeSoftware = false,
    bool deleteLogs = false,
    bool deleteSettings = false,
    bool deleteWalletFiles = false,
    bool alsoResetSidechains = false,
  }) {
    return _client.streamResetData(
      StreamResetDataRequest(
        deleteBlockchainData: deleteBlockchainData,
        deleteNodeSoftware: deleteNodeSoftware,
        deleteLogs: deleteLogs,
        deleteSettings: deleteSettings,
        deleteWalletFiles: deleteWalletFiles,
        alsoResetSidechains: alsoResetSidechains,
      ),
    );
  }
}
