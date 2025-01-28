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

import '../../google/protobuf/empty.pbjson.dart' as $1;
import '../../google/protobuf/timestamp.pbjson.dart' as $0;

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

@$core.Deprecated('Use blockDescriptor instead')
const Block$json = {
  '1': 'Block',
  '2': [
    {'1': 'block_time', '3': 1, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'blockTime'},
    {'1': 'block_height', '3': 2, '4': 1, '5': 13, '10': 'blockHeight'},
    {'1': 'hash', '3': 3, '4': 1, '5': 9, '10': 'hash'},
  ],
};

/// Descriptor for `Block`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List blockDescriptor = $convert.base64Decode(
    'CgVCbG9jaxI5CgpibG9ja190aW1lGAEgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcF'
    'IJYmxvY2tUaW1lEiEKDGJsb2NrX2hlaWdodBgCIAEoDVILYmxvY2tIZWlnaHQSEgoEaGFzaBgD'
    'IAEoCVIEaGFzaA==');

@$core.Deprecated('Use listRecentBlocksResponseDescriptor instead')
const ListRecentBlocksResponse$json = {
  '1': 'ListRecentBlocksResponse',
  '2': [
    {'1': 'recent_blocks', '3': 4, '4': 3, '5': 11, '6': '.bitcoind.v1.Block', '10': 'recentBlocks'},
  ],
};

/// Descriptor for `ListRecentBlocksResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listRecentBlocksResponseDescriptor = $convert.base64Decode(
    'ChhMaXN0UmVjZW50QmxvY2tzUmVzcG9uc2USNwoNcmVjZW50X2Jsb2NrcxgEIAMoCzISLmJpdG'
    'NvaW5kLnYxLkJsb2NrUgxyZWNlbnRCbG9ja3M=');

@$core.Deprecated('Use listRecentTransactionsRequestDescriptor instead')
const ListRecentTransactionsRequest$json = {
  '1': 'ListRecentTransactionsRequest',
  '2': [
    {'1': 'count', '3': 1, '4': 1, '5': 3, '10': 'count'},
  ],
};

/// Descriptor for `ListRecentTransactionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listRecentTransactionsRequestDescriptor = $convert.base64Decode(
    'Ch1MaXN0UmVjZW50VHJhbnNhY3Rpb25zUmVxdWVzdBIUCgVjb3VudBgBIAEoA1IFY291bnQ=');

@$core.Deprecated('Use listRecentTransactionsResponseDescriptor instead')
const ListRecentTransactionsResponse$json = {
  '1': 'ListRecentTransactionsResponse',
  '2': [
    {'1': 'transactions', '3': 1, '4': 3, '5': 11, '6': '.bitcoind.v1.RecentTransaction', '10': 'transactions'},
  ],
};

/// Descriptor for `ListRecentTransactionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listRecentTransactionsResponseDescriptor = $convert.base64Decode(
    'Ch5MaXN0UmVjZW50VHJhbnNhY3Rpb25zUmVzcG9uc2USQgoMdHJhbnNhY3Rpb25zGAEgAygLMh'
    '4uYml0Y29pbmQudjEuUmVjZW50VHJhbnNhY3Rpb25SDHRyYW5zYWN0aW9ucw==');

@$core.Deprecated('Use recentTransactionDescriptor instead')
const RecentTransaction$json = {
  '1': 'RecentTransaction',
  '2': [
    {'1': 'virtual_size', '3': 1, '4': 1, '5': 13, '10': 'virtualSize'},
    {'1': 'time', '3': 2, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'time'},
    {'1': 'txid', '3': 3, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'fee_sats', '3': 4, '4': 1, '5': 4, '10': 'feeSats'},
    {'1': 'confirmed_in_block', '3': 5, '4': 1, '5': 11, '6': '.bitcoind.v1.Block', '9': 0, '10': 'confirmedInBlock', '17': true},
  ],
  '8': [
    {'1': '_confirmed_in_block'},
  ],
};

