//
//  Generated code. Do not modify.
//  source: zside/v1/zside.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use getBalanceRequestDescriptor instead')
const GetBalanceRequest$json = {
  '1': 'GetBalanceRequest',
};

/// Descriptor for `GetBalanceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBalanceRequestDescriptor = $convert.base64Decode(
    'ChFHZXRCYWxhbmNlUmVxdWVzdA==');

@$core.Deprecated('Use getBalanceResponseDescriptor instead')
const GetBalanceResponse$json = {
  '1': 'GetBalanceResponse',
  '2': [
    {'1': 'total_sats', '3': 1, '4': 1, '5': 3, '10': 'totalSats'},
    {'1': 'available_sats', '3': 2, '4': 1, '5': 3, '10': 'availableSats'},
  ],
};

/// Descriptor for `GetBalanceResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBalanceResponseDescriptor = $convert.base64Decode(
    'ChJHZXRCYWxhbmNlUmVzcG9uc2USHQoKdG90YWxfc2F0cxgBIAEoA1IJdG90YWxTYXRzEiUKDm'
    'F2YWlsYWJsZV9zYXRzGAIgASgDUg1hdmFpbGFibGVTYXRz');

@$core.Deprecated('Use getBalanceBreakdownRequestDescriptor instead')
const GetBalanceBreakdownRequest$json = {
  '1': 'GetBalanceBreakdownRequest',
};

/// Descriptor for `GetBalanceBreakdownRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBalanceBreakdownRequestDescriptor = $convert.base64Decode(
    'ChpHZXRCYWxhbmNlQnJlYWtkb3duUmVxdWVzdA==');

@$core.Deprecated('Use getBalanceBreakdownResponseDescriptor instead')
const GetBalanceBreakdownResponse$json = {
  '1': 'GetBalanceBreakdownResponse',
  '2': [
    {'1': 'available_shielded_sats', '3': 1, '4': 1, '5': 3, '10': 'availableShieldedSats'},
    {'1': 'available_transparent_sats', '3': 2, '4': 1, '5': 3, '10': 'availableTransparentSats'},
    {'1': 'total_shielded_sats', '3': 3, '4': 1, '5': 3, '10': 'totalShieldedSats'},
    {'1': 'total_transparent_sats', '3': 4, '4': 1, '5': 3, '10': 'totalTransparentSats'},
  ],
};

/// Descriptor for `GetBalanceBreakdownResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBalanceBreakdownResponseDescriptor = $convert.base64Decode(
    'ChtHZXRCYWxhbmNlQnJlYWtkb3duUmVzcG9uc2USNgoXYXZhaWxhYmxlX3NoaWVsZGVkX3NhdH'
    'MYASABKANSFWF2YWlsYWJsZVNoaWVsZGVkU2F0cxI8ChphdmFpbGFibGVfdHJhbnNwYXJlbnRf'
    'c2F0cxgCIAEoA1IYYXZhaWxhYmxlVHJhbnNwYXJlbnRTYXRzEi4KE3RvdGFsX3NoaWVsZGVkX3'
    'NhdHMYAyABKANSEXRvdGFsU2hpZWxkZWRTYXRzEjQKFnRvdGFsX3RyYW5zcGFyZW50X3NhdHMY'
    'BCABKANSFHRvdGFsVHJhbnNwYXJlbnRTYXRz');

@$core.Deprecated('Use getBlockCountRequestDescriptor instead')
const GetBlockCountRequest$json = {
  '1': 'GetBlockCountRequest',
};

/// Descriptor for `GetBlockCountRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBlockCountRequestDescriptor = $convert.base64Decode(
    'ChRHZXRCbG9ja0NvdW50UmVxdWVzdA==');

@$core.Deprecated('Use getBlockCountResponseDescriptor instead')
const GetBlockCountResponse$json = {
  '1': 'GetBlockCountResponse',
  '2': [
    {'1': 'count', '3': 1, '4': 1, '5': 3, '10': 'count'},
  ],
};

/// Descriptor for `GetBlockCountResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBlockCountResponseDescriptor = $convert.base64Decode(
    'ChVHZXRCbG9ja0NvdW50UmVzcG9uc2USFAoFY291bnQYASABKANSBWNvdW50');

@$core.Deprecated('Use stopRequestDescriptor instead')
const StopRequest$json = {
  '1': 'StopRequest',
};

/// Descriptor for `StopRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List stopRequestDescriptor = $convert.base64Decode(
    'CgtTdG9wUmVxdWVzdA==');

@$core.Deprecated('Use stopResponseDescriptor instead')
const StopResponse$json = {
  '1': 'StopResponse',
};

/// Descriptor for `StopResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List stopResponseDescriptor = $convert.base64Decode(
    'CgxTdG9wUmVzcG9uc2U=');

@$core.Deprecated('Use getNewTransparentAddressRequestDescriptor instead')
const GetNewTransparentAddressRequest$json = {
  '1': 'GetNewTransparentAddressRequest',
};

/// Descriptor for `GetNewTransparentAddressRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNewTransparentAddressRequestDescriptor = $convert.base64Decode(
    'Ch9HZXROZXdUcmFuc3BhcmVudEFkZHJlc3NSZXF1ZXN0');

@$core.Deprecated('Use getNewTransparentAddressResponseDescriptor instead')
const GetNewTransparentAddressResponse$json = {
  '1': 'GetNewTransparentAddressResponse',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
  ],
};

/// Descriptor for `GetNewTransparentAddressResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNewTransparentAddressResponseDescriptor = $convert.base64Decode(
    'CiBHZXROZXdUcmFuc3BhcmVudEFkZHJlc3NSZXNwb25zZRIYCgdhZGRyZXNzGAEgASgJUgdhZG'
    'RyZXNz');

@$core.Deprecated('Use getNewShieldedAddressRequestDescriptor instead')
const GetNewShieldedAddressRequest$json = {
  '1': 'GetNewShieldedAddressRequest',
};

/// Descriptor for `GetNewShieldedAddressRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNewShieldedAddressRequestDescriptor = $convert.base64Decode(
    'ChxHZXROZXdTaGllbGRlZEFkZHJlc3NSZXF1ZXN0');

@$core.Deprecated('Use getNewShieldedAddressResponseDescriptor instead')
const GetNewShieldedAddressResponse$json = {
  '1': 'GetNewShieldedAddressResponse',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
  ],
};

/// Descriptor for `GetNewShieldedAddressResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNewShieldedAddressResponseDescriptor = $convert.base64Decode(
    'Ch1HZXROZXdTaGllbGRlZEFkZHJlc3NSZXNwb25zZRIYCgdhZGRyZXNzGAEgASgJUgdhZGRyZX'
    'Nz');

