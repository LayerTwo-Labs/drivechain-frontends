//
//  Generated code. Do not modify.
//  source: coinshift/v1/coinshift.proto
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

@$core.Deprecated('Use getNewAddressRequestDescriptor instead')
const GetNewAddressRequest$json = {
  '1': 'GetNewAddressRequest',
};

/// Descriptor for `GetNewAddressRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNewAddressRequestDescriptor = $convert.base64Decode(
    'ChRHZXROZXdBZGRyZXNzUmVxdWVzdA==');

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

@$core.Deprecated('Use transferRequestDescriptor instead')
const TransferRequest$json = {
  '1': 'TransferRequest',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'amount_sats', '3': 2, '4': 1, '5': 3, '10': 'amountSats'},
    {'1': 'fee_sats', '3': 3, '4': 1, '5': 3, '10': 'feeSats'},
  ],
};

/// Descriptor for `TransferRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transferRequestDescriptor = $convert.base64Decode(
    'Cg9UcmFuc2ZlclJlcXVlc3QSGAoHYWRkcmVzcxgBIAEoCVIHYWRkcmVzcxIfCgthbW91bnRfc2'
    'F0cxgCIAEoA1IKYW1vdW50U2F0cxIZCghmZWVfc2F0cxgDIAEoA1IHZmVlU2F0cw==');

@$core.Deprecated('Use transferResponseDescriptor instead')
const TransferResponse$json = {
  '1': 'TransferResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `TransferResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transferResponseDescriptor = $convert.base64Decode(
    'ChBUcmFuc2ZlclJlc3BvbnNlEhIKBHR4aWQYASABKAlSBHR4aWQ=');

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

@$core.Deprecated('Use forgetPeerRequestDescriptor instead')
const ForgetPeerRequest$json = {
  '1': 'ForgetPeerRequest',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
  ],
};

/// Descriptor for `ForgetPeerRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List forgetPeerRequestDescriptor = $convert.base64Decode(
    'ChFGb3JnZXRQZWVyUmVxdWVzdBIYCgdhZGRyZXNzGAEgASgJUgdhZGRyZXNz');

@$core.Deprecated('Use forgetPeerResponseDescriptor instead')
const ForgetPeerResponse$json = {
  '1': 'ForgetPeerResponse',
};

/// Descriptor for `ForgetPeerResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List forgetPeerResponseDescriptor = $convert.base64Decode(
    'ChJGb3JnZXRQZWVyUmVzcG9uc2U=');

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

@$core.Deprecated('Use getWalletAddressesRequestDescriptor instead')
const GetWalletAddressesRequest$json = {
  '1': 'GetWalletAddressesRequest',
};

/// Descriptor for `GetWalletAddressesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getWalletAddressesRequestDescriptor = $convert.base64Decode(
    'ChlHZXRXYWxsZXRBZGRyZXNzZXNSZXF1ZXN0');

@$core.Deprecated('Use getWalletAddressesResponseDescriptor instead')
const GetWalletAddressesResponse$json = {
  '1': 'GetWalletAddressesResponse',
  '2': [
    {'1': 'addresses', '3': 1, '4': 3, '5': 9, '10': 'addresses'},
  ],
};

/// Descriptor for `GetWalletAddressesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getWalletAddressesResponseDescriptor = $convert.base64Decode(
    'ChpHZXRXYWxsZXRBZGRyZXNzZXNSZXNwb25zZRIcCglhZGRyZXNzZXMYASADKAlSCWFkZHJlc3'
    'Nlcw==');

@$core.Deprecated('Use openapiSchemaRequestDescriptor instead')
const OpenapiSchemaRequest$json = {
  '1': 'OpenapiSchemaRequest',
};

/// Descriptor for `OpenapiSchemaRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List openapiSchemaRequestDescriptor = $convert.base64Decode(
    'ChRPcGVuYXBpU2NoZW1hUmVxdWVzdA==');

@$core.Deprecated('Use openapiSchemaResponseDescriptor instead')
const OpenapiSchemaResponse$json = {
  '1': 'OpenapiSchemaResponse',
  '2': [
    {'1': 'schema_json', '3': 1, '4': 1, '5': 9, '10': 'schemaJson'},
  ],
};

/// Descriptor for `OpenapiSchemaResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List openapiSchemaResponseDescriptor = $convert.base64Decode(
    'ChVPcGVuYXBpU2NoZW1hUmVzcG9uc2USHwoLc2NoZW1hX2pzb24YASABKAlSCnNjaGVtYUpzb2'
    '4=');

