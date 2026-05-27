//
//  Generated code. Do not modify.
//  source: utils/v1/utils.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

import '../../google/protobuf/empty.pbjson.dart' as $1;

@$core.Deprecated('Use parseBitcoinURIRequestDescriptor instead')
const ParseBitcoinURIRequest$json = {
  '1': 'ParseBitcoinURIRequest',
  '2': [
    {'1': 'uri', '3': 1, '4': 1, '5': 9, '10': 'uri'},
  ],
};

/// Descriptor for `ParseBitcoinURIRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List parseBitcoinURIRequestDescriptor = $convert.base64Decode(
    'ChZQYXJzZUJpdGNvaW5VUklSZXF1ZXN0EhAKA3VyaRgBIAEoCVIDdXJp');

@$core.Deprecated('Use parseBitcoinURIResponseDescriptor instead')
const ParseBitcoinURIResponse$json = {
  '1': 'ParseBitcoinURIResponse',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'amount', '3': 2, '4': 1, '5': 1, '10': 'amount'},
    {'1': 'label', '3': 3, '4': 1, '5': 9, '10': 'label'},
    {'1': 'message', '3': 4, '4': 1, '5': 9, '10': 'message'},
    {'1': 'extra_params', '3': 5, '4': 3, '5': 11, '6': '.utils.v1.ParseBitcoinURIResponse.ExtraParamsEntry', '10': 'extraParams'},
  ],
  '3': [ParseBitcoinURIResponse_ExtraParamsEntry$json],
};

@$core.Deprecated('Use parseBitcoinURIResponseDescriptor instead')
const ParseBitcoinURIResponse_ExtraParamsEntry$json = {
  '1': 'ExtraParamsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `ParseBitcoinURIResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List parseBitcoinURIResponseDescriptor = $convert.base64Decode(
    'ChdQYXJzZUJpdGNvaW5VUklSZXNwb25zZRIYCgdhZGRyZXNzGAEgASgJUgdhZGRyZXNzEhYKBm'
    'Ftb3VudBgCIAEoAVIGYW1vdW50EhQKBWxhYmVsGAMgASgJUgVsYWJlbBIYCgdtZXNzYWdlGAQg'
    'ASgJUgdtZXNzYWdlElUKDGV4dHJhX3BhcmFtcxgFIAMoCzIyLnV0aWxzLnYxLlBhcnNlQml0Y2'
    '9pblVSSVJlc3BvbnNlLkV4dHJhUGFyYW1zRW50cnlSC2V4dHJhUGFyYW1zGj4KEEV4dHJhUGFy'
    'YW1zRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAiABKAlSBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use validateBitcoinURIRequestDescriptor instead')
const ValidateBitcoinURIRequest$json = {
  '1': 'ValidateBitcoinURIRequest',
  '2': [
    {'1': 'uri', '3': 1, '4': 1, '5': 9, '10': 'uri'},
  ],
};

/// Descriptor for `ValidateBitcoinURIRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List validateBitcoinURIRequestDescriptor = $convert.base64Decode(
    'ChlWYWxpZGF0ZUJpdGNvaW5VUklSZXF1ZXN0EhAKA3VyaRgBIAEoCVIDdXJp');

@$core.Deprecated('Use validateBitcoinURIResponseDescriptor instead')
const ValidateBitcoinURIResponse$json = {
  '1': 'ValidateBitcoinURIResponse',
  '2': [
    {'1': 'valid', '3': 1, '4': 1, '5': 8, '10': 'valid'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
  ],
};

/// Descriptor for `ValidateBitcoinURIResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List validateBitcoinURIResponseDescriptor = $convert.base64Decode(
    'ChpWYWxpZGF0ZUJpdGNvaW5VUklSZXNwb25zZRIUCgV2YWxpZBgBIAEoCFIFdmFsaWQSFAoFZX'
    'Jyb3IYAiABKAlSBWVycm9y');

