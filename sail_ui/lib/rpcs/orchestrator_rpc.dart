import 'package:connectrpc/protobuf.dart';
import 'package:sail_ui/rpcs/keepalive_http_client.dart';
import 'package:connectrpc/protocol/connect.dart' as connect;
import 'package:sail_ui/gen/bitcoin/bitcoind/v1alpha/bitcoin.connect.client.dart';
import 'package:sail_ui/gen/orchestrator/v1/orchestrator.connect.client.dart';
import 'package:sail_ui/gen/orchestrator/v1/orchestrator.pb.dart';
import 'package:sail_ui/rpcs/orchestrator_wallet_rpc.dart';

/// RPC client for the orchestrator daemon.
///
/// Holds two transports against the same backend (h2c on the server accepts
/// either):
/// - **unary client** on HTTP/1.1 — short-lived calls; no shared connection
///   state across calls, so a single failure can't poison subsequent ones.
/// - **stream client** on HTTP/2 — long-lived server-streaming calls;
///   HTTP/2 is the connectrpc-Dart well-trodden path with PING-based
///   liveness, paired with [StreamSupervisor] for application-level
///   reconnect / heartbeat.
class OrchestratorRPC {
  late OrchestratorServiceClient _unaryClient;
  late OrchestratorServiceClient _streamClient;
  late OrchestratorWalletRPC wallet;

  /// btc-buf BitcoinService — single canonical bitcoind proxy for all
  /// callers. Routes peers / mempool / fee / blocks / PSBT helpers.
  late BitcoinServiceClient bitcoind;
  final String _host;
  final int _port;

  OrchestratorRPC({required String host, required int port}) : _host = host, _port = port {
    _initializeConnection();
  }

  String get _baseUrl => 'http://$_host:$_port';

  void _initializeConnection() {
    final unaryTransport = connect.Transport(
      baseUrl: _baseUrl,
      codec: const ProtoCodec(),
      httpClient: unaryHttpClient(),
    );
    final streamTransport = connect.Transport(
      baseUrl: _baseUrl,
      codec: const ProtoCodec(),
      httpClient: streamingHttpClient(),
    );
    _unaryClient = OrchestratorServiceClient(unaryTransport);
    _streamClient = OrchestratorServiceClient(streamTransport);
    wallet = OrchestratorWalletRPC.fromTransports(unary: unaryTransport, stream: streamTransport);
    bitcoind = BitcoinServiceClient(unaryTransport);
  }

  /// Rebuild both transports. Called by [StreamSupervisor] when it
  /// classifies an error as transport-level (GOAWAY, PROTOCOL_ERROR,
  /// half-open detected by watchdog). Both transports are rebuilt because
  /// the failure mode that knocks out HTTP/2 streams (network drop, sleep)
  /// also typically invalidates HTTP/1.1 keepalive connections.
  void recreateConnection() {
    // Silent — this fires constantly during boot while the daemon is still
    // coming up. The supervisor's own attempt counter surfaces a warning
    // once it's clearly stuck.
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
  /// Used by one-shot unary callers that want to retry once after a
  /// transport rebuild — streaming consumers should use [StreamSupervisor]
  /// instead.
  bool recreateIfHttp2Error(Object e) {
    if (!isHttp2ConnectionError(e)) return false;
    recreateConnection();
    return true;
  }

  // ─── unary ────────────────────────────────────────────────────────────────

  Future<ListBinariesResponse> listBinaries() {
    return _unaryClient.listBinaries(ListBinariesRequest());
  }

  Future<GetBinaryStatusResponse> getBinaryStatus(String name) {
    return _unaryClient.getBinaryStatus(GetBinaryStatusRequest(name: name));
  }

  Future<StartBinaryResponse> startBinary(
    String name, {
    List<String>? extraArgs,
    Map<String, String>? env,
  }) {
    return _unaryClient.startBinary(
      StartBinaryRequest(name: name, extraArgs: extraArgs ?? [], env: env ?? {}),
    );
  }

  Future<StopBinaryResponse> stopBinary(String name, {bool force = false}) {
    return _unaryClient.stopBinary(StopBinaryRequest(name: name, force: force));
  }

  Future<GetBTCPriceResponse> getBTCPrice() {
    return _unaryClient.getBTCPrice(GetBTCPriceRequest());
  }

  Future<GetMainchainBlockchainInfoResponse> getMainchainBlockchainInfo() {
    return _unaryClient.getMainchainBlockchainInfo(GetMainchainBlockchainInfoRequest());
  }

  /// Atomic snapshot of mainchain + enforcer + every known sidechain.
  /// Each ChainSync also reports download progress: when `is_downloading`
  /// is true, blocks/headers carry MB downloaded / MB total.
  Future<GetSyncStatusResponse> getSyncStatus() {
    return _unaryClient.getSyncStatus(GetSyncStatusRequest());
  }

  Future<GetMainchainBalanceResponse> getMainchainBalance() {
    return _unaryClient.getMainchainBalance(GetMainchainBalanceRequest());
  }

  Future<GetCoreMempoolInfoResponse> getCoreMempoolInfo() {
    return _unaryClient.getCoreMempoolInfo(GetCoreMempoolInfoRequest());
  }

  Future<CoreRawCallResponse> coreRawCall(
    String method, {
    String paramsJson = '',
    String wallet = '',
  }) {
    return _unaryClient.coreRawCall(
      CoreRawCallRequest(method: method, paramsJson: paramsJson, wallet: wallet),
    );
  }

  Future<PreviewResetDataResponse> previewResetData({
    bool deleteBlockchainData = false,
    bool deleteNodeSoftware = false,
    bool deleteLogs = false,
    bool deleteSettings = false,
    bool deleteWalletFiles = false,
    bool alsoResetSidechains = false,
  }) {
    return _unaryClient.previewResetData(
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

  /// Fire-and-forget: server kicks off a background download and returns
  /// immediately. Progress is polled out of [getSyncStatus] — the
  /// SyncProvider already shows download MB on the matching sidechain
  /// slot, so callers don't need to subscribe to anything.
  Future<DownloadBinaryResponse> downloadBinary(String name, {bool force = false}) {
    return _unaryClient.downloadBinary(DownloadBinaryRequest(name: name, force: force));
  }

  // ─── server-streaming ─────────────────────────────────────────────────────

  Stream<StreamLogsResponse> streamLogs(String name, {int tail = 0}) {
    return _streamClient.streamLogs(StreamLogsRequest(name: name, tail: tail));
  }

  /// Fire-and-forget: server kicks off the boot goroutine and returns
  /// immediately. Download / connection state come from polled
  /// GetSyncStatus and ListBinaries — neither tied to this call's lifetime,
  /// so a transport blip can't kill an in-flight bitcoind download.
  Future<StartWithL1Response> startWithL1(
    String target, {
    List<String>? targetArgs,
    Map<String, String>? targetEnv,
    List<String>? coreArgs,
    List<String>? enforcerArgs,
    bool immediate = false,
  }) {
    return _unaryClient.startWithL1(
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
    return _streamClient.shutdownAll(ShutdownAllRequest(force: force));
  }

  Stream<StreamResetDataResponse> streamResetData({
    bool deleteBlockchainData = false,
    bool deleteNodeSoftware = false,
    bool deleteLogs = false,
    bool deleteSettings = false,
    bool deleteWalletFiles = false,
    bool alsoResetSidechains = false,
  }) {
    return _streamClient.streamResetData(
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
