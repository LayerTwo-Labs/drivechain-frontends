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

@$core.Deprecated('Use coinSelectionStrategyDescriptor instead')
const CoinSelectionStrategy$json = {
  '1': 'CoinSelectionStrategy',
  '2': [
    {'1': 'COIN_SELECTION_STRATEGY_UNSPECIFIED', '2': 0},
    {'1': 'COIN_SELECTION_STRATEGY_LARGEST_FIRST', '2': 1},
    {'1': 'COIN_SELECTION_STRATEGY_SMALLEST_FIRST', '2': 2},
    {'1': 'COIN_SELECTION_STRATEGY_RANDOM', '2': 3},
  ],
};

/// Descriptor for `CoinSelectionStrategy`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List coinSelectionStrategyDescriptor = $convert.base64Decode(
    'ChVDb2luU2VsZWN0aW9uU3RyYXRlZ3kSJwojQ09JTl9TRUxFQ1RJT05fU1RSQVRFR1lfVU5TUE'
    'VDSUZJRUQQABIpCiVDT0lOX1NFTEVDVElPTl9TVFJBVEVHWV9MQVJHRVNUX0ZJUlNUEAESKgom'
    'Q09JTl9TRUxFQ1RJT05fU1RSQVRFR1lfU01BTExFU1RfRklSU1QQAhIiCh5DT0lOX1NFTEVDVE'
    'lPTl9TVFJBVEVHWV9SQU5ET00QAw==');

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

@$core.Deprecated('Use createBitcoinCoreWalletRequestDescriptor instead')
const CreateBitcoinCoreWalletRequest$json = {
  '1': 'CreateBitcoinCoreWalletRequest',
  '2': [
    {'1': 'seed_hex', '3': 1, '4': 1, '5': 9, '10': 'seedHex'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `CreateBitcoinCoreWalletRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createBitcoinCoreWalletRequestDescriptor = $convert.base64Decode(
    'Ch5DcmVhdGVCaXRjb2luQ29yZVdhbGxldFJlcXVlc3QSGQoIc2VlZF9oZXgYASABKAlSB3NlZW'
    'RIZXgSEgoEbmFtZRgCIAEoCVIEbmFtZQ==');

@$core.Deprecated('Use createBitcoinCoreWalletResponseDescriptor instead')
const CreateBitcoinCoreWalletResponse$json = {
  '1': 'CreateBitcoinCoreWalletResponse',
  '2': [
    {'1': 'wallet_id', '3': 1, '4': 1, '5': 9, '10': 'walletId'},
    {'1': 'core_wallet_name', '3': 2, '4': 1, '5': 9, '10': 'coreWalletName'},
    {'1': 'first_address', '3': 3, '4': 1, '5': 9, '10': 'firstAddress'},
  ],
};

/// Descriptor for `CreateBitcoinCoreWalletResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createBitcoinCoreWalletResponseDescriptor = $convert.base64Decode(
    'Ch9DcmVhdGVCaXRjb2luQ29yZVdhbGxldFJlc3BvbnNlEhsKCXdhbGxldF9pZBgBIAEoCVIId2'
    'FsbGV0SWQSKAoQY29yZV93YWxsZXRfbmFtZRgCIAEoCVIOY29yZVdhbGxldE5hbWUSIwoNZmly'
    'c3RfYWRkcmVzcxgDIAEoCVIMZmlyc3RBZGRyZXNz');

@$core.Deprecated('Use uTXOMetadataDescriptor instead')
const UTXOMetadata$json = {
  '1': 'UTXOMetadata',
  '2': [
    {'1': 'outpoint', '3': 1, '4': 1, '5': 9, '10': 'outpoint'},
    {'1': 'is_frozen', '3': 2, '4': 1, '5': 8, '10': 'isFrozen'},
    {'1': 'label', '3': 3, '4': 1, '5': 9, '10': 'label'},
  ],
};

/// Descriptor for `UTXOMetadata`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List uTXOMetadataDescriptor = $convert.base64Decode(
    'CgxVVFhPTWV0YWRhdGESGgoIb3V0cG9pbnQYASABKAlSCG91dHBvaW50EhsKCWlzX2Zyb3plbh'
    'gCIAEoCFIIaXNGcm96ZW4SFAoFbGFiZWwYAyABKAlSBWxhYmVs');

@$core.Deprecated('Use setUTXOMetadataRequestDescriptor instead')
const SetUTXOMetadataRequest$json = {
  '1': 'SetUTXOMetadataRequest',
  '2': [
    {'1': 'outpoint', '3': 1, '4': 1, '5': 9, '10': 'outpoint'},
    {'1': 'is_frozen', '3': 2, '4': 1, '5': 8, '9': 0, '10': 'isFrozen', '17': true},
    {'1': 'label', '3': 3, '4': 1, '5': 9, '9': 1, '10': 'label', '17': true},
  ],
  '8': [
    {'1': '_is_frozen'},
    {'1': '_label'},
  ],
};

/// Descriptor for `SetUTXOMetadataRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setUTXOMetadataRequestDescriptor = $convert.base64Decode(
    'ChZTZXRVVFhPTWV0YWRhdGFSZXF1ZXN0EhoKCG91dHBvaW50GAEgASgJUghvdXRwb2ludBIgCg'
    'lpc19mcm96ZW4YAiABKAhIAFIIaXNGcm96ZW6IAQESGQoFbGFiZWwYAyABKAlIAVIFbGFiZWyI'
    'AQFCDAoKX2lzX2Zyb3plbkIICgZfbGFiZWw=');

@$core.Deprecated('Use getUTXOMetadataRequestDescriptor instead')
const GetUTXOMetadataRequest$json = {
  '1': 'GetUTXOMetadataRequest',
  '2': [
    {'1': 'outpoints', '3': 1, '4': 3, '5': 9, '10': 'outpoints'},
  ],
};

/// Descriptor for `GetUTXOMetadataRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getUTXOMetadataRequestDescriptor = $convert.base64Decode(
    'ChZHZXRVVFhPTWV0YWRhdGFSZXF1ZXN0EhwKCW91dHBvaW50cxgBIAMoCVIJb3V0cG9pbnRz');

