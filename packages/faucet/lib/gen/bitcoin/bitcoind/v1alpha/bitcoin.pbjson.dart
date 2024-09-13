//
//  Generated code. Do not modify.
//  source: bitcoin/bitcoind/v1alpha/bitcoin.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

import '../../../google/protobuf/timestamp.pbjson.dart' as $0;
import '../../../google/protobuf/wrappers.pbjson.dart' as $1;

@$core.Deprecated('Use getBlockchainInfoRequestDescriptor instead')
const GetBlockchainInfoRequest$json = {
  '1': 'GetBlockchainInfoRequest',
};

/// Descriptor for `GetBlockchainInfoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBlockchainInfoRequestDescriptor = $convert.base64Decode(
    'ChhHZXRCbG9ja2NoYWluSW5mb1JlcXVlc3Q=');

@$core.Deprecated('Use getBlockchainInfoResponseDescriptor instead')
const GetBlockchainInfoResponse$json = {
  '1': 'GetBlockchainInfoResponse',
  '2': [
    {'1': 'best_block_hash', '3': 1, '4': 1, '5': 9, '10': 'bestBlockHash'},
    {'1': 'blocks', '3': 5, '4': 1, '5': 13, '10': 'blocks'},
    {'1': 'headers', '3': 6, '4': 1, '5': 13, '10': 'headers'},
    {'1': 'chain', '3': 2, '4': 1, '5': 9, '10': 'chain'},
    {'1': 'chain_work', '3': 3, '4': 1, '5': 9, '10': 'chainWork'},
    {'1': 'initial_block_download', '3': 4, '4': 1, '5': 8, '10': 'initialBlockDownload'},
  ],
};

/// Descriptor for `GetBlockchainInfoResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBlockchainInfoResponseDescriptor = $convert.base64Decode(
    'ChlHZXRCbG9ja2NoYWluSW5mb1Jlc3BvbnNlEiYKD2Jlc3RfYmxvY2tfaGFzaBgBIAEoCVINYm'
    'VzdEJsb2NrSGFzaBIWCgZibG9ja3MYBSABKA1SBmJsb2NrcxIYCgdoZWFkZXJzGAYgASgNUgdo'
    'ZWFkZXJzEhQKBWNoYWluGAIgASgJUgVjaGFpbhIdCgpjaGFpbl93b3JrGAMgASgJUgljaGFpbl'
    'dvcmsSNAoWaW5pdGlhbF9ibG9ja19kb3dubG9hZBgEIAEoCFIUaW5pdGlhbEJsb2NrRG93bmxv'
    'YWQ=');

@$core.Deprecated('Use getNewAddressRequestDescriptor instead')
const GetNewAddressRequest$json = {
  '1': 'GetNewAddressRequest',
  '2': [
    {'1': 'label', '3': 1, '4': 1, '5': 9, '10': 'label'},
    {'1': 'address_type', '3': 2, '4': 1, '5': 9, '10': 'addressType'},
    {'1': 'wallet', '3': 3, '4': 1, '5': 9, '10': 'wallet'},
  ],
};

/// Descriptor for `GetNewAddressRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNewAddressRequestDescriptor = $convert.base64Decode(
    'ChRHZXROZXdBZGRyZXNzUmVxdWVzdBIUCgVsYWJlbBgBIAEoCVIFbGFiZWwSIQoMYWRkcmVzc1'
    '90eXBlGAIgASgJUgthZGRyZXNzVHlwZRIWCgZ3YWxsZXQYAyABKAlSBndhbGxldA==');

@$core.Deprecated('Use getNewAddressResponseDescriptor instead')
const GetNewAddressResponse$json = {
  '1': 'GetNewAddressResponse',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
  ],
};

/// Descriptor for `GetNewAddressResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNewAddressResponseDescriptor = $convert.base64Decode(
    'ChVHZXROZXdBZGRyZXNzUmVzcG9uc2USGAoHYWRkcmVzcxgBIAEoCVIHYWRkcmVzcw==');

@$core.Deprecated('Use getWalletInfoRequestDescriptor instead')
const GetWalletInfoRequest$json = {
  '1': 'GetWalletInfoRequest',
  '2': [
    {'1': 'wallet', '3': 1, '4': 1, '5': 9, '10': 'wallet'},
  ],
};

/// Descriptor for `GetWalletInfoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getWalletInfoRequestDescriptor = $convert.base64Decode(
    'ChRHZXRXYWxsZXRJbmZvUmVxdWVzdBIWCgZ3YWxsZXQYASABKAlSBndhbGxldA==');

@$core.Deprecated('Use getWalletInfoResponseDescriptor instead')
const GetWalletInfoResponse$json = {
  '1': 'GetWalletInfoResponse',
  '2': [
    {'1': 'wallet_name', '3': 1, '4': 1, '5': 9, '10': 'walletName'},
    {'1': 'wallet_version', '3': 2, '4': 1, '5': 3, '10': 'walletVersion'},
    {'1': 'format', '3': 3, '4': 1, '5': 9, '10': 'format'},
    {'1': 'tx_count', '3': 7, '4': 1, '5': 3, '10': 'txCount'},
    {'1': 'key_pool_size', '3': 8, '4': 1, '5': 3, '10': 'keyPoolSize'},
    {'1': 'key_pool_size_hd_internal', '3': 9, '4': 1, '5': 3, '10': 'keyPoolSizeHdInternal'},
    {'1': 'pay_tx_fee', '3': 10, '4': 1, '5': 1, '10': 'payTxFee'},
    {'1': 'private_keys_enabled', '3': 11, '4': 1, '5': 8, '10': 'privateKeysEnabled'},
    {'1': 'avoid_reuse', '3': 12, '4': 1, '5': 8, '10': 'avoidReuse'},
    {'1': 'scanning', '3': 13, '4': 1, '5': 11, '6': '.bitcoin.bitcoind.v1alpha.WalletScan', '10': 'scanning'},
    {'1': 'descriptors', '3': 14, '4': 1, '5': 8, '10': 'descriptors'},
    {'1': 'external_signer', '3': 15, '4': 1, '5': 8, '10': 'externalSigner'},
  ],
};

/// Descriptor for `GetWalletInfoResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getWalletInfoResponseDescriptor = $convert.base64Decode(
    'ChVHZXRXYWxsZXRJbmZvUmVzcG9uc2USHwoLd2FsbGV0X25hbWUYASABKAlSCndhbGxldE5hbW'
    'USJQoOd2FsbGV0X3ZlcnNpb24YAiABKANSDXdhbGxldFZlcnNpb24SFgoGZm9ybWF0GAMgASgJ'
    'UgZmb3JtYXQSGQoIdHhfY291bnQYByABKANSB3R4Q291bnQSIgoNa2V5X3Bvb2xfc2l6ZRgIIA'
    'EoA1ILa2V5UG9vbFNpemUSOAoZa2V5X3Bvb2xfc2l6ZV9oZF9pbnRlcm5hbBgJIAEoA1IVa2V5'
    'UG9vbFNpemVIZEludGVybmFsEhwKCnBheV90eF9mZWUYCiABKAFSCHBheVR4RmVlEjAKFHByaX'
    'ZhdGVfa2V5c19lbmFibGVkGAsgASgIUhJwcml2YXRlS2V5c0VuYWJsZWQSHwoLYXZvaWRfcmV1'
    'c2UYDCABKAhSCmF2b2lkUmV1c2USQAoIc2Nhbm5pbmcYDSABKAsyJC5iaXRjb2luLmJpdGNvaW'
    '5kLnYxYWxwaGEuV2FsbGV0U2NhblIIc2Nhbm5pbmcSIAoLZGVzY3JpcHRvcnMYDiABKAhSC2Rl'
    'c2NyaXB0b3JzEicKD2V4dGVybmFsX3NpZ25lchgPIAEoCFIOZXh0ZXJuYWxTaWduZXI=');

@$core.Deprecated('Use getBalancesRequestDescriptor instead')
const GetBalancesRequest$json = {
  '1': 'GetBalancesRequest',
  '2': [
    {'1': 'wallet', '3': 1, '4': 1, '5': 9, '10': 'wallet'},
  ],
};

/// Descriptor for `GetBalancesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBalancesRequestDescriptor = $convert.base64Decode(
    'ChJHZXRCYWxhbmNlc1JlcXVlc3QSFgoGd2FsbGV0GAEgASgJUgZ3YWxsZXQ=');

@$core.Deprecated('Use getBalancesResponseDescriptor instead')
const GetBalancesResponse$json = {
  '1': 'GetBalancesResponse',
  '2': [
    {'1': 'mine', '3': 1, '4': 1, '5': 11, '6': '.bitcoin.bitcoind.v1alpha.GetBalancesResponse.Mine', '10': 'mine'},
    {'1': 'watchonly', '3': 2, '4': 1, '5': 11, '6': '.bitcoin.bitcoind.v1alpha.GetBalancesResponse.Watchonly', '10': 'watchonly'},
  ],
  '3': [GetBalancesResponse_Mine$json, GetBalancesResponse_Watchonly$json],
};

@$core.Deprecated('Use getBalancesResponseDescriptor instead')
const GetBalancesResponse_Mine$json = {
  '1': 'Mine',
  '2': [
    {'1': 'trusted', '3': 1, '4': 1, '5': 1, '10': 'trusted'},
    {'1': 'untrusted_pending', '3': 2, '4': 1, '5': 1, '10': 'untrustedPending'},
    {'1': 'immature', '3': 3, '4': 1, '5': 1, '10': 'immature'},
    {'1': 'used', '3': 4, '4': 1, '5': 1, '10': 'used'},
  ],
};

