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

@$core.Deprecated('Use kindDescriptor instead')
const Kind$json = {
  '1': 'Kind',
  '2': [
    {'1': 'KIND_UNSPECIFIED', '2': 0},
    {'1': 'KIND_TRANSFER', '2': 1},
    {'1': 'KIND_WITHDRAWAL', '2': 2},
    {'1': 'KIND_DEPOSIT', '2': 3},
  ],
};

/// Descriptor for `Kind`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List kindDescriptor = $convert.base64Decode(
    'CgRLaW5kEhQKEEtJTkRfVU5TUEVDSUZJRUQQABIRCg1LSU5EX1RSQU5TRkVSEAESEwoPS0lORF'
    '9XSVRIRFJBV0FMEAISEAoMS0lORF9ERVBPU0lUEAM=');

@$core.Deprecated('Use blockDescriptor instead')
const Block$json = {
  '1': 'Block',
  '2': [
    {'1': 'height', '3': 1, '4': 1, '5': 13, '10': 'height'},
    {'1': 'hash', '3': 2, '4': 1, '5': 9, '10': 'hash'},
    {'1': 'prev_hash', '3': 3, '4': 1, '5': 9, '10': 'prevHash'},
    {'1': 'merkle_root', '3': 4, '4': 1, '5': 9, '10': 'merkleRoot'},
    {'1': 'mainchain_hash', '3': 5, '4': 1, '5': 9, '10': 'mainchainHash'},
    {'1': 'mainchain_height', '3': 6, '4': 1, '5': 13, '10': 'mainchainHeight'},
    {'1': 'block_time', '3': 7, '4': 1, '5': 3, '10': 'blockTime'},
    {'1': 'tx_count', '3': 8, '4': 1, '5': 13, '10': 'txCount'},
    {'1': 'fees_sats', '3': 9, '4': 1, '5': 3, '10': 'feesSats'},
    {'1': 'size_bytes', '3': 10, '4': 1, '5': 3, '10': 'sizeBytes'},
    {'1': 'fees_known', '3': 11, '4': 1, '5': 8, '10': 'feesKnown'},
    {'1': 'value_sats', '3': 12, '4': 1, '5': 3, '10': 'valueSats'},
  ],
};

/// Descriptor for `Block`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List blockDescriptor = $convert.base64Decode(
    'CgVCbG9jaxIWCgZoZWlnaHQYASABKA1SBmhlaWdodBISCgRoYXNoGAIgASgJUgRoYXNoEhsKCX'
    'ByZXZfaGFzaBgDIAEoCVIIcHJldkhhc2gSHwoLbWVya2xlX3Jvb3QYBCABKAlSCm1lcmtsZVJv'
    'b3QSJQoObWFpbmNoYWluX2hhc2gYBSABKAlSDW1haW5jaGFpbkhhc2gSKQoQbWFpbmNoYWluX2'
    'hlaWdodBgGIAEoDVIPbWFpbmNoYWluSGVpZ2h0Eh0KCmJsb2NrX3RpbWUYByABKANSCWJsb2Nr'
    'VGltZRIZCgh0eF9jb3VudBgIIAEoDVIHdHhDb3VudBIbCglmZWVzX3NhdHMYCSABKANSCGZlZX'
    'NTYXRzEh0KCnNpemVfYnl0ZXMYCiABKANSCXNpemVCeXRlcxIdCgpmZWVzX2tub3duGAsgASgI'
    'UglmZWVzS25vd24SHQoKdmFsdWVfc2F0cxgMIAEoA1IJdmFsdWVTYXRz');

@$core.Deprecated('Use activityDescriptor instead')
const Activity$json = {
  '1': 'Activity',
  '2': [
    {'1': 'kind', '3': 1, '4': 1, '5': 14, '6': '.explorer.v1.Kind', '10': 'kind'},
    {'1': 'id', '3': 2, '4': 1, '5': 9, '10': 'id'},
    {'1': 'value_sats', '3': 3, '4': 1, '5': 3, '10': 'valueSats'},
    {'1': 'fee_sats', '3': 4, '4': 1, '5': 3, '10': 'feeSats'},
    {'1': 'size_bytes', '3': 5, '4': 1, '5': 3, '10': 'sizeBytes'},
    {'1': 'confirmed', '3': 6, '4': 1, '5': 8, '10': 'confirmed'},
    {'1': 'block_height', '3': 7, '4': 1, '5': 13, '10': 'blockHeight'},
    {'1': 'block_time', '3': 8, '4': 1, '5': 3, '10': 'blockTime'},
  ],
};

