//
//  Generated code. Do not modify.
//  source: cusf/mainchain/v1/validator.proto
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

import 'validator.pb.dart' as $4;
import 'validator.pbjson.dart';

export 'validator.pb.dart';

abstract class ValidatorServiceBase extends $pb.GeneratedService {
  $async.Future<$4.GetBlockHeaderInfoResponse> getBlockHeaderInfo($pb.ServerContext ctx, $4.GetBlockHeaderInfoRequest request);
  $async.Future<$4.GetBlockInfoResponse> getBlockInfo($pb.ServerContext ctx, $4.GetBlockInfoRequest request);
  $async.Future<$4.GetBmmHStarCommitmentResponse> getBmmHStarCommitment($pb.ServerContext ctx, $4.GetBmmHStarCommitmentRequest request);
  $async.Future<$4.GetChainInfoResponse> getChainInfo($pb.ServerContext ctx, $4.GetChainInfoRequest request);
  $async.Future<$4.GetChainTipResponse> getChainTip($pb.ServerContext ctx, $4.GetChainTipRequest request);
  $async.Future<$4.GetCoinbasePSBTResponse> getCoinbasePSBT($pb.ServerContext ctx, $4.GetCoinbasePSBTRequest request);
  $async.Future<$4.GetCtipResponse> getCtip($pb.ServerContext ctx, $4.GetCtipRequest request);
  $async.Future<$4.GetSidechainProposalsResponse> getSidechainProposals($pb.ServerContext ctx, $4.GetSidechainProposalsRequest request);
  $async.Future<$4.GetSidechainsResponse> getSidechains($pb.ServerContext ctx, $4.GetSidechainsRequest request);
  $async.Future<$4.GetTwoWayPegDataResponse> getTwoWayPegData($pb.ServerContext ctx, $4.GetTwoWayPegDataRequest request);
  $async.Future<$4.SubscribeEventsResponse> subscribeEvents($pb.ServerContext ctx, $4.SubscribeEventsRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetBlockHeaderInfo': return $4.GetBlockHeaderInfoRequest();
      case 'GetBlockInfo': return $4.GetBlockInfoRequest();
      case 'GetBmmHStarCommitment': return $4.GetBmmHStarCommitmentRequest();
      case 'GetChainInfo': return $4.GetChainInfoRequest();
      case 'GetChainTip': return $4.GetChainTipRequest();
      case 'GetCoinbasePSBT': return $4.GetCoinbasePSBTRequest();
      case 'GetCtip': return $4.GetCtipRequest();
      case 'GetSidechainProposals': return $4.GetSidechainProposalsRequest();
      case 'GetSidechains': return $4.GetSidechainsRequest();
      case 'GetTwoWayPegData': return $4.GetTwoWayPegDataRequest();
      case 'SubscribeEvents': return $4.SubscribeEventsRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetBlockHeaderInfo': return this.getBlockHeaderInfo(ctx, request as $4.GetBlockHeaderInfoRequest);
      case 'GetBlockInfo': return this.getBlockInfo(ctx, request as $4.GetBlockInfoRequest);
      case 'GetBmmHStarCommitment': return this.getBmmHStarCommitment(ctx, request as $4.GetBmmHStarCommitmentRequest);
      case 'GetChainInfo': return this.getChainInfo(ctx, request as $4.GetChainInfoRequest);
      case 'GetChainTip': return this.getChainTip(ctx, request as $4.GetChainTipRequest);
      case 'GetCoinbasePSBT': return this.getCoinbasePSBT(ctx, request as $4.GetCoinbasePSBTRequest);
      case 'GetCtip': return this.getCtip(ctx, request as $4.GetCtipRequest);
      case 'GetSidechainProposals': return this.getSidechainProposals(ctx, request as $4.GetSidechainProposalsRequest);
      case 'GetSidechains': return this.getSidechains(ctx, request as $4.GetSidechainsRequest);
      case 'GetTwoWayPegData': return this.getTwoWayPegData(ctx, request as $4.GetTwoWayPegDataRequest);
      case 'SubscribeEvents': return this.subscribeEvents(ctx, request as $4.SubscribeEventsRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => ValidatorServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => ValidatorServiceBase$messageJson;
}

