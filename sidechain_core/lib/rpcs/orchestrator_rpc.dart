import 'package:connectrpc/connect.dart';
import 'package:connectrpc/protobuf.dart';
import 'package:sidechain_core/auth/local_auth.dart';
import 'package:sidechain_core/rpcs/keepalive_http_client.dart';
import 'package:connectrpc/protocol/connect.dart' as connect;
import 'package:sidechain_core/gen/bitcoin/bitcoind/v1alpha/bitcoin.connect.client.dart';
import 'package:sidechain_core/gen/orchestrator/v1/orchestrator.connect.client.dart';
import 'package:sidechain_core/gen/orchestrator/v1/orchestrator.pb.dart';
import 'package:sidechain_core/rpcs/orchestrator_bmm_rpc.dart';
import 'package:sidechain_core/rpcs/orchestrator_multisig_lounge_rpc.dart';
import 'package:sidechain_core/rpcs/orchestrator_wallet_rpc.dart';

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
/// The drivechaind endpoint, overridable via --dart-define.
class OrchestratorEndpoint {
  static const host = String.fromEnvironment('ORCHESTRATOR_HOST', defaultValue: '127.0.0.1');
  static const port = int.fromEnvironment('ORCHESTRATOR_PORT', defaultValue: 30400);
  static String get url => 'http://$host:$port';
}

class OrchestratorRPC {
  late final OrchestratorServiceClient _unaryClient;
  late final OrchestratorServiceClient _streamClient;
  late final OrchestratorWalletRPC wallet;
  late final OrchestratorBmmRPC bmm;
  late final OrchestratorMultisigLoungeRPC multisigLounge;

  /// btc-buf BitcoinService — single canonical bitcoind proxy for all
  /// callers. Routes peers / mempool / fee / blocks / PSBT helpers.
  late final BitcoinServiceClient bitcoind;
  final String _host;
  final int _port;

  ({HttpClient client, void Function() close}) _unaryPool = closableUnaryHttpClient();
  HttpClient _streamPool = streamingHttpClient();

  OrchestratorRPC({required this._host, required this._port}) {
    final unaryTransport = connect.Transport(
      baseUrl: _baseUrl,
      codec: const ProtoCodec(),
      // Both transports read the pool per request rather than capture one, so
      // a rebuild never strands a client a consumer already holds. BMMProvider
      // caches its wrapper for the life of the app.
      httpClient: (req) => _unaryPool.client(req),
      interceptors: [LocalAuth.interceptor()],
    );
    final streamTransport = connect.Transport(
      baseUrl: _baseUrl,
      codec: const ProtoCodec(),
      httpClient: (req) => _streamPool(req),
      interceptors: [LocalAuth.interceptor()],
    );
    _unaryClient = OrchestratorServiceClient(unaryTransport);
    _streamClient = OrchestratorServiceClient(streamTransport);
    wallet = OrchestratorWalletRPC.fromTransports(unary: unaryTransport, stream: streamTransport);
    bmm = OrchestratorBmmRPC.fromTransports(unary: unaryTransport, stream: streamTransport);
    multisigLounge = OrchestratorMultisigLoungeRPC.fromTransport(unaryTransport);
    bitcoind = BitcoinServiceClient(unaryTransport);
  }

  String get _baseUrl => 'http://$_host:$_port';

  /// Replace the socket pool behind both transports. Called by
  /// [StreamSupervisor] when it classifies an error as transport-level
  /// (GOAWAY, PROTOCOL_ERROR, half-open detected by watchdog). Both pools go
  /// because the failure mode that knocks out HTTP/2 streams (network drop,
  /// sleep) also typically invalidates HTTP/1.1 keepalive connections.
  ///
  /// The old pool closes, or its sockets stay open until GC runs. This fires
  /// on a tight loop while the daemon is still coming up, so leaking them
  /// exhausts the process file descriptors.
  void recreateConnection() {
    // Silent — this fires constantly during boot while the daemon is still
    // coming up. The supervisor's own attempt counter surfaces a warning
    // once it's clearly stuck.
    final previous = _unaryPool;
    _unaryPool = closableUnaryHttpClient();
    previous.close();
    _streamPool = streamingHttpClient();
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
    if (!isHttp2ConnectionError(e)) {
      return false;
    }
    recreateConnection();
    return true;
  }

  // ─── unary ────────────────────────────────────────────────────────────────

  /// Sidechains pass forceBackend: true so the status describes the daemon
  /// they run, not the test build BitWindow launches.
  Future<ListBinariesResponse> listBinaries({bool forceBackend = false}) {
    return _unaryClient.listBinaries(ListBinariesRequest(forceBackend: forceBackend));
  }

