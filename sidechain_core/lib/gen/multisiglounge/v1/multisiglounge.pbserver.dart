// This is a generated file - do not edit.
//
// Generated from multisiglounge/v1/multisiglounge.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'multisiglounge.pb.dart' as $0;
import 'multisiglounge.pbjson.dart';

export 'multisiglounge.pb.dart';

abstract class MultisigLoungeServiceBase extends $pb.GeneratedService {
  $async.Future<$0.BuildDescriptorsResponse> buildDescriptors(
      $pb.ServerContext ctx, $0.BuildDescriptorsRequest request);
  $async.Future<$0.ValidatePsbtResponse> validatePsbt($pb.ServerContext ctx, $0.ValidatePsbtRequest request);
  $async.Future<$0.PublishGroupResponse> publishGroup($pb.ServerContext ctx, $0.PublishGroupRequest request);
  $async.Future<$0.ImportGroupFromTxidResponse> importGroupFromTxid(
      $pb.ServerContext ctx, $0.ImportGroupFromTxidRequest request);
  $async.Future<$0.SignTransactionResponse> signTransaction($pb.ServerContext ctx, $0.SignTransactionRequest request);
  $async.Future<$0.CombineAndBroadcastResponse> combineAndBroadcast(
      $pb.ServerContext ctx, $0.CombineAndBroadcastRequest request);
  $async.Future<$0.SyncGroupResponse> syncGroup($pb.ServerContext ctx, $0.SyncGroupRequest request);
  $async.Future<$0.RestoreHistoryResponse> restoreHistory($pb.ServerContext ctx, $0.RestoreHistoryRequest request);
  $async.Future<$0.CreateSpendPsbtResponse> createSpendPsbt($pb.ServerContext ctx, $0.CreateSpendPsbtRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'BuildDescriptors':
        return $0.BuildDescriptorsRequest();
      case 'ValidatePsbt':
        return $0.ValidatePsbtRequest();
      case 'PublishGroup':
        return $0.PublishGroupRequest();
      case 'ImportGroupFromTxid':
        return $0.ImportGroupFromTxidRequest();
      case 'SignTransaction':
        return $0.SignTransactionRequest();
      case 'CombineAndBroadcast':
        return $0.CombineAndBroadcastRequest();
      case 'SyncGroup':
        return $0.SyncGroupRequest();
      case 'RestoreHistory':
        return $0.RestoreHistoryRequest();
      case 'CreateSpendPsbt':
        return $0.CreateSpendPsbtRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall(
      $pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'BuildDescriptors':
        return buildDescriptors(ctx, request as $0.BuildDescriptorsRequest);
      case 'ValidatePsbt':
        return validatePsbt(ctx, request as $0.ValidatePsbtRequest);
      case 'PublishGroup':
        return publishGroup(ctx, request as $0.PublishGroupRequest);
      case 'ImportGroupFromTxid':
        return importGroupFromTxid(ctx, request as $0.ImportGroupFromTxidRequest);
      case 'SignTransaction':
        return signTransaction(ctx, request as $0.SignTransactionRequest);
      case 'CombineAndBroadcast':
        return combineAndBroadcast(ctx, request as $0.CombineAndBroadcastRequest);
      case 'SyncGroup':
        return syncGroup(ctx, request as $0.SyncGroupRequest);
      case 'RestoreHistory':
        return restoreHistory(ctx, request as $0.RestoreHistoryRequest);
      case 'CreateSpendPsbt':
        return createSpendPsbt(ctx, request as $0.CreateSpendPsbtRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => MultisigLoungeServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson =>
      MultisigLoungeServiceBase$messageJson;
}
