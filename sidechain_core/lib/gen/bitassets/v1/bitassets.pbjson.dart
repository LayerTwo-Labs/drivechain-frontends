//
//  Generated code. Do not modify.
//  source: bitassets/v1/bitassets.proto
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
final $typed_data.Uint8List getBalanceRequestDescriptor = $convert.base64Decode('ChFHZXRCYWxhbmNlUmVxdWVzdA==');

@$core.Deprecated('Use getBalanceResponseDescriptor instead')
const GetBalanceResponse$json = {
  '1': 'GetBalanceResponse',
  '2': [
    {'1': 'total_sats', '3': 1, '4': 1, '5': 3, '10': 'totalSats'},
    {'1': 'available_sats', '3': 2, '4': 1, '5': 3, '10': 'availableSats'},
  ],
};

/// Descriptor for `GetBalanceResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBalanceResponseDescriptor =
    $convert.base64Decode('ChJHZXRCYWxhbmNlUmVzcG9uc2USHQoKdG90YWxfc2F0cxgBIAEoA1IJdG90YWxTYXRzEiUKDm'
        'F2YWlsYWJsZV9zYXRzGAIgASgDUg1hdmFpbGFibGVTYXRz');

@$core.Deprecated('Use getBlockCountRequestDescriptor instead')
const GetBlockCountRequest$json = {
  '1': 'GetBlockCountRequest',
};

/// Descriptor for `GetBlockCountRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBlockCountRequestDescriptor = $convert.base64Decode('ChRHZXRCbG9ja0NvdW50UmVxdWVzdA==');

@$core.Deprecated('Use getBlockCountResponseDescriptor instead')
const GetBlockCountResponse$json = {
  '1': 'GetBlockCountResponse',
  '2': [
    {'1': 'count', '3': 1, '4': 1, '5': 3, '10': 'count'},
  ],
};

/// Descriptor for `GetBlockCountResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBlockCountResponseDescriptor =
    $convert.base64Decode('ChVHZXRCbG9ja0NvdW50UmVzcG9uc2USFAoFY291bnQYASABKANSBWNvdW50');

@$core.Deprecated('Use stopRequestDescriptor instead')
const StopRequest$json = {
  '1': 'StopRequest',
};

/// Descriptor for `StopRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List stopRequestDescriptor = $convert.base64Decode('CgtTdG9wUmVxdWVzdA==');

@$core.Deprecated('Use stopResponseDescriptor instead')
const StopResponse$json = {
  '1': 'StopResponse',
};

/// Descriptor for `StopResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List stopResponseDescriptor = $convert.base64Decode('CgxTdG9wUmVzcG9uc2U=');

@$core.Deprecated('Use getNewAddressRequestDescriptor instead')
const GetNewAddressRequest$json = {
  '1': 'GetNewAddressRequest',
};

/// Descriptor for `GetNewAddressRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNewAddressRequestDescriptor = $convert.base64Decode('ChRHZXROZXdBZGRyZXNzUmVxdWVzdA==');

@$core.Deprecated('Use getNewAddressResponseDescriptor instead')
const GetNewAddressResponse$json = {
  '1': 'GetNewAddressResponse',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
  ],
};

/// Descriptor for `GetNewAddressResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNewAddressResponseDescriptor =
    $convert.base64Decode('ChVHZXROZXdBZGRyZXNzUmVzcG9uc2USGAoHYWRkcmVzcxgBIAEoCVIHYWRkcmVzcw==');

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
final $typed_data.Uint8List withdrawRequestDescriptor =
    $convert.base64Decode('Cg9XaXRoZHJhd1JlcXVlc3QSGAoHYWRkcmVzcxgBIAEoCVIHYWRkcmVzcxIfCgthbW91bnRfc2'
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
final $typed_data.Uint8List withdrawResponseDescriptor =
    $convert.base64Decode('ChBXaXRoZHJhd1Jlc3BvbnNlEhIKBHR4aWQYASABKAlSBHR4aWQ=');

@$core.Deprecated('Use transferRequestDescriptor instead')
const TransferRequest$json = {
  '1': 'TransferRequest',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'amount_sats', '3': 2, '4': 1, '5': 3, '10': 'amountSats'},
    {'1': 'fee_sats', '3': 3, '4': 1, '5': 3, '10': 'feeSats'},
    {'1': 'memo', '3': 4, '4': 1, '5': 9, '9': 0, '10': 'memo', '17': true},
  ],
  '8': [
    {'1': '_memo'},
  ],
};

/// Descriptor for `TransferRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transferRequestDescriptor =
    $convert.base64Decode('Cg9UcmFuc2ZlclJlcXVlc3QSGAoHYWRkcmVzcxgBIAEoCVIHYWRkcmVzcxIfCgthbW91bnRfc2'
        'F0cxgCIAEoA1IKYW1vdW50U2F0cxIZCghmZWVfc2F0cxgDIAEoA1IHZmVlU2F0cxIXCgRtZW1v'
        'GAQgASgJSABSBG1lbW+IAQFCBwoFX21lbW8=');

@$core.Deprecated('Use transferResponseDescriptor instead')
const TransferResponse$json = {
  '1': 'TransferResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `TransferResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transferResponseDescriptor =
    $convert.base64Decode('ChBUcmFuc2ZlclJlc3BvbnNlEhIKBHR4aWQYASABKAlSBHR4aWQ=');

@$core.Deprecated('Use getSidechainWealthRequestDescriptor instead')
const GetSidechainWealthRequest$json = {
  '1': 'GetSidechainWealthRequest',
};

/// Descriptor for `GetSidechainWealthRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSidechainWealthRequestDescriptor =
    $convert.base64Decode('ChlHZXRTaWRlY2hhaW5XZWFsdGhSZXF1ZXN0');

@$core.Deprecated('Use getSidechainWealthResponseDescriptor instead')
const GetSidechainWealthResponse$json = {
  '1': 'GetSidechainWealthResponse',
  '2': [
    {'1': 'sats', '3': 1, '4': 1, '5': 3, '10': 'sats'},
  ],
};

/// Descriptor for `GetSidechainWealthResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSidechainWealthResponseDescriptor =
    $convert.base64Decode('ChpHZXRTaWRlY2hhaW5XZWFsdGhSZXNwb25zZRISCgRzYXRzGAEgASgDUgRzYXRz');

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
final $typed_data.Uint8List createDepositRequestDescriptor =
    $convert.base64Decode('ChRDcmVhdGVEZXBvc2l0UmVxdWVzdBIYCgdhZGRyZXNzGAEgASgJUgdhZGRyZXNzEh0KCnZhbH'
        'VlX3NhdHMYAiABKANSCXZhbHVlU2F0cxIZCghmZWVfc2F0cxgDIAEoA1IHZmVlU2F0cw==');

@$core.Deprecated('Use createDepositResponseDescriptor instead')
const CreateDepositResponse$json = {
  '1': 'CreateDepositResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `CreateDepositResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createDepositResponseDescriptor =
    $convert.base64Decode('ChVDcmVhdGVEZXBvc2l0UmVzcG9uc2USEgoEdHhpZBgBIAEoCVIEdHhpZA==');

@$core.Deprecated('Use getPendingWithdrawalBundleRequestDescriptor instead')
const GetPendingWithdrawalBundleRequest$json = {
  '1': 'GetPendingWithdrawalBundleRequest',
};

/// Descriptor for `GetPendingWithdrawalBundleRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPendingWithdrawalBundleRequestDescriptor =
    $convert.base64Decode('CiFHZXRQZW5kaW5nV2l0aGRyYXdhbEJ1bmRsZVJlcXVlc3Q=');

@$core.Deprecated('Use getPendingWithdrawalBundleResponseDescriptor instead')
const GetPendingWithdrawalBundleResponse$json = {
  '1': 'GetPendingWithdrawalBundleResponse',
  '2': [
    {'1': 'bundle_json', '3': 1, '4': 1, '5': 9, '10': 'bundleJson'},
  ],
};

/// Descriptor for `GetPendingWithdrawalBundleResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPendingWithdrawalBundleResponseDescriptor =
    $convert.base64Decode('CiJHZXRQZW5kaW5nV2l0aGRyYXdhbEJ1bmRsZVJlc3BvbnNlEh8KC2J1bmRsZV9qc29uGAEgAS'
        'gJUgpidW5kbGVKc29u');

@$core.Deprecated('Use connectPeerRequestDescriptor instead')
const ConnectPeerRequest$json = {
  '1': 'ConnectPeerRequest',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
  ],
};

/// Descriptor for `ConnectPeerRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List connectPeerRequestDescriptor =
    $convert.base64Decode('ChJDb25uZWN0UGVlclJlcXVlc3QSGAoHYWRkcmVzcxgBIAEoCVIHYWRkcmVzcw==');

@$core.Deprecated('Use connectPeerResponseDescriptor instead')
const ConnectPeerResponse$json = {
  '1': 'ConnectPeerResponse',
};

/// Descriptor for `ConnectPeerResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List connectPeerResponseDescriptor = $convert.base64Decode('ChNDb25uZWN0UGVlclJlc3BvbnNl');

@$core.Deprecated('Use forgetPeerRequestDescriptor instead')
const ForgetPeerRequest$json = {
  '1': 'ForgetPeerRequest',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
  ],
};

/// Descriptor for `ForgetPeerRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List forgetPeerRequestDescriptor =
    $convert.base64Decode('ChFGb3JnZXRQZWVyUmVxdWVzdBIYCgdhZGRyZXNzGAEgASgJUgdhZGRyZXNz');

@$core.Deprecated('Use forgetPeerResponseDescriptor instead')
const ForgetPeerResponse$json = {
  '1': 'ForgetPeerResponse',
};

/// Descriptor for `ForgetPeerResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List forgetPeerResponseDescriptor = $convert.base64Decode('ChJGb3JnZXRQZWVyUmVzcG9uc2U=');

@$core.Deprecated('Use listPeersRequestDescriptor instead')
const ListPeersRequest$json = {
  '1': 'ListPeersRequest',
};

/// Descriptor for `ListPeersRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listPeersRequestDescriptor = $convert.base64Decode('ChBMaXN0UGVlcnNSZXF1ZXN0');

@$core.Deprecated('Use listPeersResponseDescriptor instead')
const ListPeersResponse$json = {
  '1': 'ListPeersResponse',
  '2': [
    {'1': 'peers_json', '3': 1, '4': 1, '5': 9, '10': 'peersJson'},
  ],
};

/// Descriptor for `ListPeersResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listPeersResponseDescriptor =
    $convert.base64Decode('ChFMaXN0UGVlcnNSZXNwb25zZRIdCgpwZWVyc19qc29uGAEgASgJUglwZWVyc0pzb24=');

@$core.Deprecated('Use mineRequestDescriptor instead')
const MineRequest$json = {
  '1': 'MineRequest',
  '2': [
    {'1': 'fee_sats', '3': 1, '4': 1, '5': 3, '10': 'feeSats'},
  ],
};

/// Descriptor for `MineRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mineRequestDescriptor =
    $convert.base64Decode('CgtNaW5lUmVxdWVzdBIZCghmZWVfc2F0cxgBIAEoA1IHZmVlU2F0cw==');