  Future<GetBinaryStatusResponse> getBinaryStatus(String name, {bool forceBackend = false}) {
    return _unaryClient.getBinaryStatus(GetBinaryStatusRequest(name: name, forceBackend: forceBackend));
  }

  /// Resolve a binary's path + --version server-side. The orchestrator owns
  /// path resolution (variant- and test-build aware), so the frontend never
  /// guesses. Sidechains pass forceBackend: true to read the prod Rust node.
  Future<GetBinaryVersionResponse> getBinaryVersion(String name, {bool forceBackend = false}) {
    return _unaryClient.getBinaryVersion(
      GetBinaryVersionRequest(name: name, forceBackend: forceBackend),
    );
  }

  /// Drop a block the node must not follow. Core rejects it and every block
  /// above it, keeps them all on disk, then takes the best remaining branch.
  Future<RejectBlockResponse> rejectBlock({
    required String blockHash,
    int enforcerWaitSeconds = 0,
  }) {
    return _unaryClient.rejectBlock(
      RejectBlockRequest(
        blockHash: blockHash,
        enforcerWaitSeconds: enforcerWaitSeconds,
      ),
    );
  }

  /// Undo [rejectBlock], so the node may follow that branch again.
  Future<AcceptBlockResponse> acceptBlock({required String blockHash}) {
    return _unaryClient.acceptBlock(AcceptBlockRequest(blockHash: blockHash));
  }