@$core.Deprecated('Use createSwapRequestDescriptor instead')
const CreateSwapRequest$json = {
  '1': 'CreateSwapRequest',
  '2': [
    {'1': 'l2_amount_sats', '3': 1, '4': 1, '5': 3, '10': 'l2AmountSats'},
    {'1': 'l1_amount_sats', '3': 2, '4': 1, '5': 3, '10': 'l1AmountSats'},
    {'1': 'l1_recipient_address', '3': 3, '4': 1, '5': 9, '10': 'l1RecipientAddress'},
    {'1': 'parent_chain', '3': 4, '4': 1, '5': 9, '10': 'parentChain'},
    {'1': 'l2_recipient', '3': 5, '4': 1, '5': 9, '9': 0, '10': 'l2Recipient', '17': true},
    {'1': 'required_confirmations', '3': 6, '4': 1, '5': 5, '9': 1, '10': 'requiredConfirmations', '17': true},
    {'1': 'fee_sats', '3': 7, '4': 1, '5': 3, '10': 'feeSats'},
  ],
  '8': [
    {'1': '_l2_recipient'},
    {'1': '_required_confirmations'},
  ],
};

/// Descriptor for `CreateSwapRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createSwapRequestDescriptor = $convert.base64Decode(
    'ChFDcmVhdGVTd2FwUmVxdWVzdBIkCg5sMl9hbW91bnRfc2F0cxgBIAEoA1IMbDJBbW91bnRTYX'
    'RzEiQKDmwxX2Ftb3VudF9zYXRzGAIgASgDUgxsMUFtb3VudFNhdHMSMAoUbDFfcmVjaXBpZW50'
    'X2FkZHJlc3MYAyABKAlSEmwxUmVjaXBpZW50QWRkcmVzcxIhCgxwYXJlbnRfY2hhaW4YBCABKA'
    'lSC3BhcmVudENoYWluEiYKDGwyX3JlY2lwaWVudBgFIAEoCUgAUgtsMlJlY2lwaWVudIgBARI6'
    'ChZyZXF1aXJlZF9jb25maXJtYXRpb25zGAYgASgFSAFSFXJlcXVpcmVkQ29uZmlybWF0aW9uc4'
    'gBARIZCghmZWVfc2F0cxgHIAEoA1IHZmVlU2F0c0IPCg1fbDJfcmVjaXBpZW50QhkKF19yZXF1'
    'aXJlZF9jb25maXJtYXRpb25z');

@$core.Deprecated('Use createSwapResponseDescriptor instead')
const CreateSwapResponse$json = {
  '1': 'CreateSwapResponse',
  '2': [
    {'1': 'swap_id', '3': 1, '4': 1, '5': 9, '10': 'swapId'},
    {'1': 'txid', '3': 2, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `CreateSwapResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createSwapResponseDescriptor = $convert.base64Decode(
    'ChJDcmVhdGVTd2FwUmVzcG9uc2USFwoHc3dhcF9pZBgBIAEoCVIGc3dhcElkEhIKBHR4aWQYAi'
    'ABKAlSBHR4aWQ=');

@$core.Deprecated('Use claimSwapRequestDescriptor instead')
const ClaimSwapRequest$json = {
  '1': 'ClaimSwapRequest',
  '2': [
    {'1': 'swap_id', '3': 1, '4': 1, '5': 9, '10': 'swapId'},
    {'1': 'l2_claimer_address', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'l2ClaimerAddress', '17': true},
  ],
  '8': [
    {'1': '_l2_claimer_address'},
  ],
};

/// Descriptor for `ClaimSwapRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List claimSwapRequestDescriptor = $convert.base64Decode(
    'ChBDbGFpbVN3YXBSZXF1ZXN0EhcKB3N3YXBfaWQYASABKAlSBnN3YXBJZBIxChJsMl9jbGFpbW'
    'VyX2FkZHJlc3MYAiABKAlIAFIQbDJDbGFpbWVyQWRkcmVzc4gBAUIVChNfbDJfY2xhaW1lcl9h'
    'ZGRyZXNz');

@$core.Deprecated('Use claimSwapResponseDescriptor instead')
const ClaimSwapResponse$json = {
  '1': 'ClaimSwapResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `ClaimSwapResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List claimSwapResponseDescriptor = $convert.base64Decode(
    'ChFDbGFpbVN3YXBSZXNwb25zZRISCgR0eGlkGAEgASgJUgR0eGlk');

@$core.Deprecated('Use getSwapStatusRequestDescriptor instead')
const GetSwapStatusRequest$json = {
  '1': 'GetSwapStatusRequest',
  '2': [
    {'1': 'swap_id', '3': 1, '4': 1, '5': 9, '10': 'swapId'},
  ],
};

/// Descriptor for `GetSwapStatusRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSwapStatusRequestDescriptor = $convert.base64Decode(
    'ChRHZXRTd2FwU3RhdHVzUmVxdWVzdBIXCgdzd2FwX2lkGAEgASgJUgZzd2FwSWQ=');

@$core.Deprecated('Use getSwapStatusResponseDescriptor instead')
const GetSwapStatusResponse$json = {
  '1': 'GetSwapStatusResponse',
  '2': [
    {'1': 'swap_json', '3': 1, '4': 1, '5': 9, '10': 'swapJson'},
  ],
};

/// Descriptor for `GetSwapStatusResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSwapStatusResponseDescriptor = $convert.base64Decode(
    'ChVHZXRTd2FwU3RhdHVzUmVzcG9uc2USGwoJc3dhcF9qc29uGAEgASgJUghzd2FwSnNvbg==');

@$core.Deprecated('Use listSwapsRequestDescriptor instead')
const ListSwapsRequest$json = {
  '1': 'ListSwapsRequest',
};

/// Descriptor for `ListSwapsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listSwapsRequestDescriptor = $convert.base64Decode(
    'ChBMaXN0U3dhcHNSZXF1ZXN0');