@$core.Deprecated('Use getUTXOMetadataResponseDescriptor instead')
const GetUTXOMetadataResponse$json = {
  '1': 'GetUTXOMetadataResponse',
  '2': [
    {'1': 'metadata', '3': 1, '4': 3, '5': 11, '6': '.wallet.v1.GetUTXOMetadataResponse.MetadataEntry', '10': 'metadata'},
  ],
  '3': [GetUTXOMetadataResponse_MetadataEntry$json],
};

@$core.Deprecated('Use getUTXOMetadataResponseDescriptor instead')
const GetUTXOMetadataResponse_MetadataEntry$json = {
  '1': 'MetadataEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 11, '6': '.wallet.v1.UTXOMetadata', '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `GetUTXOMetadataResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getUTXOMetadataResponseDescriptor = $convert.base64Decode(
    'ChdHZXRVVFhPTWV0YWRhdGFSZXNwb25zZRJMCghtZXRhZGF0YRgBIAMoCzIwLndhbGxldC52MS'
    '5HZXRVVFhPTWV0YWRhdGFSZXNwb25zZS5NZXRhZGF0YUVudHJ5UghtZXRhZGF0YRpUCg1NZXRh'
    'ZGF0YUVudHJ5EhAKA2tleRgBIAEoCVIDa2V5Ei0KBXZhbHVlGAIgASgLMhcud2FsbGV0LnYxLl'
    'VUWE9NZXRhZGF0YVIFdmFsdWU6AjgB');

@$core.Deprecated('Use setCoinSelectionStrategyRequestDescriptor instead')
const SetCoinSelectionStrategyRequest$json = {
  '1': 'SetCoinSelectionStrategyRequest',
  '2': [
    {'1': 'strategy', '3': 1, '4': 1, '5': 14, '6': '.wallet.v1.CoinSelectionStrategy', '10': 'strategy'},
  ],
};

/// Descriptor for `SetCoinSelectionStrategyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setCoinSelectionStrategyRequestDescriptor = $convert.base64Decode(
    'Ch9TZXRDb2luU2VsZWN0aW9uU3RyYXRlZ3lSZXF1ZXN0EjwKCHN0cmF0ZWd5GAEgASgOMiAud2'
    'FsbGV0LnYxLkNvaW5TZWxlY3Rpb25TdHJhdGVneVIIc3RyYXRlZ3k=');

@$core.Deprecated('Use getCoinSelectionStrategyResponseDescriptor instead')
const GetCoinSelectionStrategyResponse$json = {
  '1': 'GetCoinSelectionStrategyResponse',
  '2': [
    {'1': 'strategy', '3': 1, '4': 1, '5': 14, '6': '.wallet.v1.CoinSelectionStrategy', '10': 'strategy'},
  ],
};

/// Descriptor for `GetCoinSelectionStrategyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCoinSelectionStrategyResponseDescriptor = $convert.base64Decode(
    'CiBHZXRDb2luU2VsZWN0aW9uU3RyYXRlZ3lSZXNwb25zZRI8CghzdHJhdGVneRgBIAEoDjIgLn'
    'dhbGxldC52MS5Db2luU2VsZWN0aW9uU3RyYXRlZ3lSCHN0cmF0ZWd5');

