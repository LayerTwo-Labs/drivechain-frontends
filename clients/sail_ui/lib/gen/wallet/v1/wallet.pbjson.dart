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
    {'1': 'destination', '3': 1, '4': 1, '5': 9, '10': 'destination'},
    {'1': 'amount', '3': 2, '4': 1, '5': 4, '10': 'amount'},
    {'1': 'fee_rate', '3': 3, '4': 1, '5': 1, '10': 'feeRate'},
    {'1': 'op_return_message', '3': 4, '4': 1, '5': 9, '10': 'opReturnMessage'},
    {'1': 'label', '3': 5, '4': 1, '5': 9, '10': 'label'},
  ],
};

/// Descriptor for `SendTransactionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendTransactionRequestDescriptor = $convert.base64Decode(
    'ChZTZW5kVHJhbnNhY3Rpb25SZXF1ZXN0EiAKC2Rlc3RpbmF0aW9uGAEgASgJUgtkZXN0aW5hdG'
    'lvbhIWCgZhbW91bnQYAiABKARSBmFtb3VudBIZCghmZWVfcmF0ZRgDIAEoAVIHZmVlUmF0ZRIq'
    'ChFvcF9yZXR1cm5fbWVzc2FnZRgEIAEoCVIPb3BSZXR1cm5NZXNzYWdlEhQKBWxhYmVsGAUgAS'
    'gJUgVsYWJlbA==');

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

const $core.Map<$core.String, $core.dynamic> WalletServiceBase$json = {
  '1': 'WalletService',
  '2': [
    {'1': 'SendTransaction', '2': '.wallet.v1.SendTransactionRequest', '3': '.wallet.v1.SendTransactionResponse'},
    {'1': 'GetBalance', '2': '.google.protobuf.Empty', '3': '.wallet.v1.GetBalanceResponse'},
    {'1': 'GetNewAddress', '2': '.google.protobuf.Empty', '3': '.wallet.v1.GetNewAddressResponse'},
    {'1': 'ListTransactions', '2': '.google.protobuf.Empty', '3': '.wallet.v1.ListTransactionsResponse'},
    {'1': 'ListSidechainDeposits', '2': '.wallet.v1.ListSidechainDepositsRequest', '3': '.wallet.v1.ListSidechainDepositsResponse'},
    {'1': 'CreateSidechainDeposit', '2': '.wallet.v1.CreateSidechainDepositRequest', '3': '.wallet.v1.CreateSidechainDepositResponse'},
    {'1': 'SignMessage', '2': '.wallet.v1.SignMessageRequest', '3': '.wallet.v1.SignMessageResponse'},
    {'1': 'VerifyMessage', '2': '.wallet.v1.VerifyMessageRequest', '3': '.wallet.v1.VerifyMessageResponse'},
  ],
};

@$core.Deprecated('Use walletServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> WalletServiceBase$messageJson = {
  '.wallet.v1.SendTransactionRequest': SendTransactionRequest$json,
  '.wallet.v1.SendTransactionResponse': SendTransactionResponse$json,
  '.google.protobuf.Empty': $1.Empty$json,
  '.wallet.v1.GetBalanceResponse': GetBalanceResponse$json,
  '.wallet.v1.GetNewAddressResponse': GetNewAddressResponse$json,
  '.wallet.v1.ListTransactionsResponse': ListTransactionsResponse$json,
  '.wallet.v1.WalletTransaction': WalletTransaction$json,
  '.wallet.v1.Confirmation': Confirmation$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.wallet.v1.ListSidechainDepositsRequest': ListSidechainDepositsRequest$json,
  '.wallet.v1.ListSidechainDepositsResponse': ListSidechainDepositsResponse$json,
  '.wallet.v1.ListSidechainDepositsResponse.SidechainDeposit': ListSidechainDepositsResponse_SidechainDeposit$json,
  '.wallet.v1.CreateSidechainDepositRequest': CreateSidechainDepositRequest$json,
  '.wallet.v1.CreateSidechainDepositResponse': CreateSidechainDepositResponse$json,
  '.wallet.v1.SignMessageRequest': SignMessageRequest$json,
  '.wallet.v1.SignMessageResponse': SignMessageResponse$json,
  '.wallet.v1.VerifyMessageRequest': VerifyMessageRequest$json,
  '.wallet.v1.VerifyMessageResponse': VerifyMessageResponse$json,
};

/// Descriptor for `WalletService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List walletServiceDescriptor = $convert.base64Decode(
    'Cg1XYWxsZXRTZXJ2aWNlElgKD1NlbmRUcmFuc2FjdGlvbhIhLndhbGxldC52MS5TZW5kVHJhbn'
    'NhY3Rpb25SZXF1ZXN0GiIud2FsbGV0LnYxLlNlbmRUcmFuc2FjdGlvblJlc3BvbnNlEkMKCkdl'
    'dEJhbGFuY2USFi5nb29nbGUucHJvdG9idWYuRW1wdHkaHS53YWxsZXQudjEuR2V0QmFsYW5jZV'
    'Jlc3BvbnNlEkkKDUdldE5ld0FkZHJlc3MSFi5nb29nbGUucHJvdG9idWYuRW1wdHkaIC53YWxs'
    'ZXQudjEuR2V0TmV3QWRkcmVzc1Jlc3BvbnNlEk8KEExpc3RUcmFuc2FjdGlvbnMSFi5nb29nbG'
    'UucHJvdG9idWYuRW1wdHkaIy53YWxsZXQudjEuTGlzdFRyYW5zYWN0aW9uc1Jlc3BvbnNlEmoK'
    'FUxpc3RTaWRlY2hhaW5EZXBvc2l0cxInLndhbGxldC52MS5MaXN0U2lkZWNoYWluRGVwb3NpdH'
    'NSZXF1ZXN0Gigud2FsbGV0LnYxLkxpc3RTaWRlY2hhaW5EZXBvc2l0c1Jlc3BvbnNlEm0KFkNy'
    'ZWF0ZVNpZGVjaGFpbkRlcG9zaXQSKC53YWxsZXQudjEuQ3JlYXRlU2lkZWNoYWluRGVwb3NpdF'
    'JlcXVlc3QaKS53YWxsZXQudjEuQ3JlYXRlU2lkZWNoYWluRGVwb3NpdFJlc3BvbnNlEkwKC1Np'
    'Z25NZXNzYWdlEh0ud2FsbGV0LnYxLlNpZ25NZXNzYWdlUmVxdWVzdBoeLndhbGxldC52MS5TaW'
    'duTWVzc2FnZVJlc3BvbnNlElIKDVZlcmlmeU1lc3NhZ2USHy53YWxsZXQudjEuVmVyaWZ5TWVz'
    'c2FnZVJlcXVlc3QaIC53YWxsZXQudjEuVmVyaWZ5TWVzc2FnZVJlc3BvbnNl');