/// Descriptor for `Activity`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List activityDescriptor = $convert.base64Decode(
    'CghBY3Rpdml0eRIlCgRraW5kGAEgASgOMhEuZXhwbG9yZXIudjEuS2luZFIEa2luZBIOCgJpZB'
    'gCIAEoCVICaWQSHQoKdmFsdWVfc2F0cxgDIAEoA1IJdmFsdWVTYXRzEhkKCGZlZV9zYXRzGAQg'
    'ASgDUgdmZWVTYXRzEh0KCnNpemVfYnl0ZXMYBSABKANSCXNpemVCeXRlcxIcCgljb25maXJtZW'
    'QYBiABKAhSCWNvbmZpcm1lZBIhCgxibG9ja19oZWlnaHQYByABKA1SC2Jsb2NrSGVpZ2h0Eh0K'
    'CmJsb2NrX3RpbWUYCCABKANSCWJsb2NrVGltZQ==');

@$core.Deprecated('Use coinDescriptor instead')
const Coin$json = {
  '1': 'Coin',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'value_sats', '3': 2, '4': 1, '5': 3, '10': 'valueSats'},
    {'1': 'outpoint_kind', '3': 3, '4': 1, '5': 9, '10': 'outpointKind'},
    {'1': 'content_type', '3': 4, '4': 1, '5': 9, '10': 'contentType'},
    {'1': 'main_address', '3': 5, '4': 1, '5': 9, '10': 'mainAddress'},
    {'1': 'main_fee_sats', '3': 6, '4': 1, '5': 3, '10': 'mainFeeSats'},
    {'1': 'txid', '3': 7, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'vout', '3': 8, '4': 1, '5': 13, '10': 'vout'},
  ],
};

/// Descriptor for `Coin`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List coinDescriptor = $convert.base64Decode(
    'CgRDb2luEhgKB2FkZHJlc3MYASABKAlSB2FkZHJlc3MSHQoKdmFsdWVfc2F0cxgCIAEoA1IJdm'
    'FsdWVTYXRzEiMKDW91dHBvaW50X2tpbmQYAyABKAlSDG91dHBvaW50S2luZBIhCgxjb250ZW50'
    'X3R5cGUYBCABKAlSC2NvbnRlbnRUeXBlEiEKDG1haW5fYWRkcmVzcxgFIAEoCVILbWFpbkFkZH'
    'Jlc3MSIgoNbWFpbl9mZWVfc2F0cxgGIAEoA1ILbWFpbkZlZVNhdHMSEgoEdHhpZBgHIAEoCVIE'
    'dHhpZBISCgR2b3V0GAggASgNUgR2b3V0');

@$core.Deprecated('Use transactionDescriptor instead')
const Transaction$json = {
  '1': 'Transaction',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'kind', '3': 2, '4': 1, '5': 14, '6': '.explorer.v1.Kind', '10': 'kind'},
    {'1': 'fee_sats', '3': 3, '4': 1, '5': 3, '10': 'feeSats'},
    {'1': 'size_bytes', '3': 4, '4': 1, '5': 3, '10': 'sizeBytes'},
    {'1': 'confirmed', '3': 5, '4': 1, '5': 8, '10': 'confirmed'},
    {'1': 'block_height', '3': 6, '4': 1, '5': 13, '10': 'blockHeight'},
    {'1': 'block_hash', '3': 7, '4': 1, '5': 9, '10': 'blockHash'},
    {'1': 'block_time', '3': 8, '4': 1, '5': 3, '10': 'blockTime'},
    {'1': 'inputs', '3': 9, '4': 3, '5': 11, '6': '.explorer.v1.Coin', '10': 'inputs'},
    {'1': 'outputs', '3': 10, '4': 3, '5': 11, '6': '.explorer.v1.Coin', '10': 'outputs'},
  ],
};