@$core.Deprecated('Use listSwapsResponseDescriptor instead')
const ListSwapsResponse$json = {
  '1': 'ListSwapsResponse',
  '2': [
    {'1': 'swaps_json', '3': 1, '4': 1, '5': 9, '10': 'swapsJson'},
  ],
};

/// Descriptor for `ListSwapsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listSwapsResponseDescriptor = $convert.base64Decode(
    'ChFMaXN0U3dhcHNSZXNwb25zZRIdCgpzd2Fwc19qc29uGAEgASgJUglzd2Fwc0pzb24=');

@$core.Deprecated('Use listSwapsByRecipientRequestDescriptor instead')
const ListSwapsByRecipientRequest$json = {
  '1': 'ListSwapsByRecipientRequest',
  '2': [
    {'1': 'recipient', '3': 1, '4': 1, '5': 9, '10': 'recipient'},
  ],
};

/// Descriptor for `ListSwapsByRecipientRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listSwapsByRecipientRequestDescriptor = $convert.base64Decode(
    'ChtMaXN0U3dhcHNCeVJlY2lwaWVudFJlcXVlc3QSHAoJcmVjaXBpZW50GAEgASgJUglyZWNpcG'
    'llbnQ=');

@$core.Deprecated('Use listSwapsByRecipientResponseDescriptor instead')
const ListSwapsByRecipientResponse$json = {
  '1': 'ListSwapsByRecipientResponse',
  '2': [
    {'1': 'swaps_json', '3': 1, '4': 1, '5': 9, '10': 'swapsJson'},
  ],
};

/// Descriptor for `ListSwapsByRecipientResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listSwapsByRecipientResponseDescriptor = $convert.base64Decode(
    'ChxMaXN0U3dhcHNCeVJlY2lwaWVudFJlc3BvbnNlEh0KCnN3YXBzX2pzb24YASABKAlSCXN3YX'
    'BzSnNvbg==');

@$core.Deprecated('Use updateSwapL1TxidRequestDescriptor instead')
const UpdateSwapL1TxidRequest$json = {
  '1': 'UpdateSwapL1TxidRequest',
  '2': [
    {'1': 'swap_id', '3': 1, '4': 1, '5': 9, '10': 'swapId'},
    {'1': 'l1_txid_hex', '3': 2, '4': 1, '5': 9, '10': 'l1TxidHex'},
    {'1': 'confirmations', '3': 3, '4': 1, '5': 5, '10': 'confirmations'},
  ],
};

/// Descriptor for `UpdateSwapL1TxidRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateSwapL1TxidRequestDescriptor = $convert.base64Decode(
    'ChdVcGRhdGVTd2FwTDFUeGlkUmVxdWVzdBIXCgdzd2FwX2lkGAEgASgJUgZzd2FwSWQSHgoLbD'
    'FfdHhpZF9oZXgYAiABKAlSCWwxVHhpZEhleBIkCg1jb25maXJtYXRpb25zGAMgASgFUg1jb25m'
    'aXJtYXRpb25z');

@$core.Deprecated('Use updateSwapL1TxidResponseDescriptor instead')
const UpdateSwapL1TxidResponse$json = {
  '1': 'UpdateSwapL1TxidResponse',
};

/// Descriptor for `UpdateSwapL1TxidResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateSwapL1TxidResponseDescriptor = $convert.base64Decode(
    'ChhVcGRhdGVTd2FwTDFUeGlkUmVzcG9uc2U=');

@$core.Deprecated('Use reconstructSwapsRequestDescriptor instead')
const ReconstructSwapsRequest$json = {
  '1': 'ReconstructSwapsRequest',
};

/// Descriptor for `ReconstructSwapsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reconstructSwapsRequestDescriptor = $convert.base64Decode(
    'ChdSZWNvbnN0cnVjdFN3YXBzUmVxdWVzdA==');

