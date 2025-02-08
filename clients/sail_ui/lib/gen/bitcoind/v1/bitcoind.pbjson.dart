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
    'dldFJhd1RyYW5zYWN0aW9uUmVzcG9uc2U=');