@$core.Deprecated('Use mineResponseDescriptor instead')
const MineResponse$json = {
  '1': 'MineResponse',
  '2': [
    {'1': 'bmm_result_json', '3': 1, '4': 1, '5': 9, '10': 'bmmResultJson'},
  ],
};

/// Descriptor for `MineResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mineResponseDescriptor =
    $convert.base64Decode('CgxNaW5lUmVzcG9uc2USJgoPYm1tX3Jlc3VsdF9qc29uGAEgASgJUg1ibW1SZXN1bHRKc29u');

@$core.Deprecated('Use getBlockRequestDescriptor instead')
const GetBlockRequest$json = {
  '1': 'GetBlockRequest',
  '2': [
    {'1': 'hash', '3': 1, '4': 1, '5': 9, '10': 'hash'},
  ],
};

/// Descriptor for `GetBlockRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBlockRequestDescriptor =
    $convert.base64Decode('Cg9HZXRCbG9ja1JlcXVlc3QSEgoEaGFzaBgBIAEoCVIEaGFzaA==');

@$core.Deprecated('Use getBlockResponseDescriptor instead')
const GetBlockResponse$json = {
  '1': 'GetBlockResponse',
  '2': [
    {'1': 'block_json', '3': 1, '4': 1, '5': 9, '10': 'blockJson'},
  ],
};

/// Descriptor for `GetBlockResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBlockResponseDescriptor =
    $convert.base64Decode('ChBHZXRCbG9ja1Jlc3BvbnNlEh0KCmJsb2NrX2pzb24YASABKAlSCWJsb2NrSnNvbg==');

@$core.Deprecated('Use getBestMainchainBlockHashRequestDescriptor instead')
const GetBestMainchainBlockHashRequest$json = {
  '1': 'GetBestMainchainBlockHashRequest',
};

/// Descriptor for `GetBestMainchainBlockHashRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBestMainchainBlockHashRequestDescriptor =
    $convert.base64Decode('CiBHZXRCZXN0TWFpbmNoYWluQmxvY2tIYXNoUmVxdWVzdA==');

@$core.Deprecated('Use getBestMainchainBlockHashResponseDescriptor instead')
const GetBestMainchainBlockHashResponse$json = {
  '1': 'GetBestMainchainBlockHashResponse',
  '2': [
    {'1': 'hash', '3': 1, '4': 1, '5': 9, '10': 'hash'},
  ],
};

/// Descriptor for `GetBestMainchainBlockHashResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBestMainchainBlockHashResponseDescriptor =
    $convert.base64Decode('CiFHZXRCZXN0TWFpbmNoYWluQmxvY2tIYXNoUmVzcG9uc2USEgoEaGFzaBgBIAEoCVIEaGFzaA'
        '==');

@$core.Deprecated('Use getBestSidechainBlockHashRequestDescriptor instead')
const GetBestSidechainBlockHashRequest$json = {
  '1': 'GetBestSidechainBlockHashRequest',
};

/// Descriptor for `GetBestSidechainBlockHashRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBestSidechainBlockHashRequestDescriptor =
    $convert.base64Decode('CiBHZXRCZXN0U2lkZWNoYWluQmxvY2tIYXNoUmVxdWVzdA==');

@$core.Deprecated('Use getBestSidechainBlockHashResponseDescriptor instead')
const GetBestSidechainBlockHashResponse$json = {
  '1': 'GetBestSidechainBlockHashResponse',
  '2': [
    {'1': 'hash', '3': 1, '4': 1, '5': 9, '10': 'hash'},
  ],
};

/// Descriptor for `GetBestSidechainBlockHashResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBestSidechainBlockHashResponseDescriptor =
    $convert.base64Decode('CiFHZXRCZXN0U2lkZWNoYWluQmxvY2tIYXNoUmVzcG9uc2USEgoEaGFzaBgBIAEoCVIEaGFzaA'
        '==');

@$core.Deprecated('Use getBmmInclusionsRequestDescriptor instead')
const GetBmmInclusionsRequest$json = {
  '1': 'GetBmmInclusionsRequest',
  '2': [
    {'1': 'block_hash', '3': 1, '4': 1, '5': 9, '10': 'blockHash'},
  ],
};

/// Descriptor for `GetBmmInclusionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBmmInclusionsRequestDescriptor =
    $convert.base64Decode('ChdHZXRCbW1JbmNsdXNpb25zUmVxdWVzdBIdCgpibG9ja19oYXNoGAEgASgJUglibG9ja0hhc2'
        'g=');

@$core.Deprecated('Use getBmmInclusionsResponseDescriptor instead')
const GetBmmInclusionsResponse$json = {
  '1': 'GetBmmInclusionsResponse',
  '2': [
    {'1': 'inclusions', '3': 1, '4': 1, '5': 9, '10': 'inclusions'},
  ],
};

/// Descriptor for `GetBmmInclusionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBmmInclusionsResponseDescriptor =
    $convert.base64Decode('ChhHZXRCbW1JbmNsdXNpb25zUmVzcG9uc2USHgoKaW5jbHVzaW9ucxgBIAEoCVIKaW5jbHVzaW'
        '9ucw==');

@$core.Deprecated('Use getWalletUtxosRequestDescriptor instead')
const GetWalletUtxosRequest$json = {
  '1': 'GetWalletUtxosRequest',
};

/// Descriptor for `GetWalletUtxosRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getWalletUtxosRequestDescriptor = $convert.base64Decode('ChVHZXRXYWxsZXRVdHhvc1JlcXVlc3Q=');

@$core.Deprecated('Use getWalletUtxosResponseDescriptor instead')
const GetWalletUtxosResponse$json = {
  '1': 'GetWalletUtxosResponse',
  '2': [
    {'1': 'utxos_json', '3': 1, '4': 1, '5': 9, '10': 'utxosJson'},
  ],
};

/// Descriptor for `GetWalletUtxosResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getWalletUtxosResponseDescriptor =
    $convert.base64Decode('ChZHZXRXYWxsZXRVdHhvc1Jlc3BvbnNlEh0KCnV0eG9zX2pzb24YASABKAlSCXV0eG9zSnNvbg'
        '==');

@$core.Deprecated('Use listUtxosRequestDescriptor instead')
const ListUtxosRequest$json = {
  '1': 'ListUtxosRequest',
};

/// Descriptor for `ListUtxosRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listUtxosRequestDescriptor = $convert.base64Decode('ChBMaXN0VXR4b3NSZXF1ZXN0');

@$core.Deprecated('Use listUtxosResponseDescriptor instead')
const ListUtxosResponse$json = {
  '1': 'ListUtxosResponse',
  '2': [
    {'1': 'utxos_json', '3': 1, '4': 1, '5': 9, '10': 'utxosJson'},
  ],
};

/// Descriptor for `ListUtxosResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listUtxosResponseDescriptor =
    $convert.base64Decode('ChFMaXN0VXR4b3NSZXNwb25zZRIdCgp1dHhvc19qc29uGAEgASgJUgl1dHhvc0pzb24=');

