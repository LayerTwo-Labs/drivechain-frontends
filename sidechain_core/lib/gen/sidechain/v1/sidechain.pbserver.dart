// This is a generated file - do not edit.
//
// Generated from sidechain/v1/sidechain.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'sidechain.pb.dart' as $1;
import 'sidechain.pbjson.dart';

export 'sidechain.pb.dart';

abstract class SidechainServiceBase extends $pb.GeneratedService {
  $async.Future<$1.GetDetectedWithdrawalsResponse> getDetectedWithdrawals(
      $pb.ServerContext ctx, $1.GetDetectedWithdrawalsRequest request);
  $async.Future<$1.GetWithdrawalByTxidResponse> getWithdrawalByTxid(
      $pb.ServerContext ctx, $1.GetWithdrawalByTxidRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetDetectedWithdrawals':
        return $1.GetDetectedWithdrawalsRequest();
      case 'GetWithdrawalByTxid':
        return $1.GetWithdrawalByTxidRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall(
      $pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetDetectedWithdrawals':
        return getDetectedWithdrawals(ctx, request as $1.GetDetectedWithdrawalsRequest);
      case 'GetWithdrawalByTxid':
        return getWithdrawalByTxid(ctx, request as $1.GetWithdrawalByTxidRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => SidechainServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => SidechainServiceBase$messageJson;
}
