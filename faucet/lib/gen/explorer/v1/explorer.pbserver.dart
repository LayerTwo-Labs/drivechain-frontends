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

import 'explorer.pb.dart' as $1;
import 'explorer.pbjson.dart';

export 'explorer.pb.dart';

abstract class ExplorerServiceBase extends $pb.GeneratedService {
  $async.Future<$1.GetChainTipsResponse> getChainTips($pb.ServerContext ctx, $1.GetChainTipsRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetChainTips': return $1.GetChainTipsRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetChainTips': return this.getChainTips(ctx, request as $1.GetChainTipsRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => ExplorerServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => ExplorerServiceBase$messageJson;
}

