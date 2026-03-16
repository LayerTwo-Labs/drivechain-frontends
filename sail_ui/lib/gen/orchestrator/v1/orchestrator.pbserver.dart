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
  $async.Future<$2.DownloadBinaryResponse> downloadBinary($pb.ServerContext ctx, $2.DownloadBinaryRequest request);
  $async.Future<$2.StartBinaryResponse> startBinary($pb.ServerContext ctx, $2.StartBinaryRequest request);
  $async.Future<$2.StopBinaryResponse> stopBinary($pb.ServerContext ctx, $2.StopBinaryRequest request);
  $async.Future<$2.WatchBinariesResponse> watchBinaries($pb.ServerContext ctx, $2.WatchBinariesRequest request);
  $async.Future<$2.StreamLogsResponse> streamLogs($pb.ServerContext ctx, $2.StreamLogsRequest request);
  $async.Future<$2.StartWithDepsResponse> startWithDeps($pb.ServerContext ctx, $2.StartWithDepsRequest request);
  $async.Future<$2.ShutdownAllResponse> shutdownAll($pb.ServerContext ctx, $2.ShutdownAllRequest request);
  $async.Future<$2.GetBTCPriceResponse> getBTCPrice($pb.ServerContext ctx, $2.GetBTCPriceRequest request);
  $async.Future<$2.GetMainchainBlockchainInfoResponse> getMainchainBlockchainInfo($pb.ServerContext ctx, $2.GetMainchainBlockchainInfoRequest request);
  $async.Future<$2.GetEnforcerBlockchainInfoResponse> getEnforcerBlockchainInfo($pb.ServerContext ctx, $2.GetEnforcerBlockchainInfoRequest request);
  $async.Future<$2.GetMainchainBalanceResponse> getMainchainBalance($pb.ServerContext ctx, $2.GetMainchainBalanceRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'ListBinaries': return $2.ListBinariesRequest();
      case 'GetBinaryStatus': return $2.GetBinaryStatusRequest();
      case 'DownloadBinary': return $2.DownloadBinaryRequest();
      case 'StartBinary': return $2.StartBinaryRequest();
      case 'StopBinary': return $2.StopBinaryRequest();
      case 'WatchBinaries': return $2.WatchBinariesRequest();
      case 'StreamLogs': return $2.StreamLogsRequest();
      case 'StartWithDeps': return $2.StartWithDepsRequest();
      case 'ShutdownAll': return $2.ShutdownAllRequest();
      case 'GetBTCPrice': return $2.GetBTCPriceRequest();
      case 'GetMainchainBlockchainInfo': return $2.GetMainchainBlockchainInfoRequest();
      case 'GetEnforcerBlockchainInfo': return $2.GetEnforcerBlockchainInfoRequest();
      case 'GetMainchainBalance': return $2.GetMainchainBalanceRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'ListBinaries': return this.listBinaries(ctx, request as $2.ListBinariesRequest);
      case 'GetBinaryStatus': return this.getBinaryStatus(ctx, request as $2.GetBinaryStatusRequest);
      case 'DownloadBinary': return this.downloadBinary(ctx, request as $2.DownloadBinaryRequest);
      case 'StartBinary': return this.startBinary(ctx, request as $2.StartBinaryRequest);
      case 'StopBinary': return this.stopBinary(ctx, request as $2.StopBinaryRequest);
      case 'WatchBinaries': return this.watchBinaries(ctx, request as $2.WatchBinariesRequest);
      case 'StreamLogs': return this.streamLogs(ctx, request as $2.StreamLogsRequest);
      case 'StartWithDeps': return this.startWithDeps(ctx, request as $2.StartWithDepsRequest);
      case 'ShutdownAll': return this.shutdownAll(ctx, request as $2.ShutdownAllRequest);
      case 'GetBTCPrice': return this.getBTCPrice(ctx, request as $2.GetBTCPriceRequest);
      case 'GetMainchainBlockchainInfo': return this.getMainchainBlockchainInfo(ctx, request as $2.GetMainchainBlockchainInfoRequest);
      case 'GetEnforcerBlockchainInfo': return this.getEnforcerBlockchainInfo(ctx, request as $2.GetEnforcerBlockchainInfoRequest);
      case 'GetMainchainBalance': return this.getMainchainBalance(ctx, request as $2.GetMainchainBalanceRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => OrchestratorServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => OrchestratorServiceBase$messageJson;
}

