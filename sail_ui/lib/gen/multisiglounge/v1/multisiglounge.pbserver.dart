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

import 'multisiglounge.pb.dart' as $3;
import 'multisiglounge.pbjson.dart';

export 'multisiglounge.pb.dart';

abstract class MultisigLoungeServiceBase extends $pb.GeneratedService {
  $async.Future<$3.BuildDescriptorsResponse> buildDescriptors($pb.ServerContext ctx, $3.BuildDescriptorsRequest request);
  $async.Future<$3.ValidatePsbtResponse> validatePsbt($pb.ServerContext ctx, $3.ValidatePsbtRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'BuildDescriptors': return $3.BuildDescriptorsRequest();
      case 'ValidatePsbt': return $3.ValidatePsbtRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'BuildDescriptors': return this.buildDescriptors(ctx, request as $3.BuildDescriptorsRequest);
      case 'ValidatePsbt': return this.validatePsbt(ctx, request as $3.ValidatePsbtRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => MultisigLoungeServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => MultisigLoungeServiceBase$messageJson;
}