/// Descriptor for `Transaction`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transactionDescriptor = $convert.base64Decode(
    'CgtUcmFuc2FjdGlvbhISCgR0eGlkGAEgASgJUgR0eGlkEiUKBGtpbmQYAiABKA4yES5leHBsb3'
    'Jlci52MS5LaW5kUgRraW5kEhkKCGZlZV9zYXRzGAMgASgDUgdmZWVTYXRzEh0KCnNpemVfYnl0'
    'ZXMYBCABKANSCXNpemVCeXRlcxIcCgljb25maXJtZWQYBSABKAhSCWNvbmZpcm1lZBIhCgxibG'
    '9ja19oZWlnaHQYBiABKA1SC2Jsb2NrSGVpZ2h0Eh0KCmJsb2NrX2hhc2gYByABKAlSCWJsb2Nr'
    'SGFzaBIdCgpibG9ja190aW1lGAggASgDUglibG9ja1RpbWUSKQoGaW5wdXRzGAkgAygLMhEuZX'
    'hwbG9yZXIudjEuQ29pblIGaW5wdXRzEisKB291dHB1dHMYCiADKAsyES5leHBsb3Jlci52MS5D'
    'b2luUgdvdXRwdXRz');

@$core.Deprecated('Use treasuryDescriptor instead')
const Treasury$json = {
  '1': 'Treasury',
  '2': [
    {'1': 'slot', '3': 1, '4': 1, '5': 13, '10': 'slot'},
    {'1': 'balance_sats', '3': 2, '4': 1, '5': 3, '10': 'balanceSats'},
    {'1': 'ctip_txid', '3': 3, '4': 1, '5': 9, '10': 'ctipTxid'},
    {'1': 'ctip_vout', '3': 4, '4': 1, '5': 13, '10': 'ctipVout'},
    {'1': 'activation_height', '3': 5, '4': 1, '5': 13, '10': 'activationHeight'},
  ],
};

/// Descriptor for `Treasury`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List treasuryDescriptor = $convert.base64Decode(
    'CghUcmVhc3VyeRISCgRzbG90GAEgASgNUgRzbG90EiEKDGJhbGFuY2Vfc2F0cxgCIAEoA1ILYm'
    'FsYW5jZVNhdHMSGwoJY3RpcF90eGlkGAMgASgJUghjdGlwVHhpZBIbCgljdGlwX3ZvdXQYBCAB'
    'KA1SCGN0aXBWb3V0EisKEWFjdGl2YXRpb25faGVpZ2h0GAUgASgNUhBhY3RpdmF0aW9uSGVpZ2'
    'h0');

@$core.Deprecated('Use mempoolDescriptor instead')
const Mempool$json = {
  '1': 'Mempool',
  '2': [
    {'1': 'tx_count', '3': 1, '4': 1, '5': 13, '10': 'txCount'},
    {'1': 'fees_sats', '3': 2, '4': 1, '5': 3, '10': 'feesSats'},
    {'1': 'size_bytes', '3': 3, '4': 1, '5': 3, '10': 'sizeBytes'},
  ],
};

/// Descriptor for `Mempool`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mempoolDescriptor = $convert.base64Decode(
    'CgdNZW1wb29sEhkKCHR4X2NvdW50GAEgASgNUgd0eENvdW50EhsKCWZlZXNfc2F0cxgCIAEoA1'
    'IIZmVlc1NhdHMSHQoKc2l6ZV9ieXRlcxgDIAEoA1IJc2l6ZUJ5dGVz');

@$core.Deprecated('Use getOverviewRequestDescriptor instead')
const GetOverviewRequest$json = {
  '1': 'GetOverviewRequest',
  '2': [
    {'1': 'chain', '3': 1, '4': 1, '5': 9, '10': 'chain'},
  ],
};

/// Descriptor for `GetOverviewRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getOverviewRequestDescriptor = $convert.base64Decode(
    'ChJHZXRPdmVydmlld1JlcXVlc3QSFAoFY2hhaW4YASABKAlSBWNoYWlu');

@$core.Deprecated('Use getOverviewResponseDescriptor instead')
const GetOverviewResponse$json = {
  '1': 'GetOverviewResponse',
  '2': [
    {'1': 'blocks', '3': 1, '4': 3, '5': 11, '6': '.explorer.v1.Block', '10': 'blocks'},
    {'1': 'recent', '3': 2, '4': 3, '5': 11, '6': '.explorer.v1.Activity', '10': 'recent'},
    {'1': 'mempool', '3': 3, '4': 1, '5': 11, '6': '.explorer.v1.Mempool', '10': 'mempool'},
    {'1': 'treasury', '3': 4, '4': 1, '5': 11, '6': '.explorer.v1.Treasury', '10': 'treasury'},
    {'1': 'pending_bundle', '3': 5, '4': 1, '5': 11, '6': '.explorer.v1.WithdrawalBundle', '10': 'pendingBundle'},
    {'1': 'tip_height', '3': 6, '4': 1, '5': 13, '10': 'tipHeight'},
    {'1': 'source', '3': 7, '4': 1, '5': 9, '10': 'source'},
  ],
};

