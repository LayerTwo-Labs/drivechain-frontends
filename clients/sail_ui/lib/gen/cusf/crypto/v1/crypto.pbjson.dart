//
//  Generated code. Do not modify.
//  source: cusf/crypto/v1/crypto.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use hmacSha512RequestDescriptor instead')
const HmacSha512Request$json = {
  '1': 'HmacSha512Request',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 11, '6': '.cusf.common.v1.Hex', '10': 'key'},
    {'1': 'msg', '3': 2, '4': 1, '5': 11, '6': '.cusf.common.v1.Hex', '10': 'msg'},
  ],
};

/// Descriptor for `HmacSha512Request`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List hmacSha512RequestDescriptor = $convert.base64Decode(
    'ChFIbWFjU2hhNTEyUmVxdWVzdBIlCgNrZXkYASABKAsyEy5jdXNmLmNvbW1vbi52MS5IZXhSA2'
    'tleRIlCgNtc2cYAiABKAsyEy5jdXNmLmNvbW1vbi52MS5IZXhSA21zZw==');

@$core.Deprecated('Use hmacSha512ResponseDescriptor instead')
const HmacSha512Response$json = {
  '1': 'HmacSha512Response',
  '2': [
    {'1': 'hmac', '3': 1, '4': 1, '5': 11, '6': '.cusf.common.v1.Hex', '10': 'hmac'},
  ],
};

/// Descriptor for `HmacSha512Response`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List hmacSha512ResponseDescriptor = $convert.base64Decode(
    'ChJIbWFjU2hhNTEyUmVzcG9uc2USJwoEaG1hYxgBIAEoCzITLmN1c2YuY29tbW9uLnYxLkhleF'
    'IEaG1hYw==');

@$core.Deprecated('Use ripemd160RequestDescriptor instead')
const Ripemd160Request$json = {
  '1': 'Ripemd160Request',
  '2': [
    {'1': 'msg', '3': 1, '4': 1, '5': 11, '6': '.cusf.common.v1.Hex', '10': 'msg'},
  ],
};

/// Descriptor for `Ripemd160Request`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ripemd160RequestDescriptor = $convert.base64Decode(
    'ChBSaXBlbWQxNjBSZXF1ZXN0EiUKA21zZxgBIAEoCzITLmN1c2YuY29tbW9uLnYxLkhleFIDbX'
    'Nn');

@$core.Deprecated('Use ripemd160ResponseDescriptor instead')
const Ripemd160Response$json = {
  '1': 'Ripemd160Response',
  '2': [
    {'1': 'digest', '3': 1, '4': 1, '5': 11, '6': '.cusf.common.v1.Hex', '10': 'digest'},
  ],
};

/// Descriptor for `Ripemd160Response`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ripemd160ResponseDescriptor = $convert.base64Decode(
    'ChFSaXBlbWQxNjBSZXNwb25zZRIrCgZkaWdlc3QYASABKAsyEy5jdXNmLmNvbW1vbi52MS5IZX'
    'hSBmRpZ2VzdA==');

@$core.Deprecated('Use secp256k1SecretKeyToPublicKeyRequestDescriptor instead')
const Secp256k1SecretKeyToPublicKeyRequest$json = {
  '1': 'Secp256k1SecretKeyToPublicKeyRequest',
  '2': [
    {'1': 'secret_key', '3': 1, '4': 1, '5': 11, '6': '.cusf.common.v1.ConsensusHex', '10': 'secretKey'},
  ],
};

/// Descriptor for `Secp256k1SecretKeyToPublicKeyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List secp256k1SecretKeyToPublicKeyRequestDescriptor = $convert.base64Decode(
    'CiRTZWNwMjU2azFTZWNyZXRLZXlUb1B1YmxpY0tleVJlcXVlc3QSOwoKc2VjcmV0X2tleRgBIA'
    'EoCzIcLmN1c2YuY29tbW9uLnYxLkNvbnNlbnN1c0hleFIJc2VjcmV0S2V5');

@$core.Deprecated('Use secp256k1SecretKeyToPublicKeyResponseDescriptor instead')
const Secp256k1SecretKeyToPublicKeyResponse$json = {
  '1': 'Secp256k1SecretKeyToPublicKeyResponse',
  '2': [
    {'1': 'public_key', '3': 1, '4': 1, '5': 11, '6': '.cusf.common.v1.ConsensusHex', '10': 'publicKey'},
  ],
};

