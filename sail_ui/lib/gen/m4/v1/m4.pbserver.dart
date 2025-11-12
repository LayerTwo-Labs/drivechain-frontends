//
//  Generated code. Do not modify.
//  source: m4/v1/m4.proto
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

import 'm4.pb.dart' as $5;
import 'm4.pbjson.dart';

export 'm4.pb.dart';

abstract class M4ServiceBase extends $pb.GeneratedService {
  $async.Future<$5.GetM4HistoryResponse> getM4History($pb.ServerContext ctx, $5.GetM4HistoryRequest request);
  $async.Future<$5.GetVotePreferencesResponse> getVotePreferences($pb.ServerContext ctx, $5.GetVotePreferencesRequest request);
  $async.Future<$5.SetVotePreferenceResponse> setVotePreference($pb.ServerContext ctx, $5.SetVotePreferenceRequest request);
  $async.Future<$5.GenerateM4BytesResponse> generateM4Bytes($pb.ServerContext ctx, $5.GenerateM4BytesRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetM4History': return $5.GetM4HistoryRequest();
      case 'GetVotePreferences': return $5.GetVotePreferencesRequest();
      case 'SetVotePreference': return $5.SetVotePreferenceRequest();
      case 'GenerateM4Bytes': return $5.GenerateM4BytesRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetM4History': return this.getM4History(ctx, request as $5.GetM4HistoryRequest);
      case 'GetVotePreferences': return this.getVotePreferences(ctx, request as $5.GetVotePreferencesRequest);
      case 'SetVotePreference': return this.setVotePreference(ctx, request as $5.SetVotePreferenceRequest);
      case 'GenerateM4Bytes': return this.generateM4Bytes(ctx, request as $5.GenerateM4BytesRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => M4ServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => M4ServiceBase$messageJson;
}

