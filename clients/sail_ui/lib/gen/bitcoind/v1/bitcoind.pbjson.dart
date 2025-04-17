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

@$core.Deprecated('Use listBlocksRequestDescriptor instead')
const ListBlocksRequest$json = {
  '1': 'ListBlocksRequest',
  '2': [
    {'1': 'start_height', '3': 1, '4': 1, '5': 13, '10': 'startHeight'},
    {'1': 'page_size', '3': 2, '4': 1, '5': 13, '10': 'pageSize'},
  ],
};

/// Descriptor for `ListBlocksRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listBlocksRequestDescriptor = $convert.base64Decode(
    'ChFMaXN0QmxvY2tzUmVxdWVzdBIhCgxzdGFydF9oZWlnaHQYASABKA1SC3N0YXJ0SGVpZ2h0Eh'
    'sKCXBhZ2Vfc2l6ZRgCIAEoDVIIcGFnZVNpemU=');

@$core.Deprecated('Use blockDescriptor instead')
const Block$json = {
  '1': 'Block',
  '2': [
    {'1': 'block_time', '3': 1, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'blockTime'},
    {'1': 'height', '3': 2, '4': 1, '5': 13, '10': 'height'},
    {'1': 'hash', '3': 3, '4': 1, '5': 9, '10': 'hash'},
    {'1': 'confirmations', '3': 4, '4': 1, '5': 5, '10': 'confirmations'},
    {'1': 'version', '3': 5, '4': 1, '5': 5, '10': 'version'},
    {'1': 'version_hex', '3': 6, '4': 1, '5': 9, '10': 'versionHex'},
    {'1': 'merkle_root', '3': 7, '4': 1, '5': 9, '10': 'merkleRoot'},
    {'1': 'nonce', '3': 8, '4': 1, '5': 13, '10': 'nonce'},
    {'1': 'bits', '3': 9, '4': 1, '5': 9, '10': 'bits'},
    {'1': 'difficulty', '3': 10, '4': 1, '5': 1, '10': 'difficulty'},
    {'1': 'previous_block_hash', '3': 11, '4': 1, '5': 9, '10': 'previousBlockHash'},
    {'1': 'next_block_hash', '3': 12, '4': 1, '5': 9, '10': 'nextBlockHash'},
    {'1': 'stripped_size', '3': 13, '4': 1, '5': 5, '10': 'strippedSize'},
    {'1': 'size', '3': 14, '4': 1, '5': 5, '10': 'size'},
    {'1': 'weight', '3': 15, '4': 1, '5': 5, '10': 'weight'},
    {'1': 'txids', '3': 16, '4': 3, '5': 9, '10': 'txids'},
  ],
};

/// Descriptor for `Block`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List blockDescriptor = $convert.base64Decode(
    'CgVCbG9jaxI5CgpibG9ja190aW1lGAEgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcF'
    'IJYmxvY2tUaW1lEhYKBmhlaWdodBgCIAEoDVIGaGVpZ2h0EhIKBGhhc2gYAyABKAlSBGhhc2gS'
    'JAoNY29uZmlybWF0aW9ucxgEIAEoBVINY29uZmlybWF0aW9ucxIYCgd2ZXJzaW9uGAUgASgFUg'
    'd2ZXJzaW9uEh8KC3ZlcnNpb25faGV4GAYgASgJUgp2ZXJzaW9uSGV4Eh8KC21lcmtsZV9yb290'
    'GAcgASgJUgptZXJrbGVSb290EhQKBW5vbmNlGAggASgNUgVub25jZRISCgRiaXRzGAkgASgJUg'
    'RiaXRzEh4KCmRpZmZpY3VsdHkYCiABKAFSCmRpZmZpY3VsdHkSLgoTcHJldmlvdXNfYmxvY2tf'
    'aGFzaBgLIAEoCVIRcHJldmlvdXNCbG9ja0hhc2gSJgoPbmV4dF9ibG9ja19oYXNoGAwgASgJUg'
    '1uZXh0QmxvY2tIYXNoEiMKDXN0cmlwcGVkX3NpemUYDSABKAVSDHN0cmlwcGVkU2l6ZRISCgRz'
    'aXplGA4gASgFUgRzaXplEhYKBndlaWdodBgPIAEoBVIGd2VpZ2h0EhQKBXR4aWRzGBAgAygJUg'
    'V0eGlkcw==');

@$core.Deprecated('Use listBlocksResponseDescriptor instead')
const ListBlocksResponse$json = {
  '1': 'ListBlocksResponse',
  '2': [
    {'1': 'recent_blocks', '3': 4, '4': 3, '5': 11, '6': '.bitcoind.v1.Block', '10': 'recentBlocks'},
    {'1': 'has_more', '3': 5, '4': 1, '5': 8, '10': 'hasMore'},
  ],
};

/// Descriptor for `ListBlocksResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listBlocksResponseDescriptor = $convert.base64Decode(
    'ChJMaXN0QmxvY2tzUmVzcG9uc2USNwoNcmVjZW50X2Jsb2NrcxgEIAMoCzISLmJpdGNvaW5kLn'
    'YxLkJsb2NrUgxyZWNlbnRCbG9ja3MSGQoIaGFzX21vcmUYBSABKAhSB2hhc01vcmU=');

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

@$core.Deprecated('Use getRawTransactionRequestDescriptor instead')
const GetRawTransactionRequest$json = {
  '1': 'GetRawTransactionRequest',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `GetRawTransactionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getRawTransactionRequestDescriptor = $convert.base64Decode(
    'ChhHZXRSYXdUcmFuc2FjdGlvblJlcXVlc3QSEgoEdHhpZBgBIAEoCVIEdHhpZA==');

@$core.Deprecated('Use rawTransactionDescriptor instead')
const RawTransaction$json = {
  '1': 'RawTransaction',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 12, '10': 'data'},
    {'1': 'hex', '3': 2, '4': 1, '5': 9, '10': 'hex'},
  ],
};

/// Descriptor for `RawTransaction`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rawTransactionDescriptor = $convert.base64Decode(
    'Cg5SYXdUcmFuc2FjdGlvbhISCgRkYXRhGAEgASgMUgRkYXRhEhAKA2hleBgCIAEoCVIDaGV4');

@$core.Deprecated('Use createRawTransactionRequestDescriptor instead')
const CreateRawTransactionRequest$json = {
  '1': 'CreateRawTransactionRequest',
  '2': [
    {'1': 'inputs', '3': 1, '4': 3, '5': 11, '6': '.bitcoind.v1.CreateRawTransactionRequest.Input', '10': 'inputs'},
    {'1': 'outputs', '3': 2, '4': 3, '5': 11, '6': '.bitcoind.v1.CreateRawTransactionRequest.OutputsEntry', '10': 'outputs'},
    {'1': 'locktime', '3': 3, '4': 1, '5': 13, '10': 'locktime'},
  ],
  '3': [CreateRawTransactionRequest_Input$json, CreateRawTransactionRequest_OutputsEntry$json],
};

@$core.Deprecated('Use createRawTransactionRequestDescriptor instead')
const CreateRawTransactionRequest_Input$json = {
  '1': 'Input',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'vout', '3': 2, '4': 1, '5': 13, '10': 'vout'},
    {'1': 'sequence', '3': 3, '4': 1, '5': 13, '10': 'sequence'},
  ],
};

@$core.Deprecated('Use createRawTransactionRequestDescriptor instead')
const CreateRawTransactionRequest_OutputsEntry$json = {
  '1': 'OutputsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 1, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `CreateRawTransactionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createRawTransactionRequestDescriptor = $convert.base64Decode(
    'ChtDcmVhdGVSYXdUcmFuc2FjdGlvblJlcXVlc3QSRgoGaW5wdXRzGAEgAygLMi4uYml0Y29pbm'
    'QudjEuQ3JlYXRlUmF3VHJhbnNhY3Rpb25SZXF1ZXN0LklucHV0UgZpbnB1dHMSTwoHb3V0cHV0'
    'cxgCIAMoCzI1LmJpdGNvaW5kLnYxLkNyZWF0ZVJhd1RyYW5zYWN0aW9uUmVxdWVzdC5PdXRwdX'
    'RzRW50cnlSB291dHB1dHMSGgoIbG9ja3RpbWUYAyABKA1SCGxvY2t0aW1lGksKBUlucHV0EhIK'
    'BHR4aWQYASABKAlSBHR4aWQSEgoEdm91dBgCIAEoDVIEdm91dBIaCghzZXF1ZW5jZRgDIAEoDV'
    'IIc2VxdWVuY2UaOgoMT3V0cHV0c0VudHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGAIg'
    'ASgBUgV2YWx1ZToCOAE=');

@$core.Deprecated('Use createRawTransactionResponseDescriptor instead')
const CreateRawTransactionResponse$json = {
  '1': 'CreateRawTransactionResponse',
  '2': [
    {'1': 'tx', '3': 1, '4': 1, '5': 11, '6': '.bitcoind.v1.RawTransaction', '10': 'tx'},
  ],
};

/// Descriptor for `CreateRawTransactionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createRawTransactionResponseDescriptor = $convert.base64Decode(
    'ChxDcmVhdGVSYXdUcmFuc2FjdGlvblJlc3BvbnNlEisKAnR4GAEgASgLMhsuYml0Y29pbmQudj'
    'EuUmF3VHJhbnNhY3Rpb25SAnR4');

@$core.Deprecated('Use scriptSigDescriptor instead')
const ScriptSig$json = {
  '1': 'ScriptSig',
  '2': [
    {'1': 'asm', '3': 1, '4': 1, '5': 9, '10': 'asm'},
    {'1': 'hex', '3': 2, '4': 1, '5': 9, '10': 'hex'},
  ],
};

/// Descriptor for `ScriptSig`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List scriptSigDescriptor = $convert.base64Decode(
    'CglTY3JpcHRTaWcSEAoDYXNtGAEgASgJUgNhc20SEAoDaGV4GAIgASgJUgNoZXg=');

@$core.Deprecated('Use inputDescriptor instead')
const Input$json = {
  '1': 'Input',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'vout', '3': 2, '4': 1, '5': 13, '10': 'vout'},
    {'1': 'coinbase', '3': 3, '4': 1, '5': 9, '10': 'coinbase'},
    {'1': 'script_sig', '3': 4, '4': 1, '5': 11, '6': '.bitcoind.v1.ScriptSig', '10': 'scriptSig'},
    {'1': 'sequence', '3': 5, '4': 1, '5': 13, '10': 'sequence'},
    {'1': 'witness', '3': 6, '4': 3, '5': 9, '10': 'witness'},
  ],
};

/// Descriptor for `Input`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List inputDescriptor = $convert.base64Decode(
    'CgVJbnB1dBISCgR0eGlkGAEgASgJUgR0eGlkEhIKBHZvdXQYAiABKA1SBHZvdXQSGgoIY29pbm'
    'Jhc2UYAyABKAlSCGNvaW5iYXNlEjUKCnNjcmlwdF9zaWcYBCABKAsyFi5iaXRjb2luZC52MS5T'
    'Y3JpcHRTaWdSCXNjcmlwdFNpZxIaCghzZXF1ZW5jZRgFIAEoDVIIc2VxdWVuY2USGAoHd2l0bm'
    'VzcxgGIAMoCVIHd2l0bmVzcw==');

@$core.Deprecated('Use scriptPubKeyDescriptor instead')
const ScriptPubKey$json = {
  '1': 'ScriptPubKey',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 9, '10': 'type'},
    {'1': 'address', '3': 2, '4': 1, '5': 9, '10': 'address'},
  ],
};

/// Descriptor for `ScriptPubKey`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List scriptPubKeyDescriptor = $convert.base64Decode(
    'CgxTY3JpcHRQdWJLZXkSEgoEdHlwZRgBIAEoCVIEdHlwZRIYCgdhZGRyZXNzGAIgASgJUgdhZG'
    'RyZXNz');

