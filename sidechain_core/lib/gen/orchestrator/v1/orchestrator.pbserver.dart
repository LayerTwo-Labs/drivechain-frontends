// This is a generated file - do not edit.
//
// Generated from orchestrator/v1/orchestrator.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'orchestrator.pb.dart' as $0;
import 'orchestrator.pbjson.dart';

export 'orchestrator.pb.dart';

abstract class OrchestratorServiceBase extends $pb.GeneratedService {
  $async.Future<$0.ListBinariesResponse> listBinaries($pb.ServerContext ctx, $0.ListBinariesRequest request);
  $async.Future<$0.GetBinaryStatusResponse> getBinaryStatus($pb.ServerContext ctx, $0.GetBinaryStatusRequest request);
  $async.Future<$0.GetBinaryVersionResponse> getBinaryVersion(
      $pb.ServerContext ctx, $0.GetBinaryVersionRequest request);
  $async.Future<$0.DownloadBinaryResponse> downloadBinary($pb.ServerContext ctx, $0.DownloadBinaryRequest request);
  $async.Future<$0.StartBinaryResponse> startBinary($pb.ServerContext ctx, $0.StartBinaryRequest request);
  $async.Future<$0.StopBinaryResponse> stopBinary($pb.ServerContext ctx, $0.StopBinaryRequest request);
  $async.Future<$0.StreamLogsResponse> streamLogs($pb.ServerContext ctx, $0.StreamLogsRequest request);
  $async.Future<$0.StartWithL1Response> startWithL1($pb.ServerContext ctx, $0.StartWithL1Request request);
  $async.Future<$0.RestartDaemonResponse> restartDaemon($pb.ServerContext ctx, $0.RestartDaemonRequest request);
  $async.Future<$0.RestartL1Response> restartL1($pb.ServerContext ctx, $0.RestartL1Request request);
  $async.Future<$0.ApplyUTXOSnapshotResponse> applyUTXOSnapshot(
      $pb.ServerContext ctx, $0.ApplyUTXOSnapshotRequest request);
  $async.Future<$0.GetSnapshotStatusResponse> getSnapshotStatus(
      $pb.ServerContext ctx, $0.GetSnapshotStatusRequest request);
  $async.Future<$0.GetPendingNetworkGenerationResponse> getPendingNetworkGeneration(
      $pb.ServerContext ctx, $0.GetPendingNetworkGenerationRequest request);
  $async.Future<$0.ConfirmPendingNetworkGenerationResponse> confirmPendingNetworkGeneration(
      $pb.ServerContext ctx, $0.ConfirmPendingNetworkGenerationRequest request);
  $async.Future<$0.ShutdownAllResponse> shutdownAll($pb.ServerContext ctx, $0.ShutdownAllRequest request);
  $async.Future<$0.ShutdownResponse> shutdown($pb.ServerContext ctx, $0.ShutdownRequest request);
  $async.Future<$0.AdoptOwnerResponse> adoptOwner($pb.ServerContext ctx, $0.AdoptOwnerRequest request);
  $async.Future<$0.GetBTCPriceResponse> getBTCPrice($pb.ServerContext ctx, $0.GetBTCPriceRequest request);
  $async.Future<$0.GetMainchainBlockchainInfoResponse> getMainchainBlockchainInfo(
      $pb.ServerContext ctx, $0.GetMainchainBlockchainInfoRequest request);
  $async.Future<$0.GetEnforcerBlockchainInfoResponse> getEnforcerBlockchainInfo(
      $pb.ServerContext ctx, $0.GetEnforcerBlockchainInfoRequest request);
  $async.Future<$0.GetSyncStatusResponse> getSyncStatus($pb.ServerContext ctx, $0.GetSyncStatusRequest request);
  $async.Future<$0.GetDownloadStatusResponse> getDownloadStatus(
      $pb.ServerContext ctx, $0.GetDownloadStatusRequest request);
  $async.Future<$0.GetMainchainBalanceResponse> getMainchainBalance(
      $pb.ServerContext ctx, $0.GetMainchainBalanceRequest request);
  $async.Future<$0.GetSidechainBalanceResponse> getSidechainBalance(
      $pb.ServerContext ctx, $0.GetSidechainBalanceRequest request);
  $async.Future<$0.GatherFilesToDeleteResponse> gatherFilesToDelete(
      $pb.ServerContext ctx, $0.GatherFilesToDeleteRequest request);
  $async.Future<$0.DeleteFilesResponse> deleteFiles($pb.ServerContext ctx, $0.DeleteFilesRequest request);
  $async.Future<$0.RejectBlockResponse> rejectBlock($pb.ServerContext ctx, $0.RejectBlockRequest request);
  $async.Future<$0.AcceptBlockResponse> acceptBlock($pb.ServerContext ctx, $0.AcceptBlockRequest request);
  $async.Future<$0.ResetToBlockResponse> resetToBlock($pb.ServerContext ctx, $0.ResetToBlockRequest request);
  $async.Future<$0.GetCoreMempoolInfoResponse> getCoreMempoolInfo(
      $pb.ServerContext ctx, $0.GetCoreMempoolInfoRequest request);
  $async.Future<$0.GetBmmContextResponse> getBmmContext($pb.ServerContext ctx, $0.GetBmmContextRequest request);
  $async.Future<$0.CoreRawCallResponse> coreRawCall($pb.ServerContext ctx, $0.CoreRawCallRequest request);
  $async.Future<$0.GetForkStatusResponse> getForkStatus($pb.ServerContext ctx, $0.GetForkStatusRequest request);
  $async.Future<$0.PreviewECashMigrationResponse> previewECashMigration(
      $pb.ServerContext ctx, $0.PreviewECashMigrationRequest request);
  $async.Future<$0.StartECashMigrationResponse> startECashMigration(
      $pb.ServerContext ctx, $0.StartECashMigrationRequest request);
  $async.Future<$0.GetECashMigrationStatusResponse> getECashMigrationStatus(
      $pb.ServerContext ctx, $0.GetECashMigrationStatusRequest request);
  $async.Future<$0.GetDatadirNetworkResponse> getDatadirNetwork(
      $pb.ServerContext ctx, $0.GetDatadirNetworkRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'ListBinaries':
        return $0.ListBinariesRequest();
      case 'GetBinaryStatus':
        return $0.GetBinaryStatusRequest();
      case 'GetBinaryVersion':
        return $0.GetBinaryVersionRequest();
      case 'DownloadBinary':
        return $0.DownloadBinaryRequest();
      case 'StartBinary':
        return $0.StartBinaryRequest();
      case 'StopBinary':
        return $0.StopBinaryRequest();
      case 'StreamLogs':
        return $0.StreamLogsRequest();
      case 'StartWithL1':
        return $0.StartWithL1Request();
      case 'RestartDaemon':
        return $0.RestartDaemonRequest();
      case 'RestartL1':
        return $0.RestartL1Request();
      case 'ApplyUTXOSnapshot':
        return $0.ApplyUTXOSnapshotRequest();
      case 'GetSnapshotStatus':
        return $0.GetSnapshotStatusRequest();
      case 'GetPendingNetworkGeneration':
        return $0.GetPendingNetworkGenerationRequest();
      case 'ConfirmPendingNetworkGeneration':
        return $0.ConfirmPendingNetworkGenerationRequest();
      case 'ShutdownAll':
        return $0.ShutdownAllRequest();
      case 'Shutdown':
        return $0.ShutdownRequest();
      case 'AdoptOwner':
        return $0.AdoptOwnerRequest();
      case 'GetBTCPrice':
        return $0.GetBTCPriceRequest();
      case 'GetMainchainBlockchainInfo':
        return $0.GetMainchainBlockchainInfoRequest();
      case 'GetEnforcerBlockchainInfo':
        return $0.GetEnforcerBlockchainInfoRequest();
      case 'GetSyncStatus':
        return $0.GetSyncStatusRequest();
      case 'GetDownloadStatus':
        return $0.GetDownloadStatusRequest();
      case 'GetMainchainBalance':
        return $0.GetMainchainBalanceRequest();
      case 'GetSidechainBalance':
        return $0.GetSidechainBalanceRequest();
      case 'GatherFilesToDelete':
        return $0.GatherFilesToDeleteRequest();
      case 'DeleteFiles':
        return $0.DeleteFilesRequest();
      case 'RejectBlock':
        return $0.RejectBlockRequest();
      case 'AcceptBlock':
        return $0.AcceptBlockRequest();
      case 'ResetToBlock':
        return $0.ResetToBlockRequest();
      case 'GetCoreMempoolInfo':
        return $0.GetCoreMempoolInfoRequest();
      case 'GetBmmContext':
        return $0.GetBmmContextRequest();
      case 'CoreRawCall':
        return $0.CoreRawCallRequest();
      case 'GetForkStatus':
        return $0.GetForkStatusRequest();
      case 'PreviewECashMigration':
        return $0.PreviewECashMigrationRequest();
      case 'StartECashMigration':
        return $0.StartECashMigrationRequest();
      case 'GetECashMigrationStatus':
        return $0.GetECashMigrationStatusRequest();
      case 'GetDatadirNetwork':
        return $0.GetDatadirNetworkRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall(
      $pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'ListBinaries':
        return listBinaries(ctx, request as $0.ListBinariesRequest);
      case 'GetBinaryStatus':
        return getBinaryStatus(ctx, request as $0.GetBinaryStatusRequest);
      case 'GetBinaryVersion':
        return getBinaryVersion(ctx, request as $0.GetBinaryVersionRequest);
      case 'DownloadBinary':
        return downloadBinary(ctx, request as $0.DownloadBinaryRequest);
      case 'StartBinary':
        return startBinary(ctx, request as $0.StartBinaryRequest);
      case 'StopBinary':
        return stopBinary(ctx, request as $0.StopBinaryRequest);
      case 'StreamLogs':
        return streamLogs(ctx, request as $0.StreamLogsRequest);
      case 'StartWithL1':
        return startWithL1(ctx, request as $0.StartWithL1Request);
      case 'RestartDaemon':
        return restartDaemon(ctx, request as $0.RestartDaemonRequest);
      case 'RestartL1':
        return restartL1(ctx, request as $0.RestartL1Request);
      case 'ApplyUTXOSnapshot':
        return applyUTXOSnapshot(ctx, request as $0.ApplyUTXOSnapshotRequest);
      case 'GetSnapshotStatus':
        return getSnapshotStatus(ctx, request as $0.GetSnapshotStatusRequest);
      case 'GetPendingNetworkGeneration':
        return getPendingNetworkGeneration(ctx, request as $0.GetPendingNetworkGenerationRequest);
      case 'ConfirmPendingNetworkGeneration':
        return confirmPendingNetworkGeneration(ctx, request as $0.ConfirmPendingNetworkGenerationRequest);
      case 'ShutdownAll':
        return shutdownAll(ctx, request as $0.ShutdownAllRequest);
      case 'Shutdown':
        return shutdown(ctx, request as $0.ShutdownRequest);
      case 'AdoptOwner':
        return adoptOwner(ctx, request as $0.AdoptOwnerRequest);
      case 'GetBTCPrice':
        return getBTCPrice(ctx, request as $0.GetBTCPriceRequest);
      case 'GetMainchainBlockchainInfo':
        return getMainchainBlockchainInfo(ctx, request as $0.GetMainchainBlockchainInfoRequest);
      case 'GetEnforcerBlockchainInfo':
        return getEnforcerBlockchainInfo(ctx, request as $0.GetEnforcerBlockchainInfoRequest);
      case 'GetSyncStatus':
        return getSyncStatus(ctx, request as $0.GetSyncStatusRequest);
      case 'GetDownloadStatus':
        return getDownloadStatus(ctx, request as $0.GetDownloadStatusRequest);
      case 'GetMainchainBalance':
        return getMainchainBalance(ctx, request as $0.GetMainchainBalanceRequest);
      case 'GetSidechainBalance':
        return getSidechainBalance(ctx, request as $0.GetSidechainBalanceRequest);
      case 'GatherFilesToDelete':
        return gatherFilesToDelete(ctx, request as $0.GatherFilesToDeleteRequest);
      case 'DeleteFiles':
        return deleteFiles(ctx, request as $0.DeleteFilesRequest);
      case 'RejectBlock':
        return rejectBlock(ctx, request as $0.RejectBlockRequest);
      case 'AcceptBlock':
        return acceptBlock(ctx, request as $0.AcceptBlockRequest);
      case 'ResetToBlock':
        return resetToBlock(ctx, request as $0.ResetToBlockRequest);
      case 'GetCoreMempoolInfo':
        return getCoreMempoolInfo(ctx, request as $0.GetCoreMempoolInfoRequest);
      case 'GetBmmContext':
        return getBmmContext(ctx, request as $0.GetBmmContextRequest);
      case 'CoreRawCall':
        return coreRawCall(ctx, request as $0.CoreRawCallRequest);
      case 'GetForkStatus':
        return getForkStatus(ctx, request as $0.GetForkStatusRequest);
      case 'PreviewECashMigration':
        return previewECashMigration(ctx, request as $0.PreviewECashMigrationRequest);
      case 'StartECashMigration':
        return startECashMigration(ctx, request as $0.StartECashMigrationRequest);
      case 'GetECashMigrationStatus':
        return getECashMigrationStatus(ctx, request as $0.GetECashMigrationStatusRequest);
      case 'GetDatadirNetwork':
        return getDatadirNetwork(ctx, request as $0.GetDatadirNetworkRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => OrchestratorServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson =>
      OrchestratorServiceBase$messageJson;
}
