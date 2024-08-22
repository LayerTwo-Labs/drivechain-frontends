//
//  Generated code. Do not modify.
//  source: drivechain/v1/drivechain.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use getNewAddressResponseDescriptor instead')
const GetNewAddressResponse$json = {
  '1': 'GetNewAddressResponse',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'index', '3': 2, '4': 1, '5': 13, '10': 'index'},
  ],
};

/// Descriptor for `GetNewAddressResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNewAddressResponseDescriptor = $convert.base64Decode(
    'ChVHZXROZXdBZGRyZXNzUmVzcG9uc2USGAoHYWRkcmVzcxgBIAEoCVIHYWRkcmVzcxIUCgVpbm'
    'RleBgCIAEoDVIFaW5kZXg=');

@$core.Deprecated('Use sendTransactionRequestDescriptor instead')
const SendTransactionRequest$json = {
  '1': 'SendTransactionRequest',
  '2': [
    {'1': 'destinations', '3': 1, '4': 3, '5': 11, '6': '.drivechain.v1.SendTransactionRequest.DestinationsEntry', '10': 'destinations'},
    {'1': 'satoshi_per_vbyte', '3': 2, '4': 1, '5': 1, '10': 'satoshiPerVbyte'},
  ],
  '3': [SendTransactionRequest_DestinationsEntry$json],
};

@$core.Deprecated('Use sendTransactionRequestDescriptor instead')
const SendTransactionRequest_DestinationsEntry$json = {
  '1': 'DestinationsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 4, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `SendTransactionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendTransactionRequestDescriptor = $convert.base64Decode(
    'ChZTZW5kVHJhbnNhY3Rpb25SZXF1ZXN0ElsKDGRlc3RpbmF0aW9ucxgBIAMoCzI3LmRyaXZlY2'
    'hhaW4udjEuU2VuZFRyYW5zYWN0aW9uUmVxdWVzdC5EZXN0aW5hdGlvbnNFbnRyeVIMZGVzdGlu'
    'YXRpb25zEioKEXNhdG9zaGlfcGVyX3ZieXRlGAIgASgBUg9zYXRvc2hpUGVyVmJ5dGUaPwoRRG'
    'VzdGluYXRpb25zRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAiABKARSBXZhbHVl'
    'OgI4AQ==');

@$core.Deprecated('Use sendTransactionResponseDescriptor instead')
const SendTransactionResponse$json = {
  '1': 'SendTransactionResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `SendTransactionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendTransactionResponseDescriptor = $convert.base64Decode(
    'ChdTZW5kVHJhbnNhY3Rpb25SZXNwb25zZRISCgR0eGlkGAEgASgJUgR0eGlk');

@$core.Deprecated('Use getBalanceResponseDescriptor instead')
const GetBalanceResponse$json = {
  '1': 'GetBalanceResponse',
  '2': [
    {'1': 'confirmed_satoshi', '3': 1, '4': 1, '5': 4, '10': 'confirmedSatoshi'},
    {'1': 'pending_satoshi', '3': 2, '4': 1, '5': 4, '10': 'pendingSatoshi'},
  ],
};

/// Descriptor for `GetBalanceResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBalanceResponseDescriptor = $convert.base64Decode(
    'ChJHZXRCYWxhbmNlUmVzcG9uc2USKwoRY29uZmlybWVkX3NhdG9zaGkYASABKARSEGNvbmZpcm'
    '1lZFNhdG9zaGkSJwoPcGVuZGluZ19zYXRvc2hpGAIgASgEUg5wZW5kaW5nU2F0b3NoaQ==');

@$core.Deprecated('Use listTransactionsResponseDescriptor instead')
const ListTransactionsResponse$json = {
  '1': 'ListTransactionsResponse',
  '2': [
    {'1': 'transactions', '3': 1, '4': 3, '5': 11, '6': '.drivechain.v1.Transaction', '10': 'transactions'},
  ],
};

/// Descriptor for `ListTransactionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listTransactionsResponseDescriptor = $convert.base64Decode(
    'ChhMaXN0VHJhbnNhY3Rpb25zUmVzcG9uc2USPgoMdHJhbnNhY3Rpb25zGAEgAygLMhouZHJpdm'
    'VjaGFpbi52MS5UcmFuc2FjdGlvblIMdHJhbnNhY3Rpb25z');

