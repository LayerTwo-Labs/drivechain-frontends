//
//  Generated code. Do not modify.
//  source: multisig/v1/multisig.proto
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

import '../../google/protobuf/empty.pb.dart' as $1;
import 'multisig.pb.dart' as $9;
import 'multisig.pbjson.dart';

export 'multisig.pb.dart';

abstract class MultisigServiceBase extends $pb.GeneratedService {
  $async.Future<$9.ListGroupsResponse> listGroups($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$9.SaveGroupResponse> saveGroup($pb.ServerContext ctx, $9.SaveGroupRequest request);
  $async.Future<$1.Empty> deleteGroup($pb.ServerContext ctx, $9.DeleteGroupRequest request);
  $async.Future<$9.ListTransactionsResponse> listTransactions($pb.ServerContext ctx, $9.ListTransactionsRequest request);
  $async.Future<$9.MultisigTransaction> getTransaction($pb.ServerContext ctx, $9.GetTransactionRequest request);
  $async.Future<$9.MultisigTransaction> getTransactionByTxid($pb.ServerContext ctx, $9.GetTransactionByTxidRequest request);
  $async.Future<$9.SaveTransactionResponse> saveTransaction($pb.ServerContext ctx, $9.SaveTransactionRequest request);
  $async.Future<$9.ListSoloKeysResponse> listSoloKeys($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$1.Empty> addSoloKey($pb.ServerContext ctx, $9.AddSoloKeyRequest request);
  $async.Future<$9.GetNextAccountIndexResponse> getNextAccountIndex($pb.ServerContext ctx, $9.GetNextAccountIndexRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'ListGroups': return $1.Empty();
      case 'SaveGroup': return $9.SaveGroupRequest();
      case 'DeleteGroup': return $9.DeleteGroupRequest();
      case 'ListTransactions': return $9.ListTransactionsRequest();
      case 'GetTransaction': return $9.GetTransactionRequest();
      case 'GetTransactionByTxid': return $9.GetTransactionByTxidRequest();
      case 'SaveTransaction': return $9.SaveTransactionRequest();
      case 'ListSoloKeys': return $1.Empty();
      case 'AddSoloKey': return $9.AddSoloKeyRequest();
      case 'GetNextAccountIndex': return $9.GetNextAccountIndexRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'ListGroups': return this.listGroups(ctx, request as $1.Empty);
      case 'SaveGroup': return this.saveGroup(ctx, request as $9.SaveGroupRequest);
      case 'DeleteGroup': return this.deleteGroup(ctx, request as $9.DeleteGroupRequest);
      case 'ListTransactions': return this.listTransactions(ctx, request as $9.ListTransactionsRequest);
      case 'GetTransaction': return this.getTransaction(ctx, request as $9.GetTransactionRequest);
      case 'GetTransactionByTxid': return this.getTransactionByTxid(ctx, request as $9.GetTransactionByTxidRequest);
      case 'SaveTransaction': return this.saveTransaction(ctx, request as $9.SaveTransactionRequest);
      case 'ListSoloKeys': return this.listSoloKeys(ctx, request as $1.Empty);
      case 'AddSoloKey': return this.addSoloKey(ctx, request as $9.AddSoloKeyRequest);
      case 'GetNextAccountIndex': return this.getNextAccountIndex(ctx, request as $9.GetNextAccountIndexRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => MultisigServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => MultisigServiceBase$messageJson;
}

