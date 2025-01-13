//
//  Generated code. Do not modify.
//  source: wallet/v1/wallet.proto
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
    {'1': 'destinations', '3': 1, '4': 3, '5': 11, '6': '.wallet.v1.SendTransactionRequest.DestinationsEntry', '10': 'destinations'},
    {'1': 'fee_rate', '3': 2, '4': 1, '5': 1, '10': 'feeRate'},
    {'1': 'op_return_message', '3': 3, '4': 1, '5': 9, '9': 0, '10': 'opReturnMessage', '17': true},
  ],
  '3': [SendTransactionRequest_DestinationsEntry$json],
  '8': [
    {'1': '_op_return_message'},
  ],
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
    'ChZTZW5kVHJhbnNhY3Rpb25SZXF1ZXN0ElcKDGRlc3RpbmF0aW9ucxgBIAMoCzIzLndhbGxldC'
    '52MS5TZW5kVHJhbnNhY3Rpb25SZXF1ZXN0LkRlc3RpbmF0aW9uc0VudHJ5UgxkZXN0aW5hdGlv'
    'bnMSGQoIZmVlX3JhdGUYAiABKAFSB2ZlZVJhdGUSLwoRb3BfcmV0dXJuX21lc3NhZ2UYAyABKA'
    'lIAFIPb3BSZXR1cm5NZXNzYWdliAEBGj8KEURlc3RpbmF0aW9uc0VudHJ5EhAKA2tleRgBIAEo'
    'CVIDa2V5EhQKBXZhbHVlGAIgASgEUgV2YWx1ZToCOAFCFAoSX29wX3JldHVybl9tZXNzYWdl');

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
    {'1': 'transactions', '3': 1, '4': 3, '5': 11, '6': '.wallet.v1.WalletTransaction', '10': 'transactions'},
  ],
};

/// Descriptor for `ListTransactionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listTransactionsResponseDescriptor = $convert.base64Decode(
    'ChhMaXN0VHJhbnNhY3Rpb25zUmVzcG9uc2USQAoMdHJhbnNhY3Rpb25zGAEgAygLMhwud2FsbG'
    'V0LnYxLldhbGxldFRyYW5zYWN0aW9uUgx0cmFuc2FjdGlvbnM=');

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

@$core.Deprecated('Use walletTransactionDescriptor instead')
const WalletTransaction$json = {
  '1': 'WalletTransaction',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'fee_sats', '3': 2, '4': 1, '5': 4, '10': 'feeSats'},
    {'1': 'received_satoshi', '3': 3, '4': 1, '5': 4, '10': 'receivedSatoshi'},
    {'1': 'sent_satoshi', '3': 4, '4': 1, '5': 4, '10': 'sentSatoshi'},
    {'1': 'confirmation_time', '3': 5, '4': 1, '5': 11, '6': '.wallet.v1.Confirmation', '10': 'confirmationTime'},
  ],
};

/// Descriptor for `WalletTransaction`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List walletTransactionDescriptor = $convert.base64Decode(
    'ChFXYWxsZXRUcmFuc2FjdGlvbhISCgR0eGlkGAEgASgJUgR0eGlkEhkKCGZlZV9zYXRzGAIgAS'
    'gEUgdmZWVTYXRzEikKEHJlY2VpdmVkX3NhdG9zaGkYAyABKARSD3JlY2VpdmVkU2F0b3NoaRIh'
    'CgxzZW50X3NhdG9zaGkYBCABKARSC3NlbnRTYXRvc2hpEkQKEWNvbmZpcm1hdGlvbl90aW1lGA'
    'UgASgLMhcud2FsbGV0LnYxLkNvbmZpcm1hdGlvblIQY29uZmlybWF0aW9uVGltZQ==');

@$core.Deprecated('Use listSidechainDepositsRequestDescriptor instead')
const ListSidechainDepositsRequest$json = {
  '1': 'ListSidechainDepositsRequest',
  '2': [
    {'1': 'slot', '3': 1, '4': 1, '5': 5, '10': 'slot'},
  ],
};

