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

  /// Resolve a binary's on-disk path the same way the launcher does (variant-
  /// and test-build aware, honoring force_backend) and return its --version
  /// output. The frontend must never re-derive the path or shell out itself;
  /// this RPC is the single source of truth for "which binary, what version".
  static const getBinaryVersion = connect.Spec(
    '/$name/GetBinaryVersion',
    connect.StreamType.unary,
    orchestratorv1orchestrator.GetBinaryVersionRequest.new,
    orchestratorv1orchestrator.GetBinaryVersionResponse.new,
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

  /// Stop the named binary and start it again, single-daemon scope. Never
  /// touches sibling daemons: restarting "enforcer" never spawns or adopts
  /// bitcoind. Use this for per-daemon "Restart" buttons on UI cards;
  /// StartWithL1 stays the entry point for full-chain bootstrap. Same
  /// fire-and-forget shape as StartWithL1.
  static const restartDaemon = connect.Spec(
    '/$name/RestartDaemon',
    connect.StreamType.unary,
    orchestratorv1orchestrator.RestartDaemonRequest.new,
    orchestratorv1orchestrator.RestartDaemonResponse.new,
  );

  /// Restart the whole L1 stack (bitcoind + enforcer) on the current config.
  /// Stops both (a not-running daemon is skipped, never an error) then boots
  /// the L1 chain via the same path as StartWithL1. Running sidechains are left
  /// alone — they reconnect once the enforcer is back. Fire-and-forget: returns
  /// as soon as the boot goroutine is dispatched. Use this for the "Restart
  /// Bitcoin Core and Enforcer" UI flow instead of hand-sequencing stop/start.
  static const restartL1 = connect.Spec(
    '/$name/RestartL1',
    connect.StreamType.unary,
    orchestratorv1orchestrator.RestartL1Request.new,
    orchestratorv1orchestrator.RestartL1Response.new,
  );

  /// Load a UTXO snapshot into the running Bitcoin Core. Streams download and
  /// load progress; a snapshot Core refuses (its base block already passed, or
  /// a snapshot already loaded in this datadir) comes back as an error carrying
  /// Core's own message. Nothing is stopped, restarted or deleted.
  static const applyUTXOSnapshot = connect.Spec(
    '/$name/ApplyUTXOSnapshot',
    connect.StreamType.server,
    orchestratorv1orchestrator.ApplyUTXOSnapshotRequest.new,
    orchestratorv1orchestrator.ApplyUTXOSnapshotResponse.new,
  );

  /// The UTXO snapshot published for the active network (from the network
  /// catalog) plus the one currently loaded in Bitcoin Core, if any. Feeds the
  /// settings UI: pre-fills the snapshot field and shows what is loaded.
  static const getSnapshotStatus = connect.Spec(
    '/$name/GetSnapshotStatus',
    connect.StreamType.unary,
    orchestratorv1orchestrator.GetSnapshotStatusRequest.new,
    orchestratorv1orchestrator.GetSnapshotStatusResponse.new,
  );

  /// Shutdown all running binaries.
  static const shutdownAll = connect.Spec(
    '/$name/ShutdownAll',
    connect.StreamType.server,
    orchestratorv1orchestrator.ShutdownAllRequest.new,
    orchestratorv1orchestrator.ShutdownAllResponse.new,
  );

  /// Detached-daemon shutdown. bitwindowd calls this on window close;
  /// orchestratord acks immediately, drains its children (bitcoind, enforcer,
  /// sidechains) in a background goroutine, and os.Exit(0)s when done.
  /// Idempotent. If bitwindow is relaunched while the drain is still in
  /// flight, the next StartWithL1 transparently adopts it (flips the
  /// will-exit bit + awaits the in-flight stops) before booting a fresh
  /// stack — no separate cancel/await RPCs needed by callers.
  static const shutdown = connect.Spec(
    '/$name/Shutdown',
    connect.StreamType.unary,
    orchestratorv1orchestrator.ShutdownRequest.new,
    orchestratorv1orchestrator.ShutdownResponse.new,
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

  /// Snapshot of every binary the orchestrator is currently downloading.
  /// Reads from the in-memory DownloadManager state — light, polled by the
  /// frontend's DownloadProvider on a fast (100ms) cadence while a download
  /// is in flight, and dropping back to 2s when the response is empty.
  static const getDownloadStatus = connect.Spec(
    '/$name/GetDownloadStatus',
    connect.StreamType.unary,
    orchestratorv1orchestrator.GetDownloadStatusRequest.new,
    orchestratorv1orchestrator.GetDownloadStatusResponse.new,
  );

  /// Get wallet balance from Bitcoin Core (proxied via orchestrator).
  static const getMainchainBalance = connect.Spec(
    '/$name/GetMainchainBalance',
    connect.StreamType.unary,
    orchestratorv1orchestrator.GetMainchainBalanceRequest.new,
    orchestratorv1orchestrator.GetMainchainBalanceResponse.new,
  );

  /// Get wallet balance from a sidechain daemon (proxied via orchestrator).
  static const getSidechainBalance = connect.Spec(
    '/$name/GetSidechainBalance',
    connect.StreamType.unary,
    orchestratorv1orchestrator.GetSidechainBalanceRequest.new,
    orchestratorv1orchestrator.GetSidechainBalanceResponse.new,
  );

  /// Gather the files/dirs that would be deleted for a per-binary deletion spec
  /// (no side effects). Shared by the single-binary wipe and the full reset page.
  static const gatherFilesToDelete = connect.Spec(
    '/$name/GatherFilesToDelete',
    connect.StreamType.unary,
    orchestratorv1orchestrator.GatherFilesToDeleteRequest.new,
    orchestratorv1orchestrator.GatherFilesToDeleteResponse.new,
  );

  /// Delete the selected files. Stops binaries first; wallet paths are moved to
  /// wallet_backups/ instead of removed. Returns a gRPC error if it can't run.
  /// Streams one message per path; an unset error means that path succeeded.
  static const deleteFiles = connect.Spec(
    '/$name/DeleteFiles',
    connect.StreamType.server,
    orchestratorv1orchestrator.DeleteFilesRequest.new,
    orchestratorv1orchestrator.DeleteFilesResponse.new,
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

  /// ─── eCash fork ───────────────────────────────────────────────────────────
  /// Report where the mainchain tip sits relative to the eCash fork height.
  /// The orchestrator is the single source of truth for the fork height; the
  /// frontend renders "fork mode" (the claim card) off fork_active. Per-wallet
  /// pre-fork coin detection and the sweep itself stay in the frontend via the
  /// existing WalletManagerService (listUnspent / sendTransaction), one call
  /// per wallet — this RPC only supplies the height.
  static const getForkStatus = connect.Spec(
    '/$name/GetForkStatus',
    connect.StreamType.unary,
    orchestratorv1orchestrator.GetForkStatusRequest.new,
    orchestratorv1orchestrator.GetForkStatusResponse.new,
  );
}
