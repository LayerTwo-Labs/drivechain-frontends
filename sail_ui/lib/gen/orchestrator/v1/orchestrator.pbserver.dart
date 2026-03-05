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

import 'orchestrator.pb.dart' as $0;
import 'orchestrator.pbjson.dart';

export 'orchestrator.pb.dart';

abstract class OrchestratorServiceBase extends $pb.GeneratedService {
  $async.Future<$0.ListBinariesResponse> listBinaries($pb.ServerContext ctx, $0.ListBinariesRequest request);
  $async.Future<$0.GetBinaryStatusResponse> getBinaryStatus($pb.ServerContext ctx, $0.GetBinaryStatusRequest request);
  $async.Future<$0.DownloadBinaryResponse> downloadBinary($pb.ServerContext ctx, $0.DownloadBinaryRequest request);
  $async.Future<$0.StartBinaryResponse> startBinary($pb.ServerContext ctx, $0.StartBinaryRequest request);
  $async.Future<$0.StopBinaryResponse> stopBinary($pb.ServerContext ctx, $0.StopBinaryRequest request);
  $async.Future<$0.WatchBinariesResponse> watchBinaries($pb.ServerContext ctx, $0.WatchBinariesRequest request);
  $async.Future<$0.StreamLogsResponse> streamLogs($pb.ServerContext ctx, $0.StreamLogsRequest request);
  $async.Future<$0.StartWithDepsResponse> startWithDeps($pb.ServerContext ctx, $0.StartWithDepsRequest request);
  $async.Future<$0.ShutdownAllResponse> shutdownAll($pb.ServerContext ctx, $0.ShutdownAllRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'ListBinaries': return $0.ListBinariesRequest();
      case 'GetBinaryStatus': return $0.GetBinaryStatusRequest();
      case 'DownloadBinary': return $0.DownloadBinaryRequest();
      case 'StartBinary': return $0.StartBinaryRequest();
      case 'StopBinary': return $0.StopBinaryRequest();
      case 'WatchBinaries': return $0.WatchBinariesRequest();
      case 'StreamLogs': return $0.StreamLogsRequest();
      case 'StartWithDeps': return $0.StartWithDepsRequest();
      case 'ShutdownAll': return $0.ShutdownAllRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'ListBinaries': return this.listBinaries(ctx, request as $0.ListBinariesRequest);
      case 'GetBinaryStatus': return this.getBinaryStatus(ctx, request as $0.GetBinaryStatusRequest);
      case 'DownloadBinary': return this.downloadBinary(ctx, request as $0.DownloadBinaryRequest);
      case 'StartBinary': return this.startBinary(ctx, request as $0.StartBinaryRequest);
      case 'StopBinary': return this.stopBinary(ctx, request as $0.StopBinaryRequest);
      case 'WatchBinaries': return this.watchBinaries(ctx, request as $0.WatchBinariesRequest);
      case 'StreamLogs': return this.streamLogs(ctx, request as $0.StreamLogsRequest);
      case 'StartWithDeps': return this.startWithDeps(ctx, request as $0.StartWithDepsRequest);
      case 'ShutdownAll': return this.shutdownAll(ctx, request as $0.ShutdownAllRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => OrchestratorServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => OrchestratorServiceBase$messageJson;
}