@$core.Deprecated('Use reconstructSwapsResponseDescriptor instead')
const ReconstructSwapsResponse$json = {
  '1': 'ReconstructSwapsResponse',
  '2': [
    {'1': 'count', '3': 1, '4': 1, '5': 3, '10': 'count'},
  ],
};

/// Descriptor for `ReconstructSwapsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reconstructSwapsResponseDescriptor = $convert.base64Decode(
    'ChhSZWNvbnN0cnVjdFN3YXBzUmVzcG9uc2USFAoFY291bnQYASABKANSBWNvdW50');

const $core.Map<$core.String, $core.dynamic> CoinShiftServiceBase$json = {
  '1': 'CoinShiftService',
  '2': [
    {'1': 'GetBalance', '2': '.coinshift.v1.GetBalanceRequest', '3': '.coinshift.v1.GetBalanceResponse'},
    {'1': 'GetBlockCount', '2': '.coinshift.v1.GetBlockCountRequest', '3': '.coinshift.v1.GetBlockCountResponse'},
    {'1': 'Stop', '2': '.coinshift.v1.StopRequest', '3': '.coinshift.v1.StopResponse'},
    {'1': 'GetNewAddress', '2': '.coinshift.v1.GetNewAddressRequest', '3': '.coinshift.v1.GetNewAddressResponse'},
    {'1': 'Withdraw', '2': '.coinshift.v1.WithdrawRequest', '3': '.coinshift.v1.WithdrawResponse'},
    {'1': 'Transfer', '2': '.coinshift.v1.TransferRequest', '3': '.coinshift.v1.TransferResponse'},
    {'1': 'GetSidechainWealth', '2': '.coinshift.v1.GetSidechainWealthRequest', '3': '.coinshift.v1.GetSidechainWealthResponse'},
    {'1': 'CreateDeposit', '2': '.coinshift.v1.CreateDepositRequest', '3': '.coinshift.v1.CreateDepositResponse'},
    {'1': 'GetPendingWithdrawalBundle', '2': '.coinshift.v1.GetPendingWithdrawalBundleRequest', '3': '.coinshift.v1.GetPendingWithdrawalBundleResponse'},
    {'1': 'ConnectPeer', '2': '.coinshift.v1.ConnectPeerRequest', '3': '.coinshift.v1.ConnectPeerResponse'},
    {'1': 'ForgetPeer', '2': '.coinshift.v1.ForgetPeerRequest', '3': '.coinshift.v1.ForgetPeerResponse'},
    {'1': 'ListPeers', '2': '.coinshift.v1.ListPeersRequest', '3': '.coinshift.v1.ListPeersResponse'},
    {'1': 'Mine', '2': '.coinshift.v1.MineRequest', '3': '.coinshift.v1.MineResponse'},
    {'1': 'GetBlock', '2': '.coinshift.v1.GetBlockRequest', '3': '.coinshift.v1.GetBlockResponse'},
    {'1': 'GetBestMainchainBlockHash', '2': '.coinshift.v1.GetBestMainchainBlockHashRequest', '3': '.coinshift.v1.GetBestMainchainBlockHashResponse'},
    {'1': 'GetBestSidechainBlockHash', '2': '.coinshift.v1.GetBestSidechainBlockHashRequest', '3': '.coinshift.v1.GetBestSidechainBlockHashResponse'},
    {'1': 'GetBmmInclusions', '2': '.coinshift.v1.GetBmmInclusionsRequest', '3': '.coinshift.v1.GetBmmInclusionsResponse'},
    {'1': 'GetWalletUtxos', '2': '.coinshift.v1.GetWalletUtxosRequest', '3': '.coinshift.v1.GetWalletUtxosResponse'},
    {'1': 'ListUtxos', '2': '.coinshift.v1.ListUtxosRequest', '3': '.coinshift.v1.ListUtxosResponse'},
    {'1': 'RemoveFromMempool', '2': '.coinshift.v1.RemoveFromMempoolRequest', '3': '.coinshift.v1.RemoveFromMempoolResponse'},
    {'1': 'GetLatestFailedWithdrawalBundleHeight', '2': '.coinshift.v1.GetLatestFailedWithdrawalBundleHeightRequest', '3': '.coinshift.v1.GetLatestFailedWithdrawalBundleHeightResponse'},
    {'1': 'GenerateMnemonic', '2': '.coinshift.v1.GenerateMnemonicRequest', '3': '.coinshift.v1.GenerateMnemonicResponse'},
    {'1': 'SetSeedFromMnemonic', '2': '.coinshift.v1.SetSeedFromMnemonicRequest', '3': '.coinshift.v1.SetSeedFromMnemonicResponse'},
    {'1': 'CallRaw', '2': '.coinshift.v1.CallRawRequest', '3': '.coinshift.v1.CallRawResponse'},
    {'1': 'GetWalletAddresses', '2': '.coinshift.v1.GetWalletAddressesRequest', '3': '.coinshift.v1.GetWalletAddressesResponse'},
    {'1': 'OpenapiSchema', '2': '.coinshift.v1.OpenapiSchemaRequest', '3': '.coinshift.v1.OpenapiSchemaResponse'},
    {'1': 'CreateSwap', '2': '.coinshift.v1.CreateSwapRequest', '3': '.coinshift.v1.CreateSwapResponse'},
    {'1': 'ClaimSwap', '2': '.coinshift.v1.ClaimSwapRequest', '3': '.coinshift.v1.ClaimSwapResponse'},
    {'1': 'GetSwapStatus', '2': '.coinshift.v1.GetSwapStatusRequest', '3': '.coinshift.v1.GetSwapStatusResponse'},
    {'1': 'ListSwaps', '2': '.coinshift.v1.ListSwapsRequest', '3': '.coinshift.v1.ListSwapsResponse'},
    {'1': 'ListSwapsByRecipient', '2': '.coinshift.v1.ListSwapsByRecipientRequest', '3': '.coinshift.v1.ListSwapsByRecipientResponse'},
    {'1': 'UpdateSwapL1Txid', '2': '.coinshift.v1.UpdateSwapL1TxidRequest', '3': '.coinshift.v1.UpdateSwapL1TxidResponse'},
    {'1': 'ReconstructSwaps', '2': '.coinshift.v1.ReconstructSwapsRequest', '3': '.coinshift.v1.ReconstructSwapsResponse'},
  ],
};

