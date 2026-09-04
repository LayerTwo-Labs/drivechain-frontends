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

import 'explorer.pb.dart' as $6;
import 'explorer.pbjson.dart';

export 'explorer.pb.dart';

abstract class ExplorerServiceBase extends $pb.GeneratedService {
  $async.Future<$6.GetOverviewResponse> getOverview($pb.ServerContext ctx, $6.GetOverviewRequest request);
  $async.Future<$6.GetBlockResponse> getBlock($pb.ServerContext ctx, $6.GetBlockRequest request);
  $async.Future<$6.GetTransactionResponse> getTransaction($pb.ServerContext ctx, $6.GetTransactionRequest request);
  $async.Future<$6.GetAddressResponse> getAddress($pb.ServerContext ctx, $6.GetAddressRequest request);
  $async.Future<$6.GetWithdrawalsResponse> getWithdrawals($pb.ServerContext ctx, $6.GetWithdrawalsRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetOverview': return $6.GetOverviewRequest();
      case 'GetBlock': return $6.GetBlockRequest();
      case 'GetTransaction': return $6.GetTransactionRequest();
      case 'GetAddress': return $6.GetAddressRequest();
      case 'GetWithdrawals': return $6.GetWithdrawalsRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetOverview': return this.getOverview(ctx, request as $6.GetOverviewRequest);
      case 'GetBlock': return this.getBlock(ctx, request as $6.GetBlockRequest);
      case 'GetTransaction': return this.getTransaction(ctx, request as $6.GetTransactionRequest);
      case 'GetAddress': return this.getAddress(ctx, request as $6.GetAddressRequest);
      case 'GetWithdrawals': return this.getWithdrawals(ctx, request as $6.GetWithdrawalsRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => ExplorerServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => ExplorerServiceBase$messageJson;
}