@$core.Deprecated('Use getBalancesResponseDescriptor instead')
const GetBalancesResponse_Watchonly$json = {
  '1': 'Watchonly',
  '2': [
    {'1': 'trusted', '3': 1, '4': 1, '5': 1, '10': 'trusted'},
    {'1': 'untrusted_pending', '3': 2, '4': 1, '5': 1, '10': 'untrustedPending'},
    {'1': 'immature', '3': 3, '4': 1, '5': 1, '10': 'immature'},
  ],
};

/// Descriptor for `GetBalancesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBalancesResponseDescriptor = $convert.base64Decode(
    'ChNHZXRCYWxhbmNlc1Jlc3BvbnNlEkYKBG1pbmUYASABKAsyMi5iaXRjb2luLmJpdGNvaW5kLn'
    'YxYWxwaGEuR2V0QmFsYW5jZXNSZXNwb25zZS5NaW5lUgRtaW5lElUKCXdhdGNob25seRgCIAEo'
    'CzI3LmJpdGNvaW4uYml0Y29pbmQudjFhbHBoYS5HZXRCYWxhbmNlc1Jlc3BvbnNlLldhdGNob2'
    '5seVIJd2F0Y2hvbmx5Gn0KBE1pbmUSGAoHdHJ1c3RlZBgBIAEoAVIHdHJ1c3RlZBIrChF1bnRy'
    'dXN0ZWRfcGVuZGluZxgCIAEoAVIQdW50cnVzdGVkUGVuZGluZxIaCghpbW1hdHVyZRgDIAEoAV'
    'IIaW1tYXR1cmUSEgoEdXNlZBgEIAEoAVIEdXNlZBpuCglXYXRjaG9ubHkSGAoHdHJ1c3RlZBgB'
    'IAEoAVIHdHJ1c3RlZBIrChF1bnRydXN0ZWRfcGVuZGluZxgCIAEoAVIQdW50cnVzdGVkUGVuZG'
    'luZxIaCghpbW1hdHVyZRgDIAEoAVIIaW1tYXR1cmU=');

@$core.Deprecated('Use walletScanDescriptor instead')
const WalletScan$json = {
  '1': 'WalletScan',
  '2': [
    {'1': 'duration', '3': 1, '4': 1, '5': 3, '10': 'duration'},
    {'1': 'progress', '3': 2, '4': 1, '5': 1, '10': 'progress'},
  ],
};

/// Descriptor for `WalletScan`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List walletScanDescriptor = $convert.base64Decode(
    'CgpXYWxsZXRTY2FuEhoKCGR1cmF0aW9uGAEgASgDUghkdXJhdGlvbhIaCghwcm9ncmVzcxgCIA'
    'EoAVIIcHJvZ3Jlc3M=');

@$core.Deprecated('Use getTransactionRequestDescriptor instead')
const GetTransactionRequest$json = {
  '1': 'GetTransactionRequest',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'include_watchonly', '3': 2, '4': 1, '5': 8, '10': 'includeWatchonly'},
    {'1': 'verbose', '3': 3, '4': 1, '5': 8, '10': 'verbose'},
    {'1': 'wallet', '3': 4, '4': 1, '5': 9, '10': 'wallet'},
  ],
};

/// Descriptor for `GetTransactionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTransactionRequestDescriptor = $convert.base64Decode(
    'ChVHZXRUcmFuc2FjdGlvblJlcXVlc3QSEgoEdHhpZBgBIAEoCVIEdHhpZBIrChFpbmNsdWRlX3'
    'dhdGNob25seRgCIAEoCFIQaW5jbHVkZVdhdGNob25seRIYCgd2ZXJib3NlGAMgASgIUgd2ZXJi'
    'b3NlEhYKBndhbGxldBgEIAEoCVIGd2FsbGV0');

@$core.Deprecated('Use getTransactionResponseDescriptor instead')
const GetTransactionResponse$json = {
  '1': 'GetTransactionResponse',
  '2': [
    {'1': 'amount', '3': 1, '4': 1, '5': 1, '10': 'amount'},
    {'1': 'fee', '3': 2, '4': 1, '5': 1, '10': 'fee'},
    {'1': 'confirmations', '3': 3, '4': 1, '5': 5, '10': 'confirmations'},
    {'1': 'block_hash', '3': 6, '4': 1, '5': 9, '10': 'blockHash'},
    {'1': 'block_index', '3': 8, '4': 1, '5': 13, '10': 'blockIndex'},
    {'1': 'block_time', '3': 9, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'blockTime'},
    {'1': 'txid', '3': 10, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'wallet_conflicts', '3': 12, '4': 3, '5': 9, '10': 'walletConflicts'},
    {'1': 'replaced_by_txid', '3': 13, '4': 1, '5': 9, '10': 'replacedByTxid'},
    {'1': 'replaces_txid', '3': 14, '4': 1, '5': 9, '10': 'replacesTxid'},
    {'1': 'time', '3': 17, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'time'},
    {'1': 'time_received', '3': 18, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'timeReceived'},
    {'1': 'bip125_replaceable', '3': 19, '4': 1, '5': 14, '6': '.bitcoin.bitcoind.v1alpha.GetTransactionResponse.Replaceable', '10': 'bip125Replaceable'},
    {'1': 'details', '3': 21, '4': 3, '5': 11, '6': '.bitcoin.bitcoind.v1alpha.GetTransactionResponse.Details', '10': 'details'},
    {'1': 'hex', '3': 22, '4': 1, '5': 9, '10': 'hex'},
  ],
  '3': [GetTransactionResponse_Details$json],
  '4': [GetTransactionResponse_Replaceable$json, GetTransactionResponse_Category$json],
};

@$core.Deprecated('Use getTransactionResponseDescriptor instead')
const GetTransactionResponse_Details$json = {
  '1': 'Details',
  '2': [
    {'1': 'involves_watch_only', '3': 1, '4': 1, '5': 8, '10': 'involvesWatchOnly'},
    {'1': 'address', '3': 2, '4': 1, '5': 9, '10': 'address'},
    {'1': 'category', '3': 3, '4': 1, '5': 14, '6': '.bitcoin.bitcoind.v1alpha.GetTransactionResponse.Category', '10': 'category'},
    {'1': 'amount', '3': 4, '4': 1, '5': 1, '10': 'amount'},
    {'1': 'vout', '3': 6, '4': 1, '5': 13, '10': 'vout'},
    {'1': 'fee', '3': 7, '4': 1, '5': 1, '10': 'fee'},
  ],
};

@$core.Deprecated('Use getTransactionResponseDescriptor instead')
const GetTransactionResponse_Replaceable$json = {
  '1': 'Replaceable',
  '2': [
    {'1': 'REPLACEABLE_UNSPECIFIED', '2': 0},
    {'1': 'REPLACEABLE_YES', '2': 1},
    {'1': 'REPLACEABLE_NO', '2': 2},
  ],
};

@$core.Deprecated('Use getTransactionResponseDescriptor instead')
const GetTransactionResponse_Category$json = {
  '1': 'Category',
  '2': [
    {'1': 'CATEGORY_UNSPECIFIED', '2': 0},
    {'1': 'CATEGORY_SEND', '2': 1},
    {'1': 'CATEGORY_RECEIVE', '2': 2},
    {'1': 'CATEGORY_GENERATE', '2': 3},
    {'1': 'CATEGORY_IMMATURE', '2': 4},
    {'1': 'CATEGORY_ORPHAN', '2': 5},
  ],
};

/// Descriptor for `GetTransactionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTransactionResponseDescriptor = $convert.base64Decode(
    'ChZHZXRUcmFuc2FjdGlvblJlc3BvbnNlEhYKBmFtb3VudBgBIAEoAVIGYW1vdW50EhAKA2ZlZR'
    'gCIAEoAVIDZmVlEiQKDWNvbmZpcm1hdGlvbnMYAyABKAVSDWNvbmZpcm1hdGlvbnMSHQoKYmxv'
    'Y2tfaGFzaBgGIAEoCVIJYmxvY2tIYXNoEh8KC2Jsb2NrX2luZGV4GAggASgNUgpibG9ja0luZG'
    'V4EjkKCmJsb2NrX3RpbWUYCSABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUglibG9j'
    'a1RpbWUSEgoEdHhpZBgKIAEoCVIEdHhpZBIpChB3YWxsZXRfY29uZmxpY3RzGAwgAygJUg93YW'
    'xsZXRDb25mbGljdHMSKAoQcmVwbGFjZWRfYnlfdHhpZBgNIAEoCVIOcmVwbGFjZWRCeVR4aWQS'
    'IwoNcmVwbGFjZXNfdHhpZBgOIAEoCVIMcmVwbGFjZXNUeGlkEi4KBHRpbWUYESABKAsyGi5nb2'
    '9nbGUucHJvdG9idWYuVGltZXN0YW1wUgR0aW1lEj8KDXRpbWVfcmVjZWl2ZWQYEiABKAsyGi5n'
    'b29nbGUucHJvdG9idWYuVGltZXN0YW1wUgx0aW1lUmVjZWl2ZWQSawoSYmlwMTI1X3JlcGxhY2'
    'VhYmxlGBMgASgOMjwuYml0Y29pbi5iaXRjb2luZC52MWFscGhhLkdldFRyYW5zYWN0aW9uUmVz'
    'cG9uc2UuUmVwbGFjZWFibGVSEWJpcDEyNVJlcGxhY2VhYmxlElIKB2RldGFpbHMYFSADKAsyOC'
    '5iaXRjb2luLmJpdGNvaW5kLnYxYWxwaGEuR2V0VHJhbnNhY3Rpb25SZXNwb25zZS5EZXRhaWxz'
    'UgdkZXRhaWxzEhAKA2hleBgWIAEoCVIDaGV4GugBCgdEZXRhaWxzEi4KE2ludm9sdmVzX3dhdG'
    'NoX29ubHkYASABKAhSEWludm9sdmVzV2F0Y2hPbmx5EhgKB2FkZHJlc3MYAiABKAlSB2FkZHJl'
    'c3MSVQoIY2F0ZWdvcnkYAyABKA4yOS5iaXRjb2luLmJpdGNvaW5kLnYxYWxwaGEuR2V0VHJhbn'
    'NhY3Rpb25SZXNwb25zZS5DYXRlZ29yeVIIY2F0ZWdvcnkSFgoGYW1vdW50GAQgASgBUgZhbW91'
    'bnQSEgoEdm91dBgGIAEoDVIEdm91dBIQCgNmZWUYByABKAFSA2ZlZSJTCgtSZXBsYWNlYWJsZR'
    'IbChdSRVBMQUNFQUJMRV9VTlNQRUNJRklFRBAAEhMKD1JFUExBQ0VBQkxFX1lFUxABEhIKDlJF'
    'UExBQ0VBQkxFX05PEAIikAEKCENhdGVnb3J5EhgKFENBVEVHT1JZX1VOU1BFQ0lGSUVEEAASEQ'
    'oNQ0FURUdPUllfU0VORBABEhQKEENBVEVHT1JZX1JFQ0VJVkUQAhIVChFDQVRFR09SWV9HRU5F'
    'UkFURRADEhUKEUNBVEVHT1JZX0lNTUFUVVJFEAQSEwoPQ0FURUdPUllfT1JQSEFOEAU=');

