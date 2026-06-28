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

import 'orchestrator.pb.dart' as $6;
import 'orchestrator.pbjson.dart';

export 'orchestrator.pb.dart';

abstract class OrchestratorServiceBase extends $pb.GeneratedService {
  $async.Future<$6.ListBinariesResponse> listBinaries($pb.ServerContext ctx, $6.ListBinariesRequest request);
  $async.Future<$6.GetBinaryStatusResponse> getBinaryStatus($pb.ServerContext ctx, $6.GetBinaryStatusRequest request);
  $async.Future<$6.GetBinaryVersionResponse> getBinaryVersion($pb.ServerContext ctx, $6.GetBinaryVersionRequest request);
  $async.Future<$6.DownloadBinaryResponse> downloadBinary($pb.ServerContext ctx, $6.DownloadBinaryRequest request);
  $async.Future<$6.StartBinaryResponse> startBinary($pb.ServerContext ctx, $6.StartBinaryRequest request);
  $async.Future<$6.StopBinaryResponse> stopBinary($pb.ServerContext ctx, $6.StopBinaryRequest request);
  $async.Future<$6.StreamLogsResponse> streamLogs($pb.ServerContext ctx, $6.StreamLogsRequest request);
  $async.Future<$6.StartWithL1Response> startWithL1($pb.ServerContext ctx, $6.StartWithL1Request request);
  $async.Future<$6.RestartDaemonResponse> restartDaemon($pb.ServerContext ctx, $6.RestartDaemonRequest request);
  $async.Future<$6.RestartL1Response> restartL1($pb.ServerContext ctx, $6.RestartL1Request request);
  $async.Future<$6.ShutdownAllResponse> shutdownAll($pb.ServerContext ctx, $6.ShutdownAllRequest request);
  $async.Future<$6.ShutdownResponse> shutdown($pb.ServerContext ctx, $6.ShutdownRequest request);
  $async.Future<$6.GetBTCPriceResponse> getBTCPrice($pb.ServerContext ctx, $6.GetBTCPriceRequest request);
  $async.Future<$6.GetMainchainBlockchainInfoResponse> getMainchainBlockchainInfo($pb.ServerContext ctx, $6.GetMainchainBlockchainInfoRequest request);
  $async.Future<$6.GetEnforcerBlockchainInfoResponse> getEnforcerBlockchainInfo($pb.ServerContext ctx, $6.GetEnforcerBlockchainInfoRequest request);
  $async.Future<$6.GetSyncStatusResponse> getSyncStatus($pb.ServerContext ctx, $6.GetSyncStatusRequest request);
  $async.Future<$6.GetDownloadStatusResponse> getDownloadStatus($pb.ServerContext ctx, $6.GetDownloadStatusRequest request);
  $async.Future<$6.GetMainchainBalanceResponse> getMainchainBalance($pb.ServerContext ctx, $6.GetMainchainBalanceRequest request);
  $async.Future<$6.GetSidechainBalanceResponse> getSidechainBalance($pb.ServerContext ctx, $6.GetSidechainBalanceRequest request);
  $async.Future<$6.GatherFilesToDeleteResponse> gatherFilesToDelete($pb.ServerContext ctx, $6.GatherFilesToDeleteRequest request);
  $async.Future<$6.DeleteFilesResponse> deleteFiles($pb.ServerContext ctx, $6.DeleteFilesRequest request);
  $async.Future<$6.GetCoreMempoolInfoResponse> getCoreMempoolInfo($pb.ServerContext ctx, $6.GetCoreMempoolInfoRequest request);
  $async.Future<$6.CoreRawCallResponse> coreRawCall($pb.ServerContext ctx, $6.CoreRawCallRequest request);
  $async.Future<$6.GetForkStatusResponse> getForkStatus($pb.ServerContext ctx, $6.GetForkStatusRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'ListBinaries': return $6.ListBinariesRequest();
      case 'GetBinaryStatus': return $6.GetBinaryStatusRequest();
      case 'GetBinaryVersion': return $6.GetBinaryVersionRequest();
      case 'DownloadBinary': return $6.DownloadBinaryRequest();
      case 'StartBinary': return $6.StartBinaryRequest();
      case 'StopBinary': return $6.StopBinaryRequest();
      case 'StreamLogs': return $6.StreamLogsRequest();
      case 'StartWithL1': return $6.StartWithL1Request();
      case 'RestartDaemon': return $6.RestartDaemonRequest();
      case 'RestartL1': return $6.RestartL1Request();
      case 'ShutdownAll': return $6.ShutdownAllRequest();
      case 'Shutdown': return $6.ShutdownRequest();
      case 'GetBTCPrice': return $6.GetBTCPriceRequest();
      case 'GetMainchainBlockchainInfo': return $6.GetMainchainBlockchainInfoRequest();
      case 'GetEnforcerBlockchainInfo': return $6.GetEnforcerBlockchainInfoRequest();
      case 'GetSyncStatus': return $6.GetSyncStatusRequest();
      case 'GetDownloadStatus': return $6.GetDownloadStatusRequest();
      case 'GetMainchainBalance': return $6.GetMainchainBalanceRequest();
      case 'GetSidechainBalance': return $6.GetSidechainBalanceRequest();
      case 'GatherFilesToDelete': return $6.GatherFilesToDeleteRequest();
      case 'DeleteFiles': return $6.DeleteFilesRequest();
      case 'GetCoreMempoolInfo': return $6.GetCoreMempoolInfoRequest();
      case 'CoreRawCall': return $6.CoreRawCallRequest();
      case 'GetForkStatus': return $6.GetForkStatusRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'ListBinaries': return this.listBinaries(ctx, request as $6.ListBinariesRequest);
      case 'GetBinaryStatus': return this.getBinaryStatus(ctx, request as $6.GetBinaryStatusRequest);
      case 'GetBinaryVersion': return this.getBinaryVersion(ctx, request as $6.GetBinaryVersionRequest);
      case 'DownloadBinary': return this.downloadBinary(ctx, request as $6.DownloadBinaryRequest);
      case 'StartBinary': return this.startBinary(ctx, request as $6.StartBinaryRequest);
      case 'StopBinary': return this.stopBinary(ctx, request as $6.StopBinaryRequest);
      case 'StreamLogs': return this.streamLogs(ctx, request as $6.StreamLogsRequest);
      case 'StartWithL1': return this.startWithL1(ctx, request as $6.StartWithL1Request);
      case 'RestartDaemon': return this.restartDaemon(ctx, request as $6.RestartDaemonRequest);
      case 'RestartL1': return this.restartL1(ctx, request as $6.RestartL1Request);
      case 'ShutdownAll': return this.shutdownAll(ctx, request as $6.ShutdownAllRequest);
      case 'Shutdown': return this.shutdown(ctx, request as $6.ShutdownRequest);
      case 'GetBTCPrice': return this.getBTCPrice(ctx, request as $6.GetBTCPriceRequest);
      case 'GetMainchainBlockchainInfo': return this.getMainchainBlockchainInfo(ctx, request as $6.GetMainchainBlockchainInfoRequest);
      case 'GetEnforcerBlockchainInfo': return this.getEnforcerBlockchainInfo(ctx, request as $6.GetEnforcerBlockchainInfoRequest);
      case 'GetSyncStatus': return this.getSyncStatus(ctx, request as $6.GetSyncStatusRequest);
      case 'GetDownloadStatus': return this.getDownloadStatus(ctx, request as $6.GetDownloadStatusRequest);
      case 'GetMainchainBalance': return this.getMainchainBalance(ctx, request as $6.GetMainchainBalanceRequest);
      case 'GetSidechainBalance': return this.getSidechainBalance(ctx, request as $6.GetSidechainBalanceRequest);
      case 'GatherFilesToDelete': return this.gatherFilesToDelete(ctx, request as $6.GatherFilesToDeleteRequest);
      case 'DeleteFiles': return this.deleteFiles(ctx, request as $6.DeleteFilesRequest);
      case 'GetCoreMempoolInfo': return this.getCoreMempoolInfo(ctx, request as $6.GetCoreMempoolInfoRequest);
      case 'CoreRawCall': return this.coreRawCall(ctx, request as $6.CoreRawCallRequest);
      case 'GetForkStatus': return this.getForkStatus(ctx, request as $6.GetForkStatusRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => OrchestratorServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => OrchestratorServiceBase$messageJson;
}

