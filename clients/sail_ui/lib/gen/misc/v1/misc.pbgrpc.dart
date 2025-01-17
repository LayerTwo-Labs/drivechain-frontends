//
//  Generated code. Do not modify.
//  source: misc/v1/misc.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import '../../google/protobuf/empty.pb.dart' as $1;
import 'misc.pb.dart' as $3;

export 'misc.pb.dart';

@$pb.GrpcServiceName('misc.v1.MiscService')
class MiscServiceClient extends $grpc.Client {
  static final _$listOPReturn = $grpc.ClientMethod<$1.Empty, $3.ListOPReturnResponse>(
      '/misc.v1.MiscService/ListOPReturn',
      ($1.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $3.ListOPReturnResponse.fromBuffer(value));
  static final _$broadcastNews = $grpc.ClientMethod<$3.BroadcastNewsRequest, $3.BroadcastNewsResponse>(
      '/misc.v1.MiscService/BroadcastNews',
      ($3.BroadcastNewsRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $3.BroadcastNewsResponse.fromBuffer(value));
  static final _$createTopic = $grpc.ClientMethod<$3.CreateTopicRequest, $3.CreateTopicResponse>(
      '/misc.v1.MiscService/CreateTopic',
      ($3.CreateTopicRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $3.CreateTopicResponse.fromBuffer(value));
  static final _$listTopics = $grpc.ClientMethod<$1.Empty, $3.ListTopicsResponse>(
      '/misc.v1.MiscService/ListTopics',
      ($1.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $3.ListTopicsResponse.fromBuffer(value));
  static final _$listCoinNews = $grpc.ClientMethod<$3.ListCoinNewsRequest, $3.ListCoinNewsResponse>(
      '/misc.v1.MiscService/ListCoinNews',
      ($3.ListCoinNewsRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $3.ListCoinNewsResponse.fromBuffer(value));

  MiscServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$3.ListOPReturnResponse> listOPReturn($1.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listOPReturn, request, options: options);
  }

  $grpc.ResponseFuture<$3.BroadcastNewsResponse> broadcastNews($3.BroadcastNewsRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$broadcastNews, request, options: options);
  }

  $grpc.ResponseFuture<$3.CreateTopicResponse> createTopic($3.CreateTopicRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$createTopic, request, options: options);
  }

  $grpc.ResponseFuture<$3.ListTopicsResponse> listTopics($1.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listTopics, request, options: options);
  }

  $grpc.ResponseFuture<$3.ListCoinNewsResponse> listCoinNews($3.ListCoinNewsRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listCoinNews, request, options: options);
  }
}

@$pb.GrpcServiceName('misc.v1.MiscService')
abstract class MiscServiceBase extends $grpc.Service {
  $core.String get $name => 'misc.v1.MiscService';

  MiscServiceBase() {
    $addMethod($grpc.ServiceMethod<$1.Empty, $3.ListOPReturnResponse>(
        'ListOPReturn',
        listOPReturn_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($3.ListOPReturnResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$3.BroadcastNewsRequest, $3.BroadcastNewsResponse>(
        'BroadcastNews',
        broadcastNews_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $3.BroadcastNewsRequest.fromBuffer(value),
        ($3.BroadcastNewsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$3.CreateTopicRequest, $3.CreateTopicResponse>(
        'CreateTopic',
        createTopic_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $3.CreateTopicRequest.fromBuffer(value),
        ($3.CreateTopicResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $3.ListTopicsResponse>(
        'ListTopics',
        listTopics_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($3.ListTopicsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$3.ListCoinNewsRequest, $3.ListCoinNewsResponse>(
        'ListCoinNews',
        listCoinNews_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $3.ListCoinNewsRequest.fromBuffer(value),
        ($3.ListCoinNewsResponse value) => value.writeToBuffer()));
  }

  $async.Future<$3.ListOPReturnResponse> listOPReturn_Pre($grpc.ServiceCall call, $async.Future<$1.Empty> request) async {
    return listOPReturn(call, await request);
  }

  $async.Future<$3.BroadcastNewsResponse> broadcastNews_Pre($grpc.ServiceCall call, $async.Future<$3.BroadcastNewsRequest> request) async {
    return broadcastNews(call, await request);
  }

  $async.Future<$3.CreateTopicResponse> createTopic_Pre($grpc.ServiceCall call, $async.Future<$3.CreateTopicRequest> request) async {
    return createTopic(call, await request);
  }

  $async.Future<$3.ListTopicsResponse> listTopics_Pre($grpc.ServiceCall call, $async.Future<$1.Empty> request) async {
    return listTopics(call, await request);
  }

  $async.Future<$3.ListCoinNewsResponse> listCoinNews_Pre($grpc.ServiceCall call, $async.Future<$3.ListCoinNewsRequest> request) async {
    return listCoinNews(call, await request);
  }

  $async.Future<$3.ListOPReturnResponse> listOPReturn($grpc.ServiceCall call, $1.Empty request);
  $async.Future<$3.BroadcastNewsResponse> broadcastNews($grpc.ServiceCall call, $3.BroadcastNewsRequest request);
  $async.Future<$3.CreateTopicResponse> createTopic($grpc.ServiceCall call, $3.CreateTopicRequest request);
  $async.Future<$3.ListTopicsResponse> listTopics($grpc.ServiceCall call, $1.Empty request);
  $async.Future<$3.ListCoinNewsResponse> listCoinNews($grpc.ServiceCall call, $3.ListCoinNewsRequest request);
}