@$core.Deprecated('Use getShieldedWalletAddressesRequestDescriptor instead')
const GetShieldedWalletAddressesRequest$json = {
  '1': 'GetShieldedWalletAddressesRequest',
};

/// Descriptor for `GetShieldedWalletAddressesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getShieldedWalletAddressesRequestDescriptor = $convert.base64Decode(
    'CiFHZXRTaGllbGRlZFdhbGxldEFkZHJlc3Nlc1JlcXVlc3Q=');

@$core.Deprecated('Use getShieldedWalletAddressesResponseDescriptor instead')
const GetShieldedWalletAddressesResponse$json = {
  '1': 'GetShieldedWalletAddressesResponse',
  '2': [
    {'1': 'addresses', '3': 1, '4': 3, '5': 9, '10': 'addresses'},
  ],
};

/// Descriptor for `GetShieldedWalletAddressesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getShieldedWalletAddressesResponseDescriptor = $convert.base64Decode(
    'CiJHZXRTaGllbGRlZFdhbGxldEFkZHJlc3Nlc1Jlc3BvbnNlEhwKCWFkZHJlc3NlcxgBIAMoCV'
    'IJYWRkcmVzc2Vz');

@$core.Deprecated('Use getTransparentWalletAddressesRequestDescriptor instead')
const GetTransparentWalletAddressesRequest$json = {
  '1': 'GetTransparentWalletAddressesRequest',
};

/// Descriptor for `GetTransparentWalletAddressesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTransparentWalletAddressesRequestDescriptor = $convert.base64Decode(
    'CiRHZXRUcmFuc3BhcmVudFdhbGxldEFkZHJlc3Nlc1JlcXVlc3Q=');

@$core.Deprecated('Use getTransparentWalletAddressesResponseDescriptor instead')
const GetTransparentWalletAddressesResponse$json = {
  '1': 'GetTransparentWalletAddressesResponse',
  '2': [
    {'1': 'addresses', '3': 1, '4': 3, '5': 9, '10': 'addresses'},
  ],
};

/// Descriptor for `GetTransparentWalletAddressesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTransparentWalletAddressesResponseDescriptor = $convert.base64Decode(
    'CiVHZXRUcmFuc3BhcmVudFdhbGxldEFkZHJlc3Nlc1Jlc3BvbnNlEhwKCWFkZHJlc3NlcxgBIA'
    'MoCVIJYWRkcmVzc2Vz');

@$core.Deprecated('Use withdrawRequestDescriptor instead')
const WithdrawRequest$json = {
  '1': 'WithdrawRequest',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'amount_sats', '3': 2, '4': 1, '5': 3, '10': 'amountSats'},
    {'1': 'side_fee_sats', '3': 3, '4': 1, '5': 3, '10': 'sideFeeSats'},
    {'1': 'main_fee_sats', '3': 4, '4': 1, '5': 3, '10': 'mainFeeSats'},
  ],
};

/// Descriptor for `WithdrawRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List withdrawRequestDescriptor = $convert.base64Decode(
    'Cg9XaXRoZHJhd1JlcXVlc3QSGAoHYWRkcmVzcxgBIAEoCVIHYWRkcmVzcxIfCgthbW91bnRfc2'
    'F0cxgCIAEoA1IKYW1vdW50U2F0cxIiCg1zaWRlX2ZlZV9zYXRzGAMgASgDUgtzaWRlRmVlU2F0'
    'cxIiCg1tYWluX2ZlZV9zYXRzGAQgASgDUgttYWluRmVlU2F0cw==');

@$core.Deprecated('Use withdrawResponseDescriptor instead')
const WithdrawResponse$json = {
  '1': 'WithdrawResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `WithdrawResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List withdrawResponseDescriptor = $convert.base64Decode(
    'ChBXaXRoZHJhd1Jlc3BvbnNlEhIKBHR4aWQYASABKAlSBHR4aWQ=');

@$core.Deprecated('Use transparentTransferRequestDescriptor instead')
const TransparentTransferRequest$json = {
  '1': 'TransparentTransferRequest',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'amount_sats', '3': 2, '4': 1, '5': 3, '10': 'amountSats'},
    {'1': 'fee_sats', '3': 3, '4': 1, '5': 3, '10': 'feeSats'},
  ],
};

/// Descriptor for `TransparentTransferRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transparentTransferRequestDescriptor = $convert.base64Decode(
    'ChpUcmFuc3BhcmVudFRyYW5zZmVyUmVxdWVzdBIYCgdhZGRyZXNzGAEgASgJUgdhZGRyZXNzEh'
    '8KC2Ftb3VudF9zYXRzGAIgASgDUgphbW91bnRTYXRzEhkKCGZlZV9zYXRzGAMgASgDUgdmZWVT'
    'YXRz');

@$core.Deprecated('Use transparentTransferResponseDescriptor instead')
const TransparentTransferResponse$json = {
  '1': 'TransparentTransferResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `TransparentTransferResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transparentTransferResponseDescriptor = $convert.base64Decode(
    'ChtUcmFuc3BhcmVudFRyYW5zZmVyUmVzcG9uc2USEgoEdHhpZBgBIAEoCVIEdHhpZA==');

@$core.Deprecated('Use shieldedTransferRequestDescriptor instead')
const ShieldedTransferRequest$json = {
  '1': 'ShieldedTransferRequest',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'amount_sats', '3': 2, '4': 1, '5': 3, '10': 'amountSats'},
    {'1': 'fee_sats', '3': 3, '4': 1, '5': 3, '10': 'feeSats'},
  ],
};

/// Descriptor for `ShieldedTransferRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List shieldedTransferRequestDescriptor = $convert.base64Decode(
    'ChdTaGllbGRlZFRyYW5zZmVyUmVxdWVzdBIYCgdhZGRyZXNzGAEgASgJUgdhZGRyZXNzEh8KC2'
    'Ftb3VudF9zYXRzGAIgASgDUgphbW91bnRTYXRzEhkKCGZlZV9zYXRzGAMgASgDUgdmZWVTYXRz');

@$core.Deprecated('Use shieldedTransferResponseDescriptor instead')
const ShieldedTransferResponse$json = {
  '1': 'ShieldedTransferResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `ShieldedTransferResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List shieldedTransferResponseDescriptor = $convert.base64Decode(
    'ChhTaGllbGRlZFRyYW5zZmVyUmVzcG9uc2USEgoEdHhpZBgBIAEoCVIEdHhpZA==');

@$core.Deprecated('Use shieldRequestDescriptor instead')
const ShieldRequest$json = {
  '1': 'ShieldRequest',
  '2': [
    {'1': 'amount_sats', '3': 1, '4': 1, '5': 3, '10': 'amountSats'},
    {'1': 'fee_sats', '3': 2, '4': 1, '5': 3, '10': 'feeSats'},
  ],
};