@$core.Deprecated('Use getTransactionDetailsRequestDescriptor instead')
const GetTransactionDetailsRequest$json = {
  '1': 'GetTransactionDetailsRequest',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `GetTransactionDetailsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTransactionDetailsRequestDescriptor = $convert.base64Decode(
    'ChxHZXRUcmFuc2FjdGlvbkRldGFpbHNSZXF1ZXN0EhIKBHR4aWQYASABKAlSBHR4aWQ=');

@$core.Deprecated('Use getTransactionDetailsResponseDescriptor instead')
const GetTransactionDetailsResponse$json = {
  '1': 'GetTransactionDetailsResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'blockhash', '3': 2, '4': 1, '5': 9, '10': 'blockhash'},
    {'1': 'confirmations', '3': 3, '4': 1, '5': 5, '10': 'confirmations'},
    {'1': 'block_time', '3': 4, '4': 1, '5': 3, '10': 'blockTime'},
    {'1': 'version', '3': 5, '4': 1, '5': 5, '10': 'version'},
    {'1': 'locktime', '3': 6, '4': 1, '5': 5, '10': 'locktime'},
    {'1': 'size_bytes', '3': 7, '4': 1, '5': 5, '10': 'sizeBytes'},
    {'1': 'vsize_vbytes', '3': 8, '4': 1, '5': 5, '10': 'vsizeVbytes'},
    {'1': 'weight_wu', '3': 9, '4': 1, '5': 5, '10': 'weightWu'},
    {'1': 'fee_sats', '3': 10, '4': 1, '5': 3, '10': 'feeSats'},
    {'1': 'fee_rate_sat_vb', '3': 11, '4': 1, '5': 1, '10': 'feeRateSatVb'},
    {'1': 'inputs', '3': 12, '4': 3, '5': 11, '6': '.wallet.v1.TransactionInput', '10': 'inputs'},
    {'1': 'total_input_sats', '3': 13, '4': 1, '5': 3, '10': 'totalInputSats'},
    {'1': 'outputs', '3': 14, '4': 3, '5': 11, '6': '.wallet.v1.TransactionOutput', '10': 'outputs'},
    {'1': 'total_output_sats', '3': 15, '4': 1, '5': 3, '10': 'totalOutputSats'},
    {'1': 'hex', '3': 16, '4': 1, '5': 9, '10': 'hex'},
  ],
};

/// Descriptor for `GetTransactionDetailsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTransactionDetailsResponseDescriptor = $convert.base64Decode(
    'Ch1HZXRUcmFuc2FjdGlvbkRldGFpbHNSZXNwb25zZRISCgR0eGlkGAEgASgJUgR0eGlkEhwKCW'
    'Jsb2NraGFzaBgCIAEoCVIJYmxvY2toYXNoEiQKDWNvbmZpcm1hdGlvbnMYAyABKAVSDWNvbmZp'
    'cm1hdGlvbnMSHQoKYmxvY2tfdGltZRgEIAEoA1IJYmxvY2tUaW1lEhgKB3ZlcnNpb24YBSABKA'
    'VSB3ZlcnNpb24SGgoIbG9ja3RpbWUYBiABKAVSCGxvY2t0aW1lEh0KCnNpemVfYnl0ZXMYByAB'
    'KAVSCXNpemVCeXRlcxIhCgx2c2l6ZV92Ynl0ZXMYCCABKAVSC3ZzaXplVmJ5dGVzEhsKCXdlaW'
    'dodF93dRgJIAEoBVIId2VpZ2h0V3USGQoIZmVlX3NhdHMYCiABKANSB2ZlZVNhdHMSJQoPZmVl'
    'X3JhdGVfc2F0X3ZiGAsgASgBUgxmZWVSYXRlU2F0VmISMwoGaW5wdXRzGAwgAygLMhsud2FsbG'
    'V0LnYxLlRyYW5zYWN0aW9uSW5wdXRSBmlucHV0cxIoChB0b3RhbF9pbnB1dF9zYXRzGA0gASgD'
    'Ug50b3RhbElucHV0U2F0cxI2CgdvdXRwdXRzGA4gAygLMhwud2FsbGV0LnYxLlRyYW5zYWN0aW'
    '9uT3V0cHV0UgdvdXRwdXRzEioKEXRvdGFsX291dHB1dF9zYXRzGA8gASgDUg90b3RhbE91dHB1'
    'dFNhdHMSEAoDaGV4GBAgASgJUgNoZXg=');

@$core.Deprecated('Use transactionInputDescriptor instead')
const TransactionInput$json = {
  '1': 'TransactionInput',
  '2': [
    {'1': 'index', '3': 1, '4': 1, '5': 5, '10': 'index'},
    {'1': 'prev_txid', '3': 2, '4': 1, '5': 9, '10': 'prevTxid'},
    {'1': 'prev_vout', '3': 3, '4': 1, '5': 5, '10': 'prevVout'},
    {'1': 'address', '3': 4, '4': 1, '5': 9, '10': 'address'},
    {'1': 'value_sats', '3': 5, '4': 1, '5': 3, '10': 'valueSats'},
    {'1': 'script_sig_asm', '3': 6, '4': 1, '5': 9, '10': 'scriptSigAsm'},
    {'1': 'script_sig_hex', '3': 7, '4': 1, '5': 9, '10': 'scriptSigHex'},
    {'1': 'witness', '3': 8, '4': 3, '5': 9, '10': 'witness'},
    {'1': 'sequence', '3': 9, '4': 1, '5': 3, '10': 'sequence'},
    {'1': 'is_coinbase', '3': 10, '4': 1, '5': 8, '10': 'isCoinbase'},
  ],
};

/// Descriptor for `TransactionInput`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transactionInputDescriptor = $convert.base64Decode(
    'ChBUcmFuc2FjdGlvbklucHV0EhQKBWluZGV4GAEgASgFUgVpbmRleBIbCglwcmV2X3R4aWQYAi'
    'ABKAlSCHByZXZUeGlkEhsKCXByZXZfdm91dBgDIAEoBVIIcHJldlZvdXQSGAoHYWRkcmVzcxgE'
    'IAEoCVIHYWRkcmVzcxIdCgp2YWx1ZV9zYXRzGAUgASgDUgl2YWx1ZVNhdHMSJAoOc2NyaXB0X3'
    'NpZ19hc20YBiABKAlSDHNjcmlwdFNpZ0FzbRIkCg5zY3JpcHRfc2lnX2hleBgHIAEoCVIMc2Ny'
    'aXB0U2lnSGV4EhgKB3dpdG5lc3MYCCADKAlSB3dpdG5lc3MSGgoIc2VxdWVuY2UYCSABKANSCH'
    'NlcXVlbmNlEh8KC2lzX2NvaW5iYXNlGAogASgIUgppc0NvaW5iYXNl');

