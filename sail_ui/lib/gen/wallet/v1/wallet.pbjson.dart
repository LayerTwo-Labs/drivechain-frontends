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

import '../../bitwindowd/v1/bitwindowd.pbjson.dart' as $2;
import '../../google/protobuf/empty.pbjson.dart' as $1;
import '../../google/protobuf/timestamp.pbjson.dart' as $0;

@$core.Deprecated('Use getBalanceRequestDescriptor instead')
const GetBalanceRequest$json = {
  '1': 'GetBalanceRequest',
  '2': [
    {'1': 'wallet_id', '3': 1, '4': 1, '5': 9, '10': 'walletId'},
  ],
};

/// Descriptor for `GetBalanceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBalanceRequestDescriptor = $convert.base64Decode(
    'ChFHZXRCYWxhbmNlUmVxdWVzdBIbCgl3YWxsZXRfaWQYASABKAlSCHdhbGxldElk');

@$core.Deprecated('Use getNewAddressRequestDescriptor instead')
const GetNewAddressRequest$json = {
  '1': 'GetNewAddressRequest',
  '2': [
    {'1': 'wallet_id', '3': 1, '4': 1, '5': 9, '10': 'walletId'},
  ],
};

/// Descriptor for `GetNewAddressRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNewAddressRequestDescriptor = $convert.base64Decode(
    'ChRHZXROZXdBZGRyZXNzUmVxdWVzdBIbCgl3YWxsZXRfaWQYASABKAlSCHdhbGxldElk');

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

@$core.Deprecated('Use listTransactionsRequestDescriptor instead')
const ListTransactionsRequest$json = {
  '1': 'ListTransactionsRequest',
  '2': [
    {'1': 'wallet_id', '3': 1, '4': 1, '5': 9, '10': 'walletId'},
  ],
};

/// Descriptor for `ListTransactionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listTransactionsRequestDescriptor = $convert.base64Decode(
    'ChdMaXN0VHJhbnNhY3Rpb25zUmVxdWVzdBIbCgl3YWxsZXRfaWQYASABKAlSCHdhbGxldElk');

@$core.Deprecated('Use listUnspentRequestDescriptor instead')
const ListUnspentRequest$json = {
  '1': 'ListUnspentRequest',
  '2': [
    {'1': 'wallet_id', '3': 1, '4': 1, '5': 9, '10': 'walletId'},
  ],
};

/// Descriptor for `ListUnspentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listUnspentRequestDescriptor = $convert.base64Decode(
    'ChJMaXN0VW5zcGVudFJlcXVlc3QSGwoJd2FsbGV0X2lkGAEgASgJUgh3YWxsZXRJZA==');

@$core.Deprecated('Use listReceiveAddressesRequestDescriptor instead')
const ListReceiveAddressesRequest$json = {
  '1': 'ListReceiveAddressesRequest',
  '2': [
    {'1': 'wallet_id', '3': 1, '4': 1, '5': 9, '10': 'walletId'},
  ],
};

/// Descriptor for `ListReceiveAddressesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listReceiveAddressesRequestDescriptor = $convert.base64Decode(
    'ChtMaXN0UmVjZWl2ZUFkZHJlc3Nlc1JlcXVlc3QSGwoJd2FsbGV0X2lkGAEgASgJUgh3YWxsZX'
    'RJZA==');

@$core.Deprecated('Use getStatsRequestDescriptor instead')
const GetStatsRequest$json = {
  '1': 'GetStatsRequest',
  '2': [
    {'1': 'wallet_id', '3': 1, '4': 1, '5': 9, '10': 'walletId'},
  ],
};

/// Descriptor for `GetStatsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getStatsRequestDescriptor = $convert.base64Decode(
    'Cg9HZXRTdGF0c1JlcXVlc3QSGwoJd2FsbGV0X2lkGAEgASgJUgh3YWxsZXRJZA==');

@$core.Deprecated('Use sendTransactionRequestDescriptor instead')
const SendTransactionRequest$json = {
  '1': 'SendTransactionRequest',
  '2': [
    {'1': 'wallet_id', '3': 1, '4': 1, '5': 9, '10': 'walletId'},
    {'1': 'destinations', '3': 2, '4': 3, '5': 11, '6': '.wallet.v1.SendTransactionRequest.DestinationsEntry', '10': 'destinations'},
    {'1': 'fee_sat_per_vbyte', '3': 3, '4': 1, '5': 4, '10': 'feeSatPerVbyte'},
    {'1': 'fixed_fee_sats', '3': 4, '4': 1, '5': 4, '10': 'fixedFeeSats'},
    {'1': 'op_return_message', '3': 5, '4': 1, '5': 9, '10': 'opReturnMessage'},
    {'1': 'label', '3': 6, '4': 1, '5': 9, '10': 'label'},
    {'1': 'required_inputs', '3': 7, '4': 3, '5': 11, '6': '.wallet.v1.UnspentOutput', '10': 'requiredInputs'},
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
    'ChZTZW5kVHJhbnNhY3Rpb25SZXF1ZXN0EhsKCXdhbGxldF9pZBgBIAEoCVIId2FsbGV0SWQSVw'
    'oMZGVzdGluYXRpb25zGAIgAygLMjMud2FsbGV0LnYxLlNlbmRUcmFuc2FjdGlvblJlcXVlc3Qu'
    'RGVzdGluYXRpb25zRW50cnlSDGRlc3RpbmF0aW9ucxIpChFmZWVfc2F0X3Blcl92Ynl0ZRgDIA'
    'EoBFIOZmVlU2F0UGVyVmJ5dGUSJAoOZml4ZWRfZmVlX3NhdHMYBCABKARSDGZpeGVkRmVlU2F0'
    'cxIqChFvcF9yZXR1cm5fbWVzc2FnZRgFIAEoCVIPb3BSZXR1cm5NZXNzYWdlEhQKBWxhYmVsGA'
    'YgASgJUgVsYWJlbBJBCg9yZXF1aXJlZF9pbnB1dHMYByADKAsyGC53YWxsZXQudjEuVW5zcGVu'
    'dE91dHB1dFIOcmVxdWlyZWRJbnB1dHMaPwoRRGVzdGluYXRpb25zRW50cnkSEAoDa2V5GAEgAS'
    'gJUgNrZXkSFAoFdmFsdWUYAiABKARSBXZhbHVlOgI4AQ==');

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

@$core.Deprecated('Use unspentOutputDescriptor instead')
const UnspentOutput$json = {
  '1': 'UnspentOutput',
  '2': [
    {'1': 'output', '3': 1, '4': 1, '5': 9, '10': 'output'},
    {'1': 'address', '3': 2, '4': 1, '5': 9, '10': 'address'},
    {'1': 'label', '3': 3, '4': 1, '5': 9, '10': 'label'},
    {'1': 'value_sats', '3': 4, '4': 1, '5': 4, '10': 'valueSats'},
    {'1': 'is_change', '3': 5, '4': 1, '5': 8, '10': 'isChange'},
    {'1': 'received_at', '3': 6, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'receivedAt'},
    {'1': 'denial_info', '3': 7, '4': 1, '5': 11, '6': '.bitwindowd.v1.DenialInfo', '9': 0, '10': 'denialInfo', '17': true},
  ],
  '8': [
    {'1': '_denial_info'},
  ],
};

/// Descriptor for `UnspentOutput`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unspentOutputDescriptor = $convert.base64Decode(
    'Cg1VbnNwZW50T3V0cHV0EhYKBm91dHB1dBgBIAEoCVIGb3V0cHV0EhgKB2FkZHJlc3MYAiABKA'
    'lSB2FkZHJlc3MSFAoFbGFiZWwYAyABKAlSBWxhYmVsEh0KCnZhbHVlX3NhdHMYBCABKARSCXZh'
    'bHVlU2F0cxIbCglpc19jaGFuZ2UYBSABKAhSCGlzQ2hhbmdlEjsKC3JlY2VpdmVkX2F0GAYgAS'
    'gLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIKcmVjZWl2ZWRBdBI/CgtkZW5pYWxfaW5m'
    'bxgHIAEoCzIZLmJpdHdpbmRvd2QudjEuRGVuaWFsSW5mb0gAUgpkZW5pYWxJbmZviAEBQg4KDF'
    '9kZW5pYWxfaW5mbw==');

