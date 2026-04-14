//
//  Generated code. Do not modify.
//  source: sidechain/v1/sidechain.proto
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

import 'sidechain.pb.dart' as $10;
import 'sidechain.pbjson.dart';

export 'sidechain.pb.dart';

abstract class SidechainServiceBase extends $pb.GeneratedService {
  $async.Future<$10.GetDetectedWithdrawalsResponse> getDetectedWithdrawals($pb.ServerContext ctx, $10.GetDetectedWithdrawalsRequest request);
  $async.Future<$10.GetWithdrawalByTxidResponse> getWithdrawalByTxid($pb.ServerContext ctx, $10.GetWithdrawalByTxidRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetDetectedWithdrawals': return $10.GetDetectedWithdrawalsRequest();
      case 'GetWithdrawalByTxid': return $10.GetWithdrawalByTxidRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetDetectedWithdrawals': return this.getDetectedWithdrawals(ctx, request as $10.GetDetectedWithdrawalsRequest);
      case 'GetWithdrawalByTxid': return this.getWithdrawalByTxid(ctx, request as $10.GetWithdrawalByTxidRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => SidechainServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => SidechainServiceBase$messageJson;
}

