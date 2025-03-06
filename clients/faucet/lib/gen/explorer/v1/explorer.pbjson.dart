//
//  Generated code. Do not modify.
//  source: explorer/v1/explorer.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

import '../../google/protobuf/timestamp.pbjson.dart' as $0;

@$core.Deprecated('Use getChainTipsRequestDescriptor instead')
const GetChainTipsRequest$json = {
  '1': 'GetChainTipsRequest',
};

/// Descriptor for `GetChainTipsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getChainTipsRequestDescriptor = $convert.base64Decode(
    'ChNHZXRDaGFpblRpcHNSZXF1ZXN0');

@$core.Deprecated('Use chainTipDescriptor instead')
const ChainTip$json = {
  '1': 'ChainTip',
  '2': [
    {'1': 'hash', '3': 1, '4': 1, '5': 9, '10': 'hash'},
    {'1': 'height', '3': 2, '4': 1, '5': 4, '10': 'height'},
    {'1': 'timestamp', '3': 3, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'timestamp'},
  ],
};

/// Descriptor for `ChainTip`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chainTipDescriptor = $convert.base64Decode(
    'CghDaGFpblRpcBISCgRoYXNoGAEgASgJUgRoYXNoEhYKBmhlaWdodBgCIAEoBFIGaGVpZ2h0Ej'
    'gKCXRpbWVzdGFtcBgDIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXRpbWVzdGFt'
    'cA==');

@$core.Deprecated('Use getChainTipsResponseDescriptor instead')
const GetChainTipsResponse$json = {
  '1': 'GetChainTipsResponse',
  '2': [
    {'1': 'mainchain', '3': 1, '4': 1, '5': 11, '6': '.explorer.v1.ChainTip', '10': 'mainchain'},
    {'1': 'thunder', '3': 2, '4': 1, '5': 11, '6': '.explorer.v1.ChainTip', '10': 'thunder'},
    {'1': 'bitassets', '3': 3, '4': 1, '5': 11, '6': '.explorer.v1.ChainTip', '10': 'bitassets'},
    {'1': 'bitnames', '3': 4, '4': 1, '5': 11, '6': '.explorer.v1.ChainTip', '10': 'bitnames'},
  ],
};

/// Descriptor for `GetChainTipsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getChainTipsResponseDescriptor = $convert.base64Decode(
    'ChRHZXRDaGFpblRpcHNSZXNwb25zZRIzCgltYWluY2hhaW4YASABKAsyFS5leHBsb3Jlci52MS'
    '5DaGFpblRpcFIJbWFpbmNoYWluEi8KB3RodW5kZXIYAiABKAsyFS5leHBsb3Jlci52MS5DaGFp'
    'blRpcFIHdGh1bmRlchIzCgliaXRhc3NldHMYAyABKAsyFS5leHBsb3Jlci52MS5DaGFpblRpcF'
    'IJYml0YXNzZXRzEjEKCGJpdG5hbWVzGAQgASgLMhUuZXhwbG9yZXIudjEuQ2hhaW5UaXBSCGJp'
    'dG5hbWVz');

const $core.Map<$core.String, $core.dynamic> ExplorerServiceBase$json = {
  '1': 'ExplorerService',
  '2': [
    {'1': 'GetChainTips', '2': '.explorer.v1.GetChainTipsRequest', '3': '.explorer.v1.GetChainTipsResponse', '4': {}},
  ],
};

@$core.Deprecated('Use explorerServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> ExplorerServiceBase$messageJson = {
  '.explorer.v1.GetChainTipsRequest': GetChainTipsRequest$json,
  '.explorer.v1.GetChainTipsResponse': GetChainTipsResponse$json,
  '.explorer.v1.ChainTip': ChainTip$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
};

/// Descriptor for `ExplorerService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List explorerServiceDescriptor = $convert.base64Decode(
    'Cg9FeHBsb3JlclNlcnZpY2USVQoMR2V0Q2hhaW5UaXBzEiAuZXhwbG9yZXIudjEuR2V0Q2hhaW'
    '5UaXBzUmVxdWVzdBohLmV4cGxvcmVyLnYxLkdldENoYWluVGlwc1Jlc3BvbnNlIgA=');