@$core.Deprecated('Use transactionOutputDescriptor instead')
const TransactionOutput$json = {
  '1': 'TransactionOutput',
  '2': [
    {'1': 'index', '3': 1, '4': 1, '5': 5, '10': 'index'},
    {'1': 'value_sats', '3': 2, '4': 1, '5': 3, '10': 'valueSats'},
    {'1': 'address', '3': 3, '4': 1, '5': 9, '10': 'address'},
    {'1': 'script_type', '3': 4, '4': 1, '5': 9, '10': 'scriptType'},
    {'1': 'script_pubkey_asm', '3': 5, '4': 1, '5': 9, '10': 'scriptPubkeyAsm'},
    {'1': 'script_pubkey_hex', '3': 6, '4': 1, '5': 9, '10': 'scriptPubkeyHex'},
  ],
};

/// Descriptor for `TransactionOutput`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transactionOutputDescriptor = $convert.base64Decode(
    'ChFUcmFuc2FjdGlvbk91dHB1dBIUCgVpbmRleBgBIAEoBVIFaW5kZXgSHQoKdmFsdWVfc2F0cx'
    'gCIAEoA1IJdmFsdWVTYXRzEhgKB2FkZHJlc3MYAyABKAlSB2FkZHJlc3MSHwoLc2NyaXB0X3R5'
    'cGUYBCABKAlSCnNjcmlwdFR5cGUSKgoRc2NyaXB0X3B1YmtleV9hc20YBSABKAlSD3NjcmlwdF'
    'B1YmtleUFzbRIqChFzY3JpcHRfcHVia2V5X2hleBgGIAEoCVIPc2NyaXB0UHVia2V5SGV4');

