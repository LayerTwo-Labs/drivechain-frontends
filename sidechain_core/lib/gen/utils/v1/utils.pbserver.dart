// This is a generated file - do not edit.
//
// Generated from utils/v1/utils.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart' as $0;

import 'utils.pb.dart' as $1;
import 'utils.pbjson.dart';

export 'utils.pb.dart';

abstract class UtilsServiceBase extends $pb.GeneratedService {
  $async.Future<$1.ParseBitcoinURIResponse> parseBitcoinURI($pb.ServerContext ctx, $1.ParseBitcoinURIRequest request);
  $async.Future<$1.ValidateBitcoinURIResponse> validateBitcoinURI(
      $pb.ServerContext ctx, $1.ValidateBitcoinURIRequest request);
  $async.Future<$1.DecodeBase58CheckResponse> decodeBase58Check(
      $pb.ServerContext ctx, $1.DecodeBase58CheckRequest request);
  $async.Future<$1.EncodeBase58CheckResponse> encodeBase58Check(
      $pb.ServerContext ctx, $1.EncodeBase58CheckRequest request);
  $async.Future<$1.CalculateMerkleTreeResponse> calculateMerkleTree(
      $pb.ServerContext ctx, $1.CalculateMerkleTreeRequest request);
  $async.Future<$1.GeneratePaperWalletResponse> generatePaperWallet($pb.ServerContext ctx, $0.Empty request);
  $async.Future<$1.ValidateWIFResponse> validateWIF($pb.ServerContext ctx, $1.ValidateWIFRequest request);
  $async.Future<$1.WIFToAddressResponse> wIFToAddress($pb.ServerContext ctx, $1.WIFToAddressRequest request);
  $async.Future<$1.CreatePaperWalletPdfResponse> createPaperWalletPdf(
      $pb.ServerContext ctx, $1.CreatePaperWalletPdfRequest request);
  $async.Future<$1.CreatePaperCheckPdfResponse> createPaperCheckPdf(
      $pb.ServerContext ctx, $1.CreatePaperCheckPdfRequest request);
  $async.Future<$1.ConvertResponse> convert($pb.ServerContext ctx, $1.ConvertRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'ParseBitcoinURI':
        return $1.ParseBitcoinURIRequest();
      case 'ValidateBitcoinURI':
        return $1.ValidateBitcoinURIRequest();
      case 'DecodeBase58Check':
        return $1.DecodeBase58CheckRequest();
      case 'EncodeBase58Check':
        return $1.EncodeBase58CheckRequest();
      case 'CalculateMerkleTree':
        return $1.CalculateMerkleTreeRequest();
      case 'GeneratePaperWallet':
        return $0.Empty();
      case 'ValidateWIF':
        return $1.ValidateWIFRequest();
      case 'WIFToAddress':
        return $1.WIFToAddressRequest();
      case 'CreatePaperWalletPdf':
        return $1.CreatePaperWalletPdfRequest();
      case 'CreatePaperCheckPdf':
        return $1.CreatePaperCheckPdfRequest();
      case 'Convert':
        return $1.ConvertRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall(
      $pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'ParseBitcoinURI':
        return parseBitcoinURI(ctx, request as $1.ParseBitcoinURIRequest);
      case 'ValidateBitcoinURI':
        return validateBitcoinURI(ctx, request as $1.ValidateBitcoinURIRequest);
      case 'DecodeBase58Check':
        return decodeBase58Check(ctx, request as $1.DecodeBase58CheckRequest);
      case 'EncodeBase58Check':
        return encodeBase58Check(ctx, request as $1.EncodeBase58CheckRequest);
      case 'CalculateMerkleTree':
        return calculateMerkleTree(ctx, request as $1.CalculateMerkleTreeRequest);
      case 'GeneratePaperWallet':
        return generatePaperWallet(ctx, request as $0.Empty);
      case 'ValidateWIF':
        return validateWIF(ctx, request as $1.ValidateWIFRequest);
      case 'WIFToAddress':
        return wIFToAddress(ctx, request as $1.WIFToAddressRequest);
      case 'CreatePaperWalletPdf':
        return createPaperWalletPdf(ctx, request as $1.CreatePaperWalletPdfRequest);
      case 'CreatePaperCheckPdf':
        return createPaperCheckPdf(ctx, request as $1.CreatePaperCheckPdfRequest);
      case 'Convert':
        return convert(ctx, request as $1.ConvertRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => UtilsServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => UtilsServiceBase$messageJson;
}
