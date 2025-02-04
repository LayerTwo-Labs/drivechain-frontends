//
//  Generated code. Do not modify.
//  source: cusf/crypto/v1/crypto.proto
//

import "package:connectrpc/connect.dart" as connect;
import "crypto.pb.dart" as cusfcryptov1crypto;

abstract final class CryptoService {
  /// Fully-qualified name of the CryptoService service.
  static const name = 'cusf.crypto.v1.CryptoService';

  static const hmacSha512 = connect.Spec(
    '/$name/HmacSha512',
    connect.StreamType.unary,
    cusfcryptov1crypto.HmacSha512Request.new,
    cusfcryptov1crypto.HmacSha512Response.new,
  );

  static const ripemd160 = connect.Spec(
    '/$name/Ripemd160',
    connect.StreamType.unary,
    cusfcryptov1crypto.Ripemd160Request.new,
    cusfcryptov1crypto.Ripemd160Response.new,
  );

  static const secp256k1SecretKeyToPublicKey = connect.Spec(
    '/$name/Secp256k1SecretKeyToPublicKey',
    connect.StreamType.unary,
    cusfcryptov1crypto.Secp256k1SecretKeyToPublicKeyRequest.new,
    cusfcryptov1crypto.Secp256k1SecretKeyToPublicKeyResponse.new,
  );

  static const secp256k1Sign = connect.Spec(
    '/$name/Secp256k1Sign',
    connect.StreamType.unary,
    cusfcryptov1crypto.Secp256k1SignRequest.new,
    cusfcryptov1crypto.Secp256k1SignResponse.new,
  );

  static const secp256k1Verify = connect.Spec(
    '/$name/Secp256k1Verify',
    connect.StreamType.unary,
    cusfcryptov1crypto.Secp256k1VerifyRequest.new,
    cusfcryptov1crypto.Secp256k1VerifyResponse.new,
  );
}
