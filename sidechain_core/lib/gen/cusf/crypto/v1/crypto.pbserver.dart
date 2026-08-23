//
//  Generated code. Do not modify.
//  source: cusf/crypto/v1/crypto.proto
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

import 'crypto.pb.dart' as $2;
import 'crypto.pbjson.dart';

export 'crypto.pb.dart';

abstract class CryptoServiceBase extends $pb.GeneratedService {
  $async.Future<$2.HmacSha512Response> hmacSha512($pb.ServerContext ctx, $2.HmacSha512Request request);
  $async.Future<$2.Ripemd160Response> ripemd160($pb.ServerContext ctx, $2.Ripemd160Request request);
  $async.Future<$2.Secp256k1SecretKeyToPublicKeyResponse> secp256k1SecretKeyToPublicKey($pb.ServerContext ctx, $2.Secp256k1SecretKeyToPublicKeyRequest request);
  $async.Future<$2.Secp256k1SignResponse> secp256k1Sign($pb.ServerContext ctx, $2.Secp256k1SignRequest request);
  $async.Future<$2.Secp256k1VerifyResponse> secp256k1Verify($pb.ServerContext ctx, $2.Secp256k1VerifyRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'HmacSha512': return $2.HmacSha512Request();
      case 'Ripemd160': return $2.Ripemd160Request();
      case 'Secp256k1SecretKeyToPublicKey': return $2.Secp256k1SecretKeyToPublicKeyRequest();
      case 'Secp256k1Sign': return $2.Secp256k1SignRequest();
      case 'Secp256k1Verify': return $2.Secp256k1VerifyRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'HmacSha512': return this.hmacSha512(ctx, request as $2.HmacSha512Request);
      case 'Ripemd160': return this.ripemd160(ctx, request as $2.Ripemd160Request);
      case 'Secp256k1SecretKeyToPublicKey': return this.secp256k1SecretKeyToPublicKey(ctx, request as $2.Secp256k1SecretKeyToPublicKeyRequest);
      case 'Secp256k1Sign': return this.secp256k1Sign(ctx, request as $2.Secp256k1SignRequest);
      case 'Secp256k1Verify': return this.secp256k1Verify(ctx, request as $2.Secp256k1VerifyRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => CryptoServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => CryptoServiceBase$messageJson;
}

