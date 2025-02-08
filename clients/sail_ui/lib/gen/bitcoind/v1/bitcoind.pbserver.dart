//
//  Generated code. Do not modify.
//  source: bitcoind/v1/bitcoind.proto
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

import '../../google/protobuf/empty.pb.dart' as $1;
import 'bitcoind.pb.dart' as $2;
import 'bitcoind.pbjson.dart';

export 'bitcoind.pb.dart';

abstract class BitcoindServiceBase extends $pb.GeneratedService {
  $async.Future<$2.ListRecentTransactionsResponse> listRecentTransactions($pb.ServerContext ctx, $2.ListRecentTransactionsRequest request);
  $async.Future<$2.ListBlocksResponse> listBlocks($pb.ServerContext ctx, $2.ListBlocksRequest request);
  $async.Future<$2.GetBlockResponse> getBlock($pb.ServerContext ctx, $2.GetBlockRequest request);
  $async.Future<$2.GetBlockchainInfoResponse> getBlockchainInfo($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$2.ListPeersResponse> listPeers($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$2.EstimateSmartFeeResponse> estimateSmartFee($pb.ServerContext ctx, $2.EstimateSmartFeeRequest request);
  $async.Future<$2.GetRawTransactionResponse> getRawTransaction($pb.ServerContext ctx, $2.GetRawTransactionRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'ListRecentTransactions': return $2.ListRecentTransactionsRequest();
      case 'ListBlocks': return $2.ListBlocksRequest();
      case 'GetBlock': return $2.GetBlockRequest();
      case 'GetBlockchainInfo': return $1.Empty();
      case 'ListPeers': return $1.Empty();
      case 'EstimateSmartFee': return $2.EstimateSmartFeeRequest();
      case 'GetRawTransaction': return $2.GetRawTransactionRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'ListRecentTransactions': return this.listRecentTransactions(ctx, request as $2.ListRecentTransactionsRequest);
      case 'ListBlocks': return this.listBlocks(ctx, request as $2.ListBlocksRequest);
      case 'GetBlock': return this.getBlock(ctx, request as $2.GetBlockRequest);
      case 'GetBlockchainInfo': return this.getBlockchainInfo(ctx, request as $1.Empty);
      case 'ListPeers': return this.listPeers(ctx, request as $1.Empty);
      case 'EstimateSmartFee': return this.estimateSmartFee(ctx, request as $2.EstimateSmartFeeRequest);
      case 'GetRawTransaction': return this.getRawTransaction(ctx, request as $2.GetRawTransactionRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => BitcoindServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => BitcoindServiceBase$messageJson;
}