@$core.Deprecated('Use listUnspentResponseDescriptor instead')
const ListUnspentResponse$json = {
  '1': 'ListUnspentResponse',
  '2': [
    {'1': 'utxos', '3': 1, '4': 3, '5': 11, '6': '.wallet.v1.UnspentOutput', '10': 'utxos'},
  ],
};

/// Descriptor for `ListUnspentResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listUnspentResponseDescriptor = $convert.base64Decode(
    'ChNMaXN0VW5zcGVudFJlc3BvbnNlEi4KBXV0eG9zGAEgAygLMhgud2FsbGV0LnYxLlVuc3Blbn'
    'RPdXRwdXRSBXV0eG9z');

@$core.Deprecated('Use listReceiveAddressesResponseDescriptor instead')
const ListReceiveAddressesResponse$json = {
  '1': 'ListReceiveAddressesResponse',
  '2': [
    {'1': 'addresses', '3': 1, '4': 3, '5': 11, '6': '.wallet.v1.ReceiveAddress', '10': 'addresses'},
  ],
};

/// Descriptor for `ListReceiveAddressesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listReceiveAddressesResponseDescriptor = $convert.base64Decode(
    'ChxMaXN0UmVjZWl2ZUFkZHJlc3Nlc1Jlc3BvbnNlEjcKCWFkZHJlc3NlcxgBIAMoCzIZLndhbG'
    'xldC52MS5SZWNlaXZlQWRkcmVzc1IJYWRkcmVzc2Vz');

@$core.Deprecated('Use receiveAddressDescriptor instead')
const ReceiveAddress$json = {
  '1': 'ReceiveAddress',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'label', '3': 2, '4': 1, '5': 9, '10': 'label'},
    {'1': 'current_balance_sat', '3': 3, '4': 1, '5': 4, '10': 'currentBalanceSat'},
    {'1': 'is_change', '3': 4, '4': 1, '5': 8, '10': 'isChange'},
    {'1': 'last_used_at', '3': 5, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'lastUsedAt'},
  ],
};

/// Descriptor for `ReceiveAddress`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List receiveAddressDescriptor = $convert.base64Decode(
    'Cg5SZWNlaXZlQWRkcmVzcxIYCgdhZGRyZXNzGAEgASgJUgdhZGRyZXNzEhQKBWxhYmVsGAIgAS'
    'gJUgVsYWJlbBIuChNjdXJyZW50X2JhbGFuY2Vfc2F0GAMgASgEUhFjdXJyZW50QmFsYW5jZVNh'
    'dBIbCglpc19jaGFuZ2UYBCABKAhSCGlzQ2hhbmdlEjwKDGxhc3RfdXNlZF9hdBgFIAEoCzIaLm'
    'dvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCmxhc3RVc2VkQXQ=');

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
    {'1': 'address', '3': 5, '4': 1, '5': 9, '10': 'address'},
    {'1': 'address_label', '3': 6, '4': 1, '5': 9, '10': 'addressLabel'},
    {'1': 'note', '3': 7, '4': 1, '5': 9, '10': 'note'},
    {'1': 'confirmation_time', '3': 8, '4': 1, '5': 11, '6': '.wallet.v1.Confirmation', '10': 'confirmationTime'},
  ],
};

/// Descriptor for `WalletTransaction`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List walletTransactionDescriptor = $convert.base64Decode(
    'ChFXYWxsZXRUcmFuc2FjdGlvbhISCgR0eGlkGAEgASgJUgR0eGlkEhkKCGZlZV9zYXRzGAIgAS'
    'gEUgdmZWVTYXRzEikKEHJlY2VpdmVkX3NhdG9zaGkYAyABKARSD3JlY2VpdmVkU2F0b3NoaRIh'
    'CgxzZW50X3NhdG9zaGkYBCABKARSC3NlbnRTYXRvc2hpEhgKB2FkZHJlc3MYBSABKAlSB2FkZH'
    'Jlc3MSIwoNYWRkcmVzc19sYWJlbBgGIAEoCVIMYWRkcmVzc0xhYmVsEhIKBG5vdGUYByABKAlS'
    'BG5vdGUSRAoRY29uZmlybWF0aW9uX3RpbWUYCCABKAsyFy53YWxsZXQudjEuQ29uZmlybWF0aW'
    '9uUhBjb25maXJtYXRpb25UaW1l');

