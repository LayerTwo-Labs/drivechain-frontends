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

import 'validator.pb.dart' as $0;

export 'validator.pb.dart';

@$pb.GrpcServiceName('cusf.mainchain.v1.ValidatorService')
class ValidatorServiceClient extends $grpc.Client {
  static final _$getBlockHeaderInfo = $grpc.ClientMethod<$0.GetBlockHeaderInfoRequest, $0.GetBlockHeaderInfoResponse>(
      '/cusf.mainchain.v1.ValidatorService/GetBlockHeaderInfo',
      ($0.GetBlockHeaderInfoRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GetBlockHeaderInfoResponse.fromBuffer(value));
  static final _$getBlockInfo = $grpc.ClientMethod<$0.GetBlockInfoRequest, $0.GetBlockInfoResponse>(
      '/cusf.mainchain.v1.ValidatorService/GetBlockInfo',
      ($0.GetBlockInfoRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GetBlockInfoResponse.fromBuffer(value));
  static final _$getBmmHStarCommitment = $grpc.ClientMethod<$0.GetBmmHStarCommitmentRequest, $0.GetBmmHStarCommitmentResponse>(
      '/cusf.mainchain.v1.ValidatorService/GetBmmHStarCommitment',
      ($0.GetBmmHStarCommitmentRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GetBmmHStarCommitmentResponse.fromBuffer(value));
  static final _$getChainInfo = $grpc.ClientMethod<$0.GetChainInfoRequest, $0.GetChainInfoResponse>(
      '/cusf.mainchain.v1.ValidatorService/GetChainInfo',
      ($0.GetChainInfoRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GetChainInfoResponse.fromBuffer(value));
  static final _$getChainTip = $grpc.ClientMethod<$0.GetChainTipRequest, $0.GetChainTipResponse>(
      '/cusf.mainchain.v1.ValidatorService/GetChainTip',
      ($0.GetChainTipRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GetChainTipResponse.fromBuffer(value));
  static final _$getCoinbasePSBT = $grpc.ClientMethod<$0.GetCoinbasePSBTRequest, $0.GetCoinbasePSBTResponse>(
      '/cusf.mainchain.v1.ValidatorService/GetCoinbasePSBT',
      ($0.GetCoinbasePSBTRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GetCoinbasePSBTResponse.fromBuffer(value));
  static final _$getCtip = $grpc.ClientMethod<$0.GetCtipRequest, $0.GetCtipResponse>(
      '/cusf.mainchain.v1.ValidatorService/GetCtip',
      ($0.GetCtipRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GetCtipResponse.fromBuffer(value));
  static final _$getSidechainProposals = $grpc.ClientMethod<$0.GetSidechainProposalsRequest, $0.GetSidechainProposalsResponse>(
      '/cusf.mainchain.v1.ValidatorService/GetSidechainProposals',
      ($0.GetSidechainProposalsRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GetSidechainProposalsResponse.fromBuffer(value));
  static final _$getSidechains = $grpc.ClientMethod<$0.GetSidechainsRequest, $0.GetSidechainsResponse>(
      '/cusf.mainchain.v1.ValidatorService/GetSidechains',
      ($0.GetSidechainsRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GetSidechainsResponse.fromBuffer(value));
  static final _$getTwoWayPegData = $grpc.ClientMethod<$0.GetTwoWayPegDataRequest, $0.GetTwoWayPegDataResponse>(
      '/cusf.mainchain.v1.ValidatorService/GetTwoWayPegData',
      ($0.GetTwoWayPegDataRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GetTwoWayPegDataResponse.fromBuffer(value));
  static final _$subscribeEvents = $grpc.ClientMethod<$0.SubscribeEventsRequest, $0.SubscribeEventsResponse>(
      '/cusf.mainchain.v1.ValidatorService/SubscribeEvents',
      ($0.SubscribeEventsRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.SubscribeEventsResponse.fromBuffer(value));

  ValidatorServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.GetBlockHeaderInfoResponse> getBlockHeaderInfo($0.GetBlockHeaderInfoRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getBlockHeaderInfo, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetBlockInfoResponse> getBlockInfo($0.GetBlockInfoRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getBlockInfo, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetBmmHStarCommitmentResponse> getBmmHStarCommitment($0.GetBmmHStarCommitmentRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getBmmHStarCommitment, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetChainInfoResponse> getChainInfo($0.GetChainInfoRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getChainInfo, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetChainTipResponse> getChainTip($0.GetChainTipRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getChainTip, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetCoinbasePSBTResponse> getCoinbasePSBT($0.GetCoinbasePSBTRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getCoinbasePSBT, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetCtipResponse> getCtip($0.GetCtipRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getCtip, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetSidechainProposalsResponse> getSidechainProposals($0.GetSidechainProposalsRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getSidechainProposals, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetSidechainsResponse> getSidechains($0.GetSidechainsRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getSidechains, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetTwoWayPegDataResponse> getTwoWayPegData($0.GetTwoWayPegDataRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getTwoWayPegData, request, options: options);
  }

  $grpc.ResponseStream<$0.SubscribeEventsResponse> subscribeEvents($0.SubscribeEventsRequest request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$subscribeEvents, $async.Stream.fromIterable([request]), options: options);
  }
}

@$pb.GrpcServiceName('cusf.mainchain.v1.ValidatorService')
abstract class ValidatorServiceBase extends $grpc.Service {
  $core.String get $name => 'cusf.mainchain.v1.ValidatorService';

  ValidatorServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.GetBlockHeaderInfoRequest, $0.GetBlockHeaderInfoResponse>(
        'GetBlockHeaderInfo',
        getBlockHeaderInfo_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetBlockHeaderInfoRequest.fromBuffer(value),
        ($0.GetBlockHeaderInfoResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetBlockInfoRequest, $0.GetBlockInfoResponse>(
        'GetBlockInfo',
        getBlockInfo_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetBlockInfoRequest.fromBuffer(value),
        ($0.GetBlockInfoResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetBmmHStarCommitmentRequest, $0.GetBmmHStarCommitmentResponse>(
        'GetBmmHStarCommitment',
        getBmmHStarCommitment_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetBmmHStarCommitmentRequest.fromBuffer(value),
        ($0.GetBmmHStarCommitmentResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetChainInfoRequest, $0.GetChainInfoResponse>(
        'GetChainInfo',
        getChainInfo_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetChainInfoRequest.fromBuffer(value),
        ($0.GetChainInfoResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetChainTipRequest, $0.GetChainTipResponse>(
        'GetChainTip',
        getChainTip_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetChainTipRequest.fromBuffer(value),
        ($0.GetChainTipResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetCoinbasePSBTRequest, $0.GetCoinbasePSBTResponse>(
        'GetCoinbasePSBT',
        getCoinbasePSBT_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetCoinbasePSBTRequest.fromBuffer(value),
        ($0.GetCoinbasePSBTResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetCtipRequest, $0.GetCtipResponse>(
        'GetCtip',
        getCtip_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetCtipRequest.fromBuffer(value),
        ($0.GetCtipResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetSidechainProposalsRequest, $0.GetSidechainProposalsResponse>(
        'GetSidechainProposals',
        getSidechainProposals_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetSidechainProposalsRequest.fromBuffer(value),
        ($0.GetSidechainProposalsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetSidechainsRequest, $0.GetSidechainsResponse>(
        'GetSidechains',
        getSidechains_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetSidechainsRequest.fromBuffer(value),
        ($0.GetSidechainsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetTwoWayPegDataRequest, $0.GetTwoWayPegDataResponse>(
        'GetTwoWayPegData',
        getTwoWayPegData_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetTwoWayPegDataRequest.fromBuffer(value),
        ($0.GetTwoWayPegDataResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SubscribeEventsRequest, $0.SubscribeEventsResponse>(
        'SubscribeEvents',
        subscribeEvents_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.SubscribeEventsRequest.fromBuffer(value),
        ($0.SubscribeEventsResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.GetBlockHeaderInfoResponse> getBlockHeaderInfo_Pre($grpc.ServiceCall call, $async.Future<$0.GetBlockHeaderInfoRequest> request) async {
    return getBlockHeaderInfo(call, await request);
  }

  $async.Future<$0.GetBlockInfoResponse> getBlockInfo_Pre($grpc.ServiceCall call, $async.Future<$0.GetBlockInfoRequest> request) async {
    return getBlockInfo(call, await request);
  }

  $async.Future<$0.GetBmmHStarCommitmentResponse> getBmmHStarCommitment_Pre($grpc.ServiceCall call, $async.Future<$0.GetBmmHStarCommitmentRequest> request) async {
    return getBmmHStarCommitment(call, await request);
  }

  $async.Future<$0.GetChainInfoResponse> getChainInfo_Pre($grpc.ServiceCall call, $async.Future<$0.GetChainInfoRequest> request) async {
    return getChainInfo(call, await request);
  }

  $async.Future<$0.GetChainTipResponse> getChainTip_Pre($grpc.ServiceCall call, $async.Future<$0.GetChainTipRequest> request) async {
    return getChainTip(call, await request);
  }

  $async.Future<$0.GetCoinbasePSBTResponse> getCoinbasePSBT_Pre($grpc.ServiceCall call, $async.Future<$0.GetCoinbasePSBTRequest> request) async {
    return getCoinbasePSBT(call, await request);
  }

  $async.Future<$0.GetCtipResponse> getCtip_Pre($grpc.ServiceCall call, $async.Future<$0.GetCtipRequest> request) async {
    return getCtip(call, await request);
  }

  $async.Future<$0.GetSidechainProposalsResponse> getSidechainProposals_Pre($grpc.ServiceCall call, $async.Future<$0.GetSidechainProposalsRequest> request) async {
    return getSidechainProposals(call, await request);
  }

  $async.Future<$0.GetSidechainsResponse> getSidechains_Pre($grpc.ServiceCall call, $async.Future<$0.GetSidechainsRequest> request) async {
    return getSidechains(call, await request);
  }

  $async.Future<$0.GetTwoWayPegDataResponse> getTwoWayPegData_Pre($grpc.ServiceCall call, $async.Future<$0.GetTwoWayPegDataRequest> request) async {
    return getTwoWayPegData(call, await request);
  }

  $async.Stream<$0.SubscribeEventsResponse> subscribeEvents_Pre($grpc.ServiceCall call, $async.Future<$0.SubscribeEventsRequest> request) async* {
    yield* subscribeEvents(call, await request);
  }

  $async.Future<$0.GetBlockHeaderInfoResponse> getBlockHeaderInfo($grpc.ServiceCall call, $0.GetBlockHeaderInfoRequest request);
  $async.Future<$0.GetBlockInfoResponse> getBlockInfo($grpc.ServiceCall call, $0.GetBlockInfoRequest request);
  $async.Future<$0.GetBmmHStarCommitmentResponse> getBmmHStarCommitment($grpc.ServiceCall call, $0.GetBmmHStarCommitmentRequest request);
  $async.Future<$0.GetChainInfoResponse> getChainInfo($grpc.ServiceCall call, $0.GetChainInfoRequest request);
  $async.Future<$0.GetChainTipResponse> getChainTip($grpc.ServiceCall call, $0.GetChainTipRequest request);
  $async.Future<$0.GetCoinbasePSBTResponse> getCoinbasePSBT($grpc.ServiceCall call, $0.GetCoinbasePSBTRequest request);
  $async.Future<$0.GetCtipResponse> getCtip($grpc.ServiceCall call, $0.GetCtipRequest request);
  $async.Future<$0.GetSidechainProposalsResponse> getSidechainProposals($grpc.ServiceCall call, $0.GetSidechainProposalsRequest request);
  $async.Future<$0.GetSidechainsResponse> getSidechains($grpc.ServiceCall call, $0.GetSidechainsRequest request);
  $async.Future<$0.GetTwoWayPegDataResponse> getTwoWayPegData($grpc.ServiceCall call, $0.GetTwoWayPegDataRequest request);
  $async.Stream<$0.SubscribeEventsResponse> subscribeEvents($grpc.ServiceCall call, $0.SubscribeEventsRequest request);
}
