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

import '../../bitwindowd/v1/bitwindowd.pbjson.dart' as $3;
import '../../google/protobuf/empty.pbjson.dart' as $1;
import '../../google/protobuf/timestamp.pbjson.dart' as $0;

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
    {'1': 'fee_sat_per_vbyte', '3': 2, '4': 1, '5': 4, '10': 'feeSatPerVbyte'},
    {'1': 'fixed_fee_sats', '3': 3, '4': 1, '5': 4, '10': 'fixedFeeSats'},
    {'1': 'op_return_message', '3': 4, '4': 1, '5': 9, '10': 'opReturnMessage'},
    {'1': 'label', '3': 5, '4': 1, '5': 9, '10': 'label'},
    {'1': 'required_inputs', '3': 6, '4': 3, '5': 11, '6': '.wallet.v1.UnspentOutput', '10': 'requiredInputs'},
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
    'ChZTZW5kVHJhbnNhY3Rpb25SZXF1ZXN0ElcKDGRlc3RpbmF0aW9ucxgBIAMoCzIzLndhbGxldC'
    '52MS5TZW5kVHJhbnNhY3Rpb25SZXF1ZXN0LkRlc3RpbmF0aW9uc0VudHJ5UgxkZXN0aW5hdGlv'
    'bnMSKQoRZmVlX3NhdF9wZXJfdmJ5dGUYAiABKARSDmZlZVNhdFBlclZieXRlEiQKDmZpeGVkX2'
    'ZlZV9zYXRzGAMgASgEUgxmaXhlZEZlZVNhdHMSKgoRb3BfcmV0dXJuX21lc3NhZ2UYBCABKAlS'
    'D29wUmV0dXJuTWVzc2FnZRIUCgVsYWJlbBgFIAEoCVIFbGFiZWwSQQoPcmVxdWlyZWRfaW5wdX'
    'RzGAYgAygLMhgud2FsbGV0LnYxLlVuc3BlbnRPdXRwdXRSDnJlcXVpcmVkSW5wdXRzGj8KEURl'
    'c3RpbmF0aW9uc0VudHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGAIgASgEUgV2YWx1ZT'
    'oCOAE=');

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
    {'1': 'slot', '3': 1, '4': 1, '5': 3, '10': 'slot'},
    {'1': 'destination', '3': 2, '4': 1, '5': 9, '10': 'destination'},
    {'1': 'amount', '3': 3, '4': 1, '5': 1, '10': 'amount'},
    {'1': 'fee', '3': 4, '4': 1, '5': 1, '10': 'fee'},
  ],
};

