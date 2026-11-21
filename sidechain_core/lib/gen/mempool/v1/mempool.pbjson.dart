// This is a generated file - do not edit.
//
// Generated from mempool/v1/mempool.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

import 'package:protobuf/well_known_types/google/protobuf/timestamp.pbjson.dart' as $0;

@$core.Deprecated('Use transactionDescriptor instead')
const Transaction$json = {
  '1': 'Transaction',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'fee_sats', '3': 2, '4': 1, '5': 4, '10': 'feeSats'},
    {'1': 'vsize', '3': 3, '4': 1, '5': 13, '10': 'vsize'},
    {'1': 'time', '3': 4, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'time'},
    {'1': 'ancestor_fee_sats', '3': 5, '4': 1, '5': 4, '10': 'ancestorFeeSats'},
    {'1': 'ancestor_vsize', '3': 6, '4': 1, '5': 13, '10': 'ancestorVsize'},
    {'1': 'height', '3': 7, '4': 1, '5': 13, '10': 'height'},
  ],
};

/// Descriptor for `Transaction`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transactionDescriptor =
    $convert.base64Decode('CgtUcmFuc2FjdGlvbhISCgR0eGlkGAEgASgJUgR0eGlkEhkKCGZlZV9zYXRzGAIgASgEUgdmZW'
        'VTYXRzEhQKBXZzaXplGAMgASgNUgV2c2l6ZRIuCgR0aW1lGAQgASgLMhouZ29vZ2xlLnByb3Rv'
        'YnVmLlRpbWVzdGFtcFIEdGltZRIqChFhbmNlc3Rvcl9mZWVfc2F0cxgFIAEoBFIPYW5jZXN0b3'
        'JGZWVTYXRzEiUKDmFuY2VzdG9yX3ZzaXplGAYgASgNUg1hbmNlc3RvclZzaXplEhYKBmhlaWdo'
        'dBgHIAEoDVIGaGVpZ2h0');

@$core.Deprecated('Use listTransactionsRequestDescriptor instead')
const ListTransactionsRequest$json = {
  '1': 'ListTransactionsRequest',
  '2': [
    {'1': 'count', '3': 1, '4': 1, '5': 13, '10': 'count'},
  ],
};

/// Descriptor for `ListTransactionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listTransactionsRequestDescriptor =
    $convert.base64Decode('ChdMaXN0VHJhbnNhY3Rpb25zUmVxdWVzdBIUCgVjb3VudBgBIAEoDVIFY291bnQ=');

@$core.Deprecated('Use listTransactionsResponseDescriptor instead')
const ListTransactionsResponse$json = {
  '1': 'ListTransactionsResponse',
  '2': [
    {'1': 'transactions', '3': 1, '4': 3, '5': 11, '6': '.mempool.v1.Transaction', '10': 'transactions'},
    {'1': 'total', '3': 2, '4': 1, '5': 4, '10': 'total'},
  ],
};

/// Descriptor for `ListTransactionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listTransactionsResponseDescriptor =
    $convert.base64Decode('ChhMaXN0VHJhbnNhY3Rpb25zUmVzcG9uc2USOwoMdHJhbnNhY3Rpb25zGAEgAygLMhcubWVtcG'
        '9vbC52MS5UcmFuc2FjdGlvblIMdHJhbnNhY3Rpb25zEhQKBXRvdGFsGAIgASgEUgV0b3RhbA==');

@$core.Deprecated('Use getStatsRequestDescriptor instead')
const GetStatsRequest$json = {
  '1': 'GetStatsRequest',
  '2': [
    {'1': 'bucket_edges', '3': 1, '4': 3, '5': 1, '10': 'bucketEdges'},
  ],
};

/// Descriptor for `GetStatsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getStatsRequestDescriptor =
    $convert.base64Decode('Cg9HZXRTdGF0c1JlcXVlc3QSIQoMYnVja2V0X2VkZ2VzGAEgAygBUgtidWNrZXRFZGdlcw==');

@$core.Deprecated('Use feeBucketDescriptor instead')
const FeeBucket$json = {
  '1': 'FeeBucket',
  '2': [
    {'1': 'min_fee_rate', '3': 1, '4': 1, '5': 1, '10': 'minFeeRate'},
    {'1': 'tx_count', '3': 2, '4': 1, '5': 4, '10': 'txCount'},
    {'1': 'vsize', '3': 3, '4': 1, '5': 4, '10': 'vsize'},
    {'1': 'fee_sats', '3': 4, '4': 1, '5': 4, '10': 'feeSats'},
  ],
};