@$core.Deprecated('Use outputDescriptor instead')
const Output$json = {
  '1': 'Output',
  '2': [
    {'1': 'amount', '3': 1, '4': 1, '5': 1, '10': 'amount'},
    {'1': 'vout', '3': 2, '4': 1, '5': 13, '10': 'vout'},
    {'1': 'script_pub_key', '3': 3, '4': 1, '5': 11, '6': '.bitcoind.v1.ScriptPubKey', '10': 'scriptPubKey'},
    {'1': 'script_sig', '3': 4, '4': 1, '5': 11, '6': '.bitcoind.v1.ScriptSig', '10': 'scriptSig'},
  ],
};

/// Descriptor for `Output`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List outputDescriptor = $convert.base64Decode(
    'CgZPdXRwdXQSFgoGYW1vdW50GAEgASgBUgZhbW91bnQSEgoEdm91dBgCIAEoDVIEdm91dBI/Cg'
    '5zY3JpcHRfcHViX2tleRgDIAEoCzIZLmJpdGNvaW5kLnYxLlNjcmlwdFB1YktleVIMc2NyaXB0'
    'UHViS2V5EjUKCnNjcmlwdF9zaWcYBCABKAsyFi5iaXRjb2luZC52MS5TY3JpcHRTaWdSCXNjcm'
    'lwdFNpZw==');

@$core.Deprecated('Use getRawTransactionResponseDescriptor instead')
const GetRawTransactionResponse$json = {
  '1': 'GetRawTransactionResponse',
  '2': [
    {'1': 'tx', '3': 1, '4': 1, '5': 11, '6': '.bitcoind.v1.RawTransaction', '10': 'tx'},
    {'1': 'txid', '3': 8, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'hash', '3': 9, '4': 1, '5': 9, '10': 'hash'},
    {'1': 'size', '3': 10, '4': 1, '5': 5, '10': 'size'},
    {'1': 'vsize', '3': 11, '4': 1, '5': 5, '10': 'vsize'},
    {'1': 'weight', '3': 12, '4': 1, '5': 5, '10': 'weight'},
    {'1': 'version', '3': 13, '4': 1, '5': 13, '10': 'version'},
    {'1': 'locktime', '3': 14, '4': 1, '5': 13, '10': 'locktime'},
    {'1': 'inputs', '3': 2, '4': 3, '5': 11, '6': '.bitcoind.v1.Input', '10': 'inputs'},
    {'1': 'outputs', '3': 3, '4': 3, '5': 11, '6': '.bitcoind.v1.Output', '10': 'outputs'},
    {'1': 'blockhash', '3': 4, '4': 1, '5': 9, '10': 'blockhash'},
    {'1': 'confirmations', '3': 5, '4': 1, '5': 13, '10': 'confirmations'},
    {'1': 'time', '3': 6, '4': 1, '5': 3, '10': 'time'},
    {'1': 'blocktime', '3': 7, '4': 1, '5': 3, '10': 'blocktime'},
  ],
};

/// Descriptor for `GetRawTransactionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getRawTransactionResponseDescriptor = $convert.base64Decode(
    'ChlHZXRSYXdUcmFuc2FjdGlvblJlc3BvbnNlEisKAnR4GAEgASgLMhsuYml0Y29pbmQudjEuUm'
    'F3VHJhbnNhY3Rpb25SAnR4EhIKBHR4aWQYCCABKAlSBHR4aWQSEgoEaGFzaBgJIAEoCVIEaGFz'
    'aBISCgRzaXplGAogASgFUgRzaXplEhQKBXZzaXplGAsgASgFUgV2c2l6ZRIWCgZ3ZWlnaHQYDC'
    'ABKAVSBndlaWdodBIYCgd2ZXJzaW9uGA0gASgNUgd2ZXJzaW9uEhoKCGxvY2t0aW1lGA4gASgN'
    'Ughsb2NrdGltZRIqCgZpbnB1dHMYAiADKAsyEi5iaXRjb2luZC52MS5JbnB1dFIGaW5wdXRzEi'
    '0KB291dHB1dHMYAyADKAsyEy5iaXRjb2luZC52MS5PdXRwdXRSB291dHB1dHMSHAoJYmxvY2to'
    'YXNoGAQgASgJUglibG9ja2hhc2gSJAoNY29uZmlybWF0aW9ucxgFIAEoDVINY29uZmlybWF0aW'
    '9ucxISCgR0aW1lGAYgASgDUgR0aW1lEhwKCWJsb2NrdGltZRgHIAEoA1IJYmxvY2t0aW1l');

@$core.Deprecated('Use getBlockRequestDescriptor instead')
const GetBlockRequest$json = {
  '1': 'GetBlockRequest',
  '2': [
    {'1': 'hash', '3': 1, '4': 1, '5': 9, '9': 0, '10': 'hash'},
    {'1': 'height', '3': 2, '4': 1, '5': 13, '9': 0, '10': 'height'},
  ],
  '8': [
    {'1': 'identifier'},
  ],
};

/// Descriptor for `GetBlockRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBlockRequestDescriptor = $convert.base64Decode(
    'Cg9HZXRCbG9ja1JlcXVlc3QSFAoEaGFzaBgBIAEoCUgAUgRoYXNoEhgKBmhlaWdodBgCIAEoDU'
    'gAUgZoZWlnaHRCDAoKaWRlbnRpZmllcg==');

@$core.Deprecated('Use getBlockResponseDescriptor instead')
const GetBlockResponse$json = {
  '1': 'GetBlockResponse',
  '2': [
    {'1': 'block', '3': 1, '4': 1, '5': 11, '6': '.bitcoind.v1.Block', '10': 'block'},
  ],
};

/// Descriptor for `GetBlockResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBlockResponseDescriptor = $convert.base64Decode(
    'ChBHZXRCbG9ja1Jlc3BvbnNlEigKBWJsb2NrGAEgASgLMhIuYml0Y29pbmQudjEuQmxvY2tSBW'
    'Jsb2Nr');

@$core.Deprecated('Use createWalletRequestDescriptor instead')
const CreateWalletRequest$json = {
  '1': 'CreateWalletRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'disable_private_keys', '3': 2, '4': 1, '5': 8, '10': 'disablePrivateKeys'},
    {'1': 'blank', '3': 3, '4': 1, '5': 8, '10': 'blank'},
    {'1': 'passphrase', '3': 4, '4': 1, '5': 9, '10': 'passphrase'},
    {'1': 'avoid_reuse', '3': 5, '4': 1, '5': 8, '10': 'avoidReuse'},
  ],
};

/// Descriptor for `CreateWalletRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createWalletRequestDescriptor = $convert.base64Decode(
    'ChNDcmVhdGVXYWxsZXRSZXF1ZXN0EhIKBG5hbWUYASABKAlSBG5hbWUSMAoUZGlzYWJsZV9wcm'
    'l2YXRlX2tleXMYAiABKAhSEmRpc2FibGVQcml2YXRlS2V5cxIUCgVibGFuaxgDIAEoCFIFYmxh'
    'bmsSHgoKcGFzc3BocmFzZRgEIAEoCVIKcGFzc3BocmFzZRIfCgthdm9pZF9yZXVzZRgFIAEoCF'
    'IKYXZvaWRSZXVzZQ==');

@$core.Deprecated('Use createWalletResponseDescriptor instead')
const CreateWalletResponse$json = {
  '1': 'CreateWalletResponse',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'warning', '3': 2, '4': 1, '5': 9, '10': 'warning'},
  ],
};

/// Descriptor for `CreateWalletResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createWalletResponseDescriptor = $convert.base64Decode(
    'ChRDcmVhdGVXYWxsZXRSZXNwb25zZRISCgRuYW1lGAEgASgJUgRuYW1lEhgKB3dhcm5pbmcYAi'
    'ABKAlSB3dhcm5pbmc=');

@$core.Deprecated('Use backupWalletRequestDescriptor instead')
const BackupWalletRequest$json = {
  '1': 'BackupWalletRequest',
  '2': [
    {'1': 'destination', '3': 1, '4': 1, '5': 9, '10': 'destination'},
    {'1': 'wallet', '3': 2, '4': 1, '5': 9, '10': 'wallet'},
  ],
};

/// Descriptor for `BackupWalletRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List backupWalletRequestDescriptor = $convert.base64Decode(
    'ChNCYWNrdXBXYWxsZXRSZXF1ZXN0EiAKC2Rlc3RpbmF0aW9uGAEgASgJUgtkZXN0aW5hdGlvbh'
    'IWCgZ3YWxsZXQYAiABKAlSBndhbGxldA==');

@$core.Deprecated('Use backupWalletResponseDescriptor instead')
const BackupWalletResponse$json = {
  '1': 'BackupWalletResponse',
};

/// Descriptor for `BackupWalletResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List backupWalletResponseDescriptor = $convert.base64Decode(
    'ChRCYWNrdXBXYWxsZXRSZXNwb25zZQ==');

@$core.Deprecated('Use dumpWalletRequestDescriptor instead')
const DumpWalletRequest$json = {
  '1': 'DumpWalletRequest',
  '2': [
    {'1': 'filename', '3': 1, '4': 1, '5': 9, '10': 'filename'},
    {'1': 'wallet', '3': 2, '4': 1, '5': 9, '10': 'wallet'},
  ],
};

/// Descriptor for `DumpWalletRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dumpWalletRequestDescriptor = $convert.base64Decode(
    'ChFEdW1wV2FsbGV0UmVxdWVzdBIaCghmaWxlbmFtZRgBIAEoCVIIZmlsZW5hbWUSFgoGd2FsbG'
    'V0GAIgASgJUgZ3YWxsZXQ=');

@$core.Deprecated('Use dumpWalletResponseDescriptor instead')
const DumpWalletResponse$json = {
  '1': 'DumpWalletResponse',
  '2': [
    {'1': 'filename', '3': 1, '4': 1, '5': 9, '10': 'filename'},
  ],
};

/// Descriptor for `DumpWalletResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dumpWalletResponseDescriptor = $convert.base64Decode(
    'ChJEdW1wV2FsbGV0UmVzcG9uc2USGgoIZmlsZW5hbWUYASABKAlSCGZpbGVuYW1l');

@$core.Deprecated('Use importWalletRequestDescriptor instead')
const ImportWalletRequest$json = {
  '1': 'ImportWalletRequest',
  '2': [
    {'1': 'filename', '3': 1, '4': 1, '5': 9, '10': 'filename'},
    {'1': 'wallet', '3': 2, '4': 1, '5': 9, '10': 'wallet'},
  ],
};

/// Descriptor for `ImportWalletRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importWalletRequestDescriptor = $convert.base64Decode(
    'ChNJbXBvcnRXYWxsZXRSZXF1ZXN0EhoKCGZpbGVuYW1lGAEgASgJUghmaWxlbmFtZRIWCgZ3YW'
    'xsZXQYAiABKAlSBndhbGxldA==');

@$core.Deprecated('Use importWalletResponseDescriptor instead')
const ImportWalletResponse$json = {
  '1': 'ImportWalletResponse',
};

/// Descriptor for `ImportWalletResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importWalletResponseDescriptor = $convert.base64Decode(
    'ChRJbXBvcnRXYWxsZXRSZXNwb25zZQ==');

@$core.Deprecated('Use unloadWalletRequestDescriptor instead')
const UnloadWalletRequest$json = {
  '1': 'UnloadWalletRequest',
  '2': [
    {'1': 'wallet_name', '3': 1, '4': 1, '5': 9, '10': 'walletName'},
    {'1': 'wallet', '3': 2, '4': 1, '5': 9, '10': 'wallet'},
  ],
};

/// Descriptor for `UnloadWalletRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unloadWalletRequestDescriptor = $convert.base64Decode(
    'ChNVbmxvYWRXYWxsZXRSZXF1ZXN0Eh8KC3dhbGxldF9uYW1lGAEgASgJUgp3YWxsZXROYW1lEh'
    'YKBndhbGxldBgCIAEoCVIGd2FsbGV0');

