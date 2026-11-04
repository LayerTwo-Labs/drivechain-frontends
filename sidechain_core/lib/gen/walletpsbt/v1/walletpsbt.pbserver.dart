// This is a generated file - do not edit.
//
// Generated from walletpsbt/v1/walletpsbt.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart' as $0;

import 'walletpsbt.pb.dart' as $1;
import 'walletpsbt.pbjson.dart';

export 'walletpsbt.pb.dart';

abstract class WalletPsbtServiceBase extends $pb.GeneratedService {
  $async.Future<$1.ListDraftsResponse> listDrafts($pb.ServerContext ctx, $1.ListDraftsRequest request);
  $async.Future<$1.SaveDraftResponse> saveDraft($pb.ServerContext ctx, $1.SaveDraftRequest request);
  $async.Future<$0.Empty> deleteDraft($pb.ServerContext ctx, $1.DeleteDraftRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'ListDrafts':
        return $1.ListDraftsRequest();
      case 'SaveDraft':
        return $1.SaveDraftRequest();
      case 'DeleteDraft':
        return $1.DeleteDraftRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall(
      $pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'ListDrafts':
        return listDrafts(ctx, request as $1.ListDraftsRequest);
      case 'SaveDraft':
        return saveDraft(ctx, request as $1.SaveDraftRequest);
      case 'DeleteDraft':
        return deleteDraft(ctx, request as $1.DeleteDraftRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => WalletPsbtServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => WalletPsbtServiceBase$messageJson;
}
