//
//  Generated code. Do not modify.
//  source: cusf/crypto/v1/crypto.proto
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

import 'crypto.pb.dart' as $0;

export 'crypto.pb.dart';

@$pb.GrpcServiceName('cusf.crypto.v1.CryptoService')
class CryptoServiceClient extends $grpc.Client {
  static final _$hmacSha512 = $grpc.ClientMethod<$0.HmacSha512Request, $0.HmacSha512Response>(
      '/cusf.crypto.v1.CryptoService/HmacSha512',
      ($0.HmacSha512Request value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.HmacSha512Response.fromBuffer(value));
  static final _$ripemd160 = $grpc.ClientMethod<$0.Ripemd160Request, $0.Ripemd160Response>(
      '/cusf.crypto.v1.CryptoService/Ripemd160',
      ($0.Ripemd160Request value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Ripemd160Response.fromBuffer(value));
  static final _$secp256k1SecretKeyToPublicKey = $grpc.ClientMethod<$0.Secp256k1SecretKeyToPublicKeyRequest, $0.Secp256k1SecretKeyToPublicKeyResponse>(
      '/cusf.crypto.v1.CryptoService/Secp256k1SecretKeyToPublicKey',
      ($0.Secp256k1SecretKeyToPublicKeyRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Secp256k1SecretKeyToPublicKeyResponse.fromBuffer(value));
  static final _$secp256k1Sign = $grpc.ClientMethod<$0.Secp256k1SignRequest, $0.Secp256k1SignResponse>(
      '/cusf.crypto.v1.CryptoService/Secp256k1Sign',
      ($0.Secp256k1SignRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Secp256k1SignResponse.fromBuffer(value));
  static final _$secp256k1Verify = $grpc.ClientMethod<$0.Secp256k1VerifyRequest, $0.Secp256k1VerifyResponse>(
      '/cusf.crypto.v1.CryptoService/Secp256k1Verify',
      ($0.Secp256k1VerifyRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Secp256k1VerifyResponse.fromBuffer(value));

  CryptoServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.HmacSha512Response> hmacSha512($0.HmacSha512Request request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$hmacSha512, request, options: options);
  }

  $grpc.ResponseFuture<$0.Ripemd160Response> ripemd160($0.Ripemd160Request request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$ripemd160, request, options: options);
  }

  $grpc.ResponseFuture<$0.Secp256k1SecretKeyToPublicKeyResponse> secp256k1SecretKeyToPublicKey($0.Secp256k1SecretKeyToPublicKeyRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$secp256k1SecretKeyToPublicKey, request, options: options);
  }

  $grpc.ResponseFuture<$0.Secp256k1SignResponse> secp256k1Sign($0.Secp256k1SignRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$secp256k1Sign, request, options: options);
  }

  $grpc.ResponseFuture<$0.Secp256k1VerifyResponse> secp256k1Verify($0.Secp256k1VerifyRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$secp256k1Verify, request, options: options);
  }
}

@$pb.GrpcServiceName('cusf.crypto.v1.CryptoService')
abstract class CryptoServiceBase extends $grpc.Service {
  $core.String get $name => 'cusf.crypto.v1.CryptoService';

  CryptoServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.HmacSha512Request, $0.HmacSha512Response>(
        'HmacSha512',
        hmacSha512_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.HmacSha512Request.fromBuffer(value),
        ($0.HmacSha512Response value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Ripemd160Request, $0.Ripemd160Response>(
        'Ripemd160',
        ripemd160_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Ripemd160Request.fromBuffer(value),
        ($0.Ripemd160Response value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Secp256k1SecretKeyToPublicKeyRequest, $0.Secp256k1SecretKeyToPublicKeyResponse>(
        'Secp256k1SecretKeyToPublicKey',
        secp256k1SecretKeyToPublicKey_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Secp256k1SecretKeyToPublicKeyRequest.fromBuffer(value),
        ($0.Secp256k1SecretKeyToPublicKeyResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Secp256k1SignRequest, $0.Secp256k1SignResponse>(
        'Secp256k1Sign',
        secp256k1Sign_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Secp256k1SignRequest.fromBuffer(value),
        ($0.Secp256k1SignResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Secp256k1VerifyRequest, $0.Secp256k1VerifyResponse>(
        'Secp256k1Verify',
        secp256k1Verify_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Secp256k1VerifyRequest.fromBuffer(value),
        ($0.Secp256k1VerifyResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.HmacSha512Response> hmacSha512_Pre($grpc.ServiceCall call, $async.Future<$0.HmacSha512Request> request) async {
    return hmacSha512(call, await request);
  }

  $async.Future<$0.Ripemd160Response> ripemd160_Pre($grpc.ServiceCall call, $async.Future<$0.Ripemd160Request> request) async {
    return ripemd160(call, await request);
  }

  $async.Future<$0.Secp256k1SecretKeyToPublicKeyResponse> secp256k1SecretKeyToPublicKey_Pre($grpc.ServiceCall call, $async.Future<$0.Secp256k1SecretKeyToPublicKeyRequest> request) async {
    return secp256k1SecretKeyToPublicKey(call, await request);
  }

  $async.Future<$0.Secp256k1SignResponse> secp256k1Sign_Pre($grpc.ServiceCall call, $async.Future<$0.Secp256k1SignRequest> request) async {
    return secp256k1Sign(call, await request);
  }

  $async.Future<$0.Secp256k1VerifyResponse> secp256k1Verify_Pre($grpc.ServiceCall call, $async.Future<$0.Secp256k1VerifyRequest> request) async {
    return secp256k1Verify(call, await request);
  }

  $async.Future<$0.HmacSha512Response> hmacSha512($grpc.ServiceCall call, $0.HmacSha512Request request);
  $async.Future<$0.Ripemd160Response> ripemd160($grpc.ServiceCall call, $0.Ripemd160Request request);
  $async.Future<$0.Secp256k1SecretKeyToPublicKeyResponse> secp256k1SecretKeyToPublicKey($grpc.ServiceCall call, $0.Secp256k1SecretKeyToPublicKeyRequest request);
  $async.Future<$0.Secp256k1SignResponse> secp256k1Sign($grpc.ServiceCall call, $0.Secp256k1SignRequest request);
  $async.Future<$0.Secp256k1VerifyResponse> secp256k1Verify($grpc.ServiceCall call, $0.Secp256k1VerifyRequest request);
}
