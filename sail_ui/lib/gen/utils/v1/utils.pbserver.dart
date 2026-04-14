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
import 'utils.pb.dart' as $11;
import 'utils.pbjson.dart';

export 'utils.pb.dart';

abstract class UtilsServiceBase extends $pb.GeneratedService {
  $async.Future<$11.ParseBitcoinURIResponse> parseBitcoinURI($pb.ServerContext ctx, $11.ParseBitcoinURIRequest request);
  $async.Future<$11.ValidateBitcoinURIResponse> validateBitcoinURI($pb.ServerContext ctx, $11.ValidateBitcoinURIRequest request);
  $async.Future<$11.DecodeBase58CheckResponse> decodeBase58Check($pb.ServerContext ctx, $11.DecodeBase58CheckRequest request);
  $async.Future<$11.EncodeBase58CheckResponse> encodeBase58Check($pb.ServerContext ctx, $11.EncodeBase58CheckRequest request);
  $async.Future<$11.CalculateMerkleTreeResponse> calculateMerkleTree($pb.ServerContext ctx, $11.CalculateMerkleTreeRequest request);
  $async.Future<$11.GeneratePaperWalletResponse> generatePaperWallet($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$11.ValidateWIFResponse> validateWIF($pb.ServerContext ctx, $11.ValidateWIFRequest request);
  $async.Future<$11.WIFToAddressResponse> wIFToAddress($pb.ServerContext ctx, $11.WIFToAddressRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'ParseBitcoinURI': return $11.ParseBitcoinURIRequest();
      case 'ValidateBitcoinURI': return $11.ValidateBitcoinURIRequest();
      case 'DecodeBase58Check': return $11.DecodeBase58CheckRequest();
      case 'EncodeBase58Check': return $11.EncodeBase58CheckRequest();
      case 'CalculateMerkleTree': return $11.CalculateMerkleTreeRequest();
      case 'GeneratePaperWallet': return $1.Empty();
      case 'ValidateWIF': return $11.ValidateWIFRequest();
      case 'WIFToAddress': return $11.WIFToAddressRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'ParseBitcoinURI': return this.parseBitcoinURI(ctx, request as $11.ParseBitcoinURIRequest);
      case 'ValidateBitcoinURI': return this.validateBitcoinURI(ctx, request as $11.ValidateBitcoinURIRequest);
      case 'DecodeBase58Check': return this.decodeBase58Check(ctx, request as $11.DecodeBase58CheckRequest);
      case 'EncodeBase58Check': return this.encodeBase58Check(ctx, request as $11.EncodeBase58CheckRequest);
      case 'CalculateMerkleTree': return this.calculateMerkleTree(ctx, request as $11.CalculateMerkleTreeRequest);
      case 'GeneratePaperWallet': return this.generatePaperWallet(ctx, request as $1.Empty);
      case 'ValidateWIF': return this.validateWIF(ctx, request as $11.ValidateWIFRequest);
      case 'WIFToAddress': return this.wIFToAddress(ctx, request as $11.WIFToAddressRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => UtilsServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => UtilsServiceBase$messageJson;
}

