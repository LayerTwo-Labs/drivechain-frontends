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
import 'utils.pb.dart' as $9;
import 'utils.pbjson.dart';

export 'utils.pb.dart';

abstract class UtilsServiceBase extends $pb.GeneratedService {
  $async.Future<$9.ParseBitcoinURIResponse> parseBitcoinURI($pb.ServerContext ctx, $9.ParseBitcoinURIRequest request);
  $async.Future<$9.ValidateBitcoinURIResponse> validateBitcoinURI($pb.ServerContext ctx, $9.ValidateBitcoinURIRequest request);
  $async.Future<$9.DecodeBase58CheckResponse> decodeBase58Check($pb.ServerContext ctx, $9.DecodeBase58CheckRequest request);
  $async.Future<$9.EncodeBase58CheckResponse> encodeBase58Check($pb.ServerContext ctx, $9.EncodeBase58CheckRequest request);
  $async.Future<$9.CalculateMerkleTreeResponse> calculateMerkleTree($pb.ServerContext ctx, $9.CalculateMerkleTreeRequest request);
  $async.Future<$9.GeneratePaperWalletResponse> generatePaperWallet($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$9.ValidateWIFResponse> validateWIF($pb.ServerContext ctx, $9.ValidateWIFRequest request);
  $async.Future<$9.WIFToAddressResponse> wIFToAddress($pb.ServerContext ctx, $9.WIFToAddressRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'ParseBitcoinURI': return $9.ParseBitcoinURIRequest();
      case 'ValidateBitcoinURI': return $9.ValidateBitcoinURIRequest();
      case 'DecodeBase58Check': return $9.DecodeBase58CheckRequest();
      case 'EncodeBase58Check': return $9.EncodeBase58CheckRequest();
      case 'CalculateMerkleTree': return $9.CalculateMerkleTreeRequest();
      case 'GeneratePaperWallet': return $1.Empty();
      case 'ValidateWIF': return $9.ValidateWIFRequest();
      case 'WIFToAddress': return $9.WIFToAddressRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'ParseBitcoinURI': return this.parseBitcoinURI(ctx, request as $9.ParseBitcoinURIRequest);
      case 'ValidateBitcoinURI': return this.validateBitcoinURI(ctx, request as $9.ValidateBitcoinURIRequest);
      case 'DecodeBase58Check': return this.decodeBase58Check(ctx, request as $9.DecodeBase58CheckRequest);
      case 'EncodeBase58Check': return this.encodeBase58Check(ctx, request as $9.EncodeBase58CheckRequest);
      case 'CalculateMerkleTree': return this.calculateMerkleTree(ctx, request as $9.CalculateMerkleTreeRequest);
      case 'GeneratePaperWallet': return this.generatePaperWallet(ctx, request as $1.Empty);
      case 'ValidateWIF': return this.validateWIF(ctx, request as $9.ValidateWIFRequest);
      case 'WIFToAddress': return this.wIFToAddress(ctx, request as $9.WIFToAddressRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => UtilsServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => UtilsServiceBase$messageJson;
}

