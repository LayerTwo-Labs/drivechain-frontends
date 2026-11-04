// This is a generated file - do not edit.
//
// Generated from drivechain/v1/drivechain.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'drivechain.pb.dart' as $0;
import 'drivechain.pbjson.dart';

export 'drivechain.pb.dart';

abstract class DrivechainServiceBase extends $pb.GeneratedService {
  $async.Future<$0.ListSidechainsResponse> listSidechains($pb.ServerContext ctx, $0.ListSidechainsRequest request);
  $async.Future<$0.ListSidechainProposalsResponse> listSidechainProposals(
      $pb.ServerContext ctx, $0.ListSidechainProposalsRequest request);
  $async.Future<$0.ProposeSidechainResponse> proposeSidechain(
      $pb.ServerContext ctx, $0.ProposeSidechainRequest request);
  $async.Future<$0.ListWithdrawalsResponse> listWithdrawals($pb.ServerContext ctx, $0.ListWithdrawalsRequest request);
  $async.Future<$0.ListRecentActionsResponse> listRecentActions(
      $pb.ServerContext ctx, $0.ListRecentActionsRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'ListSidechains':
        return $0.ListSidechainsRequest();
      case 'ListSidechainProposals':
        return $0.ListSidechainProposalsRequest();
      case 'ProposeSidechain':
        return $0.ProposeSidechainRequest();
      case 'ListWithdrawals':
        return $0.ListWithdrawalsRequest();
      case 'ListRecentActions':
        return $0.ListRecentActionsRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall(
      $pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'ListSidechains':
        return listSidechains(ctx, request as $0.ListSidechainsRequest);
      case 'ListSidechainProposals':
        return listSidechainProposals(ctx, request as $0.ListSidechainProposalsRequest);
      case 'ProposeSidechain':
        return proposeSidechain(ctx, request as $0.ProposeSidechainRequest);
      case 'ListWithdrawals':
        return listWithdrawals(ctx, request as $0.ListWithdrawalsRequest);
      case 'ListRecentActions':
        return listRecentActions(ctx, request as $0.ListRecentActionsRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => DrivechainServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => DrivechainServiceBase$messageJson;
}