@$core.Deprecated('Use unloadWalletResponseDescriptor instead')
const UnloadWalletResponse$json = {
  '1': 'UnloadWalletResponse',
};

/// Descriptor for `UnloadWalletResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unloadWalletResponseDescriptor = $convert.base64Decode(
    'ChRVbmxvYWRXYWxsZXRSZXNwb25zZQ==');

@$core.Deprecated('Use dumpPrivKeyRequestDescriptor instead')
const DumpPrivKeyRequest$json = {
  '1': 'DumpPrivKeyRequest',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'wallet', '3': 2, '4': 1, '5': 9, '10': 'wallet'},
  ],
};

/// Descriptor for `DumpPrivKeyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dumpPrivKeyRequestDescriptor = $convert.base64Decode(
    'ChJEdW1wUHJpdktleVJlcXVlc3QSGAoHYWRkcmVzcxgBIAEoCVIHYWRkcmVzcxIWCgZ3YWxsZX'
    'QYAiABKAlSBndhbGxldA==');

@$core.Deprecated('Use dumpPrivKeyResponseDescriptor instead')
const DumpPrivKeyResponse$json = {
  '1': 'DumpPrivKeyResponse',
  '2': [
    {'1': 'private_key', '3': 1, '4': 1, '5': 9, '10': 'privateKey'},
  ],
};

/// Descriptor for `DumpPrivKeyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dumpPrivKeyResponseDescriptor = $convert.base64Decode(
    'ChNEdW1wUHJpdktleVJlc3BvbnNlEh8KC3ByaXZhdGVfa2V5GAEgASgJUgpwcml2YXRlS2V5');

@$core.Deprecated('Use importPrivKeyRequestDescriptor instead')
const ImportPrivKeyRequest$json = {
  '1': 'ImportPrivKeyRequest',
  '2': [
    {'1': 'private_key', '3': 1, '4': 1, '5': 9, '10': 'privateKey'},
    {'1': 'label', '3': 2, '4': 1, '5': 9, '10': 'label'},
    {'1': 'rescan', '3': 3, '4': 1, '5': 8, '10': 'rescan'},
    {'1': 'wallet', '3': 4, '4': 1, '5': 9, '10': 'wallet'},
  ],
};

/// Descriptor for `ImportPrivKeyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importPrivKeyRequestDescriptor = $convert.base64Decode(
    'ChRJbXBvcnRQcml2S2V5UmVxdWVzdBIfCgtwcml2YXRlX2tleRgBIAEoCVIKcHJpdmF0ZUtleR'
    'IUCgVsYWJlbBgCIAEoCVIFbGFiZWwSFgoGcmVzY2FuGAMgASgIUgZyZXNjYW4SFgoGd2FsbGV0'
    'GAQgASgJUgZ3YWxsZXQ=');

@$core.Deprecated('Use importPrivKeyResponseDescriptor instead')
const ImportPrivKeyResponse$json = {
  '1': 'ImportPrivKeyResponse',
};

/// Descriptor for `ImportPrivKeyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importPrivKeyResponseDescriptor = $convert.base64Decode(
    'ChVJbXBvcnRQcml2S2V5UmVzcG9uc2U=');

@$core.Deprecated('Use importAddressRequestDescriptor instead')
const ImportAddressRequest$json = {
  '1': 'ImportAddressRequest',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'label', '3': 2, '4': 1, '5': 9, '10': 'label'},
    {'1': 'rescan', '3': 3, '4': 1, '5': 8, '10': 'rescan'},
    {'1': 'wallet', '3': 4, '4': 1, '5': 9, '10': 'wallet'},
  ],
};

/// Descriptor for `ImportAddressRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importAddressRequestDescriptor = $convert.base64Decode(
    'ChRJbXBvcnRBZGRyZXNzUmVxdWVzdBIYCgdhZGRyZXNzGAEgASgJUgdhZGRyZXNzEhQKBWxhYm'
    'VsGAIgASgJUgVsYWJlbBIWCgZyZXNjYW4YAyABKAhSBnJlc2NhbhIWCgZ3YWxsZXQYBCABKAlS'
    'BndhbGxldA==');

@$core.Deprecated('Use importAddressResponseDescriptor instead')
const ImportAddressResponse$json = {
  '1': 'ImportAddressResponse',
};

/// Descriptor for `ImportAddressResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importAddressResponseDescriptor = $convert.base64Decode(
    'ChVJbXBvcnRBZGRyZXNzUmVzcG9uc2U=');

@$core.Deprecated('Use importPubKeyRequestDescriptor instead')
const ImportPubKeyRequest$json = {
  '1': 'ImportPubKeyRequest',
  '2': [
    {'1': 'pubkey', '3': 1, '4': 1, '5': 9, '10': 'pubkey'},
    {'1': 'rescan', '3': 2, '4': 1, '5': 8, '10': 'rescan'},
    {'1': 'wallet', '3': 3, '4': 1, '5': 9, '10': 'wallet'},
  ],
};

/// Descriptor for `ImportPubKeyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importPubKeyRequestDescriptor = $convert.base64Decode(
    'ChNJbXBvcnRQdWJLZXlSZXF1ZXN0EhYKBnB1YmtleRgBIAEoCVIGcHVia2V5EhYKBnJlc2Nhbh'
    'gCIAEoCFIGcmVzY2FuEhYKBndhbGxldBgDIAEoCVIGd2FsbGV0');

@$core.Deprecated('Use importPubKeyResponseDescriptor instead')
const ImportPubKeyResponse$json = {
  '1': 'ImportPubKeyResponse',
};

/// Descriptor for `ImportPubKeyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importPubKeyResponseDescriptor = $convert.base64Decode(
    'ChRJbXBvcnRQdWJLZXlSZXNwb25zZQ==');

@$core.Deprecated('Use keyPoolRefillRequestDescriptor instead')
const KeyPoolRefillRequest$json = {
  '1': 'KeyPoolRefillRequest',
  '2': [
    {'1': 'new_size', '3': 1, '4': 1, '5': 13, '10': 'newSize'},
    {'1': 'wallet', '3': 2, '4': 1, '5': 9, '10': 'wallet'},
  ],
};

/// Descriptor for `KeyPoolRefillRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List keyPoolRefillRequestDescriptor = $convert.base64Decode(
    'ChRLZXlQb29sUmVmaWxsUmVxdWVzdBIZCghuZXdfc2l6ZRgBIAEoDVIHbmV3U2l6ZRIWCgZ3YW'
    'xsZXQYAiABKAlSBndhbGxldA==');

@$core.Deprecated('Use keyPoolRefillResponseDescriptor instead')
const KeyPoolRefillResponse$json = {
  '1': 'KeyPoolRefillResponse',
};

/// Descriptor for `KeyPoolRefillResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List keyPoolRefillResponseDescriptor = $convert.base64Decode(
    'ChVLZXlQb29sUmVmaWxsUmVzcG9uc2U=');

@$core.Deprecated('Use getAccountRequestDescriptor instead')
const GetAccountRequest$json = {
  '1': 'GetAccountRequest',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'wallet', '3': 2, '4': 1, '5': 9, '10': 'wallet'},
  ],
};

/// Descriptor for `GetAccountRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAccountRequestDescriptor = $convert.base64Decode(
    'ChFHZXRBY2NvdW50UmVxdWVzdBIYCgdhZGRyZXNzGAEgASgJUgdhZGRyZXNzEhYKBndhbGxldB'
    'gCIAEoCVIGd2FsbGV0');

@$core.Deprecated('Use getAccountResponseDescriptor instead')
const GetAccountResponse$json = {
  '1': 'GetAccountResponse',
  '2': [
    {'1': 'account', '3': 1, '4': 1, '5': 9, '10': 'account'},
  ],
};

/// Descriptor for `GetAccountResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAccountResponseDescriptor = $convert.base64Decode(
    'ChJHZXRBY2NvdW50UmVzcG9uc2USGAoHYWNjb3VudBgBIAEoCVIHYWNjb3VudA==');

@$core.Deprecated('Use setAccountRequestDescriptor instead')
const SetAccountRequest$json = {
  '1': 'SetAccountRequest',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'account', '3': 2, '4': 1, '5': 9, '10': 'account'},
    {'1': 'wallet', '3': 3, '4': 1, '5': 9, '10': 'wallet'},
  ],
};

/// Descriptor for `SetAccountRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setAccountRequestDescriptor = $convert.base64Decode(
    'ChFTZXRBY2NvdW50UmVxdWVzdBIYCgdhZGRyZXNzGAEgASgJUgdhZGRyZXNzEhgKB2FjY291bn'
    'QYAiABKAlSB2FjY291bnQSFgoGd2FsbGV0GAMgASgJUgZ3YWxsZXQ=');

@$core.Deprecated('Use setAccountResponseDescriptor instead')
const SetAccountResponse$json = {
  '1': 'SetAccountResponse',
};

/// Descriptor for `SetAccountResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setAccountResponseDescriptor = $convert.base64Decode(
    'ChJTZXRBY2NvdW50UmVzcG9uc2U=');

@$core.Deprecated('Use getAddressesByAccountRequestDescriptor instead')
const GetAddressesByAccountRequest$json = {
  '1': 'GetAddressesByAccountRequest',
  '2': [
    {'1': 'account', '3': 1, '4': 1, '5': 9, '10': 'account'},
    {'1': 'wallet', '3': 2, '4': 1, '5': 9, '10': 'wallet'},
  ],
};

/// Descriptor for `GetAddressesByAccountRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAddressesByAccountRequestDescriptor = $convert.base64Decode(
    'ChxHZXRBZGRyZXNzZXNCeUFjY291bnRSZXF1ZXN0EhgKB2FjY291bnQYASABKAlSB2FjY291bn'
    'QSFgoGd2FsbGV0GAIgASgJUgZ3YWxsZXQ=');

@$core.Deprecated('Use getAddressesByAccountResponseDescriptor instead')
const GetAddressesByAccountResponse$json = {
  '1': 'GetAddressesByAccountResponse',
  '2': [
    {'1': 'addresses', '3': 1, '4': 3, '5': 9, '10': 'addresses'},
  ],
};

/// Descriptor for `GetAddressesByAccountResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAddressesByAccountResponseDescriptor = $convert.base64Decode(
    'Ch1HZXRBZGRyZXNzZXNCeUFjY291bnRSZXNwb25zZRIcCglhZGRyZXNzZXMYASADKAlSCWFkZH'
    'Jlc3Nlcw==');

@$core.Deprecated('Use listAccountsRequestDescriptor instead')
const ListAccountsRequest$json = {
  '1': 'ListAccountsRequest',
  '2': [
    {'1': 'min_conf', '3': 1, '4': 1, '5': 5, '10': 'minConf'},
    {'1': 'wallet', '3': 2, '4': 1, '5': 9, '10': 'wallet'},
  ],
};

/// Descriptor for `ListAccountsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listAccountsRequestDescriptor = $convert.base64Decode(
    'ChNMaXN0QWNjb3VudHNSZXF1ZXN0EhkKCG1pbl9jb25mGAEgASgFUgdtaW5Db25mEhYKBndhbG'
    'xldBgCIAEoCVIGd2FsbGV0');

@$core.Deprecated('Use listAccountsResponseDescriptor instead')
const ListAccountsResponse$json = {
  '1': 'ListAccountsResponse',
  '2': [
    {'1': 'accounts', '3': 1, '4': 3, '5': 11, '6': '.bitcoind.v1.ListAccountsResponse.AccountsEntry', '10': 'accounts'},
  ],
  '3': [ListAccountsResponse_AccountsEntry$json],
};

@$core.Deprecated('Use listAccountsResponseDescriptor instead')
const ListAccountsResponse_AccountsEntry$json = {
  '1': 'AccountsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 1, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `ListAccountsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listAccountsResponseDescriptor = $convert.base64Decode(
    'ChRMaXN0QWNjb3VudHNSZXNwb25zZRJLCghhY2NvdW50cxgBIAMoCzIvLmJpdGNvaW5kLnYxLk'
    'xpc3RBY2NvdW50c1Jlc3BvbnNlLkFjY291bnRzRW50cnlSCGFjY291bnRzGjsKDUFjY291bnRz'
    'RW50cnkSEAoDa2V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAiABKAFSBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use addMultisigAddressRequestDescriptor instead')