@$core.Deprecated('Use getUTXODistributionRequestDescriptor instead')
const GetUTXODistributionRequest$json = {
  '1': 'GetUTXODistributionRequest',
  '2': [
    {'1': 'wallet_id', '3': 1, '4': 1, '5': 9, '10': 'walletId'},
    {'1': 'max_buckets', '3': 2, '4': 1, '5': 5, '10': 'maxBuckets'},
  ],
};

/// Descriptor for `GetUTXODistributionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getUTXODistributionRequestDescriptor = $convert.base64Decode(
    'ChpHZXRVVFhPRGlzdHJpYnV0aW9uUmVxdWVzdBIbCgl3YWxsZXRfaWQYASABKAlSCHdhbGxldE'
    'lkEh8KC21heF9idWNrZXRzGAIgASgFUgptYXhCdWNrZXRz');

@$core.Deprecated('Use getUTXODistributionResponseDescriptor instead')
const GetUTXODistributionResponse$json = {
  '1': 'GetUTXODistributionResponse',
  '2': [
    {'1': 'buckets', '3': 1, '4': 3, '5': 11, '6': '.wallet.v1.UTXOBucket', '10': 'buckets'},
  ],
};

/// Descriptor for `GetUTXODistributionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getUTXODistributionResponseDescriptor = $convert.base64Decode(
    'ChtHZXRVVFhPRGlzdHJpYnV0aW9uUmVzcG9uc2USLwoHYnVja2V0cxgBIAMoCzIVLndhbGxldC'
    '52MS5VVFhPQnVja2V0UgdidWNrZXRz');

@$core.Deprecated('Use uTXOBucketDescriptor instead')
const UTXOBucket$json = {
  '1': 'UTXOBucket',
  '2': [
    {'1': 'label', '3': 1, '4': 1, '5': 9, '10': 'label'},
    {'1': 'value_sats', '3': 2, '4': 1, '5': 3, '10': 'valueSats'},
    {'1': 'count', '3': 3, '4': 1, '5': 5, '10': 'count'},
    {'1': 'outpoints', '3': 4, '4': 3, '5': 9, '10': 'outpoints'},
  ],
};

/// Descriptor for `UTXOBucket`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List uTXOBucketDescriptor = $convert.base64Decode(
    'CgpVVFhPQnVja2V0EhQKBWxhYmVsGAEgASgJUgVsYWJlbBIdCgp2YWx1ZV9zYXRzGAIgASgDUg'
    'l2YWx1ZVNhdHMSFAoFY291bnQYAyABKAVSBWNvdW50EhwKCW91dHBvaW50cxgEIAMoCVIJb3V0'
    'cG9pbnRz');

