//
//  Generated code. Do not modify.
//  source: misc/v1/misc.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import '../../google/protobuf/empty.pb.dart' as $1;
import 'misc.pb.dart' as $3;

export 'misc.pb.dart';

@$pb.GrpcServiceName('misc.v1.MiscService')
class MiscServiceClient extends $grpc.Client {
  static final _$listOPReturn = $grpc.ClientMethod<$1.Empty, $3.ListOPReturnResponse>(
      '/misc.v1.MiscService/ListOPReturn',
      ($1.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $3.ListOPReturnResponse.fromBuffer(value));

  MiscServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$3.ListOPReturnResponse> listOPReturn($1.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listOPReturn, request, options: options);
  }
}

@$pb.GrpcServiceName('misc.v1.MiscService')
abstract class MiscServiceBase extends $grpc.Service {
  $core.String get $name => 'misc.v1.MiscService';

  MiscServiceBase() {
    $addMethod($grpc.ServiceMethod<$1.Empty, $3.ListOPReturnResponse>(
        'ListOPReturn',
        listOPReturn_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($3.ListOPReturnResponse value) => value.writeToBuffer()));
  }

  $async.Future<$3.ListOPReturnResponse> listOPReturn_Pre($grpc.ServiceCall call, $async.Future<$1.Empty> request) async {
    return listOPReturn(call, await request);
  }

  $async.Future<$3.ListOPReturnResponse> listOPReturn($grpc.ServiceCall call, $1.Empty request);
}
