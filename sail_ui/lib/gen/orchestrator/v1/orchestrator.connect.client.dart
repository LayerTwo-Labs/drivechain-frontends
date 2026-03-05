//
//  Generated code. Do not modify.
//  source: orchestrator/v1/orchestrator.proto
//

import "package:connectrpc/connect.dart" as connect;
import "orchestrator.pb.dart" as orchestratorv1orchestrator;
import "orchestrator.connect.spec.dart" as specs;

extension type OrchestratorServiceClient (connect.Transport _transport) {
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
  Stream<orchestratorv1orchestrator.DownloadBinaryResponse> downloadBinary(
    orchestratorv1orchestrator.DownloadBinaryRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
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

  /// Stream live status updates for all binaries.
  Stream<orchestratorv1orchestrator.WatchBinariesResponse> watchBinaries(
    orchestratorv1orchestrator.WatchBinariesRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.OrchestratorService.watchBinaries,
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

  /// Start a binary with its full dependency chain (Core -> Enforcer -> target).
  Stream<orchestratorv1orchestrator.StartWithDepsResponse> startWithDeps(
    orchestratorv1orchestrator.StartWithDepsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.OrchestratorService.startWithDeps,
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
}