/// Descriptor for `RecentTransaction`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List recentTransactionDescriptor = $convert.base64Decode(
    'ChFSZWNlbnRUcmFuc2FjdGlvbhIhCgx2aXJ0dWFsX3NpemUYASABKA1SC3ZpcnR1YWxTaXplEi'
    '4KBHRpbWUYAiABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgR0aW1lEhIKBHR4aWQY'
    'AyABKAlSBHR4aWQSGQoIZmVlX3NhdHMYBCABKARSB2ZlZVNhdHMSRQoSY29uZmlybWVkX2luX2'
    'Jsb2NrGAUgASgLMhIuYml0Y29pbmQudjEuQmxvY2tIAFIQY29uZmlybWVkSW5CbG9ja4gBAUIV'
    'ChNfY29uZmlybWVkX2luX2Jsb2Nr');

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

const $core.Map<$core.String, $core.dynamic> BitcoindServiceBase$json = {
  '1': 'BitcoindService',
  '2': [
    {'1': 'ListRecentTransactions', '2': '.bitcoind.v1.ListRecentTransactionsRequest', '3': '.bitcoind.v1.ListRecentTransactionsResponse'},
    {'1': 'ListRecentBlocks', '2': '.bitcoind.v1.ListRecentBlocksRequest', '3': '.bitcoind.v1.ListRecentBlocksResponse'},
    {'1': 'GetBlockchainInfo', '2': '.google.protobuf.Empty', '3': '.bitcoind.v1.GetBlockchainInfoResponse'},
    {'1': 'ListPeers', '2': '.google.protobuf.Empty', '3': '.bitcoind.v1.ListPeersResponse'},
    {'1': 'EstimateSmartFee', '2': '.bitcoind.v1.EstimateSmartFeeRequest', '3': '.bitcoind.v1.EstimateSmartFeeResponse'},
  ],
};

@$core.Deprecated('Use bitcoindServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> BitcoindServiceBase$messageJson = {
  '.bitcoind.v1.ListRecentTransactionsRequest': ListRecentTransactionsRequest$json,
  '.bitcoind.v1.ListRecentTransactionsResponse': ListRecentTransactionsResponse$json,
  '.bitcoind.v1.RecentTransaction': RecentTransaction$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.bitcoind.v1.Block': Block$json,
  '.bitcoind.v1.ListRecentBlocksRequest': ListRecentBlocksRequest$json,
  '.bitcoind.v1.ListRecentBlocksResponse': ListRecentBlocksResponse$json,
  '.google.protobuf.Empty': $1.Empty$json,
  '.bitcoind.v1.GetBlockchainInfoResponse': GetBlockchainInfoResponse$json,
  '.bitcoind.v1.ListPeersResponse': ListPeersResponse$json,
  '.bitcoind.v1.Peer': Peer$json,
  '.bitcoind.v1.EstimateSmartFeeRequest': EstimateSmartFeeRequest$json,
  '.bitcoind.v1.EstimateSmartFeeResponse': EstimateSmartFeeResponse$json,
};

/// Descriptor for `BitcoindService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List bitcoindServiceDescriptor = $convert.base64Decode(
    'Cg9CaXRjb2luZFNlcnZpY2UScQoWTGlzdFJlY2VudFRyYW5zYWN0aW9ucxIqLmJpdGNvaW5kLn'
    'YxLkxpc3RSZWNlbnRUcmFuc2FjdGlvbnNSZXF1ZXN0GisuYml0Y29pbmQudjEuTGlzdFJlY2Vu'
    'dFRyYW5zYWN0aW9uc1Jlc3BvbnNlEl8KEExpc3RSZWNlbnRCbG9ja3MSJC5iaXRjb2luZC52MS'
    '5MaXN0UmVjZW50QmxvY2tzUmVxdWVzdBolLmJpdGNvaW5kLnYxLkxpc3RSZWNlbnRCbG9ja3NS'
    'ZXNwb25zZRJTChFHZXRCbG9ja2NoYWluSW5mbxIWLmdvb2dsZS5wcm90b2J1Zi5FbXB0eRomLm'
    'JpdGNvaW5kLnYxLkdldEJsb2NrY2hhaW5JbmZvUmVzcG9uc2USQwoJTGlzdFBlZXJzEhYuZ29v'
    'Z2xlLnByb3RvYnVmLkVtcHR5Gh4uYml0Y29pbmQudjEuTGlzdFBlZXJzUmVzcG9uc2USXwoQRX'
    'N0aW1hdGVTbWFydEZlZRIkLmJpdGNvaW5kLnYxLkVzdGltYXRlU21hcnRGZWVSZXF1ZXN0GiUu'
    'Yml0Y29pbmQudjEuRXN0aW1hdGVTbWFydEZlZVJlc3BvbnNl');