@$core.Deprecated('Use getRawTransactionRequestDescriptor instead')
const GetRawTransactionRequest$json = {
  '1': 'GetRawTransactionRequest',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'verbose', '3': 2, '4': 1, '5': 8, '10': 'verbose'},
  ],
};

/// Descriptor for `GetRawTransactionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getRawTransactionRequestDescriptor = $convert.base64Decode(
    'ChhHZXRSYXdUcmFuc2FjdGlvblJlcXVlc3QSEgoEdHhpZBgBIAEoCVIEdHhpZBIYCgd2ZXJib3'
    'NlGAIgASgIUgd2ZXJib3Nl');

@$core.Deprecated('Use inputDescriptor instead')
const Input$json = {
  '1': 'Input',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'vout', '3': 2, '4': 1, '5': 13, '10': 'vout'},
  ],
};

/// Descriptor for `Input`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List inputDescriptor = $convert.base64Decode(
    'CgVJbnB1dBISCgR0eGlkGAEgASgJUgR0eGlkEhIKBHZvdXQYAiABKA1SBHZvdXQ=');

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
    {'1': 'n', '3': 2, '4': 1, '5': 13, '10': 'n'},
    {'1': 'script_pub_key', '3': 3, '4': 1, '5': 11, '6': '.bitcoin.bitcoind.v1alpha.ScriptPubKey', '10': 'scriptPubKey'},
  ],
};

/// Descriptor for `Output`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List outputDescriptor = $convert.base64Decode(
    'CgZPdXRwdXQSFgoGYW1vdW50GAEgASgBUgZhbW91bnQSDAoBbhgCIAEoDVIBbhJMCg5zY3JpcH'
    'RfcHViX2tleRgDIAEoCzImLmJpdGNvaW4uYml0Y29pbmQudjFhbHBoYS5TY3JpcHRQdWJLZXlS'
    'DHNjcmlwdFB1YktleQ==');

@$core.Deprecated('Use getRawTransactionResponseDescriptor instead')
const GetRawTransactionResponse$json = {
  '1': 'GetRawTransactionResponse',
  '2': [
    {'1': 'tx', '3': 1, '4': 1, '5': 11, '6': '.bitcoin.bitcoind.v1alpha.RawTransaction', '10': 'tx'},
    {'1': 'inputs', '3': 2, '4': 3, '5': 11, '6': '.bitcoin.bitcoind.v1alpha.Input', '10': 'inputs'},
    {'1': 'outputs', '3': 3, '4': 3, '5': 11, '6': '.bitcoin.bitcoind.v1alpha.Output', '10': 'outputs'},
    {'1': 'blockhash', '3': 4, '4': 1, '5': 9, '10': 'blockhash'},
    {'1': 'confirmations', '3': 5, '4': 1, '5': 13, '10': 'confirmations'},
    {'1': 'time', '3': 6, '4': 1, '5': 3, '10': 'time'},
    {'1': 'blocktime', '3': 7, '4': 1, '5': 3, '10': 'blocktime'},
  ],
};

/// Descriptor for `GetRawTransactionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getRawTransactionResponseDescriptor = $convert.base64Decode(
    'ChlHZXRSYXdUcmFuc2FjdGlvblJlc3BvbnNlEjgKAnR4GAEgASgLMiguYml0Y29pbi5iaXRjb2'
    'luZC52MWFscGhhLlJhd1RyYW5zYWN0aW9uUgJ0eBI3CgZpbnB1dHMYAiADKAsyHy5iaXRjb2lu'
    'LmJpdGNvaW5kLnYxYWxwaGEuSW5wdXRSBmlucHV0cxI6CgdvdXRwdXRzGAMgAygLMiAuYml0Y2'
    '9pbi5iaXRjb2luZC52MWFscGhhLk91dHB1dFIHb3V0cHV0cxIcCglibG9ja2hhc2gYBCABKAlS'
    'CWJsb2NraGFzaBIkCg1jb25maXJtYXRpb25zGAUgASgNUg1jb25maXJtYXRpb25zEhIKBHRpbW'
    'UYBiABKANSBHRpbWUSHAoJYmxvY2t0aW1lGAcgASgDUglibG9ja3RpbWU=');

@$core.Deprecated('Use sendRequestDescriptor instead')
const SendRequest$json = {
  '1': 'SendRequest',
  '2': [
    {'1': 'destinations', '3': 1, '4': 3, '5': 11, '6': '.bitcoin.bitcoind.v1alpha.SendRequest.DestinationsEntry', '10': 'destinations'},
    {'1': 'conf_target', '3': 2, '4': 1, '5': 13, '10': 'confTarget'},
    {'1': 'wallet', '3': 3, '4': 1, '5': 9, '10': 'wallet'},
    {'1': 'include_unsafe', '3': 4, '4': 1, '5': 8, '10': 'includeUnsafe'},
    {'1': 'subtract_fee_from_outputs', '3': 5, '4': 3, '5': 9, '10': 'subtractFeeFromOutputs'},
    {'1': 'add_to_wallet', '3': 6, '4': 1, '5': 11, '6': '.google.protobuf.BoolValue', '10': 'addToWallet'},
    {'1': 'fee_rate', '3': 7, '4': 1, '5': 1, '10': 'feeRate'},
  ],
  '3': [SendRequest_DestinationsEntry$json],
};

@$core.Deprecated('Use sendRequestDescriptor instead')
const SendRequest_DestinationsEntry$json = {
  '1': 'DestinationsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 1, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `SendRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendRequestDescriptor = $convert.base64Decode(
    'CgtTZW5kUmVxdWVzdBJbCgxkZXN0aW5hdGlvbnMYASADKAsyNy5iaXRjb2luLmJpdGNvaW5kLn'
    'YxYWxwaGEuU2VuZFJlcXVlc3QuRGVzdGluYXRpb25zRW50cnlSDGRlc3RpbmF0aW9ucxIfCgtj'
    'b25mX3RhcmdldBgCIAEoDVIKY29uZlRhcmdldBIWCgZ3YWxsZXQYAyABKAlSBndhbGxldBIlCg'
    '5pbmNsdWRlX3Vuc2FmZRgEIAEoCFINaW5jbHVkZVVuc2FmZRI5ChlzdWJ0cmFjdF9mZWVfZnJv'
    'bV9vdXRwdXRzGAUgAygJUhZzdWJ0cmFjdEZlZUZyb21PdXRwdXRzEj4KDWFkZF90b193YWxsZX'
    'QYBiABKAsyGi5nb29nbGUucHJvdG9idWYuQm9vbFZhbHVlUgthZGRUb1dhbGxldBIZCghmZWVf'
    'cmF0ZRgHIAEoAVIHZmVlUmF0ZRo/ChFEZXN0aW5hdGlvbnNFbnRyeRIQCgNrZXkYASABKAlSA2'
    'tleRIUCgV2YWx1ZRgCIAEoAVIFdmFsdWU6AjgB');

@$core.Deprecated('Use sendResponseDescriptor instead')
const SendResponse$json = {
  '1': 'SendResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'complete', '3': 2, '4': 1, '5': 8, '10': 'complete'},
    {'1': 'tx', '3': 3, '4': 1, '5': 11, '6': '.bitcoin.bitcoind.v1alpha.RawTransaction', '10': 'tx'},
  ],
};

/// Descriptor for `SendResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendResponseDescriptor = $convert.base64Decode(
    'CgxTZW5kUmVzcG9uc2USEgoEdHhpZBgBIAEoCVIEdHhpZBIaCghjb21wbGV0ZRgCIAEoCFIIY2'
    '9tcGxldGUSOAoCdHgYAyABKAsyKC5iaXRjb2luLmJpdGNvaW5kLnYxYWxwaGEuUmF3VHJhbnNh'
    'Y3Rpb25SAnR4');

@$core.Deprecated('Use sendToAddressRequestDescriptor instead')
const SendToAddressRequest$json = {
  '1': 'SendToAddressRequest',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'amount', '3': 2, '4': 1, '5': 1, '10': 'amount'},
    {'1': 'comment', '3': 3, '4': 1, '5': 9, '10': 'comment'},
    {'1': 'comment_to', '3': 4, '4': 1, '5': 9, '10': 'commentTo'},
    {'1': 'wallet', '3': 5, '4': 1, '5': 9, '10': 'wallet'},
  ],
};