@$core.Deprecated('Use listSidechainDepositsRequestDescriptor instead')
const ListSidechainDepositsRequest$json = {
  '1': 'ListSidechainDepositsRequest',
  '2': [
    {'1': 'wallet_id', '3': 1, '4': 1, '5': 9, '10': 'walletId'},
    {'1': 'slot', '3': 2, '4': 1, '5': 5, '10': 'slot'},
  ],
};

/// Descriptor for `ListSidechainDepositsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listSidechainDepositsRequestDescriptor = $convert.base64Decode(
    'ChxMaXN0U2lkZWNoYWluRGVwb3NpdHNSZXF1ZXN0EhsKCXdhbGxldF9pZBgBIAEoCVIId2FsbG'
    'V0SWQSEgoEc2xvdBgCIAEoBVIEc2xvdA==');

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
    {'1': 'amount', '3': 2, '4': 1, '5': 3, '10': 'amount'},
    {'1': 'fee', '3': 3, '4': 1, '5': 3, '10': 'fee'},
    {'1': 'confirmations', '3': 4, '4': 1, '5': 5, '10': 'confirmations'},
  ],
};

/// Descriptor for `ListSidechainDepositsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listSidechainDepositsResponseDescriptor = $convert.base64Decode(
    'Ch1MaXN0U2lkZWNoYWluRGVwb3NpdHNSZXNwb25zZRJVCghkZXBvc2l0cxgBIAMoCzI5LndhbG'
    'xldC52MS5MaXN0U2lkZWNoYWluRGVwb3NpdHNSZXNwb25zZS5TaWRlY2hhaW5EZXBvc2l0Ughk'
    'ZXBvc2l0cxp2ChBTaWRlY2hhaW5EZXBvc2l0EhIKBHR4aWQYASABKAlSBHR4aWQSFgoGYW1vdW'
    '50GAIgASgDUgZhbW91bnQSEAoDZmVlGAMgASgDUgNmZWUSJAoNY29uZmlybWF0aW9ucxgEIAEo'
    'BVINY29uZmlybWF0aW9ucw==');

@$core.Deprecated('Use createSidechainDepositRequestDescriptor instead')
const CreateSidechainDepositRequest$json = {
  '1': 'CreateSidechainDepositRequest',
  '2': [
    {'1': 'wallet_id', '3': 1, '4': 1, '5': 9, '10': 'walletId'},
    {'1': 'slot', '3': 2, '4': 1, '5': 3, '10': 'slot'},
    {'1': 'destination', '3': 3, '4': 1, '5': 9, '10': 'destination'},
    {'1': 'amount', '3': 4, '4': 1, '5': 1, '10': 'amount'},
    {'1': 'fee', '3': 5, '4': 1, '5': 1, '10': 'fee'},
  ],
};

/// Descriptor for `CreateSidechainDepositRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createSidechainDepositRequestDescriptor = $convert.base64Decode(
    'Ch1DcmVhdGVTaWRlY2hhaW5EZXBvc2l0UmVxdWVzdBIbCgl3YWxsZXRfaWQYASABKAlSCHdhbG'
    'xldElkEhIKBHNsb3QYAiABKANSBHNsb3QSIAoLZGVzdGluYXRpb24YAyABKAlSC2Rlc3RpbmF0'
    'aW9uEhYKBmFtb3VudBgEIAEoAVIGYW1vdW50EhAKA2ZlZRgFIAEoAVIDZmVl');

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