/// Descriptor for `FeeBucket`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List feeBucketDescriptor =
    $convert.base64Decode('CglGZWVCdWNrZXQSIAoMbWluX2ZlZV9yYXRlGAEgASgBUgptaW5GZWVSYXRlEhkKCHR4X2NvdW'
        '50GAIgASgEUgd0eENvdW50EhQKBXZzaXplGAMgASgEUgV2c2l6ZRIZCghmZWVfc2F0cxgEIAEo'
        'BFIHZmVlU2F0cw==');

@$core.Deprecated('Use getStatsResponseDescriptor instead')
const GetStatsResponse$json = {
  '1': 'GetStatsResponse',
  '2': [
    {'1': 'tx_count', '3': 1, '4': 1, '5': 4, '10': 'txCount'},
    {'1': 'vsize', '3': 2, '4': 1, '5': 4, '10': 'vsize'},
    {'1': 'fee_sats', '3': 3, '4': 1, '5': 4, '10': 'feeSats'},
    {'1': 'median_fee_rate', '3': 4, '4': 1, '5': 1, '10': 'medianFeeRate'},
    {'1': 'buckets', '3': 5, '4': 3, '5': 11, '6': '.mempool.v1.FeeBucket', '10': 'buckets'},
  ],
};

/// Descriptor for `GetStatsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getStatsResponseDescriptor =
    $convert.base64Decode('ChBHZXRTdGF0c1Jlc3BvbnNlEhkKCHR4X2NvdW50GAEgASgEUgd0eENvdW50EhQKBXZzaXplGA'
        'IgASgEUgV2c2l6ZRIZCghmZWVfc2F0cxgDIAEoBFIHZmVlU2F0cxImCg9tZWRpYW5fZmVlX3Jh'
        'dGUYBCABKAFSDW1lZGlhbkZlZVJhdGUSLwoHYnVja2V0cxgFIAMoCzIVLm1lbXBvb2wudjEuRm'
        'VlQnVja2V0UgdidWNrZXRz');

@$core.Deprecated('Use watchTransactionsRequestDescriptor instead')
const WatchTransactionsRequest$json = {
  '1': 'WatchTransactionsRequest',
};

/// Descriptor for `WatchTransactionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List watchTransactionsRequestDescriptor =
    $convert.base64Decode('ChhXYXRjaFRyYW5zYWN0aW9uc1JlcXVlc3Q=');

@$core.Deprecated('Use watchTransactionsResponseDescriptor instead')
const WatchTransactionsResponse$json = {
  '1': 'WatchTransactionsResponse',
  '2': [
    {'1': 'snapshot', '3': 1, '4': 1, '5': 11, '6': '.mempool.v1.Snapshot', '10': 'snapshot'},
    {'1': 'changes', '3': 2, '4': 3, '5': 11, '6': '.mempool.v1.Change', '10': 'changes'},
    {'1': 'heartbeat', '3': 3, '4': 1, '5': 8, '10': 'heartbeat'},
  ],
};

/// Descriptor for `WatchTransactionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List watchTransactionsResponseDescriptor =
    $convert.base64Decode('ChlXYXRjaFRyYW5zYWN0aW9uc1Jlc3BvbnNlEjAKCHNuYXBzaG90GAEgASgLMhQubWVtcG9vbC'
        '52MS5TbmFwc2hvdFIIc25hcHNob3QSLAoHY2hhbmdlcxgCIAMoCzISLm1lbXBvb2wudjEuQ2hh'
        'bmdlUgdjaGFuZ2VzEhwKCWhlYXJ0YmVhdBgDIAEoCFIJaGVhcnRiZWF0');

@$core.Deprecated('Use snapshotDescriptor instead')
const Snapshot$json = {
  '1': 'Snapshot',
  '2': [
    {'1': 'height', '3': 1, '4': 1, '5': 13, '10': 'height'},
    {'1': 'transactions', '3': 2, '4': 3, '5': 11, '6': '.mempool.v1.Transaction', '10': 'transactions'},
    {'1': 'more', '3': 3, '4': 1, '5': 8, '10': 'more'},
  ],
};

/// Descriptor for `Snapshot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List snapshotDescriptor =
    $convert.base64Decode('CghTbmFwc2hvdBIWCgZoZWlnaHQYASABKA1SBmhlaWdodBI7Cgx0cmFuc2FjdGlvbnMYAiADKA'
        'syFy5tZW1wb29sLnYxLlRyYW5zYWN0aW9uUgx0cmFuc2FjdGlvbnMSEgoEbW9yZRgDIAEoCFIE'
        'bW9yZQ==');