/// Descriptor for `SendToAddressRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendToAddressRequestDescriptor = $convert.base64Decode(
    'ChRTZW5kVG9BZGRyZXNzUmVxdWVzdBIYCgdhZGRyZXNzGAEgASgJUgdhZGRyZXNzEhYKBmFtb3'
    'VudBgCIAEoAVIGYW1vdW50EhgKB2NvbW1lbnQYAyABKAlSB2NvbW1lbnQSHQoKY29tbWVudF90'
    'bxgEIAEoCVIJY29tbWVudFRvEhYKBndhbGxldBgFIAEoCVIGd2FsbGV0');

@$core.Deprecated('Use sendToAddressResponseDescriptor instead')
const SendToAddressResponse$json = {
  '1': 'SendToAddressResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `SendToAddressResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendToAddressResponseDescriptor = $convert.base64Decode(
    'ChVTZW5kVG9BZGRyZXNzUmVzcG9uc2USEgoEdHhpZBgBIAEoCVIEdHhpZA==');

@$core.Deprecated('Use estimateSmartFeeRequestDescriptor instead')
const EstimateSmartFeeRequest$json = {
  '1': 'EstimateSmartFeeRequest',
  '2': [
    {'1': 'conf_target', '3': 1, '4': 1, '5': 3, '10': 'confTarget'},
    {'1': 'estimate_mode', '3': 2, '4': 1, '5': 14, '6': '.bitcoin.bitcoind.v1alpha.EstimateSmartFeeRequest.EstimateMode', '10': 'estimateMode'},
  ],
  '4': [EstimateSmartFeeRequest_EstimateMode$json],
};

@$core.Deprecated('Use estimateSmartFeeRequestDescriptor instead')
const EstimateSmartFeeRequest_EstimateMode$json = {
  '1': 'EstimateMode',
  '2': [
    {'1': 'ESTIMATE_MODE_UNSPECIFIED', '2': 0},
    {'1': 'ESTIMATE_MODE_ECONOMICAL', '2': 1},
    {'1': 'ESTIMATE_MODE_CONSERVATIVE', '2': 2},
  ],
};

/// Descriptor for `EstimateSmartFeeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List estimateSmartFeeRequestDescriptor = $convert.base64Decode(
    'ChdFc3RpbWF0ZVNtYXJ0RmVlUmVxdWVzdBIfCgtjb25mX3RhcmdldBgBIAEoA1IKY29uZlRhcm'
    'dldBJjCg1lc3RpbWF0ZV9tb2RlGAIgASgOMj4uYml0Y29pbi5iaXRjb2luZC52MWFscGhhLkVz'
    'dGltYXRlU21hcnRGZWVSZXF1ZXN0LkVzdGltYXRlTW9kZVIMZXN0aW1hdGVNb2RlImsKDEVzdG'
    'ltYXRlTW9kZRIdChlFU1RJTUFURV9NT0RFX1VOU1BFQ0lGSUVEEAASHAoYRVNUSU1BVEVfTU9E'
    'RV9FQ09OT01JQ0FMEAESHgoaRVNUSU1BVEVfTU9ERV9DT05TRVJWQVRJVkUQAg==');

@$core.Deprecated('Use estimateSmartFeeResponseDescriptor instead')
const EstimateSmartFeeResponse$json = {
  '1': 'EstimateSmartFeeResponse',
  '2': [
    {'1': 'fee_rate', '3': 1, '4': 1, '5': 1, '10': 'feeRate'},
    {'1': 'errors', '3': 2, '4': 3, '5': 9, '10': 'errors'},
    {'1': 'blocks', '3': 3, '4': 1, '5': 3, '10': 'blocks'},
  ],
};

/// Descriptor for `EstimateSmartFeeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List estimateSmartFeeResponseDescriptor = $convert.base64Decode(
    'ChhFc3RpbWF0ZVNtYXJ0RmVlUmVzcG9uc2USGQoIZmVlX3JhdGUYASABKAFSB2ZlZVJhdGUSFg'
    'oGZXJyb3JzGAIgAygJUgZlcnJvcnMSFgoGYmxvY2tzGAMgASgDUgZibG9ja3M=');

@$core.Deprecated('Use decodeRawTransactionRequestDescriptor instead')
const DecodeRawTransactionRequest$json = {
  '1': 'DecodeRawTransactionRequest',
  '2': [
    {'1': 'tx', '3': 1, '4': 1, '5': 11, '6': '.bitcoin.bitcoind.v1alpha.RawTransaction', '10': 'tx'},
  ],
};

/// Descriptor for `DecodeRawTransactionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List decodeRawTransactionRequestDescriptor = $convert.base64Decode(
    'ChtEZWNvZGVSYXdUcmFuc2FjdGlvblJlcXVlc3QSOAoCdHgYASABKAsyKC5iaXRjb2luLmJpdG'
    'NvaW5kLnYxYWxwaGEuUmF3VHJhbnNhY3Rpb25SAnR4');

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
    {'1': 'inputs', '3': 8, '4': 3, '5': 11, '6': '.bitcoin.bitcoind.v1alpha.Input', '10': 'inputs'},
    {'1': 'outputs', '3': 9, '4': 3, '5': 11, '6': '.bitcoin.bitcoind.v1alpha.Output', '10': 'outputs'},
  ],
};

/// Descriptor for `DecodeRawTransactionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List decodeRawTransactionResponseDescriptor = $convert.base64Decode(
    'ChxEZWNvZGVSYXdUcmFuc2FjdGlvblJlc3BvbnNlEhIKBHR4aWQYASABKAlSBHR4aWQSEgoEaG'
    'FzaBgCIAEoCVIEaGFzaBISCgRzaXplGAMgASgNUgRzaXplEiEKDHZpcnR1YWxfc2l6ZRgEIAEo'
    'DVILdmlydHVhbFNpemUSFgoGd2VpZ2h0GAUgASgNUgZ3ZWlnaHQSGAoHdmVyc2lvbhgGIAEoDV'
    'IHdmVyc2lvbhIaCghsb2NrdGltZRgHIAEoDVIIbG9ja3RpbWUSNwoGaW5wdXRzGAggAygLMh8u'
    'Yml0Y29pbi5iaXRjb2luZC52MWFscGhhLklucHV0UgZpbnB1dHMSOgoHb3V0cHV0cxgJIAMoCz'
    'IgLmJpdGNvaW4uYml0Y29pbmQudjFhbHBoYS5PdXRwdXRSB291dHB1dHM=');

@$core.Deprecated('Use importDescriptorsRequestDescriptor instead')
const ImportDescriptorsRequest$json = {
  '1': 'ImportDescriptorsRequest',
  '2': [
    {'1': 'wallet', '3': 1, '4': 1, '5': 9, '10': 'wallet'},
    {'1': 'requests', '3': 2, '4': 3, '5': 11, '6': '.bitcoin.bitcoind.v1alpha.ImportDescriptorsRequest.Request', '10': 'requests'},
  ],
  '3': [ImportDescriptorsRequest_Request$json],
};

@$core.Deprecated('Use importDescriptorsRequestDescriptor instead')
const ImportDescriptorsRequest_Request$json = {
  '1': 'Request',
  '2': [
    {'1': 'descriptor', '3': 1, '4': 1, '5': 9, '10': 'descriptor'},
    {'1': 'active', '3': 2, '4': 1, '5': 8, '10': 'active'},
    {'1': 'range_start', '3': 3, '4': 1, '5': 13, '10': 'rangeStart'},
    {'1': 'range_end', '3': 4, '4': 1, '5': 13, '10': 'rangeEnd'},
    {'1': 'timestamp', '3': 5, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'timestamp'},
    {'1': 'internal', '3': 6, '4': 1, '5': 8, '10': 'internal'},
    {'1': 'label', '3': 7, '4': 1, '5': 9, '10': 'label'},
  ],
};

/// Descriptor for `ImportDescriptorsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importDescriptorsRequestDescriptor = $convert.base64Decode(
    'ChhJbXBvcnREZXNjcmlwdG9yc1JlcXVlc3QSFgoGd2FsbGV0GAEgASgJUgZ3YWxsZXQSVgoIcm'
    'VxdWVzdHMYAiADKAsyOi5iaXRjb2luLmJpdGNvaW5kLnYxYWxwaGEuSW1wb3J0RGVzY3JpcHRv'
    'cnNSZXF1ZXN0LlJlcXVlc3RSCHJlcXVlc3RzGusBCgdSZXF1ZXN0Eh4KCmRlc2NyaXB0b3IYAS'
    'ABKAlSCmRlc2NyaXB0b3ISFgoGYWN0aXZlGAIgASgIUgZhY3RpdmUSHwoLcmFuZ2Vfc3RhcnQY'
    'AyABKA1SCnJhbmdlU3RhcnQSGwoJcmFuZ2VfZW5kGAQgASgNUghyYW5nZUVuZBI4Cgl0aW1lc3'
    'RhbXAYBSABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgl0aW1lc3RhbXASGgoIaW50'
    'ZXJuYWwYBiABKAhSCGludGVybmFsEhQKBWxhYmVsGAcgASgJUgVsYWJlbA==');

@$core.Deprecated('Use importDescriptorsResponseDescriptor instead')
const ImportDescriptorsResponse$json = {
  '1': 'ImportDescriptorsResponse',
  '2': [
    {'1': 'responses', '3': 1, '4': 3, '5': 11, '6': '.bitcoin.bitcoind.v1alpha.ImportDescriptorsResponse.Response', '10': 'responses'},
  ],
  '3': [ImportDescriptorsResponse_Error$json, ImportDescriptorsResponse_Response$json],
};