@$core.Deprecated('Use removeFromMempoolRequestDescriptor instead')
const RemoveFromMempoolRequest$json = {
  '1': 'RemoveFromMempoolRequest',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `RemoveFromMempoolRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeFromMempoolRequestDescriptor =
    $convert.base64Decode('ChhSZW1vdmVGcm9tTWVtcG9vbFJlcXVlc3QSEgoEdHhpZBgBIAEoCVIEdHhpZA==');

@$core.Deprecated('Use removeFromMempoolResponseDescriptor instead')
const RemoveFromMempoolResponse$json = {
  '1': 'RemoveFromMempoolResponse',
};

/// Descriptor for `RemoveFromMempoolResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeFromMempoolResponseDescriptor =
    $convert.base64Decode('ChlSZW1vdmVGcm9tTWVtcG9vbFJlc3BvbnNl');

@$core.Deprecated('Use getLatestFailedWithdrawalBundleHeightRequestDescriptor instead')
const GetLatestFailedWithdrawalBundleHeightRequest$json = {
  '1': 'GetLatestFailedWithdrawalBundleHeightRequest',
};

/// Descriptor for `GetLatestFailedWithdrawalBundleHeightRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getLatestFailedWithdrawalBundleHeightRequestDescriptor =
    $convert.base64Decode('CixHZXRMYXRlc3RGYWlsZWRXaXRoZHJhd2FsQnVuZGxlSGVpZ2h0UmVxdWVzdA==');

@$core.Deprecated('Use getLatestFailedWithdrawalBundleHeightResponseDescriptor instead')
const GetLatestFailedWithdrawalBundleHeightResponse$json = {
  '1': 'GetLatestFailedWithdrawalBundleHeightResponse',
  '2': [
    {'1': 'height', '3': 1, '4': 1, '5': 3, '10': 'height'},
  ],
};

/// Descriptor for `GetLatestFailedWithdrawalBundleHeightResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getLatestFailedWithdrawalBundleHeightResponseDescriptor =
    $convert.base64Decode('Ci1HZXRMYXRlc3RGYWlsZWRXaXRoZHJhd2FsQnVuZGxlSGVpZ2h0UmVzcG9uc2USFgoGaGVpZ2'
        'h0GAEgASgDUgZoZWlnaHQ=');

@$core.Deprecated('Use generateMnemonicRequestDescriptor instead')
const GenerateMnemonicRequest$json = {
  '1': 'GenerateMnemonicRequest',
};

/// Descriptor for `GenerateMnemonicRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List generateMnemonicRequestDescriptor =
    $convert.base64Decode('ChdHZW5lcmF0ZU1uZW1vbmljUmVxdWVzdA==');

@$core.Deprecated('Use generateMnemonicResponseDescriptor instead')
const GenerateMnemonicResponse$json = {
  '1': 'GenerateMnemonicResponse',
  '2': [
    {'1': 'mnemonic', '3': 1, '4': 1, '5': 9, '10': 'mnemonic'},
  ],
};

/// Descriptor for `GenerateMnemonicResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List generateMnemonicResponseDescriptor =
    $convert.base64Decode('ChhHZW5lcmF0ZU1uZW1vbmljUmVzcG9uc2USGgoIbW5lbW9uaWMYASABKAlSCG1uZW1vbmlj');

@$core.Deprecated('Use setSeedFromMnemonicRequestDescriptor instead')
const SetSeedFromMnemonicRequest$json = {
  '1': 'SetSeedFromMnemonicRequest',
  '2': [
    {'1': 'mnemonic', '3': 1, '4': 1, '5': 9, '10': 'mnemonic'},
  ],
};

/// Descriptor for `SetSeedFromMnemonicRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setSeedFromMnemonicRequestDescriptor =
    $convert.base64Decode('ChpTZXRTZWVkRnJvbU1uZW1vbmljUmVxdWVzdBIaCghtbmVtb25pYxgBIAEoCVIIbW5lbW9uaW'
        'M=');

@$core.Deprecated('Use setSeedFromMnemonicResponseDescriptor instead')
const SetSeedFromMnemonicResponse$json = {
  '1': 'SetSeedFromMnemonicResponse',
};

/// Descriptor for `SetSeedFromMnemonicResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setSeedFromMnemonicResponseDescriptor =
    $convert.base64Decode('ChtTZXRTZWVkRnJvbU1uZW1vbmljUmVzcG9uc2U=');

@$core.Deprecated('Use callRawRequestDescriptor instead')
const CallRawRequest$json = {
  '1': 'CallRawRequest',
  '2': [
    {'1': 'method', '3': 1, '4': 1, '5': 9, '10': 'method'},
    {'1': 'params_json', '3': 2, '4': 1, '5': 9, '10': 'paramsJson'},
  ],
};

/// Descriptor for `CallRawRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List callRawRequestDescriptor =
    $convert.base64Decode('Cg5DYWxsUmF3UmVxdWVzdBIWCgZtZXRob2QYASABKAlSBm1ldGhvZBIfCgtwYXJhbXNfanNvbh'
        'gCIAEoCVIKcGFyYW1zSnNvbg==');

@$core.Deprecated('Use callRawResponseDescriptor instead')
const CallRawResponse$json = {
  '1': 'CallRawResponse',
  '2': [
    {'1': 'result_json', '3': 1, '4': 1, '5': 9, '10': 'resultJson'},
  ],
};

/// Descriptor for `CallRawResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List callRawResponseDescriptor =
    $convert.base64Decode('Cg9DYWxsUmF3UmVzcG9uc2USHwoLcmVzdWx0X2pzb24YASABKAlSCnJlc3VsdEpzb24=');

@$core.Deprecated('Use getBitAssetDataRequestDescriptor instead')
const GetBitAssetDataRequest$json = {
  '1': 'GetBitAssetDataRequest',
  '2': [
    {'1': 'asset_id', '3': 1, '4': 1, '5': 9, '10': 'assetId'},
  ],
};

/// Descriptor for `GetBitAssetDataRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBitAssetDataRequestDescriptor =
    $convert.base64Decode('ChZHZXRCaXRBc3NldERhdGFSZXF1ZXN0EhkKCGFzc2V0X2lkGAEgASgJUgdhc3NldElk');

@$core.Deprecated('Use getBitAssetDataResponseDescriptor instead')
const GetBitAssetDataResponse$json = {
  '1': 'GetBitAssetDataResponse',
  '2': [
    {'1': 'data_json', '3': 1, '4': 1, '5': 9, '10': 'dataJson'},
  ],
};

/// Descriptor for `GetBitAssetDataResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBitAssetDataResponseDescriptor =
    $convert.base64Decode('ChdHZXRCaXRBc3NldERhdGFSZXNwb25zZRIbCglkYXRhX2pzb24YASABKAlSCGRhdGFKc29u');

@$core.Deprecated('Use listBitAssetsRequestDescriptor instead')
const ListBitAssetsRequest$json = {
  '1': 'ListBitAssetsRequest',
};

/// Descriptor for `ListBitAssetsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listBitAssetsRequestDescriptor = $convert.base64Decode('ChRMaXN0Qml0QXNzZXRzUmVxdWVzdA==');

@$core.Deprecated('Use listBitAssetsResponseDescriptor instead')
const ListBitAssetsResponse$json = {
  '1': 'ListBitAssetsResponse',
  '2': [
    {'1': 'bitassets_json', '3': 1, '4': 1, '5': 9, '10': 'bitassetsJson'},
  ],
};

/// Descriptor for `ListBitAssetsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listBitAssetsResponseDescriptor =
    $convert.base64Decode('ChVMaXN0Qml0QXNzZXRzUmVzcG9uc2USJQoOYml0YXNzZXRzX2pzb24YASABKAlSDWJpdGFzc2'
        'V0c0pzb24=');

@$core.Deprecated('Use registerBitAssetRequestDescriptor instead')
const RegisterBitAssetRequest$json = {
  '1': 'RegisterBitAssetRequest',
  '2': [
    {'1': 'plaintext_name', '3': 1, '4': 1, '5': 9, '10': 'plaintextName'},
    {'1': 'initial_supply', '3': 2, '4': 1, '5': 3, '10': 'initialSupply'},
    {'1': 'data_json', '3': 3, '4': 1, '5': 9, '10': 'dataJson'},
  ],
};

/// Descriptor for `RegisterBitAssetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerBitAssetRequestDescriptor =
    $convert.base64Decode('ChdSZWdpc3RlckJpdEFzc2V0UmVxdWVzdBIlCg5wbGFpbnRleHRfbmFtZRgBIAEoCVINcGxhaW'
        '50ZXh0TmFtZRIlCg5pbml0aWFsX3N1cHBseRgCIAEoA1INaW5pdGlhbFN1cHBseRIbCglkYXRh'
        'X2pzb24YAyABKAlSCGRhdGFKc29u');

@$core.Deprecated('Use registerBitAssetResponseDescriptor instead')
const RegisterBitAssetResponse$json = {
  '1': 'RegisterBitAssetResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `RegisterBitAssetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerBitAssetResponseDescriptor =
    $convert.base64Decode('ChhSZWdpc3RlckJpdEFzc2V0UmVzcG9uc2USEgoEdHhpZBgBIAEoCVIEdHhpZA==');

@$core.Deprecated('Use reserveBitAssetRequestDescriptor instead')
const ReserveBitAssetRequest$json = {
  '1': 'ReserveBitAssetRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `ReserveBitAssetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reserveBitAssetRequestDescriptor =
    $convert.base64Decode('ChZSZXNlcnZlQml0QXNzZXRSZXF1ZXN0EhIKBG5hbWUYASABKAlSBG5hbWU=');

@$core.Deprecated('Use reserveBitAssetResponseDescriptor instead')
const ReserveBitAssetResponse$json = {
  '1': 'ReserveBitAssetResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `ReserveBitAssetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reserveBitAssetResponseDescriptor =
    $convert.base64Decode('ChdSZXNlcnZlQml0QXNzZXRSZXNwb25zZRISCgR0eGlkGAEgASgJUgR0eGlk');

@$core.Deprecated('Use transferBitAssetRequestDescriptor instead')
const TransferBitAssetRequest$json = {
  '1': 'TransferBitAssetRequest',
  '2': [
    {'1': 'asset_id', '3': 1, '4': 1, '5': 9, '10': 'assetId'},
    {'1': 'dest', '3': 2, '4': 1, '5': 9, '10': 'dest'},
    {'1': 'amount', '3': 3, '4': 1, '5': 3, '10': 'amount'},
    {'1': 'fee_sats', '3': 4, '4': 1, '5': 3, '10': 'feeSats'},
  ],
};

/// Descriptor for `TransferBitAssetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transferBitAssetRequestDescriptor =
    $convert.base64Decode('ChdUcmFuc2ZlckJpdEFzc2V0UmVxdWVzdBIZCghhc3NldF9pZBgBIAEoCVIHYXNzZXRJZBISCg'
        'RkZXN0GAIgASgJUgRkZXN0EhYKBmFtb3VudBgDIAEoA1IGYW1vdW50EhkKCGZlZV9zYXRzGAQg'
        'ASgDUgdmZWVTYXRz');

@$core.Deprecated('Use transferBitAssetResponseDescriptor instead')
const TransferBitAssetResponse$json = {
  '1': 'TransferBitAssetResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `TransferBitAssetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transferBitAssetResponseDescriptor =
    $convert.base64Decode('ChhUcmFuc2ZlckJpdEFzc2V0UmVzcG9uc2USEgoEdHhpZBgBIAEoCVIEdHhpZA==');

@$core.Deprecated('Use getNewEncryptionKeyRequestDescriptor instead')
const GetNewEncryptionKeyRequest$json = {
  '1': 'GetNewEncryptionKeyRequest',
};

/// Descriptor for `GetNewEncryptionKeyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNewEncryptionKeyRequestDescriptor =
    $convert.base64Decode('ChpHZXROZXdFbmNyeXB0aW9uS2V5UmVxdWVzdA==');

@$core.Deprecated('Use getNewEncryptionKeyResponseDescriptor instead')
const GetNewEncryptionKeyResponse$json = {
  '1': 'GetNewEncryptionKeyResponse',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
  ],
};

/// Descriptor for `GetNewEncryptionKeyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNewEncryptionKeyResponseDescriptor =
    $convert.base64Decode('ChtHZXROZXdFbmNyeXB0aW9uS2V5UmVzcG9uc2USEAoDa2V5GAEgASgJUgNrZXk=');

@$core.Deprecated('Use getNewVerifyingKeyRequestDescriptor instead')
const GetNewVerifyingKeyRequest$json = {
  '1': 'GetNewVerifyingKeyRequest',
};

/// Descriptor for `GetNewVerifyingKeyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNewVerifyingKeyRequestDescriptor =
    $convert.base64Decode('ChlHZXROZXdWZXJpZnlpbmdLZXlSZXF1ZXN0');

@$core.Deprecated('Use getNewVerifyingKeyResponseDescriptor instead')
const GetNewVerifyingKeyResponse$json = {
  '1': 'GetNewVerifyingKeyResponse',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
  ],
};

/// Descriptor for `GetNewVerifyingKeyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNewVerifyingKeyResponseDescriptor =
    $convert.base64Decode('ChpHZXROZXdWZXJpZnlpbmdLZXlSZXNwb25zZRIQCgNrZXkYASABKAlSA2tleQ==');

@$core.Deprecated('Use decryptMsgRequestDescriptor instead')
const DecryptMsgRequest$json = {
  '1': 'DecryptMsgRequest',
  '2': [
    {'1': 'ciphertext', '3': 1, '4': 1, '5': 9, '10': 'ciphertext'},
    {'1': 'encryption_pubkey', '3': 2, '4': 1, '5': 9, '10': 'encryptionPubkey'},
  ],
};

/// Descriptor for `DecryptMsgRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List decryptMsgRequestDescriptor =
    $convert.base64Decode('ChFEZWNyeXB0TXNnUmVxdWVzdBIeCgpjaXBoZXJ0ZXh0GAEgASgJUgpjaXBoZXJ0ZXh0EisKEW'
        'VuY3J5cHRpb25fcHVia2V5GAIgASgJUhBlbmNyeXB0aW9uUHVia2V5');

@$core.Deprecated('Use decryptMsgResponseDescriptor instead')
const DecryptMsgResponse$json = {
  '1': 'DecryptMsgResponse',
  '2': [
    {'1': 'plaintext', '3': 1, '4': 1, '5': 9, '10': 'plaintext'},
  ],
};

/// Descriptor for `DecryptMsgResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List decryptMsgResponseDescriptor =
    $convert.base64Decode('ChJEZWNyeXB0TXNnUmVzcG9uc2USHAoJcGxhaW50ZXh0GAEgASgJUglwbGFpbnRleHQ=');

@$core.Deprecated('Use encryptMsgRequestDescriptor instead')
const EncryptMsgRequest$json = {
  '1': 'EncryptMsgRequest',
  '2': [
    {'1': 'msg', '3': 1, '4': 1, '5': 9, '10': 'msg'},
    {'1': 'encryption_pubkey', '3': 2, '4': 1, '5': 9, '10': 'encryptionPubkey'},
  ],
};

/// Descriptor for `EncryptMsgRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List encryptMsgRequestDescriptor =
    $convert.base64Decode('ChFFbmNyeXB0TXNnUmVxdWVzdBIQCgNtc2cYASABKAlSA21zZxIrChFlbmNyeXB0aW9uX3B1Ym'
        'tleRgCIAEoCVIQZW5jcnlwdGlvblB1YmtleQ==');

@$core.Deprecated('Use encryptMsgResponseDescriptor instead')
const EncryptMsgResponse$json = {
  '1': 'EncryptMsgResponse',
  '2': [
    {'1': 'ciphertext', '3': 1, '4': 1, '5': 9, '10': 'ciphertext'},
  ],
};

/// Descriptor for `EncryptMsgResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List encryptMsgResponseDescriptor =
    $convert.base64Decode('ChJFbmNyeXB0TXNnUmVzcG9uc2USHgoKY2lwaGVydGV4dBgBIAEoCVIKY2lwaGVydGV4dA==');

@$core.Deprecated('Use signArbitraryMsgRequestDescriptor instead')
const SignArbitraryMsgRequest$json = {
  '1': 'SignArbitraryMsgRequest',
  '2': [
    {'1': 'msg', '3': 1, '4': 1, '5': 9, '10': 'msg'},
    {'1': 'verifying_key', '3': 2, '4': 1, '5': 9, '10': 'verifyingKey'},
  ],
};

/// Descriptor for `SignArbitraryMsgRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List signArbitraryMsgRequestDescriptor =
    $convert.base64Decode('ChdTaWduQXJiaXRyYXJ5TXNnUmVxdWVzdBIQCgNtc2cYASABKAlSA21zZxIjCg12ZXJpZnlpbm'
        'dfa2V5GAIgASgJUgx2ZXJpZnlpbmdLZXk=');

@$core.Deprecated('Use signArbitraryMsgResponseDescriptor instead')
const SignArbitraryMsgResponse$json = {
  '1': 'SignArbitraryMsgResponse',
  '2': [
    {'1': 'signature', '3': 1, '4': 1, '5': 9, '10': 'signature'},
  ],
};

/// Descriptor for `SignArbitraryMsgResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List signArbitraryMsgResponseDescriptor =
    $convert.base64Decode('ChhTaWduQXJiaXRyYXJ5TXNnUmVzcG9uc2USHAoJc2lnbmF0dXJlGAEgASgJUglzaWduYXR1cm'
        'U=');

@$core.Deprecated('Use signArbitraryMsgAsAddrRequestDescriptor instead')
const SignArbitraryMsgAsAddrRequest$json = {
  '1': 'SignArbitraryMsgAsAddrRequest',
  '2': [
    {'1': 'msg', '3': 1, '4': 1, '5': 9, '10': 'msg'},
    {'1': 'address', '3': 2, '4': 1, '5': 9, '10': 'address'},
  ],
};

/// Descriptor for `SignArbitraryMsgAsAddrRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List signArbitraryMsgAsAddrRequestDescriptor =
    $convert.base64Decode('Ch1TaWduQXJiaXRyYXJ5TXNnQXNBZGRyUmVxdWVzdBIQCgNtc2cYASABKAlSA21zZxIYCgdhZG'
        'RyZXNzGAIgASgJUgdhZGRyZXNz');

@$core.Deprecated('Use signArbitraryMsgAsAddrResponseDescriptor instead')
const SignArbitraryMsgAsAddrResponse$json = {
  '1': 'SignArbitraryMsgAsAddrResponse',
  '2': [
    {'1': 'verifying_key', '3': 1, '4': 1, '5': 9, '10': 'verifyingKey'},
    {'1': 'signature', '3': 2, '4': 1, '5': 9, '10': 'signature'},
  ],
};

/// Descriptor for `SignArbitraryMsgAsAddrResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List signArbitraryMsgAsAddrResponseDescriptor =
    $convert.base64Decode('Ch5TaWduQXJiaXRyYXJ5TXNnQXNBZGRyUmVzcG9uc2USIwoNdmVyaWZ5aW5nX2tleRgBIAEoCV'
        'IMdmVyaWZ5aW5nS2V5EhwKCXNpZ25hdHVyZRgCIAEoCVIJc2lnbmF0dXJl');

@$core.Deprecated('Use verifySignatureRequestDescriptor instead')
const VerifySignatureRequest$json = {
  '1': 'VerifySignatureRequest',
  '2': [
    {'1': 'msg', '3': 1, '4': 1, '5': 9, '10': 'msg'},
    {'1': 'signature', '3': 2, '4': 1, '5': 9, '10': 'signature'},
    {'1': 'verifying_key', '3': 3, '4': 1, '5': 9, '10': 'verifyingKey'},
  ],
};

/// Descriptor for `VerifySignatureRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List verifySignatureRequestDescriptor =
    $convert.base64Decode('ChZWZXJpZnlTaWduYXR1cmVSZXF1ZXN0EhAKA21zZxgBIAEoCVIDbXNnEhwKCXNpZ25hdHVyZR'
        'gCIAEoCVIJc2lnbmF0dXJlEiMKDXZlcmlmeWluZ19rZXkYAyABKAlSDHZlcmlmeWluZ0tleQ==');

@$core.Deprecated('Use verifySignatureResponseDescriptor instead')
const VerifySignatureResponse$json = {
  '1': 'VerifySignatureResponse',
  '2': [
    {'1': 'valid', '3': 1, '4': 1, '5': 8, '10': 'valid'},
  ],
};

/// Descriptor for `VerifySignatureResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List verifySignatureResponseDescriptor =
    $convert.base64Decode('ChdWZXJpZnlTaWduYXR1cmVSZXNwb25zZRIUCgV2YWxpZBgBIAEoCFIFdmFsaWQ=');

@$core.Deprecated('Use getWalletAddressesRequestDescriptor instead')
const GetWalletAddressesRequest$json = {
  '1': 'GetWalletAddressesRequest',
};

/// Descriptor for `GetWalletAddressesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getWalletAddressesRequestDescriptor =
    $convert.base64Decode('ChlHZXRXYWxsZXRBZGRyZXNzZXNSZXF1ZXN0');

@$core.Deprecated('Use getWalletAddressesResponseDescriptor instead')
const GetWalletAddressesResponse$json = {
  '1': 'GetWalletAddressesResponse',
  '2': [
    {'1': 'addresses', '3': 1, '4': 3, '5': 9, '10': 'addresses'},
  ],
};

/// Descriptor for `GetWalletAddressesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getWalletAddressesResponseDescriptor =
    $convert.base64Decode('ChpHZXRXYWxsZXRBZGRyZXNzZXNSZXNwb25zZRIcCglhZGRyZXNzZXMYASADKAlSCWFkZHJlc3'
        'Nlcw==');

@$core.Deprecated('Use myUnconfirmedUtxosRequestDescriptor instead')
const MyUnconfirmedUtxosRequest$json = {
  '1': 'MyUnconfirmedUtxosRequest',
};

/// Descriptor for `MyUnconfirmedUtxosRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List myUnconfirmedUtxosRequestDescriptor =
    $convert.base64Decode('ChlNeVVuY29uZmlybWVkVXR4b3NSZXF1ZXN0');

@$core.Deprecated('Use myUnconfirmedUtxosResponseDescriptor instead')
const MyUnconfirmedUtxosResponse$json = {
  '1': 'MyUnconfirmedUtxosResponse',
  '2': [
    {'1': 'utxos_json', '3': 1, '4': 1, '5': 9, '10': 'utxosJson'},
  ],
};

/// Descriptor for `MyUnconfirmedUtxosResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List myUnconfirmedUtxosResponseDescriptor =
    $convert.base64Decode('ChpNeVVuY29uZmlybWVkVXR4b3NSZXNwb25zZRIdCgp1dHhvc19qc29uGAEgASgJUgl1dHhvc0'
        'pzb24=');

@$core.Deprecated('Use openapiSchemaRequestDescriptor instead')
const OpenapiSchemaRequest$json = {
  '1': 'OpenapiSchemaRequest',
};

/// Descriptor for `OpenapiSchemaRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List openapiSchemaRequestDescriptor = $convert.base64Decode('ChRPcGVuYXBpU2NoZW1hUmVxdWVzdA==');

@$core.Deprecated('Use openapiSchemaResponseDescriptor instead')
const OpenapiSchemaResponse$json = {
  '1': 'OpenapiSchemaResponse',
  '2': [
    {'1': 'schema_json', '3': 1, '4': 1, '5': 9, '10': 'schemaJson'},
  ],
};

/// Descriptor for `OpenapiSchemaResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List openapiSchemaResponseDescriptor =
    $convert.base64Decode('ChVPcGVuYXBpU2NoZW1hUmVzcG9uc2USHwoLc2NoZW1hX2pzb24YASABKAlSCnNjaGVtYUpzb2'
        '4=');

@$core.Deprecated('Use ammBurnRequestDescriptor instead')
const AmmBurnRequest$json = {
  '1': 'AmmBurnRequest',
  '2': [
    {'1': 'asset0', '3': 1, '4': 1, '5': 9, '10': 'asset0'},
    {'1': 'asset1', '3': 2, '4': 1, '5': 9, '10': 'asset1'},
    {'1': 'lp_token_amount', '3': 3, '4': 1, '5': 3, '10': 'lpTokenAmount'},
  ],
};

/// Descriptor for `AmmBurnRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ammBurnRequestDescriptor =
    $convert.base64Decode('Cg5BbW1CdXJuUmVxdWVzdBIWCgZhc3NldDAYASABKAlSBmFzc2V0MBIWCgZhc3NldDEYAiABKA'
        'lSBmFzc2V0MRImCg9scF90b2tlbl9hbW91bnQYAyABKANSDWxwVG9rZW5BbW91bnQ=');

@$core.Deprecated('Use ammBurnResponseDescriptor instead')
const AmmBurnResponse$json = {
  '1': 'AmmBurnResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `AmmBurnResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ammBurnResponseDescriptor =
    $convert.base64Decode('Cg9BbW1CdXJuUmVzcG9uc2USEgoEdHhpZBgBIAEoCVIEdHhpZA==');

@$core.Deprecated('Use ammMintRequestDescriptor instead')
const AmmMintRequest$json = {
  '1': 'AmmMintRequest',
  '2': [
    {'1': 'asset0', '3': 1, '4': 1, '5': 9, '10': 'asset0'},
    {'1': 'asset1', '3': 2, '4': 1, '5': 9, '10': 'asset1'},
    {'1': 'amount0', '3': 3, '4': 1, '5': 3, '10': 'amount0'},
    {'1': 'amount1', '3': 4, '4': 1, '5': 3, '10': 'amount1'},
  ],
};

/// Descriptor for `AmmMintRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ammMintRequestDescriptor =
    $convert.base64Decode('Cg5BbW1NaW50UmVxdWVzdBIWCgZhc3NldDAYASABKAlSBmFzc2V0MBIWCgZhc3NldDEYAiABKA'
        'lSBmFzc2V0MRIYCgdhbW91bnQwGAMgASgDUgdhbW91bnQwEhgKB2Ftb3VudDEYBCABKANSB2Ft'
        'b3VudDE=');

@$core.Deprecated('Use ammMintResponseDescriptor instead')
const AmmMintResponse$json = {
  '1': 'AmmMintResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `AmmMintResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ammMintResponseDescriptor =
    $convert.base64Decode('Cg9BbW1NaW50UmVzcG9uc2USEgoEdHhpZBgBIAEoCVIEdHhpZA==');

@$core.Deprecated('Use ammSwapRequestDescriptor instead')
const AmmSwapRequest$json = {
  '1': 'AmmSwapRequest',
  '2': [
    {'1': 'asset_spend', '3': 1, '4': 1, '5': 9, '10': 'assetSpend'},
    {'1': 'asset_receive', '3': 2, '4': 1, '5': 9, '10': 'assetReceive'},
    {'1': 'amount_spend', '3': 3, '4': 1, '5': 3, '10': 'amountSpend'},
  ],
};

/// Descriptor for `AmmSwapRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ammSwapRequestDescriptor =
    $convert.base64Decode('Cg5BbW1Td2FwUmVxdWVzdBIfCgthc3NldF9zcGVuZBgBIAEoCVIKYXNzZXRTcGVuZBIjCg1hc3'
        'NldF9yZWNlaXZlGAIgASgJUgxhc3NldFJlY2VpdmUSIQoMYW1vdW50X3NwZW5kGAMgASgDUgth'
        'bW91bnRTcGVuZA==');

@$core.Deprecated('Use ammSwapResponseDescriptor instead')
const AmmSwapResponse$json = {
  '1': 'AmmSwapResponse',
  '2': [
    {'1': 'amount_receive', '3': 1, '4': 1, '5': 3, '10': 'amountReceive'},
  ],
};

/// Descriptor for `AmmSwapResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ammSwapResponseDescriptor =
    $convert.base64Decode('Cg9BbW1Td2FwUmVzcG9uc2USJQoOYW1vdW50X3JlY2VpdmUYASABKANSDWFtb3VudFJlY2Vpdm'
        'U=');

@$core.Deprecated('Use getAmmPoolStateRequestDescriptor instead')
const GetAmmPoolStateRequest$json = {
  '1': 'GetAmmPoolStateRequest',
  '2': [
    {'1': 'asset0', '3': 1, '4': 1, '5': 9, '10': 'asset0'},
    {'1': 'asset1', '3': 2, '4': 1, '5': 9, '10': 'asset1'},
  ],
};

/// Descriptor for `GetAmmPoolStateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAmmPoolStateRequestDescriptor =
    $convert.base64Decode('ChZHZXRBbW1Qb29sU3RhdGVSZXF1ZXN0EhYKBmFzc2V0MBgBIAEoCVIGYXNzZXQwEhYKBmFzc2'
        'V0MRgCIAEoCVIGYXNzZXQx');

@$core.Deprecated('Use getAmmPoolStateResponseDescriptor instead')
const GetAmmPoolStateResponse$json = {
  '1': 'GetAmmPoolStateResponse',
  '2': [
    {'1': 'pool_state_json', '3': 1, '4': 1, '5': 9, '10': 'poolStateJson'},
  ],
};

/// Descriptor for `GetAmmPoolStateResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAmmPoolStateResponseDescriptor =
    $convert.base64Decode('ChdHZXRBbW1Qb29sU3RhdGVSZXNwb25zZRImCg9wb29sX3N0YXRlX2pzb24YASABKAlSDXBvb2'
        'xTdGF0ZUpzb24=');

@$core.Deprecated('Use getAmmPriceRequestDescriptor instead')
const GetAmmPriceRequest$json = {
  '1': 'GetAmmPriceRequest',
  '2': [
    {'1': 'base', '3': 1, '4': 1, '5': 9, '10': 'base'},
    {'1': 'quote', '3': 2, '4': 1, '5': 9, '10': 'quote'},
  ],
};

/// Descriptor for `GetAmmPriceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAmmPriceRequestDescriptor =
    $convert.base64Decode('ChJHZXRBbW1QcmljZVJlcXVlc3QSEgoEYmFzZRgBIAEoCVIEYmFzZRIUCgVxdW90ZRgCIAEoCV'
        'IFcXVvdGU=');

@$core.Deprecated('Use getAmmPriceResponseDescriptor instead')
const GetAmmPriceResponse$json = {
  '1': 'GetAmmPriceResponse',
  '2': [
    {'1': 'price_json', '3': 1, '4': 1, '5': 9, '10': 'priceJson'},
  ],
};

/// Descriptor for `GetAmmPriceResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAmmPriceResponseDescriptor =
    $convert.base64Decode('ChNHZXRBbW1QcmljZVJlc3BvbnNlEh0KCnByaWNlX2pzb24YASABKAlSCXByaWNlSnNvbg==');

@$core.Deprecated('Use dutchAuctionBidRequestDescriptor instead')
const DutchAuctionBidRequest$json = {
  '1': 'DutchAuctionBidRequest',
  '2': [
    {'1': 'dutch_auction_id', '3': 1, '4': 1, '5': 9, '10': 'dutchAuctionId'},
    {'1': 'bid_size', '3': 2, '4': 1, '5': 3, '10': 'bidSize'},
  ],
};

/// Descriptor for `DutchAuctionBidRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dutchAuctionBidRequestDescriptor =
    $convert.base64Decode('ChZEdXRjaEF1Y3Rpb25CaWRSZXF1ZXN0EigKEGR1dGNoX2F1Y3Rpb25faWQYASABKAlSDmR1dG'
        'NoQXVjdGlvbklkEhkKCGJpZF9zaXplGAIgASgDUgdiaWRTaXpl');

@$core.Deprecated('Use dutchAuctionBidResponseDescriptor instead')
const DutchAuctionBidResponse$json = {
  '1': 'DutchAuctionBidResponse',
  '2': [
    {'1': 'base_amount', '3': 1, '4': 1, '5': 3, '10': 'baseAmount'},
  ],
};

/// Descriptor for `DutchAuctionBidResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dutchAuctionBidResponseDescriptor =
    $convert.base64Decode('ChdEdXRjaEF1Y3Rpb25CaWRSZXNwb25zZRIfCgtiYXNlX2Ftb3VudBgBIAEoA1IKYmFzZUFtb3'
        'VudA==');

@$core.Deprecated('Use dutchAuctionCollectRequestDescriptor instead')
const DutchAuctionCollectRequest$json = {
  '1': 'DutchAuctionCollectRequest',
  '2': [
    {'1': 'dutch_auction_id', '3': 1, '4': 1, '5': 9, '10': 'dutchAuctionId'},
  ],
};

/// Descriptor for `DutchAuctionCollectRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dutchAuctionCollectRequestDescriptor =
    $convert.base64Decode('ChpEdXRjaEF1Y3Rpb25Db2xsZWN0UmVxdWVzdBIoChBkdXRjaF9hdWN0aW9uX2lkGAEgASgJUg'
        '5kdXRjaEF1Y3Rpb25JZA==');

@$core.Deprecated('Use dutchAuctionCollectResponseDescriptor instead')
const DutchAuctionCollectResponse$json = {
  '1': 'DutchAuctionCollectResponse',
  '2': [
    {'1': 'base_amount', '3': 1, '4': 1, '5': 3, '10': 'baseAmount'},
    {'1': 'quote_amount', '3': 2, '4': 1, '5': 3, '10': 'quoteAmount'},
  ],
};

/// Descriptor for `DutchAuctionCollectResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dutchAuctionCollectResponseDescriptor =
    $convert.base64Decode('ChtEdXRjaEF1Y3Rpb25Db2xsZWN0UmVzcG9uc2USHwoLYmFzZV9hbW91bnQYASABKANSCmJhc2'
        'VBbW91bnQSIQoMcXVvdGVfYW1vdW50GAIgASgDUgtxdW90ZUFtb3VudA==');

@$core.Deprecated('Use dutchAuctionCreateRequestDescriptor instead')
const DutchAuctionCreateRequest$json = {
  '1': 'DutchAuctionCreateRequest',
  '2': [
    {'1': 'start_block', '3': 1, '4': 1, '5': 3, '10': 'startBlock'},
    {'1': 'duration', '3': 2, '4': 1, '5': 3, '10': 'duration'},
    {'1': 'base_asset', '3': 3, '4': 1, '5': 9, '10': 'baseAsset'},
    {'1': 'base_amount', '3': 4, '4': 1, '5': 3, '10': 'baseAmount'},
    {'1': 'quote_asset', '3': 5, '4': 1, '5': 9, '10': 'quoteAsset'},
    {'1': 'initial_price', '3': 6, '4': 1, '5': 3, '10': 'initialPrice'},
    {'1': 'final_price', '3': 7, '4': 1, '5': 3, '10': 'finalPrice'},
  ],
};

/// Descriptor for `DutchAuctionCreateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dutchAuctionCreateRequestDescriptor =
    $convert.base64Decode('ChlEdXRjaEF1Y3Rpb25DcmVhdGVSZXF1ZXN0Eh8KC3N0YXJ0X2Jsb2NrGAEgASgDUgpzdGFydE'
        'Jsb2NrEhoKCGR1cmF0aW9uGAIgASgDUghkdXJhdGlvbhIdCgpiYXNlX2Fzc2V0GAMgASgJUgli'
        'YXNlQXNzZXQSHwoLYmFzZV9hbW91bnQYBCABKANSCmJhc2VBbW91bnQSHwoLcXVvdGVfYXNzZX'
        'QYBSABKAlSCnF1b3RlQXNzZXQSIwoNaW5pdGlhbF9wcmljZRgGIAEoA1IMaW5pdGlhbFByaWNl'
        'Eh8KC2ZpbmFsX3ByaWNlGAcgASgDUgpmaW5hbFByaWNl');

@$core.Deprecated('Use dutchAuctionCreateResponseDescriptor instead')
const DutchAuctionCreateResponse$json = {
  '1': 'DutchAuctionCreateResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `DutchAuctionCreateResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dutchAuctionCreateResponseDescriptor =
    $convert.base64Decode('ChpEdXRjaEF1Y3Rpb25DcmVhdGVSZXNwb25zZRISCgR0eGlkGAEgASgJUgR0eGlk');

@$core.Deprecated('Use dutchAuctionsRequestDescriptor instead')
const DutchAuctionsRequest$json = {
  '1': 'DutchAuctionsRequest',
};

/// Descriptor for `DutchAuctionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dutchAuctionsRequestDescriptor = $convert.base64Decode('ChREdXRjaEF1Y3Rpb25zUmVxdWVzdA==');

@$core.Deprecated('Use dutchAuctionsResponseDescriptor instead')
const DutchAuctionsResponse$json = {
  '1': 'DutchAuctionsResponse',
  '2': [
    {'1': 'auctions_json', '3': 1, '4': 1, '5': 9, '10': 'auctionsJson'},
  ],
};

/// Descriptor for `DutchAuctionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dutchAuctionsResponseDescriptor =
    $convert.base64Decode('ChVEdXRjaEF1Y3Rpb25zUmVzcG9uc2USIwoNYXVjdGlvbnNfanNvbhgBIAEoCVIMYXVjdGlvbn'
        'NKc29u');

const $core.Map<$core.String, $core.dynamic> BitAssetsServiceBase$json = {
  '1': 'BitAssetsService',
  '2': [
    {'1': 'GetBalance', '2': '.bitassets.v1.GetBalanceRequest', '3': '.bitassets.v1.GetBalanceResponse'},
    {'1': 'GetBlockCount', '2': '.bitassets.v1.GetBlockCountRequest', '3': '.bitassets.v1.GetBlockCountResponse'},
    {'1': 'Stop', '2': '.bitassets.v1.StopRequest', '3': '.bitassets.v1.StopResponse'},
    {'1': 'GetNewAddress', '2': '.bitassets.v1.GetNewAddressRequest', '3': '.bitassets.v1.GetNewAddressResponse'},
    {'1': 'Withdraw', '2': '.bitassets.v1.WithdrawRequest', '3': '.bitassets.v1.WithdrawResponse'},
    {'1': 'Transfer', '2': '.bitassets.v1.TransferRequest', '3': '.bitassets.v1.TransferResponse'},
    {
      '1': 'GetSidechainWealth',
      '2': '.bitassets.v1.GetSidechainWealthRequest',
      '3': '.bitassets.v1.GetSidechainWealthResponse'
    },
    {'1': 'CreateDeposit', '2': '.bitassets.v1.CreateDepositRequest', '3': '.bitassets.v1.CreateDepositResponse'},
    {
      '1': 'GetPendingWithdrawalBundle',
      '2': '.bitassets.v1.GetPendingWithdrawalBundleRequest',
      '3': '.bitassets.v1.GetPendingWithdrawalBundleResponse'
    },
    {'1': 'ConnectPeer', '2': '.bitassets.v1.ConnectPeerRequest', '3': '.bitassets.v1.ConnectPeerResponse'},
    {'1': 'ForgetPeer', '2': '.bitassets.v1.ForgetPeerRequest', '3': '.bitassets.v1.ForgetPeerResponse'},
    {'1': 'ListPeers', '2': '.bitassets.v1.ListPeersRequest', '3': '.bitassets.v1.ListPeersResponse'},
    {'1': 'Mine', '2': '.bitassets.v1.MineRequest', '3': '.bitassets.v1.MineResponse'},
    {'1': 'GetBlock', '2': '.bitassets.v1.GetBlockRequest', '3': '.bitassets.v1.GetBlockResponse'},
    {
      '1': 'GetBestMainchainBlockHash',
      '2': '.bitassets.v1.GetBestMainchainBlockHashRequest',
      '3': '.bitassets.v1.GetBestMainchainBlockHashResponse'
    },
    {
      '1': 'GetBestSidechainBlockHash',
      '2': '.bitassets.v1.GetBestSidechainBlockHashRequest',
      '3': '.bitassets.v1.GetBestSidechainBlockHashResponse'
    },
    {
      '1': 'GetBmmInclusions',
      '2': '.bitassets.v1.GetBmmInclusionsRequest',
      '3': '.bitassets.v1.GetBmmInclusionsResponse'
    },
    {'1': 'GetWalletUtxos', '2': '.bitassets.v1.GetWalletUtxosRequest', '3': '.bitassets.v1.GetWalletUtxosResponse'},
    {'1': 'ListUtxos', '2': '.bitassets.v1.ListUtxosRequest', '3': '.bitassets.v1.ListUtxosResponse'},
    {
      '1': 'RemoveFromMempool',
      '2': '.bitassets.v1.RemoveFromMempoolRequest',
      '3': '.bitassets.v1.RemoveFromMempoolResponse'
    },
    {
      '1': 'GetLatestFailedWithdrawalBundleHeight',
      '2': '.bitassets.v1.GetLatestFailedWithdrawalBundleHeightRequest',
      '3': '.bitassets.v1.GetLatestFailedWithdrawalBundleHeightResponse'
    },
    {
      '1': 'GenerateMnemonic',
      '2': '.bitassets.v1.GenerateMnemonicRequest',
      '3': '.bitassets.v1.GenerateMnemonicResponse'
    },
    {
      '1': 'SetSeedFromMnemonic',
      '2': '.bitassets.v1.SetSeedFromMnemonicRequest',
      '3': '.bitassets.v1.SetSeedFromMnemonicResponse'
    },
    {'1': 'CallRaw', '2': '.bitassets.v1.CallRawRequest', '3': '.bitassets.v1.CallRawResponse'},
    {'1': 'GetBitAssetData', '2': '.bitassets.v1.GetBitAssetDataRequest', '3': '.bitassets.v1.GetBitAssetDataResponse'},
    {'1': 'ListBitAssets', '2': '.bitassets.v1.ListBitAssetsRequest', '3': '.bitassets.v1.ListBitAssetsResponse'},
    {
      '1': 'RegisterBitAsset',
      '2': '.bitassets.v1.RegisterBitAssetRequest',
      '3': '.bitassets.v1.RegisterBitAssetResponse'
    },
    {'1': 'ReserveBitAsset', '2': '.bitassets.v1.ReserveBitAssetRequest', '3': '.bitassets.v1.ReserveBitAssetResponse'},
    {
      '1': 'TransferBitAsset',
      '2': '.bitassets.v1.TransferBitAssetRequest',
      '3': '.bitassets.v1.TransferBitAssetResponse'
    },
    {
      '1': 'GetNewEncryptionKey',
      '2': '.bitassets.v1.GetNewEncryptionKeyRequest',
      '3': '.bitassets.v1.GetNewEncryptionKeyResponse'
    },
    {
      '1': 'GetNewVerifyingKey',
      '2': '.bitassets.v1.GetNewVerifyingKeyRequest',
      '3': '.bitassets.v1.GetNewVerifyingKeyResponse'
    },
    {'1': 'DecryptMsg', '2': '.bitassets.v1.DecryptMsgRequest', '3': '.bitassets.v1.DecryptMsgResponse'},
    {'1': 'EncryptMsg', '2': '.bitassets.v1.EncryptMsgRequest', '3': '.bitassets.v1.EncryptMsgResponse'},
    {
      '1': 'SignArbitraryMsg',
      '2': '.bitassets.v1.SignArbitraryMsgRequest',
      '3': '.bitassets.v1.SignArbitraryMsgResponse'
    },
    {
      '1': 'SignArbitraryMsgAsAddr',
      '2': '.bitassets.v1.SignArbitraryMsgAsAddrRequest',
      '3': '.bitassets.v1.SignArbitraryMsgAsAddrResponse'
    },
    {'1': 'VerifySignature', '2': '.bitassets.v1.VerifySignatureRequest', '3': '.bitassets.v1.VerifySignatureResponse'},
    {
      '1': 'GetWalletAddresses',
      '2': '.bitassets.v1.GetWalletAddressesRequest',
      '3': '.bitassets.v1.GetWalletAddressesResponse'
    },
    {
      '1': 'MyUnconfirmedUtxos',
      '2': '.bitassets.v1.MyUnconfirmedUtxosRequest',
      '3': '.bitassets.v1.MyUnconfirmedUtxosResponse'
    },
    {'1': 'OpenapiSchema', '2': '.bitassets.v1.OpenapiSchemaRequest', '3': '.bitassets.v1.OpenapiSchemaResponse'},
    {'1': 'AmmBurn', '2': '.bitassets.v1.AmmBurnRequest', '3': '.bitassets.v1.AmmBurnResponse'},
    {'1': 'AmmMint', '2': '.bitassets.v1.AmmMintRequest', '3': '.bitassets.v1.AmmMintResponse'},
    {'1': 'AmmSwap', '2': '.bitassets.v1.AmmSwapRequest', '3': '.bitassets.v1.AmmSwapResponse'},
    {'1': 'GetAmmPoolState', '2': '.bitassets.v1.GetAmmPoolStateRequest', '3': '.bitassets.v1.GetAmmPoolStateResponse'},
    {'1': 'GetAmmPrice', '2': '.bitassets.v1.GetAmmPriceRequest', '3': '.bitassets.v1.GetAmmPriceResponse'},
    {'1': 'DutchAuctionBid', '2': '.bitassets.v1.DutchAuctionBidRequest', '3': '.bitassets.v1.DutchAuctionBidResponse'},
    {
      '1': 'DutchAuctionCollect',
      '2': '.bitassets.v1.DutchAuctionCollectRequest',
      '3': '.bitassets.v1.DutchAuctionCollectResponse'
    },
    {
      '1': 'DutchAuctionCreate',
      '2': '.bitassets.v1.DutchAuctionCreateRequest',
      '3': '.bitassets.v1.DutchAuctionCreateResponse'
    },
    {'1': 'DutchAuctions', '2': '.bitassets.v1.DutchAuctionsRequest', '3': '.bitassets.v1.DutchAuctionsResponse'},
  ],
};

@$core.Deprecated('Use bitAssetsServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> BitAssetsServiceBase$messageJson = {
  '.bitassets.v1.GetBalanceRequest': GetBalanceRequest$json,
  '.bitassets.v1.GetBalanceResponse': GetBalanceResponse$json,
  '.bitassets.v1.GetBlockCountRequest': GetBlockCountRequest$json,
  '.bitassets.v1.GetBlockCountResponse': GetBlockCountResponse$json,
  '.bitassets.v1.StopRequest': StopRequest$json,
  '.bitassets.v1.StopResponse': StopResponse$json,
  '.bitassets.v1.GetNewAddressRequest': GetNewAddressRequest$json,
  '.bitassets.v1.GetNewAddressResponse': GetNewAddressResponse$json,
  '.bitassets.v1.WithdrawRequest': WithdrawRequest$json,
  '.bitassets.v1.WithdrawResponse': WithdrawResponse$json,
  '.bitassets.v1.TransferRequest': TransferRequest$json,
  '.bitassets.v1.TransferResponse': TransferResponse$json,
  '.bitassets.v1.GetSidechainWealthRequest': GetSidechainWealthRequest$json,
  '.bitassets.v1.GetSidechainWealthResponse': GetSidechainWealthResponse$json,
  '.bitassets.v1.CreateDepositRequest': CreateDepositRequest$json,
  '.bitassets.v1.CreateDepositResponse': CreateDepositResponse$json,
  '.bitassets.v1.GetPendingWithdrawalBundleRequest': GetPendingWithdrawalBundleRequest$json,
  '.bitassets.v1.GetPendingWithdrawalBundleResponse': GetPendingWithdrawalBundleResponse$json,
  '.bitassets.v1.ConnectPeerRequest': ConnectPeerRequest$json,
  '.bitassets.v1.ConnectPeerResponse': ConnectPeerResponse$json,
  '.bitassets.v1.ForgetPeerRequest': ForgetPeerRequest$json,
  '.bitassets.v1.ForgetPeerResponse': ForgetPeerResponse$json,
  '.bitassets.v1.ListPeersRequest': ListPeersRequest$json,
  '.bitassets.v1.ListPeersResponse': ListPeersResponse$json,
  '.bitassets.v1.MineRequest': MineRequest$json,
  '.bitassets.v1.MineResponse': MineResponse$json,
  '.bitassets.v1.GetBlockRequest': GetBlockRequest$json,
  '.bitassets.v1.GetBlockResponse': GetBlockResponse$json,
  '.bitassets.v1.GetBestMainchainBlockHashRequest': GetBestMainchainBlockHashRequest$json,
  '.bitassets.v1.GetBestMainchainBlockHashResponse': GetBestMainchainBlockHashResponse$json,
  '.bitassets.v1.GetBestSidechainBlockHashRequest': GetBestSidechainBlockHashRequest$json,
  '.bitassets.v1.GetBestSidechainBlockHashResponse': GetBestSidechainBlockHashResponse$json,
  '.bitassets.v1.GetBmmInclusionsRequest': GetBmmInclusionsRequest$json,
  '.bitassets.v1.GetBmmInclusionsResponse': GetBmmInclusionsResponse$json,
  '.bitassets.v1.GetWalletUtxosRequest': GetWalletUtxosRequest$json,
  '.bitassets.v1.GetWalletUtxosResponse': GetWalletUtxosResponse$json,
  '.bitassets.v1.ListUtxosRequest': ListUtxosRequest$json,
  '.bitassets.v1.ListUtxosResponse': ListUtxosResponse$json,
  '.bitassets.v1.RemoveFromMempoolRequest': RemoveFromMempoolRequest$json,
  '.bitassets.v1.RemoveFromMempoolResponse': RemoveFromMempoolResponse$json,
  '.bitassets.v1.GetLatestFailedWithdrawalBundleHeightRequest': GetLatestFailedWithdrawalBundleHeightRequest$json,
  '.bitassets.v1.GetLatestFailedWithdrawalBundleHeightResponse': GetLatestFailedWithdrawalBundleHeightResponse$json,
  '.bitassets.v1.GenerateMnemonicRequest': GenerateMnemonicRequest$json,
  '.bitassets.v1.GenerateMnemonicResponse': GenerateMnemonicResponse$json,
  '.bitassets.v1.SetSeedFromMnemonicRequest': SetSeedFromMnemonicRequest$json,
  '.bitassets.v1.SetSeedFromMnemonicResponse': SetSeedFromMnemonicResponse$json,
  '.bitassets.v1.CallRawRequest': CallRawRequest$json,
  '.bitassets.v1.CallRawResponse': CallRawResponse$json,
  '.bitassets.v1.GetBitAssetDataRequest': GetBitAssetDataRequest$json,
  '.bitassets.v1.GetBitAssetDataResponse': GetBitAssetDataResponse$json,
  '.bitassets.v1.ListBitAssetsRequest': ListBitAssetsRequest$json,
  '.bitassets.v1.ListBitAssetsResponse': ListBitAssetsResponse$json,
  '.bitassets.v1.RegisterBitAssetRequest': RegisterBitAssetRequest$json,
  '.bitassets.v1.RegisterBitAssetResponse': RegisterBitAssetResponse$json,
  '.bitassets.v1.ReserveBitAssetRequest': ReserveBitAssetRequest$json,
  '.bitassets.v1.ReserveBitAssetResponse': ReserveBitAssetResponse$json,
  '.bitassets.v1.TransferBitAssetRequest': TransferBitAssetRequest$json,
  '.bitassets.v1.TransferBitAssetResponse': TransferBitAssetResponse$json,
  '.bitassets.v1.GetNewEncryptionKeyRequest': GetNewEncryptionKeyRequest$json,
  '.bitassets.v1.GetNewEncryptionKeyResponse': GetNewEncryptionKeyResponse$json,
  '.bitassets.v1.GetNewVerifyingKeyRequest': GetNewVerifyingKeyRequest$json,
  '.bitassets.v1.GetNewVerifyingKeyResponse': GetNewVerifyingKeyResponse$json,
  '.bitassets.v1.DecryptMsgRequest': DecryptMsgRequest$json,
  '.bitassets.v1.DecryptMsgResponse': DecryptMsgResponse$json,
  '.bitassets.v1.EncryptMsgRequest': EncryptMsgRequest$json,
  '.bitassets.v1.EncryptMsgResponse': EncryptMsgResponse$json,
  '.bitassets.v1.SignArbitraryMsgRequest': SignArbitraryMsgRequest$json,
  '.bitassets.v1.SignArbitraryMsgResponse': SignArbitraryMsgResponse$json,
  '.bitassets.v1.SignArbitraryMsgAsAddrRequest': SignArbitraryMsgAsAddrRequest$json,
  '.bitassets.v1.SignArbitraryMsgAsAddrResponse': SignArbitraryMsgAsAddrResponse$json,
  '.bitassets.v1.VerifySignatureRequest': VerifySignatureRequest$json,
  '.bitassets.v1.VerifySignatureResponse': VerifySignatureResponse$json,
  '.bitassets.v1.GetWalletAddressesRequest': GetWalletAddressesRequest$json,
  '.bitassets.v1.GetWalletAddressesResponse': GetWalletAddressesResponse$json,
  '.bitassets.v1.MyUnconfirmedUtxosRequest': MyUnconfirmedUtxosRequest$json,
  '.bitassets.v1.MyUnconfirmedUtxosResponse': MyUnconfirmedUtxosResponse$json,
  '.bitassets.v1.OpenapiSchemaRequest': OpenapiSchemaRequest$json,
  '.bitassets.v1.OpenapiSchemaResponse': OpenapiSchemaResponse$json,
  '.bitassets.v1.AmmBurnRequest': AmmBurnRequest$json,
  '.bitassets.v1.AmmBurnResponse': AmmBurnResponse$json,
  '.bitassets.v1.AmmMintRequest': AmmMintRequest$json,
  '.bitassets.v1.AmmMintResponse': AmmMintResponse$json,
  '.bitassets.v1.AmmSwapRequest': AmmSwapRequest$json,
  '.bitassets.v1.AmmSwapResponse': AmmSwapResponse$json,
  '.bitassets.v1.GetAmmPoolStateRequest': GetAmmPoolStateRequest$json,
  '.bitassets.v1.GetAmmPoolStateResponse': GetAmmPoolStateResponse$json,
  '.bitassets.v1.GetAmmPriceRequest': GetAmmPriceRequest$json,
  '.bitassets.v1.GetAmmPriceResponse': GetAmmPriceResponse$json,
  '.bitassets.v1.DutchAuctionBidRequest': DutchAuctionBidRequest$json,
  '.bitassets.v1.DutchAuctionBidResponse': DutchAuctionBidResponse$json,
  '.bitassets.v1.DutchAuctionCollectRequest': DutchAuctionCollectRequest$json,
  '.bitassets.v1.DutchAuctionCollectResponse': DutchAuctionCollectResponse$json,
  '.bitassets.v1.DutchAuctionCreateRequest': DutchAuctionCreateRequest$json,
  '.bitassets.v1.DutchAuctionCreateResponse': DutchAuctionCreateResponse$json,
  '.bitassets.v1.DutchAuctionsRequest': DutchAuctionsRequest$json,
  '.bitassets.v1.DutchAuctionsResponse': DutchAuctionsResponse$json,
};

/// Descriptor for `BitAssetsService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List bitAssetsServiceDescriptor =
    $convert.base64Decode('ChBCaXRBc3NldHNTZXJ2aWNlEk8KCkdldEJhbGFuY2USHy5iaXRhc3NldHMudjEuR2V0QmFsYW'
        '5jZVJlcXVlc3QaIC5iaXRhc3NldHMudjEuR2V0QmFsYW5jZVJlc3BvbnNlElgKDUdldEJsb2Nr'
        'Q291bnQSIi5iaXRhc3NldHMudjEuR2V0QmxvY2tDb3VudFJlcXVlc3QaIy5iaXRhc3NldHMudj'
        'EuR2V0QmxvY2tDb3VudFJlc3BvbnNlEj0KBFN0b3ASGS5iaXRhc3NldHMudjEuU3RvcFJlcXVl'
        'c3QaGi5iaXRhc3NldHMudjEuU3RvcFJlc3BvbnNlElgKDUdldE5ld0FkZHJlc3MSIi5iaXRhc3'
        'NldHMudjEuR2V0TmV3QWRkcmVzc1JlcXVlc3QaIy5iaXRhc3NldHMudjEuR2V0TmV3QWRkcmVz'
        'c1Jlc3BvbnNlEkkKCFdpdGhkcmF3Eh0uYml0YXNzZXRzLnYxLldpdGhkcmF3UmVxdWVzdBoeLm'
        'JpdGFzc2V0cy52MS5XaXRoZHJhd1Jlc3BvbnNlEkkKCFRyYW5zZmVyEh0uYml0YXNzZXRzLnYx'
        'LlRyYW5zZmVyUmVxdWVzdBoeLmJpdGFzc2V0cy52MS5UcmFuc2ZlclJlc3BvbnNlEmcKEkdldF'
        'NpZGVjaGFpbldlYWx0aBInLmJpdGFzc2V0cy52MS5HZXRTaWRlY2hhaW5XZWFsdGhSZXF1ZXN0'
        'GiguYml0YXNzZXRzLnYxLkdldFNpZGVjaGFpbldlYWx0aFJlc3BvbnNlElgKDUNyZWF0ZURlcG'
        '9zaXQSIi5iaXRhc3NldHMudjEuQ3JlYXRlRGVwb3NpdFJlcXVlc3QaIy5iaXRhc3NldHMudjEu'
        'Q3JlYXRlRGVwb3NpdFJlc3BvbnNlEn8KGkdldFBlbmRpbmdXaXRoZHJhd2FsQnVuZGxlEi8uYm'
        'l0YXNzZXRzLnYxLkdldFBlbmRpbmdXaXRoZHJhd2FsQnVuZGxlUmVxdWVzdBowLmJpdGFzc2V0'
        'cy52MS5HZXRQZW5kaW5nV2l0aGRyYXdhbEJ1bmRsZVJlc3BvbnNlElIKC0Nvbm5lY3RQZWVyEi'
        'AuYml0YXNzZXRzLnYxLkNvbm5lY3RQZWVyUmVxdWVzdBohLmJpdGFzc2V0cy52MS5Db25uZWN0'
        'UGVlclJlc3BvbnNlEk8KCkZvcmdldFBlZXISHy5iaXRhc3NldHMudjEuRm9yZ2V0UGVlclJlcX'
        'Vlc3QaIC5iaXRhc3NldHMudjEuRm9yZ2V0UGVlclJlc3BvbnNlEkwKCUxpc3RQZWVycxIeLmJp'
        'dGFzc2V0cy52MS5MaXN0UGVlcnNSZXF1ZXN0Gh8uYml0YXNzZXRzLnYxLkxpc3RQZWVyc1Jlc3'
        'BvbnNlEj0KBE1pbmUSGS5iaXRhc3NldHMudjEuTWluZVJlcXVlc3QaGi5iaXRhc3NldHMudjEu'
        'TWluZVJlc3BvbnNlEkkKCEdldEJsb2NrEh0uYml0YXNzZXRzLnYxLkdldEJsb2NrUmVxdWVzdB'
        'oeLmJpdGFzc2V0cy52MS5HZXRCbG9ja1Jlc3BvbnNlEnwKGUdldEJlc3RNYWluY2hhaW5CbG9j'
        'a0hhc2gSLi5iaXRhc3NldHMudjEuR2V0QmVzdE1haW5jaGFpbkJsb2NrSGFzaFJlcXVlc3QaLy'
        '5iaXRhc3NldHMudjEuR2V0QmVzdE1haW5jaGFpbkJsb2NrSGFzaFJlc3BvbnNlEnwKGUdldEJl'
        'c3RTaWRlY2hhaW5CbG9ja0hhc2gSLi5iaXRhc3NldHMudjEuR2V0QmVzdFNpZGVjaGFpbkJsb2'
        'NrSGFzaFJlcXVlc3QaLy5iaXRhc3NldHMudjEuR2V0QmVzdFNpZGVjaGFpbkJsb2NrSGFzaFJl'
        'c3BvbnNlEmEKEEdldEJtbUluY2x1c2lvbnMSJS5iaXRhc3NldHMudjEuR2V0Qm1tSW5jbHVzaW'
        '9uc1JlcXVlc3QaJi5iaXRhc3NldHMudjEuR2V0Qm1tSW5jbHVzaW9uc1Jlc3BvbnNlElsKDkdl'
        'dFdhbGxldFV0eG9zEiMuYml0YXNzZXRzLnYxLkdldFdhbGxldFV0eG9zUmVxdWVzdBokLmJpdG'
        'Fzc2V0cy52MS5HZXRXYWxsZXRVdHhvc1Jlc3BvbnNlEkwKCUxpc3RVdHhvcxIeLmJpdGFzc2V0'
        'cy52MS5MaXN0VXR4b3NSZXF1ZXN0Gh8uYml0YXNzZXRzLnYxLkxpc3RVdHhvc1Jlc3BvbnNlEm'
        'QKEVJlbW92ZUZyb21NZW1wb29sEiYuYml0YXNzZXRzLnYxLlJlbW92ZUZyb21NZW1wb29sUmVx'
        'dWVzdBonLmJpdGFzc2V0cy52MS5SZW1vdmVGcm9tTWVtcG9vbFJlc3BvbnNlEqABCiVHZXRMYX'
        'Rlc3RGYWlsZWRXaXRoZHJhd2FsQnVuZGxlSGVpZ2h0EjouYml0YXNzZXRzLnYxLkdldExhdGVz'
        'dEZhaWxlZFdpdGhkcmF3YWxCdW5kbGVIZWlnaHRSZXF1ZXN0GjsuYml0YXNzZXRzLnYxLkdldE'
        'xhdGVzdEZhaWxlZFdpdGhkcmF3YWxCdW5kbGVIZWlnaHRSZXNwb25zZRJhChBHZW5lcmF0ZU1u'
        'ZW1vbmljEiUuYml0YXNzZXRzLnYxLkdlbmVyYXRlTW5lbW9uaWNSZXF1ZXN0GiYuYml0YXNzZX'
        'RzLnYxLkdlbmVyYXRlTW5lbW9uaWNSZXNwb25zZRJqChNTZXRTZWVkRnJvbU1uZW1vbmljEigu'
        'Yml0YXNzZXRzLnYxLlNldFNlZWRGcm9tTW5lbW9uaWNSZXF1ZXN0GikuYml0YXNzZXRzLnYxLl'
        'NldFNlZWRGcm9tTW5lbW9uaWNSZXNwb25zZRJGCgdDYWxsUmF3EhwuYml0YXNzZXRzLnYxLkNh'
        'bGxSYXdSZXF1ZXN0Gh0uYml0YXNzZXRzLnYxLkNhbGxSYXdSZXNwb25zZRJeCg9HZXRCaXRBc3'
        'NldERhdGESJC5iaXRhc3NldHMudjEuR2V0Qml0QXNzZXREYXRhUmVxdWVzdBolLmJpdGFzc2V0'
        'cy52MS5HZXRCaXRBc3NldERhdGFSZXNwb25zZRJYCg1MaXN0Qml0QXNzZXRzEiIuYml0YXNzZX'
        'RzLnYxLkxpc3RCaXRBc3NldHNSZXF1ZXN0GiMuYml0YXNzZXRzLnYxLkxpc3RCaXRBc3NldHNS'
        'ZXNwb25zZRJhChBSZWdpc3RlckJpdEFzc2V0EiUuYml0YXNzZXRzLnYxLlJlZ2lzdGVyQml0QX'
        'NzZXRSZXF1ZXN0GiYuYml0YXNzZXRzLnYxLlJlZ2lzdGVyQml0QXNzZXRSZXNwb25zZRJeCg9S'
        'ZXNlcnZlQml0QXNzZXQSJC5iaXRhc3NldHMudjEuUmVzZXJ2ZUJpdEFzc2V0UmVxdWVzdBolLm'
        'JpdGFzc2V0cy52MS5SZXNlcnZlQml0QXNzZXRSZXNwb25zZRJhChBUcmFuc2ZlckJpdEFzc2V0'
        'EiUuYml0YXNzZXRzLnYxLlRyYW5zZmVyQml0QXNzZXRSZXF1ZXN0GiYuYml0YXNzZXRzLnYxLl'
        'RyYW5zZmVyQml0QXNzZXRSZXNwb25zZRJqChNHZXROZXdFbmNyeXB0aW9uS2V5EiguYml0YXNz'
        'ZXRzLnYxLkdldE5ld0VuY3J5cHRpb25LZXlSZXF1ZXN0GikuYml0YXNzZXRzLnYxLkdldE5ld0'
        'VuY3J5cHRpb25LZXlSZXNwb25zZRJnChJHZXROZXdWZXJpZnlpbmdLZXkSJy5iaXRhc3NldHMu'
        'djEuR2V0TmV3VmVyaWZ5aW5nS2V5UmVxdWVzdBooLmJpdGFzc2V0cy52MS5HZXROZXdWZXJpZn'
        'lpbmdLZXlSZXNwb25zZRJPCgpEZWNyeXB0TXNnEh8uYml0YXNzZXRzLnYxLkRlY3J5cHRNc2dS'
        'ZXF1ZXN0GiAuYml0YXNzZXRzLnYxLkRlY3J5cHRNc2dSZXNwb25zZRJPCgpFbmNyeXB0TXNnEh'
        '8uYml0YXNzZXRzLnYxLkVuY3J5cHRNc2dSZXF1ZXN0GiAuYml0YXNzZXRzLnYxLkVuY3J5cHRN'
        'c2dSZXNwb25zZRJhChBTaWduQXJiaXRyYXJ5TXNnEiUuYml0YXNzZXRzLnYxLlNpZ25BcmJpdH'
        'JhcnlNc2dSZXF1ZXN0GiYuYml0YXNzZXRzLnYxLlNpZ25BcmJpdHJhcnlNc2dSZXNwb25zZRJz'
        'ChZTaWduQXJiaXRyYXJ5TXNnQXNBZGRyEisuYml0YXNzZXRzLnYxLlNpZ25BcmJpdHJhcnlNc2'
        'dBc0FkZHJSZXF1ZXN0GiwuYml0YXNzZXRzLnYxLlNpZ25BcmJpdHJhcnlNc2dBc0FkZHJSZXNw'
        'b25zZRJeCg9WZXJpZnlTaWduYXR1cmUSJC5iaXRhc3NldHMudjEuVmVyaWZ5U2lnbmF0dXJlUm'
        'VxdWVzdBolLmJpdGFzc2V0cy52MS5WZXJpZnlTaWduYXR1cmVSZXNwb25zZRJnChJHZXRXYWxs'
        'ZXRBZGRyZXNzZXMSJy5iaXRhc3NldHMudjEuR2V0V2FsbGV0QWRkcmVzc2VzUmVxdWVzdBooLm'
        'JpdGFzc2V0cy52MS5HZXRXYWxsZXRBZGRyZXNzZXNSZXNwb25zZRJnChJNeVVuY29uZmlybWVk'
        'VXR4b3MSJy5iaXRhc3NldHMudjEuTXlVbmNvbmZpcm1lZFV0eG9zUmVxdWVzdBooLmJpdGFzc2'
        'V0cy52MS5NeVVuY29uZmlybWVkVXR4b3NSZXNwb25zZRJYCg1PcGVuYXBpU2NoZW1hEiIuYml0'
        'YXNzZXRzLnYxLk9wZW5hcGlTY2hlbWFSZXF1ZXN0GiMuYml0YXNzZXRzLnYxLk9wZW5hcGlTY2'
        'hlbWFSZXNwb25zZRJGCgdBbW1CdXJuEhwuYml0YXNzZXRzLnYxLkFtbUJ1cm5SZXF1ZXN0Gh0u'
        'Yml0YXNzZXRzLnYxLkFtbUJ1cm5SZXNwb25zZRJGCgdBbW1NaW50EhwuYml0YXNzZXRzLnYxLk'
        'FtbU1pbnRSZXF1ZXN0Gh0uYml0YXNzZXRzLnYxLkFtbU1pbnRSZXNwb25zZRJGCgdBbW1Td2Fw'
        'EhwuYml0YXNzZXRzLnYxLkFtbVN3YXBSZXF1ZXN0Gh0uYml0YXNzZXRzLnYxLkFtbVN3YXBSZX'
        'Nwb25zZRJeCg9HZXRBbW1Qb29sU3RhdGUSJC5iaXRhc3NldHMudjEuR2V0QW1tUG9vbFN0YXRl'
        'UmVxdWVzdBolLmJpdGFzc2V0cy52MS5HZXRBbW1Qb29sU3RhdGVSZXNwb25zZRJSCgtHZXRBbW'
        '1QcmljZRIgLmJpdGFzc2V0cy52MS5HZXRBbW1QcmljZVJlcXVlc3QaIS5iaXRhc3NldHMudjEu'
        'R2V0QW1tUHJpY2VSZXNwb25zZRJeCg9EdXRjaEF1Y3Rpb25CaWQSJC5iaXRhc3NldHMudjEuRH'
        'V0Y2hBdWN0aW9uQmlkUmVxdWVzdBolLmJpdGFzc2V0cy52MS5EdXRjaEF1Y3Rpb25CaWRSZXNw'
        'b25zZRJqChNEdXRjaEF1Y3Rpb25Db2xsZWN0EiguYml0YXNzZXRzLnYxLkR1dGNoQXVjdGlvbk'
        'NvbGxlY3RSZXF1ZXN0GikuYml0YXNzZXRzLnYxLkR1dGNoQXVjdGlvbkNvbGxlY3RSZXNwb25z'
        'ZRJnChJEdXRjaEF1Y3Rpb25DcmVhdGUSJy5iaXRhc3NldHMudjEuRHV0Y2hBdWN0aW9uQ3JlYX'
        'RlUmVxdWVzdBooLmJpdGFzc2V0cy52MS5EdXRjaEF1Y3Rpb25DcmVhdGVSZXNwb25zZRJYCg1E'
        'dXRjaEF1Y3Rpb25zEiIuYml0YXNzZXRzLnYxLkR1dGNoQXVjdGlvbnNSZXF1ZXN0GiMuYml0YX'
        'NzZXRzLnYxLkR1dGNoQXVjdGlvbnNSZXNwb25zZQ==');