/// Descriptor for `ShieldRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List shieldRequestDescriptor = $convert.base64Decode(
    'Cg1TaGllbGRSZXF1ZXN0Eh8KC2Ftb3VudF9zYXRzGAEgASgDUgphbW91bnRTYXRzEhkKCGZlZV'
    '9zYXRzGAIgASgDUgdmZWVTYXRz');

@$core.Deprecated('Use shieldResponseDescriptor instead')
const ShieldResponse$json = {
  '1': 'ShieldResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `ShieldResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List shieldResponseDescriptor = $convert.base64Decode(
    'Cg5TaGllbGRSZXNwb25zZRISCgR0eGlkGAEgASgJUgR0eGlk');

@$core.Deprecated('Use unshieldRequestDescriptor instead')
const UnshieldRequest$json = {
  '1': 'UnshieldRequest',
  '2': [
    {'1': 'amount_sats', '3': 1, '4': 1, '5': 3, '10': 'amountSats'},
    {'1': 'fee_sats', '3': 2, '4': 1, '5': 3, '10': 'feeSats'},
  ],
};

/// Descriptor for `UnshieldRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unshieldRequestDescriptor = $convert.base64Decode(
    'Cg9VbnNoaWVsZFJlcXVlc3QSHwoLYW1vdW50X3NhdHMYASABKANSCmFtb3VudFNhdHMSGQoIZm'
    'VlX3NhdHMYAiABKANSB2ZlZVNhdHM=');

@$core.Deprecated('Use unshieldResponseDescriptor instead')
const UnshieldResponse$json = {
  '1': 'UnshieldResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `UnshieldResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unshieldResponseDescriptor = $convert.base64Decode(
    'ChBVbnNoaWVsZFJlc3BvbnNlEhIKBHR4aWQYASABKAlSBHR4aWQ=');

@$core.Deprecated('Use getSidechainWealthRequestDescriptor instead')
const GetSidechainWealthRequest$json = {
  '1': 'GetSidechainWealthRequest',
};

/// Descriptor for `GetSidechainWealthRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSidechainWealthRequestDescriptor = $convert.base64Decode(
    'ChlHZXRTaWRlY2hhaW5XZWFsdGhSZXF1ZXN0');

@$core.Deprecated('Use getSidechainWealthResponseDescriptor instead')
const GetSidechainWealthResponse$json = {
  '1': 'GetSidechainWealthResponse',
  '2': [
    {'1': 'sats', '3': 1, '4': 1, '5': 3, '10': 'sats'},
  ],
};

/// Descriptor for `GetSidechainWealthResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSidechainWealthResponseDescriptor = $convert.base64Decode(
    'ChpHZXRTaWRlY2hhaW5XZWFsdGhSZXNwb25zZRISCgRzYXRzGAEgASgDUgRzYXRz');

@$core.Deprecated('Use createDepositRequestDescriptor instead')
const CreateDepositRequest$json = {
  '1': 'CreateDepositRequest',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'value_sats', '3': 2, '4': 1, '5': 3, '10': 'valueSats'},
    {'1': 'fee_sats', '3': 3, '4': 1, '5': 3, '10': 'feeSats'},
  ],
};

/// Descriptor for `CreateDepositRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createDepositRequestDescriptor = $convert.base64Decode(
    'ChRDcmVhdGVEZXBvc2l0UmVxdWVzdBIYCgdhZGRyZXNzGAEgASgJUgdhZGRyZXNzEh0KCnZhbH'
    'VlX3NhdHMYAiABKANSCXZhbHVlU2F0cxIZCghmZWVfc2F0cxgDIAEoA1IHZmVlU2F0cw==');

@$core.Deprecated('Use createDepositResponseDescriptor instead')
const CreateDepositResponse$json = {
  '1': 'CreateDepositResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `CreateDepositResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createDepositResponseDescriptor = $convert.base64Decode(
    'ChVDcmVhdGVEZXBvc2l0UmVzcG9uc2USEgoEdHhpZBgBIAEoCVIEdHhpZA==');

@$core.Deprecated('Use getPendingWithdrawalBundleRequestDescriptor instead')
const GetPendingWithdrawalBundleRequest$json = {
  '1': 'GetPendingWithdrawalBundleRequest',
};

/// Descriptor for `GetPendingWithdrawalBundleRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPendingWithdrawalBundleRequestDescriptor = $convert.base64Decode(
    'CiFHZXRQZW5kaW5nV2l0aGRyYXdhbEJ1bmRsZVJlcXVlc3Q=');

@$core.Deprecated('Use getPendingWithdrawalBundleResponseDescriptor instead')
const GetPendingWithdrawalBundleResponse$json = {
  '1': 'GetPendingWithdrawalBundleResponse',
  '2': [
    {'1': 'bundle_json', '3': 1, '4': 1, '5': 9, '10': 'bundleJson'},
  ],
};

/// Descriptor for `GetPendingWithdrawalBundleResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPendingWithdrawalBundleResponseDescriptor = $convert.base64Decode(
    'CiJHZXRQZW5kaW5nV2l0aGRyYXdhbEJ1bmRsZVJlc3BvbnNlEh8KC2J1bmRsZV9qc29uGAEgAS'
    'gJUgpidW5kbGVKc29u');

@$core.Deprecated('Use connectPeerRequestDescriptor instead')
const ConnectPeerRequest$json = {
  '1': 'ConnectPeerRequest',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
  ],
};

/// Descriptor for `ConnectPeerRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List connectPeerRequestDescriptor = $convert.base64Decode(
    'ChJDb25uZWN0UGVlclJlcXVlc3QSGAoHYWRkcmVzcxgBIAEoCVIHYWRkcmVzcw==');

@$core.Deprecated('Use connectPeerResponseDescriptor instead')
const ConnectPeerResponse$json = {
  '1': 'ConnectPeerResponse',
};

/// Descriptor for `ConnectPeerResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List connectPeerResponseDescriptor = $convert.base64Decode(
    'ChNDb25uZWN0UGVlclJlc3BvbnNl');

@$core.Deprecated('Use listPeersRequestDescriptor instead')
const ListPeersRequest$json = {
  '1': 'ListPeersRequest',
};

/// Descriptor for `ListPeersRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listPeersRequestDescriptor = $convert.base64Decode(
    'ChBMaXN0UGVlcnNSZXF1ZXN0');

@$core.Deprecated('Use listPeersResponseDescriptor instead')
const ListPeersResponse$json = {
  '1': 'ListPeersResponse',
  '2': [
    {'1': 'peers_json', '3': 1, '4': 1, '5': 9, '10': 'peersJson'},
  ],
};