@$core.Deprecated('Use decodeBase58CheckRequestDescriptor instead')
const DecodeBase58CheckRequest$json = {
  '1': 'DecodeBase58CheckRequest',
  '2': [
    {'1': 'input', '3': 1, '4': 1, '5': 9, '10': 'input'},
  ],
};

/// Descriptor for `DecodeBase58CheckRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List decodeBase58CheckRequestDescriptor = $convert.base64Decode(
    'ChhEZWNvZGVCYXNlNThDaGVja1JlcXVlc3QSFAoFaW5wdXQYASABKAlSBWlucHV0');

@$core.Deprecated('Use decodeBase58CheckResponseDescriptor instead')
const DecodeBase58CheckResponse$json = {
  '1': 'DecodeBase58CheckResponse',
  '2': [
    {'1': 'valid', '3': 1, '4': 1, '5': 8, '10': 'valid'},
    {'1': 'version_byte', '3': 2, '4': 1, '5': 5, '10': 'versionByte'},
    {'1': 'payload', '3': 3, '4': 1, '5': 12, '10': 'payload'},
    {'1': 'checksum', '3': 4, '4': 1, '5': 12, '10': 'checksum'},
    {'1': 'checksum_valid', '3': 5, '4': 1, '5': 8, '10': 'checksumValid'},
    {'1': 'address_type', '3': 6, '4': 1, '5': 9, '10': 'addressType'},
    {'1': 'error', '3': 7, '4': 1, '5': 9, '10': 'error'},
  ],
};

/// Descriptor for `DecodeBase58CheckResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List decodeBase58CheckResponseDescriptor = $convert.base64Decode(
    'ChlEZWNvZGVCYXNlNThDaGVja1Jlc3BvbnNlEhQKBXZhbGlkGAEgASgIUgV2YWxpZBIhCgx2ZX'
    'JzaW9uX2J5dGUYAiABKAVSC3ZlcnNpb25CeXRlEhgKB3BheWxvYWQYAyABKAxSB3BheWxvYWQS'
    'GgoIY2hlY2tzdW0YBCABKAxSCGNoZWNrc3VtEiUKDmNoZWNrc3VtX3ZhbGlkGAUgASgIUg1jaG'
    'Vja3N1bVZhbGlkEiEKDGFkZHJlc3NfdHlwZRgGIAEoCVILYWRkcmVzc1R5cGUSFAoFZXJyb3IY'
    'ByABKAlSBWVycm9y');

@$core.Deprecated('Use encodeBase58CheckRequestDescriptor instead')
const EncodeBase58CheckRequest$json = {
  '1': 'EncodeBase58CheckRequest',
  '2': [
    {'1': 'version_byte', '3': 1, '4': 1, '5': 5, '10': 'versionByte'},
    {'1': 'data', '3': 2, '4': 1, '5': 12, '10': 'data'},
  ],
};

/// Descriptor for `EncodeBase58CheckRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List encodeBase58CheckRequestDescriptor = $convert.base64Decode(
    'ChhFbmNvZGVCYXNlNThDaGVja1JlcXVlc3QSIQoMdmVyc2lvbl9ieXRlGAEgASgFUgt2ZXJzaW'
    '9uQnl0ZRISCgRkYXRhGAIgASgMUgRkYXRh');

@$core.Deprecated('Use encodeBase58CheckResponseDescriptor instead')
const EncodeBase58CheckResponse$json = {
  '1': 'EncodeBase58CheckResponse',
  '2': [
    {'1': 'encoded', '3': 1, '4': 1, '5': 9, '10': 'encoded'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
  ],
};

/// Descriptor for `EncodeBase58CheckResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List encodeBase58CheckResponseDescriptor = $convert.base64Decode(
    'ChlFbmNvZGVCYXNlNThDaGVja1Jlc3BvbnNlEhgKB2VuY29kZWQYASABKAlSB2VuY29kZWQSFA'
    'oFZXJyb3IYAiABKAlSBWVycm9y');

