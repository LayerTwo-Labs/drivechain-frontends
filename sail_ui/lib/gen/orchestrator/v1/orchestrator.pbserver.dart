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
  $async.Future<$5.DownloadBinaryResponse> downloadBinary($pb.ServerContext ctx, $5.DownloadBinaryRequest request);
  $async.Future<$5.StartBinaryResponse> startBinary($pb.ServerContext ctx, $5.StartBinaryRequest request);
  $async.Future<$5.StopBinaryResponse> stopBinary($pb.ServerContext ctx, $5.StopBinaryRequest request);
  $async.Future<$5.WatchBinariesResponse> watchBinaries($pb.ServerContext ctx, $5.WatchBinariesRequest request);
  $async.Future<$5.StreamLogsResponse> streamLogs($pb.ServerContext ctx, $5.StreamLogsRequest request);
  $async.Future<$5.StartWithDepsResponse> startWithDeps($pb.ServerContext ctx, $5.StartWithDepsRequest request);
  $async.Future<$5.ShutdownAllResponse> shutdownAll($pb.ServerContext ctx, $5.ShutdownAllRequest request);
  $async.Future<$5.GetBTCPriceResponse> getBTCPrice($pb.ServerContext ctx, $5.GetBTCPriceRequest request);
  $async.Future<$5.GetMainchainBlockchainInfoResponse> getMainchainBlockchainInfo($pb.ServerContext ctx, $5.GetMainchainBlockchainInfoRequest request);
  $async.Future<$5.GetEnforcerBlockchainInfoResponse> getEnforcerBlockchainInfo($pb.ServerContext ctx, $5.GetEnforcerBlockchainInfoRequest request);
  $async.Future<$5.GetMainchainBalanceResponse> getMainchainBalance($pb.ServerContext ctx, $5.GetMainchainBalanceRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'ListBinaries': return $5.ListBinariesRequest();
      case 'GetBinaryStatus': return $5.GetBinaryStatusRequest();
      case 'DownloadBinary': return $5.DownloadBinaryRequest();
      case 'StartBinary': return $5.StartBinaryRequest();
      case 'StopBinary': return $5.StopBinaryRequest();
      case 'WatchBinaries': return $5.WatchBinariesRequest();
      case 'StreamLogs': return $5.StreamLogsRequest();
      case 'StartWithDeps': return $5.StartWithDepsRequest();
      case 'ShutdownAll': return $5.ShutdownAllRequest();
      case 'GetBTCPrice': return $5.GetBTCPriceRequest();
      case 'GetMainchainBlockchainInfo': return $5.GetMainchainBlockchainInfoRequest();
      case 'GetEnforcerBlockchainInfo': return $5.GetEnforcerBlockchainInfoRequest();
      case 'GetMainchainBalance': return $5.GetMainchainBalanceRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'ListBinaries': return this.listBinaries(ctx, request as $5.ListBinariesRequest);
      case 'GetBinaryStatus': return this.getBinaryStatus(ctx, request as $5.GetBinaryStatusRequest);
      case 'DownloadBinary': return this.downloadBinary(ctx, request as $5.DownloadBinaryRequest);
      case 'StartBinary': return this.startBinary(ctx, request as $5.StartBinaryRequest);
      case 'StopBinary': return this.stopBinary(ctx, request as $5.StopBinaryRequest);
      case 'WatchBinaries': return this.watchBinaries(ctx, request as $5.WatchBinariesRequest);
      case 'StreamLogs': return this.streamLogs(ctx, request as $5.StreamLogsRequest);
      case 'StartWithDeps': return this.startWithDeps(ctx, request as $5.StartWithDepsRequest);
      case 'ShutdownAll': return this.shutdownAll(ctx, request as $5.ShutdownAllRequest);
      case 'GetBTCPrice': return this.getBTCPrice(ctx, request as $5.GetBTCPriceRequest);
      case 'GetMainchainBlockchainInfo': return this.getMainchainBlockchainInfo(ctx, request as $5.GetMainchainBlockchainInfoRequest);
      case 'GetEnforcerBlockchainInfo': return this.getEnforcerBlockchainInfo(ctx, request as $5.GetEnforcerBlockchainInfoRequest);
      case 'GetMainchainBalance': return this.getMainchainBalance(ctx, request as $5.GetMainchainBalanceRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => OrchestratorServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => OrchestratorServiceBase$messageJson;
}