@$core.Deprecated('Use coinShiftServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> CoinShiftServiceBase$messageJson = {
  '.coinshift.v1.GetBalanceRequest': GetBalanceRequest$json,
  '.coinshift.v1.GetBalanceResponse': GetBalanceResponse$json,
  '.coinshift.v1.GetBlockCountRequest': GetBlockCountRequest$json,
  '.coinshift.v1.GetBlockCountResponse': GetBlockCountResponse$json,
  '.coinshift.v1.StopRequest': StopRequest$json,
  '.coinshift.v1.StopResponse': StopResponse$json,
  '.coinshift.v1.GetNewAddressRequest': GetNewAddressRequest$json,
  '.coinshift.v1.GetNewAddressResponse': GetNewAddressResponse$json,
  '.coinshift.v1.WithdrawRequest': WithdrawRequest$json,
  '.coinshift.v1.WithdrawResponse': WithdrawResponse$json,
  '.coinshift.v1.TransferRequest': TransferRequest$json,
  '.coinshift.v1.TransferResponse': TransferResponse$json,
  '.coinshift.v1.GetSidechainWealthRequest': GetSidechainWealthRequest$json,
  '.coinshift.v1.GetSidechainWealthResponse': GetSidechainWealthResponse$json,
  '.coinshift.v1.CreateDepositRequest': CreateDepositRequest$json,
  '.coinshift.v1.CreateDepositResponse': CreateDepositResponse$json,
  '.coinshift.v1.GetPendingWithdrawalBundleRequest': GetPendingWithdrawalBundleRequest$json,
  '.coinshift.v1.GetPendingWithdrawalBundleResponse': GetPendingWithdrawalBundleResponse$json,
  '.coinshift.v1.ConnectPeerRequest': ConnectPeerRequest$json,
  '.coinshift.v1.ConnectPeerResponse': ConnectPeerResponse$json,
  '.coinshift.v1.ForgetPeerRequest': ForgetPeerRequest$json,
  '.coinshift.v1.ForgetPeerResponse': ForgetPeerResponse$json,
  '.coinshift.v1.ListPeersRequest': ListPeersRequest$json,
  '.coinshift.v1.ListPeersResponse': ListPeersResponse$json,
  '.coinshift.v1.MineRequest': MineRequest$json,
  '.coinshift.v1.MineResponse': MineResponse$json,
  '.coinshift.v1.GetBlockRequest': GetBlockRequest$json,
  '.coinshift.v1.GetBlockResponse': GetBlockResponse$json,
  '.coinshift.v1.GetBestMainchainBlockHashRequest': GetBestMainchainBlockHashRequest$json,
  '.coinshift.v1.GetBestMainchainBlockHashResponse': GetBestMainchainBlockHashResponse$json,
  '.coinshift.v1.GetBestSidechainBlockHashRequest': GetBestSidechainBlockHashRequest$json,
  '.coinshift.v1.GetBestSidechainBlockHashResponse': GetBestSidechainBlockHashResponse$json,
  '.coinshift.v1.GetBmmInclusionsRequest': GetBmmInclusionsRequest$json,
  '.coinshift.v1.GetBmmInclusionsResponse': GetBmmInclusionsResponse$json,
  '.coinshift.v1.GetWalletUtxosRequest': GetWalletUtxosRequest$json,
  '.coinshift.v1.GetWalletUtxosResponse': GetWalletUtxosResponse$json,
  '.coinshift.v1.ListUtxosRequest': ListUtxosRequest$json,
  '.coinshift.v1.ListUtxosResponse': ListUtxosResponse$json,
  '.coinshift.v1.RemoveFromMempoolRequest': RemoveFromMempoolRequest$json,
  '.coinshift.v1.RemoveFromMempoolResponse': RemoveFromMempoolResponse$json,
  '.coinshift.v1.GetLatestFailedWithdrawalBundleHeightRequest': GetLatestFailedWithdrawalBundleHeightRequest$json,
  '.coinshift.v1.GetLatestFailedWithdrawalBundleHeightResponse': GetLatestFailedWithdrawalBundleHeightResponse$json,
  '.coinshift.v1.GenerateMnemonicRequest': GenerateMnemonicRequest$json,
  '.coinshift.v1.GenerateMnemonicResponse': GenerateMnemonicResponse$json,
  '.coinshift.v1.SetSeedFromMnemonicRequest': SetSeedFromMnemonicRequest$json,
  '.coinshift.v1.SetSeedFromMnemonicResponse': SetSeedFromMnemonicResponse$json,
  '.coinshift.v1.CallRawRequest': CallRawRequest$json,
  '.coinshift.v1.CallRawResponse': CallRawResponse$json,
  '.coinshift.v1.GetWalletAddressesRequest': GetWalletAddressesRequest$json,
  '.coinshift.v1.GetWalletAddressesResponse': GetWalletAddressesResponse$json,
  '.coinshift.v1.OpenapiSchemaRequest': OpenapiSchemaRequest$json,
  '.coinshift.v1.OpenapiSchemaResponse': OpenapiSchemaResponse$json,
  '.coinshift.v1.CreateSwapRequest': CreateSwapRequest$json,
  '.coinshift.v1.CreateSwapResponse': CreateSwapResponse$json,
  '.coinshift.v1.ClaimSwapRequest': ClaimSwapRequest$json,
  '.coinshift.v1.ClaimSwapResponse': ClaimSwapResponse$json,
  '.coinshift.v1.GetSwapStatusRequest': GetSwapStatusRequest$json,
  '.coinshift.v1.GetSwapStatusResponse': GetSwapStatusResponse$json,
  '.coinshift.v1.ListSwapsRequest': ListSwapsRequest$json,
  '.coinshift.v1.ListSwapsResponse': ListSwapsResponse$json,
  '.coinshift.v1.ListSwapsByRecipientRequest': ListSwapsByRecipientRequest$json,
  '.coinshift.v1.ListSwapsByRecipientResponse': ListSwapsByRecipientResponse$json,
  '.coinshift.v1.UpdateSwapL1TxidRequest': UpdateSwapL1TxidRequest$json,
  '.coinshift.v1.UpdateSwapL1TxidResponse': UpdateSwapL1TxidResponse$json,
  '.coinshift.v1.ReconstructSwapsRequest': ReconstructSwapsRequest$json,
  '.coinshift.v1.ReconstructSwapsResponse': ReconstructSwapsResponse$json,
};