@$core.Deprecated('Use calculateMerkleTreeRequestDescriptor instead')
const CalculateMerkleTreeRequest$json = {
  '1': 'CalculateMerkleTreeRequest',
  '2': [
    {'1': 'txids', '3': 1, '4': 3, '5': 9, '10': 'txids'},
  ],
};

/// Descriptor for `CalculateMerkleTreeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List calculateMerkleTreeRequestDescriptor = $convert.base64Decode(
    'ChpDYWxjdWxhdGVNZXJrbGVUcmVlUmVxdWVzdBIUCgV0eGlkcxgBIAMoCVIFdHhpZHM=');

@$core.Deprecated('Use calculateMerkleTreeResponseDescriptor instead')
const CalculateMerkleTreeResponse$json = {
  '1': 'CalculateMerkleTreeResponse',
  '2': [
    {'1': 'merkle_root', '3': 1, '4': 1, '5': 9, '10': 'merkleRoot'},
    {'1': 'levels', '3': 2, '4': 3, '5': 11, '6': '.utils.v1.MerkleTreeLevel', '10': 'levels'},
    {'1': 'formatted_text', '3': 3, '4': 1, '5': 9, '10': 'formattedText'},
  ],
};

/// Descriptor for `CalculateMerkleTreeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List calculateMerkleTreeResponseDescriptor = $convert.base64Decode(
    'ChtDYWxjdWxhdGVNZXJrbGVUcmVlUmVzcG9uc2USHwoLbWVya2xlX3Jvb3QYASABKAlSCm1lcm'
    'tsZVJvb3QSMQoGbGV2ZWxzGAIgAygLMhkudXRpbHMudjEuTWVya2xlVHJlZUxldmVsUgZsZXZl'
    'bHMSJQoOZm9ybWF0dGVkX3RleHQYAyABKAlSDWZvcm1hdHRlZFRleHQ=');

@$core.Deprecated('Use merkleTreeLevelDescriptor instead')
const MerkleTreeLevel$json = {
  '1': 'MerkleTreeLevel',
  '2': [
    {'1': 'level', '3': 1, '4': 1, '5': 5, '10': 'level'},
    {'1': 'hashes', '3': 2, '4': 3, '5': 9, '10': 'hashes'},
    {'1': 'rcb', '3': 3, '4': 3, '5': 9, '10': 'rcb'},
  ],
};

/// Descriptor for `MerkleTreeLevel`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List merkleTreeLevelDescriptor = $convert.base64Decode(
    'Cg9NZXJrbGVUcmVlTGV2ZWwSFAoFbGV2ZWwYASABKAVSBWxldmVsEhYKBmhhc2hlcxgCIAMoCV'
    'IGaGFzaGVzEhAKA3JjYhgDIAMoCVIDcmNi');

@$core.Deprecated('Use generatePaperWalletResponseDescriptor instead')
const GeneratePaperWalletResponse$json = {
  '1': 'GeneratePaperWalletResponse',
  '2': [
    {'1': 'private_key_wif', '3': 1, '4': 1, '5': 9, '10': 'privateKeyWif'},
    {'1': 'public_address', '3': 2, '4': 1, '5': 9, '10': 'publicAddress'},
    {'1': 'private_key_hex', '3': 3, '4': 1, '5': 9, '10': 'privateKeyHex'},
  ],
};

/// Descriptor for `GeneratePaperWalletResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List generatePaperWalletResponseDescriptor = $convert.base64Decode(
    'ChtHZW5lcmF0ZVBhcGVyV2FsbGV0UmVzcG9uc2USJgoPcHJpdmF0ZV9rZXlfd2lmGAEgASgJUg'
    '1wcml2YXRlS2V5V2lmEiUKDnB1YmxpY19hZGRyZXNzGAIgASgJUg1wdWJsaWNBZGRyZXNzEiYK'
    'D3ByaXZhdGVfa2V5X2hleBgDIAEoCVINcHJpdmF0ZUtleUhleA==');

@$core.Deprecated('Use validateWIFRequestDescriptor instead')
const ValidateWIFRequest$json = {
  '1': 'ValidateWIFRequest',
  '2': [
    {'1': 'wif', '3': 1, '4': 1, '5': 9, '10': 'wif'},
  ],
};

