//
//  Generated code. Do not modify.
//  source: bitwindowd/v1/bitwindowd.proto
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
import 'bitwindowd.pb.dart' as $2;
import 'bitwindowd.pbjson.dart';

export 'bitwindowd.pb.dart';

abstract class BitwindowdServiceBase extends $pb.GeneratedService {
  $async.Future<$1.Empty> stop($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$1.Empty> createDenial($pb.ServerContext ctx, $2.CreateDenialRequest request);
  $async.Future<$1.Empty> cancelDenial($pb.ServerContext ctx, $2.CancelDenialRequest request);
  $async.Future<$2.CreateAddressBookEntryResponse> createAddressBookEntry($pb.ServerContext ctx, $2.CreateAddressBookEntryRequest request);
  $async.Future<$2.ListAddressBookResponse> listAddressBook($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$1.Empty> updateAddressBookEntry($pb.ServerContext ctx, $2.UpdateAddressBookEntryRequest request);
  $async.Future<$1.Empty> deleteAddressBookEntry($pb.ServerContext ctx, $2.DeleteAddressBookEntryRequest request);
  $async.Future<$2.GetSyncInfoResponse> getSyncInfo($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$1.Empty> setTransactionNote($pb.ServerContext ctx, $2.SetTransactionNoteRequest request);
  $async.Future<$2.GetFireplaceStatsResponse> getFireplaceStats($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$2.ListRecentTransactionsResponse> listRecentTransactions($pb.ServerContext ctx, $2.ListRecentTransactionsRequest request);
  $async.Future<$2.ListBlocksResponse> listBlocks($pb.ServerContext ctx, $2.ListBlocksRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'Stop': return $1.Empty();
      case 'CreateDenial': return $2.CreateDenialRequest();
      case 'CancelDenial': return $2.CancelDenialRequest();
      case 'CreateAddressBookEntry': return $2.CreateAddressBookEntryRequest();
      case 'ListAddressBook': return $1.Empty();
      case 'UpdateAddressBookEntry': return $2.UpdateAddressBookEntryRequest();
      case 'DeleteAddressBookEntry': return $2.DeleteAddressBookEntryRequest();
      case 'GetSyncInfo': return $1.Empty();
      case 'SetTransactionNote': return $2.SetTransactionNoteRequest();
      case 'GetFireplaceStats': return $1.Empty();
      case 'ListRecentTransactions': return $2.ListRecentTransactionsRequest();
      case 'ListBlocks': return $2.ListBlocksRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'Stop': return this.stop(ctx, request as $1.Empty);
      case 'CreateDenial': return this.createDenial(ctx, request as $2.CreateDenialRequest);
      case 'CancelDenial': return this.cancelDenial(ctx, request as $2.CancelDenialRequest);
      case 'CreateAddressBookEntry': return this.createAddressBookEntry(ctx, request as $2.CreateAddressBookEntryRequest);
      case 'ListAddressBook': return this.listAddressBook(ctx, request as $1.Empty);
      case 'UpdateAddressBookEntry': return this.updateAddressBookEntry(ctx, request as $2.UpdateAddressBookEntryRequest);
      case 'DeleteAddressBookEntry': return this.deleteAddressBookEntry(ctx, request as $2.DeleteAddressBookEntryRequest);
      case 'GetSyncInfo': return this.getSyncInfo(ctx, request as $1.Empty);
      case 'SetTransactionNote': return this.setTransactionNote(ctx, request as $2.SetTransactionNoteRequest);
      case 'GetFireplaceStats': return this.getFireplaceStats(ctx, request as $1.Empty);
      case 'ListRecentTransactions': return this.listRecentTransactions(ctx, request as $2.ListRecentTransactionsRequest);
      case 'ListBlocks': return this.listBlocks(ctx, request as $2.ListBlocksRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => BitwindowdServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => BitwindowdServiceBase$messageJson;
}

