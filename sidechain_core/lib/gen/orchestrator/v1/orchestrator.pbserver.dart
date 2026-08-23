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

import 'orchestrator.pb.dart' as $2;
import 'orchestrator.pbjson.dart';

export 'orchestrator.pb.dart';

abstract class OrchestratorServiceBase extends $pb.GeneratedService {
  $async.Future<$2.ListBinariesResponse> listBinaries($pb.ServerContext ctx, $2.ListBinariesRequest request);
  $async.Future<$2.GetBinaryStatusResponse> getBinaryStatus($pb.ServerContext ctx, $2.GetBinaryStatusRequest request);
  $async.Future<$2.GetBinaryVersionResponse> getBinaryVersion($pb.ServerContext ctx, $2.GetBinaryVersionRequest request);
  $async.Future<$2.DownloadBinaryResponse> downloadBinary($pb.ServerContext ctx, $2.DownloadBinaryRequest request);
  $async.Future<$2.StartBinaryResponse> startBinary($pb.ServerContext ctx, $2.StartBinaryRequest request);
  $async.Future<$2.StopBinaryResponse> stopBinary($pb.ServerContext ctx, $2.StopBinaryRequest request);
  $async.Future<$2.StreamLogsResponse> streamLogs($pb.ServerContext ctx, $2.StreamLogsRequest request);
  $async.Future<$2.StartWithL1Response> startWithL1($pb.ServerContext ctx, $2.StartWithL1Request request);
  $async.Future<$2.RestartDaemonResponse> restartDaemon($pb.ServerContext ctx, $2.RestartDaemonRequest request);
  $async.Future<$2.RestartL1Response> restartL1($pb.ServerContext ctx, $2.RestartL1Request request);
  $async.Future<$2.ApplyUTXOSnapshotResponse> applyUTXOSnapshot($pb.ServerContext ctx, $2.ApplyUTXOSnapshotRequest request);
  $async.Future<$2.GetSnapshotStatusResponse> getSnapshotStatus($pb.ServerContext ctx, $2.GetSnapshotStatusRequest request);
  $async.Future<$2.GetPendingNetworkGenerationResponse> getPendingNetworkGeneration($pb.ServerContext ctx, $2.GetPendingNetworkGenerationRequest request);
  $async.Future<$2.ConfirmPendingNetworkGenerationResponse> confirmPendingNetworkGeneration($pb.ServerContext ctx, $2.ConfirmPendingNetworkGenerationRequest request);
  $async.Future<$2.ShutdownAllResponse> shutdownAll($pb.ServerContext ctx, $2.ShutdownAllRequest request);
  $async.Future<$2.ShutdownResponse> shutdown($pb.ServerContext ctx, $2.ShutdownRequest request);
  $async.Future<$2.GetBTCPriceResponse> getBTCPrice($pb.ServerContext ctx, $2.GetBTCPriceRequest request);
  $async.Future<$2.GetMainchainBlockchainInfoResponse> getMainchainBlockchainInfo($pb.ServerContext ctx, $2.GetMainchainBlockchainInfoRequest request);
  $async.Future<$2.GetEnforcerBlockchainInfoResponse> getEnforcerBlockchainInfo($pb.ServerContext ctx, $2.GetEnforcerBlockchainInfoRequest request);
  $async.Future<$2.GetSyncStatusResponse> getSyncStatus($pb.ServerContext ctx, $2.GetSyncStatusRequest request);
  $async.Future<$2.GetDownloadStatusResponse> getDownloadStatus($pb.ServerContext ctx, $2.GetDownloadStatusRequest request);
  $async.Future<$2.GetMainchainBalanceResponse> getMainchainBalance($pb.ServerContext ctx, $2.GetMainchainBalanceRequest request);
  $async.Future<$2.GetSidechainBalanceResponse> getSidechainBalance($pb.ServerContext ctx, $2.GetSidechainBalanceRequest request);
  $async.Future<$2.GatherFilesToDeleteResponse> gatherFilesToDelete($pb.ServerContext ctx, $2.GatherFilesToDeleteRequest request);
  $async.Future<$2.DeleteFilesResponse> deleteFiles($pb.ServerContext ctx, $2.DeleteFilesRequest request);
  $async.Future<$2.RejectBlockResponse> rejectBlock($pb.ServerContext ctx, $2.RejectBlockRequest request);
  $async.Future<$2.AcceptBlockResponse> acceptBlock($pb.ServerContext ctx, $2.AcceptBlockRequest request);
  $async.Future<$2.ResetToBlockResponse> resetToBlock($pb.ServerContext ctx, $2.ResetToBlockRequest request);
  $async.Future<$2.GetCoreMempoolInfoResponse> getCoreMempoolInfo($pb.ServerContext ctx, $2.GetCoreMempoolInfoRequest request);
  $async.Future<$2.GetBmmContextResponse> getBmmContext($pb.ServerContext ctx, $2.GetBmmContextRequest request);
  $async.Future<$2.CoreRawCallResponse> coreRawCall($pb.ServerContext ctx, $2.CoreRawCallRequest request);
  $async.Future<$2.GetForkStatusResponse> getForkStatus($pb.ServerContext ctx, $2.GetForkStatusRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'ListBinaries': return $2.ListBinariesRequest();
      case 'GetBinaryStatus': return $2.GetBinaryStatusRequest();
      case 'GetBinaryVersion': return $2.GetBinaryVersionRequest();
      case 'DownloadBinary': return $2.DownloadBinaryRequest();
      case 'StartBinary': return $2.StartBinaryRequest();
      case 'StopBinary': return $2.StopBinaryRequest();
      case 'StreamLogs': return $2.StreamLogsRequest();
      case 'StartWithL1': return $2.StartWithL1Request();
      case 'RestartDaemon': return $2.RestartDaemonRequest();
      case 'RestartL1': return $2.RestartL1Request();
      case 'ApplyUTXOSnapshot': return $2.ApplyUTXOSnapshotRequest();
      case 'GetSnapshotStatus': return $2.GetSnapshotStatusRequest();
      case 'GetPendingNetworkGeneration': return $2.GetPendingNetworkGenerationRequest();
      case 'ConfirmPendingNetworkGeneration': return $2.ConfirmPendingNetworkGenerationRequest();
      case 'ShutdownAll': return $2.ShutdownAllRequest();
      case 'Shutdown': return $2.ShutdownRequest();
      case 'GetBTCPrice': return $2.GetBTCPriceRequest();
      case 'GetMainchainBlockchainInfo': return $2.GetMainchainBlockchainInfoRequest();
      case 'GetEnforcerBlockchainInfo': return $2.GetEnforcerBlockchainInfoRequest();
      case 'GetSyncStatus': return $2.GetSyncStatusRequest();
      case 'GetDownloadStatus': return $2.GetDownloadStatusRequest();
      case 'GetMainchainBalance': return $2.GetMainchainBalanceRequest();
      case 'GetSidechainBalance': return $2.GetSidechainBalanceRequest();
      case 'GatherFilesToDelete': return $2.GatherFilesToDeleteRequest();
      case 'DeleteFiles': return $2.DeleteFilesRequest();
      case 'RejectBlock': return $2.RejectBlockRequest();
      case 'AcceptBlock': return $2.AcceptBlockRequest();
      case 'ResetToBlock': return $2.ResetToBlockRequest();
      case 'GetCoreMempoolInfo': return $2.GetCoreMempoolInfoRequest();
      case 'GetBmmContext': return $2.GetBmmContextRequest();
      case 'CoreRawCall': return $2.CoreRawCallRequest();
      case 'GetForkStatus': return $2.GetForkStatusRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'ListBinaries': return this.listBinaries(ctx, request as $2.ListBinariesRequest);
      case 'GetBinaryStatus': return this.getBinaryStatus(ctx, request as $2.GetBinaryStatusRequest);
      case 'GetBinaryVersion': return this.getBinaryVersion(ctx, request as $2.GetBinaryVersionRequest);
      case 'DownloadBinary': return this.downloadBinary(ctx, request as $2.DownloadBinaryRequest);
      case 'StartBinary': return this.startBinary(ctx, request as $2.StartBinaryRequest);
      case 'StopBinary': return this.stopBinary(ctx, request as $2.StopBinaryRequest);
      case 'StreamLogs': return this.streamLogs(ctx, request as $2.StreamLogsRequest);
      case 'StartWithL1': return this.startWithL1(ctx, request as $2.StartWithL1Request);
      case 'RestartDaemon': return this.restartDaemon(ctx, request as $2.RestartDaemonRequest);
      case 'RestartL1': return this.restartL1(ctx, request as $2.RestartL1Request);
      case 'ApplyUTXOSnapshot': return this.applyUTXOSnapshot(ctx, request as $2.ApplyUTXOSnapshotRequest);
      case 'GetSnapshotStatus': return this.getSnapshotStatus(ctx, request as $2.GetSnapshotStatusRequest);
      case 'GetPendingNetworkGeneration': return this.getPendingNetworkGeneration(ctx, request as $2.GetPendingNetworkGenerationRequest);
      case 'ConfirmPendingNetworkGeneration': return this.confirmPendingNetworkGeneration(ctx, request as $2.ConfirmPendingNetworkGenerationRequest);
      case 'ShutdownAll': return this.shutdownAll(ctx, request as $2.ShutdownAllRequest);
      case 'Shutdown': return this.shutdown(ctx, request as $2.ShutdownRequest);
      case 'GetBTCPrice': return this.getBTCPrice(ctx, request as $2.GetBTCPriceRequest);
      case 'GetMainchainBlockchainInfo': return this.getMainchainBlockchainInfo(ctx, request as $2.GetMainchainBlockchainInfoRequest);
      case 'GetEnforcerBlockchainInfo': return this.getEnforcerBlockchainInfo(ctx, request as $2.GetEnforcerBlockchainInfoRequest);
      case 'GetSyncStatus': return this.getSyncStatus(ctx, request as $2.GetSyncStatusRequest);
      case 'GetDownloadStatus': return this.getDownloadStatus(ctx, request as $2.GetDownloadStatusRequest);
      case 'GetMainchainBalance': return this.getMainchainBalance(ctx, request as $2.GetMainchainBalanceRequest);
      case 'GetSidechainBalance': return this.getSidechainBalance(ctx, request as $2.GetSidechainBalanceRequest);
      case 'GatherFilesToDelete': return this.gatherFilesToDelete(ctx, request as $2.GatherFilesToDeleteRequest);
      case 'DeleteFiles': return this.deleteFiles(ctx, request as $2.DeleteFilesRequest);
      case 'RejectBlock': return this.rejectBlock(ctx, request as $2.RejectBlockRequest);
      case 'AcceptBlock': return this.acceptBlock(ctx, request as $2.AcceptBlockRequest);
      case 'ResetToBlock': return this.resetToBlock(ctx, request as $2.ResetToBlockRequest);
      case 'GetCoreMempoolInfo': return this.getCoreMempoolInfo(ctx, request as $2.GetCoreMempoolInfoRequest);
      case 'GetBmmContext': return this.getBmmContext(ctx, request as $2.GetBmmContextRequest);
      case 'CoreRawCall': return this.coreRawCall(ctx, request as $2.CoreRawCallRequest);
      case 'GetForkStatus': return this.getForkStatus(ctx, request as $2.GetForkStatusRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => OrchestratorServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => OrchestratorServiceBase$messageJson;
}