/// Descriptor for `CreateSidechainDepositRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createSidechainDepositRequestDescriptor = $convert.base64Decode(
    'Ch1DcmVhdGVTaWRlY2hhaW5EZXBvc2l0UmVxdWVzdBISCgRzbG90GAEgASgDUgRzbG90EiAKC2'
    'Rlc3RpbmF0aW9uGAIgASgJUgtkZXN0aW5hdGlvbhIWCgZhbW91bnQYAyABKAFSBmFtb3VudBIQ'
    'CgNmZWUYBCABKAFSA2ZlZQ==');

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
    {'1': 'message', '3': 1, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `SignMessageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List signMessageRequestDescriptor = $convert.base64Decode(
    'ChJTaWduTWVzc2FnZVJlcXVlc3QSGAoHbWVzc2FnZRgBIAEoCVIHbWVzc2FnZQ==');

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
    {'1': 'message', '3': 1, '4': 1, '5': 9, '10': 'message'},
    {'1': 'signature', '3': 2, '4': 1, '5': 9, '10': 'signature'},
    {'1': 'public_key', '3': 3, '4': 1, '5': 9, '10': 'publicKey'},
  ],
};

/// Descriptor for `VerifyMessageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List verifyMessageRequestDescriptor = $convert.base64Decode(
    'ChRWZXJpZnlNZXNzYWdlUmVxdWVzdBIYCgdtZXNzYWdlGAEgASgJUgdtZXNzYWdlEhwKCXNpZ2'
    '5hdHVyZRgCIAEoCVIJc2lnbmF0dXJlEh0KCnB1YmxpY19rZXkYAyABKAlSCXB1YmxpY0tleQ==');

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

const $core.Map<$core.String, $core.dynamic> WalletServiceBase$json = {
  '1': 'WalletService',
  '2': [
    {'1': 'SendTransaction', '2': '.wallet.v1.SendTransactionRequest', '3': '.wallet.v1.SendTransactionResponse'},
    {'1': 'GetBalance', '2': '.google.protobuf.Empty', '3': '.wallet.v1.GetBalanceResponse'},
    {'1': 'GetNewAddress', '2': '.google.protobuf.Empty', '3': '.wallet.v1.GetNewAddressResponse'},
    {'1': 'ListTransactions', '2': '.google.protobuf.Empty', '3': '.wallet.v1.ListTransactionsResponse'},
    {'1': 'ListUnspent', '2': '.google.protobuf.Empty', '3': '.wallet.v1.ListUnspentResponse'},
    {'1': 'ListReceiveAddresses', '2': '.google.protobuf.Empty', '3': '.wallet.v1.ListReceiveAddressesResponse'},
    {'1': 'ListSidechainDeposits', '2': '.wallet.v1.ListSidechainDepositsRequest', '3': '.wallet.v1.ListSidechainDepositsResponse'},
    {'1': 'CreateSidechainDeposit', '2': '.wallet.v1.CreateSidechainDepositRequest', '3': '.wallet.v1.CreateSidechainDepositResponse'},
    {'1': 'SignMessage', '2': '.wallet.v1.SignMessageRequest', '3': '.wallet.v1.SignMessageResponse'},
    {'1': 'VerifyMessage', '2': '.wallet.v1.VerifyMessageRequest', '3': '.wallet.v1.VerifyMessageResponse'},
    {'1': 'GetStats', '2': '.google.protobuf.Empty', '3': '.wallet.v1.GetStatsResponse'},
  ],
};

@$core.Deprecated('Use walletServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> WalletServiceBase$messageJson = {
  '.wallet.v1.SendTransactionRequest': SendTransactionRequest$json,
  '.wallet.v1.SendTransactionRequest.DestinationsEntry': SendTransactionRequest_DestinationsEntry$json,
  '.wallet.v1.UnspentOutput': UnspentOutput$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.bitwindowd.v1.DenialInfo': $3.DenialInfo$json,
  '.bitwindowd.v1.ExecutedDenial': $3.ExecutedDenial$json,
  '.wallet.v1.SendTransactionResponse': SendTransactionResponse$json,
  '.google.protobuf.Empty': $1.Empty$json,
  '.wallet.v1.GetBalanceResponse': GetBalanceResponse$json,
  '.wallet.v1.GetNewAddressResponse': GetNewAddressResponse$json,
  '.wallet.v1.ListTransactionsResponse': ListTransactionsResponse$json,
  '.wallet.v1.WalletTransaction': WalletTransaction$json,
  '.wallet.v1.Confirmation': Confirmation$json,
  '.wallet.v1.ListUnspentResponse': ListUnspentResponse$json,
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
  '.wallet.v1.GetStatsResponse': GetStatsResponse$json,
};

/// Descriptor for `WalletService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List walletServiceDescriptor = $convert.base64Decode(
    'Cg1XYWxsZXRTZXJ2aWNlElgKD1NlbmRUcmFuc2FjdGlvbhIhLndhbGxldC52MS5TZW5kVHJhbn'
    'NhY3Rpb25SZXF1ZXN0GiIud2FsbGV0LnYxLlNlbmRUcmFuc2FjdGlvblJlc3BvbnNlEkMKCkdl'
    'dEJhbGFuY2USFi5nb29nbGUucHJvdG9idWYuRW1wdHkaHS53YWxsZXQudjEuR2V0QmFsYW5jZV'
    'Jlc3BvbnNlEkkKDUdldE5ld0FkZHJlc3MSFi5nb29nbGUucHJvdG9idWYuRW1wdHkaIC53YWxs'
    'ZXQudjEuR2V0TmV3QWRkcmVzc1Jlc3BvbnNlEk8KEExpc3RUcmFuc2FjdGlvbnMSFi5nb29nbG'
    'UucHJvdG9idWYuRW1wdHkaIy53YWxsZXQudjEuTGlzdFRyYW5zYWN0aW9uc1Jlc3BvbnNlEkUK'
    'C0xpc3RVbnNwZW50EhYuZ29vZ2xlLnByb3RvYnVmLkVtcHR5Gh4ud2FsbGV0LnYxLkxpc3RVbn'
    'NwZW50UmVzcG9uc2USVwoUTGlzdFJlY2VpdmVBZGRyZXNzZXMSFi5nb29nbGUucHJvdG9idWYu'
    'RW1wdHkaJy53YWxsZXQudjEuTGlzdFJlY2VpdmVBZGRyZXNzZXNSZXNwb25zZRJqChVMaXN0U2'
    'lkZWNoYWluRGVwb3NpdHMSJy53YWxsZXQudjEuTGlzdFNpZGVjaGFpbkRlcG9zaXRzUmVxdWVz'
    'dBooLndhbGxldC52MS5MaXN0U2lkZWNoYWluRGVwb3NpdHNSZXNwb25zZRJtChZDcmVhdGVTaW'
    'RlY2hhaW5EZXBvc2l0Eigud2FsbGV0LnYxLkNyZWF0ZVNpZGVjaGFpbkRlcG9zaXRSZXF1ZXN0'
    'Gikud2FsbGV0LnYxLkNyZWF0ZVNpZGVjaGFpbkRlcG9zaXRSZXNwb25zZRJMCgtTaWduTWVzc2'
    'FnZRIdLndhbGxldC52MS5TaWduTWVzc2FnZVJlcXVlc3QaHi53YWxsZXQudjEuU2lnbk1lc3Nh'
    'Z2VSZXNwb25zZRJSCg1WZXJpZnlNZXNzYWdlEh8ud2FsbGV0LnYxLlZlcmlmeU1lc3NhZ2VSZX'
    'F1ZXN0GiAud2FsbGV0LnYxLlZlcmlmeU1lc3NhZ2VSZXNwb25zZRI/CghHZXRTdGF0cxIWLmdv'
    'b2dsZS5wcm90b2J1Zi5FbXB0eRobLndhbGxldC52MS5HZXRTdGF0c1Jlc3BvbnNl');

