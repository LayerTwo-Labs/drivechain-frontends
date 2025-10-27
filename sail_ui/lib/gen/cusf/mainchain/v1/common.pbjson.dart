//
//  Generated code. Do not modify.
//  source: cusf/mainchain/v1/common.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use outPointDescriptor instead')
const OutPoint$json = {
  '1': 'OutPoint',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 11, '6': '.cusf.common.v1.ReverseHex', '10': 'txid'},
    {'1': 'vout', '3': 2, '4': 1, '5': 11, '6': '.google.protobuf.UInt32Value', '10': 'vout'},
  ],
};

/// Descriptor for `OutPoint`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List outPointDescriptor = $convert.base64Decode(
    'CghPdXRQb2ludBIuCgR0eGlkGAEgASgLMhouY3VzZi5jb21tb24udjEuUmV2ZXJzZUhleFIEdH'
    'hpZBIwCgR2b3V0GAIgASgLMhwuZ29vZ2xlLnByb3RvYnVmLlVJbnQzMlZhbHVlUgR2b3V0');

@$core.Deprecated('Use sidechainDeclarationDescriptor instead')
const SidechainDeclaration$json = {
  '1': 'SidechainDeclaration',
  '2': [
    {'1': 'v0', '3': 1, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.SidechainDeclaration.V0', '9': 0, '10': 'v0'},
  ],
  '3': [SidechainDeclaration_V0$json],
  '8': [
    {'1': 'sidechain_declaration'},
  ],
};

@$core.Deprecated('Use sidechainDeclarationDescriptor instead')
const SidechainDeclaration_V0$json = {
  '1': 'V0',
  '2': [
    {'1': 'title', '3': 1, '4': 1, '5': 11, '6': '.google.protobuf.StringValue', '10': 'title'},
    {'1': 'description', '3': 2, '4': 1, '5': 11, '6': '.google.protobuf.StringValue', '10': 'description'},
    {'1': 'hash_id_1', '3': 3, '4': 1, '5': 11, '6': '.cusf.common.v1.ConsensusHex', '10': 'hashId1'},
    {'1': 'hash_id_2', '3': 4, '4': 1, '5': 11, '6': '.cusf.common.v1.Hex', '10': 'hashId2'},
  ],
};

/// Descriptor for `SidechainDeclaration`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sidechainDeclarationDescriptor = $convert.base64Decode(
    'ChRTaWRlY2hhaW5EZWNsYXJhdGlvbhI8CgJ2MBgBIAEoCzIqLmN1c2YubWFpbmNoYWluLnYxLl'
    'NpZGVjaGFpbkRlY2xhcmF0aW9uLlYwSABSAnYwGuMBCgJWMBIyCgV0aXRsZRgBIAEoCzIcLmdv'
    'b2dsZS5wcm90b2J1Zi5TdHJpbmdWYWx1ZVIFdGl0bGUSPgoLZGVzY3JpcHRpb24YAiABKAsyHC'
    '5nb29nbGUucHJvdG9idWYuU3RyaW5nVmFsdWVSC2Rlc2NyaXB0aW9uEjgKCWhhc2hfaWRfMRgD'
    'IAEoCzIcLmN1c2YuY29tbW9uLnYxLkNvbnNlbnN1c0hleFIHaGFzaElkMRIvCgloYXNoX2lkXz'
    'IYBCABKAsyEy5jdXNmLmNvbW1vbi52MS5IZXhSB2hhc2hJZDJCFwoVc2lkZWNoYWluX2RlY2xh'
    'cmF0aW9u');

