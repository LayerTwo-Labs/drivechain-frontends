//
//  Generated code. Do not modify.
//  source: bitcoind/v1/bitcoind.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use listRecentBlocksRequestDescriptor instead')
const ListRecentBlocksRequest$json = {
  '1': 'ListRecentBlocksRequest',
  '2': [
    {'1': 'count', '3': 1, '4': 1, '5': 3, '10': 'count'},
  ],
};

/// Descriptor for `ListRecentBlocksRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listRecentBlocksRequestDescriptor = $convert.base64Decode(
    'ChdMaXN0UmVjZW50QmxvY2tzUmVxdWVzdBIUCgVjb3VudBgBIAEoA1IFY291bnQ=');

@$core.Deprecated('Use listRecentBlocksResponseDescriptor instead')
const ListRecentBlocksResponse$json = {
  '1': 'ListRecentBlocksResponse',
  '2': [
    {'1': 'recent_blocks', '3': 4, '4': 3, '5': 11, '6': '.bitcoind.v1.ListRecentBlocksResponse.RecentBlock', '10': 'recentBlocks'},
  ],
  '3': [ListRecentBlocksResponse_RecentBlock$json],
};

@$core.Deprecated('Use listRecentBlocksResponseDescriptor instead')
const ListRecentBlocksResponse_RecentBlock$json = {
  '1': 'RecentBlock',
  '2': [
    {'1': 'block_time', '3': 1, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'blockTime'},
    {'1': 'block_height', '3': 2, '4': 1, '5': 13, '10': 'blockHeight'},
    {'1': 'hash', '3': 3, '4': 1, '5': 9, '10': 'hash'},
  ],
};

/// Descriptor for `ListRecentBlocksResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listRecentBlocksResponseDescriptor = $convert.base64Decode(
    'ChhMaXN0UmVjZW50QmxvY2tzUmVzcG9uc2USVgoNcmVjZW50X2Jsb2NrcxgEIAMoCzIxLmJpdG'
    'NvaW5kLnYxLkxpc3RSZWNlbnRCbG9ja3NSZXNwb25zZS5SZWNlbnRCbG9ja1IMcmVjZW50Qmxv'
    'Y2tzGn8KC1JlY2VudEJsb2NrEjkKCmJsb2NrX3RpbWUYASABKAsyGi5nb29nbGUucHJvdG9idW'
    'YuVGltZXN0YW1wUglibG9ja1RpbWUSIQoMYmxvY2tfaGVpZ2h0GAIgASgNUgtibG9ja0hlaWdo'
    'dBISCgRoYXNoGAMgASgJUgRoYXNo');

@$core.Deprecated('Use listUnconfirmedTransactionsRequestDescriptor instead')
const ListUnconfirmedTransactionsRequest$json = {
  '1': 'ListUnconfirmedTransactionsRequest',
  '2': [
    {'1': 'count', '3': 1, '4': 1, '5': 3, '10': 'count'},
  ],
};

/// Descriptor for `ListUnconfirmedTransactionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listUnconfirmedTransactionsRequestDescriptor = $convert.base64Decode(
    'CiJMaXN0VW5jb25maXJtZWRUcmFuc2FjdGlvbnNSZXF1ZXN0EhQKBWNvdW50GAEgASgDUgVjb3'
    'VudA==');

@$core.Deprecated('Use listUnconfirmedTransactionsResponseDescriptor instead')
const ListUnconfirmedTransactionsResponse$json = {
  '1': 'ListUnconfirmedTransactionsResponse',
  '2': [
    {'1': 'unconfirmed_transactions', '3': 1, '4': 3, '5': 11, '6': '.bitcoind.v1.UnconfirmedTransaction', '10': 'unconfirmedTransactions'},
  ],
};

/// Descriptor for `ListUnconfirmedTransactionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listUnconfirmedTransactionsResponseDescriptor = $convert.base64Decode(
    'CiNMaXN0VW5jb25maXJtZWRUcmFuc2FjdGlvbnNSZXNwb25zZRJeChh1bmNvbmZpcm1lZF90cm'
    'Fuc2FjdGlvbnMYASADKAsyIy5iaXRjb2luZC52MS5VbmNvbmZpcm1lZFRyYW5zYWN0aW9uUhd1'
    'bmNvbmZpcm1lZFRyYW5zYWN0aW9ucw==');

@$core.Deprecated('Use unconfirmedTransactionDescriptor instead')
const UnconfirmedTransaction$json = {
  '1': 'UnconfirmedTransaction',
  '2': [
    {'1': 'virtual_size', '3': 1, '4': 1, '5': 13, '10': 'virtualSize'},
    {'1': 'weight', '3': 2, '4': 1, '5': 13, '10': 'weight'},
    {'1': 'time', '3': 3, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'time'},
    {'1': 'txid', '3': 4, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'fee_satoshi', '3': 5, '4': 1, '5': 4, '10': 'feeSatoshi'},
  ],
};