@$core.Deprecated('Use importDescriptorsResponseDescriptor instead')
const ImportDescriptorsResponse_Error$json = {
  '1': 'Error',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 5, '10': 'code'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

@$core.Deprecated('Use importDescriptorsResponseDescriptor instead')
const ImportDescriptorsResponse_Response$json = {
  '1': 'Response',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'warnings', '3': 2, '4': 3, '5': 9, '10': 'warnings'},
    {'1': 'error', '3': 3, '4': 1, '5': 11, '6': '.bitcoin.bitcoind.v1alpha.ImportDescriptorsResponse.Error', '10': 'error'},
  ],
};

/// Descriptor for `ImportDescriptorsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importDescriptorsResponseDescriptor = $convert.base64Decode(
    'ChlJbXBvcnREZXNjcmlwdG9yc1Jlc3BvbnNlEloKCXJlc3BvbnNlcxgBIAMoCzI8LmJpdGNvaW'
    '4uYml0Y29pbmQudjFhbHBoYS5JbXBvcnREZXNjcmlwdG9yc1Jlc3BvbnNlLlJlc3BvbnNlUgly'
    'ZXNwb25zZXMaNQoFRXJyb3ISEgoEY29kZRgBIAEoBVIEY29kZRIYCgdtZXNzYWdlGAIgASgJUg'
    'dtZXNzYWdlGpEBCghSZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEhoKCHdhcm5p'
    'bmdzGAIgAygJUgh3YXJuaW5ncxJPCgVlcnJvchgDIAEoCzI5LmJpdGNvaW4uYml0Y29pbmQudj'
    'FhbHBoYS5JbXBvcnREZXNjcmlwdG9yc1Jlc3BvbnNlLkVycm9yUgVlcnJvcg==');

@$core.Deprecated('Use getDescriptorInfoRequestDescriptor instead')
const GetDescriptorInfoRequest$json = {
  '1': 'GetDescriptorInfoRequest',
  '2': [
    {'1': 'descriptor', '3': 1, '4': 1, '5': 9, '10': 'descriptor'},
  ],
};

/// Descriptor for `GetDescriptorInfoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getDescriptorInfoRequestDescriptor = $convert.base64Decode(
    'ChhHZXREZXNjcmlwdG9ySW5mb1JlcXVlc3QSHgoKZGVzY3JpcHRvchgBIAEoCVIKZGVzY3JpcH'
    'Rvcg==');

@$core.Deprecated('Use getDescriptorInfoResponseDescriptor instead')
const GetDescriptorInfoResponse$json = {
  '1': 'GetDescriptorInfoResponse',
  '2': [
    {'1': 'descriptor', '3': 1, '4': 1, '5': 9, '10': 'descriptor'},
    {'1': 'checksum', '3': 2, '4': 1, '5': 9, '10': 'checksum'},
    {'1': 'is_range', '3': 3, '4': 1, '5': 8, '10': 'isRange'},
    {'1': 'is_solvable', '3': 4, '4': 1, '5': 8, '10': 'isSolvable'},
    {'1': 'has_private_keys', '3': 5, '4': 1, '5': 8, '10': 'hasPrivateKeys'},
  ],
};

/// Descriptor for `GetDescriptorInfoResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getDescriptorInfoResponseDescriptor = $convert.base64Decode(
    'ChlHZXREZXNjcmlwdG9ySW5mb1Jlc3BvbnNlEh4KCmRlc2NyaXB0b3IYASABKAlSCmRlc2NyaX'
    'B0b3ISGgoIY2hlY2tzdW0YAiABKAlSCGNoZWNrc3VtEhkKCGlzX3JhbmdlGAMgASgIUgdpc1Jh'
    'bmdlEh8KC2lzX3NvbHZhYmxlGAQgASgIUgppc1NvbHZhYmxlEigKEGhhc19wcml2YXRlX2tleX'
    'MYBSABKAhSDmhhc1ByaXZhdGVLZXlz');

@$core.Deprecated('Use getBlockRequestDescriptor instead')
const GetBlockRequest$json = {
  '1': 'GetBlockRequest',
  '2': [
    {'1': 'hash', '3': 1, '4': 1, '5': 9, '10': 'hash'},
    {'1': 'verbosity', '3': 2, '4': 1, '5': 14, '6': '.bitcoin.bitcoind.v1alpha.GetBlockRequest.Verbosity', '10': 'verbosity'},
  ],
  '4': [GetBlockRequest_Verbosity$json],
};

@$core.Deprecated('Use getBlockRequestDescriptor instead')
const GetBlockRequest_Verbosity$json = {
  '1': 'Verbosity',
  '2': [
    {'1': 'VERBOSITY_UNSPECIFIED', '2': 0},
    {'1': 'VERBOSITY_RAW_DATA', '2': 1},
    {'1': 'VERBOSITY_BLOCK_INFO', '2': 2},
    {'1': 'VERBOSITY_BLOCK_TX_INFO', '2': 3},
    {'1': 'VERBOSITY_BLOCK_TX_PREVOUT_INFO', '2': 4},
  ],
};

/// Descriptor for `GetBlockRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBlockRequestDescriptor = $convert.base64Decode(
    'Cg9HZXRCbG9ja1JlcXVlc3QSEgoEaGFzaBgBIAEoCVIEaGFzaBJRCgl2ZXJib3NpdHkYAiABKA'
    '4yMy5iaXRjb2luLmJpdGNvaW5kLnYxYWxwaGEuR2V0QmxvY2tSZXF1ZXN0LlZlcmJvc2l0eVIJ'
    'dmVyYm9zaXR5IpoBCglWZXJib3NpdHkSGQoVVkVSQk9TSVRZX1VOU1BFQ0lGSUVEEAASFgoSVk'
    'VSQk9TSVRZX1JBV19EQVRBEAESGAoUVkVSQk9TSVRZX0JMT0NLX0lORk8QAhIbChdWRVJCT1NJ'
    'VFlfQkxPQ0tfVFhfSU5GTxADEiMKH1ZFUkJPU0lUWV9CTE9DS19UWF9QUkVWT1VUX0lORk8QBA'
    '==');

@$core.Deprecated('Use getBlockResponseDescriptor instead')
const GetBlockResponse$json = {
  '1': 'GetBlockResponse',
  '2': [
    {'1': 'hex', '3': 1, '4': 1, '5': 9, '10': 'hex'},
    {'1': 'hash', '3': 2, '4': 1, '5': 9, '10': 'hash'},
    {'1': 'confirmations', '3': 3, '4': 1, '5': 5, '10': 'confirmations'},
    {'1': 'height', '3': 4, '4': 1, '5': 13, '10': 'height'},
    {'1': 'version', '3': 5, '4': 1, '5': 5, '10': 'version'},
    {'1': 'version_hex', '3': 6, '4': 1, '5': 9, '10': 'versionHex'},
    {'1': 'merkle_root', '3': 7, '4': 1, '5': 9, '10': 'merkleRoot'},
    {'1': 'time', '3': 8, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'time'},
    {'1': 'nonce', '3': 9, '4': 1, '5': 13, '10': 'nonce'},
    {'1': 'bits', '3': 10, '4': 1, '5': 9, '10': 'bits'},
    {'1': 'difficulty', '3': 11, '4': 1, '5': 1, '10': 'difficulty'},
    {'1': 'previous_block_hash', '3': 12, '4': 1, '5': 9, '10': 'previousBlockHash'},
    {'1': 'next_block_hash', '3': 13, '4': 1, '5': 9, '10': 'nextBlockHash'},
    {'1': 'stripped_size', '3': 14, '4': 1, '5': 5, '10': 'strippedSize'},
    {'1': 'size', '3': 15, '4': 1, '5': 5, '10': 'size'},
    {'1': 'weight', '3': 16, '4': 1, '5': 5, '10': 'weight'},
    {'1': 'txids', '3': 17, '4': 3, '5': 9, '10': 'txids'},
  ],
};

/// Descriptor for `GetBlockResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBlockResponseDescriptor = $convert.base64Decode(
    'ChBHZXRCbG9ja1Jlc3BvbnNlEhAKA2hleBgBIAEoCVIDaGV4EhIKBGhhc2gYAiABKAlSBGhhc2'
    'gSJAoNY29uZmlybWF0aW9ucxgDIAEoBVINY29uZmlybWF0aW9ucxIWCgZoZWlnaHQYBCABKA1S'
    'BmhlaWdodBIYCgd2ZXJzaW9uGAUgASgFUgd2ZXJzaW9uEh8KC3ZlcnNpb25faGV4GAYgASgJUg'
    'p2ZXJzaW9uSGV4Eh8KC21lcmtsZV9yb290GAcgASgJUgptZXJrbGVSb290Ei4KBHRpbWUYCCAB'
    'KAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgR0aW1lEhQKBW5vbmNlGAkgASgNUgVub2'
    '5jZRISCgRiaXRzGAogASgJUgRiaXRzEh4KCmRpZmZpY3VsdHkYCyABKAFSCmRpZmZpY3VsdHkS'
    'LgoTcHJldmlvdXNfYmxvY2tfaGFzaBgMIAEoCVIRcHJldmlvdXNCbG9ja0hhc2gSJgoPbmV4dF'
    '9ibG9ja19oYXNoGA0gASgJUg1uZXh0QmxvY2tIYXNoEiMKDXN0cmlwcGVkX3NpemUYDiABKAVS'
    'DHN0cmlwcGVkU2l6ZRISCgRzaXplGA8gASgFUgRzaXplEhYKBndlaWdodBgQIAEoBVIGd2VpZ2'
    'h0EhQKBXR4aWRzGBEgAygJUgV0eGlkcw==');