const AddMultisigAddressRequest$json = {
  '1': 'AddMultisigAddressRequest',
  '2': [
    {'1': 'required_sigs', '3': 1, '4': 1, '5': 5, '10': 'requiredSigs'},
    {'1': 'keys', '3': 2, '4': 3, '5': 9, '10': 'keys'},
    {'1': 'label', '3': 3, '4': 1, '5': 9, '10': 'label'},
    {'1': 'wallet', '3': 4, '4': 1, '5': 9, '10': 'wallet'},
  ],
};

/// Descriptor for `AddMultisigAddressRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addMultisigAddressRequestDescriptor = $convert.base64Decode(
    'ChlBZGRNdWx0aXNpZ0FkZHJlc3NSZXF1ZXN0EiMKDXJlcXVpcmVkX3NpZ3MYASABKAVSDHJlcX'
    'VpcmVkU2lncxISCgRrZXlzGAIgAygJUgRrZXlzEhQKBWxhYmVsGAMgASgJUgVsYWJlbBIWCgZ3'
    'YWxsZXQYBCABKAlSBndhbGxldA==');

@$core.Deprecated('Use addMultisigAddressResponseDescriptor instead')
const AddMultisigAddressResponse$json = {
  '1': 'AddMultisigAddressResponse',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
  ],
};

/// Descriptor for `AddMultisigAddressResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addMultisigAddressResponseDescriptor = $convert.base64Decode(
    'ChpBZGRNdWx0aXNpZ0FkZHJlc3NSZXNwb25zZRIYCgdhZGRyZXNzGAEgASgJUgdhZGRyZXNz');

@$core.Deprecated('Use createMultisigRequestDescriptor instead')
const CreateMultisigRequest$json = {
  '1': 'CreateMultisigRequest',
  '2': [
    {'1': 'required_sigs', '3': 1, '4': 1, '5': 5, '10': 'requiredSigs'},
    {'1': 'keys', '3': 2, '4': 3, '5': 9, '10': 'keys'},
  ],
};

/// Descriptor for `CreateMultisigRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createMultisigRequestDescriptor = $convert.base64Decode(
    'ChVDcmVhdGVNdWx0aXNpZ1JlcXVlc3QSIwoNcmVxdWlyZWRfc2lncxgBIAEoBVIMcmVxdWlyZW'
    'RTaWdzEhIKBGtleXMYAiADKAlSBGtleXM=');

@$core.Deprecated('Use createMultisigResponseDescriptor instead')
const CreateMultisigResponse$json = {
  '1': 'CreateMultisigResponse',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'redeem_script', '3': 2, '4': 1, '5': 9, '10': 'redeemScript'},
  ],
};

/// Descriptor for `CreateMultisigResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createMultisigResponseDescriptor = $convert.base64Decode(
    'ChZDcmVhdGVNdWx0aXNpZ1Jlc3BvbnNlEhgKB2FkZHJlc3MYASABKAlSB2FkZHJlc3MSIwoNcm'
    'VkZWVtX3NjcmlwdBgCIAEoCVIMcmVkZWVtU2NyaXB0');

@$core.Deprecated('Use createPsbtRequestDescriptor instead')
const CreatePsbtRequest$json = {
  '1': 'CreatePsbtRequest',
  '2': [
    {'1': 'inputs', '3': 1, '4': 3, '5': 11, '6': '.bitcoind.v1.CreatePsbtRequest.Input', '10': 'inputs'},
    {'1': 'outputs', '3': 2, '4': 3, '5': 11, '6': '.bitcoind.v1.CreatePsbtRequest.OutputsEntry', '10': 'outputs'},
    {'1': 'locktime', '3': 3, '4': 1, '5': 13, '10': 'locktime'},
    {'1': 'replaceable', '3': 4, '4': 1, '5': 8, '10': 'replaceable'},
  ],
  '3': [CreatePsbtRequest_Input$json, CreatePsbtRequest_OutputsEntry$json],
};

@$core.Deprecated('Use createPsbtRequestDescriptor instead')
const CreatePsbtRequest_Input$json = {
  '1': 'Input',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'vout', '3': 2, '4': 1, '5': 13, '10': 'vout'},
    {'1': 'sequence', '3': 3, '4': 1, '5': 13, '10': 'sequence'},
  ],
};

@$core.Deprecated('Use createPsbtRequestDescriptor instead')
const CreatePsbtRequest_OutputsEntry$json = {
  '1': 'OutputsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 1, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `CreatePsbtRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createPsbtRequestDescriptor = $convert.base64Decode(
    'ChFDcmVhdGVQc2J0UmVxdWVzdBI8CgZpbnB1dHMYASADKAsyJC5iaXRjb2luZC52MS5DcmVhdG'
    'VQc2J0UmVxdWVzdC5JbnB1dFIGaW5wdXRzEkUKB291dHB1dHMYAiADKAsyKy5iaXRjb2luZC52'
    'MS5DcmVhdGVQc2J0UmVxdWVzdC5PdXRwdXRzRW50cnlSB291dHB1dHMSGgoIbG9ja3RpbWUYAy'
    'ABKA1SCGxvY2t0aW1lEiAKC3JlcGxhY2VhYmxlGAQgASgIUgtyZXBsYWNlYWJsZRpLCgVJbnB1'
    'dBISCgR0eGlkGAEgASgJUgR0eGlkEhIKBHZvdXQYAiABKA1SBHZvdXQSGgoIc2VxdWVuY2UYAy'
    'ABKA1SCHNlcXVlbmNlGjoKDE91dHB1dHNFbnRyeRIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1'
    'ZRgCIAEoAVIFdmFsdWU6AjgB');

@$core.Deprecated('Use createPsbtResponseDescriptor instead')
const CreatePsbtResponse$json = {
  '1': 'CreatePsbtResponse',
  '2': [
    {'1': 'psbt', '3': 1, '4': 1, '5': 9, '10': 'psbt'},
  ],
};

/// Descriptor for `CreatePsbtResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createPsbtResponseDescriptor = $convert.base64Decode(
    'ChJDcmVhdGVQc2J0UmVzcG9uc2USEgoEcHNidBgBIAEoCVIEcHNidA==');

@$core.Deprecated('Use decodePsbtRequestDescriptor instead')
const DecodePsbtRequest$json = {
  '1': 'DecodePsbtRequest',
  '2': [
    {'1': 'psbt', '3': 1, '4': 1, '5': 9, '10': 'psbt'},
  ],
};

/// Descriptor for `DecodePsbtRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List decodePsbtRequestDescriptor = $convert.base64Decode(
    'ChFEZWNvZGVQc2J0UmVxdWVzdBISCgRwc2J0GAEgASgJUgRwc2J0');

@$core.Deprecated('Use decodeRawTransactionResponseDescriptor instead')
const DecodeRawTransactionResponse$json = {
  '1': 'DecodeRawTransactionResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'hash', '3': 2, '4': 1, '5': 9, '10': 'hash'},
    {'1': 'size', '3': 3, '4': 1, '5': 13, '10': 'size'},
    {'1': 'virtual_size', '3': 4, '4': 1, '5': 13, '10': 'virtualSize'},
    {'1': 'weight', '3': 5, '4': 1, '5': 13, '10': 'weight'},
    {'1': 'version', '3': 6, '4': 1, '5': 13, '10': 'version'},
    {'1': 'locktime', '3': 7, '4': 1, '5': 13, '10': 'locktime'},
    {'1': 'inputs', '3': 8, '4': 3, '5': 11, '6': '.bitcoind.v1.Input', '10': 'inputs'},
    {'1': 'outputs', '3': 9, '4': 3, '5': 11, '6': '.bitcoind.v1.Output', '10': 'outputs'},
  ],
};

/// Descriptor for `DecodeRawTransactionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List decodeRawTransactionResponseDescriptor = $convert.base64Decode(
    'ChxEZWNvZGVSYXdUcmFuc2FjdGlvblJlc3BvbnNlEhIKBHR4aWQYASABKAlSBHR4aWQSEgoEaG'
    'FzaBgCIAEoCVIEaGFzaBISCgRzaXplGAMgASgNUgRzaXplEiEKDHZpcnR1YWxfc2l6ZRgEIAEo'
    'DVILdmlydHVhbFNpemUSFgoGd2VpZ2h0GAUgASgNUgZ3ZWlnaHQSGAoHdmVyc2lvbhgGIAEoDV'
    'IHdmVyc2lvbhIaCghsb2NrdGltZRgHIAEoDVIIbG9ja3RpbWUSKgoGaW5wdXRzGAggAygLMhIu'
    'Yml0Y29pbmQudjEuSW5wdXRSBmlucHV0cxItCgdvdXRwdXRzGAkgAygLMhMuYml0Y29pbmQudj'
    'EuT3V0cHV0UgdvdXRwdXRz');

@$core.Deprecated('Use decodePsbtResponseDescriptor instead')
const DecodePsbtResponse$json = {
  '1': 'DecodePsbtResponse',
  '2': [
    {'1': 'tx', '3': 1, '4': 1, '5': 11, '6': '.bitcoind.v1.DecodeRawTransactionResponse', '10': 'tx'},
    {'1': 'unknown', '3': 2, '4': 3, '5': 11, '6': '.bitcoind.v1.DecodePsbtResponse.UnknownEntry', '10': 'unknown'},
    {'1': 'inputs', '3': 3, '4': 3, '5': 11, '6': '.bitcoind.v1.DecodePsbtResponse.Input', '10': 'inputs'},
    {'1': 'outputs', '3': 4, '4': 3, '5': 11, '6': '.bitcoind.v1.DecodePsbtResponse.Output', '10': 'outputs'},
    {'1': 'fee', '3': 5, '4': 1, '5': 1, '10': 'fee'},
  ],
  '3': [DecodePsbtResponse_WitnessUtxo$json, DecodePsbtResponse_RedeemScript$json, DecodePsbtResponse_Bip32Deriv$json, DecodePsbtResponse_Input$json, DecodePsbtResponse_Output$json, DecodePsbtResponse_UnknownEntry$json],
};

@$core.Deprecated('Use decodePsbtResponseDescriptor instead')
const DecodePsbtResponse_WitnessUtxo$json = {
  '1': 'WitnessUtxo',
  '2': [
    {'1': 'amount', '3': 1, '4': 1, '5': 1, '10': 'amount'},
    {'1': 'script_pub_key', '3': 2, '4': 1, '5': 11, '6': '.bitcoind.v1.ScriptPubKey', '10': 'scriptPubKey'},
  ],
};

@$core.Deprecated('Use decodePsbtResponseDescriptor instead')
const DecodePsbtResponse_RedeemScript$json = {
  '1': 'RedeemScript',
  '2': [
    {'1': 'asm', '3': 1, '4': 1, '5': 9, '10': 'asm'},
    {'1': 'hex', '3': 2, '4': 1, '5': 9, '10': 'hex'},
    {'1': 'type', '3': 3, '4': 1, '5': 9, '10': 'type'},
  ],
};

@$core.Deprecated('Use decodePsbtResponseDescriptor instead')
const DecodePsbtResponse_Bip32Deriv$json = {
  '1': 'Bip32Deriv',
  '2': [
    {'1': 'pubkey', '3': 1, '4': 1, '5': 9, '10': 'pubkey'},
    {'1': 'master_fingerprint', '3': 2, '4': 1, '5': 9, '10': 'masterFingerprint'},
    {'1': 'path', '3': 3, '4': 1, '5': 9, '10': 'path'},
  ],
};