  /// Move the chain back to a block, then sync forward to the tip again.
  /// [target] takes a height or a 64-character hash. Emits one message per
  /// phase, and the last message carries the enforcer result.
  Stream<ResetToBlockResponse> resetToBlock({
    required String target,
    int enforcerWaitSeconds = 0,
  }) {
    return _streamClient.resetToBlock(
      ResetToBlockRequest(target: target, enforcerWaitSeconds: enforcerWaitSeconds),
    );
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

  /// Sidechains pass forceBackend: true to stop the daemon without closing
  /// themselves — they are the GUI the orchestrator would otherwise stop too.
  Future<StopBinaryResponse> stopBinary(String name, {bool force = false, bool forceBackend = false}) {
    return _unaryClient.stopBinary(StopBinaryRequest(name: name, force: force, forceBackend: forceBackend));
  }

  Future<GetBTCPriceResponse> getBTCPrice() {
    return _unaryClient.getBTCPrice(GetBTCPriceRequest());
  }

  Future<GetMainchainBlockchainInfoResponse> getMainchainBlockchainInfo() {
    return _unaryClient.getMainchainBlockchainInfo(GetMainchainBlockchainInfoRequest());
  }

  /// Canonical eCash fork state from the orchestrator's ForkEngine — the single
  /// source of truth. Carries the heights, the claim-before-countdown gate, and
  /// the per-wallet claimable UTXOs. The frontend renders this verbatim and does
  /// no fork math of its own; the sweep spends the UTXOs listed here.
  Future<GetForkStatusResponse> getForkStatus() {
    return _unaryClient.getForkStatus(GetForkStatusRequest());
  }

  /// Atomic snapshot of mainchain + enforcer + every known sidechain.
  /// Each ChainSync also reports download progress: when `is_downloading`
  /// is true, blocks/headers carry MB downloaded / MB total.
  Future<GetSyncStatusResponse> getSyncStatus() {
    return _unaryClient.getSyncStatus(GetSyncStatusRequest());
  }

  /// Snapshot of every binary the orchestrator is currently downloading.
  /// Empty list is the steady state — drives the [DownloadProvider]'s
  /// passive-vs-aggressive cadence.
  Future<GetDownloadStatusResponse> getDownloadStatus() {
    return _unaryClient.getDownloadStatus(GetDownloadStatusRequest());
  }

  Future<GetMainchainBalanceResponse> getMainchainBalance() {
    return _unaryClient.getMainchainBalance(GetMainchainBalanceRequest());
  }

  Future<GetSidechainBalanceResponse> getSidechainBalance(BinaryType sidechain) {
    return _unaryClient.getSidechainBalance(GetSidechainBalanceRequest(sidechain: sidechain));
  }

  Future<GetCoreMempoolInfoResponse> getCoreMempoolInfo() {
    return _unaryClient.getCoreMempoolInfo(GetCoreMempoolInfoRequest());
  }

  Future<GetBmmContextResponse> getBmmContext() {
    return _unaryClient.getBmmContext(GetBmmContextRequest());
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

  /// Gather (no side effects) the files/dirs that would be deleted for the
  /// given per-binary deletion spec. Used to build the reset preview.
  Future<GatherFilesToDeleteResponse> gatherFilesToDelete(List<SingleDeletion> items) {
    return _unaryClient.gatherFilesToDelete(
      GatherFilesToDeleteRequest(items: items),
    );
  }

  /// Fire-and-forget: server kicks off a background download and returns
  /// immediately. Progress is polled out of [getSyncStatus] — the
  /// SyncProvider already shows download MB on the matching sidechain
  /// slot, so callers don't need to subscribe to anything.
  /// Sidechains pass forceBackend: true so an update installs the daemon they
  /// run, not the Flutter bundle BitWindow would launch.
  Future<DownloadBinaryResponse> downloadBinary(String name, {bool force = false, bool forceBackend = false}) {
    return _unaryClient.downloadBinary(DownloadBinaryRequest(name: name, force: force, forceBackend: forceBackend));
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
    bool forceBackend = false,
  }) {
    return _unaryClient.startWithL1(
      StartWithL1Request(
        target: target,
        targetArgs: targetArgs ?? [],
        targetEnv: targetEnv ?? {},
        coreArgs: coreArgs ?? [],
        enforcerArgs: enforcerArgs ?? [],
        immediate: immediate,
        forceBackend: forceBackend,
      ),
    );
  }

  /// Fire-and-forget: stops + starts the named binary on the server. Single-
  /// daemon scope — never touches sibling daemons, so restarting "enforcer"
  /// can't surface a phantom "bitcoind is already running" error on Bitcoin
  /// Core's card. Use this for per-daemon Restart buttons; reserve
  /// [startWithL1] for full-chain bootstrap.
  Future<RestartDaemonResponse> restartDaemon(String name, {bool forceBackend = false}) {
    return _unaryClient.restartDaemon(RestartDaemonRequest(name: name, forceBackend: forceBackend));
  }

  /// Restart the whole L1 stack (bitcoind + enforcer). The orchestrator owns
  /// the stop/start sequence; a not-running daemon is skipped, not an error.
  /// Fire-and-forget — returns once the server dispatches the reboot.
  Future<RestartL1Response> restartL1() {
    return _unaryClient.restartL1(RestartL1Request());
  }

  /// Load a UTXO snapshot into the running Bitcoin Core. Pass exactly one of
  /// [url] or [path]; [sha256] is optional and skips verification when omitted.
  /// Streams download and load progress. Nothing is stopped or deleted — a
  /// snapshot Core refuses arrives as an error carrying Core's own message.
  Stream<ApplyUTXOSnapshotResponse> applyUTXOSnapshot({
    String url = '',
    String path = '',
    String sha256 = '',
  }) {
    return _streamClient.applyUTXOSnapshot(
      ApplyUTXOSnapshotRequest(url: url, path: path, sha256: sha256),
    );
  }

  /// The UTXO snapshot the active network publishes plus the one Bitcoin Core
  /// currently has loaded. Drives the snapshot section in settings.
  Future<GetSnapshotStatusResponse> getSnapshotStatus() {
    return _unaryClient.getSnapshotStatus(GetSnapshotStatusRequest());
  }

  /// The eCash network published but not switched to yet, with the UTXO
  /// snapshot it offers. An empty pendingNetworkId means already current.
  Future<GetPendingNetworkGenerationResponse> getPendingNetworkGeneration() {
    return _unaryClient.getPendingNetworkGeneration(GetPendingNetworkGenerationRequest());
  }

  /// Record the go-ahead to switch to the published eCash network. Applied
  /// on the next backend start, which the caller is responsible for.
  Future<ConfirmPendingNetworkGenerationResponse> confirmPendingNetworkGeneration() {
    return _unaryClient.confirmPendingNetworkGeneration(ConfirmPendingNetworkGenerationRequest());
  }

  Stream<ShutdownAllResponse> shutdownAll({bool force = false}) {
    return _streamClient.shutdownAll(ShutdownAllRequest(force: force));
  }

  /// Detached-daemon shutdown: drivechaind acks immediately and runs the
  /// drain (bitcoind/enforcer/sidechains over up to ~90s) in the background.
  /// Survives the caller's exit. Idempotent. If bitwindow is relaunched
  /// mid-drain, the next [startWithL1] transparently adopts it server-side
  /// — no separate cancel/await calls needed here.
  /// Pass [onlyIfLast] when quitting: the backend then drains only once no
  /// client is left and the owner process is gone.
  Future<ShutdownResponse> shutdown({bool onlyIfLast = false}) {
    return _unaryClient.shutdown(ShutdownRequest(onlyIfLast: onlyIfLast));
  }

  /// Delete the files for [items] (the same selection passed to
  /// [gatherFilesToDelete]), skipping any path in [except]. Streams one event
  /// per path; an empty [DeleteFilesResponse.error] means that path succeeded.
  Stream<DeleteFilesResponse> deleteFiles(List<SingleDeletion> items, {List<String> except = const []}) {
    return _streamClient.deleteFiles(DeleteFilesRequest(items: items, except: except));
  }
}