@$core.Deprecated('Use bumpFeeRequestDescriptor instead')
const BumpFeeRequest$json = {
  '1': 'BumpFeeRequest',
  '2': [
    {'1': 'wallet', '3': 1, '4': 1, '5': 9, '10': 'wallet'},
    {'1': 'txid', '3': 2, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `BumpFeeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List bumpFeeRequestDescriptor = $convert.base64Decode(
    'Cg5CdW1wRmVlUmVxdWVzdBIWCgZ3YWxsZXQYASABKAlSBndhbGxldBISCgR0eGlkGAIgASgJUg'
    'R0eGlk');

@$core.Deprecated('Use bumpFeeResponseDescriptor instead')
const BumpFeeResponse$json = {
  '1': 'BumpFeeResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'original_fee', '3': 2, '4': 1, '5': 1, '10': 'originalFee'},
    {'1': 'new_fee', '3': 3, '4': 1, '5': 1, '10': 'newFee'},
    {'1': 'errors', '3': 4, '4': 3, '5': 9, '10': 'errors'},
  ],
};

/// Descriptor for `BumpFeeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List bumpFeeResponseDescriptor = $convert.base64Decode(
    'Cg9CdW1wRmVlUmVzcG9uc2USEgoEdHhpZBgBIAEoCVIEdHhpZBIhCgxvcmlnaW5hbF9mZWUYAi'
    'ABKAFSC29yaWdpbmFsRmVlEhcKB25ld19mZWUYAyABKAFSBm5ld0ZlZRIWCgZlcnJvcnMYBCAD'
    'KAlSBmVycm9ycw==');

@$core.Deprecated('Use listSinceBlockRequestDescriptor instead')
const ListSinceBlockRequest$json = {
  '1': 'ListSinceBlockRequest',
  '2': [
    {'1': 'wallet', '3': 1, '4': 1, '5': 9, '10': 'wallet'},
    {'1': 'hash', '3': 2, '4': 1, '5': 9, '10': 'hash'},
  ],
};

/// Descriptor for `ListSinceBlockRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listSinceBlockRequestDescriptor = $convert.base64Decode(
    'ChVMaXN0U2luY2VCbG9ja1JlcXVlc3QSFgoGd2FsbGV0GAEgASgJUgZ3YWxsZXQSEgoEaGFzaB'
    'gCIAEoCVIEaGFzaA==');

@$core.Deprecated('Use listSinceBlockResponseDescriptor instead')
const ListSinceBlockResponse$json = {
  '1': 'ListSinceBlockResponse',
  '2': [
    {'1': 'transactions', '3': 1, '4': 3, '5': 11, '6': '.bitcoin.bitcoind.v1alpha.GetTransactionResponse', '10': 'transactions'},
  ],
};

/// Descriptor for `ListSinceBlockResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listSinceBlockResponseDescriptor = $convert.base64Decode(
    'ChZMaXN0U2luY2VCbG9ja1Jlc3BvbnNlElQKDHRyYW5zYWN0aW9ucxgBIAMoCzIwLmJpdGNvaW'
    '4uYml0Y29pbmQudjFhbHBoYS5HZXRUcmFuc2FjdGlvblJlc3BvbnNlUgx0cmFuc2FjdGlvbnM=');

@$core.Deprecated('Use getRawMempoolRequestDescriptor instead')
const GetRawMempoolRequest$json = {
  '1': 'GetRawMempoolRequest',
  '2': [
    {'1': 'verbose', '3': 1, '4': 1, '5': 8, '10': 'verbose'},
  ],
};

/// Descriptor for `GetRawMempoolRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getRawMempoolRequestDescriptor = $convert.base64Decode(
    'ChRHZXRSYXdNZW1wb29sUmVxdWVzdBIYCgd2ZXJib3NlGAEgASgIUgd2ZXJib3Nl');

@$core.Deprecated('Use mempoolEntryDescriptor instead')
const MempoolEntry$json = {
  '1': 'MempoolEntry',
  '2': [
    {'1': 'virtual_size', '3': 1, '4': 1, '5': 13, '10': 'virtualSize'},
    {'1': 'weight', '3': 2, '4': 1, '5': 13, '10': 'weight'},
    {'1': 'time', '3': 3, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'time'},
    {'1': 'descendant_count', '3': 4, '4': 1, '5': 13, '10': 'descendantCount'},
    {'1': 'descendant_size', '3': 5, '4': 1, '5': 13, '10': 'descendantSize'},
    {'1': 'ancestor_count', '3': 6, '4': 1, '5': 13, '10': 'ancestorCount'},
    {'1': 'ancestor_size', '3': 7, '4': 1, '5': 13, '10': 'ancestorSize'},
    {'1': 'witness_txid', '3': 8, '4': 1, '5': 9, '10': 'witnessTxid'},
    {'1': 'fees', '3': 9, '4': 1, '5': 11, '6': '.bitcoin.bitcoind.v1alpha.MempoolEntry.Fees', '10': 'fees'},
    {'1': 'depends', '3': 10, '4': 3, '5': 9, '10': 'depends'},
    {'1': 'spent_by', '3': 11, '4': 3, '5': 9, '10': 'spentBy'},
    {'1': 'bip125_replaceable', '3': 12, '4': 1, '5': 8, '10': 'bip125Replaceable'},
    {'1': 'unbroadcast', '3': 13, '4': 1, '5': 8, '10': 'unbroadcast'},
  ],
  '3': [MempoolEntry_Fees$json],
};

@$core.Deprecated('Use mempoolEntryDescriptor instead')
const MempoolEntry_Fees$json = {
  '1': 'Fees',
  '2': [
    {'1': 'base', '3': 1, '4': 1, '5': 1, '10': 'base'},
    {'1': 'modified', '3': 2, '4': 1, '5': 1, '10': 'modified'},
    {'1': 'ancestor', '3': 3, '4': 1, '5': 1, '10': 'ancestor'},
    {'1': 'descendant', '3': 4, '4': 1, '5': 1, '10': 'descendant'},
  ],
};

/// Descriptor for `MempoolEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mempoolEntryDescriptor = $convert.base64Decode(
    'CgxNZW1wb29sRW50cnkSIQoMdmlydHVhbF9zaXplGAEgASgNUgt2aXJ0dWFsU2l6ZRIWCgZ3ZW'
    'lnaHQYAiABKA1SBndlaWdodBIuCgR0aW1lGAMgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVz'
    'dGFtcFIEdGltZRIpChBkZXNjZW5kYW50X2NvdW50GAQgASgNUg9kZXNjZW5kYW50Q291bnQSJw'
    'oPZGVzY2VuZGFudF9zaXplGAUgASgNUg5kZXNjZW5kYW50U2l6ZRIlCg5hbmNlc3Rvcl9jb3Vu'
    'dBgGIAEoDVINYW5jZXN0b3JDb3VudBIjCg1hbmNlc3Rvcl9zaXplGAcgASgNUgxhbmNlc3Rvcl'
    'NpemUSIQoMd2l0bmVzc190eGlkGAggASgJUgt3aXRuZXNzVHhpZBI/CgRmZWVzGAkgASgLMisu'
    'Yml0Y29pbi5iaXRjb2luZC52MWFscGhhLk1lbXBvb2xFbnRyeS5GZWVzUgRmZWVzEhgKB2RlcG'
    'VuZHMYCiADKAlSB2RlcGVuZHMSGQoIc3BlbnRfYnkYCyADKAlSB3NwZW50QnkSLQoSYmlwMTI1'
    'X3JlcGxhY2VhYmxlGAwgASgIUhFiaXAxMjVSZXBsYWNlYWJsZRIgCgt1bmJyb2FkY2FzdBgNIA'
    'EoCFILdW5icm9hZGNhc3QacgoERmVlcxISCgRiYXNlGAEgASgBUgRiYXNlEhoKCG1vZGlmaWVk'
    'GAIgASgBUghtb2RpZmllZBIaCghhbmNlc3RvchgDIAEoAVIIYW5jZXN0b3ISHgoKZGVzY2VuZG'
    'FudBgEIAEoAVIKZGVzY2VuZGFudA==');

@$core.Deprecated('Use getRawMempoolResponseDescriptor instead')
const GetRawMempoolResponse$json = {
  '1': 'GetRawMempoolResponse',
  '2': [
    {'1': 'txids', '3': 1, '4': 3, '5': 9, '10': 'txids'},
    {'1': 'transactions', '3': 2, '4': 3, '5': 11, '6': '.bitcoin.bitcoind.v1alpha.GetRawMempoolResponse.TransactionsEntry', '10': 'transactions'},
  ],
  '3': [GetRawMempoolResponse_TransactionsEntry$json],
};

@$core.Deprecated('Use getRawMempoolResponseDescriptor instead')
const GetRawMempoolResponse_TransactionsEntry$json = {
  '1': 'TransactionsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 11, '6': '.bitcoin.bitcoind.v1alpha.MempoolEntry', '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `GetRawMempoolResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getRawMempoolResponseDescriptor = $convert.base64Decode(
    'ChVHZXRSYXdNZW1wb29sUmVzcG9uc2USFAoFdHhpZHMYASADKAlSBXR4aWRzEmUKDHRyYW5zYW'
    'N0aW9ucxgCIAMoCzJBLmJpdGNvaW4uYml0Y29pbmQudjFhbHBoYS5HZXRSYXdNZW1wb29sUmVz'
    'cG9uc2UuVHJhbnNhY3Rpb25zRW50cnlSDHRyYW5zYWN0aW9ucxpnChFUcmFuc2FjdGlvbnNFbn'
    'RyeRIQCgNrZXkYASABKAlSA2tleRI8CgV2YWx1ZRgCIAEoCzImLmJpdGNvaW4uYml0Y29pbmQu'
    'djFhbHBoYS5NZW1wb29sRW50cnlSBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use getBlockHashRequestDescriptor instead')
const GetBlockHashRequest$json = {
  '1': 'GetBlockHashRequest',
  '2': [
    {'1': 'height', '3': 1, '4': 1, '5': 13, '10': 'height'},
  ],
};

/// Descriptor for `GetBlockHashRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBlockHashRequestDescriptor = $convert.base64Decode(
    'ChNHZXRCbG9ja0hhc2hSZXF1ZXN0EhYKBmhlaWdodBgBIAEoDVIGaGVpZ2h0');

@$core.Deprecated('Use getBlockHashResponseDescriptor instead')
const GetBlockHashResponse$json = {
  '1': 'GetBlockHashResponse',
  '2': [
    {'1': 'hash', '3': 1, '4': 1, '5': 9, '10': 'hash'},
  ],
};

/// Descriptor for `GetBlockHashResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBlockHashResponseDescriptor = $convert.base64Decode(
    'ChRHZXRCbG9ja0hhc2hSZXNwb25zZRISCgRoYXNoGAEgASgJUgRoYXNo');

