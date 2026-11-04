// This is a generated file - do not edit.
//
// Generated from multisig/v1/multisig.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart' as $1;

import 'multisig.pb.dart' as $2;
import 'multisig.pbjson.dart';

export 'multisig.pb.dart';

abstract class MultisigServiceBase extends $pb.GeneratedService {
  $async.Future<$2.ListGroupsResponse> listGroups($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$2.SaveGroupResponse> saveGroup($pb.ServerContext ctx, $2.SaveGroupRequest request);
  $async.Future<$1.Empty> deleteGroup($pb.ServerContext ctx, $2.DeleteGroupRequest request);
  $async.Future<$2.ListTransactionsResponse> listTransactions(
      $pb.ServerContext ctx, $2.ListTransactionsRequest request);
  $async.Future<$2.MultisigTransaction> getTransaction($pb.ServerContext ctx, $2.GetTransactionRequest request);
  $async.Future<$2.MultisigTransaction> getTransactionByTxid(
      $pb.ServerContext ctx, $2.GetTransactionByTxidRequest request);
  $async.Future<$2.SaveTransactionResponse> saveTransaction($pb.ServerContext ctx, $2.SaveTransactionRequest request);
  $async.Future<$2.ListSoloKeysResponse> listSoloKeys($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$1.Empty> addSoloKey($pb.ServerContext ctx, $2.AddSoloKeyRequest request);
  $async.Future<$2.GetNextAccountIndexResponse> getNextAccountIndex(
      $pb.ServerContext ctx, $2.GetNextAccountIndexRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'ListGroups':
        return $1.Empty();
      case 'SaveGroup':
        return $2.SaveGroupRequest();
      case 'DeleteGroup':
        return $2.DeleteGroupRequest();
      case 'ListTransactions':
        return $2.ListTransactionsRequest();
      case 'GetTransaction':
        return $2.GetTransactionRequest();
      case 'GetTransactionByTxid':
        return $2.GetTransactionByTxidRequest();
      case 'SaveTransaction':
        return $2.SaveTransactionRequest();
      case 'ListSoloKeys':
        return $1.Empty();
      case 'AddSoloKey':
        return $2.AddSoloKeyRequest();
      case 'GetNextAccountIndex':
        return $2.GetNextAccountIndexRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall(
      $pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'ListGroups':
        return listGroups(ctx, request as $1.Empty);
      case 'SaveGroup':
        return saveGroup(ctx, request as $2.SaveGroupRequest);
      case 'DeleteGroup':
        return deleteGroup(ctx, request as $2.DeleteGroupRequest);
      case 'ListTransactions':
        return listTransactions(ctx, request as $2.ListTransactionsRequest);
      case 'GetTransaction':
        return getTransaction(ctx, request as $2.GetTransactionRequest);
      case 'GetTransactionByTxid':
        return getTransactionByTxid(ctx, request as $2.GetTransactionByTxidRequest);
      case 'SaveTransaction':
        return saveTransaction(ctx, request as $2.SaveTransactionRequest);
      case 'ListSoloKeys':
        return listSoloKeys(ctx, request as $1.Empty);
      case 'AddSoloKey':
        return addSoloKey(ctx, request as $2.AddSoloKeyRequest);
      case 'GetNextAccountIndex':
        return getNextAccountIndex(ctx, request as $2.GetNextAccountIndexRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => MultisigServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => MultisigServiceBase$messageJson;
}