/// Descriptor for `ListPeersResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listPeersResponseDescriptor = $convert.base64Decode(
    'ChFMaXN0UGVlcnNSZXNwb25zZRIdCgpwZWVyc19qc29uGAEgASgJUglwZWVyc0pzb24=');

@$core.Deprecated('Use mineRequestDescriptor instead')
const MineRequest$json = {
  '1': 'MineRequest',
  '2': [
    {'1': 'fee_sats', '3': 1, '4': 1, '5': 3, '10': 'feeSats'},
  ],
};

/// Descriptor for `MineRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mineRequestDescriptor = $convert.base64Decode(
    'CgtNaW5lUmVxdWVzdBIZCghmZWVfc2F0cxgBIAEoA1IHZmVlU2F0cw==');

@$core.Deprecated('Use mineResponseDescriptor instead')
const MineResponse$json = {
  '1': 'MineResponse',
  '2': [
    {'1': 'bmm_result_json', '3': 1, '4': 1, '5': 9, '10': 'bmmResultJson'},
  ],
};

/// Descriptor for `MineResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mineResponseDescriptor = $convert.base64Decode(
    'CgxNaW5lUmVzcG9uc2USJgoPYm1tX3Jlc3VsdF9qc29uGAEgASgJUg1ibW1SZXN1bHRKc29u');

@$core.Deprecated('Use getBlockRequestDescriptor instead')
const GetBlockRequest$json = {
  '1': 'GetBlockRequest',
  '2': [
    {'1': 'hash', '3': 1, '4': 1, '5': 9, '10': 'hash'},
  ],
};

/// Descriptor for `GetBlockRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBlockRequestDescriptor = $convert.base64Decode(
    'Cg9HZXRCbG9ja1JlcXVlc3QSEgoEaGFzaBgBIAEoCVIEaGFzaA==');

@$core.Deprecated('Use getBlockResponseDescriptor instead')
const GetBlockResponse$json = {
  '1': 'GetBlockResponse',
  '2': [
    {'1': 'block_json', '3': 1, '4': 1, '5': 9, '10': 'blockJson'},
  ],
};

/// Descriptor for `GetBlockResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBlockResponseDescriptor = $convert.base64Decode(
    'ChBHZXRCbG9ja1Jlc3BvbnNlEh0KCmJsb2NrX2pzb24YASABKAlSCWJsb2NrSnNvbg==');

@$core.Deprecated('Use getBestMainchainBlockHashRequestDescriptor instead')
const GetBestMainchainBlockHashRequest$json = {
  '1': 'GetBestMainchainBlockHashRequest',
};

/// Descriptor for `GetBestMainchainBlockHashRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBestMainchainBlockHashRequestDescriptor = $convert.base64Decode(
    'CiBHZXRCZXN0TWFpbmNoYWluQmxvY2tIYXNoUmVxdWVzdA==');

@$core.Deprecated('Use getBestMainchainBlockHashResponseDescriptor instead')
const GetBestMainchainBlockHashResponse$json = {
  '1': 'GetBestMainchainBlockHashResponse',
  '2': [
    {'1': 'hash', '3': 1, '4': 1, '5': 9, '10': 'hash'},
  ],
};

/// Descriptor for `GetBestMainchainBlockHashResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBestMainchainBlockHashResponseDescriptor = $convert.base64Decode(
    'CiFHZXRCZXN0TWFpbmNoYWluQmxvY2tIYXNoUmVzcG9uc2USEgoEaGFzaBgBIAEoCVIEaGFzaA'
    '==');

@$core.Deprecated('Use getBestSidechainBlockHashRequestDescriptor instead')
const GetBestSidechainBlockHashRequest$json = {
  '1': 'GetBestSidechainBlockHashRequest',
};

/// Descriptor for `GetBestSidechainBlockHashRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBestSidechainBlockHashRequestDescriptor = $convert.base64Decode(
    'CiBHZXRCZXN0U2lkZWNoYWluQmxvY2tIYXNoUmVxdWVzdA==');

@$core.Deprecated('Use getBestSidechainBlockHashResponseDescriptor instead')
const GetBestSidechainBlockHashResponse$json = {
  '1': 'GetBestSidechainBlockHashResponse',
  '2': [
    {'1': 'hash', '3': 1, '4': 1, '5': 9, '10': 'hash'},
  ],
};

/// Descriptor for `GetBestSidechainBlockHashResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBestSidechainBlockHashResponseDescriptor = $convert.base64Decode(
    'CiFHZXRCZXN0U2lkZWNoYWluQmxvY2tIYXNoUmVzcG9uc2USEgoEaGFzaBgBIAEoCVIEaGFzaA'
    '==');

@$core.Deprecated('Use getBmmInclusionsRequestDescriptor instead')
const GetBmmInclusionsRequest$json = {
  '1': 'GetBmmInclusionsRequest',
  '2': [
    {'1': 'block_hash', '3': 1, '4': 1, '5': 9, '10': 'blockHash'},
  ],
};

/// Descriptor for `GetBmmInclusionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBmmInclusionsRequestDescriptor = $convert.base64Decode(
    'ChdHZXRCbW1JbmNsdXNpb25zUmVxdWVzdBIdCgpibG9ja19oYXNoGAEgASgJUglibG9ja0hhc2'
    'g=');

@$core.Deprecated('Use getBmmInclusionsResponseDescriptor instead')
const GetBmmInclusionsResponse$json = {
  '1': 'GetBmmInclusionsResponse',
  '2': [
    {'1': 'inclusions', '3': 1, '4': 1, '5': 9, '10': 'inclusions'},
  ],
};

/// Descriptor for `GetBmmInclusionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBmmInclusionsResponseDescriptor = $convert.base64Decode(
    'ChhHZXRCbW1JbmNsdXNpb25zUmVzcG9uc2USHgoKaW5jbHVzaW9ucxgBIAEoCVIKaW5jbHVzaW'
    '9ucw==');

@$core.Deprecated('Use getWalletUtxosRequestDescriptor instead')
const GetWalletUtxosRequest$json = {
  '1': 'GetWalletUtxosRequest',
};

/// Descriptor for `GetWalletUtxosRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getWalletUtxosRequestDescriptor = $convert.base64Decode(
    'ChVHZXRXYWxsZXRVdHhvc1JlcXVlc3Q=');

@$core.Deprecated('Use getWalletUtxosResponseDescriptor instead')
const GetWalletUtxosResponse$json = {
  '1': 'GetWalletUtxosResponse',
  '2': [
    {'1': 'utxos_json', '3': 1, '4': 1, '5': 9, '10': 'utxosJson'},
  ],
};