@$core.Deprecated('Use decodePsbtResponseDescriptor instead')
const DecodePsbtResponse_Input$json = {
  '1': 'Input',
  '2': [
    {'1': 'non_witness_utxo', '3': 1, '4': 1, '5': 11, '6': '.bitcoind.v1.DecodeRawTransactionResponse', '10': 'nonWitnessUtxo'},
    {'1': 'witness_utxo', '3': 2, '4': 1, '5': 11, '6': '.bitcoind.v1.DecodePsbtResponse.WitnessUtxo', '10': 'witnessUtxo'},
    {'1': 'partial_signatures', '3': 3, '4': 3, '5': 11, '6': '.bitcoind.v1.DecodePsbtResponse.Input.PartialSignaturesEntry', '10': 'partialSignatures'},
    {'1': 'sighash', '3': 4, '4': 1, '5': 9, '10': 'sighash'},
    {'1': 'redeem_script', '3': 5, '4': 1, '5': 11, '6': '.bitcoind.v1.DecodePsbtResponse.RedeemScript', '10': 'redeemScript'},
    {'1': 'witness_script', '3': 6, '4': 1, '5': 11, '6': '.bitcoind.v1.DecodePsbtResponse.RedeemScript', '10': 'witnessScript'},
    {'1': 'bip32_derivs', '3': 7, '4': 3, '5': 11, '6': '.bitcoind.v1.DecodePsbtResponse.Bip32Deriv', '10': 'bip32Derivs'},
    {'1': 'final_scriptsig', '3': 8, '4': 1, '5': 11, '6': '.bitcoind.v1.ScriptSig', '10': 'finalScriptsig'},
    {'1': 'final_scriptwitness', '3': 9, '4': 3, '5': 9, '10': 'finalScriptwitness'},
    {'1': 'unknown', '3': 10, '4': 3, '5': 11, '6': '.bitcoind.v1.DecodePsbtResponse.Input.UnknownEntry', '10': 'unknown'},
  ],
  '3': [DecodePsbtResponse_Input_PartialSignaturesEntry$json, DecodePsbtResponse_Input_UnknownEntry$json],
};

@$core.Deprecated('Use decodePsbtResponseDescriptor instead')
const DecodePsbtResponse_Input_PartialSignaturesEntry$json = {
  '1': 'PartialSignaturesEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use decodePsbtResponseDescriptor instead')
const DecodePsbtResponse_Input_UnknownEntry$json = {
  '1': 'UnknownEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use decodePsbtResponseDescriptor instead')
const DecodePsbtResponse_Output$json = {
  '1': 'Output',
  '2': [
    {'1': 'redeem_script', '3': 1, '4': 1, '5': 11, '6': '.bitcoind.v1.DecodePsbtResponse.RedeemScript', '10': 'redeemScript'},
    {'1': 'witness_script', '3': 2, '4': 1, '5': 11, '6': '.bitcoind.v1.DecodePsbtResponse.RedeemScript', '10': 'witnessScript'},
    {'1': 'bip32_derivs', '3': 3, '4': 3, '5': 11, '6': '.bitcoind.v1.DecodePsbtResponse.Bip32Deriv', '10': 'bip32Derivs'},
    {'1': 'unknown', '3': 4, '4': 3, '5': 11, '6': '.bitcoind.v1.DecodePsbtResponse.Output.UnknownEntry', '10': 'unknown'},
  ],
  '3': [DecodePsbtResponse_Output_UnknownEntry$json],
};

@$core.Deprecated('Use decodePsbtResponseDescriptor instead')
const DecodePsbtResponse_Output_UnknownEntry$json = {
  '1': 'UnknownEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use decodePsbtResponseDescriptor instead')
const DecodePsbtResponse_UnknownEntry$json = {
  '1': 'UnknownEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `DecodePsbtResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List decodePsbtResponseDescriptor = $convert.base64Decode(
    'ChJEZWNvZGVQc2J0UmVzcG9uc2USOQoCdHgYASABKAsyKS5iaXRjb2luZC52MS5EZWNvZGVSYX'
    'dUcmFuc2FjdGlvblJlc3BvbnNlUgJ0eBJGCgd1bmtub3duGAIgAygLMiwuYml0Y29pbmQudjEu'
    'RGVjb2RlUHNidFJlc3BvbnNlLlVua25vd25FbnRyeVIHdW5rbm93bhI9CgZpbnB1dHMYAyADKA'
    'syJS5iaXRjb2luZC52MS5EZWNvZGVQc2J0UmVzcG9uc2UuSW5wdXRSBmlucHV0cxJACgdvdXRw'
    'dXRzGAQgAygLMiYuYml0Y29pbmQudjEuRGVjb2RlUHNidFJlc3BvbnNlLk91dHB1dFIHb3V0cH'
    'V0cxIQCgNmZWUYBSABKAFSA2ZlZRpmCgtXaXRuZXNzVXR4bxIWCgZhbW91bnQYASABKAFSBmFt'
    'b3VudBI/Cg5zY3JpcHRfcHViX2tleRgCIAEoCzIZLmJpdGNvaW5kLnYxLlNjcmlwdFB1YktleV'
    'IMc2NyaXB0UHViS2V5GkYKDFJlZGVlbVNjcmlwdBIQCgNhc20YASABKAlSA2FzbRIQCgNoZXgY'
    'AiABKAlSA2hleBISCgR0eXBlGAMgASgJUgR0eXBlGmcKCkJpcDMyRGVyaXYSFgoGcHVia2V5GA'
    'EgASgJUgZwdWJrZXkSLQoSbWFzdGVyX2ZpbmdlcnByaW50GAIgASgJUhFtYXN0ZXJGaW5nZXJw'
    'cmludBISCgRwYXRoGAMgASgJUgRwYXRoGuwGCgVJbnB1dBJTChBub25fd2l0bmVzc191dHhvGA'
    'EgASgLMikuYml0Y29pbmQudjEuRGVjb2RlUmF3VHJhbnNhY3Rpb25SZXNwb25zZVIObm9uV2l0'
    'bmVzc1V0eG8STgoMd2l0bmVzc191dHhvGAIgASgLMisuYml0Y29pbmQudjEuRGVjb2RlUHNidF'
    'Jlc3BvbnNlLldpdG5lc3NVdHhvUgt3aXRuZXNzVXR4bxJrChJwYXJ0aWFsX3NpZ25hdHVyZXMY'
    'AyADKAsyPC5iaXRjb2luZC52MS5EZWNvZGVQc2J0UmVzcG9uc2UuSW5wdXQuUGFydGlhbFNpZ2'
    '5hdHVyZXNFbnRyeVIRcGFydGlhbFNpZ25hdHVyZXMSGAoHc2lnaGFzaBgEIAEoCVIHc2lnaGFz'
    'aBJRCg1yZWRlZW1fc2NyaXB0GAUgASgLMiwuYml0Y29pbmQudjEuRGVjb2RlUHNidFJlc3Bvbn'
    'NlLlJlZGVlbVNjcmlwdFIMcmVkZWVtU2NyaXB0ElMKDndpdG5lc3Nfc2NyaXB0GAYgASgLMiwu'
    'Yml0Y29pbmQudjEuRGVjb2RlUHNidFJlc3BvbnNlLlJlZGVlbVNjcmlwdFINd2l0bmVzc1Njcm'
    'lwdBJNCgxiaXAzMl9kZXJpdnMYByADKAsyKi5iaXRjb2luZC52MS5EZWNvZGVQc2J0UmVzcG9u'
    'c2UuQmlwMzJEZXJpdlILYmlwMzJEZXJpdnMSPwoPZmluYWxfc2NyaXB0c2lnGAggASgLMhYuYm'
    'l0Y29pbmQudjEuU2NyaXB0U2lnUg5maW5hbFNjcmlwdHNpZxIvChNmaW5hbF9zY3JpcHR3aXRu'
    'ZXNzGAkgAygJUhJmaW5hbFNjcmlwdHdpdG5lc3MSTAoHdW5rbm93bhgKIAMoCzIyLmJpdGNvaW'
    '5kLnYxLkRlY29kZVBzYnRSZXNwb25zZS5JbnB1dC5Vbmtub3duRW50cnlSB3Vua25vd24aRAoW'
    'UGFydGlhbFNpZ25hdHVyZXNFbnRyeRIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1ZRgCIAEoCV'
    'IFdmFsdWU6AjgBGjoKDFVua25vd25FbnRyeRIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1ZRgC'
    'IAEoCVIFdmFsdWU6AjgBGooDCgZPdXRwdXQSUQoNcmVkZWVtX3NjcmlwdBgBIAEoCzIsLmJpdG'
    'NvaW5kLnYxLkRlY29kZVBzYnRSZXNwb25zZS5SZWRlZW1TY3JpcHRSDHJlZGVlbVNjcmlwdBJT'
    'Cg53aXRuZXNzX3NjcmlwdBgCIAEoCzIsLmJpdGNvaW5kLnYxLkRlY29kZVBzYnRSZXNwb25zZS'
    '5SZWRlZW1TY3JpcHRSDXdpdG5lc3NTY3JpcHQSTQoMYmlwMzJfZGVyaXZzGAMgAygLMiouYml0'
    'Y29pbmQudjEuRGVjb2RlUHNidFJlc3BvbnNlLkJpcDMyRGVyaXZSC2JpcDMyRGVyaXZzEk0KB3'
    'Vua25vd24YBCADKAsyMy5iaXRjb2luZC52MS5EZWNvZGVQc2J0UmVzcG9uc2UuT3V0cHV0LlVu'
    'a25vd25FbnRyeVIHdW5rbm93bho6CgxVbmtub3duRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSFA'
    'oFdmFsdWUYAiABKAlSBXZhbHVlOgI4ARo6CgxVbmtub3duRW50cnkSEAoDa2V5GAEgASgJUgNr'
    'ZXkSFAoFdmFsdWUYAiABKAlSBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use analyzePsbtRequestDescriptor instead')
const AnalyzePsbtRequest$json = {
  '1': 'AnalyzePsbtRequest',
  '2': [
    {'1': 'psbt', '3': 1, '4': 1, '5': 9, '10': 'psbt'},
  ],
};

/// Descriptor for `AnalyzePsbtRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List analyzePsbtRequestDescriptor = $convert.base64Decode(
    'ChJBbmFseXplUHNidFJlcXVlc3QSEgoEcHNidBgBIAEoCVIEcHNidA==');

@$core.Deprecated('Use analyzePsbtResponseDescriptor instead')
const AnalyzePsbtResponse$json = {
  '1': 'AnalyzePsbtResponse',
  '2': [
    {'1': 'inputs', '3': 1, '4': 3, '5': 11, '6': '.bitcoind.v1.AnalyzePsbtResponse.Input', '10': 'inputs'},
    {'1': 'estimated_vsize', '3': 2, '4': 1, '5': 1, '10': 'estimatedVsize'},
    {'1': 'estimated_feerate', '3': 3, '4': 1, '5': 1, '10': 'estimatedFeerate'},
    {'1': 'fee', '3': 4, '4': 1, '5': 1, '10': 'fee'},
    {'1': 'next', '3': 5, '4': 1, '5': 9, '10': 'next'},
    {'1': 'error', '3': 6, '4': 1, '5': 9, '10': 'error'},
  ],
  '3': [AnalyzePsbtResponse_Input$json],
};

@$core.Deprecated('Use analyzePsbtResponseDescriptor instead')
const AnalyzePsbtResponse_Input$json = {
  '1': 'Input',
  '2': [
    {'1': 'has_utxo', '3': 1, '4': 1, '5': 8, '10': 'hasUtxo'},
    {'1': 'is_final', '3': 2, '4': 1, '5': 8, '10': 'isFinal'},
    {'1': 'missing', '3': 3, '4': 1, '5': 11, '6': '.bitcoind.v1.AnalyzePsbtResponse.Input.Missing', '10': 'missing'},
    {'1': 'next', '3': 4, '4': 1, '5': 9, '10': 'next'},
  ],
  '3': [AnalyzePsbtResponse_Input_Missing$json],
};

