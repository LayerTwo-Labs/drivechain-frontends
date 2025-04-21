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
import 'bitwindowd.pb.dart' as $3;
import 'bitwindowd.pbjson.dart';

export 'bitwindowd.pb.dart';

abstract class BitwindowdServiceBase extends $pb.GeneratedService {
  $async.Future<$1.Empty> stop($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$1.Empty> createDenial($pb.ServerContext ctx, $3.CreateDenialRequest request);
  $async.Future<$3.ListDenialsResponse> listDenials($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$1.Empty> cancelDenial($pb.ServerContext ctx, $3.CancelDenialRequest request);
  $async.Future<$1.Empty> createAddressBookEntry($pb.ServerContext ctx, $3.CreateAddressBookEntryRequest request);
  $async.Future<$3.ListAddressBookResponse> listAddressBook($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$1.Empty> updateAddressBookEntry($pb.ServerContext ctx, $3.UpdateAddressBookEntryRequest request);
  $async.Future<$1.Empty> deleteAddressBookEntry($pb.ServerContext ctx, $3.DeleteAddressBookEntryRequest request);
  $async.Future<$3.GetSyncInfoResponse> getSyncInfo($pb.ServerContext ctx, $1.Empty request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'Stop': return $1.Empty();
      case 'CreateDenial': return $3.CreateDenialRequest();
      case 'ListDenials': return $1.Empty();
      case 'CancelDenial': return $3.CancelDenialRequest();
      case 'CreateAddressBookEntry': return $3.CreateAddressBookEntryRequest();
      case 'ListAddressBook': return $1.Empty();
      case 'UpdateAddressBookEntry': return $3.UpdateAddressBookEntryRequest();
      case 'DeleteAddressBookEntry': return $3.DeleteAddressBookEntryRequest();
      case 'GetSyncInfo': return $1.Empty();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'Stop': return this.stop(ctx, request as $1.Empty);
      case 'CreateDenial': return this.createDenial(ctx, request as $3.CreateDenialRequest);
      case 'ListDenials': return this.listDenials(ctx, request as $1.Empty);
      case 'CancelDenial': return this.cancelDenial(ctx, request as $3.CancelDenialRequest);
      case 'CreateAddressBookEntry': return this.createAddressBookEntry(ctx, request as $3.CreateAddressBookEntryRequest);
      case 'ListAddressBook': return this.listAddressBook(ctx, request as $1.Empty);
      case 'UpdateAddressBookEntry': return this.updateAddressBookEntry(ctx, request as $3.UpdateAddressBookEntryRequest);
      case 'DeleteAddressBookEntry': return this.deleteAddressBookEntry(ctx, request as $3.DeleteAddressBookEntryRequest);
      case 'GetSyncInfo': return this.getSyncInfo(ctx, request as $1.Empty);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => BitwindowdServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => BitwindowdServiceBase$messageJson;
}