/// Descriptor for `GetWalletUtxosResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getWalletUtxosResponseDescriptor = $convert.base64Decode(
    'ChZHZXRXYWxsZXRVdHhvc1Jlc3BvbnNlEh0KCnV0eG9zX2pzb24YASABKAlSCXV0eG9zSnNvbg'
    '==');

@$core.Deprecated('Use listUtxosRequestDescriptor instead')
const ListUtxosRequest$json = {
  '1': 'ListUtxosRequest',
};

/// Descriptor for `ListUtxosRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listUtxosRequestDescriptor = $convert.base64Decode(
    'ChBMaXN0VXR4b3NSZXF1ZXN0');

@$core.Deprecated('Use listUtxosResponseDescriptor instead')
const ListUtxosResponse$json = {
  '1': 'ListUtxosResponse',
  '2': [
    {'1': 'utxos_json', '3': 1, '4': 1, '5': 9, '10': 'utxosJson'},
  ],
};

/// Descriptor for `ListUtxosResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listUtxosResponseDescriptor = $convert.base64Decode(
    'ChFMaXN0VXR4b3NSZXNwb25zZRIdCgp1dHhvc19qc29uGAEgASgJUgl1dHhvc0pzb24=');

@$core.Deprecated('Use removeFromMempoolRequestDescriptor instead')
const RemoveFromMempoolRequest$json = {
  '1': 'RemoveFromMempoolRequest',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `RemoveFromMempoolRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeFromMempoolRequestDescriptor = $convert.base64Decode(
    'ChhSZW1vdmVGcm9tTWVtcG9vbFJlcXVlc3QSEgoEdHhpZBgBIAEoCVIEdHhpZA==');

@$core.Deprecated('Use removeFromMempoolResponseDescriptor instead')
const RemoveFromMempoolResponse$json = {
  '1': 'RemoveFromMempoolResponse',
};

/// Descriptor for `RemoveFromMempoolResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeFromMempoolResponseDescriptor = $convert.base64Decode(
    'ChlSZW1vdmVGcm9tTWVtcG9vbFJlc3BvbnNl');

@$core.Deprecated('Use getLatestFailedWithdrawalBundleHeightRequestDescriptor instead')
const GetLatestFailedWithdrawalBundleHeightRequest$json = {
  '1': 'GetLatestFailedWithdrawalBundleHeightRequest',
};

/// Descriptor for `GetLatestFailedWithdrawalBundleHeightRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getLatestFailedWithdrawalBundleHeightRequestDescriptor = $convert.base64Decode(
    'CixHZXRMYXRlc3RGYWlsZWRXaXRoZHJhd2FsQnVuZGxlSGVpZ2h0UmVxdWVzdA==');

@$core.Deprecated('Use getLatestFailedWithdrawalBundleHeightResponseDescriptor instead')
const GetLatestFailedWithdrawalBundleHeightResponse$json = {
  '1': 'GetLatestFailedWithdrawalBundleHeightResponse',
  '2': [
    {'1': 'height', '3': 1, '4': 1, '5': 3, '10': 'height'},
  ],
};

/// Descriptor for `GetLatestFailedWithdrawalBundleHeightResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getLatestFailedWithdrawalBundleHeightResponseDescriptor = $convert.base64Decode(
    'Ci1HZXRMYXRlc3RGYWlsZWRXaXRoZHJhd2FsQnVuZGxlSGVpZ2h0UmVzcG9uc2USFgoGaGVpZ2'
    'h0GAEgASgDUgZoZWlnaHQ=');

@$core.Deprecated('Use generateMnemonicRequestDescriptor instead')
const GenerateMnemonicRequest$json = {
  '1': 'GenerateMnemonicRequest',
};

/// Descriptor for `GenerateMnemonicRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List generateMnemonicRequestDescriptor = $convert.base64Decode(
    'ChdHZW5lcmF0ZU1uZW1vbmljUmVxdWVzdA==');

@$core.Deprecated('Use generateMnemonicResponseDescriptor instead')
const GenerateMnemonicResponse$json = {
  '1': 'GenerateMnemonicResponse',
  '2': [
    {'1': 'mnemonic', '3': 1, '4': 1, '5': 9, '10': 'mnemonic'},
  ],
};

/// Descriptor for `GenerateMnemonicResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List generateMnemonicResponseDescriptor = $convert.base64Decode(
    'ChhHZW5lcmF0ZU1uZW1vbmljUmVzcG9uc2USGgoIbW5lbW9uaWMYASABKAlSCG1uZW1vbmlj');

@$core.Deprecated('Use setSeedFromMnemonicRequestDescriptor instead')
const SetSeedFromMnemonicRequest$json = {
  '1': 'SetSeedFromMnemonicRequest',
  '2': [
    {'1': 'mnemonic', '3': 1, '4': 1, '5': 9, '10': 'mnemonic'},
  ],
};

/// Descriptor for `SetSeedFromMnemonicRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setSeedFromMnemonicRequestDescriptor = $convert.base64Decode(
    'ChpTZXRTZWVkRnJvbU1uZW1vbmljUmVxdWVzdBIaCghtbmVtb25pYxgBIAEoCVIIbW5lbW9uaW'
    'M=');

@$core.Deprecated('Use setSeedFromMnemonicResponseDescriptor instead')
const SetSeedFromMnemonicResponse$json = {
  '1': 'SetSeedFromMnemonicResponse',
};

/// Descriptor for `SetSeedFromMnemonicResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setSeedFromMnemonicResponseDescriptor = $convert.base64Decode(
    'ChtTZXRTZWVkRnJvbU1uZW1vbmljUmVzcG9uc2U=');

@$core.Deprecated('Use callRawRequestDescriptor instead')
const CallRawRequest$json = {
  '1': 'CallRawRequest',
  '2': [
    {'1': 'method', '3': 1, '4': 1, '5': 9, '10': 'method'},
    {'1': 'params_json', '3': 2, '4': 1, '5': 9, '10': 'paramsJson'},
  ],
};

/// Descriptor for `CallRawRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List callRawRequestDescriptor = $convert.base64Decode(
    'Cg5DYWxsUmF3UmVxdWVzdBIWCgZtZXRob2QYASABKAlSBm1ldGhvZBIfCgtwYXJhbXNfanNvbh'
    'gCIAEoCVIKcGFyYW1zSnNvbg==');

@$core.Deprecated('Use callRawResponseDescriptor instead')
const CallRawResponse$json = {
  '1': 'CallRawResponse',
  '2': [
    {'1': 'result_json', '3': 1, '4': 1, '5': 9, '10': 'resultJson'},
  ],
};

/// Descriptor for `CallRawResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List callRawResponseDescriptor = $convert.base64Decode(
    'Cg9DYWxsUmF3UmVzcG9uc2USHwoLcmVzdWx0X2pzb24YASABKAlSCnJlc3VsdEpzb24=');

