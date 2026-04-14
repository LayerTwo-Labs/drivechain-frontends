//
//  Generated code. Do not modify.
//  source: fast_withdrawal/v1/fast_withdrawal.proto
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

import 'fast_withdrawal.pb.dart' as $5;
import 'fast_withdrawal.pbjson.dart';

export 'fast_withdrawal.pb.dart';

abstract class FastWithdrawalServiceBase extends $pb.GeneratedService {
  $async.Future<$5.FastWithdrawalUpdate> initiateFastWithdrawal($pb.ServerContext ctx, $5.InitiateFastWithdrawalRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'InitiateFastWithdrawal': return $5.InitiateFastWithdrawalRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'InitiateFastWithdrawal': return this.initiateFastWithdrawal(ctx, request as $5.InitiateFastWithdrawalRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => FastWithdrawalServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => FastWithdrawalServiceBase$messageJson;
}

