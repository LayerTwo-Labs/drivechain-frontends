//
//  Generated code. Do not modify.
//  source: cusf/mainchain/v1/validator.proto
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

import 'validator.pb.dart' as $1;

export 'validator.pb.dart';

@$pb.GrpcServiceName('cusf.mainchain.v1.ValidatorService')
class ValidatorServiceClient extends $grpc.Client {
  static final _$getBlockHeaderInfo = $grpc.ClientMethod<$1.GetBlockHeaderInfoRequest, $1.GetBlockHeaderInfoResponse>(
      '/cusf.mainchain.v1.ValidatorService/GetBlockHeaderInfo',
      ($1.GetBlockHeaderInfoRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $1.GetBlockHeaderInfoResponse.fromBuffer(value));
  static final _$getBlockInfo = $grpc.ClientMethod<$1.GetBlockInfoRequest, $1.GetBlockInfoResponse>(
      '/cusf.mainchain.v1.ValidatorService/GetBlockInfo',
      ($1.GetBlockInfoRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $1.GetBlockInfoResponse.fromBuffer(value));
  static final _$getBmmHStarCommitment = $grpc.ClientMethod<$1.GetBmmHStarCommitmentRequest, $1.GetBmmHStarCommitmentResponse>(
      '/cusf.mainchain.v1.ValidatorService/GetBmmHStarCommitment',
      ($1.GetBmmHStarCommitmentRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $1.GetBmmHStarCommitmentResponse.fromBuffer(value));
  static final _$getChainInfo = $grpc.ClientMethod<$1.GetChainInfoRequest, $1.GetChainInfoResponse>(
      '/cusf.mainchain.v1.ValidatorService/GetChainInfo',
      ($1.GetChainInfoRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $1.GetChainInfoResponse.fromBuffer(value));
  static final _$getChainTip = $grpc.ClientMethod<$1.GetChainTipRequest, $1.GetChainTipResponse>(
      '/cusf.mainchain.v1.ValidatorService/GetChainTip',
      ($1.GetChainTipRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $1.GetChainTipResponse.fromBuffer(value));
  static final _$getCoinbasePSBT = $grpc.ClientMethod<$1.GetCoinbasePSBTRequest, $1.GetCoinbasePSBTResponse>(
      '/cusf.mainchain.v1.ValidatorService/GetCoinbasePSBT',
      ($1.GetCoinbasePSBTRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $1.GetCoinbasePSBTResponse.fromBuffer(value));
  static final _$getCtip = $grpc.ClientMethod<$1.GetCtipRequest, $1.GetCtipResponse>(
      '/cusf.mainchain.v1.ValidatorService/GetCtip',
      ($1.GetCtipRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $1.GetCtipResponse.fromBuffer(value));
  static final _$getSidechainProposals = $grpc.ClientMethod<$1.GetSidechainProposalsRequest, $1.GetSidechainProposalsResponse>(
      '/cusf.mainchain.v1.ValidatorService/GetSidechainProposals',
      ($1.GetSidechainProposalsRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $1.GetSidechainProposalsResponse.fromBuffer(value));
  static final _$getSidechains = $grpc.ClientMethod<$1.GetSidechainsRequest, $1.GetSidechainsResponse>(
      '/cusf.mainchain.v1.ValidatorService/GetSidechains',
      ($1.GetSidechainsRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $1.GetSidechainsResponse.fromBuffer(value));
  static final _$getTwoWayPegData = $grpc.ClientMethod<$1.GetTwoWayPegDataRequest, $1.GetTwoWayPegDataResponse>(
      '/cusf.mainchain.v1.ValidatorService/GetTwoWayPegData',
      ($1.GetTwoWayPegDataRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $1.GetTwoWayPegDataResponse.fromBuffer(value));
  static final _$subscribeEvents = $grpc.ClientMethod<$1.SubscribeEventsRequest, $1.SubscribeEventsResponse>(
      '/cusf.mainchain.v1.ValidatorService/SubscribeEvents',
      ($1.SubscribeEventsRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $1.SubscribeEventsResponse.fromBuffer(value));

  ValidatorServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$1.GetBlockHeaderInfoResponse> getBlockHeaderInfo($1.GetBlockHeaderInfoRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getBlockHeaderInfo, request, options: options);
  }

  $grpc.ResponseFuture<$1.GetBlockInfoResponse> getBlockInfo($1.GetBlockInfoRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getBlockInfo, request, options: options);
  }

  $grpc.ResponseFuture<$1.GetBmmHStarCommitmentResponse> getBmmHStarCommitment($1.GetBmmHStarCommitmentRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getBmmHStarCommitment, request, options: options);
  }

  $grpc.ResponseFuture<$1.GetChainInfoResponse> getChainInfo($1.GetChainInfoRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getChainInfo, request, options: options);
  }

  $grpc.ResponseFuture<$1.GetChainTipResponse> getChainTip($1.GetChainTipRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getChainTip, request, options: options);
  }

  $grpc.ResponseFuture<$1.GetCoinbasePSBTResponse> getCoinbasePSBT($1.GetCoinbasePSBTRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getCoinbasePSBT, request, options: options);
  }

  $grpc.ResponseFuture<$1.GetCtipResponse> getCtip($1.GetCtipRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getCtip, request, options: options);
  }

  $grpc.ResponseFuture<$1.GetSidechainProposalsResponse> getSidechainProposals($1.GetSidechainProposalsRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getSidechainProposals, request, options: options);
  }

  $grpc.ResponseFuture<$1.GetSidechainsResponse> getSidechains($1.GetSidechainsRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getSidechains, request, options: options);
  }

  $grpc.ResponseFuture<$1.GetTwoWayPegDataResponse> getTwoWayPegData($1.GetTwoWayPegDataRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getTwoWayPegData, request, options: options);
  }

  $grpc.ResponseStream<$1.SubscribeEventsResponse> subscribeEvents($1.SubscribeEventsRequest request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$subscribeEvents, $async.Stream.fromIterable([request]), options: options);
  }
}