@$core.Deprecated('Use listTransactionsRequestDescriptor instead')
const ListTransactionsRequest$json = {
  '1': 'ListTransactionsRequest',
  '2': [
    {'1': 'wallet', '3': 1, '4': 1, '5': 9, '10': 'wallet'},
    {'1': 'count', '3': 2, '4': 1, '5': 13, '10': 'count'},
    {'1': 'skip', '3': 3, '4': 1, '5': 13, '10': 'skip'},
  ],
};

/// Descriptor for `ListTransactionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listTransactionsRequestDescriptor = $convert.base64Decode(
    'ChdMaXN0VHJhbnNhY3Rpb25zUmVxdWVzdBIWCgZ3YWxsZXQYASABKAlSBndhbGxldBIUCgVjb3'
    'VudBgCIAEoDVIFY291bnQSEgoEc2tpcBgDIAEoDVIEc2tpcA==');

@$core.Deprecated('Use listTransactionsResponseDescriptor instead')
const ListTransactionsResponse$json = {
  '1': 'ListTransactionsResponse',
  '2': [
    {'1': 'transactions', '3': 1, '4': 3, '5': 11, '6': '.bitcoin.bitcoind.v1alpha.GetTransactionResponse', '10': 'transactions'},
  ],
};

/// Descriptor for `ListTransactionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listTransactionsResponseDescriptor = $convert.base64Decode(
    'ChhMaXN0VHJhbnNhY3Rpb25zUmVzcG9uc2USVAoMdHJhbnNhY3Rpb25zGAEgAygLMjAuYml0Y2'
    '9pbi5iaXRjb2luZC52MWFscGhhLkdldFRyYW5zYWN0aW9uUmVzcG9uc2VSDHRyYW5zYWN0aW9u'
    'cw==');

const $core.Map<$core.String, $core.dynamic> BitcoinServiceBase$json = {
  '1': 'BitcoinService',
  '2': [
    {'1': 'GetBlockchainInfo', '2': '.bitcoin.bitcoind.v1alpha.GetBlockchainInfoRequest', '3': '.bitcoin.bitcoind.v1alpha.GetBlockchainInfoResponse'},
    {'1': 'GetTransaction', '2': '.bitcoin.bitcoind.v1alpha.GetTransactionRequest', '3': '.bitcoin.bitcoind.v1alpha.GetTransactionResponse'},
    {'1': 'ListSinceBlock', '2': '.bitcoin.bitcoind.v1alpha.ListSinceBlockRequest', '3': '.bitcoin.bitcoind.v1alpha.ListSinceBlockResponse'},
    {'1': 'GetNewAddress', '2': '.bitcoin.bitcoind.v1alpha.GetNewAddressRequest', '3': '.bitcoin.bitcoind.v1alpha.GetNewAddressResponse'},
    {'1': 'GetWalletInfo', '2': '.bitcoin.bitcoind.v1alpha.GetWalletInfoRequest', '3': '.bitcoin.bitcoind.v1alpha.GetWalletInfoResponse'},
    {'1': 'GetBalances', '2': '.bitcoin.bitcoind.v1alpha.GetBalancesRequest', '3': '.bitcoin.bitcoind.v1alpha.GetBalancesResponse'},
    {'1': 'Send', '2': '.bitcoin.bitcoind.v1alpha.SendRequest', '3': '.bitcoin.bitcoind.v1alpha.SendResponse'},
    {'1': 'SendToAddress', '2': '.bitcoin.bitcoind.v1alpha.SendToAddressRequest', '3': '.bitcoin.bitcoind.v1alpha.SendToAddressResponse'},
    {'1': 'BumpFee', '2': '.bitcoin.bitcoind.v1alpha.BumpFeeRequest', '3': '.bitcoin.bitcoind.v1alpha.BumpFeeResponse'},
    {'1': 'EstimateSmartFee', '2': '.bitcoin.bitcoind.v1alpha.EstimateSmartFeeRequest', '3': '.bitcoin.bitcoind.v1alpha.EstimateSmartFeeResponse'},
    {'1': 'ImportDescriptors', '2': '.bitcoin.bitcoind.v1alpha.ImportDescriptorsRequest', '3': '.bitcoin.bitcoind.v1alpha.ImportDescriptorsResponse'},
    {'1': 'ListTransactions', '2': '.bitcoin.bitcoind.v1alpha.ListTransactionsRequest', '3': '.bitcoin.bitcoind.v1alpha.ListTransactionsResponse'},
    {'1': 'GetDescriptorInfo', '2': '.bitcoin.bitcoind.v1alpha.GetDescriptorInfoRequest', '3': '.bitcoin.bitcoind.v1alpha.GetDescriptorInfoResponse'},
    {'1': 'GetRawMempool', '2': '.bitcoin.bitcoind.v1alpha.GetRawMempoolRequest', '3': '.bitcoin.bitcoind.v1alpha.GetRawMempoolResponse'},
    {'1': 'GetRawTransaction', '2': '.bitcoin.bitcoind.v1alpha.GetRawTransactionRequest', '3': '.bitcoin.bitcoind.v1alpha.GetRawTransactionResponse'},
    {'1': 'DecodeRawTransaction', '2': '.bitcoin.bitcoind.v1alpha.DecodeRawTransactionRequest', '3': '.bitcoin.bitcoind.v1alpha.DecodeRawTransactionResponse'},
    {'1': 'GetBlock', '2': '.bitcoin.bitcoind.v1alpha.GetBlockRequest', '3': '.bitcoin.bitcoind.v1alpha.GetBlockResponse'},
    {'1': 'GetBlockHash', '2': '.bitcoin.bitcoind.v1alpha.GetBlockHashRequest', '3': '.bitcoin.bitcoind.v1alpha.GetBlockHashResponse'},
  ],
};

@$core.Deprecated('Use bitcoinServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> BitcoinServiceBase$messageJson = {
  '.bitcoin.bitcoind.v1alpha.GetBlockchainInfoRequest': GetBlockchainInfoRequest$json,
  '.bitcoin.bitcoind.v1alpha.GetBlockchainInfoResponse': GetBlockchainInfoResponse$json,
  '.bitcoin.bitcoind.v1alpha.GetTransactionRequest': GetTransactionRequest$json,
  '.bitcoin.bitcoind.v1alpha.GetTransactionResponse': GetTransactionResponse$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.bitcoin.bitcoind.v1alpha.GetTransactionResponse.Details': GetTransactionResponse_Details$json,
  '.bitcoin.bitcoind.v1alpha.ListSinceBlockRequest': ListSinceBlockRequest$json,
  '.bitcoin.bitcoind.v1alpha.ListSinceBlockResponse': ListSinceBlockResponse$json,
  '.bitcoin.bitcoind.v1alpha.GetNewAddressRequest': GetNewAddressRequest$json,
  '.bitcoin.bitcoind.v1alpha.GetNewAddressResponse': GetNewAddressResponse$json,
  '.bitcoin.bitcoind.v1alpha.GetWalletInfoRequest': GetWalletInfoRequest$json,
  '.bitcoin.bitcoind.v1alpha.GetWalletInfoResponse': GetWalletInfoResponse$json,
  '.bitcoin.bitcoind.v1alpha.WalletScan': WalletScan$json,
  '.bitcoin.bitcoind.v1alpha.GetBalancesRequest': GetBalancesRequest$json,
  '.bitcoin.bitcoind.v1alpha.GetBalancesResponse': GetBalancesResponse$json,
  '.bitcoin.bitcoind.v1alpha.GetBalancesResponse.Mine': GetBalancesResponse_Mine$json,
  '.bitcoin.bitcoind.v1alpha.GetBalancesResponse.Watchonly': GetBalancesResponse_Watchonly$json,
  '.bitcoin.bitcoind.v1alpha.SendRequest': SendRequest$json,
  '.bitcoin.bitcoind.v1alpha.SendRequest.DestinationsEntry': SendRequest_DestinationsEntry$json,
  '.google.protobuf.BoolValue': $1.BoolValue$json,
  '.bitcoin.bitcoind.v1alpha.SendResponse': SendResponse$json,
  '.bitcoin.bitcoind.v1alpha.RawTransaction': RawTransaction$json,
  '.bitcoin.bitcoind.v1alpha.SendToAddressRequest': SendToAddressRequest$json,
  '.bitcoin.bitcoind.v1alpha.SendToAddressResponse': SendToAddressResponse$json,
  '.bitcoin.bitcoind.v1alpha.BumpFeeRequest': BumpFeeRequest$json,
  '.bitcoin.bitcoind.v1alpha.BumpFeeResponse': BumpFeeResponse$json,
  '.bitcoin.bitcoind.v1alpha.EstimateSmartFeeRequest': EstimateSmartFeeRequest$json,
  '.bitcoin.bitcoind.v1alpha.EstimateSmartFeeResponse': EstimateSmartFeeResponse$json,
  '.bitcoin.bitcoind.v1alpha.ImportDescriptorsRequest': ImportDescriptorsRequest$json,
  '.bitcoin.bitcoind.v1alpha.ImportDescriptorsRequest.Request': ImportDescriptorsRequest_Request$json,
  '.bitcoin.bitcoind.v1alpha.ImportDescriptorsResponse': ImportDescriptorsResponse$json,
  '.bitcoin.bitcoind.v1alpha.ImportDescriptorsResponse.Response': ImportDescriptorsResponse_Response$json,
  '.bitcoin.bitcoind.v1alpha.ImportDescriptorsResponse.Error': ImportDescriptorsResponse_Error$json,
  '.bitcoin.bitcoind.v1alpha.ListTransactionsRequest': ListTransactionsRequest$json,
  '.bitcoin.bitcoind.v1alpha.ListTransactionsResponse': ListTransactionsResponse$json,
  '.bitcoin.bitcoind.v1alpha.GetDescriptorInfoRequest': GetDescriptorInfoRequest$json,
  '.bitcoin.bitcoind.v1alpha.GetDescriptorInfoResponse': GetDescriptorInfoResponse$json,
  '.bitcoin.bitcoind.v1alpha.GetRawMempoolRequest': GetRawMempoolRequest$json,
  '.bitcoin.bitcoind.v1alpha.GetRawMempoolResponse': GetRawMempoolResponse$json,
  '.bitcoin.bitcoind.v1alpha.GetRawMempoolResponse.TransactionsEntry': GetRawMempoolResponse_TransactionsEntry$json,
  '.bitcoin.bitcoind.v1alpha.MempoolEntry': MempoolEntry$json,
  '.bitcoin.bitcoind.v1alpha.MempoolEntry.Fees': MempoolEntry_Fees$json,
  '.bitcoin.bitcoind.v1alpha.GetRawTransactionRequest': GetRawTransactionRequest$json,
  '.bitcoin.bitcoind.v1alpha.GetRawTransactionResponse': GetRawTransactionResponse$json,
  '.bitcoin.bitcoind.v1alpha.Input': Input$json,
  '.bitcoin.bitcoind.v1alpha.Output': Output$json,
  '.bitcoin.bitcoind.v1alpha.ScriptPubKey': ScriptPubKey$json,
  '.bitcoin.bitcoind.v1alpha.DecodeRawTransactionRequest': DecodeRawTransactionRequest$json,
  '.bitcoin.bitcoind.v1alpha.DecodeRawTransactionResponse': DecodeRawTransactionResponse$json,
  '.bitcoin.bitcoind.v1alpha.GetBlockRequest': GetBlockRequest$json,
  '.bitcoin.bitcoind.v1alpha.GetBlockResponse': GetBlockResponse$json,
  '.bitcoin.bitcoind.v1alpha.GetBlockHashRequest': GetBlockHashRequest$json,
  '.bitcoin.bitcoind.v1alpha.GetBlockHashResponse': GetBlockHashResponse$json,
};