@$core.Deprecated('Use signMessageRequestDescriptor instead')
const SignMessageRequest$json = {
  '1': 'SignMessageRequest',
  '2': [
    {'1': 'wallet_id', '3': 1, '4': 1, '5': 9, '10': 'walletId'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `SignMessageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List signMessageRequestDescriptor = $convert.base64Decode(
    'ChJTaWduTWVzc2FnZVJlcXVlc3QSGwoJd2FsbGV0X2lkGAEgASgJUgh3YWxsZXRJZBIYCgdtZX'
    'NzYWdlGAIgASgJUgdtZXNzYWdl');

@$core.Deprecated('Use signMessageResponseDescriptor instead')
const SignMessageResponse$json = {
  '1': 'SignMessageResponse',
  '2': [
    {'1': 'signature', '3': 1, '4': 1, '5': 9, '10': 'signature'},
  ],
};

/// Descriptor for `SignMessageResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List signMessageResponseDescriptor = $convert.base64Decode(
    'ChNTaWduTWVzc2FnZVJlc3BvbnNlEhwKCXNpZ25hdHVyZRgBIAEoCVIJc2lnbmF0dXJl');

@$core.Deprecated('Use verifyMessageRequestDescriptor instead')
const VerifyMessageRequest$json = {
  '1': 'VerifyMessageRequest',
  '2': [
    {'1': 'wallet_id', '3': 1, '4': 1, '5': 9, '10': 'walletId'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'signature', '3': 3, '4': 1, '5': 9, '10': 'signature'},
    {'1': 'public_key', '3': 4, '4': 1, '5': 9, '10': 'publicKey'},
  ],
};

/// Descriptor for `VerifyMessageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List verifyMessageRequestDescriptor = $convert.base64Decode(
    'ChRWZXJpZnlNZXNzYWdlUmVxdWVzdBIbCgl3YWxsZXRfaWQYASABKAlSCHdhbGxldElkEhgKB2'
    '1lc3NhZ2UYAiABKAlSB21lc3NhZ2USHAoJc2lnbmF0dXJlGAMgASgJUglzaWduYXR1cmUSHQoK'
    'cHVibGljX2tleRgEIAEoCVIJcHVibGljS2V5');

@$core.Deprecated('Use verifyMessageResponseDescriptor instead')
const VerifyMessageResponse$json = {
  '1': 'VerifyMessageResponse',
  '2': [
    {'1': 'valid', '3': 1, '4': 1, '5': 8, '10': 'valid'},
  ],
};

/// Descriptor for `VerifyMessageResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List verifyMessageResponseDescriptor = $convert.base64Decode(
    'ChVWZXJpZnlNZXNzYWdlUmVzcG9uc2USFAoFdmFsaWQYASABKAhSBXZhbGlk');

@$core.Deprecated('Use getStatsResponseDescriptor instead')
const GetStatsResponse$json = {
  '1': 'GetStatsResponse',
  '2': [
    {'1': 'utxos_current', '3': 1, '4': 1, '5': 4, '10': 'utxosCurrent'},
    {'1': 'utxos_unique_addresses', '3': 2, '4': 1, '5': 4, '10': 'utxosUniqueAddresses'},
    {'1': 'sidechain_deposit_volume', '3': 3, '4': 1, '5': 3, '10': 'sidechainDepositVolume'},
    {'1': 'sidechain_deposit_volume_last_30_days', '3': 4, '4': 1, '5': 3, '10': 'sidechainDepositVolumeLast30Days'},
    {'1': 'transaction_count_total', '3': 5, '4': 1, '5': 3, '10': 'transactionCountTotal'},
    {'1': 'transaction_count_since_month', '3': 6, '4': 1, '5': 3, '10': 'transactionCountSinceMonth'},
  ],
};

/// Descriptor for `GetStatsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getStatsResponseDescriptor = $convert.base64Decode(
    'ChBHZXRTdGF0c1Jlc3BvbnNlEiMKDXV0eG9zX2N1cnJlbnQYASABKARSDHV0eG9zQ3VycmVudB'
    'I0ChZ1dHhvc191bmlxdWVfYWRkcmVzc2VzGAIgASgEUhR1dHhvc1VuaXF1ZUFkZHJlc3NlcxI4'
    'ChhzaWRlY2hhaW5fZGVwb3NpdF92b2x1bWUYAyABKANSFnNpZGVjaGFpbkRlcG9zaXRWb2x1bW'
    'USTwolc2lkZWNoYWluX2RlcG9zaXRfdm9sdW1lX2xhc3RfMzBfZGF5cxgEIAEoA1Igc2lkZWNo'
    'YWluRGVwb3NpdFZvbHVtZUxhc3QzMERheXMSNgoXdHJhbnNhY3Rpb25fY291bnRfdG90YWwYBS'
    'ABKANSFXRyYW5zYWN0aW9uQ291bnRUb3RhbBJBCh10cmFuc2FjdGlvbl9jb3VudF9zaW5jZV9t'
    'b250aBgGIAEoA1IadHJhbnNhY3Rpb25Db3VudFNpbmNlTW9udGg=');

@$core.Deprecated('Use unlockWalletRequestDescriptor instead')
const UnlockWalletRequest$json = {
  '1': 'UnlockWalletRequest',
  '2': [
    {'1': 'password', '3': 1, '4': 1, '5': 9, '10': 'password'},
  ],
};

/// Descriptor for `UnlockWalletRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unlockWalletRequestDescriptor = $convert.base64Decode(
    'ChNVbmxvY2tXYWxsZXRSZXF1ZXN0EhoKCHBhc3N3b3JkGAEgASgJUghwYXNzd29yZA==');

@$core.Deprecated('Use createChequeRequestDescriptor instead')
const CreateChequeRequest$json = {
  '1': 'CreateChequeRequest',
  '2': [
    {'1': 'wallet_id', '3': 1, '4': 1, '5': 9, '10': 'walletId'},
    {'1': 'expected_amount_sats', '3': 2, '4': 1, '5': 4, '10': 'expectedAmountSats'},
  ],
};

/// Descriptor for `CreateChequeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createChequeRequestDescriptor = $convert.base64Decode(
    'ChNDcmVhdGVDaGVxdWVSZXF1ZXN0EhsKCXdhbGxldF9pZBgBIAEoCVIId2FsbGV0SWQSMAoUZX'
    'hwZWN0ZWRfYW1vdW50X3NhdHMYAiABKARSEmV4cGVjdGVkQW1vdW50U2F0cw==');

@$core.Deprecated('Use createChequeResponseDescriptor instead')
const CreateChequeResponse$json = {
  '1': 'CreateChequeResponse',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'address', '3': 2, '4': 1, '5': 9, '10': 'address'},
    {'1': 'derivation_index', '3': 3, '4': 1, '5': 13, '10': 'derivationIndex'},
  ],
};

/// Descriptor for `CreateChequeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createChequeResponseDescriptor = $convert.base64Decode(
    'ChRDcmVhdGVDaGVxdWVSZXNwb25zZRIOCgJpZBgBIAEoA1ICaWQSGAoHYWRkcmVzcxgCIAEoCV'
    'IHYWRkcmVzcxIpChBkZXJpdmF0aW9uX2luZGV4GAMgASgNUg9kZXJpdmF0aW9uSW5kZXg=');

@$core.Deprecated('Use getChequeRequestDescriptor instead')
const GetChequeRequest$json = {
  '1': 'GetChequeRequest',
  '2': [
    {'1': 'wallet_id', '3': 1, '4': 1, '5': 9, '10': 'walletId'},
    {'1': 'id', '3': 2, '4': 1, '5': 3, '10': 'id'},
  ],
};

/// Descriptor for `GetChequeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getChequeRequestDescriptor = $convert.base64Decode(
    'ChBHZXRDaGVxdWVSZXF1ZXN0EhsKCXdhbGxldF9pZBgBIAEoCVIId2FsbGV0SWQSDgoCaWQYAi'
    'ABKANSAmlk');

@$core.Deprecated('Use getChequeResponseDescriptor instead')
const GetChequeResponse$json = {
  '1': 'GetChequeResponse',
  '2': [
    {'1': 'cheque', '3': 1, '4': 1, '5': 11, '6': '.wallet.v1.Cheque', '10': 'cheque'},
  ],
};

/// Descriptor for `GetChequeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getChequeResponseDescriptor = $convert.base64Decode(
    'ChFHZXRDaGVxdWVSZXNwb25zZRIpCgZjaGVxdWUYASABKAsyES53YWxsZXQudjEuQ2hlcXVlUg'
    'ZjaGVxdWU=');