/// Descriptor for `ListSidechainDepositsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listSidechainDepositsRequestDescriptor = $convert.base64Decode(
    'ChxMaXN0U2lkZWNoYWluRGVwb3NpdHNSZXF1ZXN0EhIKBHNsb3QYASABKAVSBHNsb3Q=');

@$core.Deprecated('Use listSidechainDepositsResponseDescriptor instead')
const ListSidechainDepositsResponse$json = {
  '1': 'ListSidechainDepositsResponse',
  '2': [
    {'1': 'deposits', '3': 1, '4': 3, '5': 11, '6': '.wallet.v1.ListSidechainDepositsResponse.SidechainDeposit', '10': 'deposits'},
  ],
  '3': [ListSidechainDepositsResponse_SidechainDeposit$json],
};

@$core.Deprecated('Use listSidechainDepositsResponseDescriptor instead')
const ListSidechainDepositsResponse_SidechainDeposit$json = {
  '1': 'SidechainDeposit',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'address', '3': 2, '4': 1, '5': 9, '10': 'address'},
    {'1': 'amount', '3': 3, '4': 1, '5': 1, '10': 'amount'},
    {'1': 'fee', '3': 4, '4': 1, '5': 1, '10': 'fee'},
    {'1': 'confirmations', '3': 5, '4': 1, '5': 5, '10': 'confirmations'},
  ],
};

/// Descriptor for `ListSidechainDepositsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listSidechainDepositsResponseDescriptor = $convert.base64Decode(
    'Ch1MaXN0U2lkZWNoYWluRGVwb3NpdHNSZXNwb25zZRJVCghkZXBvc2l0cxgBIAMoCzI5LndhbG'
    'xldC52MS5MaXN0U2lkZWNoYWluRGVwb3NpdHNSZXNwb25zZS5TaWRlY2hhaW5EZXBvc2l0Ughk'
    'ZXBvc2l0cxqQAQoQU2lkZWNoYWluRGVwb3NpdBISCgR0eGlkGAEgASgJUgR0eGlkEhgKB2FkZH'
    'Jlc3MYAiABKAlSB2FkZHJlc3MSFgoGYW1vdW50GAMgASgBUgZhbW91bnQSEAoDZmVlGAQgASgB'
    'UgNmZWUSJAoNY29uZmlybWF0aW9ucxgFIAEoBVINY29uZmlybWF0aW9ucw==');

@$core.Deprecated('Use createSidechainDepositRequestDescriptor instead')
const CreateSidechainDepositRequest$json = {
  '1': 'CreateSidechainDepositRequest',
  '2': [
    {'1': 'destination', '3': 1, '4': 1, '5': 9, '10': 'destination'},
    {'1': 'amount', '3': 2, '4': 1, '5': 1, '10': 'amount'},
    {'1': 'fee', '3': 3, '4': 1, '5': 1, '10': 'fee'},
  ],
};

/// Descriptor for `CreateSidechainDepositRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createSidechainDepositRequestDescriptor = $convert.base64Decode(
    'Ch1DcmVhdGVTaWRlY2hhaW5EZXBvc2l0UmVxdWVzdBIgCgtkZXN0aW5hdGlvbhgBIAEoCVILZG'
    'VzdGluYXRpb24SFgoGYW1vdW50GAIgASgBUgZhbW91bnQSEAoDZmVlGAMgASgBUgNmZWU=');

@$core.Deprecated('Use createSidechainDepositResponseDescriptor instead')
const CreateSidechainDepositResponse$json = {
  '1': 'CreateSidechainDepositResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `CreateSidechainDepositResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createSidechainDepositResponseDescriptor = $convert.base64Decode(
    'Ch5DcmVhdGVTaWRlY2hhaW5EZXBvc2l0UmVzcG9uc2USEgoEdHhpZBgBIAEoCVIEdHhpZA==');