/// Descriptor for `GetOverviewResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getOverviewResponseDescriptor = $convert.base64Decode(
    'ChNHZXRPdmVydmlld1Jlc3BvbnNlEioKBmJsb2NrcxgBIAMoCzISLmV4cGxvcmVyLnYxLkJsb2'
    'NrUgZibG9ja3MSLQoGcmVjZW50GAIgAygLMhUuZXhwbG9yZXIudjEuQWN0aXZpdHlSBnJlY2Vu'
    'dBIuCgdtZW1wb29sGAMgASgLMhQuZXhwbG9yZXIudjEuTWVtcG9vbFIHbWVtcG9vbBIxCgh0cm'
    'Vhc3VyeRgEIAEoCzIVLmV4cGxvcmVyLnYxLlRyZWFzdXJ5Ugh0cmVhc3VyeRJECg5wZW5kaW5n'
    'X2J1bmRsZRgFIAEoCzIdLmV4cGxvcmVyLnYxLldpdGhkcmF3YWxCdW5kbGVSDXBlbmRpbmdCdW'
    '5kbGUSHQoKdGlwX2hlaWdodBgGIAEoDVIJdGlwSGVpZ2h0EhYKBnNvdXJjZRgHIAEoCVIGc291'
    'cmNl');

@$core.Deprecated('Use getBlockRequestDescriptor instead')
const GetBlockRequest$json = {
  '1': 'GetBlockRequest',
  '2': [
    {'1': 'chain', '3': 1, '4': 1, '5': 9, '10': 'chain'},
    {'1': 'hash', '3': 2, '4': 1, '5': 9, '10': 'hash'},
    {'1': 'height', '3': 3, '4': 1, '5': 13, '10': 'height'},
  ],
};

/// Descriptor for `GetBlockRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBlockRequestDescriptor = $convert.base64Decode(
    'Cg9HZXRCbG9ja1JlcXVlc3QSFAoFY2hhaW4YASABKAlSBWNoYWluEhIKBGhhc2gYAiABKAlSBG'
    'hhc2gSFgoGaGVpZ2h0GAMgASgNUgZoZWlnaHQ=');

@$core.Deprecated('Use getBlockResponseDescriptor instead')
const GetBlockResponse$json = {
  '1': 'GetBlockResponse',
  '2': [
    {'1': 'block', '3': 1, '4': 1, '5': 11, '6': '.explorer.v1.Block', '10': 'block'},
    {'1': 'activity', '3': 2, '4': 3, '5': 11, '6': '.explorer.v1.Activity', '10': 'activity'},
  ],
};

/// Descriptor for `GetBlockResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBlockResponseDescriptor = $convert.base64Decode(
    'ChBHZXRCbG9ja1Jlc3BvbnNlEigKBWJsb2NrGAEgASgLMhIuZXhwbG9yZXIudjEuQmxvY2tSBW'
    'Jsb2NrEjEKCGFjdGl2aXR5GAIgAygLMhUuZXhwbG9yZXIudjEuQWN0aXZpdHlSCGFjdGl2aXR5');