/// Descriptor for `CoinShiftService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List coinShiftServiceDescriptor = $convert.base64Decode(
    'ChBDb2luU2hpZnRTZXJ2aWNlEk8KCkdldEJhbGFuY2USHy5jb2luc2hpZnQudjEuR2V0QmFsYW'
    '5jZVJlcXVlc3QaIC5jb2luc2hpZnQudjEuR2V0QmFsYW5jZVJlc3BvbnNlElgKDUdldEJsb2Nr'
    'Q291bnQSIi5jb2luc2hpZnQudjEuR2V0QmxvY2tDb3VudFJlcXVlc3QaIy5jb2luc2hpZnQudj'
    'EuR2V0QmxvY2tDb3VudFJlc3BvbnNlEj0KBFN0b3ASGS5jb2luc2hpZnQudjEuU3RvcFJlcXVl'
    'c3QaGi5jb2luc2hpZnQudjEuU3RvcFJlc3BvbnNlElgKDUdldE5ld0FkZHJlc3MSIi5jb2luc2'
    'hpZnQudjEuR2V0TmV3QWRkcmVzc1JlcXVlc3QaIy5jb2luc2hpZnQudjEuR2V0TmV3QWRkcmVz'
    'c1Jlc3BvbnNlEkkKCFdpdGhkcmF3Eh0uY29pbnNoaWZ0LnYxLldpdGhkcmF3UmVxdWVzdBoeLm'
    'NvaW5zaGlmdC52MS5XaXRoZHJhd1Jlc3BvbnNlEkkKCFRyYW5zZmVyEh0uY29pbnNoaWZ0LnYx'
    'LlRyYW5zZmVyUmVxdWVzdBoeLmNvaW5zaGlmdC52MS5UcmFuc2ZlclJlc3BvbnNlEmcKEkdldF'
    'NpZGVjaGFpbldlYWx0aBInLmNvaW5zaGlmdC52MS5HZXRTaWRlY2hhaW5XZWFsdGhSZXF1ZXN0'
    'GiguY29pbnNoaWZ0LnYxLkdldFNpZGVjaGFpbldlYWx0aFJlc3BvbnNlElgKDUNyZWF0ZURlcG'
    '9zaXQSIi5jb2luc2hpZnQudjEuQ3JlYXRlRGVwb3NpdFJlcXVlc3QaIy5jb2luc2hpZnQudjEu'
    'Q3JlYXRlRGVwb3NpdFJlc3BvbnNlEn8KGkdldFBlbmRpbmdXaXRoZHJhd2FsQnVuZGxlEi8uY2'
    '9pbnNoaWZ0LnYxLkdldFBlbmRpbmdXaXRoZHJhd2FsQnVuZGxlUmVxdWVzdBowLmNvaW5zaGlm'
    'dC52MS5HZXRQZW5kaW5nV2l0aGRyYXdhbEJ1bmRsZVJlc3BvbnNlElIKC0Nvbm5lY3RQZWVyEi'
    'AuY29pbnNoaWZ0LnYxLkNvbm5lY3RQZWVyUmVxdWVzdBohLmNvaW5zaGlmdC52MS5Db25uZWN0'
    'UGVlclJlc3BvbnNlEk8KCkZvcmdldFBlZXISHy5jb2luc2hpZnQudjEuRm9yZ2V0UGVlclJlcX'
    'Vlc3QaIC5jb2luc2hpZnQudjEuRm9yZ2V0UGVlclJlc3BvbnNlEkwKCUxpc3RQZWVycxIeLmNv'
    'aW5zaGlmdC52MS5MaXN0UGVlcnNSZXF1ZXN0Gh8uY29pbnNoaWZ0LnYxLkxpc3RQZWVyc1Jlc3'
    'BvbnNlEj0KBE1pbmUSGS5jb2luc2hpZnQudjEuTWluZVJlcXVlc3QaGi5jb2luc2hpZnQudjEu'
    'TWluZVJlc3BvbnNlEkkKCEdldEJsb2NrEh0uY29pbnNoaWZ0LnYxLkdldEJsb2NrUmVxdWVzdB'
    'oeLmNvaW5zaGlmdC52MS5HZXRCbG9ja1Jlc3BvbnNlEnwKGUdldEJlc3RNYWluY2hhaW5CbG9j'
    'a0hhc2gSLi5jb2luc2hpZnQudjEuR2V0QmVzdE1haW5jaGFpbkJsb2NrSGFzaFJlcXVlc3QaLy'
    '5jb2luc2hpZnQudjEuR2V0QmVzdE1haW5jaGFpbkJsb2NrSGFzaFJlc3BvbnNlEnwKGUdldEJl'
    'c3RTaWRlY2hhaW5CbG9ja0hhc2gSLi5jb2luc2hpZnQudjEuR2V0QmVzdFNpZGVjaGFpbkJsb2'
    'NrSGFzaFJlcXVlc3QaLy5jb2luc2hpZnQudjEuR2V0QmVzdFNpZGVjaGFpbkJsb2NrSGFzaFJl'
    'c3BvbnNlEmEKEEdldEJtbUluY2x1c2lvbnMSJS5jb2luc2hpZnQudjEuR2V0Qm1tSW5jbHVzaW'
    '9uc1JlcXVlc3QaJi5jb2luc2hpZnQudjEuR2V0Qm1tSW5jbHVzaW9uc1Jlc3BvbnNlElsKDkdl'
    'dFdhbGxldFV0eG9zEiMuY29pbnNoaWZ0LnYxLkdldFdhbGxldFV0eG9zUmVxdWVzdBokLmNvaW'
    '5zaGlmdC52MS5HZXRXYWxsZXRVdHhvc1Jlc3BvbnNlEkwKCUxpc3RVdHhvcxIeLmNvaW5zaGlm'
    'dC52MS5MaXN0VXR4b3NSZXF1ZXN0Gh8uY29pbnNoaWZ0LnYxLkxpc3RVdHhvc1Jlc3BvbnNlEm'
    'QKEVJlbW92ZUZyb21NZW1wb29sEiYuY29pbnNoaWZ0LnYxLlJlbW92ZUZyb21NZW1wb29sUmVx'
    'dWVzdBonLmNvaW5zaGlmdC52MS5SZW1vdmVGcm9tTWVtcG9vbFJlc3BvbnNlEqABCiVHZXRMYX'
    'Rlc3RGYWlsZWRXaXRoZHJhd2FsQnVuZGxlSGVpZ2h0EjouY29pbnNoaWZ0LnYxLkdldExhdGVz'
    'dEZhaWxlZFdpdGhkcmF3YWxCdW5kbGVIZWlnaHRSZXF1ZXN0GjsuY29pbnNoaWZ0LnYxLkdldE'
    'xhdGVzdEZhaWxlZFdpdGhkcmF3YWxCdW5kbGVIZWlnaHRSZXNwb25zZRJhChBHZW5lcmF0ZU1u'
    'ZW1vbmljEiUuY29pbnNoaWZ0LnYxLkdlbmVyYXRlTW5lbW9uaWNSZXF1ZXN0GiYuY29pbnNoaW'
    'Z0LnYxLkdlbmVyYXRlTW5lbW9uaWNSZXNwb25zZRJqChNTZXRTZWVkRnJvbU1uZW1vbmljEigu'
    'Y29pbnNoaWZ0LnYxLlNldFNlZWRGcm9tTW5lbW9uaWNSZXF1ZXN0GikuY29pbnNoaWZ0LnYxLl'
    'NldFNlZWRGcm9tTW5lbW9uaWNSZXNwb25zZRJGCgdDYWxsUmF3EhwuY29pbnNoaWZ0LnYxLkNh'
    'bGxSYXdSZXF1ZXN0Gh0uY29pbnNoaWZ0LnYxLkNhbGxSYXdSZXNwb25zZRJnChJHZXRXYWxsZX'
    'RBZGRyZXNzZXMSJy5jb2luc2hpZnQudjEuR2V0V2FsbGV0QWRkcmVzc2VzUmVxdWVzdBooLmNv'
    'aW5zaGlmdC52MS5HZXRXYWxsZXRBZGRyZXNzZXNSZXNwb25zZRJYCg1PcGVuYXBpU2NoZW1hEi'
    'IuY29pbnNoaWZ0LnYxLk9wZW5hcGlTY2hlbWFSZXF1ZXN0GiMuY29pbnNoaWZ0LnYxLk9wZW5h'
    'cGlTY2hlbWFSZXNwb25zZRJPCgpDcmVhdGVTd2FwEh8uY29pbnNoaWZ0LnYxLkNyZWF0ZVN3YX'
    'BSZXF1ZXN0GiAuY29pbnNoaWZ0LnYxLkNyZWF0ZVN3YXBSZXNwb25zZRJMCglDbGFpbVN3YXAS'
    'Hi5jb2luc2hpZnQudjEuQ2xhaW1Td2FwUmVxdWVzdBofLmNvaW5zaGlmdC52MS5DbGFpbVN3YX'
    'BSZXNwb25zZRJYCg1HZXRTd2FwU3RhdHVzEiIuY29pbnNoaWZ0LnYxLkdldFN3YXBTdGF0dXNS'
    'ZXF1ZXN0GiMuY29pbnNoaWZ0LnYxLkdldFN3YXBTdGF0dXNSZXNwb25zZRJMCglMaXN0U3dhcH'
    'MSHi5jb2luc2hpZnQudjEuTGlzdFN3YXBzUmVxdWVzdBofLmNvaW5zaGlmdC52MS5MaXN0U3dh'
    'cHNSZXNwb25zZRJtChRMaXN0U3dhcHNCeVJlY2lwaWVudBIpLmNvaW5zaGlmdC52MS5MaXN0U3'
    'dhcHNCeVJlY2lwaWVudFJlcXVlc3QaKi5jb2luc2hpZnQudjEuTGlzdFN3YXBzQnlSZWNpcGll'
    'bnRSZXNwb25zZRJhChBVcGRhdGVTd2FwTDFUeGlkEiUuY29pbnNoaWZ0LnYxLlVwZGF0ZVN3YX'
    'BMMVR4aWRSZXF1ZXN0GiYuY29pbnNoaWZ0LnYxLlVwZGF0ZVN3YXBMMVR4aWRSZXNwb25zZRJh'
    'ChBSZWNvbnN0cnVjdFN3YXBzEiUuY29pbnNoaWZ0LnYxLlJlY29uc3RydWN0U3dhcHNSZXF1ZX'
    'N0GiYuY29pbnNoaWZ0LnYxLlJlY29uc3RydWN0U3dhcHNSZXNwb25zZQ==');

