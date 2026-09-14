//
//  Generated code. Do not modify.
//  source: explorer/v1/explorer.proto
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

import 'explorer.pb.dart' as $0;
import 'explorer.pbjson.dart';

export 'explorer.pb.dart';

abstract class ExplorerServiceBase extends $pb.GeneratedService {
  $async.Future<$0.GetOverviewResponse> getOverview($pb.ServerContext ctx, $0.GetOverviewRequest request);
  $async.Future<$0.GetBlockResponse> getBlock($pb.ServerContext ctx, $0.GetBlockRequest request);
  $async.Future<$0.ListBlocksResponse> listBlocks($pb.ServerContext ctx, $0.ListBlocksRequest request);
  $async.Future<$0.GetTransactionResponse> getTransaction($pb.ServerContext ctx, $0.GetTransactionRequest request);
  $async.Future<$0.GetSignedTransactionResponse> getSignedTransaction($pb.ServerContext ctx, $0.GetSignedTransactionRequest request);
  $async.Future<$0.RebroadcastTransactionResponse> rebroadcastTransaction($pb.ServerContext ctx, $0.RebroadcastTransactionRequest request);
  $async.Future<$0.BroadcastTransactionResponse> broadcastTransaction($pb.ServerContext ctx, $0.BroadcastTransactionRequest request);
  $async.Future<$0.GetAddressResponse> getAddress($pb.ServerContext ctx, $0.GetAddressRequest request);
  $async.Future<$0.GetWithdrawalsResponse> getWithdrawals($pb.ServerContext ctx, $0.GetWithdrawalsRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetOverview': return $0.GetOverviewRequest();
      case 'GetBlock': return $0.GetBlockRequest();
      case 'ListBlocks': return $0.ListBlocksRequest();
      case 'GetTransaction': return $0.GetTransactionRequest();
      case 'GetSignedTransaction': return $0.GetSignedTransactionRequest();
      case 'RebroadcastTransaction': return $0.RebroadcastTransactionRequest();
      case 'BroadcastTransaction': return $0.BroadcastTransactionRequest();
      case 'GetAddress': return $0.GetAddressRequest();
      case 'GetWithdrawals': return $0.GetWithdrawalsRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetOverview': return this.getOverview(ctx, request as $0.GetOverviewRequest);
      case 'GetBlock': return this.getBlock(ctx, request as $0.GetBlockRequest);
      case 'ListBlocks': return this.listBlocks(ctx, request as $0.ListBlocksRequest);
      case 'GetTransaction': return this.getTransaction(ctx, request as $0.GetTransactionRequest);
      case 'GetSignedTransaction': return this.getSignedTransaction(ctx, request as $0.GetSignedTransactionRequest);
      case 'RebroadcastTransaction': return this.rebroadcastTransaction(ctx, request as $0.RebroadcastTransactionRequest);
      case 'BroadcastTransaction': return this.broadcastTransaction(ctx, request as $0.BroadcastTransactionRequest);
      case 'GetAddress': return this.getAddress(ctx, request as $0.GetAddressRequest);
      case 'GetWithdrawals': return this.getWithdrawals(ctx, request as $0.GetWithdrawalsRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => ExplorerServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => ExplorerServiceBase$messageJson;
}

