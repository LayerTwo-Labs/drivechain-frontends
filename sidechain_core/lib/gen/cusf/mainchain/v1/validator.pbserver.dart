// This is a generated file - do not edit.
//
// Generated from cusf/mainchain/v1/validator.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'validator.pb.dart' as $3;
import 'validator.pbjson.dart';

export 'validator.pb.dart';

abstract class ValidatorServiceBase extends $pb.GeneratedService {
  $async.Future<$3.GetBlockHeaderInfoResponse> getBlockHeaderInfo(
      $pb.ServerContext ctx, $3.GetBlockHeaderInfoRequest request);
  $async.Future<$3.GetBlockInfoResponse> getBlockInfo($pb.ServerContext ctx, $3.GetBlockInfoRequest request);
  $async.Future<$3.GetBmmHStarCommitmentResponse> getBmmHStarCommitment(
      $pb.ServerContext ctx, $3.GetBmmHStarCommitmentRequest request);
  $async.Future<$3.GetChainInfoResponse> getChainInfo($pb.ServerContext ctx, $3.GetChainInfoRequest request);
  $async.Future<$3.GetChainTipResponse> getChainTip($pb.ServerContext ctx, $3.GetChainTipRequest request);
  $async.Future<$3.GetCoinbasePSBTResponse> getCoinbasePSBT($pb.ServerContext ctx, $3.GetCoinbasePSBTRequest request);
  $async.Future<$3.GetCtipResponse> getCtip($pb.ServerContext ctx, $3.GetCtipRequest request);
  $async.Future<$3.GetSidechainProposalsResponse> getSidechainProposals(
      $pb.ServerContext ctx, $3.GetSidechainProposalsRequest request);
  $async.Future<$3.GetSidechainsResponse> getSidechains($pb.ServerContext ctx, $3.GetSidechainsRequest request);
  $async.Future<$3.GetTwoWayPegDataResponse> getTwoWayPegData(
      $pb.ServerContext ctx, $3.GetTwoWayPegDataRequest request);
  $async.Future<$3.SubscribeEventsResponse> subscribeEvents($pb.ServerContext ctx, $3.SubscribeEventsRequest request);
  $async.Future<$3.SubscribeHeaderSyncProgressResponse> subscribeHeaderSyncProgress(
      $pb.ServerContext ctx, $3.SubscribeHeaderSyncProgressRequest request);
  $async.Future<$3.StopResponse> stop($pb.ServerContext ctx, $3.StopRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetBlockHeaderInfo':
        return $3.GetBlockHeaderInfoRequest();
      case 'GetBlockInfo':
        return $3.GetBlockInfoRequest();
      case 'GetBmmHStarCommitment':
        return $3.GetBmmHStarCommitmentRequest();
      case 'GetChainInfo':
        return $3.GetChainInfoRequest();
      case 'GetChainTip':
        return $3.GetChainTipRequest();
      case 'GetCoinbasePSBT':
        return $3.GetCoinbasePSBTRequest();
      case 'GetCtip':
        return $3.GetCtipRequest();
      case 'GetSidechainProposals':
        return $3.GetSidechainProposalsRequest();
      case 'GetSidechains':
        return $3.GetSidechainsRequest();
      case 'GetTwoWayPegData':
        return $3.GetTwoWayPegDataRequest();
      case 'SubscribeEvents':
        return $3.SubscribeEventsRequest();
      case 'SubscribeHeaderSyncProgress':
        return $3.SubscribeHeaderSyncProgressRequest();
      case 'Stop':
        return $3.StopRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall(
      $pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetBlockHeaderInfo':
        return getBlockHeaderInfo(ctx, request as $3.GetBlockHeaderInfoRequest);
      case 'GetBlockInfo':
        return getBlockInfo(ctx, request as $3.GetBlockInfoRequest);
      case 'GetBmmHStarCommitment':
        return getBmmHStarCommitment(ctx, request as $3.GetBmmHStarCommitmentRequest);
      case 'GetChainInfo':
        return getChainInfo(ctx, request as $3.GetChainInfoRequest);
      case 'GetChainTip':
        return getChainTip(ctx, request as $3.GetChainTipRequest);
      case 'GetCoinbasePSBT':
        return getCoinbasePSBT(ctx, request as $3.GetCoinbasePSBTRequest);
      case 'GetCtip':
        return getCtip(ctx, request as $3.GetCtipRequest);
      case 'GetSidechainProposals':
        return getSidechainProposals(ctx, request as $3.GetSidechainProposalsRequest);
      case 'GetSidechains':
        return getSidechains(ctx, request as $3.GetSidechainsRequest);
      case 'GetTwoWayPegData':
        return getTwoWayPegData(ctx, request as $3.GetTwoWayPegDataRequest);
      case 'SubscribeEvents':
        return subscribeEvents(ctx, request as $3.SubscribeEventsRequest);
      case 'SubscribeHeaderSyncProgress':
        return subscribeHeaderSyncProgress(ctx, request as $3.SubscribeHeaderSyncProgressRequest);
      case 'Stop':
        return stop(ctx, request as $3.StopRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => ValidatorServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => ValidatorServiceBase$messageJson;
}
