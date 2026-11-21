// This is a generated file - do not edit.
//
// Generated from mempool/v1/mempool.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'mempool.pb.dart' as $1;
import 'mempool.pbjson.dart';

export 'mempool.pb.dart';

abstract class MempoolServiceBase extends $pb.GeneratedService {
  $async.Future<$1.ListTransactionsResponse> listTransactions(
      $pb.ServerContext ctx, $1.ListTransactionsRequest request);
  $async.Future<$1.GetStatsResponse> getStats($pb.ServerContext ctx, $1.GetStatsRequest request);
  $async.Future<$1.WatchTransactionsResponse> watchTransactions(
      $pb.ServerContext ctx, $1.WatchTransactionsRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'ListTransactions':
        return $1.ListTransactionsRequest();
      case 'GetStats':
        return $1.GetStatsRequest();
      case 'WatchTransactions':
        return $1.WatchTransactionsRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall(
      $pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'ListTransactions':
        return listTransactions(ctx, request as $1.ListTransactionsRequest);
      case 'GetStats':
        return getStats(ctx, request as $1.GetStatsRequest);
      case 'WatchTransactions':
        return watchTransactions(ctx, request as $1.WatchTransactionsRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => MempoolServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => MempoolServiceBase$messageJson;
}