@$core.Deprecated('Use bumpFeeRequestDescriptor instead')
const BumpFeeRequest$json = {
  '1': 'BumpFeeRequest',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `BumpFeeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List bumpFeeRequestDescriptor = $convert.base64Decode(
    'Cg5CdW1wRmVlUmVxdWVzdBISCgR0eGlkGAEgASgJUgR0eGlk');

@$core.Deprecated('Use bumpFeeResponseDescriptor instead')
const BumpFeeResponse$json = {
  '1': 'BumpFeeResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'original_fee', '3': 2, '4': 1, '5': 1, '10': 'originalFee'},
    {'1': 'new_fee', '3': 3, '4': 1, '5': 1, '10': 'newFee'},
  ],
};

/// Descriptor for `BumpFeeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List bumpFeeResponseDescriptor = $convert.base64Decode(
    'Cg9CdW1wRmVlUmVzcG9uc2USEgoEdHhpZBgBIAEoCVIEdHhpZBIhCgxvcmlnaW5hbF9mZWUYAi'
    'ABKAFSC29yaWdpbmFsRmVlEhcKB25ld19mZWUYAyABKAFSBm5ld0ZlZQ==');

const $core.Map<$core.String, $core.dynamic> WalletServiceBase$json = {
  '1': 'WalletService',
  '2': [
    {'1': 'CreateBitcoinCoreWallet', '2': '.wallet.v1.CreateBitcoinCoreWalletRequest', '3': '.wallet.v1.CreateBitcoinCoreWalletResponse'},
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
    {'1': 'SetUTXOMetadata', '2': '.wallet.v1.SetUTXOMetadataRequest', '3': '.google.protobuf.Empty'},
    {'1': 'GetUTXOMetadata', '2': '.wallet.v1.GetUTXOMetadataRequest', '3': '.wallet.v1.GetUTXOMetadataResponse'},
    {'1': 'SetCoinSelectionStrategy', '2': '.wallet.v1.SetCoinSelectionStrategyRequest', '3': '.google.protobuf.Empty'},
    {'1': 'GetCoinSelectionStrategy', '2': '.google.protobuf.Empty', '3': '.wallet.v1.GetCoinSelectionStrategyResponse'},
    {'1': 'GetTransactionDetails', '2': '.wallet.v1.GetTransactionDetailsRequest', '3': '.wallet.v1.GetTransactionDetailsResponse'},
    {'1': 'GetUTXODistribution', '2': '.wallet.v1.GetUTXODistributionRequest', '3': '.wallet.v1.GetUTXODistributionResponse'},
    {'1': 'BumpFee', '2': '.wallet.v1.BumpFeeRequest', '3': '.wallet.v1.BumpFeeResponse'},
  ],
};

@$core.Deprecated('Use walletServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> WalletServiceBase$messageJson = {
  '.wallet.v1.CreateBitcoinCoreWalletRequest': CreateBitcoinCoreWalletRequest$json,
  '.wallet.v1.CreateBitcoinCoreWalletResponse': CreateBitcoinCoreWalletResponse$json,
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
  '.wallet.v1.SetUTXOMetadataRequest': SetUTXOMetadataRequest$json,
  '.wallet.v1.GetUTXOMetadataRequest': GetUTXOMetadataRequest$json,
  '.wallet.v1.GetUTXOMetadataResponse': GetUTXOMetadataResponse$json,
  '.wallet.v1.GetUTXOMetadataResponse.MetadataEntry': GetUTXOMetadataResponse_MetadataEntry$json,
  '.wallet.v1.UTXOMetadata': UTXOMetadata$json,
  '.wallet.v1.SetCoinSelectionStrategyRequest': SetCoinSelectionStrategyRequest$json,
  '.wallet.v1.GetCoinSelectionStrategyResponse': GetCoinSelectionStrategyResponse$json,
  '.wallet.v1.GetTransactionDetailsRequest': GetTransactionDetailsRequest$json,
  '.wallet.v1.GetTransactionDetailsResponse': GetTransactionDetailsResponse$json,
  '.wallet.v1.TransactionInput': TransactionInput$json,
  '.wallet.v1.TransactionOutput': TransactionOutput$json,
  '.wallet.v1.GetUTXODistributionRequest': GetUTXODistributionRequest$json,
  '.wallet.v1.GetUTXODistributionResponse': GetUTXODistributionResponse$json,
  '.wallet.v1.UTXOBucket': UTXOBucket$json,
  '.wallet.v1.BumpFeeRequest': BumpFeeRequest$json,
  '.wallet.v1.BumpFeeResponse': BumpFeeResponse$json,
};

/// Descriptor for `WalletService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List walletServiceDescriptor = $convert.base64Decode(
    'Cg1XYWxsZXRTZXJ2aWNlEnAKF0NyZWF0ZUJpdGNvaW5Db3JlV2FsbGV0Eikud2FsbGV0LnYxLk'
    'NyZWF0ZUJpdGNvaW5Db3JlV2FsbGV0UmVxdWVzdBoqLndhbGxldC52MS5DcmVhdGVCaXRjb2lu'
    'Q29yZVdhbGxldFJlc3BvbnNlElgKD1NlbmRUcmFuc2FjdGlvbhIhLndhbGxldC52MS5TZW5kVH'
    'JhbnNhY3Rpb25SZXF1ZXN0GiIud2FsbGV0LnYxLlNlbmRUcmFuc2FjdGlvblJlc3BvbnNlEkkK'
    'CkdldEJhbGFuY2USHC53YWxsZXQudjEuR2V0QmFsYW5jZVJlcXVlc3QaHS53YWxsZXQudjEuR2'
    'V0QmFsYW5jZVJlc3BvbnNlElIKDUdldE5ld0FkZHJlc3MSHy53YWxsZXQudjEuR2V0TmV3QWRk'
    'cmVzc1JlcXVlc3QaIC53YWxsZXQudjEuR2V0TmV3QWRkcmVzc1Jlc3BvbnNlElsKEExpc3RUcm'
    'Fuc2FjdGlvbnMSIi53YWxsZXQudjEuTGlzdFRyYW5zYWN0aW9uc1JlcXVlc3QaIy53YWxsZXQu'
    'djEuTGlzdFRyYW5zYWN0aW9uc1Jlc3BvbnNlEkwKC0xpc3RVbnNwZW50Eh0ud2FsbGV0LnYxLk'
    'xpc3RVbnNwZW50UmVxdWVzdBoeLndhbGxldC52MS5MaXN0VW5zcGVudFJlc3BvbnNlEmcKFExp'
    'c3RSZWNlaXZlQWRkcmVzc2VzEiYud2FsbGV0LnYxLkxpc3RSZWNlaXZlQWRkcmVzc2VzUmVxdW'
    'VzdBonLndhbGxldC52MS5MaXN0UmVjZWl2ZUFkZHJlc3Nlc1Jlc3BvbnNlEmoKFUxpc3RTaWRl'
    'Y2hhaW5EZXBvc2l0cxInLndhbGxldC52MS5MaXN0U2lkZWNoYWluRGVwb3NpdHNSZXF1ZXN0Gi'
    'gud2FsbGV0LnYxLkxpc3RTaWRlY2hhaW5EZXBvc2l0c1Jlc3BvbnNlEm0KFkNyZWF0ZVNpZGVj'
    'aGFpbkRlcG9zaXQSKC53YWxsZXQudjEuQ3JlYXRlU2lkZWNoYWluRGVwb3NpdFJlcXVlc3QaKS'
    '53YWxsZXQudjEuQ3JlYXRlU2lkZWNoYWluRGVwb3NpdFJlc3BvbnNlEkwKC1NpZ25NZXNzYWdl'
    'Eh0ud2FsbGV0LnYxLlNpZ25NZXNzYWdlUmVxdWVzdBoeLndhbGxldC52MS5TaWduTWVzc2FnZV'
    'Jlc3BvbnNlElIKDVZlcmlmeU1lc3NhZ2USHy53YWxsZXQudjEuVmVyaWZ5TWVzc2FnZVJlcXVl'
    'c3QaIC53YWxsZXQudjEuVmVyaWZ5TWVzc2FnZVJlc3BvbnNlEkMKCEdldFN0YXRzEhoud2FsbG'
    'V0LnYxLkdldFN0YXRzUmVxdWVzdBobLndhbGxldC52MS5HZXRTdGF0c1Jlc3BvbnNlEkYKDFVu'
    'bG9ja1dhbGxldBIeLndhbGxldC52MS5VbmxvY2tXYWxsZXRSZXF1ZXN0GhYuZ29vZ2xlLnByb3'
    'RvYnVmLkVtcHR5EjwKCkxvY2tXYWxsZXQSFi5nb29nbGUucHJvdG9idWYuRW1wdHkaFi5nb29n'
    'bGUucHJvdG9idWYuRW1wdHkSQgoQSXNXYWxsZXRVbmxvY2tlZBIWLmdvb2dsZS5wcm90b2J1Zi'
    '5FbXB0eRoWLmdvb2dsZS5wcm90b2J1Zi5FbXB0eRJPCgxDcmVhdGVDaGVxdWUSHi53YWxsZXQu'
    'djEuQ3JlYXRlQ2hlcXVlUmVxdWVzdBofLndhbGxldC52MS5DcmVhdGVDaGVxdWVSZXNwb25zZR'
    'JGCglHZXRDaGVxdWUSGy53YWxsZXQudjEuR2V0Q2hlcXVlUmVxdWVzdBocLndhbGxldC52MS5H'
    'ZXRDaGVxdWVSZXNwb25zZRJkChNHZXRDaGVxdWVQcml2YXRlS2V5EiUud2FsbGV0LnYxLkdldE'
    'NoZXF1ZVByaXZhdGVLZXlSZXF1ZXN0GiYud2FsbGV0LnYxLkdldENoZXF1ZVByaXZhdGVLZXlS'
    'ZXNwb25zZRJMCgtMaXN0Q2hlcXVlcxIdLndhbGxldC52MS5MaXN0Q2hlcXVlc1JlcXVlc3QaHi'
    '53YWxsZXQudjEuTGlzdENoZXF1ZXNSZXNwb25zZRJhChJDaGVja0NoZXF1ZUZ1bmRpbmcSJC53'
    'YWxsZXQudjEuQ2hlY2tDaGVxdWVGdW5kaW5nUmVxdWVzdBolLndhbGxldC52MS5DaGVja0NoZX'
    'F1ZUZ1bmRpbmdSZXNwb25zZRJMCgtTd2VlcENoZXF1ZRIdLndhbGxldC52MS5Td2VlcENoZXF1'
    'ZVJlcXVlc3QaHi53YWxsZXQudjEuU3dlZXBDaGVxdWVSZXNwb25zZRJGCgxEZWxldGVDaGVxdW'
    'USHi53YWxsZXQudjEuRGVsZXRlQ2hlcXVlUmVxdWVzdBoWLmdvb2dsZS5wcm90b2J1Zi5FbXB0'
    'eRJMCg9TZXRVVFhPTWV0YWRhdGESIS53YWxsZXQudjEuU2V0VVRYT01ldGFkYXRhUmVxdWVzdB'
    'oWLmdvb2dsZS5wcm90b2J1Zi5FbXB0eRJYCg9HZXRVVFhPTWV0YWRhdGESIS53YWxsZXQudjEu'
    'R2V0VVRYT01ldGFkYXRhUmVxdWVzdBoiLndhbGxldC52MS5HZXRVVFhPTWV0YWRhdGFSZXNwb2'
    '5zZRJeChhTZXRDb2luU2VsZWN0aW9uU3RyYXRlZ3kSKi53YWxsZXQudjEuU2V0Q29pblNlbGVj'
    'dGlvblN0cmF0ZWd5UmVxdWVzdBoWLmdvb2dsZS5wcm90b2J1Zi5FbXB0eRJfChhHZXRDb2luU2'
    'VsZWN0aW9uU3RyYXRlZ3kSFi5nb29nbGUucHJvdG9idWYuRW1wdHkaKy53YWxsZXQudjEuR2V0'
    'Q29pblNlbGVjdGlvblN0cmF0ZWd5UmVzcG9uc2USagoVR2V0VHJhbnNhY3Rpb25EZXRhaWxzEi'
    'cud2FsbGV0LnYxLkdldFRyYW5zYWN0aW9uRGV0YWlsc1JlcXVlc3QaKC53YWxsZXQudjEuR2V0'
    'VHJhbnNhY3Rpb25EZXRhaWxzUmVzcG9uc2USZAoTR2V0VVRYT0Rpc3RyaWJ1dGlvbhIlLndhbG'
    'xldC52MS5HZXRVVFhPRGlzdHJpYnV0aW9uUmVxdWVzdBomLndhbGxldC52MS5HZXRVVFhPRGlz'
    'dHJpYnV0aW9uUmVzcG9uc2USQAoHQnVtcEZlZRIZLndhbGxldC52MS5CdW1wRmVlUmVxdWVzdB'
    'oaLndhbGxldC52MS5CdW1wRmVlUmVzcG9uc2U=');