@$core.Deprecated('Use changeDescriptor instead')
const Change$json = {
  '1': 'Change',
  '2': [
    {'1': 'added', '3': 1, '4': 1, '5': 11, '6': '.mempool.v1.Transaction', '9': 0, '10': 'added'},
    {'1': 'removed', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'removed'},
    {'1': 'block', '3': 3, '4': 1, '5': 11, '6': '.mempool.v1.Block', '9': 0, '10': 'block'},
  ],
  '8': [
    {'1': 'change'},
  ],
};

/// Descriptor for `Change`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List changeDescriptor =
    $convert.base64Decode('CgZDaGFuZ2USLwoFYWRkZWQYASABKAsyFy5tZW1wb29sLnYxLlRyYW5zYWN0aW9uSABSBWFkZG'
        'VkEhoKB3JlbW92ZWQYAiABKAlIAFIHcmVtb3ZlZBIpCgVibG9jaxgDIAEoCzIRLm1lbXBvb2wu'
        'djEuQmxvY2tIAFIFYmxvY2tCCAoGY2hhbmdl');

@$core.Deprecated('Use blockDescriptor instead')
const Block$json = {
  '1': 'Block',
  '2': [
    {'1': 'hash', '3': 1, '4': 1, '5': 9, '10': 'hash'},
    {'1': 'height', '3': 2, '4': 1, '5': 13, '10': 'height'},
    {'1': 'connected', '3': 3, '4': 1, '5': 8, '10': 'connected'},
    {'1': 'txids', '3': 4, '4': 3, '5': 9, '10': 'txids'},
  ],
};

/// Descriptor for `Block`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List blockDescriptor =
    $convert.base64Decode('CgVCbG9jaxISCgRoYXNoGAEgASgJUgRoYXNoEhYKBmhlaWdodBgCIAEoDVIGaGVpZ2h0EhwKCW'
        'Nvbm5lY3RlZBgDIAEoCFIJY29ubmVjdGVkEhQKBXR4aWRzGAQgAygJUgV0eGlkcw==');

const $core.Map<$core.String, $core.dynamic> MempoolServiceBase$json = {
  '1': 'MempoolService',
  '2': [
    {'1': 'ListTransactions', '2': '.mempool.v1.ListTransactionsRequest', '3': '.mempool.v1.ListTransactionsResponse'},
    {'1': 'GetStats', '2': '.mempool.v1.GetStatsRequest', '3': '.mempool.v1.GetStatsResponse'},
    {
      '1': 'WatchTransactions',
      '2': '.mempool.v1.WatchTransactionsRequest',
      '3': '.mempool.v1.WatchTransactionsResponse',
      '6': true
    },
  ],
};

@$core.Deprecated('Use mempoolServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> MempoolServiceBase$messageJson = {
  '.mempool.v1.ListTransactionsRequest': ListTransactionsRequest$json,
  '.mempool.v1.ListTransactionsResponse': ListTransactionsResponse$json,
  '.mempool.v1.Transaction': Transaction$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.mempool.v1.GetStatsRequest': GetStatsRequest$json,
  '.mempool.v1.GetStatsResponse': GetStatsResponse$json,
  '.mempool.v1.FeeBucket': FeeBucket$json,
  '.mempool.v1.WatchTransactionsRequest': WatchTransactionsRequest$json,
  '.mempool.v1.WatchTransactionsResponse': WatchTransactionsResponse$json,
  '.mempool.v1.Snapshot': Snapshot$json,
  '.mempool.v1.Change': Change$json,
  '.mempool.v1.Block': Block$json,
};

/// Descriptor for `MempoolService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List mempoolServiceDescriptor =
    $convert.base64Decode('Cg5NZW1wb29sU2VydmljZRJdChBMaXN0VHJhbnNhY3Rpb25zEiMubWVtcG9vbC52MS5MaXN0VH'
        'JhbnNhY3Rpb25zUmVxdWVzdBokLm1lbXBvb2wudjEuTGlzdFRyYW5zYWN0aW9uc1Jlc3BvbnNl'
        'EkUKCEdldFN0YXRzEhsubWVtcG9vbC52MS5HZXRTdGF0c1JlcXVlc3QaHC5tZW1wb29sLnYxLk'
        'dldFN0YXRzUmVzcG9uc2USYgoRV2F0Y2hUcmFuc2FjdGlvbnMSJC5tZW1wb29sLnYxLldhdGNo'
        'VHJhbnNhY3Rpb25zUmVxdWVzdBolLm1lbXBvb2wudjEuV2F0Y2hUcmFuc2FjdGlvbnNSZXNwb2'
        '5zZTAB');
