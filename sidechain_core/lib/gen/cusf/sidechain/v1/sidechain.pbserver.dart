// This is a generated file - do not edit.
//
// Generated from cusf/sidechain/v1/sidechain.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'sidechain.pb.dart' as $0;
import 'sidechain.pbjson.dart';

export 'sidechain.pb.dart';

abstract class SidechainServiceBase extends $pb.GeneratedService {
  $async.Future<$0.GetMempoolTxsResponse> getMempoolTxs($pb.ServerContext ctx, $0.GetMempoolTxsRequest request);
  $async.Future<$0.GetUtxosResponse> getUtxos($pb.ServerContext ctx, $0.GetUtxosRequest request);
  $async.Future<$0.SubmitTransactionResponse> submitTransaction(
      $pb.ServerContext ctx, $0.SubmitTransactionRequest request);
  $async.Future<$0.SubscribeEventsResponse> subscribeEvents($pb.ServerContext ctx, $0.SubscribeEventsRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetMempoolTxs':
        return $0.GetMempoolTxsRequest();
      case 'GetUtxos':
        return $0.GetUtxosRequest();
      case 'SubmitTransaction':
        return $0.SubmitTransactionRequest();
      case 'SubscribeEvents':
        return $0.SubscribeEventsRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall(
      $pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetMempoolTxs':
        return getMempoolTxs(ctx, request as $0.GetMempoolTxsRequest);
      case 'GetUtxos':
        return getUtxos(ctx, request as $0.GetUtxosRequest);
      case 'SubmitTransaction':
        return submitTransaction(ctx, request as $0.SubmitTransactionRequest);
      case 'SubscribeEvents':
        return subscribeEvents(ctx, request as $0.SubscribeEventsRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => SidechainServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => SidechainServiceBase$messageJson;
}
