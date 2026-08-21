//
//  Generated code. Do not modify.
//  source: walletpsbt/v1/walletpsbt.proto
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
import 'walletpsbt.pb.dart' as $14;
import 'walletpsbt.pbjson.dart';

export 'walletpsbt.pb.dart';

abstract class WalletPsbtServiceBase extends $pb.GeneratedService {
  $async.Future<$14.ListDraftsResponse> listDrafts($pb.ServerContext ctx, $14.ListDraftsRequest request);
  $async.Future<$14.SaveDraftResponse> saveDraft($pb.ServerContext ctx, $14.SaveDraftRequest request);
  $async.Future<$1.Empty> deleteDraft($pb.ServerContext ctx, $14.DeleteDraftRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'ListDrafts': return $14.ListDraftsRequest();
      case 'SaveDraft': return $14.SaveDraftRequest();
      case 'DeleteDraft': return $14.DeleteDraftRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'ListDrafts': return this.listDrafts(ctx, request as $14.ListDraftsRequest);
      case 'SaveDraft': return this.saveDraft(ctx, request as $14.SaveDraftRequest);
      case 'DeleteDraft': return this.deleteDraft(ctx, request as $14.DeleteDraftRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => WalletPsbtServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => WalletPsbtServiceBase$messageJson;
}