@$core.Deprecated('Use getChequePrivateKeyRequestDescriptor instead')
const GetChequePrivateKeyRequest$json = {
  '1': 'GetChequePrivateKeyRequest',
  '2': [
    {'1': 'wallet_id', '3': 1, '4': 1, '5': 9, '10': 'walletId'},
    {'1': 'id', '3': 2, '4': 1, '5': 3, '10': 'id'},
  ],
};

/// Descriptor for `GetChequePrivateKeyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getChequePrivateKeyRequestDescriptor = $convert.base64Decode(
    'ChpHZXRDaGVxdWVQcml2YXRlS2V5UmVxdWVzdBIbCgl3YWxsZXRfaWQYASABKAlSCHdhbGxldE'
    'lkEg4KAmlkGAIgASgDUgJpZA==');

@$core.Deprecated('Use getChequePrivateKeyResponseDescriptor instead')
const GetChequePrivateKeyResponse$json = {
  '1': 'GetChequePrivateKeyResponse',
  '2': [
    {'1': 'private_key_wif', '3': 1, '4': 1, '5': 9, '10': 'privateKeyWif'},
  ],
};

/// Descriptor for `GetChequePrivateKeyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getChequePrivateKeyResponseDescriptor = $convert.base64Decode(
    'ChtHZXRDaGVxdWVQcml2YXRlS2V5UmVzcG9uc2USJgoPcHJpdmF0ZV9rZXlfd2lmGAEgASgJUg'
    '1wcml2YXRlS2V5V2lm');

@$core.Deprecated('Use chequeDescriptor instead')
const Cheque$json = {
  '1': 'Cheque',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'derivation_index', '3': 2, '4': 1, '5': 13, '10': 'derivationIndex'},
    {'1': 'address', '3': 3, '4': 1, '5': 9, '10': 'address'},
    {'1': 'expected_amount_sats', '3': 4, '4': 1, '5': 4, '10': 'expectedAmountSats'},
    {'1': 'funded', '3': 5, '4': 1, '5': 8, '10': 'funded'},
    {'1': 'funded_txid', '3': 6, '4': 1, '5': 9, '9': 0, '10': 'fundedTxid', '17': true},
    {'1': 'actual_amount_sats', '3': 7, '4': 1, '5': 4, '9': 1, '10': 'actualAmountSats', '17': true},
    {'1': 'created_at', '3': 8, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'createdAt'},
    {'1': 'funded_at', '3': 9, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '9': 2, '10': 'fundedAt', '17': true},
    {'1': 'private_key_wif', '3': 10, '4': 1, '5': 9, '9': 3, '10': 'privateKeyWif', '17': true},
    {'1': 'swept_txid', '3': 11, '4': 1, '5': 9, '9': 4, '10': 'sweptTxid', '17': true},
    {'1': 'swept_at', '3': 12, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '9': 5, '10': 'sweptAt', '17': true},
  ],
  '8': [
    {'1': '_funded_txid'},
    {'1': '_actual_amount_sats'},
    {'1': '_funded_at'},
    {'1': '_private_key_wif'},
    {'1': '_swept_txid'},
    {'1': '_swept_at'},
  ],
};

/// Descriptor for `Cheque`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chequeDescriptor = $convert.base64Decode(
    'CgZDaGVxdWUSDgoCaWQYASABKANSAmlkEikKEGRlcml2YXRpb25faW5kZXgYAiABKA1SD2Rlcm'
    'l2YXRpb25JbmRleBIYCgdhZGRyZXNzGAMgASgJUgdhZGRyZXNzEjAKFGV4cGVjdGVkX2Ftb3Vu'
    'dF9zYXRzGAQgASgEUhJleHBlY3RlZEFtb3VudFNhdHMSFgoGZnVuZGVkGAUgASgIUgZmdW5kZW'
    'QSJAoLZnVuZGVkX3R4aWQYBiABKAlIAFIKZnVuZGVkVHhpZIgBARIxChJhY3R1YWxfYW1vdW50'
    'X3NhdHMYByABKARIAVIQYWN0dWFsQW1vdW50U2F0c4gBARI5CgpjcmVhdGVkX2F0GAggASgLMh'
    'ouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJY3JlYXRlZEF0EjwKCWZ1bmRlZF9hdBgJIAEo'
    'CzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBIAlIIZnVuZGVkQXSIAQESKwoPcHJpdmF0ZV'
    '9rZXlfd2lmGAogASgJSANSDXByaXZhdGVLZXlXaWaIAQESIgoKc3dlcHRfdHhpZBgLIAEoCUgE'
    'Uglzd2VwdFR4aWSIAQESOgoIc3dlcHRfYXQYDCABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZX'
    'N0YW1wSAVSB3N3ZXB0QXSIAQFCDgoMX2Z1bmRlZF90eGlkQhUKE19hY3R1YWxfYW1vdW50X3Nh'
    'dHNCDAoKX2Z1bmRlZF9hdEISChBfcHJpdmF0ZV9rZXlfd2lmQg0KC19zd2VwdF90eGlkQgsKCV'
    '9zd2VwdF9hdA==');

@$core.Deprecated('Use listChequesRequestDescriptor instead')
const ListChequesRequest$json = {
  '1': 'ListChequesRequest',
  '2': [
    {'1': 'wallet_id', '3': 1, '4': 1, '5': 9, '10': 'walletId'},
  ],
};

/// Descriptor for `ListChequesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listChequesRequestDescriptor = $convert.base64Decode(
    'ChJMaXN0Q2hlcXVlc1JlcXVlc3QSGwoJd2FsbGV0X2lkGAEgASgJUgh3YWxsZXRJZA==');

@$core.Deprecated('Use listChequesResponseDescriptor instead')
const ListChequesResponse$json = {
  '1': 'ListChequesResponse',
  '2': [
    {'1': 'cheques', '3': 1, '4': 3, '5': 11, '6': '.wallet.v1.Cheque', '10': 'cheques'},
  ],
};

/// Descriptor for `ListChequesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listChequesResponseDescriptor = $convert.base64Decode(
    'ChNMaXN0Q2hlcXVlc1Jlc3BvbnNlEisKB2NoZXF1ZXMYASADKAsyES53YWxsZXQudjEuQ2hlcX'
    'VlUgdjaGVxdWVz');