@$core.Deprecated('Use analyzePsbtResponseDescriptor instead')
const AnalyzePsbtResponse_Input_Missing$json = {
  '1': 'Missing',
  '2': [
    {'1': 'pubkeys', '3': 1, '4': 3, '5': 9, '10': 'pubkeys'},
    {'1': 'signatures', '3': 2, '4': 3, '5': 9, '10': 'signatures'},
    {'1': 'redeem_script', '3': 3, '4': 1, '5': 9, '10': 'redeemScript'},
    {'1': 'witness_script', '3': 4, '4': 1, '5': 9, '10': 'witnessScript'},
  ],
};

/// Descriptor for `AnalyzePsbtResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List analyzePsbtResponseDescriptor = $convert.base64Decode(
    'ChNBbmFseXplUHNidFJlc3BvbnNlEj4KBmlucHV0cxgBIAMoCzImLmJpdGNvaW5kLnYxLkFuYW'
    'x5emVQc2J0UmVzcG9uc2UuSW5wdXRSBmlucHV0cxInCg9lc3RpbWF0ZWRfdnNpemUYAiABKAFS'
    'DmVzdGltYXRlZFZzaXplEisKEWVzdGltYXRlZF9mZWVyYXRlGAMgASgBUhBlc3RpbWF0ZWRGZW'
    'VyYXRlEhAKA2ZlZRgEIAEoAVIDZmVlEhIKBG5leHQYBSABKAlSBG5leHQSFAoFZXJyb3IYBiAB'
    'KAlSBWVycm9yGq0CCgVJbnB1dBIZCghoYXNfdXR4bxgBIAEoCFIHaGFzVXR4bxIZCghpc19maW'
    '5hbBgCIAEoCFIHaXNGaW5hbBJICgdtaXNzaW5nGAMgASgLMi4uYml0Y29pbmQudjEuQW5hbHl6'
    'ZVBzYnRSZXNwb25zZS5JbnB1dC5NaXNzaW5nUgdtaXNzaW5nEhIKBG5leHQYBCABKAlSBG5leH'
    'QajwEKB01pc3NpbmcSGAoHcHVia2V5cxgBIAMoCVIHcHVia2V5cxIeCgpzaWduYXR1cmVzGAIg'
    'AygJUgpzaWduYXR1cmVzEiMKDXJlZGVlbV9zY3JpcHQYAyABKAlSDHJlZGVlbVNjcmlwdBIlCg'
    '53aXRuZXNzX3NjcmlwdBgEIAEoCVINd2l0bmVzc1NjcmlwdA==');

@$core.Deprecated('Use combinePsbtRequestDescriptor instead')
const CombinePsbtRequest$json = {
  '1': 'CombinePsbtRequest',
  '2': [
    {'1': 'psbts', '3': 1, '4': 3, '5': 9, '10': 'psbts'},
  ],
};

/// Descriptor for `CombinePsbtRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List combinePsbtRequestDescriptor = $convert.base64Decode(
    'ChJDb21iaW5lUHNidFJlcXVlc3QSFAoFcHNidHMYASADKAlSBXBzYnRz');

@$core.Deprecated('Use combinePsbtResponseDescriptor instead')
const CombinePsbtResponse$json = {
  '1': 'CombinePsbtResponse',
  '2': [
    {'1': 'psbt', '3': 1, '4': 1, '5': 9, '10': 'psbt'},
  ],
};

/// Descriptor for `CombinePsbtResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List combinePsbtResponseDescriptor = $convert.base64Decode(
    'ChNDb21iaW5lUHNidFJlc3BvbnNlEhIKBHBzYnQYASABKAlSBHBzYnQ=');

@$core.Deprecated('Use utxoUpdatePsbtRequestDescriptor instead')
const UtxoUpdatePsbtRequest$json = {
  '1': 'UtxoUpdatePsbtRequest',
  '2': [
    {'1': 'psbt', '3': 1, '4': 1, '5': 9, '10': 'psbt'},
    {'1': 'descriptors', '3': 2, '4': 3, '5': 11, '6': '.bitcoind.v1.Descriptor', '10': 'descriptors'},
  ],
};

/// Descriptor for `UtxoUpdatePsbtRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List utxoUpdatePsbtRequestDescriptor = $convert.base64Decode(
    'ChVVdHhvVXBkYXRlUHNidFJlcXVlc3QSEgoEcHNidBgBIAEoCVIEcHNidBI5CgtkZXNjcmlwdG'
    '9ycxgCIAMoCzIXLmJpdGNvaW5kLnYxLkRlc2NyaXB0b3JSC2Rlc2NyaXB0b3Jz');

@$core.Deprecated('Use utxoUpdatePsbtResponseDescriptor instead')
const UtxoUpdatePsbtResponse$json = {
  '1': 'UtxoUpdatePsbtResponse',
  '2': [
    {'1': 'psbt', '3': 1, '4': 1, '5': 9, '10': 'psbt'},
  ],
};

/// Descriptor for `UtxoUpdatePsbtResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List utxoUpdatePsbtResponseDescriptor = $convert.base64Decode(
    'ChZVdHhvVXBkYXRlUHNidFJlc3BvbnNlEhIKBHBzYnQYASABKAlSBHBzYnQ=');

@$core.Deprecated('Use joinPsbtsRequestDescriptor instead')
const JoinPsbtsRequest$json = {
  '1': 'JoinPsbtsRequest',
  '2': [
    {'1': 'psbts', '3': 1, '4': 3, '5': 9, '10': 'psbts'},
  ],
};

/// Descriptor for `JoinPsbtsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List joinPsbtsRequestDescriptor = $convert.base64Decode(
    'ChBKb2luUHNidHNSZXF1ZXN0EhQKBXBzYnRzGAEgAygJUgVwc2J0cw==');

@$core.Deprecated('Use joinPsbtsResponseDescriptor instead')
const JoinPsbtsResponse$json = {
  '1': 'JoinPsbtsResponse',
  '2': [
    {'1': 'psbt', '3': 1, '4': 1, '5': 9, '10': 'psbt'},
  ],
};

/// Descriptor for `JoinPsbtsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List joinPsbtsResponseDescriptor = $convert.base64Decode(
    'ChFKb2luUHNidHNSZXNwb25zZRISCgRwc2J0GAEgASgJUgRwc2J0');

@$core.Deprecated('Use testMempoolAcceptRequestDescriptor instead')
const TestMempoolAcceptRequest$json = {
  '1': 'TestMempoolAcceptRequest',
  '2': [
    {'1': 'rawtxs', '3': 1, '4': 3, '5': 9, '10': 'rawtxs'},
    {'1': 'max_fee_rate', '3': 2, '4': 1, '5': 1, '10': 'maxFeeRate'},
  ],
};

/// Descriptor for `TestMempoolAcceptRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List testMempoolAcceptRequestDescriptor = $convert.base64Decode(
    'ChhUZXN0TWVtcG9vbEFjY2VwdFJlcXVlc3QSFgoGcmF3dHhzGAEgAygJUgZyYXd0eHMSIAoMbW'
    'F4X2ZlZV9yYXRlGAIgASgBUgptYXhGZWVSYXRl');

@$core.Deprecated('Use testMempoolAcceptResponseDescriptor instead')
const TestMempoolAcceptResponse$json = {
  '1': 'TestMempoolAcceptResponse',
  '2': [
    {'1': 'results', '3': 1, '4': 3, '5': 11, '6': '.bitcoind.v1.TestMempoolAcceptResponse.Result', '10': 'results'},
  ],
  '3': [TestMempoolAcceptResponse_Result$json],
};

@$core.Deprecated('Use testMempoolAcceptResponseDescriptor instead')
const TestMempoolAcceptResponse_Result$json = {
  '1': 'Result',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'allowed', '3': 2, '4': 1, '5': 8, '10': 'allowed'},
    {'1': 'reject_reason', '3': 3, '4': 1, '5': 9, '10': 'rejectReason'},
    {'1': 'vsize', '3': 4, '4': 1, '5': 13, '10': 'vsize'},
    {'1': 'fees', '3': 5, '4': 1, '5': 1, '10': 'fees'},
  ],
};

/// Descriptor for `TestMempoolAcceptResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List testMempoolAcceptResponseDescriptor = $convert.base64Decode(
    'ChlUZXN0TWVtcG9vbEFjY2VwdFJlc3BvbnNlEkcKB3Jlc3VsdHMYASADKAsyLS5iaXRjb2luZC'
    '52MS5UZXN0TWVtcG9vbEFjY2VwdFJlc3BvbnNlLlJlc3VsdFIHcmVzdWx0cxqFAQoGUmVzdWx0'
    'EhIKBHR4aWQYASABKAlSBHR4aWQSGAoHYWxsb3dlZBgCIAEoCFIHYWxsb3dlZBIjCg1yZWplY3'
    'RfcmVhc29uGAMgASgJUgxyZWplY3RSZWFzb24SFAoFdnNpemUYBCABKA1SBXZzaXplEhIKBGZl'
    'ZXMYBSABKAFSBGZlZXM=');

@$core.Deprecated('Use descriptorRangeDescriptor instead')
const DescriptorRange$json = {
  '1': 'DescriptorRange',
  '2': [
    {'1': 'end', '3': 1, '4': 1, '5': 5, '9': 0, '10': 'end'},
    {'1': 'range', '3': 2, '4': 1, '5': 11, '6': '.bitcoind.v1.Range', '9': 0, '10': 'range'},
  ],
  '8': [
    {'1': 'range_type'},
  ],
};

/// Descriptor for `DescriptorRange`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List descriptorRangeDescriptor = $convert.base64Decode(
    'Cg9EZXNjcmlwdG9yUmFuZ2USEgoDZW5kGAEgASgFSABSA2VuZBIqCgVyYW5nZRgCIAEoCzISLm'
    'JpdGNvaW5kLnYxLlJhbmdlSABSBXJhbmdlQgwKCnJhbmdlX3R5cGU=');

@$core.Deprecated('Use rangeDescriptor instead')
const Range$json = {
  '1': 'Range',
  '2': [
    {'1': 'begin', '3': 1, '4': 1, '5': 5, '10': 'begin'},
    {'1': 'end', '3': 2, '4': 1, '5': 5, '10': 'end'},
  ],
};

/// Descriptor for `Range`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rangeDescriptor = $convert.base64Decode(
    'CgVSYW5nZRIUCgViZWdpbhgBIAEoBVIFYmVnaW4SEAoDZW5kGAIgASgFUgNlbmQ=');

@$core.Deprecated('Use descriptorDescriptor instead')
const Descriptor$json = {
  '1': 'Descriptor',
  '2': [
    {'1': 'string_descriptor', '3': 1, '4': 1, '5': 9, '9': 0, '10': 'stringDescriptor'},
    {'1': 'object_descriptor', '3': 2, '4': 1, '5': 11, '6': '.bitcoind.v1.DescriptorObject', '9': 0, '10': 'objectDescriptor'},
  ],
  '8': [
    {'1': 'descriptor'},
  ],
};

/// Descriptor for `Descriptor`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List descriptorDescriptor = $convert.base64Decode(
    'CgpEZXNjcmlwdG9yEi0KEXN0cmluZ19kZXNjcmlwdG9yGAEgASgJSABSEHN0cmluZ0Rlc2NyaX'
    'B0b3ISTAoRb2JqZWN0X2Rlc2NyaXB0b3IYAiABKAsyHS5iaXRjb2luZC52MS5EZXNjcmlwdG9y'
    'T2JqZWN0SABSEG9iamVjdERlc2NyaXB0b3JCDAoKZGVzY3JpcHRvcg==');

@$core.Deprecated('Use descriptorObjectDescriptor instead')
const DescriptorObject$json = {
  '1': 'DescriptorObject',
  '2': [
    {'1': 'desc', '3': 1, '4': 1, '5': 9, '10': 'desc'},
    {'1': 'range', '3': 2, '4': 1, '5': 11, '6': '.bitcoind.v1.DescriptorRange', '10': 'range'},
  ],
};