@$core.Deprecated('Use getTransactionRequestDescriptor instead')
const GetTransactionRequest$json = {
  '1': 'GetTransactionRequest',
  '2': [
    {'1': 'chain', '3': 1, '4': 1, '5': 9, '10': 'chain'},
    {'1': 'txid', '3': 2, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `GetTransactionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTransactionRequestDescriptor = $convert.base64Decode(
    'ChVHZXRUcmFuc2FjdGlvblJlcXVlc3QSFAoFY2hhaW4YASABKAlSBWNoYWluEhIKBHR4aWQYAi'
    'ABKAlSBHR4aWQ=');

@$core.Deprecated('Use getTransactionResponseDescriptor instead')
const GetTransactionResponse$json = {
  '1': 'GetTransactionResponse',
  '2': [
    {'1': 'transaction', '3': 1, '4': 1, '5': 11, '6': '.explorer.v1.Transaction', '10': 'transaction'},
  ],
};

/// Descriptor for `GetTransactionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTransactionResponseDescriptor = $convert.base64Decode(
    'ChZHZXRUcmFuc2FjdGlvblJlc3BvbnNlEjoKC3RyYW5zYWN0aW9uGAEgASgLMhguZXhwbG9yZX'
    'IudjEuVHJhbnNhY3Rpb25SC3RyYW5zYWN0aW9u');

@$core.Deprecated('Use getAddressRequestDescriptor instead')
const GetAddressRequest$json = {
  '1': 'GetAddressRequest',
  '2': [
    {'1': 'chain', '3': 1, '4': 1, '5': 9, '10': 'chain'},
    {'1': 'address', '3': 2, '4': 1, '5': 9, '10': 'address'},
  ],
};

/// Descriptor for `GetAddressRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAddressRequestDescriptor = $convert.base64Decode(
    'ChFHZXRBZGRyZXNzUmVxdWVzdBIUCgVjaGFpbhgBIAEoCVIFY2hhaW4SGAoHYWRkcmVzcxgCIA'
    'EoCVIHYWRkcmVzcw==');

@$core.Deprecated('Use getAddressResponseDescriptor instead')
const GetAddressResponse$json = {
  '1': 'GetAddressResponse',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'confirmed_balance_sats', '3': 2, '4': 1, '5': 3, '10': 'confirmedBalanceSats'},
    {'1': 'unconfirmed_balance_sats', '3': 3, '4': 1, '5': 3, '10': 'unconfirmedBalanceSats'},
    {'1': 'total_received_sats', '3': 4, '4': 1, '5': 3, '10': 'totalReceivedSats'},
    {'1': 'confirmed_coin_count', '3': 5, '4': 1, '5': 13, '10': 'confirmedCoinCount'},
    {'1': 'unconfirmed_coin_count', '3': 6, '4': 1, '5': 13, '10': 'unconfirmedCoinCount'},
    {'1': 'tx_count', '3': 7, '4': 1, '5': 13, '10': 'txCount'},
    {'1': 'transactions', '3': 8, '4': 3, '5': 11, '6': '.explorer.v1.Transaction', '10': 'transactions'},
  ],
};

/// Descriptor for `GetAddressResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAddressResponseDescriptor = $convert.base64Decode(
    'ChJHZXRBZGRyZXNzUmVzcG9uc2USGAoHYWRkcmVzcxgBIAEoCVIHYWRkcmVzcxI0ChZjb25maX'
    'JtZWRfYmFsYW5jZV9zYXRzGAIgASgDUhRjb25maXJtZWRCYWxhbmNlU2F0cxI4Chh1bmNvbmZp'
    'cm1lZF9iYWxhbmNlX3NhdHMYAyABKANSFnVuY29uZmlybWVkQmFsYW5jZVNhdHMSLgoTdG90YW'
    'xfcmVjZWl2ZWRfc2F0cxgEIAEoA1IRdG90YWxSZWNlaXZlZFNhdHMSMAoUY29uZmlybWVkX2Nv'
    'aW5fY291bnQYBSABKA1SEmNvbmZpcm1lZENvaW5Db3VudBI0ChZ1bmNvbmZpcm1lZF9jb2luX2'
    'NvdW50GAYgASgNUhR1bmNvbmZpcm1lZENvaW5Db3VudBIZCgh0eF9jb3VudBgHIAEoDVIHdHhD'
    'b3VudBI8Cgx0cmFuc2FjdGlvbnMYCCADKAsyGC5leHBsb3Jlci52MS5UcmFuc2FjdGlvblIMdH'
    'JhbnNhY3Rpb25z');

@$core.Deprecated('Use withdrawalDescriptor instead')
const Withdrawal$json = {
  '1': 'Withdrawal',
  '2': [
    {'1': 'main_address', '3': 1, '4': 1, '5': 9, '10': 'mainAddress'},
    {'1': 'value_sats', '3': 2, '4': 1, '5': 3, '10': 'valueSats'},
    {'1': 'main_fee_sats', '3': 3, '4': 1, '5': 3, '10': 'mainFeeSats'},
    {'1': 'cumulative_weight', '3': 4, '4': 1, '5': 13, '10': 'cumulativeWeight'},
  ],
};

