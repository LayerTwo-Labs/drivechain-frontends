//
//  Generated code. Do not modify.
//  source: cusf/sidechain/v1/sidechain.proto
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

import 'sidechain.pb.dart' as $2;

export 'sidechain.pb.dart';

@$pb.GrpcServiceName('cusf.sidechain.v1.SidechainService')
class SidechainServiceClient extends $grpc.Client {
  static final _$getMempoolTxs = $grpc.ClientMethod<$2.GetMempoolTxsRequest, $2.GetMempoolTxsResponse>(
      '/cusf.sidechain.v1.SidechainService/GetMempoolTxs',
      ($2.GetMempoolTxsRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $2.GetMempoolTxsResponse.fromBuffer(value));
  static final _$getUtxos = $grpc.ClientMethod<$2.GetUtxosRequest, $2.GetUtxosResponse>(
      '/cusf.sidechain.v1.SidechainService/GetUtxos',
      ($2.GetUtxosRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $2.GetUtxosResponse.fromBuffer(value));
  static final _$submitTransaction = $grpc.ClientMethod<$2.SubmitTransactionRequest, $2.SubmitTransactionResponse>(
      '/cusf.sidechain.v1.SidechainService/SubmitTransaction',
      ($2.SubmitTransactionRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $2.SubmitTransactionResponse.fromBuffer(value));
  static final _$subscribeEvents = $grpc.ClientMethod<$2.SubscribeEventsRequest, $2.SubscribeEventsResponse>(
      '/cusf.sidechain.v1.SidechainService/SubscribeEvents',
      ($2.SubscribeEventsRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $2.SubscribeEventsResponse.fromBuffer(value));

  SidechainServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$2.GetMempoolTxsResponse> getMempoolTxs($2.GetMempoolTxsRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getMempoolTxs, request, options: options);
  }

  $grpc.ResponseFuture<$2.GetUtxosResponse> getUtxos($2.GetUtxosRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getUtxos, request, options: options);
  }

  $grpc.ResponseFuture<$2.SubmitTransactionResponse> submitTransaction($2.SubmitTransactionRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$submitTransaction, request, options: options);
  }

  $grpc.ResponseStream<$2.SubscribeEventsResponse> subscribeEvents($2.SubscribeEventsRequest request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$subscribeEvents, $async.Stream.fromIterable([request]), options: options);
  }
}

@$pb.GrpcServiceName('cusf.sidechain.v1.SidechainService')
abstract class SidechainServiceBase extends $grpc.Service {
  $core.String get $name => 'cusf.sidechain.v1.SidechainService';

  SidechainServiceBase() {
    $addMethod($grpc.ServiceMethod<$2.GetMempoolTxsRequest, $2.GetMempoolTxsResponse>(
        'GetMempoolTxs',
        getMempoolTxs_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.GetMempoolTxsRequest.fromBuffer(value),
        ($2.GetMempoolTxsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.GetUtxosRequest, $2.GetUtxosResponse>(
        'GetUtxos',
        getUtxos_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.GetUtxosRequest.fromBuffer(value),
        ($2.GetUtxosResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.SubmitTransactionRequest, $2.SubmitTransactionResponse>(
        'SubmitTransaction',
        submitTransaction_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.SubmitTransactionRequest.fromBuffer(value),
        ($2.SubmitTransactionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.SubscribeEventsRequest, $2.SubscribeEventsResponse>(
        'SubscribeEvents',
        subscribeEvents_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $2.SubscribeEventsRequest.fromBuffer(value),
        ($2.SubscribeEventsResponse value) => value.writeToBuffer()));
  }

  $async.Future<$2.GetMempoolTxsResponse> getMempoolTxs_Pre($grpc.ServiceCall call, $async.Future<$2.GetMempoolTxsRequest> request) async {
    return getMempoolTxs(call, await request);
  }

  $async.Future<$2.GetUtxosResponse> getUtxos_Pre($grpc.ServiceCall call, $async.Future<$2.GetUtxosRequest> request) async {
    return getUtxos(call, await request);
  }

  $async.Future<$2.SubmitTransactionResponse> submitTransaction_Pre($grpc.ServiceCall call, $async.Future<$2.SubmitTransactionRequest> request) async {
    return submitTransaction(call, await request);
  }

  $async.Stream<$2.SubscribeEventsResponse> subscribeEvents_Pre($grpc.ServiceCall call, $async.Future<$2.SubscribeEventsRequest> request) async* {
    yield* subscribeEvents(call, await request);
  }

  $async.Future<$2.GetMempoolTxsResponse> getMempoolTxs($grpc.ServiceCall call, $2.GetMempoolTxsRequest request);
  $async.Future<$2.GetUtxosResponse> getUtxos($grpc.ServiceCall call, $2.GetUtxosRequest request);
  $async.Future<$2.SubmitTransactionResponse> submitTransaction($grpc.ServiceCall call, $2.SubmitTransactionRequest request);
  $async.Stream<$2.SubscribeEventsResponse> subscribeEvents($grpc.ServiceCall call, $2.SubscribeEventsRequest request);
}