/// Descriptor for `UnconfirmedTransaction`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unconfirmedTransactionDescriptor = $convert.base64Decode(
    'ChZVbmNvbmZpcm1lZFRyYW5zYWN0aW9uEiEKDHZpcnR1YWxfc2l6ZRgBIAEoDVILdmlydHVhbF'
    'NpemUSFgoGd2VpZ2h0GAIgASgNUgZ3ZWlnaHQSLgoEdGltZRgDIAEoCzIaLmdvb2dsZS5wcm90'
    'b2J1Zi5UaW1lc3RhbXBSBHRpbWUSEgoEdHhpZBgEIAEoCVIEdHhpZBIfCgtmZWVfc2F0b3NoaR'
    'gFIAEoBFIKZmVlU2F0b3NoaQ==');

@$core.Deprecated('Use getBlockchainInfoResponseDescriptor instead')
const GetBlockchainInfoResponse$json = {
  '1': 'GetBlockchainInfoResponse',
  '2': [
    {'1': 'chain', '3': 1, '4': 1, '5': 9, '10': 'chain'},
    {'1': 'blocks', '3': 2, '4': 1, '5': 13, '10': 'blocks'},
    {'1': 'headers', '3': 3, '4': 1, '5': 13, '10': 'headers'},
    {'1': 'best_block_hash', '3': 4, '4': 1, '5': 9, '10': 'bestBlockHash'},
    {'1': 'initial_block_download', '3': 8, '4': 1, '5': 8, '10': 'initialBlockDownload'},
  ],
};

/// Descriptor for `GetBlockchainInfoResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBlockchainInfoResponseDescriptor = $convert.base64Decode(
    'ChlHZXRCbG9ja2NoYWluSW5mb1Jlc3BvbnNlEhQKBWNoYWluGAEgASgJUgVjaGFpbhIWCgZibG'
    '9ja3MYAiABKA1SBmJsb2NrcxIYCgdoZWFkZXJzGAMgASgNUgdoZWFkZXJzEiYKD2Jlc3RfYmxv'
    'Y2tfaGFzaBgEIAEoCVINYmVzdEJsb2NrSGFzaBI0ChZpbml0aWFsX2Jsb2NrX2Rvd25sb2FkGA'
    'ggASgIUhRpbml0aWFsQmxvY2tEb3dubG9hZA==');

@$core.Deprecated('Use peerDescriptor instead')
const Peer$json = {
  '1': 'Peer',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'addr', '3': 2, '4': 1, '5': 9, '10': 'addr'},
    {'1': 'synced_blocks', '3': 3, '4': 1, '5': 5, '10': 'syncedBlocks'},
  ],
};

/// Descriptor for `Peer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List peerDescriptor = $convert.base64Decode(
    'CgRQZWVyEg4KAmlkGAEgASgFUgJpZBISCgRhZGRyGAIgASgJUgRhZGRyEiMKDXN5bmNlZF9ibG'
    '9ja3MYAyABKAVSDHN5bmNlZEJsb2Nrcw==');

@$core.Deprecated('Use listPeersResponseDescriptor instead')
const ListPeersResponse$json = {
  '1': 'ListPeersResponse',
  '2': [
    {'1': 'peers', '3': 1, '4': 3, '5': 11, '6': '.bitcoind.v1.Peer', '10': 'peers'},
  ],
};

/// Descriptor for `ListPeersResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listPeersResponseDescriptor = $convert.base64Decode(
    'ChFMaXN0UGVlcnNSZXNwb25zZRInCgVwZWVycxgBIAMoCzIRLmJpdGNvaW5kLnYxLlBlZXJSBX'
    'BlZXJz');

@$core.Deprecated('Use estimateSmartFeeRequestDescriptor instead')
const EstimateSmartFeeRequest$json = {
  '1': 'EstimateSmartFeeRequest',
  '2': [
    {'1': 'conf_target', '3': 1, '4': 1, '5': 3, '10': 'confTarget'},
  ],
};

/// Descriptor for `EstimateSmartFeeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List estimateSmartFeeRequestDescriptor = $convert.base64Decode(
    'ChdFc3RpbWF0ZVNtYXJ0RmVlUmVxdWVzdBIfCgtjb25mX3RhcmdldBgBIAEoA1IKY29uZlRhcm'
    'dldA==');

@$core.Deprecated('Use estimateSmartFeeResponseDescriptor instead')
const EstimateSmartFeeResponse$json = {
  '1': 'EstimateSmartFeeResponse',
  '2': [
    {'1': 'fee_rate', '3': 1, '4': 1, '5': 1, '10': 'feeRate'},
    {'1': 'errors', '3': 2, '4': 3, '5': 9, '10': 'errors'},
  ],
};

/// Descriptor for `EstimateSmartFeeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List estimateSmartFeeResponseDescriptor = $convert.base64Decode(
    'ChhFc3RpbWF0ZVNtYXJ0RmVlUmVzcG9uc2USGQoIZmVlX3JhdGUYASABKAFSB2ZlZVJhdGUSFg'
    'oGZXJyb3JzGAIgAygJUgZlcnJvcnM=');

