//
//  Generated code. Do not modify.
//  source: orchestrator/v1/orchestrator.proto
//

import "package:connectrpc/connect.dart" as connect;
import "orchestrator.pb.dart" as orchestratorv1orchestrator;

abstract final class OrchestratorService {
  /// Fully-qualified name of the OrchestratorService service.
  static const name = 'orchestrator.v1.OrchestratorService';

  /// List all configured binaries and their status.
  static const listBinaries = connect.Spec(
    '/$name/ListBinaries',
    connect.StreamType.unary,
    orchestratorv1orchestrator.ListBinariesRequest.new,
    orchestratorv1orchestrator.ListBinariesResponse.new,
  );

  /// Get the status of a single binary.
  static const getBinaryStatus = connect.Spec(
    '/$name/GetBinaryStatus',
    connect.StreamType.unary,
    orchestratorv1orchestrator.GetBinaryStatusRequest.new,
    orchestratorv1orchestrator.GetBinaryStatusResponse.new,
  );

  /// Download a binary with streaming progress.
  /// Kicks off a download in a background goroutine and returns
  /// immediately. Progress (MB downloaded / total, is_downloading) is
  /// polled out of GetSyncStatus, never tied to this RPC's lifetime — so
  /// a transport blip can't cancel an in-flight download.
  static const downloadBinary = connect.Spec(
    '/$name/DownloadBinary',
    connect.StreamType.unary,
    orchestratorv1orchestrator.DownloadBinaryRequest.new,
    orchestratorv1orchestrator.DownloadBinaryResponse.new,
  );

  /// Start a binary.
  static const startBinary = connect.Spec(
    '/$name/StartBinary',
    connect.StreamType.unary,
    orchestratorv1orchestrator.StartBinaryRequest.new,
    orchestratorv1orchestrator.StartBinaryResponse.new,
  );

  /// Stop a binary.
  static const stopBinary = connect.Spec(
    '/$name/StopBinary',
    connect.StreamType.unary,
    orchestratorv1orchestrator.StopBinaryRequest.new,
    orchestratorv1orchestrator.StopBinaryResponse.new,
  );

  /// Stream stdout/stderr from a binary.
  static const streamLogs = connect.Spec(
    '/$name/StreamLogs',
    connect.StreamType.server,
    orchestratorv1orchestrator.StreamLogsRequest.new,
    orchestratorv1orchestrator.StreamLogsResponse.new,
  );

  /// Kick off a binary and its full L1 dependency chain (Core -> Enforcer ->
  /// target). Fire-and-forget on the server: returns as soon as the boot
  /// goroutine is dispatched. Callers poll GetSyncStatus / ListBinaries for
  /// download progress and connection state — never tied to this RPC's
  /// lifetime, so a transport blip can't kill an in-flight download.
  static const startWithL1 = connect.Spec(
    '/$name/StartWithL1',
    connect.StreamType.unary,
    orchestratorv1orchestrator.StartWithL1Request.new,
    orchestratorv1orchestrator.StartWithL1Response.new,
  );

  /// Shutdown all running binaries.
  static const shutdownAll = connect.Spec(
    '/$name/ShutdownAll',
    connect.StreamType.server,
    orchestratorv1orchestrator.ShutdownAllRequest.new,
    orchestratorv1orchestrator.ShutdownAllResponse.new,
  );

  /// Get the current BTC/USD exchange rate.
  static const getBTCPrice = connect.Spec(
    '/$name/GetBTCPrice',
    connect.StreamType.unary,
    orchestratorv1orchestrator.GetBTCPriceRequest.new,
    orchestratorv1orchestrator.GetBTCPriceResponse.new,
  );

  /// Get blockchain info from Bitcoin Core (proxied via orchestrator).
  static const getMainchainBlockchainInfo = connect.Spec(
    '/$name/GetMainchainBlockchainInfo',
    connect.StreamType.unary,
    orchestratorv1orchestrator.GetMainchainBlockchainInfoRequest.new,
    orchestratorv1orchestrator.GetMainchainBlockchainInfoResponse.new,
  );

  /// Get blockchain info from the enforcer (proxied via orchestrator).
  static const getEnforcerBlockchainInfo = connect.Spec(
    '/$name/GetEnforcerBlockchainInfo',
    connect.StreamType.unary,
    orchestratorv1orchestrator.GetEnforcerBlockchainInfoRequest.new,
    orchestratorv1orchestrator.GetEnforcerBlockchainInfoResponse.new,
  );

  /// One-shot snapshot of mainchain + enforcer + bitwindow daemon sync state.
  /// Backend fans out to all three in parallel so the three numbers are taken
  /// at the same wall-clock instant — no two cards in the UI can ever disagree.
  static const getSyncStatus = connect.Spec(
    '/$name/GetSyncStatus',
    connect.StreamType.unary,
    orchestratorv1orchestrator.GetSyncStatusRequest.new,
    orchestratorv1orchestrator.GetSyncStatusResponse.new,
  );

  /// Get wallet balance from Bitcoin Core (proxied via orchestrator).
  static const getMainchainBalance = connect.Spec(
    '/$name/GetMainchainBalance',
    connect.StreamType.unary,
    orchestratorv1orchestrator.GetMainchainBalanceRequest.new,
    orchestratorv1orchestrator.GetMainchainBalanceResponse.new,
  );

  /// Preview what would be deleted for the given reset categories (no side effects).
  static const previewResetData = connect.Spec(
    '/$name/PreviewResetData',
    connect.StreamType.unary,
    orchestratorv1orchestrator.PreviewResetDataRequest.new,
    orchestratorv1orchestrator.PreviewResetDataResponse.new,
  );

  /// Reset/delete data categories. Stops affected binaries, streams each deletion event.
  static const streamResetData = connect.Spec(
    '/$name/StreamResetData',
    connect.StreamType.server,
    orchestratorv1orchestrator.StreamResetDataRequest.new,
    orchestratorv1orchestrator.StreamResetDataResponse.new,
  );

  /// Full bitcoind getmempoolinfo response. Distinct from getrawmempool.
  static const getCoreMempoolInfo = connect.Spec(
    '/$name/GetCoreMempoolInfo',
    connect.StreamType.unary,
    orchestratorv1orchestrator.GetCoreMempoolInfoRequest.new,
    orchestratorv1orchestrator.GetCoreMempoolInfoResponse.new,
  );

  /// Generic raw bitcoind RPC. Optional `wallet` field routes the call to
  /// /wallet/{name} on bitcoind for wallet-scoped RPCs.
  static const coreRawCall = connect.Spec(
    '/$name/CoreRawCall',
    connect.StreamType.unary,
    orchestratorv1orchestrator.CoreRawCallRequest.new,
    orchestratorv1orchestrator.CoreRawCallResponse.new,
  );
}
