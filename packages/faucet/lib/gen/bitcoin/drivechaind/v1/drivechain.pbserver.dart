//
//  Generated code. Do not modify.
//  source: bitcoin/drivechaind/v1/drivechain.proto
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

import 'drivechain.pb.dart' as $3;
import 'drivechain.pbjson.dart';

export 'drivechain.pb.dart';

abstract class DrivechainServiceBase extends $pb.GeneratedService {
  $async.Future<$3.CreateSidechainDepositResponse> createSidechainDeposit($pb.ServerContext ctx, $3.CreateSidechainDepositRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'CreateSidechainDeposit': return $3.CreateSidechainDepositRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'CreateSidechainDeposit': return this.createSidechainDeposit(ctx, request as $3.CreateSidechainDepositRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => DrivechainServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => DrivechainServiceBase$messageJson;
}

