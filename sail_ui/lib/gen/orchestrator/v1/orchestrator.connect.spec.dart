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
  static const downloadBinary = connect.Spec(
    '/$name/DownloadBinary',
    connect.StreamType.server,
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

  /// Stream live status updates for all binaries.
  static const watchBinaries = connect.Spec(
    '/$name/WatchBinaries',
    connect.StreamType.server,
    orchestratorv1orchestrator.WatchBinariesRequest.new,
    orchestratorv1orchestrator.WatchBinariesResponse.new,
  );

  /// Stream stdout/stderr from a binary.
  static const streamLogs = connect.Spec(
    '/$name/StreamLogs',
    connect.StreamType.server,
    orchestratorv1orchestrator.StreamLogsRequest.new,
    orchestratorv1orchestrator.StreamLogsResponse.new,
  );

  /// Start a binary with its full dependency chain (Core -> Enforcer -> target).
  static const startWithDeps = connect.Spec(
    '/$name/StartWithDeps',
    connect.StreamType.server,
    orchestratorv1orchestrator.StartWithDepsRequest.new,
    orchestratorv1orchestrator.StartWithDepsResponse.new,
  );

  /// Shutdown all running binaries.
  static const shutdownAll = connect.Spec(
    '/$name/ShutdownAll',
    connect.StreamType.server,
    orchestratorv1orchestrator.ShutdownAllRequest.new,
    orchestratorv1orchestrator.ShutdownAllResponse.new,
  );
}
