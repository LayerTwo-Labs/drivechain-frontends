//
//  Generated code. Do not modify.
//  source: utils/v1/utils.proto
//

import "package:connectrpc/connect.dart" as connect;
import "utils.pb.dart" as utilsv1utils;
import "utils.connect.spec.dart" as specs;
import "../../google/protobuf/empty.pb.dart" as googleprotobufempty;

extension type UtilsServiceClient (connect.Transport _transport) {
  /// Bitcoin URI parsing (BIP-0021)
  Future<utilsv1utils.ParseBitcoinURIResponse> parseBitcoinURI(
    utilsv1utils.ParseBitcoinURIRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.UtilsService.parseBitcoinURI,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<utilsv1utils.ValidateBitcoinURIResponse> validateBitcoinURI(
    utilsv1utils.ValidateBitcoinURIRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.UtilsService.validateBitcoinURI,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Base58Check encoding/decoding
  Future<utilsv1utils.DecodeBase58CheckResponse> decodeBase58Check(
    utilsv1utils.DecodeBase58CheckRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.UtilsService.decodeBase58Check,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<utilsv1utils.EncodeBase58CheckResponse> encodeBase58Check(
    utilsv1utils.EncodeBase58CheckRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.UtilsService.encodeBase58Check,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Merkle Tree calculation
  Future<utilsv1utils.CalculateMerkleTreeResponse> calculateMerkleTree(
    utilsv1utils.CalculateMerkleTreeRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.UtilsService.calculateMerkleTree,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Paper Wallet generation
  Future<utilsv1utils.GeneratePaperWalletResponse> generatePaperWallet(
    googleprotobufempty.Empty input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.UtilsService.generatePaperWallet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<utilsv1utils.ValidateWIFResponse> validateWIF(
    utilsv1utils.ValidateWIFRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.UtilsService.validateWIF,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<utilsv1utils.WIFToAddressResponse> wIFToAddress(
    utilsv1utils.WIFToAddressRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.UtilsService.wIFToAddress,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