/// Descriptor for `DescriptorObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List descriptorObjectDescriptor = $convert.base64Decode(
    'ChBEZXNjcmlwdG9yT2JqZWN0EhIKBGRlc2MYASABKAlSBGRlc2MSMgoFcmFuZ2UYAiABKAsyHC'
    '5iaXRjb2luZC52MS5EZXNjcmlwdG9yUmFuZ2VSBXJhbmdl');

const $core.Map<$core.String, $core.dynamic> BitcoindServiceBase$json = {
  '1': 'BitcoindService',
  '2': [
    {'1': 'ListRecentTransactions', '2': '.bitcoind.v1.ListRecentTransactionsRequest', '3': '.bitcoind.v1.ListRecentTransactionsResponse'},
    {'1': 'ListBlocks', '2': '.bitcoind.v1.ListBlocksRequest', '3': '.bitcoind.v1.ListBlocksResponse'},
    {'1': 'GetBlock', '2': '.bitcoind.v1.GetBlockRequest', '3': '.bitcoind.v1.GetBlockResponse'},
    {'1': 'GetBlockchainInfo', '2': '.google.protobuf.Empty', '3': '.bitcoind.v1.GetBlockchainInfoResponse'},
    {'1': 'ListPeers', '2': '.google.protobuf.Empty', '3': '.bitcoind.v1.ListPeersResponse'},
    {'1': 'EstimateSmartFee', '2': '.bitcoind.v1.EstimateSmartFeeRequest', '3': '.bitcoind.v1.EstimateSmartFeeResponse'},
    {'1': 'GetRawTransaction', '2': '.bitcoind.v1.GetRawTransactionRequest', '3': '.bitcoind.v1.GetRawTransactionResponse'},
    {'1': 'CreateRawTransaction', '2': '.bitcoind.v1.CreateRawTransactionRequest', '3': '.bitcoind.v1.CreateRawTransactionResponse'},
    {'1': 'CreateWallet', '2': '.bitcoind.v1.CreateWalletRequest', '3': '.bitcoind.v1.CreateWalletResponse'},
    {'1': 'BackupWallet', '2': '.bitcoind.v1.BackupWalletRequest', '3': '.bitcoind.v1.BackupWalletResponse'},
    {'1': 'DumpWallet', '2': '.bitcoind.v1.DumpWalletRequest', '3': '.bitcoind.v1.DumpWalletResponse'},
    {'1': 'ImportWallet', '2': '.bitcoind.v1.ImportWalletRequest', '3': '.bitcoind.v1.ImportWalletResponse'},
    {'1': 'UnloadWallet', '2': '.bitcoind.v1.UnloadWalletRequest', '3': '.bitcoind.v1.UnloadWalletResponse'},
    {'1': 'DumpPrivKey', '2': '.bitcoind.v1.DumpPrivKeyRequest', '3': '.bitcoind.v1.DumpPrivKeyResponse'},
    {'1': 'ImportPrivKey', '2': '.bitcoind.v1.ImportPrivKeyRequest', '3': '.bitcoind.v1.ImportPrivKeyResponse'},
    {'1': 'ImportAddress', '2': '.bitcoind.v1.ImportAddressRequest', '3': '.bitcoind.v1.ImportAddressResponse'},
    {'1': 'ImportPubKey', '2': '.bitcoind.v1.ImportPubKeyRequest', '3': '.bitcoind.v1.ImportPubKeyResponse'},
    {'1': 'KeyPoolRefill', '2': '.bitcoind.v1.KeyPoolRefillRequest', '3': '.bitcoind.v1.KeyPoolRefillResponse'},
    {'1': 'GetAccount', '2': '.bitcoind.v1.GetAccountRequest', '3': '.bitcoind.v1.GetAccountResponse'},
    {'1': 'SetAccount', '2': '.bitcoind.v1.SetAccountRequest', '3': '.bitcoind.v1.SetAccountResponse'},
    {'1': 'GetAddressesByAccount', '2': '.bitcoind.v1.GetAddressesByAccountRequest', '3': '.bitcoind.v1.GetAddressesByAccountResponse'},
    {'1': 'ListAccounts', '2': '.bitcoind.v1.ListAccountsRequest', '3': '.bitcoind.v1.ListAccountsResponse'},
    {'1': 'AddMultisigAddress', '2': '.bitcoind.v1.AddMultisigAddressRequest', '3': '.bitcoind.v1.AddMultisigAddressResponse'},
    {'1': 'CreateMultisig', '2': '.bitcoind.v1.CreateMultisigRequest', '3': '.bitcoind.v1.CreateMultisigResponse'},
    {'1': 'CreatePsbt', '2': '.bitcoind.v1.CreatePsbtRequest', '3': '.bitcoind.v1.CreatePsbtResponse'},
    {'1': 'DecodePsbt', '2': '.bitcoind.v1.DecodePsbtRequest', '3': '.bitcoind.v1.DecodePsbtResponse'},
    {'1': 'AnalyzePsbt', '2': '.bitcoind.v1.AnalyzePsbtRequest', '3': '.bitcoind.v1.AnalyzePsbtResponse'},
    {'1': 'CombinePsbt', '2': '.bitcoind.v1.CombinePsbtRequest', '3': '.bitcoind.v1.CombinePsbtResponse'},
    {'1': 'UtxoUpdatePsbt', '2': '.bitcoind.v1.UtxoUpdatePsbtRequest', '3': '.bitcoind.v1.UtxoUpdatePsbtResponse'},
    {'1': 'JoinPsbts', '2': '.bitcoind.v1.JoinPsbtsRequest', '3': '.bitcoind.v1.JoinPsbtsResponse'},
    {'1': 'TestMempoolAccept', '2': '.bitcoind.v1.TestMempoolAcceptRequest', '3': '.bitcoind.v1.TestMempoolAcceptResponse'},
  ],
};

@$core.Deprecated('Use bitcoindServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> BitcoindServiceBase$messageJson = {
  '.bitcoind.v1.ListRecentTransactionsRequest': ListRecentTransactionsRequest$json,
  '.bitcoind.v1.ListRecentTransactionsResponse': ListRecentTransactionsResponse$json,
  '.bitcoind.v1.RecentTransaction': RecentTransaction$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.bitcoind.v1.Block': Block$json,
  '.bitcoind.v1.ListBlocksRequest': ListBlocksRequest$json,
  '.bitcoind.v1.ListBlocksResponse': ListBlocksResponse$json,
  '.bitcoind.v1.GetBlockRequest': GetBlockRequest$json,
  '.bitcoind.v1.GetBlockResponse': GetBlockResponse$json,
  '.google.protobuf.Empty': $1.Empty$json,
  '.bitcoind.v1.GetBlockchainInfoResponse': GetBlockchainInfoResponse$json,
  '.bitcoind.v1.ListPeersResponse': ListPeersResponse$json,
  '.bitcoind.v1.Peer': Peer$json,
  '.bitcoind.v1.EstimateSmartFeeRequest': EstimateSmartFeeRequest$json,
  '.bitcoind.v1.EstimateSmartFeeResponse': EstimateSmartFeeResponse$json,
  '.bitcoind.v1.GetRawTransactionRequest': GetRawTransactionRequest$json,
  '.bitcoind.v1.GetRawTransactionResponse': GetRawTransactionResponse$json,
  '.bitcoind.v1.RawTransaction': RawTransaction$json,
  '.bitcoind.v1.Input': Input$json,
  '.bitcoind.v1.ScriptSig': ScriptSig$json,
  '.bitcoind.v1.Output': Output$json,
  '.bitcoind.v1.ScriptPubKey': ScriptPubKey$json,
  '.bitcoind.v1.CreateRawTransactionRequest': CreateRawTransactionRequest$json,
  '.bitcoind.v1.CreateRawTransactionRequest.Input': CreateRawTransactionRequest_Input$json,
  '.bitcoind.v1.CreateRawTransactionRequest.OutputsEntry': CreateRawTransactionRequest_OutputsEntry$json,
  '.bitcoind.v1.CreateRawTransactionResponse': CreateRawTransactionResponse$json,
  '.bitcoind.v1.CreateWalletRequest': CreateWalletRequest$json,
  '.bitcoind.v1.CreateWalletResponse': CreateWalletResponse$json,
  '.bitcoind.v1.BackupWalletRequest': BackupWalletRequest$json,
  '.bitcoind.v1.BackupWalletResponse': BackupWalletResponse$json,
  '.bitcoind.v1.DumpWalletRequest': DumpWalletRequest$json,
  '.bitcoind.v1.DumpWalletResponse': DumpWalletResponse$json,
  '.bitcoind.v1.ImportWalletRequest': ImportWalletRequest$json,
  '.bitcoind.v1.ImportWalletResponse': ImportWalletResponse$json,
  '.bitcoind.v1.UnloadWalletRequest': UnloadWalletRequest$json,
  '.bitcoind.v1.UnloadWalletResponse': UnloadWalletResponse$json,
  '.bitcoind.v1.DumpPrivKeyRequest': DumpPrivKeyRequest$json,
  '.bitcoind.v1.DumpPrivKeyResponse': DumpPrivKeyResponse$json,
  '.bitcoind.v1.ImportPrivKeyRequest': ImportPrivKeyRequest$json,
  '.bitcoind.v1.ImportPrivKeyResponse': ImportPrivKeyResponse$json,
  '.bitcoind.v1.ImportAddressRequest': ImportAddressRequest$json,
  '.bitcoind.v1.ImportAddressResponse': ImportAddressResponse$json,
  '.bitcoind.v1.ImportPubKeyRequest': ImportPubKeyRequest$json,
  '.bitcoind.v1.ImportPubKeyResponse': ImportPubKeyResponse$json,
  '.bitcoind.v1.KeyPoolRefillRequest': KeyPoolRefillRequest$json,
  '.bitcoind.v1.KeyPoolRefillResponse': KeyPoolRefillResponse$json,
  '.bitcoind.v1.GetAccountRequest': GetAccountRequest$json,
  '.bitcoind.v1.GetAccountResponse': GetAccountResponse$json,
  '.bitcoind.v1.SetAccountRequest': SetAccountRequest$json,
  '.bitcoind.v1.SetAccountResponse': SetAccountResponse$json,
  '.bitcoind.v1.GetAddressesByAccountRequest': GetAddressesByAccountRequest$json,
  '.bitcoind.v1.GetAddressesByAccountResponse': GetAddressesByAccountResponse$json,
  '.bitcoind.v1.ListAccountsRequest': ListAccountsRequest$json,
  '.bitcoind.v1.ListAccountsResponse': ListAccountsResponse$json,
  '.bitcoind.v1.ListAccountsResponse.AccountsEntry': ListAccountsResponse_AccountsEntry$json,
  '.bitcoind.v1.AddMultisigAddressRequest': AddMultisigAddressRequest$json,
  '.bitcoind.v1.AddMultisigAddressResponse': AddMultisigAddressResponse$json,
  '.bitcoind.v1.CreateMultisigRequest': CreateMultisigRequest$json,
  '.bitcoind.v1.CreateMultisigResponse': CreateMultisigResponse$json,
  '.bitcoind.v1.CreatePsbtRequest': CreatePsbtRequest$json,
  '.bitcoind.v1.CreatePsbtRequest.Input': CreatePsbtRequest_Input$json,
  '.bitcoind.v1.CreatePsbtRequest.OutputsEntry': CreatePsbtRequest_OutputsEntry$json,
  '.bitcoind.v1.CreatePsbtResponse': CreatePsbtResponse$json,
  '.bitcoind.v1.DecodePsbtRequest': DecodePsbtRequest$json,
  '.bitcoind.v1.DecodePsbtResponse': DecodePsbtResponse$json,
  '.bitcoind.v1.DecodeRawTransactionResponse': DecodeRawTransactionResponse$json,
  '.bitcoind.v1.DecodePsbtResponse.UnknownEntry': DecodePsbtResponse_UnknownEntry$json,
  '.bitcoind.v1.DecodePsbtResponse.Input': DecodePsbtResponse_Input$json,
  '.bitcoind.v1.DecodePsbtResponse.WitnessUtxo': DecodePsbtResponse_WitnessUtxo$json,
  '.bitcoind.v1.DecodePsbtResponse.Input.PartialSignaturesEntry': DecodePsbtResponse_Input_PartialSignaturesEntry$json,
  '.bitcoind.v1.DecodePsbtResponse.RedeemScript': DecodePsbtResponse_RedeemScript$json,
  '.bitcoind.v1.DecodePsbtResponse.Bip32Deriv': DecodePsbtResponse_Bip32Deriv$json,
  '.bitcoind.v1.DecodePsbtResponse.Input.UnknownEntry': DecodePsbtResponse_Input_UnknownEntry$json,
  '.bitcoind.v1.DecodePsbtResponse.Output': DecodePsbtResponse_Output$json,
  '.bitcoind.v1.DecodePsbtResponse.Output.UnknownEntry': DecodePsbtResponse_Output_UnknownEntry$json,
  '.bitcoind.v1.AnalyzePsbtRequest': AnalyzePsbtRequest$json,
  '.bitcoind.v1.AnalyzePsbtResponse': AnalyzePsbtResponse$json,
  '.bitcoind.v1.AnalyzePsbtResponse.Input': AnalyzePsbtResponse_Input$json,
  '.bitcoind.v1.AnalyzePsbtResponse.Input.Missing': AnalyzePsbtResponse_Input_Missing$json,
  '.bitcoind.v1.CombinePsbtRequest': CombinePsbtRequest$json,
  '.bitcoind.v1.CombinePsbtResponse': CombinePsbtResponse$json,
  '.bitcoind.v1.UtxoUpdatePsbtRequest': UtxoUpdatePsbtRequest$json,
  '.bitcoind.v1.Descriptor': Descriptor$json,
  '.bitcoind.v1.DescriptorObject': DescriptorObject$json,
  '.bitcoind.v1.DescriptorRange': DescriptorRange$json,
  '.bitcoind.v1.Range': Range$json,
  '.bitcoind.v1.UtxoUpdatePsbtResponse': UtxoUpdatePsbtResponse$json,
  '.bitcoind.v1.JoinPsbtsRequest': JoinPsbtsRequest$json,
  '.bitcoind.v1.JoinPsbtsResponse': JoinPsbtsResponse$json,
  '.bitcoind.v1.TestMempoolAcceptRequest': TestMempoolAcceptRequest$json,
  '.bitcoind.v1.TestMempoolAcceptResponse': TestMempoolAcceptResponse$json,
  '.bitcoind.v1.TestMempoolAcceptResponse.Result': TestMempoolAcceptResponse_Result$json,
};

