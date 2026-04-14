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

import 'm4.pb.dart' as $7;
import 'm4.pbjson.dart';

export 'm4.pb.dart';

abstract class M4ServiceBase extends $pb.GeneratedService {
  $async.Future<$7.GetM4HistoryResponse> getM4History($pb.ServerContext ctx, $7.GetM4HistoryRequest request);
  $async.Future<$7.GetVotePreferencesResponse> getVotePreferences($pb.ServerContext ctx, $7.GetVotePreferencesRequest request);
  $async.Future<$7.SetVotePreferenceResponse> setVotePreference($pb.ServerContext ctx, $7.SetVotePreferenceRequest request);
  $async.Future<$7.GenerateM4BytesResponse> generateM4Bytes($pb.ServerContext ctx, $7.GenerateM4BytesRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetM4History': return $7.GetM4HistoryRequest();
      case 'GetVotePreferences': return $7.GetVotePreferencesRequest();
      case 'SetVotePreference': return $7.SetVotePreferenceRequest();
      case 'GenerateM4Bytes': return $7.GenerateM4BytesRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetM4History': return this.getM4History(ctx, request as $7.GetM4HistoryRequest);
      case 'GetVotePreferences': return this.getVotePreferences(ctx, request as $7.GetVotePreferencesRequest);
      case 'SetVotePreference': return this.setVotePreference(ctx, request as $7.SetVotePreferenceRequest);
      case 'GenerateM4Bytes': return this.generateM4Bytes(ctx, request as $7.GenerateM4BytesRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => M4ServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => M4ServiceBase$messageJson;
}

