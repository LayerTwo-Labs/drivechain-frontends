//
//  Generated code. Do not modify.
//  source: orchestrator/v1/orchestrator.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'orchestrator.pb.dart' as $5;
import 'orchestrator.pbjson.dart';

export 'orchestrator.pb.dart';

abstract class OrchestratorServiceBase extends $pb.GeneratedService {
  $async.Future<$5.ListBinariesResponse> listBinaries($pb.ServerContext ctx, $5.ListBinariesRequest request);
  $async.Future<$5.GetBinaryStatusResponse> getBinaryStatus($pb.ServerContext ctx, $5.GetBinaryStatusRequest request);
  $async.Future<$5.GetBinaryVersionResponse> getBinaryVersion($pb.ServerContext ctx, $5.GetBinaryVersionRequest request);
  $async.Future<$5.DownloadBinaryResponse> downloadBinary($pb.ServerContext ctx, $5.DownloadBinaryRequest request);
  $async.Future<$5.StartBinaryResponse> startBinary($pb.ServerContext ctx, $5.StartBinaryRequest request);
  $async.Future<$5.StopBinaryResponse> stopBinary($pb.ServerContext ctx, $5.StopBinaryRequest request);
  $async.Future<$5.StreamLogsResponse> streamLogs($pb.ServerContext ctx, $5.StreamLogsRequest request);
  $async.Future<$5.StartWithL1Response> startWithL1($pb.ServerContext ctx, $5.StartWithL1Request request);
  $async.Future<$5.RestartDaemonResponse> restartDaemon($pb.ServerContext ctx, $5.RestartDaemonRequest request);
  $async.Future<$5.RestartL1Response> restartL1($pb.ServerContext ctx, $5.RestartL1Request request);
  $async.Future<$5.ShutdownAllResponse> shutdownAll($pb.ServerContext ctx, $5.ShutdownAllRequest request);
  $async.Future<$5.ShutdownResponse> shutdown($pb.ServerContext ctx, $5.ShutdownRequest request);
  $async.Future<$5.GetBTCPriceResponse> getBTCPrice($pb.ServerContext ctx, $5.GetBTCPriceRequest request);
  $async.Future<$5.GetMainchainBlockchainInfoResponse> getMainchainBlockchainInfo($pb.ServerContext ctx, $5.GetMainchainBlockchainInfoRequest request);
  $async.Future<$5.GetEnforcerBlockchainInfoResponse> getEnforcerBlockchainInfo($pb.ServerContext ctx, $5.GetEnforcerBlockchainInfoRequest request);
  $async.Future<$5.GetSyncStatusResponse> getSyncStatus($pb.ServerContext ctx, $5.GetSyncStatusRequest request);
  $async.Future<$5.GetDownloadStatusResponse> getDownloadStatus($pb.ServerContext ctx, $5.GetDownloadStatusRequest request);
  $async.Future<$5.GetMainchainBalanceResponse> getMainchainBalance($pb.ServerContext ctx, $5.GetMainchainBalanceRequest request);
  $async.Future<$5.GetSidechainBalanceResponse> getSidechainBalance($pb.ServerContext ctx, $5.GetSidechainBalanceRequest request);
  $async.Future<$5.GatherFilesToDeleteResponse> gatherFilesToDelete($pb.ServerContext ctx, $5.GatherFilesToDeleteRequest request);
  $async.Future<$5.DeleteFilesResponse> deleteFiles($pb.ServerContext ctx, $5.DeleteFilesRequest request);
  $async.Future<$5.GetCoreMempoolInfoResponse> getCoreMempoolInfo($pb.ServerContext ctx, $5.GetCoreMempoolInfoRequest request);
  $async.Future<$5.CoreRawCallResponse> coreRawCall($pb.ServerContext ctx, $5.CoreRawCallRequest request);
  $async.Future<$5.GetForkStatusResponse> getForkStatus($pb.ServerContext ctx, $5.GetForkStatusRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'ListBinaries': return $5.ListBinariesRequest();
      case 'GetBinaryStatus': return $5.GetBinaryStatusRequest();
      case 'GetBinaryVersion': return $5.GetBinaryVersionRequest();
      case 'DownloadBinary': return $5.DownloadBinaryRequest();
      case 'StartBinary': return $5.StartBinaryRequest();
      case 'StopBinary': return $5.StopBinaryRequest();
      case 'StreamLogs': return $5.StreamLogsRequest();
      case 'StartWithL1': return $5.StartWithL1Request();
      case 'RestartDaemon': return $5.RestartDaemonRequest();
      case 'RestartL1': return $5.RestartL1Request();
      case 'ShutdownAll': return $5.ShutdownAllRequest();
      case 'Shutdown': return $5.ShutdownRequest();
      case 'GetBTCPrice': return $5.GetBTCPriceRequest();
      case 'GetMainchainBlockchainInfo': return $5.GetMainchainBlockchainInfoRequest();
      case 'GetEnforcerBlockchainInfo': return $5.GetEnforcerBlockchainInfoRequest();
      case 'GetSyncStatus': return $5.GetSyncStatusRequest();
      case 'GetDownloadStatus': return $5.GetDownloadStatusRequest();
      case 'GetMainchainBalance': return $5.GetMainchainBalanceRequest();
      case 'GetSidechainBalance': return $5.GetSidechainBalanceRequest();
      case 'GatherFilesToDelete': return $5.GatherFilesToDeleteRequest();
      case 'DeleteFiles': return $5.DeleteFilesRequest();
      case 'GetCoreMempoolInfo': return $5.GetCoreMempoolInfoRequest();
      case 'CoreRawCall': return $5.CoreRawCallRequest();
      case 'GetForkStatus': return $5.GetForkStatusRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'ListBinaries': return this.listBinaries(ctx, request as $5.ListBinariesRequest);
      case 'GetBinaryStatus': return this.getBinaryStatus(ctx, request as $5.GetBinaryStatusRequest);
      case 'GetBinaryVersion': return this.getBinaryVersion(ctx, request as $5.GetBinaryVersionRequest);
      case 'DownloadBinary': return this.downloadBinary(ctx, request as $5.DownloadBinaryRequest);
      case 'StartBinary': return this.startBinary(ctx, request as $5.StartBinaryRequest);
      case 'StopBinary': return this.stopBinary(ctx, request as $5.StopBinaryRequest);
      case 'StreamLogs': return this.streamLogs(ctx, request as $5.StreamLogsRequest);
      case 'StartWithL1': return this.startWithL1(ctx, request as $5.StartWithL1Request);
      case 'RestartDaemon': return this.restartDaemon(ctx, request as $5.RestartDaemonRequest);
      case 'RestartL1': return this.restartL1(ctx, request as $5.RestartL1Request);
      case 'ShutdownAll': return this.shutdownAll(ctx, request as $5.ShutdownAllRequest);
      case 'Shutdown': return this.shutdown(ctx, request as $5.ShutdownRequest);
      case 'GetBTCPrice': return this.getBTCPrice(ctx, request as $5.GetBTCPriceRequest);
      case 'GetMainchainBlockchainInfo': return this.getMainchainBlockchainInfo(ctx, request as $5.GetMainchainBlockchainInfoRequest);
      case 'GetEnforcerBlockchainInfo': return this.getEnforcerBlockchainInfo(ctx, request as $5.GetEnforcerBlockchainInfoRequest);
      case 'GetSyncStatus': return this.getSyncStatus(ctx, request as $5.GetSyncStatusRequest);
      case 'GetDownloadStatus': return this.getDownloadStatus(ctx, request as $5.GetDownloadStatusRequest);
      case 'GetMainchainBalance': return this.getMainchainBalance(ctx, request as $5.GetMainchainBalanceRequest);
      case 'GetSidechainBalance': return this.getSidechainBalance(ctx, request as $5.GetSidechainBalanceRequest);
      case 'GatherFilesToDelete': return this.gatherFilesToDelete(ctx, request as $5.GatherFilesToDeleteRequest);
      case 'DeleteFiles': return this.deleteFiles(ctx, request as $5.DeleteFilesRequest);
      case 'GetCoreMempoolInfo': return this.getCoreMempoolInfo(ctx, request as $5.GetCoreMempoolInfoRequest);
      case 'CoreRawCall': return this.coreRawCall(ctx, request as $5.CoreRawCallRequest);
      case 'GetForkStatus': return this.getForkStatus(ctx, request as $5.GetForkStatusRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => OrchestratorServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => OrchestratorServiceBase$messageJson;
}