/// Descriptor for `Secp256k1SecretKeyToPublicKeyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List secp256k1SecretKeyToPublicKeyResponseDescriptor = $convert.base64Decode(
    'CiVTZWNwMjU2azFTZWNyZXRLZXlUb1B1YmxpY0tleVJlc3BvbnNlEjsKCnB1YmxpY19rZXkYAS'
    'ABKAsyHC5jdXNmLmNvbW1vbi52MS5Db25zZW5zdXNIZXhSCXB1YmxpY0tleQ==');

@$core.Deprecated('Use secp256k1SignRequestDescriptor instead')
const Secp256k1SignRequest$json = {
  '1': 'Secp256k1SignRequest',
  '2': [
    {'1': 'message', '3': 1, '4': 1, '5': 11, '6': '.cusf.common.v1.Hex', '10': 'message'},
    {'1': 'secret_key', '3': 2, '4': 1, '5': 11, '6': '.cusf.common.v1.ConsensusHex', '10': 'secretKey'},
  ],
};

/// Descriptor for `Secp256k1SignRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List secp256k1SignRequestDescriptor = $convert.base64Decode(
    'ChRTZWNwMjU2azFTaWduUmVxdWVzdBItCgdtZXNzYWdlGAEgASgLMhMuY3VzZi5jb21tb24udj'
    'EuSGV4UgdtZXNzYWdlEjsKCnNlY3JldF9rZXkYAiABKAsyHC5jdXNmLmNvbW1vbi52MS5Db25z'
    'ZW5zdXNIZXhSCXNlY3JldEtleQ==');

@$core.Deprecated('Use secp256k1SignResponseDescriptor instead')
const Secp256k1SignResponse$json = {
  '1': 'Secp256k1SignResponse',
  '2': [
    {'1': 'signature', '3': 1, '4': 1, '5': 11, '6': '.cusf.common.v1.Hex', '10': 'signature'},
  ],
};

/// Descriptor for `Secp256k1SignResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List secp256k1SignResponseDescriptor = $convert.base64Decode(
    'ChVTZWNwMjU2azFTaWduUmVzcG9uc2USMQoJc2lnbmF0dXJlGAEgASgLMhMuY3VzZi5jb21tb2'
    '4udjEuSGV4UglzaWduYXR1cmU=');

@$core.Deprecated('Use secp256k1VerifyRequestDescriptor instead')
const Secp256k1VerifyRequest$json = {
  '1': 'Secp256k1VerifyRequest',
  '2': [
    {'1': 'message', '3': 1, '4': 1, '5': 11, '6': '.cusf.common.v1.Hex', '10': 'message'},
    {'1': 'signature', '3': 2, '4': 1, '5': 11, '6': '.cusf.common.v1.Hex', '10': 'signature'},
    {'1': 'public_key', '3': 3, '4': 1, '5': 11, '6': '.cusf.common.v1.ConsensusHex', '10': 'publicKey'},
  ],
};

/// Descriptor for `Secp256k1VerifyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List secp256k1VerifyRequestDescriptor = $convert.base64Decode(
    'ChZTZWNwMjU2azFWZXJpZnlSZXF1ZXN0Ei0KB21lc3NhZ2UYASABKAsyEy5jdXNmLmNvbW1vbi'
    '52MS5IZXhSB21lc3NhZ2USMQoJc2lnbmF0dXJlGAIgASgLMhMuY3VzZi5jb21tb24udjEuSGV4'
    'UglzaWduYXR1cmUSOwoKcHVibGljX2tleRgDIAEoCzIcLmN1c2YuY29tbW9uLnYxLkNvbnNlbn'
    'N1c0hleFIJcHVibGljS2V5');

@$core.Deprecated('Use secp256k1VerifyResponseDescriptor instead')
const Secp256k1VerifyResponse$json = {
  '1': 'Secp256k1VerifyResponse',
  '2': [
    {'1': 'valid', '3': 1, '4': 1, '5': 8, '10': 'valid'},
  ],
};

/// Descriptor for `Secp256k1VerifyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List secp256k1VerifyResponseDescriptor = $convert.base64Decode(
    'ChdTZWNwMjU2azFWZXJpZnlSZXNwb25zZRIUCgV2YWxpZBgBIAEoCFIFdmFsaWQ=');