@$core.Deprecated('Use checkChequeFundingRequestDescriptor instead')
const CheckChequeFundingRequest$json = {
  '1': 'CheckChequeFundingRequest',
  '2': [
    {'1': 'wallet_id', '3': 1, '4': 1, '5': 9, '10': 'walletId'},
    {'1': 'id', '3': 2, '4': 1, '5': 3, '10': 'id'},
  ],
};

/// Descriptor for `CheckChequeFundingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List checkChequeFundingRequestDescriptor = $convert.base64Decode(
    'ChlDaGVja0NoZXF1ZUZ1bmRpbmdSZXF1ZXN0EhsKCXdhbGxldF9pZBgBIAEoCVIId2FsbGV0SW'
    'QSDgoCaWQYAiABKANSAmlk');

@$core.Deprecated('Use checkChequeFundingResponseDescriptor instead')
const CheckChequeFundingResponse$json = {
  '1': 'CheckChequeFundingResponse',
  '2': [
    {'1': 'funded', '3': 1, '4': 1, '5': 8, '10': 'funded'},
    {'1': 'actual_amount_sats', '3': 2, '4': 1, '5': 4, '10': 'actualAmountSats'},
    {'1': 'funded_txid', '3': 3, '4': 1, '5': 9, '10': 'fundedTxid'},
    {'1': 'funded_at', '3': 4, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '9': 0, '10': 'fundedAt', '17': true},
  ],
  '8': [
    {'1': '_funded_at'},
  ],
};

/// Descriptor for `CheckChequeFundingResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List checkChequeFundingResponseDescriptor = $convert.base64Decode(
    'ChpDaGVja0NoZXF1ZUZ1bmRpbmdSZXNwb25zZRIWCgZmdW5kZWQYASABKAhSBmZ1bmRlZBIsCh'
    'JhY3R1YWxfYW1vdW50X3NhdHMYAiABKARSEGFjdHVhbEFtb3VudFNhdHMSHwoLZnVuZGVkX3R4'
    'aWQYAyABKAlSCmZ1bmRlZFR4aWQSPAoJZnVuZGVkX2F0GAQgASgLMhouZ29vZ2xlLnByb3RvYn'
    'VmLlRpbWVzdGFtcEgAUghmdW5kZWRBdIgBAUIMCgpfZnVuZGVkX2F0');

@$core.Deprecated('Use sweepChequeRequestDescriptor instead')
const SweepChequeRequest$json = {
  '1': 'SweepChequeRequest',
  '2': [
    {'1': 'wallet_id', '3': 1, '4': 1, '5': 9, '10': 'walletId'},
    {'1': 'private_key_wif', '3': 2, '4': 1, '5': 9, '10': 'privateKeyWif'},
    {'1': 'destination_address', '3': 3, '4': 1, '5': 9, '10': 'destinationAddress'},
    {'1': 'fee_sat_per_vbyte', '3': 4, '4': 1, '5': 4, '10': 'feeSatPerVbyte'},
  ],
};

/// Descriptor for `SweepChequeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sweepChequeRequestDescriptor = $convert.base64Decode(
    'ChJTd2VlcENoZXF1ZVJlcXVlc3QSGwoJd2FsbGV0X2lkGAEgASgJUgh3YWxsZXRJZBImCg9wcm'
    'l2YXRlX2tleV93aWYYAiABKAlSDXByaXZhdGVLZXlXaWYSLwoTZGVzdGluYXRpb25fYWRkcmVz'
    'cxgDIAEoCVISZGVzdGluYXRpb25BZGRyZXNzEikKEWZlZV9zYXRfcGVyX3ZieXRlGAQgASgEUg'
    '5mZWVTYXRQZXJWYnl0ZQ==');

@$core.Deprecated('Use sweepChequeResponseDescriptor instead')
const SweepChequeResponse$json = {
  '1': 'SweepChequeResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'amount_sats', '3': 2, '4': 1, '5': 4, '10': 'amountSats'},
  ],
};

/// Descriptor for `SweepChequeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sweepChequeResponseDescriptor = $convert.base64Decode(
    'ChNTd2VlcENoZXF1ZVJlc3BvbnNlEhIKBHR4aWQYASABKAlSBHR4aWQSHwoLYW1vdW50X3NhdH'
    'MYAiABKARSCmFtb3VudFNhdHM=');

@$core.Deprecated('Use deleteChequeRequestDescriptor instead')
const DeleteChequeRequest$json = {
  '1': 'DeleteChequeRequest',
  '2': [
    {'1': 'wallet_id', '3': 1, '4': 1, '5': 9, '10': 'walletId'},
    {'1': 'id', '3': 2, '4': 1, '5': 3, '10': 'id'},
  ],
};

/// Descriptor for `DeleteChequeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteChequeRequestDescriptor = $convert.base64Decode(
    'ChNEZWxldGVDaGVxdWVSZXF1ZXN0EhsKCXdhbGxldF9pZBgBIAEoCVIId2FsbGV0SWQSDgoCaW'
    'QYAiABKANSAmlk');