/// Descriptor for `Withdrawal`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List withdrawalDescriptor = $convert.base64Decode(
    'CgpXaXRoZHJhd2FsEiEKDG1haW5fYWRkcmVzcxgBIAEoCVILbWFpbkFkZHJlc3MSHQoKdmFsdW'
    'Vfc2F0cxgCIAEoA1IJdmFsdWVTYXRzEiIKDW1haW5fZmVlX3NhdHMYAyABKANSC21haW5GZWVT'
    'YXRzEisKEWN1bXVsYXRpdmVfd2VpZ2h0GAQgASgNUhBjdW11bGF0aXZlV2VpZ2h0');

@$core.Deprecated('Use withdrawalBundleDescriptor instead')
const WithdrawalBundle$json = {
  '1': 'WithdrawalBundle',
  '2': [
    {'1': 'present', '3': 1, '4': 1, '5': 8, '10': 'present'},
    {'1': 'm6id', '3': 2, '4': 1, '5': 9, '10': 'm6id'},
    {'1': 'height_created', '3': 3, '4': 1, '5': 13, '10': 'heightCreated'},
    {'1': 'total_value_sats', '3': 4, '4': 1, '5': 3, '10': 'totalValueSats'},
    {'1': 'total_main_fees_sats', '3': 5, '4': 1, '5': 3, '10': 'totalMainFeesSats'},
    {'1': 'total_weight', '3': 6, '4': 1, '5': 13, '10': 'totalWeight'},
    {'1': 'max_weight', '3': 7, '4': 1, '5': 13, '10': 'maxWeight'},
    {'1': 'withdrawals', '3': 8, '4': 3, '5': 11, '6': '.explorer.v1.Withdrawal', '10': 'withdrawals'},
  ],
};

/// Descriptor for `WithdrawalBundle`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List withdrawalBundleDescriptor = $convert.base64Decode(
    'ChBXaXRoZHJhd2FsQnVuZGxlEhgKB3ByZXNlbnQYASABKAhSB3ByZXNlbnQSEgoEbTZpZBgCIA'
    'EoCVIEbTZpZBIlCg5oZWlnaHRfY3JlYXRlZBgDIAEoDVINaGVpZ2h0Q3JlYXRlZBIoChB0b3Rh'
    'bF92YWx1ZV9zYXRzGAQgASgDUg50b3RhbFZhbHVlU2F0cxIvChR0b3RhbF9tYWluX2ZlZXNfc2'
    'F0cxgFIAEoA1IRdG90YWxNYWluRmVlc1NhdHMSIQoMdG90YWxfd2VpZ2h0GAYgASgNUgt0b3Rh'
    'bFdlaWdodBIdCgptYXhfd2VpZ2h0GAcgASgNUgltYXhXZWlnaHQSOQoLd2l0aGRyYXdhbHMYCC'
    'ADKAsyFy5leHBsb3Jlci52MS5XaXRoZHJhd2FsUgt3aXRoZHJhd2Fscw==');

@$core.Deprecated('Use getWithdrawalsRequestDescriptor instead')
const GetWithdrawalsRequest$json = {
  '1': 'GetWithdrawalsRequest',
  '2': [
    {'1': 'chain', '3': 1, '4': 1, '5': 9, '10': 'chain'},
  ],
};

/// Descriptor for `GetWithdrawalsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getWithdrawalsRequestDescriptor = $convert.base64Decode(
    'ChVHZXRXaXRoZHJhd2Fsc1JlcXVlc3QSFAoFY2hhaW4YASABKAlSBWNoYWlu');

@$core.Deprecated('Use getWithdrawalsResponseDescriptor instead')
const GetWithdrawalsResponse$json = {
  '1': 'GetWithdrawalsResponse',
  '2': [
    {'1': 'bundle', '3': 1, '4': 1, '5': 11, '6': '.explorer.v1.WithdrawalBundle', '10': 'bundle'},
    {'1': 'last_failed_height', '3': 2, '4': 1, '5': 13, '10': 'lastFailedHeight'},
  ],
};

