//
//  Generated code. Do not modify.
//  source: orchestrator/v1/orchestrator.proto
//

import "package:connectrpc/connect.dart" as connect;
import "orchestrator.pb.dart" as orchestratorv1orchestrator;
import "orchestrator.connect.spec.dart" as specs;

extension type OrchestratorServiceClient(connect.Transport _transport) {
  /// List all configured binaries and their status.
  Future<orchestratorv1orchestrator.ListBinariesResponse> listBinaries(
    orchestratorv1orchestrator.ListBinariesRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.OrchestratorService.listBinaries,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get the status of a single binary.
  Future<orchestratorv1orchestrator.GetBinaryStatusResponse> getBinaryStatus(
    orchestratorv1orchestrator.GetBinaryStatusRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.OrchestratorService.getBinaryStatus,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Download a binary with streaming progress.
  /// Kicks off a download in a background goroutine and returns
  /// immediately. Progress (MB downloaded / total, is_downloading) is
  /// polled out of GetSyncStatus, never tied to this RPC's lifetime — so
  /// a transport blip can't cancel an in-flight download.
  Future<orchestratorv1orchestrator.DownloadBinaryResponse> downloadBinary(
    orchestratorv1orchestrator.DownloadBinaryRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.OrchestratorService.downloadBinary,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Start a binary.
  Future<orchestratorv1orchestrator.StartBinaryResponse> startBinary(
    orchestratorv1orchestrator.StartBinaryRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.OrchestratorService.startBinary,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Stop a binary.
  Future<orchestratorv1orchestrator.StopBinaryResponse> stopBinary(
    orchestratorv1orchestrator.StopBinaryRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.OrchestratorService.stopBinary,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Stream stdout/stderr from a binary.
  Stream<orchestratorv1orchestrator.StreamLogsResponse> streamLogs(
    orchestratorv1orchestrator.StreamLogsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.OrchestratorService.streamLogs,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Kick off a binary and its full L1 dependency chain (Core -> Enforcer ->
  /// target). Fire-and-forget on the server: returns as soon as the boot
  /// goroutine is dispatched. Callers poll GetSyncStatus / ListBinaries for
  /// download progress and connection state — never tied to this RPC's
  /// lifetime, so a transport blip can't kill an in-flight download.
  Future<orchestratorv1orchestrator.StartWithL1Response> startWithL1(
    orchestratorv1orchestrator.StartWithL1Request input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.OrchestratorService.startWithL1,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Shutdown all running binaries.
  Stream<orchestratorv1orchestrator.ShutdownAllResponse> shutdownAll(
    orchestratorv1orchestrator.ShutdownAllRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.OrchestratorService.shutdownAll,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get the current BTC/USD exchange rate.
  Future<orchestratorv1orchestrator.GetBTCPriceResponse> getBTCPrice(
    orchestratorv1orchestrator.GetBTCPriceRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.OrchestratorService.getBTCPrice,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get blockchain info from Bitcoin Core (proxied via orchestrator).
  Future<orchestratorv1orchestrator.GetMainchainBlockchainInfoResponse> getMainchainBlockchainInfo(
    orchestratorv1orchestrator.GetMainchainBlockchainInfoRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.OrchestratorService.getMainchainBlockchainInfo,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get blockchain info from the enforcer (proxied via orchestrator).
  Future<orchestratorv1orchestrator.GetEnforcerBlockchainInfoResponse> getEnforcerBlockchainInfo(
    orchestratorv1orchestrator.GetEnforcerBlockchainInfoRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.OrchestratorService.getEnforcerBlockchainInfo,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// One-shot snapshot of mainchain + enforcer + bitwindow daemon sync state.
  /// Backend fans out to all three in parallel so the three numbers are taken
  /// at the same wall-clock instant — no two cards in the UI can ever disagree.
  Future<orchestratorv1orchestrator.GetSyncStatusResponse> getSyncStatus(
    orchestratorv1orchestrator.GetSyncStatusRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.OrchestratorService.getSyncStatus,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get wallet balance from Bitcoin Core (proxied via orchestrator).
  Future<orchestratorv1orchestrator.GetMainchainBalanceResponse> getMainchainBalance(
    orchestratorv1orchestrator.GetMainchainBalanceRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.OrchestratorService.getMainchainBalance,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Preview what would be deleted for the given reset categories (no side effects).
  Future<orchestratorv1orchestrator.PreviewResetDataResponse> previewResetData(
    orchestratorv1orchestrator.PreviewResetDataRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.OrchestratorService.previewResetData,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Reset/delete data categories. Stops affected binaries, streams each deletion event.
  Stream<orchestratorv1orchestrator.StreamResetDataResponse> streamResetData(
    orchestratorv1orchestrator.StreamResetDataRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.OrchestratorService.streamResetData,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Full bitcoind getmempoolinfo response. Distinct from getrawmempool.
  Future<orchestratorv1orchestrator.GetCoreMempoolInfoResponse> getCoreMempoolInfo(
    orchestratorv1orchestrator.GetCoreMempoolInfoRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.OrchestratorService.getCoreMempoolInfo,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Generic raw bitcoind RPC. Optional `wallet` field routes the call to
  /// /wallet/{name} on bitcoind for wallet-scoped RPCs.
  Future<orchestratorv1orchestrator.CoreRawCallResponse> coreRawCall(
    orchestratorv1orchestrator.CoreRawCallRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.OrchestratorService.coreRawCall,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