/// Descriptor for `BitcoinService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List bitcoinServiceDescriptor = $convert.base64Decode(
    'Cg5CaXRjb2luU2VydmljZRJ8ChFHZXRCbG9ja2NoYWluSW5mbxIyLmJpdGNvaW4uYml0Y29pbm'
    'QudjFhbHBoYS5HZXRCbG9ja2NoYWluSW5mb1JlcXVlc3QaMy5iaXRjb2luLmJpdGNvaW5kLnYx'
    'YWxwaGEuR2V0QmxvY2tjaGFpbkluZm9SZXNwb25zZRJzCg5HZXRUcmFuc2FjdGlvbhIvLmJpdG'
    'NvaW4uYml0Y29pbmQudjFhbHBoYS5HZXRUcmFuc2FjdGlvblJlcXVlc3QaMC5iaXRjb2luLmJp'
    'dGNvaW5kLnYxYWxwaGEuR2V0VHJhbnNhY3Rpb25SZXNwb25zZRJzCg5MaXN0U2luY2VCbG9jax'
    'IvLmJpdGNvaW4uYml0Y29pbmQudjFhbHBoYS5MaXN0U2luY2VCbG9ja1JlcXVlc3QaMC5iaXRj'
    'b2luLmJpdGNvaW5kLnYxYWxwaGEuTGlzdFNpbmNlQmxvY2tSZXNwb25zZRJwCg1HZXROZXdBZG'
    'RyZXNzEi4uYml0Y29pbi5iaXRjb2luZC52MWFscGhhLkdldE5ld0FkZHJlc3NSZXF1ZXN0Gi8u'
    'Yml0Y29pbi5iaXRjb2luZC52MWFscGhhLkdldE5ld0FkZHJlc3NSZXNwb25zZRJwCg1HZXRXYW'
    'xsZXRJbmZvEi4uYml0Y29pbi5iaXRjb2luZC52MWFscGhhLkdldFdhbGxldEluZm9SZXF1ZXN0'
    'Gi8uYml0Y29pbi5iaXRjb2luZC52MWFscGhhLkdldFdhbGxldEluZm9SZXNwb25zZRJqCgtHZX'
    'RCYWxhbmNlcxIsLmJpdGNvaW4uYml0Y29pbmQudjFhbHBoYS5HZXRCYWxhbmNlc1JlcXVlc3Qa'
    'LS5iaXRjb2luLmJpdGNvaW5kLnYxYWxwaGEuR2V0QmFsYW5jZXNSZXNwb25zZRJVCgRTZW5kEi'
    'UuYml0Y29pbi5iaXRjb2luZC52MWFscGhhLlNlbmRSZXF1ZXN0GiYuYml0Y29pbi5iaXRjb2lu'
    'ZC52MWFscGhhLlNlbmRSZXNwb25zZRJwCg1TZW5kVG9BZGRyZXNzEi4uYml0Y29pbi5iaXRjb2'
    'luZC52MWFscGhhLlNlbmRUb0FkZHJlc3NSZXF1ZXN0Gi8uYml0Y29pbi5iaXRjb2luZC52MWFs'
    'cGhhLlNlbmRUb0FkZHJlc3NSZXNwb25zZRJeCgdCdW1wRmVlEiguYml0Y29pbi5iaXRjb2luZC'
    '52MWFscGhhLkJ1bXBGZWVSZXF1ZXN0GikuYml0Y29pbi5iaXRjb2luZC52MWFscGhhLkJ1bXBG'
    'ZWVSZXNwb25zZRJ5ChBFc3RpbWF0ZVNtYXJ0RmVlEjEuYml0Y29pbi5iaXRjb2luZC52MWFscG'
    'hhLkVzdGltYXRlU21hcnRGZWVSZXF1ZXN0GjIuYml0Y29pbi5iaXRjb2luZC52MWFscGhhLkVz'
    'dGltYXRlU21hcnRGZWVSZXNwb25zZRJ8ChFJbXBvcnREZXNjcmlwdG9ycxIyLmJpdGNvaW4uYm'
    'l0Y29pbmQudjFhbHBoYS5JbXBvcnREZXNjcmlwdG9yc1JlcXVlc3QaMy5iaXRjb2luLmJpdGNv'
    'aW5kLnYxYWxwaGEuSW1wb3J0RGVzY3JpcHRvcnNSZXNwb25zZRJ5ChBMaXN0VHJhbnNhY3Rpb2'
    '5zEjEuYml0Y29pbi5iaXRjb2luZC52MWFscGhhLkxpc3RUcmFuc2FjdGlvbnNSZXF1ZXN0GjIu'
    'Yml0Y29pbi5iaXRjb2luZC52MWFscGhhLkxpc3RUcmFuc2FjdGlvbnNSZXNwb25zZRJ8ChFHZX'
    'REZXNjcmlwdG9ySW5mbxIyLmJpdGNvaW4uYml0Y29pbmQudjFhbHBoYS5HZXREZXNjcmlwdG9y'
    'SW5mb1JlcXVlc3QaMy5iaXRjb2luLmJpdGNvaW5kLnYxYWxwaGEuR2V0RGVzY3JpcHRvckluZm'
    '9SZXNwb25zZRJwCg1HZXRSYXdNZW1wb29sEi4uYml0Y29pbi5iaXRjb2luZC52MWFscGhhLkdl'
    'dFJhd01lbXBvb2xSZXF1ZXN0Gi8uYml0Y29pbi5iaXRjb2luZC52MWFscGhhLkdldFJhd01lbX'
    'Bvb2xSZXNwb25zZRJ8ChFHZXRSYXdUcmFuc2FjdGlvbhIyLmJpdGNvaW4uYml0Y29pbmQudjFh'
    'bHBoYS5HZXRSYXdUcmFuc2FjdGlvblJlcXVlc3QaMy5iaXRjb2luLmJpdGNvaW5kLnYxYWxwaG'
    'EuR2V0UmF3VHJhbnNhY3Rpb25SZXNwb25zZRKFAQoURGVjb2RlUmF3VHJhbnNhY3Rpb24SNS5i'
    'aXRjb2luLmJpdGNvaW5kLnYxYWxwaGEuRGVjb2RlUmF3VHJhbnNhY3Rpb25SZXF1ZXN0GjYuYm'
    'l0Y29pbi5iaXRjb2luZC52MWFscGhhLkRlY29kZVJhd1RyYW5zYWN0aW9uUmVzcG9uc2USYQoI'
    'R2V0QmxvY2sSKS5iaXRjb2luLmJpdGNvaW5kLnYxYWxwaGEuR2V0QmxvY2tSZXF1ZXN0GiouYm'
    'l0Y29pbi5iaXRjb2luZC52MWFscGhhLkdldEJsb2NrUmVzcG9uc2USbQoMR2V0QmxvY2tIYXNo'
    'Ei0uYml0Y29pbi5iaXRjb2luZC52MWFscGhhLkdldEJsb2NrSGFzaFJlcXVlc3QaLi5iaXRjb2'
    'luLmJpdGNvaW5kLnYxYWxwaGEuR2V0QmxvY2tIYXNoUmVzcG9uc2U=');