const $core.Map<$core.String, $core.dynamic> ZSideServiceBase$json = {
  '1': 'ZSideService',
  '2': [
    {'1': 'GetBalance', '2': '.zside.v1.GetBalanceRequest', '3': '.zside.v1.GetBalanceResponse'},
    {'1': 'GetBalanceBreakdown', '2': '.zside.v1.GetBalanceBreakdownRequest', '3': '.zside.v1.GetBalanceBreakdownResponse'},
    {'1': 'GetBlockCount', '2': '.zside.v1.GetBlockCountRequest', '3': '.zside.v1.GetBlockCountResponse'},
    {'1': 'Stop', '2': '.zside.v1.StopRequest', '3': '.zside.v1.StopResponse'},
    {'1': 'GetNewTransparentAddress', '2': '.zside.v1.GetNewTransparentAddressRequest', '3': '.zside.v1.GetNewTransparentAddressResponse'},
    {'1': 'GetNewShieldedAddress', '2': '.zside.v1.GetNewShieldedAddressRequest', '3': '.zside.v1.GetNewShieldedAddressResponse'},
    {'1': 'GetShieldedWalletAddresses', '2': '.zside.v1.GetShieldedWalletAddressesRequest', '3': '.zside.v1.GetShieldedWalletAddressesResponse'},
    {'1': 'GetTransparentWalletAddresses', '2': '.zside.v1.GetTransparentWalletAddressesRequest', '3': '.zside.v1.GetTransparentWalletAddressesResponse'},
    {'1': 'Withdraw', '2': '.zside.v1.WithdrawRequest', '3': '.zside.v1.WithdrawResponse'},
    {'1': 'TransparentTransfer', '2': '.zside.v1.TransparentTransferRequest', '3': '.zside.v1.TransparentTransferResponse'},
    {'1': 'ShieldedTransfer', '2': '.zside.v1.ShieldedTransferRequest', '3': '.zside.v1.ShieldedTransferResponse'},
    {'1': 'Shield', '2': '.zside.v1.ShieldRequest', '3': '.zside.v1.ShieldResponse'},
    {'1': 'Unshield', '2': '.zside.v1.UnshieldRequest', '3': '.zside.v1.UnshieldResponse'},
    {'1': 'GetSidechainWealth', '2': '.zside.v1.GetSidechainWealthRequest', '3': '.zside.v1.GetSidechainWealthResponse'},
    {'1': 'CreateDeposit', '2': '.zside.v1.CreateDepositRequest', '3': '.zside.v1.CreateDepositResponse'},
    {'1': 'GetPendingWithdrawalBundle', '2': '.zside.v1.GetPendingWithdrawalBundleRequest', '3': '.zside.v1.GetPendingWithdrawalBundleResponse'},
    {'1': 'ConnectPeer', '2': '.zside.v1.ConnectPeerRequest', '3': '.zside.v1.ConnectPeerResponse'},
    {'1': 'ListPeers', '2': '.zside.v1.ListPeersRequest', '3': '.zside.v1.ListPeersResponse'},
    {'1': 'Mine', '2': '.zside.v1.MineRequest', '3': '.zside.v1.MineResponse'},
    {'1': 'GetBlock', '2': '.zside.v1.GetBlockRequest', '3': '.zside.v1.GetBlockResponse'},
    {'1': 'GetBestMainchainBlockHash', '2': '.zside.v1.GetBestMainchainBlockHashRequest', '3': '.zside.v1.GetBestMainchainBlockHashResponse'},
    {'1': 'GetBestSidechainBlockHash', '2': '.zside.v1.GetBestSidechainBlockHashRequest', '3': '.zside.v1.GetBestSidechainBlockHashResponse'},
    {'1': 'GetBmmInclusions', '2': '.zside.v1.GetBmmInclusionsRequest', '3': '.zside.v1.GetBmmInclusionsResponse'},
    {'1': 'GetWalletUtxos', '2': '.zside.v1.GetWalletUtxosRequest', '3': '.zside.v1.GetWalletUtxosResponse'},
    {'1': 'ListUtxos', '2': '.zside.v1.ListUtxosRequest', '3': '.zside.v1.ListUtxosResponse'},
    {'1': 'RemoveFromMempool', '2': '.zside.v1.RemoveFromMempoolRequest', '3': '.zside.v1.RemoveFromMempoolResponse'},
    {'1': 'GetLatestFailedWithdrawalBundleHeight', '2': '.zside.v1.GetLatestFailedWithdrawalBundleHeightRequest', '3': '.zside.v1.GetLatestFailedWithdrawalBundleHeightResponse'},
    {'1': 'GenerateMnemonic', '2': '.zside.v1.GenerateMnemonicRequest', '3': '.zside.v1.GenerateMnemonicResponse'},
    {'1': 'SetSeedFromMnemonic', '2': '.zside.v1.SetSeedFromMnemonicRequest', '3': '.zside.v1.SetSeedFromMnemonicResponse'},
    {'1': 'CallRaw', '2': '.zside.v1.CallRawRequest', '3': '.zside.v1.CallRawResponse'},
  ],
};