@$core.Deprecated('Use confirmationDescriptor instead')
const Confirmation$json = {
  '1': 'Confirmation',
  '2': [
    {'1': 'height', '3': 1, '4': 1, '5': 13, '10': 'height'},
    {'1': 'timestamp', '3': 2, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'timestamp'},
  ],
};

/// Descriptor for `Confirmation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List confirmationDescriptor = $convert.base64Decode(
    'CgxDb25maXJtYXRpb24SFgoGaGVpZ2h0GAEgASgNUgZoZWlnaHQSOAoJdGltZXN0YW1wGAIgAS'
    'gLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJdGltZXN0YW1w');

@$core.Deprecated('Use transactionDescriptor instead')
const Transaction$json = {
  '1': 'Transaction',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'fee_satoshi', '3': 2, '4': 1, '5': 4, '10': 'feeSatoshi'},
    {'1': 'received_satoshi', '3': 3, '4': 1, '5': 4, '10': 'receivedSatoshi'},
    {'1': 'sent_satoshi', '3': 4, '4': 1, '5': 4, '10': 'sentSatoshi'},
    {'1': 'confirmation_time', '3': 5, '4': 1, '5': 11, '6': '.drivechain.v1.Confirmation', '10': 'confirmationTime'},
  ],
};

/// Descriptor for `Transaction`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transactionDescriptor = $convert.base64Decode(
    'CgtUcmFuc2FjdGlvbhISCgR0eGlkGAEgASgJUgR0eGlkEh8KC2ZlZV9zYXRvc2hpGAIgASgEUg'
    'pmZWVTYXRvc2hpEikKEHJlY2VpdmVkX3NhdG9zaGkYAyABKARSD3JlY2VpdmVkU2F0b3NoaRIh'
    'CgxzZW50X3NhdG9zaGkYBCABKARSC3NlbnRTYXRvc2hpEkgKEWNvbmZpcm1hdGlvbl90aW1lGA'
    'UgASgLMhsuZHJpdmVjaGFpbi52MS5Db25maXJtYXRpb25SEGNvbmZpcm1hdGlvblRpbWU=');

@$core.Deprecated('Use listRecentBlocksResponseDescriptor instead')
const ListRecentBlocksResponse$json = {
  '1': 'ListRecentBlocksResponse',
  '2': [
    {'1': 'recent_blocks', '3': 4, '4': 3, '5': 11, '6': '.drivechain.v1.ListRecentBlocksResponse.RecentBlock', '10': 'recentBlocks'},
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
    'ChhMaXN0UmVjZW50QmxvY2tzUmVzcG9uc2USWAoNcmVjZW50X2Jsb2NrcxgEIAMoCzIzLmRyaX'
    'ZlY2hhaW4udjEuTGlzdFJlY2VudEJsb2Nrc1Jlc3BvbnNlLlJlY2VudEJsb2NrUgxyZWNlbnRC'
    'bG9ja3MafwoLUmVjZW50QmxvY2sSOQoKYmxvY2tfdGltZRgBIAEoCzIaLmdvb2dsZS5wcm90b2'
    'J1Zi5UaW1lc3RhbXBSCWJsb2NrVGltZRIhCgxibG9ja19oZWlnaHQYAiABKA1SC2Jsb2NrSGVp'
    'Z2h0EhIKBGhhc2gYAyABKAlSBGhhc2g=');

@$core.Deprecated('Use listUnconfirmedTransactionsResponseDescriptor instead')
const ListUnconfirmedTransactionsResponse$json = {
  '1': 'ListUnconfirmedTransactionsResponse',
  '2': [
    {'1': 'unconfirmed_transactions', '3': 1, '4': 3, '5': 11, '6': '.drivechain.v1.UnconfirmedTransaction', '10': 'unconfirmedTransactions'},
  ],
};

/// Descriptor for `ListUnconfirmedTransactionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listUnconfirmedTransactionsResponseDescriptor = $convert.base64Decode(
    'CiNMaXN0VW5jb25maXJtZWRUcmFuc2FjdGlvbnNSZXNwb25zZRJgChh1bmNvbmZpcm1lZF90cm'
    'Fuc2FjdGlvbnMYASADKAsyJS5kcml2ZWNoYWluLnYxLlVuY29uZmlybWVkVHJhbnNhY3Rpb25S'
    'F3VuY29uZmlybWVkVHJhbnNhY3Rpb25z');

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

