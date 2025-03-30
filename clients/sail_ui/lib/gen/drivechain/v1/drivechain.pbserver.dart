//
//  Generated code. Do not modify.
//  source: drivechain/v1/drivechain.proto
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

import 'drivechain.pb.dart' as $4;
import 'drivechain.pbjson.dart';

export 'drivechain.pb.dart';

abstract class DrivechainServiceBase extends $pb.GeneratedService {
  $async.Future<$4.ListSidechainsResponse> listSidechains($pb.ServerContext ctx, $4.ListSidechainsRequest request);
  $async.Future<$4.ListSidechainProposalsResponse> listSidechainProposals($pb.ServerContext ctx, $4.ListSidechainProposalsRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'ListSidechains': return $4.ListSidechainsRequest();
      case 'ListSidechainProposals': return $4.ListSidechainProposalsRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'ListSidechains': return this.listSidechains(ctx, request as $4.ListSidechainsRequest);
      case 'ListSidechainProposals': return this.listSidechainProposals(ctx, request as $4.ListSidechainProposalsRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => DrivechainServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => DrivechainServiceBase$messageJson;
}