@$core.Deprecated('Use zSideServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> ZSideServiceBase$messageJson = {
  '.zside.v1.GetBalanceRequest': GetBalanceRequest$json,
  '.zside.v1.GetBalanceResponse': GetBalanceResponse$json,
  '.zside.v1.GetBalanceBreakdownRequest': GetBalanceBreakdownRequest$json,
  '.zside.v1.GetBalanceBreakdownResponse': GetBalanceBreakdownResponse$json,
  '.zside.v1.GetBlockCountRequest': GetBlockCountRequest$json,
  '.zside.v1.GetBlockCountResponse': GetBlockCountResponse$json,
  '.zside.v1.StopRequest': StopRequest$json,
  '.zside.v1.StopResponse': StopResponse$json,
  '.zside.v1.GetNewTransparentAddressRequest': GetNewTransparentAddressRequest$json,
  '.zside.v1.GetNewTransparentAddressResponse': GetNewTransparentAddressResponse$json,
  '.zside.v1.GetNewShieldedAddressRequest': GetNewShieldedAddressRequest$json,
  '.zside.v1.GetNewShieldedAddressResponse': GetNewShieldedAddressResponse$json,
  '.zside.v1.GetShieldedWalletAddressesRequest': GetShieldedWalletAddressesRequest$json,
  '.zside.v1.GetShieldedWalletAddressesResponse': GetShieldedWalletAddressesResponse$json,
  '.zside.v1.GetTransparentWalletAddressesRequest': GetTransparentWalletAddressesRequest$json,
  '.zside.v1.GetTransparentWalletAddressesResponse': GetTransparentWalletAddressesResponse$json,
  '.zside.v1.WithdrawRequest': WithdrawRequest$json,
  '.zside.v1.WithdrawResponse': WithdrawResponse$json,
  '.zside.v1.TransparentTransferRequest': TransparentTransferRequest$json,
  '.zside.v1.TransparentTransferResponse': TransparentTransferResponse$json,
  '.zside.v1.ShieldedTransferRequest': ShieldedTransferRequest$json,
  '.zside.v1.ShieldedTransferResponse': ShieldedTransferResponse$json,
  '.zside.v1.ShieldRequest': ShieldRequest$json,
  '.zside.v1.ShieldResponse': ShieldResponse$json,
  '.zside.v1.UnshieldRequest': UnshieldRequest$json,
  '.zside.v1.UnshieldResponse': UnshieldResponse$json,
  '.zside.v1.GetSidechainWealthRequest': GetSidechainWealthRequest$json,
  '.zside.v1.GetSidechainWealthResponse': GetSidechainWealthResponse$json,
  '.zside.v1.CreateDepositRequest': CreateDepositRequest$json,
  '.zside.v1.CreateDepositResponse': CreateDepositResponse$json,
  '.zside.v1.GetPendingWithdrawalBundleRequest': GetPendingWithdrawalBundleRequest$json,
  '.zside.v1.GetPendingWithdrawalBundleResponse': GetPendingWithdrawalBundleResponse$json,
  '.zside.v1.ConnectPeerRequest': ConnectPeerRequest$json,
  '.zside.v1.ConnectPeerResponse': ConnectPeerResponse$json,
  '.zside.v1.ListPeersRequest': ListPeersRequest$json,
  '.zside.v1.ListPeersResponse': ListPeersResponse$json,
  '.zside.v1.MineRequest': MineRequest$json,
  '.zside.v1.MineResponse': MineResponse$json,
  '.zside.v1.GetBlockRequest': GetBlockRequest$json,
  '.zside.v1.GetBlockResponse': GetBlockResponse$json,
  '.zside.v1.GetBestMainchainBlockHashRequest': GetBestMainchainBlockHashRequest$json,
  '.zside.v1.GetBestMainchainBlockHashResponse': GetBestMainchainBlockHashResponse$json,
  '.zside.v1.GetBestSidechainBlockHashRequest': GetBestSidechainBlockHashRequest$json,
  '.zside.v1.GetBestSidechainBlockHashResponse': GetBestSidechainBlockHashResponse$json,
  '.zside.v1.GetBmmInclusionsRequest': GetBmmInclusionsRequest$json,
  '.zside.v1.GetBmmInclusionsResponse': GetBmmInclusionsResponse$json,
  '.zside.v1.GetWalletUtxosRequest': GetWalletUtxosRequest$json,
  '.zside.v1.GetWalletUtxosResponse': GetWalletUtxosResponse$json,
  '.zside.v1.ListUtxosRequest': ListUtxosRequest$json,
  '.zside.v1.ListUtxosResponse': ListUtxosResponse$json,
  '.zside.v1.RemoveFromMempoolRequest': RemoveFromMempoolRequest$json,
  '.zside.v1.RemoveFromMempoolResponse': RemoveFromMempoolResponse$json,
  '.zside.v1.GetLatestFailedWithdrawalBundleHeightRequest': GetLatestFailedWithdrawalBundleHeightRequest$json,
  '.zside.v1.GetLatestFailedWithdrawalBundleHeightResponse': GetLatestFailedWithdrawalBundleHeightResponse$json,
  '.zside.v1.GenerateMnemonicRequest': GenerateMnemonicRequest$json,
  '.zside.v1.GenerateMnemonicResponse': GenerateMnemonicResponse$json,
  '.zside.v1.SetSeedFromMnemonicRequest': SetSeedFromMnemonicRequest$json,
  '.zside.v1.SetSeedFromMnemonicResponse': SetSeedFromMnemonicResponse$json,
  '.zside.v1.CallRawRequest': CallRawRequest$json,
  '.zside.v1.CallRawResponse': CallRawResponse$json,
};