/// Descriptor for `ValidateWIFRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List validateWIFRequestDescriptor = $convert.base64Decode(
    'ChJWYWxpZGF0ZVdJRlJlcXVlc3QSEAoDd2lmGAEgASgJUgN3aWY=');

@$core.Deprecated('Use validateWIFResponseDescriptor instead')
const ValidateWIFResponse$json = {
  '1': 'ValidateWIFResponse',
  '2': [
    {'1': 'valid', '3': 1, '4': 1, '5': 8, '10': 'valid'},
  ],
};

/// Descriptor for `ValidateWIFResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List validateWIFResponseDescriptor = $convert.base64Decode(
    'ChNWYWxpZGF0ZVdJRlJlc3BvbnNlEhQKBXZhbGlkGAEgASgIUgV2YWxpZA==');

@$core.Deprecated('Use wIFToAddressRequestDescriptor instead')
const WIFToAddressRequest$json = {
  '1': 'WIFToAddressRequest',
  '2': [
    {'1': 'wif', '3': 1, '4': 1, '5': 9, '10': 'wif'},
  ],
};

/// Descriptor for `WIFToAddressRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List wIFToAddressRequestDescriptor = $convert.base64Decode(
    'ChNXSUZUb0FkZHJlc3NSZXF1ZXN0EhAKA3dpZhgBIAEoCVIDd2lm');

@$core.Deprecated('Use wIFToAddressResponseDescriptor instead')
const WIFToAddressResponse$json = {
  '1': 'WIFToAddressResponse',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
  ],
};

/// Descriptor for `WIFToAddressResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List wIFToAddressResponseDescriptor = $convert.base64Decode(
    'ChRXSUZUb0FkZHJlc3NSZXNwb25zZRIYCgdhZGRyZXNzGAEgASgJUgdhZGRyZXNzEhQKBWVycm'
    '9yGAIgASgJUgVlcnJvcg==');

const $core.Map<$core.String, $core.dynamic> UtilsServiceBase$json = {
  '1': 'UtilsService',
  '2': [
    {'1': 'ParseBitcoinURI', '2': '.utils.v1.ParseBitcoinURIRequest', '3': '.utils.v1.ParseBitcoinURIResponse'},
    {'1': 'ValidateBitcoinURI', '2': '.utils.v1.ValidateBitcoinURIRequest', '3': '.utils.v1.ValidateBitcoinURIResponse'},
    {'1': 'DecodeBase58Check', '2': '.utils.v1.DecodeBase58CheckRequest', '3': '.utils.v1.DecodeBase58CheckResponse'},
    {'1': 'EncodeBase58Check', '2': '.utils.v1.EncodeBase58CheckRequest', '3': '.utils.v1.EncodeBase58CheckResponse'},
    {'1': 'CalculateMerkleTree', '2': '.utils.v1.CalculateMerkleTreeRequest', '3': '.utils.v1.CalculateMerkleTreeResponse'},
    {'1': 'GeneratePaperWallet', '2': '.google.protobuf.Empty', '3': '.utils.v1.GeneratePaperWalletResponse'},
    {'1': 'ValidateWIF', '2': '.utils.v1.ValidateWIFRequest', '3': '.utils.v1.ValidateWIFResponse'},
    {'1': 'WIFToAddress', '2': '.utils.v1.WIFToAddressRequest', '3': '.utils.v1.WIFToAddressResponse'},
  ],
};