@$pb.GrpcServiceName('cusf.mainchain.v1.ValidatorService')
abstract class ValidatorServiceBase extends $grpc.Service {
  $core.String get $name => 'cusf.mainchain.v1.ValidatorService';

  ValidatorServiceBase() {
    $addMethod($grpc.ServiceMethod<$1.GetBlockHeaderInfoRequest, $1.GetBlockHeaderInfoResponse>(
        'GetBlockHeaderInfo',
        getBlockHeaderInfo_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.GetBlockHeaderInfoRequest.fromBuffer(value),
        ($1.GetBlockHeaderInfoResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.GetBlockInfoRequest, $1.GetBlockInfoResponse>(
        'GetBlockInfo',
        getBlockInfo_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.GetBlockInfoRequest.fromBuffer(value),
        ($1.GetBlockInfoResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.GetBmmHStarCommitmentRequest, $1.GetBmmHStarCommitmentResponse>(
        'GetBmmHStarCommitment',
        getBmmHStarCommitment_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.GetBmmHStarCommitmentRequest.fromBuffer(value),
        ($1.GetBmmHStarCommitmentResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.GetChainInfoRequest, $1.GetChainInfoResponse>(
        'GetChainInfo',
        getChainInfo_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.GetChainInfoRequest.fromBuffer(value),
        ($1.GetChainInfoResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.GetChainTipRequest, $1.GetChainTipResponse>(
        'GetChainTip',
        getChainTip_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.GetChainTipRequest.fromBuffer(value),
        ($1.GetChainTipResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.GetCoinbasePSBTRequest, $1.GetCoinbasePSBTResponse>(
        'GetCoinbasePSBT',
        getCoinbasePSBT_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.GetCoinbasePSBTRequest.fromBuffer(value),
        ($1.GetCoinbasePSBTResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.GetCtipRequest, $1.GetCtipResponse>(
        'GetCtip',
        getCtip_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.GetCtipRequest.fromBuffer(value),
        ($1.GetCtipResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.GetSidechainProposalsRequest, $1.GetSidechainProposalsResponse>(
        'GetSidechainProposals',
        getSidechainProposals_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.GetSidechainProposalsRequest.fromBuffer(value),
        ($1.GetSidechainProposalsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.GetSidechainsRequest, $1.GetSidechainsResponse>(
        'GetSidechains',
        getSidechains_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.GetSidechainsRequest.fromBuffer(value),
        ($1.GetSidechainsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.GetTwoWayPegDataRequest, $1.GetTwoWayPegDataResponse>(
        'GetTwoWayPegData',
        getTwoWayPegData_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.GetTwoWayPegDataRequest.fromBuffer(value),
        ($1.GetTwoWayPegDataResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.SubscribeEventsRequest, $1.SubscribeEventsResponse>(
        'SubscribeEvents',
        subscribeEvents_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $1.SubscribeEventsRequest.fromBuffer(value),
        ($1.SubscribeEventsResponse value) => value.writeToBuffer()));
  }

  $async.Future<$1.GetBlockHeaderInfoResponse> getBlockHeaderInfo_Pre($grpc.ServiceCall call, $async.Future<$1.GetBlockHeaderInfoRequest> request) async {
    return getBlockHeaderInfo(call, await request);
  }

  $async.Future<$1.GetBlockInfoResponse> getBlockInfo_Pre($grpc.ServiceCall call, $async.Future<$1.GetBlockInfoRequest> request) async {
    return getBlockInfo(call, await request);
  }

  $async.Future<$1.GetBmmHStarCommitmentResponse> getBmmHStarCommitment_Pre($grpc.ServiceCall call, $async.Future<$1.GetBmmHStarCommitmentRequest> request) async {
    return getBmmHStarCommitment(call, await request);
  }

  $async.Future<$1.GetChainInfoResponse> getChainInfo_Pre($grpc.ServiceCall call, $async.Future<$1.GetChainInfoRequest> request) async {
    return getChainInfo(call, await request);
  }

  $async.Future<$1.GetChainTipResponse> getChainTip_Pre($grpc.ServiceCall call, $async.Future<$1.GetChainTipRequest> request) async {
    return getChainTip(call, await request);
  }

  $async.Future<$1.GetCoinbasePSBTResponse> getCoinbasePSBT_Pre($grpc.ServiceCall call, $async.Future<$1.GetCoinbasePSBTRequest> request) async {
    return getCoinbasePSBT(call, await request);
  }

  $async.Future<$1.GetCtipResponse> getCtip_Pre($grpc.ServiceCall call, $async.Future<$1.GetCtipRequest> request) async {
    return getCtip(call, await request);
  }

  $async.Future<$1.GetSidechainProposalsResponse> getSidechainProposals_Pre($grpc.ServiceCall call, $async.Future<$1.GetSidechainProposalsRequest> request) async {
    return getSidechainProposals(call, await request);
  }

  $async.Future<$1.GetSidechainsResponse> getSidechains_Pre($grpc.ServiceCall call, $async.Future<$1.GetSidechainsRequest> request) async {
    return getSidechains(call, await request);
  }

  $async.Future<$1.GetTwoWayPegDataResponse> getTwoWayPegData_Pre($grpc.ServiceCall call, $async.Future<$1.GetTwoWayPegDataRequest> request) async {
    return getTwoWayPegData(call, await request);
  }

  $async.Stream<$1.SubscribeEventsResponse> subscribeEvents_Pre($grpc.ServiceCall call, $async.Future<$1.SubscribeEventsRequest> request) async* {
    yield* subscribeEvents(call, await request);
  }

  $async.Future<$1.GetBlockHeaderInfoResponse> getBlockHeaderInfo($grpc.ServiceCall call, $1.GetBlockHeaderInfoRequest request);
  $async.Future<$1.GetBlockInfoResponse> getBlockInfo($grpc.ServiceCall call, $1.GetBlockInfoRequest request);
  $async.Future<$1.GetBmmHStarCommitmentResponse> getBmmHStarCommitment($grpc.ServiceCall call, $1.GetBmmHStarCommitmentRequest request);
  $async.Future<$1.GetChainInfoResponse> getChainInfo($grpc.ServiceCall call, $1.GetChainInfoRequest request);
  $async.Future<$1.GetChainTipResponse> getChainTip($grpc.ServiceCall call, $1.GetChainTipRequest request);
  $async.Future<$1.GetCoinbasePSBTResponse> getCoinbasePSBT($grpc.ServiceCall call, $1.GetCoinbasePSBTRequest request);
  $async.Future<$1.GetCtipResponse> getCtip($grpc.ServiceCall call, $1.GetCtipRequest request);
  $async.Future<$1.GetSidechainProposalsResponse> getSidechainProposals($grpc.ServiceCall call, $1.GetSidechainProposalsRequest request);
  $async.Future<$1.GetSidechainsResponse> getSidechains($grpc.ServiceCall call, $1.GetSidechainsRequest request);
  $async.Future<$1.GetTwoWayPegDataResponse> getTwoWayPegData($grpc.ServiceCall call, $1.GetTwoWayPegDataRequest request);
  $async.Stream<$1.SubscribeEventsResponse> subscribeEvents($grpc.ServiceCall call, $1.SubscribeEventsRequest request);
}
