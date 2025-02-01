//
//  Generated code. Do not modify.
//  source: misc/v1/misc.proto
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
import 'misc.pb.dart' as $5;
import 'misc.pbjson.dart';

export 'misc.pb.dart';

abstract class MiscServiceBase extends $pb.GeneratedService {
  $async.Future<$5.ListOPReturnResponse> listOPReturn($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$5.BroadcastNewsResponse> broadcastNews($pb.ServerContext ctx, $5.BroadcastNewsRequest request);
  $async.Future<$5.CreateTopicResponse> createTopic($pb.ServerContext ctx, $5.CreateTopicRequest request);
  $async.Future<$5.ListTopicsResponse> listTopics($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$5.ListCoinNewsResponse> listCoinNews($pb.ServerContext ctx, $5.ListCoinNewsRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'ListOPReturn': return $1.Empty();
      case 'BroadcastNews': return $5.BroadcastNewsRequest();
      case 'CreateTopic': return $5.CreateTopicRequest();
      case 'ListTopics': return $1.Empty();
      case 'ListCoinNews': return $5.ListCoinNewsRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'ListOPReturn': return this.listOPReturn(ctx, request as $1.Empty);
      case 'BroadcastNews': return this.broadcastNews(ctx, request as $5.BroadcastNewsRequest);
      case 'CreateTopic': return this.createTopic(ctx, request as $5.CreateTopicRequest);
      case 'ListTopics': return this.listTopics(ctx, request as $1.Empty);
      case 'ListCoinNews': return this.listCoinNews(ctx, request as $5.ListCoinNewsRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => MiscServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => MiscServiceBase$messageJson;
}

