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

import 'sidechain.pb.dart' as $3;

export 'sidechain.pb.dart';

@$pb.GrpcServiceName('cusf.sidechain.v1.SidechainService')
class SidechainServiceClient extends $grpc.Client {
  static final _$getMempoolTxs = $grpc.ClientMethod<$3.GetMempoolTxsRequest, $3.GetMempoolTxsResponse>(
      '/cusf.sidechain.v1.SidechainService/GetMempoolTxs',
      ($3.GetMempoolTxsRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $3.GetMempoolTxsResponse.fromBuffer(value));
  static final _$getUtxos = $grpc.ClientMethod<$3.GetUtxosRequest, $3.GetUtxosResponse>(
      '/cusf.sidechain.v1.SidechainService/GetUtxos',
      ($3.GetUtxosRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $3.GetUtxosResponse.fromBuffer(value));
  static final _$submitTransaction = $grpc.ClientMethod<$3.SubmitTransactionRequest, $3.SubmitTransactionResponse>(
      '/cusf.sidechain.v1.SidechainService/SubmitTransaction',
      ($3.SubmitTransactionRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $3.SubmitTransactionResponse.fromBuffer(value));
  static final _$subscribeEvents = $grpc.ClientMethod<$3.SubscribeEventsRequest, $3.SubscribeEventsResponse>(
      '/cusf.sidechain.v1.SidechainService/SubscribeEvents',
      ($3.SubscribeEventsRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $3.SubscribeEventsResponse.fromBuffer(value));

  SidechainServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$3.GetMempoolTxsResponse> getMempoolTxs($3.GetMempoolTxsRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getMempoolTxs, request, options: options);
  }

  $grpc.ResponseFuture<$3.GetUtxosResponse> getUtxos($3.GetUtxosRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getUtxos, request, options: options);
  }

  $grpc.ResponseFuture<$3.SubmitTransactionResponse> submitTransaction($3.SubmitTransactionRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$submitTransaction, request, options: options);
  }

  $grpc.ResponseStream<$3.SubscribeEventsResponse> subscribeEvents($3.SubscribeEventsRequest request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$subscribeEvents, $async.Stream.fromIterable([request]), options: options);
  }
}

@$pb.GrpcServiceName('cusf.sidechain.v1.SidechainService')
abstract class SidechainServiceBase extends $grpc.Service {
  $core.String get $name => 'cusf.sidechain.v1.SidechainService';

  SidechainServiceBase() {
    $addMethod($grpc.ServiceMethod<$3.GetMempoolTxsRequest, $3.GetMempoolTxsResponse>(
        'GetMempoolTxs',
        getMempoolTxs_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $3.GetMempoolTxsRequest.fromBuffer(value),
        ($3.GetMempoolTxsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$3.GetUtxosRequest, $3.GetUtxosResponse>(
        'GetUtxos',
        getUtxos_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $3.GetUtxosRequest.fromBuffer(value),
        ($3.GetUtxosResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$3.SubmitTransactionRequest, $3.SubmitTransactionResponse>(
        'SubmitTransaction',
        submitTransaction_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $3.SubmitTransactionRequest.fromBuffer(value),
        ($3.SubmitTransactionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$3.SubscribeEventsRequest, $3.SubscribeEventsResponse>(
        'SubscribeEvents',
        subscribeEvents_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $3.SubscribeEventsRequest.fromBuffer(value),
        ($3.SubscribeEventsResponse value) => value.writeToBuffer()));
  }

  $async.Future<$3.GetMempoolTxsResponse> getMempoolTxs_Pre($grpc.ServiceCall call, $async.Future<$3.GetMempoolTxsRequest> request) async {
    return getMempoolTxs(call, await request);
  }

  $async.Future<$3.GetUtxosResponse> getUtxos_Pre($grpc.ServiceCall call, $async.Future<$3.GetUtxosRequest> request) async {
    return getUtxos(call, await request);
  }

  $async.Future<$3.SubmitTransactionResponse> submitTransaction_Pre($grpc.ServiceCall call, $async.Future<$3.SubmitTransactionRequest> request) async {
    return submitTransaction(call, await request);
  }

  $async.Stream<$3.SubscribeEventsResponse> subscribeEvents_Pre($grpc.ServiceCall call, $async.Future<$3.SubscribeEventsRequest> request) async* {
    yield* subscribeEvents(call, await request);
  }

  $async.Future<$3.GetMempoolTxsResponse> getMempoolTxs($grpc.ServiceCall call, $3.GetMempoolTxsRequest request);
  $async.Future<$3.GetUtxosResponse> getUtxos($grpc.ServiceCall call, $3.GetUtxosRequest request);
  $async.Future<$3.SubmitTransactionResponse> submitTransaction($grpc.ServiceCall call, $3.SubmitTransactionRequest request);
  $async.Stream<$3.SubscribeEventsResponse> subscribeEvents($grpc.ServiceCall call, $3.SubscribeEventsRequest request);
}
