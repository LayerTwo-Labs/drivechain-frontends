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

import 'multisiglounge.pb.dart' as $7;
import 'multisiglounge.pbjson.dart';

export 'multisiglounge.pb.dart';

abstract class MultisigLoungeServiceBase extends $pb.GeneratedService {
  $async.Future<$7.BuildDescriptorsResponse> buildDescriptors($pb.ServerContext ctx, $7.BuildDescriptorsRequest request);
  $async.Future<$7.ValidatePsbtResponse> validatePsbt($pb.ServerContext ctx, $7.ValidatePsbtRequest request);
  $async.Future<$7.PublishGroupResponse> publishGroup($pb.ServerContext ctx, $7.PublishGroupRequest request);
  $async.Future<$7.ImportGroupFromTxidResponse> importGroupFromTxid($pb.ServerContext ctx, $7.ImportGroupFromTxidRequest request);
  $async.Future<$7.SignTransactionResponse> signTransaction($pb.ServerContext ctx, $7.SignTransactionRequest request);
  $async.Future<$7.CombineAndBroadcastResponse> combineAndBroadcast($pb.ServerContext ctx, $7.CombineAndBroadcastRequest request);
  $async.Future<$7.SyncGroupResponse> syncGroup($pb.ServerContext ctx, $7.SyncGroupRequest request);
  $async.Future<$7.RestoreHistoryResponse> restoreHistory($pb.ServerContext ctx, $7.RestoreHistoryRequest request);
  $async.Future<$7.CreateSpendPsbtResponse> createSpendPsbt($pb.ServerContext ctx, $7.CreateSpendPsbtRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'BuildDescriptors': return $7.BuildDescriptorsRequest();
      case 'ValidatePsbt': return $7.ValidatePsbtRequest();
      case 'PublishGroup': return $7.PublishGroupRequest();
      case 'ImportGroupFromTxid': return $7.ImportGroupFromTxidRequest();
      case 'SignTransaction': return $7.SignTransactionRequest();
      case 'CombineAndBroadcast': return $7.CombineAndBroadcastRequest();
      case 'SyncGroup': return $7.SyncGroupRequest();
      case 'RestoreHistory': return $7.RestoreHistoryRequest();
      case 'CreateSpendPsbt': return $7.CreateSpendPsbtRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'BuildDescriptors': return this.buildDescriptors(ctx, request as $7.BuildDescriptorsRequest);
      case 'ValidatePsbt': return this.validatePsbt(ctx, request as $7.ValidatePsbtRequest);
      case 'PublishGroup': return this.publishGroup(ctx, request as $7.PublishGroupRequest);
      case 'ImportGroupFromTxid': return this.importGroupFromTxid(ctx, request as $7.ImportGroupFromTxidRequest);
      case 'SignTransaction': return this.signTransaction(ctx, request as $7.SignTransactionRequest);
      case 'CombineAndBroadcast': return this.combineAndBroadcast(ctx, request as $7.CombineAndBroadcastRequest);
      case 'SyncGroup': return this.syncGroup(ctx, request as $7.SyncGroupRequest);
      case 'RestoreHistory': return this.restoreHistory(ctx, request as $7.RestoreHistoryRequest);
      case 'CreateSpendPsbt': return this.createSpendPsbt(ctx, request as $7.CreateSpendPsbtRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => MultisigLoungeServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => MultisigLoungeServiceBase$messageJson;
}