const $core.Map<$core.String, $core.dynamic> WalletServiceBase$json = {
  '1': 'WalletService',
  '2': [
    {'1': 'SendTransaction', '2': '.wallet.v1.SendTransactionRequest', '3': '.wallet.v1.SendTransactionResponse'},
    {'1': 'GetBalance', '2': '.wallet.v1.GetBalanceRequest', '3': '.wallet.v1.GetBalanceResponse'},
    {'1': 'GetNewAddress', '2': '.wallet.v1.GetNewAddressRequest', '3': '.wallet.v1.GetNewAddressResponse'},
    {'1': 'ListTransactions', '2': '.wallet.v1.ListTransactionsRequest', '3': '.wallet.v1.ListTransactionsResponse'},
    {'1': 'ListUnspent', '2': '.wallet.v1.ListUnspentRequest', '3': '.wallet.v1.ListUnspentResponse'},
    {'1': 'ListReceiveAddresses', '2': '.wallet.v1.ListReceiveAddressesRequest', '3': '.wallet.v1.ListReceiveAddressesResponse'},
    {'1': 'ListSidechainDeposits', '2': '.wallet.v1.ListSidechainDepositsRequest', '3': '.wallet.v1.ListSidechainDepositsResponse'},
    {'1': 'CreateSidechainDeposit', '2': '.wallet.v1.CreateSidechainDepositRequest', '3': '.wallet.v1.CreateSidechainDepositResponse'},
    {'1': 'SignMessage', '2': '.wallet.v1.SignMessageRequest', '3': '.wallet.v1.SignMessageResponse'},
    {'1': 'VerifyMessage', '2': '.wallet.v1.VerifyMessageRequest', '3': '.wallet.v1.VerifyMessageResponse'},
    {'1': 'GetStats', '2': '.wallet.v1.GetStatsRequest', '3': '.wallet.v1.GetStatsResponse'},
    {'1': 'UnlockWallet', '2': '.wallet.v1.UnlockWalletRequest', '3': '.google.protobuf.Empty'},
    {'1': 'LockWallet', '2': '.google.protobuf.Empty', '3': '.google.protobuf.Empty'},
    {'1': 'IsWalletUnlocked', '2': '.google.protobuf.Empty', '3': '.google.protobuf.Empty'},
    {'1': 'CreateCheque', '2': '.wallet.v1.CreateChequeRequest', '3': '.wallet.v1.CreateChequeResponse'},
    {'1': 'GetCheque', '2': '.wallet.v1.GetChequeRequest', '3': '.wallet.v1.GetChequeResponse'},
    {'1': 'GetChequePrivateKey', '2': '.wallet.v1.GetChequePrivateKeyRequest', '3': '.wallet.v1.GetChequePrivateKeyResponse'},
    {'1': 'ListCheques', '2': '.wallet.v1.ListChequesRequest', '3': '.wallet.v1.ListChequesResponse'},
    {'1': 'CheckChequeFunding', '2': '.wallet.v1.CheckChequeFundingRequest', '3': '.wallet.v1.CheckChequeFundingResponse'},
    {'1': 'SweepCheque', '2': '.wallet.v1.SweepChequeRequest', '3': '.wallet.v1.SweepChequeResponse'},
    {'1': 'DeleteCheque', '2': '.wallet.v1.DeleteChequeRequest', '3': '.google.protobuf.Empty'},
  ],
};

@$core.Deprecated('Use walletServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> WalletServiceBase$messageJson = {
  '.wallet.v1.SendTransactionRequest': SendTransactionRequest$json,
  '.wallet.v1.SendTransactionRequest.DestinationsEntry': SendTransactionRequest_DestinationsEntry$json,
  '.wallet.v1.UnspentOutput': UnspentOutput$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.bitwindowd.v1.DenialInfo': $2.DenialInfo$json,
  '.bitwindowd.v1.ExecutedDenial': $2.ExecutedDenial$json,
  '.wallet.v1.SendTransactionResponse': SendTransactionResponse$json,
  '.wallet.v1.GetBalanceRequest': GetBalanceRequest$json,
  '.wallet.v1.GetBalanceResponse': GetBalanceResponse$json,
  '.wallet.v1.GetNewAddressRequest': GetNewAddressRequest$json,
  '.wallet.v1.GetNewAddressResponse': GetNewAddressResponse$json,
  '.wallet.v1.ListTransactionsRequest': ListTransactionsRequest$json,
  '.wallet.v1.ListTransactionsResponse': ListTransactionsResponse$json,
  '.wallet.v1.WalletTransaction': WalletTransaction$json,
  '.wallet.v1.Confirmation': Confirmation$json,
  '.wallet.v1.ListUnspentRequest': ListUnspentRequest$json,
  '.wallet.v1.ListUnspentResponse': ListUnspentResponse$json,
  '.wallet.v1.ListReceiveAddressesRequest': ListReceiveAddressesRequest$json,
  '.wallet.v1.ListReceiveAddressesResponse': ListReceiveAddressesResponse$json,
  '.wallet.v1.ReceiveAddress': ReceiveAddress$json,
  '.wallet.v1.ListSidechainDepositsRequest': ListSidechainDepositsRequest$json,
  '.wallet.v1.ListSidechainDepositsResponse': ListSidechainDepositsResponse$json,
  '.wallet.v1.ListSidechainDepositsResponse.SidechainDeposit': ListSidechainDepositsResponse_SidechainDeposit$json,
  '.wallet.v1.CreateSidechainDepositRequest': CreateSidechainDepositRequest$json,
  '.wallet.v1.CreateSidechainDepositResponse': CreateSidechainDepositResponse$json,
  '.wallet.v1.SignMessageRequest': SignMessageRequest$json,
  '.wallet.v1.SignMessageResponse': SignMessageResponse$json,
  '.wallet.v1.VerifyMessageRequest': VerifyMessageRequest$json,
  '.wallet.v1.VerifyMessageResponse': VerifyMessageResponse$json,
  '.wallet.v1.GetStatsRequest': GetStatsRequest$json,
  '.wallet.v1.GetStatsResponse': GetStatsResponse$json,
  '.wallet.v1.UnlockWalletRequest': UnlockWalletRequest$json,
  '.google.protobuf.Empty': $1.Empty$json,
  '.wallet.v1.CreateChequeRequest': CreateChequeRequest$json,
  '.wallet.v1.CreateChequeResponse': CreateChequeResponse$json,
  '.wallet.v1.GetChequeRequest': GetChequeRequest$json,
  '.wallet.v1.GetChequeResponse': GetChequeResponse$json,
  '.wallet.v1.Cheque': Cheque$json,
  '.wallet.v1.GetChequePrivateKeyRequest': GetChequePrivateKeyRequest$json,
  '.wallet.v1.GetChequePrivateKeyResponse': GetChequePrivateKeyResponse$json,
  '.wallet.v1.ListChequesRequest': ListChequesRequest$json,
  '.wallet.v1.ListChequesResponse': ListChequesResponse$json,
  '.wallet.v1.CheckChequeFundingRequest': CheckChequeFundingRequest$json,
  '.wallet.v1.CheckChequeFundingResponse': CheckChequeFundingResponse$json,
  '.wallet.v1.SweepChequeRequest': SweepChequeRequest$json,
  '.wallet.v1.SweepChequeResponse': SweepChequeResponse$json,
  '.wallet.v1.DeleteChequeRequest': DeleteChequeRequest$json,
};