/// Descriptor for `GetWithdrawalsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getWithdrawalsResponseDescriptor = $convert.base64Decode(
    'ChZHZXRXaXRoZHJhd2Fsc1Jlc3BvbnNlEjUKBmJ1bmRsZRgBIAEoCzIdLmV4cGxvcmVyLnYxLl'
    'dpdGhkcmF3YWxCdW5kbGVSBmJ1bmRsZRIsChJsYXN0X2ZhaWxlZF9oZWlnaHQYAiABKA1SEGxh'
    'c3RGYWlsZWRIZWlnaHQ=');

const $core.Map<$core.String, $core.dynamic> ExplorerServiceBase$json = {
  '1': 'ExplorerService',
  '2': [
    {'1': 'GetOverview', '2': '.explorer.v1.GetOverviewRequest', '3': '.explorer.v1.GetOverviewResponse'},
    {'1': 'GetBlock', '2': '.explorer.v1.GetBlockRequest', '3': '.explorer.v1.GetBlockResponse'},
    {'1': 'GetTransaction', '2': '.explorer.v1.GetTransactionRequest', '3': '.explorer.v1.GetTransactionResponse'},
    {'1': 'GetAddress', '2': '.explorer.v1.GetAddressRequest', '3': '.explorer.v1.GetAddressResponse'},
    {'1': 'GetWithdrawals', '2': '.explorer.v1.GetWithdrawalsRequest', '3': '.explorer.v1.GetWithdrawalsResponse'},
  ],
};

@$core.Deprecated('Use explorerServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> ExplorerServiceBase$messageJson = {
  '.explorer.v1.GetOverviewRequest': GetOverviewRequest$json,
  '.explorer.v1.GetOverviewResponse': GetOverviewResponse$json,
  '.explorer.v1.Block': Block$json,
  '.explorer.v1.Activity': Activity$json,
  '.explorer.v1.Mempool': Mempool$json,
  '.explorer.v1.Treasury': Treasury$json,
  '.explorer.v1.WithdrawalBundle': WithdrawalBundle$json,
  '.explorer.v1.Withdrawal': Withdrawal$json,
  '.explorer.v1.GetBlockRequest': GetBlockRequest$json,
  '.explorer.v1.GetBlockResponse': GetBlockResponse$json,
  '.explorer.v1.GetTransactionRequest': GetTransactionRequest$json,
  '.explorer.v1.GetTransactionResponse': GetTransactionResponse$json,
  '.explorer.v1.Transaction': Transaction$json,
  '.explorer.v1.Coin': Coin$json,
  '.explorer.v1.GetAddressRequest': GetAddressRequest$json,
  '.explorer.v1.GetAddressResponse': GetAddressResponse$json,
  '.explorer.v1.GetWithdrawalsRequest': GetWithdrawalsRequest$json,
  '.explorer.v1.GetWithdrawalsResponse': GetWithdrawalsResponse$json,
};

/// Descriptor for `ExplorerService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List explorerServiceDescriptor = $convert.base64Decode(
    'Cg9FeHBsb3JlclNlcnZpY2USUAoLR2V0T3ZlcnZpZXcSHy5leHBsb3Jlci52MS5HZXRPdmVydm'
    'lld1JlcXVlc3QaIC5leHBsb3Jlci52MS5HZXRPdmVydmlld1Jlc3BvbnNlEkcKCEdldEJsb2Nr'
    'EhwuZXhwbG9yZXIudjEuR2V0QmxvY2tSZXF1ZXN0Gh0uZXhwbG9yZXIudjEuR2V0QmxvY2tSZX'
    'Nwb25zZRJZCg5HZXRUcmFuc2FjdGlvbhIiLmV4cGxvcmVyLnYxLkdldFRyYW5zYWN0aW9uUmVx'
    'dWVzdBojLmV4cGxvcmVyLnYxLkdldFRyYW5zYWN0aW9uUmVzcG9uc2USTQoKR2V0QWRkcmVzcx'
    'IeLmV4cGxvcmVyLnYxLkdldEFkZHJlc3NSZXF1ZXN0Gh8uZXhwbG9yZXIudjEuR2V0QWRkcmVz'
    'c1Jlc3BvbnNlElkKDkdldFdpdGhkcmF3YWxzEiIuZXhwbG9yZXIudjEuR2V0V2l0aGRyYXdhbH'
    'NSZXF1ZXN0GiMuZXhwbG9yZXIudjEuR2V0V2l0aGRyYXdhbHNSZXNwb25zZQ==');