/// Descriptor for `ZSideService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List zSideServiceDescriptor = $convert.base64Decode(
    'CgxaU2lkZVNlcnZpY2USRwoKR2V0QmFsYW5jZRIbLnpzaWRlLnYxLkdldEJhbGFuY2VSZXF1ZX'
    'N0GhwuenNpZGUudjEuR2V0QmFsYW5jZVJlc3BvbnNlEmIKE0dldEJhbGFuY2VCcmVha2Rvd24S'
    'JC56c2lkZS52MS5HZXRCYWxhbmNlQnJlYWtkb3duUmVxdWVzdBolLnpzaWRlLnYxLkdldEJhbG'
    'FuY2VCcmVha2Rvd25SZXNwb25zZRJQCg1HZXRCbG9ja0NvdW50Eh4uenNpZGUudjEuR2V0Qmxv'
    'Y2tDb3VudFJlcXVlc3QaHy56c2lkZS52MS5HZXRCbG9ja0NvdW50UmVzcG9uc2USNQoEU3RvcB'
    'IVLnpzaWRlLnYxLlN0b3BSZXF1ZXN0GhYuenNpZGUudjEuU3RvcFJlc3BvbnNlEnEKGEdldE5l'
    'd1RyYW5zcGFyZW50QWRkcmVzcxIpLnpzaWRlLnYxLkdldE5ld1RyYW5zcGFyZW50QWRkcmVzc1'
    'JlcXVlc3QaKi56c2lkZS52MS5HZXROZXdUcmFuc3BhcmVudEFkZHJlc3NSZXNwb25zZRJoChVH'
    'ZXROZXdTaGllbGRlZEFkZHJlc3MSJi56c2lkZS52MS5HZXROZXdTaGllbGRlZEFkZHJlc3NSZX'
    'F1ZXN0GicuenNpZGUudjEuR2V0TmV3U2hpZWxkZWRBZGRyZXNzUmVzcG9uc2USdwoaR2V0U2hp'
    'ZWxkZWRXYWxsZXRBZGRyZXNzZXMSKy56c2lkZS52MS5HZXRTaGllbGRlZFdhbGxldEFkZHJlc3'
    'Nlc1JlcXVlc3QaLC56c2lkZS52MS5HZXRTaGllbGRlZFdhbGxldEFkZHJlc3Nlc1Jlc3BvbnNl'
    'EoABCh1HZXRUcmFuc3BhcmVudFdhbGxldEFkZHJlc3NlcxIuLnpzaWRlLnYxLkdldFRyYW5zcG'
    'FyZW50V2FsbGV0QWRkcmVzc2VzUmVxdWVzdBovLnpzaWRlLnYxLkdldFRyYW5zcGFyZW50V2Fs'
    'bGV0QWRkcmVzc2VzUmVzcG9uc2USQQoIV2l0aGRyYXcSGS56c2lkZS52MS5XaXRoZHJhd1JlcX'
    'Vlc3QaGi56c2lkZS52MS5XaXRoZHJhd1Jlc3BvbnNlEmIKE1RyYW5zcGFyZW50VHJhbnNmZXIS'
    'JC56c2lkZS52MS5UcmFuc3BhcmVudFRyYW5zZmVyUmVxdWVzdBolLnpzaWRlLnYxLlRyYW5zcG'
    'FyZW50VHJhbnNmZXJSZXNwb25zZRJZChBTaGllbGRlZFRyYW5zZmVyEiEuenNpZGUudjEuU2hp'
    'ZWxkZWRUcmFuc2ZlclJlcXVlc3QaIi56c2lkZS52MS5TaGllbGRlZFRyYW5zZmVyUmVzcG9uc2'
    'USOwoGU2hpZWxkEhcuenNpZGUudjEuU2hpZWxkUmVxdWVzdBoYLnpzaWRlLnYxLlNoaWVsZFJl'
    'c3BvbnNlEkEKCFVuc2hpZWxkEhkuenNpZGUudjEuVW5zaGllbGRSZXF1ZXN0GhouenNpZGUudj'
    'EuVW5zaGllbGRSZXNwb25zZRJfChJHZXRTaWRlY2hhaW5XZWFsdGgSIy56c2lkZS52MS5HZXRT'
    'aWRlY2hhaW5XZWFsdGhSZXF1ZXN0GiQuenNpZGUudjEuR2V0U2lkZWNoYWluV2VhbHRoUmVzcG'
    '9uc2USUAoNQ3JlYXRlRGVwb3NpdBIeLnpzaWRlLnYxLkNyZWF0ZURlcG9zaXRSZXF1ZXN0Gh8u'
    'enNpZGUudjEuQ3JlYXRlRGVwb3NpdFJlc3BvbnNlEncKGkdldFBlbmRpbmdXaXRoZHJhd2FsQn'
    'VuZGxlEisuenNpZGUudjEuR2V0UGVuZGluZ1dpdGhkcmF3YWxCdW5kbGVSZXF1ZXN0GiwuenNp'
    'ZGUudjEuR2V0UGVuZGluZ1dpdGhkcmF3YWxCdW5kbGVSZXNwb25zZRJKCgtDb25uZWN0UGVlch'
    'IcLnpzaWRlLnYxLkNvbm5lY3RQZWVyUmVxdWVzdBodLnpzaWRlLnYxLkNvbm5lY3RQZWVyUmVz'
    'cG9uc2USRAoJTGlzdFBlZXJzEhouenNpZGUudjEuTGlzdFBlZXJzUmVxdWVzdBobLnpzaWRlLn'
    'YxLkxpc3RQZWVyc1Jlc3BvbnNlEjUKBE1pbmUSFS56c2lkZS52MS5NaW5lUmVxdWVzdBoWLnpz'
    'aWRlLnYxLk1pbmVSZXNwb25zZRJBCghHZXRCbG9jaxIZLnpzaWRlLnYxLkdldEJsb2NrUmVxdW'
    'VzdBoaLnpzaWRlLnYxLkdldEJsb2NrUmVzcG9uc2USdAoZR2V0QmVzdE1haW5jaGFpbkJsb2Nr'
    'SGFzaBIqLnpzaWRlLnYxLkdldEJlc3RNYWluY2hhaW5CbG9ja0hhc2hSZXF1ZXN0GisuenNpZG'
    'UudjEuR2V0QmVzdE1haW5jaGFpbkJsb2NrSGFzaFJlc3BvbnNlEnQKGUdldEJlc3RTaWRlY2hh'
    'aW5CbG9ja0hhc2gSKi56c2lkZS52MS5HZXRCZXN0U2lkZWNoYWluQmxvY2tIYXNoUmVxdWVzdB'
    'orLnpzaWRlLnYxLkdldEJlc3RTaWRlY2hhaW5CbG9ja0hhc2hSZXNwb25zZRJZChBHZXRCbW1J'
    'bmNsdXNpb25zEiEuenNpZGUudjEuR2V0Qm1tSW5jbHVzaW9uc1JlcXVlc3QaIi56c2lkZS52MS'
    '5HZXRCbW1JbmNsdXNpb25zUmVzcG9uc2USUwoOR2V0V2FsbGV0VXR4b3MSHy56c2lkZS52MS5H'
    'ZXRXYWxsZXRVdHhvc1JlcXVlc3QaIC56c2lkZS52MS5HZXRXYWxsZXRVdHhvc1Jlc3BvbnNlEk'
    'QKCUxpc3RVdHhvcxIaLnpzaWRlLnYxLkxpc3RVdHhvc1JlcXVlc3QaGy56c2lkZS52MS5MaXN0'
    'VXR4b3NSZXNwb25zZRJcChFSZW1vdmVGcm9tTWVtcG9vbBIiLnpzaWRlLnYxLlJlbW92ZUZyb2'
    '1NZW1wb29sUmVxdWVzdBojLnpzaWRlLnYxLlJlbW92ZUZyb21NZW1wb29sUmVzcG9uc2USmAEK'
    'JUdldExhdGVzdEZhaWxlZFdpdGhkcmF3YWxCdW5kbGVIZWlnaHQSNi56c2lkZS52MS5HZXRMYX'
    'Rlc3RGYWlsZWRXaXRoZHJhd2FsQnVuZGxlSGVpZ2h0UmVxdWVzdBo3LnpzaWRlLnYxLkdldExh'
    'dGVzdEZhaWxlZFdpdGhkcmF3YWxCdW5kbGVIZWlnaHRSZXNwb25zZRJZChBHZW5lcmF0ZU1uZW'
    '1vbmljEiEuenNpZGUudjEuR2VuZXJhdGVNbmVtb25pY1JlcXVlc3QaIi56c2lkZS52MS5HZW5l'
    'cmF0ZU1uZW1vbmljUmVzcG9uc2USYgoTU2V0U2VlZEZyb21NbmVtb25pYxIkLnpzaWRlLnYxLl'
    'NldFNlZWRGcm9tTW5lbW9uaWNSZXF1ZXN0GiUuenNpZGUudjEuU2V0U2VlZEZyb21NbmVtb25p'
    'Y1Jlc3BvbnNlEj4KB0NhbGxSYXcSGC56c2lkZS52MS5DYWxsUmF3UmVxdWVzdBoZLnpzaWRlLn'
    'YxLkNhbGxSYXdSZXNwb25zZQ==');