/// Descriptor for `WalletService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List walletServiceDescriptor = $convert.base64Decode(
    'Cg1XYWxsZXRTZXJ2aWNlElgKD1NlbmRUcmFuc2FjdGlvbhIhLndhbGxldC52MS5TZW5kVHJhbn'
    'NhY3Rpb25SZXF1ZXN0GiIud2FsbGV0LnYxLlNlbmRUcmFuc2FjdGlvblJlc3BvbnNlEkkKCkdl'
    'dEJhbGFuY2USHC53YWxsZXQudjEuR2V0QmFsYW5jZVJlcXVlc3QaHS53YWxsZXQudjEuR2V0Qm'
    'FsYW5jZVJlc3BvbnNlElIKDUdldE5ld0FkZHJlc3MSHy53YWxsZXQudjEuR2V0TmV3QWRkcmVz'
    'c1JlcXVlc3QaIC53YWxsZXQudjEuR2V0TmV3QWRkcmVzc1Jlc3BvbnNlElsKEExpc3RUcmFuc2'
    'FjdGlvbnMSIi53YWxsZXQudjEuTGlzdFRyYW5zYWN0aW9uc1JlcXVlc3QaIy53YWxsZXQudjEu'
    'TGlzdFRyYW5zYWN0aW9uc1Jlc3BvbnNlEkwKC0xpc3RVbnNwZW50Eh0ud2FsbGV0LnYxLkxpc3'
    'RVbnNwZW50UmVxdWVzdBoeLndhbGxldC52MS5MaXN0VW5zcGVudFJlc3BvbnNlEmcKFExpc3RS'
    'ZWNlaXZlQWRkcmVzc2VzEiYud2FsbGV0LnYxLkxpc3RSZWNlaXZlQWRkcmVzc2VzUmVxdWVzdB'
    'onLndhbGxldC52MS5MaXN0UmVjZWl2ZUFkZHJlc3Nlc1Jlc3BvbnNlEmoKFUxpc3RTaWRlY2hh'
    'aW5EZXBvc2l0cxInLndhbGxldC52MS5MaXN0U2lkZWNoYWluRGVwb3NpdHNSZXF1ZXN0Gigud2'
    'FsbGV0LnYxLkxpc3RTaWRlY2hhaW5EZXBvc2l0c1Jlc3BvbnNlEm0KFkNyZWF0ZVNpZGVjaGFp'
    'bkRlcG9zaXQSKC53YWxsZXQudjEuQ3JlYXRlU2lkZWNoYWluRGVwb3NpdFJlcXVlc3QaKS53YW'
    'xsZXQudjEuQ3JlYXRlU2lkZWNoYWluRGVwb3NpdFJlc3BvbnNlEkwKC1NpZ25NZXNzYWdlEh0u'
    'd2FsbGV0LnYxLlNpZ25NZXNzYWdlUmVxdWVzdBoeLndhbGxldC52MS5TaWduTWVzc2FnZVJlc3'
    'BvbnNlElIKDVZlcmlmeU1lc3NhZ2USHy53YWxsZXQudjEuVmVyaWZ5TWVzc2FnZVJlcXVlc3Qa'
    'IC53YWxsZXQudjEuVmVyaWZ5TWVzc2FnZVJlc3BvbnNlEkMKCEdldFN0YXRzEhoud2FsbGV0Ln'
    'YxLkdldFN0YXRzUmVxdWVzdBobLndhbGxldC52MS5HZXRTdGF0c1Jlc3BvbnNlEkYKDFVubG9j'
    'a1dhbGxldBIeLndhbGxldC52MS5VbmxvY2tXYWxsZXRSZXF1ZXN0GhYuZ29vZ2xlLnByb3RvYn'
    'VmLkVtcHR5EjwKCkxvY2tXYWxsZXQSFi5nb29nbGUucHJvdG9idWYuRW1wdHkaFi5nb29nbGUu'
    'cHJvdG9idWYuRW1wdHkSQgoQSXNXYWxsZXRVbmxvY2tlZBIWLmdvb2dsZS5wcm90b2J1Zi5FbX'
    'B0eRoWLmdvb2dsZS5wcm90b2J1Zi5FbXB0eRJPCgxDcmVhdGVDaGVxdWUSHi53YWxsZXQudjEu'
    'Q3JlYXRlQ2hlcXVlUmVxdWVzdBofLndhbGxldC52MS5DcmVhdGVDaGVxdWVSZXNwb25zZRJGCg'
    'lHZXRDaGVxdWUSGy53YWxsZXQudjEuR2V0Q2hlcXVlUmVxdWVzdBocLndhbGxldC52MS5HZXRD'
    'aGVxdWVSZXNwb25zZRJkChNHZXRDaGVxdWVQcml2YXRlS2V5EiUud2FsbGV0LnYxLkdldENoZX'
    'F1ZVByaXZhdGVLZXlSZXF1ZXN0GiYud2FsbGV0LnYxLkdldENoZXF1ZVByaXZhdGVLZXlSZXNw'
    'b25zZRJMCgtMaXN0Q2hlcXVlcxIdLndhbGxldC52MS5MaXN0Q2hlcXVlc1JlcXVlc3QaHi53YW'
    'xsZXQudjEuTGlzdENoZXF1ZXNSZXNwb25zZRJhChJDaGVja0NoZXF1ZUZ1bmRpbmcSJC53YWxs'
    'ZXQudjEuQ2hlY2tDaGVxdWVGdW5kaW5nUmVxdWVzdBolLndhbGxldC52MS5DaGVja0NoZXF1ZU'
    'Z1bmRpbmdSZXNwb25zZRJMCgtTd2VlcENoZXF1ZRIdLndhbGxldC52MS5Td2VlcENoZXF1ZVJl'
    'cXVlc3QaHi53YWxsZXQudjEuU3dlZXBDaGVxdWVSZXNwb25zZRJGCgxEZWxldGVDaGVxdWUSHi'
    '53YWxsZXQudjEuRGVsZXRlQ2hlcXVlUmVxdWVzdBoWLmdvb2dsZS5wcm90b2J1Zi5FbXB0eQ==');

