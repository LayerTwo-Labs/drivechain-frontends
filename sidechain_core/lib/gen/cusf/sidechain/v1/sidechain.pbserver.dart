//
//  Generated code. Do not modify.
//  source: cusf/sidechain/v1/sidechain.proto
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

import 'sidechain.pb.dart' as $5;
import 'sidechain.pbjson.dart';

export 'sidechain.pb.dart';

abstract class SidechainServiceBase extends $pb.GeneratedService {
  $async.Future<$5.GetMempoolTxsResponse> getMempoolTxs($pb.ServerContext ctx, $5.GetMempoolTxsRequest request);
  $async.Future<$5.GetUtxosResponse> getUtxos($pb.ServerContext ctx, $5.GetUtxosRequest request);
  $async.Future<$5.SubmitTransactionResponse> submitTransaction($pb.ServerContext ctx, $5.SubmitTransactionRequest request);
  $async.Future<$5.SubscribeEventsResponse> subscribeEvents($pb.ServerContext ctx, $5.SubscribeEventsRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetMempoolTxs': return $5.GetMempoolTxsRequest();
      case 'GetUtxos': return $5.GetUtxosRequest();
      case 'SubmitTransaction': return $5.SubmitTransactionRequest();
      case 'SubscribeEvents': return $5.SubscribeEventsRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetMempoolTxs': return this.getMempoolTxs(ctx, request as $5.GetMempoolTxsRequest);
      case 'GetUtxos': return this.getUtxos(ctx, request as $5.GetUtxosRequest);
      case 'SubmitTransaction': return this.submitTransaction(ctx, request as $5.SubmitTransactionRequest);
      case 'SubscribeEvents': return this.subscribeEvents(ctx, request as $5.SubscribeEventsRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => SidechainServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => SidechainServiceBase$messageJson;
}

