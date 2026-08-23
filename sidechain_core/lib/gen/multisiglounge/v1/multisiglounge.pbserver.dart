//
//  Generated code. Do not modify.
//  source: multisiglounge/v1/multisiglounge.proto
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

import 'multisiglounge.pb.dart' as $6;
import 'multisiglounge.pbjson.dart';

export 'multisiglounge.pb.dart';

abstract class MultisigLoungeServiceBase extends $pb.GeneratedService {
  $async.Future<$6.BuildDescriptorsResponse> buildDescriptors($pb.ServerContext ctx, $6.BuildDescriptorsRequest request);
  $async.Future<$6.ValidatePsbtResponse> validatePsbt($pb.ServerContext ctx, $6.ValidatePsbtRequest request);
  $async.Future<$6.PublishGroupResponse> publishGroup($pb.ServerContext ctx, $6.PublishGroupRequest request);
  $async.Future<$6.ImportGroupFromTxidResponse> importGroupFromTxid($pb.ServerContext ctx, $6.ImportGroupFromTxidRequest request);
  $async.Future<$6.SignTransactionResponse> signTransaction($pb.ServerContext ctx, $6.SignTransactionRequest request);
  $async.Future<$6.CombineAndBroadcastResponse> combineAndBroadcast($pb.ServerContext ctx, $6.CombineAndBroadcastRequest request);
  $async.Future<$6.SyncGroupResponse> syncGroup($pb.ServerContext ctx, $6.SyncGroupRequest request);
  $async.Future<$6.RestoreHistoryResponse> restoreHistory($pb.ServerContext ctx, $6.RestoreHistoryRequest request);
  $async.Future<$6.CreateSpendPsbtResponse> createSpendPsbt($pb.ServerContext ctx, $6.CreateSpendPsbtRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'BuildDescriptors': return $6.BuildDescriptorsRequest();
      case 'ValidatePsbt': return $6.ValidatePsbtRequest();
      case 'PublishGroup': return $6.PublishGroupRequest();
      case 'ImportGroupFromTxid': return $6.ImportGroupFromTxidRequest();
      case 'SignTransaction': return $6.SignTransactionRequest();
      case 'CombineAndBroadcast': return $6.CombineAndBroadcastRequest();
      case 'SyncGroup': return $6.SyncGroupRequest();
      case 'RestoreHistory': return $6.RestoreHistoryRequest();
      case 'CreateSpendPsbt': return $6.CreateSpendPsbtRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'BuildDescriptors': return this.buildDescriptors(ctx, request as $6.BuildDescriptorsRequest);
      case 'ValidatePsbt': return this.validatePsbt(ctx, request as $6.ValidatePsbtRequest);
      case 'PublishGroup': return this.publishGroup(ctx, request as $6.PublishGroupRequest);
      case 'ImportGroupFromTxid': return this.importGroupFromTxid(ctx, request as $6.ImportGroupFromTxidRequest);
      case 'SignTransaction': return this.signTransaction(ctx, request as $6.SignTransactionRequest);
      case 'CombineAndBroadcast': return this.combineAndBroadcast(ctx, request as $6.CombineAndBroadcastRequest);
      case 'SyncGroup': return this.syncGroup(ctx, request as $6.SyncGroupRequest);
      case 'RestoreHistory': return this.restoreHistory(ctx, request as $6.RestoreHistoryRequest);
      case 'CreateSpendPsbt': return this.createSpendPsbt(ctx, request as $6.CreateSpendPsbtRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => MultisigLoungeServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => MultisigLoungeServiceBase$messageJson;
}

