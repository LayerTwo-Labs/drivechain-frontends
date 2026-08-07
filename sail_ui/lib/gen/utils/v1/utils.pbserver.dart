//
//  Generated code. Do not modify.
//  source: utils/v1/utils.proto
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
import 'utils.pb.dart' as $12;
import 'utils.pbjson.dart';

export 'utils.pb.dart';

abstract class UtilsServiceBase extends $pb.GeneratedService {
  $async.Future<$12.ParseBitcoinURIResponse> parseBitcoinURI($pb.ServerContext ctx, $12.ParseBitcoinURIRequest request);
  $async.Future<$12.ValidateBitcoinURIResponse> validateBitcoinURI(
      $pb.ServerContext ctx, $12.ValidateBitcoinURIRequest request);
  $async.Future<$12.DecodeBase58CheckResponse> decodeBase58Check(
      $pb.ServerContext ctx, $12.DecodeBase58CheckRequest request);
  $async.Future<$12.EncodeBase58CheckResponse> encodeBase58Check(
      $pb.ServerContext ctx, $12.EncodeBase58CheckRequest request);
  $async.Future<$12.CalculateMerkleTreeResponse> calculateMerkleTree(
      $pb.ServerContext ctx, $12.CalculateMerkleTreeRequest request);
  $async.Future<$12.GeneratePaperWalletResponse> generatePaperWallet($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$12.ValidateWIFResponse> validateWIF($pb.ServerContext ctx, $12.ValidateWIFRequest request);
  $async.Future<$12.WIFToAddressResponse> wIFToAddress($pb.ServerContext ctx, $12.WIFToAddressRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'ParseBitcoinURI':
        return $12.ParseBitcoinURIRequest();
      case 'ValidateBitcoinURI':
        return $12.ValidateBitcoinURIRequest();
      case 'DecodeBase58Check':
        return $12.DecodeBase58CheckRequest();
      case 'EncodeBase58Check':
        return $12.EncodeBase58CheckRequest();
      case 'CalculateMerkleTree':
        return $12.CalculateMerkleTreeRequest();
      case 'GeneratePaperWallet':
        return $1.Empty();
      case 'ValidateWIF':
        return $12.ValidateWIFRequest();
      case 'WIFToAddress':
        return $12.WIFToAddressRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall(
      $pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'ParseBitcoinURI':
        return this.parseBitcoinURI(ctx, request as $12.ParseBitcoinURIRequest);
      case 'ValidateBitcoinURI':
        return this.validateBitcoinURI(ctx, request as $12.ValidateBitcoinURIRequest);
      case 'DecodeBase58Check':
        return this.decodeBase58Check(ctx, request as $12.DecodeBase58CheckRequest);
      case 'EncodeBase58Check':
        return this.encodeBase58Check(ctx, request as $12.EncodeBase58CheckRequest);
      case 'CalculateMerkleTree':
        return this.calculateMerkleTree(ctx, request as $12.CalculateMerkleTreeRequest);
      case 'GeneratePaperWallet':
        return this.generatePaperWallet(ctx, request as $1.Empty);
      case 'ValidateWIF':
        return this.validateWIF(ctx, request as $12.ValidateWIFRequest);
      case 'WIFToAddress':
        return this.wIFToAddress(ctx, request as $12.WIFToAddressRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => UtilsServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => UtilsServiceBase$messageJson;
}