/// Descriptor for `BitcoindService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List bitcoindServiceDescriptor = $convert.base64Decode(
    'Cg9CaXRjb2luZFNlcnZpY2UScQoWTGlzdFJlY2VudFRyYW5zYWN0aW9ucxIqLmJpdGNvaW5kLn'
    'YxLkxpc3RSZWNlbnRUcmFuc2FjdGlvbnNSZXF1ZXN0GisuYml0Y29pbmQudjEuTGlzdFJlY2Vu'
    'dFRyYW5zYWN0aW9uc1Jlc3BvbnNlEk0KCkxpc3RCbG9ja3MSHi5iaXRjb2luZC52MS5MaXN0Qm'
    'xvY2tzUmVxdWVzdBofLmJpdGNvaW5kLnYxLkxpc3RCbG9ja3NSZXNwb25zZRJHCghHZXRCbG9j'
    'axIcLmJpdGNvaW5kLnYxLkdldEJsb2NrUmVxdWVzdBodLmJpdGNvaW5kLnYxLkdldEJsb2NrUm'
    'VzcG9uc2USUwoRR2V0QmxvY2tjaGFpbkluZm8SFi5nb29nbGUucHJvdG9idWYuRW1wdHkaJi5i'
    'aXRjb2luZC52MS5HZXRCbG9ja2NoYWluSW5mb1Jlc3BvbnNlEkMKCUxpc3RQZWVycxIWLmdvb2'
    'dsZS5wcm90b2J1Zi5FbXB0eRoeLmJpdGNvaW5kLnYxLkxpc3RQZWVyc1Jlc3BvbnNlEl8KEEVz'
    'dGltYXRlU21hcnRGZWUSJC5iaXRjb2luZC52MS5Fc3RpbWF0ZVNtYXJ0RmVlUmVxdWVzdBolLm'
    'JpdGNvaW5kLnYxLkVzdGltYXRlU21hcnRGZWVSZXNwb25zZRJiChFHZXRSYXdUcmFuc2FjdGlv'
    'bhIlLmJpdGNvaW5kLnYxLkdldFJhd1RyYW5zYWN0aW9uUmVxdWVzdBomLmJpdGNvaW5kLnYxLk'
    'dldFJhd1RyYW5zYWN0aW9uUmVzcG9uc2USawoUQ3JlYXRlUmF3VHJhbnNhY3Rpb24SKC5iaXRj'
    'b2luZC52MS5DcmVhdGVSYXdUcmFuc2FjdGlvblJlcXVlc3QaKS5iaXRjb2luZC52MS5DcmVhdG'
    'VSYXdUcmFuc2FjdGlvblJlc3BvbnNlElMKDENyZWF0ZVdhbGxldBIgLmJpdGNvaW5kLnYxLkNy'
    'ZWF0ZVdhbGxldFJlcXVlc3QaIS5iaXRjb2luZC52MS5DcmVhdGVXYWxsZXRSZXNwb25zZRJTCg'
    'xCYWNrdXBXYWxsZXQSIC5iaXRjb2luZC52MS5CYWNrdXBXYWxsZXRSZXF1ZXN0GiEuYml0Y29p'
    'bmQudjEuQmFja3VwV2FsbGV0UmVzcG9uc2USTQoKRHVtcFdhbGxldBIeLmJpdGNvaW5kLnYxLk'
    'R1bXBXYWxsZXRSZXF1ZXN0Gh8uYml0Y29pbmQudjEuRHVtcFdhbGxldFJlc3BvbnNlElMKDElt'
    'cG9ydFdhbGxldBIgLmJpdGNvaW5kLnYxLkltcG9ydFdhbGxldFJlcXVlc3QaIS5iaXRjb2luZC'
    '52MS5JbXBvcnRXYWxsZXRSZXNwb25zZRJTCgxVbmxvYWRXYWxsZXQSIC5iaXRjb2luZC52MS5V'
    'bmxvYWRXYWxsZXRSZXF1ZXN0GiEuYml0Y29pbmQudjEuVW5sb2FkV2FsbGV0UmVzcG9uc2USUA'
    'oLRHVtcFByaXZLZXkSHy5iaXRjb2luZC52MS5EdW1wUHJpdktleVJlcXVlc3QaIC5iaXRjb2lu'
    'ZC52MS5EdW1wUHJpdktleVJlc3BvbnNlElYKDUltcG9ydFByaXZLZXkSIS5iaXRjb2luZC52MS'
    '5JbXBvcnRQcml2S2V5UmVxdWVzdBoiLmJpdGNvaW5kLnYxLkltcG9ydFByaXZLZXlSZXNwb25z'
    'ZRJWCg1JbXBvcnRBZGRyZXNzEiEuYml0Y29pbmQudjEuSW1wb3J0QWRkcmVzc1JlcXVlc3QaIi'
    '5iaXRjb2luZC52MS5JbXBvcnRBZGRyZXNzUmVzcG9uc2USUwoMSW1wb3J0UHViS2V5EiAuYml0'
    'Y29pbmQudjEuSW1wb3J0UHViS2V5UmVxdWVzdBohLmJpdGNvaW5kLnYxLkltcG9ydFB1YktleV'
    'Jlc3BvbnNlElYKDUtleVBvb2xSZWZpbGwSIS5iaXRjb2luZC52MS5LZXlQb29sUmVmaWxsUmVx'
    'dWVzdBoiLmJpdGNvaW5kLnYxLktleVBvb2xSZWZpbGxSZXNwb25zZRJNCgpHZXRBY2NvdW50Eh'
    '4uYml0Y29pbmQudjEuR2V0QWNjb3VudFJlcXVlc3QaHy5iaXRjb2luZC52MS5HZXRBY2NvdW50'
    'UmVzcG9uc2USTQoKU2V0QWNjb3VudBIeLmJpdGNvaW5kLnYxLlNldEFjY291bnRSZXF1ZXN0Gh'
    '8uYml0Y29pbmQudjEuU2V0QWNjb3VudFJlc3BvbnNlEm4KFUdldEFkZHJlc3Nlc0J5QWNjb3Vu'
    'dBIpLmJpdGNvaW5kLnYxLkdldEFkZHJlc3Nlc0J5QWNjb3VudFJlcXVlc3QaKi5iaXRjb2luZC'
    '52MS5HZXRBZGRyZXNzZXNCeUFjY291bnRSZXNwb25zZRJTCgxMaXN0QWNjb3VudHMSIC5iaXRj'
    'b2luZC52MS5MaXN0QWNjb3VudHNSZXF1ZXN0GiEuYml0Y29pbmQudjEuTGlzdEFjY291bnRzUm'
    'VzcG9uc2USZQoSQWRkTXVsdGlzaWdBZGRyZXNzEiYuYml0Y29pbmQudjEuQWRkTXVsdGlzaWdB'
    'ZGRyZXNzUmVxdWVzdBonLmJpdGNvaW5kLnYxLkFkZE11bHRpc2lnQWRkcmVzc1Jlc3BvbnNlEl'
    'kKDkNyZWF0ZU11bHRpc2lnEiIuYml0Y29pbmQudjEuQ3JlYXRlTXVsdGlzaWdSZXF1ZXN0GiMu'
    'Yml0Y29pbmQudjEuQ3JlYXRlTXVsdGlzaWdSZXNwb25zZRJNCgpDcmVhdGVQc2J0Eh4uYml0Y2'
    '9pbmQudjEuQ3JlYXRlUHNidFJlcXVlc3QaHy5iaXRjb2luZC52MS5DcmVhdGVQc2J0UmVzcG9u'
    'c2USTQoKRGVjb2RlUHNidBIeLmJpdGNvaW5kLnYxLkRlY29kZVBzYnRSZXF1ZXN0Gh8uYml0Y2'
    '9pbmQudjEuRGVjb2RlUHNidFJlc3BvbnNlElAKC0FuYWx5emVQc2J0Eh8uYml0Y29pbmQudjEu'
    'QW5hbHl6ZVBzYnRSZXF1ZXN0GiAuYml0Y29pbmQudjEuQW5hbHl6ZVBzYnRSZXNwb25zZRJQCg'
    'tDb21iaW5lUHNidBIfLmJpdGNvaW5kLnYxLkNvbWJpbmVQc2J0UmVxdWVzdBogLmJpdGNvaW5k'
    'LnYxLkNvbWJpbmVQc2J0UmVzcG9uc2USWQoOVXR4b1VwZGF0ZVBzYnQSIi5iaXRjb2luZC52MS'
    '5VdHhvVXBkYXRlUHNidFJlcXVlc3QaIy5iaXRjb2luZC52MS5VdHhvVXBkYXRlUHNidFJlc3Bv'
    'bnNlEkoKCUpvaW5Qc2J0cxIdLmJpdGNvaW5kLnYxLkpvaW5Qc2J0c1JlcXVlc3QaHi5iaXRjb2'
    'luZC52MS5Kb2luUHNidHNSZXNwb25zZRJiChFUZXN0TWVtcG9vbEFjY2VwdBIlLmJpdGNvaW5k'
    'LnYxLlRlc3RNZW1wb29sQWNjZXB0UmVxdWVzdBomLmJpdGNvaW5kLnYxLlRlc3RNZW1wb29sQW'
    'NjZXB0UmVzcG9uc2U=');

