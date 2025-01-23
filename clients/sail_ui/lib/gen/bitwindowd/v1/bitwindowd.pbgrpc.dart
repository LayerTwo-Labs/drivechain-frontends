//
//  Generated code. Do not modify.
//  source: bitwindowd/v1/bitwindowd.proto
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

export 'bitwindowd.pb.dart';

@$pb.GrpcServiceName('bitwindowd.v1.BitwindowdService')
class BitwindowdServiceClient extends $grpc.Client {
  static final _$stop = $grpc.ClientMethod<$1.Empty, $1.Empty>(
      '/bitwindowd.v1.BitwindowdService/Stop',
      ($1.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $1.Empty.fromBuffer(value));

  BitwindowdServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$1.Empty> stop($1.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$stop, request, options: options);
  }
}

@$pb.GrpcServiceName('bitwindowd.v1.BitwindowdService')
abstract class BitwindowdServiceBase extends $grpc.Service {
  $core.String get $name => 'bitwindowd.v1.BitwindowdService';

  BitwindowdServiceBase() {
    $addMethod($grpc.ServiceMethod<$1.Empty, $1.Empty>(
        'Stop',
        stop_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
  }

  $async.Future<$1.Empty> stop_Pre($grpc.ServiceCall call, $async.Future<$1.Empty> request) async {
    return stop(call, await request);
  }

  $async.Future<$1.Empty> stop($grpc.ServiceCall call, $1.Empty request);
}