@$core.Deprecated('Use utilsServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> UtilsServiceBase$messageJson = {
  '.utils.v1.ParseBitcoinURIRequest': ParseBitcoinURIRequest$json,
  '.utils.v1.ParseBitcoinURIResponse': ParseBitcoinURIResponse$json,
  '.utils.v1.ParseBitcoinURIResponse.ExtraParamsEntry': ParseBitcoinURIResponse_ExtraParamsEntry$json,
  '.utils.v1.ValidateBitcoinURIRequest': ValidateBitcoinURIRequest$json,
  '.utils.v1.ValidateBitcoinURIResponse': ValidateBitcoinURIResponse$json,
  '.utils.v1.DecodeBase58CheckRequest': DecodeBase58CheckRequest$json,
  '.utils.v1.DecodeBase58CheckResponse': DecodeBase58CheckResponse$json,
  '.utils.v1.EncodeBase58CheckRequest': EncodeBase58CheckRequest$json,
  '.utils.v1.EncodeBase58CheckResponse': EncodeBase58CheckResponse$json,
  '.utils.v1.CalculateMerkleTreeRequest': CalculateMerkleTreeRequest$json,
  '.utils.v1.CalculateMerkleTreeResponse': CalculateMerkleTreeResponse$json,
  '.utils.v1.MerkleTreeLevel': MerkleTreeLevel$json,
  '.google.protobuf.Empty': $1.Empty$json,
  '.utils.v1.GeneratePaperWalletResponse': GeneratePaperWalletResponse$json,
  '.utils.v1.ValidateWIFRequest': ValidateWIFRequest$json,
  '.utils.v1.ValidateWIFResponse': ValidateWIFResponse$json,
  '.utils.v1.WIFToAddressRequest': WIFToAddressRequest$json,
  '.utils.v1.WIFToAddressResponse': WIFToAddressResponse$json,
};

/// Descriptor for `UtilsService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List utilsServiceDescriptor = $convert.base64Decode(
    'CgxVdGlsc1NlcnZpY2USVgoPUGFyc2VCaXRjb2luVVJJEiAudXRpbHMudjEuUGFyc2VCaXRjb2'
    'luVVJJUmVxdWVzdBohLnV0aWxzLnYxLlBhcnNlQml0Y29pblVSSVJlc3BvbnNlEl8KElZhbGlk'
    'YXRlQml0Y29pblVSSRIjLnV0aWxzLnYxLlZhbGlkYXRlQml0Y29pblVSSVJlcXVlc3QaJC51dG'
    'lscy52MS5WYWxpZGF0ZUJpdGNvaW5VUklSZXNwb25zZRJcChFEZWNvZGVCYXNlNThDaGVjaxIi'
    'LnV0aWxzLnYxLkRlY29kZUJhc2U1OENoZWNrUmVxdWVzdBojLnV0aWxzLnYxLkRlY29kZUJhc2'
    'U1OENoZWNrUmVzcG9uc2USXAoRRW5jb2RlQmFzZTU4Q2hlY2sSIi51dGlscy52MS5FbmNvZGVC'
    'YXNlNThDaGVja1JlcXVlc3QaIy51dGlscy52MS5FbmNvZGVCYXNlNThDaGVja1Jlc3BvbnNlEm'
    'IKE0NhbGN1bGF0ZU1lcmtsZVRyZWUSJC51dGlscy52MS5DYWxjdWxhdGVNZXJrbGVUcmVlUmVx'
    'dWVzdBolLnV0aWxzLnYxLkNhbGN1bGF0ZU1lcmtsZVRyZWVSZXNwb25zZRJUChNHZW5lcmF0ZV'
    'BhcGVyV2FsbGV0EhYuZ29vZ2xlLnByb3RvYnVmLkVtcHR5GiUudXRpbHMudjEuR2VuZXJhdGVQ'
    'YXBlcldhbGxldFJlc3BvbnNlEkoKC1ZhbGlkYXRlV0lGEhwudXRpbHMudjEuVmFsaWRhdGVXSU'
    'ZSZXF1ZXN0Gh0udXRpbHMudjEuVmFsaWRhdGVXSUZSZXNwb25zZRJNCgxXSUZUb0FkZHJlc3MS'
    'HS51dGlscy52MS5XSUZUb0FkZHJlc3NSZXF1ZXN0Gh4udXRpbHMudjEuV0lGVG9BZGRyZXNzUm'
    'VzcG9uc2U=');

