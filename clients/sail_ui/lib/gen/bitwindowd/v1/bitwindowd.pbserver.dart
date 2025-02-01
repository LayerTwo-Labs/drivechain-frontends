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
  $async.Future<$3.CreateDenialResponse> createDenial($pb.ServerContext ctx, $3.CreateDenialRequest request);
  $async.Future<$3.ListDenialsResponse> listDenials($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$1.Empty> cancelDenial($pb.ServerContext ctx, $3.CancelDenialRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'Stop': return $1.Empty();
      case 'CreateDenial': return $3.CreateDenialRequest();
      case 'ListDenials': return $1.Empty();
      case 'CancelDenial': return $3.CancelDenialRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'Stop': return this.stop(ctx, request as $1.Empty);
      case 'CreateDenial': return this.createDenial(ctx, request as $3.CreateDenialRequest);
      case 'ListDenials': return this.listDenials(ctx, request as $1.Empty);
      case 'CancelDenial': return this.cancelDenial(ctx, request as $3.CancelDenialRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => BitwindowdServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => BitwindowdServiceBase$messageJson;
}

