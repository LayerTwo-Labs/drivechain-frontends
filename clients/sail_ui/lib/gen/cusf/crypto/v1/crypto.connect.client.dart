//
//  Generated code. Do not modify.
//  source: cusf/crypto/v1/crypto.proto
//

import "package:connectrpc/connect.dart" as connect;
import "crypto.pb.dart" as cusfcryptov1crypto;
import "crypto.connect.spec.dart" as specs;

extension type CryptoServiceClient (connect.Transport _transport) {
  Future<cusfcryptov1crypto.HmacSha512Response> hmacSha512(
    cusfcryptov1crypto.HmacSha512Request input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CryptoService.hmacSha512,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<cusfcryptov1crypto.Ripemd160Response> ripemd160(
    cusfcryptov1crypto.Ripemd160Request input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CryptoService.ripemd160,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<cusfcryptov1crypto.Secp256k1SecretKeyToPublicKeyResponse> secp256k1SecretKeyToPublicKey(
    cusfcryptov1crypto.Secp256k1SecretKeyToPublicKeyRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CryptoService.secp256k1SecretKeyToPublicKey,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<cusfcryptov1crypto.Secp256k1SignResponse> secp256k1Sign(
    cusfcryptov1crypto.Secp256k1SignRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CryptoService.secp256k1Sign,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<cusfcryptov1crypto.Secp256k1VerifyResponse> secp256k1Verify(
    cusfcryptov1crypto.Secp256k1VerifyRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CryptoService.secp256k1Verify,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
