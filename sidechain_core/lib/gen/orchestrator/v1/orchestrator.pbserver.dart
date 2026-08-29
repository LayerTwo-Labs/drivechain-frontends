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

import 'orchestrator.pb.dart' as $3;
import 'orchestrator.pbjson.dart';

export 'orchestrator.pb.dart';

abstract class OrchestratorServiceBase extends $pb.GeneratedService {
  $async.Future<$3.ListBinariesResponse> listBinaries($pb.ServerContext ctx, $3.ListBinariesRequest request);
  $async.Future<$3.GetBinaryStatusResponse> getBinaryStatus($pb.ServerContext ctx, $3.GetBinaryStatusRequest request);
  $async.Future<$3.GetBinaryVersionResponse> getBinaryVersion($pb.ServerContext ctx, $3.GetBinaryVersionRequest request);
  $async.Future<$3.DownloadBinaryResponse> downloadBinary($pb.ServerContext ctx, $3.DownloadBinaryRequest request);
  $async.Future<$3.StartBinaryResponse> startBinary($pb.ServerContext ctx, $3.StartBinaryRequest request);
  $async.Future<$3.StopBinaryResponse> stopBinary($pb.ServerContext ctx, $3.StopBinaryRequest request);
  $async.Future<$3.StreamLogsResponse> streamLogs($pb.ServerContext ctx, $3.StreamLogsRequest request);
  $async.Future<$3.StartWithL1Response> startWithL1($pb.ServerContext ctx, $3.StartWithL1Request request);
  $async.Future<$3.RestartDaemonResponse> restartDaemon($pb.ServerContext ctx, $3.RestartDaemonRequest request);
  $async.Future<$3.RestartL1Response> restartL1($pb.ServerContext ctx, $3.RestartL1Request request);
  $async.Future<$3.ApplyUTXOSnapshotResponse> applyUTXOSnapshot($pb.ServerContext ctx, $3.ApplyUTXOSnapshotRequest request);
  $async.Future<$3.GetSnapshotStatusResponse> getSnapshotStatus($pb.ServerContext ctx, $3.GetSnapshotStatusRequest request);
  $async.Future<$3.GetPendingNetworkGenerationResponse> getPendingNetworkGeneration($pb.ServerContext ctx, $3.GetPendingNetworkGenerationRequest request);
  $async.Future<$3.ConfirmPendingNetworkGenerationResponse> confirmPendingNetworkGeneration($pb.ServerContext ctx, $3.ConfirmPendingNetworkGenerationRequest request);
  $async.Future<$3.ShutdownAllResponse> shutdownAll($pb.ServerContext ctx, $3.ShutdownAllRequest request);
  $async.Future<$3.ShutdownResponse> shutdown($pb.ServerContext ctx, $3.ShutdownRequest request);
  $async.Future<$3.GetBTCPriceResponse> getBTCPrice($pb.ServerContext ctx, $3.GetBTCPriceRequest request);
  $async.Future<$3.GetMainchainBlockchainInfoResponse> getMainchainBlockchainInfo($pb.ServerContext ctx, $3.GetMainchainBlockchainInfoRequest request);
  $async.Future<$3.GetEnforcerBlockchainInfoResponse> getEnforcerBlockchainInfo($pb.ServerContext ctx, $3.GetEnforcerBlockchainInfoRequest request);
  $async.Future<$3.GetSyncStatusResponse> getSyncStatus($pb.ServerContext ctx, $3.GetSyncStatusRequest request);
  $async.Future<$3.GetDownloadStatusResponse> getDownloadStatus($pb.ServerContext ctx, $3.GetDownloadStatusRequest request);
  $async.Future<$3.GetMainchainBalanceResponse> getMainchainBalance($pb.ServerContext ctx, $3.GetMainchainBalanceRequest request);
  $async.Future<$3.GetSidechainBalanceResponse> getSidechainBalance($pb.ServerContext ctx, $3.GetSidechainBalanceRequest request);
  $async.Future<$3.GatherFilesToDeleteResponse> gatherFilesToDelete($pb.ServerContext ctx, $3.GatherFilesToDeleteRequest request);
  $async.Future<$3.DeleteFilesResponse> deleteFiles($pb.ServerContext ctx, $3.DeleteFilesRequest request);
  $async.Future<$3.RejectBlockResponse> rejectBlock($pb.ServerContext ctx, $3.RejectBlockRequest request);
  $async.Future<$3.AcceptBlockResponse> acceptBlock($pb.ServerContext ctx, $3.AcceptBlockRequest request);
  $async.Future<$3.ResetToBlockResponse> resetToBlock($pb.ServerContext ctx, $3.ResetToBlockRequest request);
  $async.Future<$3.GetCoreMempoolInfoResponse> getCoreMempoolInfo($pb.ServerContext ctx, $3.GetCoreMempoolInfoRequest request);
  $async.Future<$3.GetBmmContextResponse> getBmmContext($pb.ServerContext ctx, $3.GetBmmContextRequest request);
  $async.Future<$3.CoreRawCallResponse> coreRawCall($pb.ServerContext ctx, $3.CoreRawCallRequest request);
  $async.Future<$3.GetForkStatusResponse> getForkStatus($pb.ServerContext ctx, $3.GetForkStatusRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'ListBinaries': return $3.ListBinariesRequest();
      case 'GetBinaryStatus': return $3.GetBinaryStatusRequest();
      case 'GetBinaryVersion': return $3.GetBinaryVersionRequest();
      case 'DownloadBinary': return $3.DownloadBinaryRequest();
      case 'StartBinary': return $3.StartBinaryRequest();
      case 'StopBinary': return $3.StopBinaryRequest();
      case 'StreamLogs': return $3.StreamLogsRequest();
      case 'StartWithL1': return $3.StartWithL1Request();
      case 'RestartDaemon': return $3.RestartDaemonRequest();
      case 'RestartL1': return $3.RestartL1Request();
      case 'ApplyUTXOSnapshot': return $3.ApplyUTXOSnapshotRequest();
      case 'GetSnapshotStatus': return $3.GetSnapshotStatusRequest();
      case 'GetPendingNetworkGeneration': return $3.GetPendingNetworkGenerationRequest();
      case 'ConfirmPendingNetworkGeneration': return $3.ConfirmPendingNetworkGenerationRequest();
      case 'ShutdownAll': return $3.ShutdownAllRequest();
      case 'Shutdown': return $3.ShutdownRequest();
      case 'GetBTCPrice': return $3.GetBTCPriceRequest();
      case 'GetMainchainBlockchainInfo': return $3.GetMainchainBlockchainInfoRequest();
      case 'GetEnforcerBlockchainInfo': return $3.GetEnforcerBlockchainInfoRequest();
      case 'GetSyncStatus': return $3.GetSyncStatusRequest();
      case 'GetDownloadStatus': return $3.GetDownloadStatusRequest();
      case 'GetMainchainBalance': return $3.GetMainchainBalanceRequest();
      case 'GetSidechainBalance': return $3.GetSidechainBalanceRequest();
      case 'GatherFilesToDelete': return $3.GatherFilesToDeleteRequest();
      case 'DeleteFiles': return $3.DeleteFilesRequest();
      case 'RejectBlock': return $3.RejectBlockRequest();
      case 'AcceptBlock': return $3.AcceptBlockRequest();
      case 'ResetToBlock': return $3.ResetToBlockRequest();
      case 'GetCoreMempoolInfo': return $3.GetCoreMempoolInfoRequest();
      case 'GetBmmContext': return $3.GetBmmContextRequest();
      case 'CoreRawCall': return $3.CoreRawCallRequest();
      case 'GetForkStatus': return $3.GetForkStatusRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'ListBinaries': return this.listBinaries(ctx, request as $3.ListBinariesRequest);
      case 'GetBinaryStatus': return this.getBinaryStatus(ctx, request as $3.GetBinaryStatusRequest);
      case 'GetBinaryVersion': return this.getBinaryVersion(ctx, request as $3.GetBinaryVersionRequest);
      case 'DownloadBinary': return this.downloadBinary(ctx, request as $3.DownloadBinaryRequest);
      case 'StartBinary': return this.startBinary(ctx, request as $3.StartBinaryRequest);
      case 'StopBinary': return this.stopBinary(ctx, request as $3.StopBinaryRequest);
      case 'StreamLogs': return this.streamLogs(ctx, request as $3.StreamLogsRequest);
      case 'StartWithL1': return this.startWithL1(ctx, request as $3.StartWithL1Request);
      case 'RestartDaemon': return this.restartDaemon(ctx, request as $3.RestartDaemonRequest);
      case 'RestartL1': return this.restartL1(ctx, request as $3.RestartL1Request);
      case 'ApplyUTXOSnapshot': return this.applyUTXOSnapshot(ctx, request as $3.ApplyUTXOSnapshotRequest);
      case 'GetSnapshotStatus': return this.getSnapshotStatus(ctx, request as $3.GetSnapshotStatusRequest);
      case 'GetPendingNetworkGeneration': return this.getPendingNetworkGeneration(ctx, request as $3.GetPendingNetworkGenerationRequest);
      case 'ConfirmPendingNetworkGeneration': return this.confirmPendingNetworkGeneration(ctx, request as $3.ConfirmPendingNetworkGenerationRequest);
      case 'ShutdownAll': return this.shutdownAll(ctx, request as $3.ShutdownAllRequest);
      case 'Shutdown': return this.shutdown(ctx, request as $3.ShutdownRequest);
      case 'GetBTCPrice': return this.getBTCPrice(ctx, request as $3.GetBTCPriceRequest);
      case 'GetMainchainBlockchainInfo': return this.getMainchainBlockchainInfo(ctx, request as $3.GetMainchainBlockchainInfoRequest);
      case 'GetEnforcerBlockchainInfo': return this.getEnforcerBlockchainInfo(ctx, request as $3.GetEnforcerBlockchainInfoRequest);
      case 'GetSyncStatus': return this.getSyncStatus(ctx, request as $3.GetSyncStatusRequest);
      case 'GetDownloadStatus': return this.getDownloadStatus(ctx, request as $3.GetDownloadStatusRequest);
      case 'GetMainchainBalance': return this.getMainchainBalance(ctx, request as $3.GetMainchainBalanceRequest);
      case 'GetSidechainBalance': return this.getSidechainBalance(ctx, request as $3.GetSidechainBalanceRequest);
      case 'GatherFilesToDelete': return this.gatherFilesToDelete(ctx, request as $3.GatherFilesToDeleteRequest);
      case 'DeleteFiles': return this.deleteFiles(ctx, request as $3.DeleteFilesRequest);
      case 'RejectBlock': return this.rejectBlock(ctx, request as $3.RejectBlockRequest);
      case 'AcceptBlock': return this.acceptBlock(ctx, request as $3.AcceptBlockRequest);
      case 'ResetToBlock': return this.resetToBlock(ctx, request as $3.ResetToBlockRequest);
      case 'GetCoreMempoolInfo': return this.getCoreMempoolInfo(ctx, request as $3.GetCoreMempoolInfoRequest);
      case 'GetBmmContext': return this.getBmmContext(ctx, request as $3.GetBmmContextRequest);
      case 'CoreRawCall': return this.coreRawCall(ctx, request as $3.CoreRawCallRequest);
      case 'GetForkStatus': return this.getForkStatus(ctx, request as $3.GetForkStatusRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => OrchestratorServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => OrchestratorServiceBase$messageJson;
}

