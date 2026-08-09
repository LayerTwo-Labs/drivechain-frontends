//
//  Generated code. Do not modify.
//  source: truthcoin/v1/truthcoin.proto
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
  ],
};

/// Descriptor for `TransferRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transferRequestDescriptor =
    $convert.base64Decode('Cg9UcmFuc2ZlclJlcXVlc3QSGAoHYWRkcmVzcxgBIAEoCVIHYWRkcmVzcxIfCgthbW91bnRfc2'
        'F0cxgCIAEoA1IKYW1vdW50U2F0cxIZCghmZWVfc2F0cxgDIAEoA1IHZmVlU2F0cw==');

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

@$core.Deprecated('Use refreshWalletRequestDescriptor instead')
const RefreshWalletRequest$json = {
  '1': 'RefreshWalletRequest',
};

/// Descriptor for `RefreshWalletRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List refreshWalletRequestDescriptor = $convert.base64Decode('ChRSZWZyZXNoV2FsbGV0UmVxdWVzdA==');

@$core.Deprecated('Use refreshWalletResponseDescriptor instead')
const RefreshWalletResponse$json = {
  '1': 'RefreshWalletResponse',
};

/// Descriptor for `RefreshWalletResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List refreshWalletResponseDescriptor = $convert.base64Decode('ChVSZWZyZXNoV2FsbGV0UmVzcG9uc2U=');

@$core.Deprecated('Use getTransactionRequestDescriptor instead')
const GetTransactionRequest$json = {
  '1': 'GetTransactionRequest',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `GetTransactionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTransactionRequestDescriptor =
    $convert.base64Decode('ChVHZXRUcmFuc2FjdGlvblJlcXVlc3QSEgoEdHhpZBgBIAEoCVIEdHhpZA==');

@$core.Deprecated('Use getTransactionResponseDescriptor instead')
const GetTransactionResponse$json = {
  '1': 'GetTransactionResponse',
  '2': [
    {'1': 'transaction_json', '3': 1, '4': 1, '5': 9, '10': 'transactionJson'},
  ],
};

/// Descriptor for `GetTransactionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTransactionResponseDescriptor =
    $convert.base64Decode('ChZHZXRUcmFuc2FjdGlvblJlc3BvbnNlEikKEHRyYW5zYWN0aW9uX2pzb24YASABKAlSD3RyYW'
        '5zYWN0aW9uSnNvbg==');

@$core.Deprecated('Use getTransactionInfoRequestDescriptor instead')
const GetTransactionInfoRequest$json = {
  '1': 'GetTransactionInfoRequest',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `GetTransactionInfoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTransactionInfoRequestDescriptor =
    $convert.base64Decode('ChlHZXRUcmFuc2FjdGlvbkluZm9SZXF1ZXN0EhIKBHR4aWQYASABKAlSBHR4aWQ=');

@$core.Deprecated('Use getTransactionInfoResponseDescriptor instead')
const GetTransactionInfoResponse$json = {
  '1': 'GetTransactionInfoResponse',
  '2': [
    {'1': 'transaction_info_json', '3': 1, '4': 1, '5': 9, '10': 'transactionInfoJson'},
  ],
};

/// Descriptor for `GetTransactionInfoResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTransactionInfoResponseDescriptor =
    $convert.base64Decode('ChpHZXRUcmFuc2FjdGlvbkluZm9SZXNwb25zZRIyChV0cmFuc2FjdGlvbl9pbmZvX2pzb24YAS'
        'ABKAlSE3RyYW5zYWN0aW9uSW5mb0pzb24=');

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

@$core.Deprecated('Use myUtxosRequestDescriptor instead')
const MyUtxosRequest$json = {
  '1': 'MyUtxosRequest',
};

/// Descriptor for `MyUtxosRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List myUtxosRequestDescriptor = $convert.base64Decode('Cg5NeVV0eG9zUmVxdWVzdA==');

@$core.Deprecated('Use myUtxosResponseDescriptor instead')
const MyUtxosResponse$json = {
  '1': 'MyUtxosResponse',
  '2': [
    {'1': 'utxos_json', '3': 1, '4': 1, '5': 9, '10': 'utxosJson'},
  ],
};

/// Descriptor for `MyUtxosResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List myUtxosResponseDescriptor =
    $convert.base64Decode('Cg9NeVV0eG9zUmVzcG9uc2USHQoKdXR4b3NfanNvbhgBIAEoCVIJdXR4b3NKc29u');

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

@$core.Deprecated('Use calculateInitialLiquidityRequestDescriptor instead')
const CalculateInitialLiquidityRequest$json = {
  '1': 'CalculateInitialLiquidityRequest',
  '2': [
    {'1': 'beta', '3': 1, '4': 1, '5': 1, '10': 'beta'},
    {'1': 'num_outcomes', '3': 2, '4': 1, '5': 5, '9': 0, '10': 'numOutcomes', '17': true},
    {'1': 'dimensions', '3': 3, '4': 1, '5': 9, '9': 1, '10': 'dimensions', '17': true},
  ],
  '8': [
    {'1': '_num_outcomes'},
    {'1': '_dimensions'},
  ],
};

/// Descriptor for `CalculateInitialLiquidityRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List calculateInitialLiquidityRequestDescriptor =
    $convert.base64Decode('CiBDYWxjdWxhdGVJbml0aWFsTGlxdWlkaXR5UmVxdWVzdBISCgRiZXRhGAEgASgBUgRiZXRhEi'
        'YKDG51bV9vdXRjb21lcxgCIAEoBUgAUgtudW1PdXRjb21lc4gBARIjCgpkaW1lbnNpb25zGAMg'
        'ASgJSAFSCmRpbWVuc2lvbnOIAQFCDwoNX251bV9vdXRjb21lc0INCgtfZGltZW5zaW9ucw==');

@$core.Deprecated('Use calculateInitialLiquidityResponseDescriptor instead')
const CalculateInitialLiquidityResponse$json = {
  '1': 'CalculateInitialLiquidityResponse',
  '2': [
    {'1': 'result_json', '3': 1, '4': 1, '5': 9, '10': 'resultJson'},
  ],
};

/// Descriptor for `CalculateInitialLiquidityResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List calculateInitialLiquidityResponseDescriptor =
    $convert.base64Decode('CiFDYWxjdWxhdGVJbml0aWFsTGlxdWlkaXR5UmVzcG9uc2USHwoLcmVzdWx0X2pzb24YASABKA'
        'lSCnJlc3VsdEpzb24=');

@$core.Deprecated('Use marketCreateRequestDescriptor instead')
const MarketCreateRequest$json = {
  '1': 'MarketCreateRequest',
  '2': [
    {'1': 'title', '3': 1, '4': 1, '5': 9, '10': 'title'},
    {'1': 'description', '3': 2, '4': 1, '5': 9, '10': 'description'},
    {'1': 'dimensions', '3': 3, '4': 1, '5': 9, '10': 'dimensions'},
    {'1': 'fee_sats', '3': 4, '4': 1, '5': 3, '10': 'feeSats'},
    {'1': 'beta', '3': 5, '4': 1, '5': 1, '9': 0, '10': 'beta', '17': true},
    {'1': 'initial_liquidity', '3': 6, '4': 1, '5': 3, '9': 1, '10': 'initialLiquidity', '17': true},
    {'1': 'trading_fee', '3': 7, '4': 1, '5': 1, '9': 2, '10': 'tradingFee', '17': true},
    {'1': 'tags', '3': 8, '4': 3, '5': 9, '10': 'tags'},
    {'1': 'category_txids', '3': 9, '4': 3, '5': 9, '10': 'categoryTxids'},
    {'1': 'residual_names', '3': 10, '4': 3, '5': 9, '10': 'residualNames'},
  ],
  '8': [
    {'1': '_beta'},
    {'1': '_initial_liquidity'},
    {'1': '_trading_fee'},
  ],
};

/// Descriptor for `MarketCreateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List marketCreateRequestDescriptor =
    $convert.base64Decode('ChNNYXJrZXRDcmVhdGVSZXF1ZXN0EhQKBXRpdGxlGAEgASgJUgV0aXRsZRIgCgtkZXNjcmlwdG'
        'lvbhgCIAEoCVILZGVzY3JpcHRpb24SHgoKZGltZW5zaW9ucxgDIAEoCVIKZGltZW5zaW9ucxIZ'
        'CghmZWVfc2F0cxgEIAEoA1IHZmVlU2F0cxIXCgRiZXRhGAUgASgBSABSBGJldGGIAQESMAoRaW'
        '5pdGlhbF9saXF1aWRpdHkYBiABKANIAVIQaW5pdGlhbExpcXVpZGl0eYgBARIkCgt0cmFkaW5n'
        'X2ZlZRgHIAEoAUgCUgp0cmFkaW5nRmVliAEBEhIKBHRhZ3MYCCADKAlSBHRhZ3MSJQoOY2F0ZW'
        'dvcnlfdHhpZHMYCSADKAlSDWNhdGVnb3J5VHhpZHMSJQoOcmVzaWR1YWxfbmFtZXMYCiADKAlS'
        'DXJlc2lkdWFsTmFtZXNCBwoFX2JldGFCFAoSX2luaXRpYWxfbGlxdWlkaXR5Qg4KDF90cmFkaW'
        '5nX2ZlZQ==');

@$core.Deprecated('Use marketCreateResponseDescriptor instead')
const MarketCreateResponse$json = {
  '1': 'MarketCreateResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `MarketCreateResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List marketCreateResponseDescriptor =
    $convert.base64Decode('ChRNYXJrZXRDcmVhdGVSZXNwb25zZRISCgR0eGlkGAEgASgJUgR0eGlk');

@$core.Deprecated('Use marketListRequestDescriptor instead')
const MarketListRequest$json = {
  '1': 'MarketListRequest',
};

/// Descriptor for `MarketListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List marketListRequestDescriptor = $convert.base64Decode('ChFNYXJrZXRMaXN0UmVxdWVzdA==');

@$core.Deprecated('Use marketListResponseDescriptor instead')
const MarketListResponse$json = {
  '1': 'MarketListResponse',
  '2': [
    {'1': 'markets_json', '3': 1, '4': 1, '5': 9, '10': 'marketsJson'},
  ],
};

/// Descriptor for `MarketListResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List marketListResponseDescriptor =
    $convert.base64Decode('ChJNYXJrZXRMaXN0UmVzcG9uc2USIQoMbWFya2V0c19qc29uGAEgASgJUgttYXJrZXRzSnNvbg'
        '==');

@$core.Deprecated('Use marketGetRequestDescriptor instead')
const MarketGetRequest$json = {
  '1': 'MarketGetRequest',
  '2': [
    {'1': 'market_id', '3': 1, '4': 1, '5': 9, '10': 'marketId'},
  ],
};

/// Descriptor for `MarketGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List marketGetRequestDescriptor =
    $convert.base64Decode('ChBNYXJrZXRHZXRSZXF1ZXN0EhsKCW1hcmtldF9pZBgBIAEoCVIIbWFya2V0SWQ=');

@$core.Deprecated('Use marketGetResponseDescriptor instead')
const MarketGetResponse$json = {
  '1': 'MarketGetResponse',
  '2': [
    {'1': 'market_json', '3': 1, '4': 1, '5': 9, '10': 'marketJson'},
  ],
};

/// Descriptor for `MarketGetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List marketGetResponseDescriptor =
    $convert.base64Decode('ChFNYXJrZXRHZXRSZXNwb25zZRIfCgttYXJrZXRfanNvbhgBIAEoCVIKbWFya2V0SnNvbg==');

@$core.Deprecated('Use marketBuyRequestDescriptor instead')
const MarketBuyRequest$json = {
  '1': 'MarketBuyRequest',
  '2': [
    {'1': 'market_id', '3': 1, '4': 1, '5': 9, '10': 'marketId'},
    {'1': 'outcome_index', '3': 2, '4': 1, '5': 5, '10': 'outcomeIndex'},
    {'1': 'shares_amount', '3': 3, '4': 1, '5': 1, '10': 'sharesAmount'},
    {'1': 'dry_run', '3': 4, '4': 1, '5': 8, '9': 0, '10': 'dryRun', '17': true},
    {'1': 'fee_sats', '3': 5, '4': 1, '5': 3, '9': 1, '10': 'feeSats', '17': true},
    {'1': 'max_cost', '3': 6, '4': 1, '5': 3, '9': 2, '10': 'maxCost', '17': true},
  ],
  '8': [
    {'1': '_dry_run'},
    {'1': '_fee_sats'},
    {'1': '_max_cost'},
  ],
};

/// Descriptor for `MarketBuyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List marketBuyRequestDescriptor =
    $convert.base64Decode('ChBNYXJrZXRCdXlSZXF1ZXN0EhsKCW1hcmtldF9pZBgBIAEoCVIIbWFya2V0SWQSIwoNb3V0Y2'
        '9tZV9pbmRleBgCIAEoBVIMb3V0Y29tZUluZGV4EiMKDXNoYXJlc19hbW91bnQYAyABKAFSDHNo'
        'YXJlc0Ftb3VudBIcCgdkcnlfcnVuGAQgASgISABSBmRyeVJ1bogBARIeCghmZWVfc2F0cxgFIA'
        'EoA0gBUgdmZWVTYXRziAEBEh4KCG1heF9jb3N0GAYgASgDSAJSB21heENvc3SIAQFCCgoIX2Ry'
        'eV9ydW5CCwoJX2ZlZV9zYXRzQgsKCV9tYXhfY29zdA==');

@$core.Deprecated('Use marketBuyResponseDescriptor instead')
const MarketBuyResponse$json = {
  '1': 'MarketBuyResponse',
  '2': [
    {'1': 'result_json', '3': 1, '4': 1, '5': 9, '10': 'resultJson'},
  ],
};

/// Descriptor for `MarketBuyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List marketBuyResponseDescriptor =
    $convert.base64Decode('ChFNYXJrZXRCdXlSZXNwb25zZRIfCgtyZXN1bHRfanNvbhgBIAEoCVIKcmVzdWx0SnNvbg==');

@$core.Deprecated('Use marketSellRequestDescriptor instead')
const MarketSellRequest$json = {
  '1': 'MarketSellRequest',
  '2': [
    {'1': 'market_id', '3': 1, '4': 1, '5': 9, '10': 'marketId'},
    {'1': 'outcome_index', '3': 2, '4': 1, '5': 5, '10': 'outcomeIndex'},
    {'1': 'shares_amount', '3': 3, '4': 1, '5': 3, '10': 'sharesAmount'},
    {'1': 'seller_address', '3': 4, '4': 1, '5': 9, '10': 'sellerAddress'},
    {'1': 'dry_run', '3': 5, '4': 1, '5': 8, '9': 0, '10': 'dryRun', '17': true},
    {'1': 'fee_sats', '3': 6, '4': 1, '5': 3, '9': 1, '10': 'feeSats', '17': true},
    {'1': 'min_proceeds', '3': 7, '4': 1, '5': 3, '9': 2, '10': 'minProceeds', '17': true},
  ],
  '8': [
    {'1': '_dry_run'},
    {'1': '_fee_sats'},
    {'1': '_min_proceeds'},
  ],
};

/// Descriptor for `MarketSellRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List marketSellRequestDescriptor =
    $convert.base64Decode('ChFNYXJrZXRTZWxsUmVxdWVzdBIbCgltYXJrZXRfaWQYASABKAlSCG1hcmtldElkEiMKDW91dG'
        'NvbWVfaW5kZXgYAiABKAVSDG91dGNvbWVJbmRleBIjCg1zaGFyZXNfYW1vdW50GAMgASgDUgxz'
        'aGFyZXNBbW91bnQSJQoOc2VsbGVyX2FkZHJlc3MYBCABKAlSDXNlbGxlckFkZHJlc3MSHAoHZH'
        'J5X3J1bhgFIAEoCEgAUgZkcnlSdW6IAQESHgoIZmVlX3NhdHMYBiABKANIAVIHZmVlU2F0c4gB'
        'ARImCgxtaW5fcHJvY2VlZHMYByABKANIAlILbWluUHJvY2VlZHOIAQFCCgoIX2RyeV9ydW5CCw'
        'oJX2ZlZV9zYXRzQg8KDV9taW5fcHJvY2VlZHM=');

@$core.Deprecated('Use marketSellResponseDescriptor instead')
const MarketSellResponse$json = {
  '1': 'MarketSellResponse',
  '2': [
    {'1': 'result_json', '3': 1, '4': 1, '5': 9, '10': 'resultJson'},
  ],
};

/// Descriptor for `MarketSellResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List marketSellResponseDescriptor =
    $convert.base64Decode('ChJNYXJrZXRTZWxsUmVzcG9uc2USHwoLcmVzdWx0X2pzb24YASABKAlSCnJlc3VsdEpzb24=');

@$core.Deprecated('Use marketPositionsRequestDescriptor instead')
const MarketPositionsRequest$json = {
  '1': 'MarketPositionsRequest',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '9': 0, '10': 'address', '17': true},
    {'1': 'market_id', '3': 2, '4': 1, '5': 9, '9': 1, '10': 'marketId', '17': true},
  ],
  '8': [
    {'1': '_address'},
    {'1': '_market_id'},
  ],
};

/// Descriptor for `MarketPositionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List marketPositionsRequestDescriptor =
    $convert.base64Decode('ChZNYXJrZXRQb3NpdGlvbnNSZXF1ZXN0Eh0KB2FkZHJlc3MYASABKAlIAFIHYWRkcmVzc4gBAR'
        'IgCgltYXJrZXRfaWQYAiABKAlIAVIIbWFya2V0SWSIAQFCCgoIX2FkZHJlc3NCDAoKX21hcmtl'
        'dF9pZA==');

@$core.Deprecated('Use marketPositionsResponseDescriptor instead')
const MarketPositionsResponse$json = {
  '1': 'MarketPositionsResponse',
  '2': [
    {'1': 'positions_json', '3': 1, '4': 1, '5': 9, '10': 'positionsJson'},
  ],
};

/// Descriptor for `MarketPositionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List marketPositionsResponseDescriptor =
    $convert.base64Decode('ChdNYXJrZXRQb3NpdGlvbnNSZXNwb25zZRIlCg5wb3NpdGlvbnNfanNvbhgBIAEoCVINcG9zaX'
        'Rpb25zSnNvbg==');

@$core.Deprecated('Use slotStatusRequestDescriptor instead')
const SlotStatusRequest$json = {
  '1': 'SlotStatusRequest',
};

/// Descriptor for `SlotStatusRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List slotStatusRequestDescriptor = $convert.base64Decode('ChFTbG90U3RhdHVzUmVxdWVzdA==');

@$core.Deprecated('Use slotStatusResponseDescriptor instead')
const SlotStatusResponse$json = {
  '1': 'SlotStatusResponse',
  '2': [
    {'1': 'status_json', '3': 1, '4': 1, '5': 9, '10': 'statusJson'},
  ],
};

/// Descriptor for `SlotStatusResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List slotStatusResponseDescriptor =
    $convert.base64Decode('ChJTbG90U3RhdHVzUmVzcG9uc2USHwoLc3RhdHVzX2pzb24YASABKAlSCnN0YXR1c0pzb24=');

@$core.Deprecated('Use slotListRequestDescriptor instead')
const SlotListRequest$json = {
  '1': 'SlotListRequest',
  '2': [
    {'1': 'period', '3': 1, '4': 1, '5': 5, '9': 0, '10': 'period', '17': true},
    {'1': 'status', '3': 2, '4': 1, '5': 9, '9': 1, '10': 'status', '17': true},
  ],
  '8': [
    {'1': '_period'},
    {'1': '_status'},
  ],
};

/// Descriptor for `SlotListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List slotListRequestDescriptor =
    $convert.base64Decode('Cg9TbG90TGlzdFJlcXVlc3QSGwoGcGVyaW9kGAEgASgFSABSBnBlcmlvZIgBARIbCgZzdGF0dX'
        'MYAiABKAlIAVIGc3RhdHVziAEBQgkKB19wZXJpb2RCCQoHX3N0YXR1cw==');

@$core.Deprecated('Use slotListResponseDescriptor instead')
const SlotListResponse$json = {
  '1': 'SlotListResponse',
  '2': [
    {'1': 'slots_json', '3': 1, '4': 1, '5': 9, '10': 'slotsJson'},
  ],
};

/// Descriptor for `SlotListResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List slotListResponseDescriptor =
    $convert.base64Decode('ChBTbG90TGlzdFJlc3BvbnNlEh0KCnNsb3RzX2pzb24YASABKAlSCXNsb3RzSnNvbg==');

@$core.Deprecated('Use slotGetRequestDescriptor instead')
const SlotGetRequest$json = {
  '1': 'SlotGetRequest',
  '2': [
    {'1': 'slot_id', '3': 1, '4': 1, '5': 9, '10': 'slotId'},
  ],
};

/// Descriptor for `SlotGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List slotGetRequestDescriptor =
    $convert.base64Decode('Cg5TbG90R2V0UmVxdWVzdBIXCgdzbG90X2lkGAEgASgJUgZzbG90SWQ=');

@$core.Deprecated('Use slotGetResponseDescriptor instead')
const SlotGetResponse$json = {
  '1': 'SlotGetResponse',
  '2': [
    {'1': 'slot_json', '3': 1, '4': 1, '5': 9, '10': 'slotJson'},
  ],
};

/// Descriptor for `SlotGetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List slotGetResponseDescriptor =
    $convert.base64Decode('Cg9TbG90R2V0UmVzcG9uc2USGwoJc2xvdF9qc29uGAEgASgJUghzbG90SnNvbg==');

@$core.Deprecated('Use slotClaimRequestDescriptor instead')
const SlotClaimRequest$json = {
  '1': 'SlotClaimRequest',
  '2': [
    {'1': 'fee_sats', '3': 1, '4': 1, '5': 3, '10': 'feeSats'},
    {'1': 'period_index', '3': 2, '4': 1, '5': 5, '10': 'periodIndex'},
    {'1': 'slot_index', '3': 3, '4': 1, '5': 5, '10': 'slotIndex'},
    {'1': 'question', '3': 4, '4': 1, '5': 9, '10': 'question'},
    {'1': 'is_standard', '3': 5, '4': 1, '5': 8, '10': 'isStandard'},
    {'1': 'is_scaled', '3': 6, '4': 1, '5': 8, '9': 0, '10': 'isScaled', '17': true},
    {'1': 'min', '3': 7, '4': 1, '5': 5, '9': 1, '10': 'min', '17': true},
    {'1': 'max', '3': 8, '4': 1, '5': 5, '9': 2, '10': 'max', '17': true},
  ],
  '8': [
    {'1': '_is_scaled'},
    {'1': '_min'},
    {'1': '_max'},
  ],
};

/// Descriptor for `SlotClaimRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List slotClaimRequestDescriptor =
    $convert.base64Decode('ChBTbG90Q2xhaW1SZXF1ZXN0EhkKCGZlZV9zYXRzGAEgASgDUgdmZWVTYXRzEiEKDHBlcmlvZF'
        '9pbmRleBgCIAEoBVILcGVyaW9kSW5kZXgSHQoKc2xvdF9pbmRleBgDIAEoBVIJc2xvdEluZGV4'
        'EhoKCHF1ZXN0aW9uGAQgASgJUghxdWVzdGlvbhIfCgtpc19zdGFuZGFyZBgFIAEoCFIKaXNTdG'
        'FuZGFyZBIgCglpc19zY2FsZWQYBiABKAhIAFIIaXNTY2FsZWSIAQESFQoDbWluGAcgASgFSAFS'
        'A21pbogBARIVCgNtYXgYCCABKAVIAlIDbWF4iAEBQgwKCl9pc19zY2FsZWRCBgoEX21pbkIGCg'
        'RfbWF4');

@$core.Deprecated('Use slotClaimResponseDescriptor instead')
const SlotClaimResponse$json = {
  '1': 'SlotClaimResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `SlotClaimResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List slotClaimResponseDescriptor =
    $convert.base64Decode('ChFTbG90Q2xhaW1SZXNwb25zZRISCgR0eGlkGAEgASgJUgR0eGlk');

@$core.Deprecated('Use slotClaimCategoryRequestDescriptor instead')
const SlotClaimCategoryRequest$json = {
  '1': 'SlotClaimCategoryRequest',
  '2': [
    {'1': 'slots_json', '3': 1, '4': 1, '5': 9, '10': 'slotsJson'},
    {'1': 'is_standard', '3': 2, '4': 1, '5': 8, '10': 'isStandard'},
    {'1': 'fee_sats', '3': 3, '4': 1, '5': 3, '10': 'feeSats'},
  ],
};

/// Descriptor for `SlotClaimCategoryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List slotClaimCategoryRequestDescriptor =
    $convert.base64Decode('ChhTbG90Q2xhaW1DYXRlZ29yeVJlcXVlc3QSHQoKc2xvdHNfanNvbhgBIAEoCVIJc2xvdHNKc2'
        '9uEh8KC2lzX3N0YW5kYXJkGAIgASgIUgppc1N0YW5kYXJkEhkKCGZlZV9zYXRzGAMgASgDUgdm'
        'ZWVTYXRz');

@$core.Deprecated('Use slotClaimCategoryResponseDescriptor instead')
const SlotClaimCategoryResponse$json = {
  '1': 'SlotClaimCategoryResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `SlotClaimCategoryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List slotClaimCategoryResponseDescriptor =
    $convert.base64Decode('ChlTbG90Q2xhaW1DYXRlZ29yeVJlc3BvbnNlEhIKBHR4aWQYASABKAlSBHR4aWQ=');

@$core.Deprecated('Use voteRegisterRequestDescriptor instead')
const VoteRegisterRequest$json = {
  '1': 'VoteRegisterRequest',
  '2': [
    {'1': 'fee_sats', '3': 1, '4': 1, '5': 3, '10': 'feeSats'},
    {'1': 'reputation_bond_sats', '3': 2, '4': 1, '5': 3, '9': 0, '10': 'reputationBondSats', '17': true},
  ],
  '8': [
    {'1': '_reputation_bond_sats'},
  ],
};

/// Descriptor for `VoteRegisterRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List voteRegisterRequestDescriptor =
    $convert.base64Decode('ChNWb3RlUmVnaXN0ZXJSZXF1ZXN0EhkKCGZlZV9zYXRzGAEgASgDUgdmZWVTYXRzEjUKFHJlcH'
        'V0YXRpb25fYm9uZF9zYXRzGAIgASgDSABSEnJlcHV0YXRpb25Cb25kU2F0c4gBAUIXChVfcmVw'
        'dXRhdGlvbl9ib25kX3NhdHM=');

@$core.Deprecated('Use voteRegisterResponseDescriptor instead')
const VoteRegisterResponse$json = {
  '1': 'VoteRegisterResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `VoteRegisterResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List voteRegisterResponseDescriptor =
    $convert.base64Decode('ChRWb3RlUmVnaXN0ZXJSZXNwb25zZRISCgR0eGlkGAEgASgJUgR0eGlk');

@$core.Deprecated('Use voteVoterRequestDescriptor instead')
const VoteVoterRequest$json = {
  '1': 'VoteVoterRequest',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
  ],
};

/// Descriptor for `VoteVoterRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List voteVoterRequestDescriptor =
    $convert.base64Decode('ChBWb3RlVm90ZXJSZXF1ZXN0EhgKB2FkZHJlc3MYASABKAlSB2FkZHJlc3M=');

@$core.Deprecated('Use voteVoterResponseDescriptor instead')
const VoteVoterResponse$json = {
  '1': 'VoteVoterResponse',
  '2': [
    {'1': 'voter_json', '3': 1, '4': 1, '5': 9, '10': 'voterJson'},
  ],
};

/// Descriptor for `VoteVoterResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List voteVoterResponseDescriptor =
    $convert.base64Decode('ChFWb3RlVm90ZXJSZXNwb25zZRIdCgp2b3Rlcl9qc29uGAEgASgJUgl2b3Rlckpzb24=');

@$core.Deprecated('Use voteVotersRequestDescriptor instead')
const VoteVotersRequest$json = {
  '1': 'VoteVotersRequest',
};

/// Descriptor for `VoteVotersRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List voteVotersRequestDescriptor = $convert.base64Decode('ChFWb3RlVm90ZXJzUmVxdWVzdA==');

@$core.Deprecated('Use voteVotersResponseDescriptor instead')
const VoteVotersResponse$json = {
  '1': 'VoteVotersResponse',
  '2': [
    {'1': 'voters_json', '3': 1, '4': 1, '5': 9, '10': 'votersJson'},
  ],
};

/// Descriptor for `VoteVotersResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List voteVotersResponseDescriptor =
    $convert.base64Decode('ChJWb3RlVm90ZXJzUmVzcG9uc2USHwoLdm90ZXJzX2pzb24YASABKAlSCnZvdGVyc0pzb24=');

@$core.Deprecated('Use voteSubmitRequestDescriptor instead')
const VoteSubmitRequest$json = {
  '1': 'VoteSubmitRequest',
  '2': [
    {'1': 'votes_json', '3': 1, '4': 1, '5': 9, '10': 'votesJson'},
    {'1': 'fee_sats', '3': 2, '4': 1, '5': 3, '10': 'feeSats'},
  ],
};

/// Descriptor for `VoteSubmitRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List voteSubmitRequestDescriptor =
    $convert.base64Decode('ChFWb3RlU3VibWl0UmVxdWVzdBIdCgp2b3Rlc19qc29uGAEgASgJUgl2b3Rlc0pzb24SGQoIZm'
        'VlX3NhdHMYAiABKANSB2ZlZVNhdHM=');

@$core.Deprecated('Use voteSubmitResponseDescriptor instead')
const VoteSubmitResponse$json = {
  '1': 'VoteSubmitResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `VoteSubmitResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List voteSubmitResponseDescriptor =
    $convert.base64Decode('ChJWb3RlU3VibWl0UmVzcG9uc2USEgoEdHhpZBgBIAEoCVIEdHhpZA==');

@$core.Deprecated('Use voteListRequestDescriptor instead')
const VoteListRequest$json = {
  '1': 'VoteListRequest',
  '2': [
    {'1': 'voter', '3': 1, '4': 1, '5': 9, '9': 0, '10': 'voter', '17': true},
    {'1': 'decision_id', '3': 2, '4': 1, '5': 9, '9': 1, '10': 'decisionId', '17': true},
    {'1': 'period_id', '3': 3, '4': 1, '5': 5, '9': 2, '10': 'periodId', '17': true},
  ],
  '8': [
    {'1': '_voter'},
    {'1': '_decision_id'},
    {'1': '_period_id'},
  ],
};

/// Descriptor for `VoteListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List voteListRequestDescriptor =
    $convert.base64Decode('Cg9Wb3RlTGlzdFJlcXVlc3QSGQoFdm90ZXIYASABKAlIAFIFdm90ZXKIAQESJAoLZGVjaXNpb2'
        '5faWQYAiABKAlIAVIKZGVjaXNpb25JZIgBARIgCglwZXJpb2RfaWQYAyABKAVIAlIIcGVyaW9k'
        'SWSIAQFCCAoGX3ZvdGVyQg4KDF9kZWNpc2lvbl9pZEIMCgpfcGVyaW9kX2lk');

@$core.Deprecated('Use voteListResponseDescriptor instead')
const VoteListResponse$json = {
  '1': 'VoteListResponse',
  '2': [
    {'1': 'votes_json', '3': 1, '4': 1, '5': 9, '10': 'votesJson'},
  ],
};

/// Descriptor for `VoteListResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List voteListResponseDescriptor =
    $convert.base64Decode('ChBWb3RlTGlzdFJlc3BvbnNlEh0KCnZvdGVzX2pzb24YASABKAlSCXZvdGVzSnNvbg==');

@$core.Deprecated('Use votePeriodRequestDescriptor instead')
const VotePeriodRequest$json = {
  '1': 'VotePeriodRequest',
  '2': [
    {'1': 'period_id', '3': 1, '4': 1, '5': 5, '9': 0, '10': 'periodId', '17': true},
  ],
  '8': [
    {'1': '_period_id'},
  ],
};

/// Descriptor for `VotePeriodRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List votePeriodRequestDescriptor =
    $convert.base64Decode('ChFWb3RlUGVyaW9kUmVxdWVzdBIgCglwZXJpb2RfaWQYASABKAVIAFIIcGVyaW9kSWSIAQFCDA'
        'oKX3BlcmlvZF9pZA==');

@$core.Deprecated('Use votePeriodResponseDescriptor instead')
const VotePeriodResponse$json = {
  '1': 'VotePeriodResponse',
  '2': [
    {'1': 'period_json', '3': 1, '4': 1, '5': 9, '10': 'periodJson'},
  ],
};

/// Descriptor for `VotePeriodResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List votePeriodResponseDescriptor =
    $convert.base64Decode('ChJWb3RlUGVyaW9kUmVzcG9uc2USHwoLcGVyaW9kX2pzb24YASABKAlSCnBlcmlvZEpzb24=');

@$core.Deprecated('Use votecoinTransferRequestDescriptor instead')
const VotecoinTransferRequest$json = {
  '1': 'VotecoinTransferRequest',
  '2': [
    {'1': 'dest', '3': 1, '4': 1, '5': 9, '10': 'dest'},
    {'1': 'amount', '3': 2, '4': 1, '5': 3, '10': 'amount'},
    {'1': 'fee_sats', '3': 3, '4': 1, '5': 3, '10': 'feeSats'},
    {'1': 'memo', '3': 4, '4': 1, '5': 9, '9': 0, '10': 'memo', '17': true},
  ],
  '8': [
    {'1': '_memo'},
  ],
};

/// Descriptor for `VotecoinTransferRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List votecoinTransferRequestDescriptor =
    $convert.base64Decode('ChdWb3RlY29pblRyYW5zZmVyUmVxdWVzdBISCgRkZXN0GAEgASgJUgRkZXN0EhYKBmFtb3VudB'
        'gCIAEoA1IGYW1vdW50EhkKCGZlZV9zYXRzGAMgASgDUgdmZWVTYXRzEhcKBG1lbW8YBCABKAlI'
        'AFIEbWVtb4gBAUIHCgVfbWVtbw==');

@$core.Deprecated('Use votecoinTransferResponseDescriptor instead')
const VotecoinTransferResponse$json = {
  '1': 'VotecoinTransferResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `VotecoinTransferResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List votecoinTransferResponseDescriptor =
    $convert.base64Decode('ChhWb3RlY29pblRyYW5zZmVyUmVzcG9uc2USEgoEdHhpZBgBIAEoCVIEdHhpZA==');

@$core.Deprecated('Use votecoinBalanceRequestDescriptor instead')
const VotecoinBalanceRequest$json = {
  '1': 'VotecoinBalanceRequest',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
  ],
};

/// Descriptor for `VotecoinBalanceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List votecoinBalanceRequestDescriptor =
    $convert.base64Decode('ChZWb3RlY29pbkJhbGFuY2VSZXF1ZXN0EhgKB2FkZHJlc3MYASABKAlSB2FkZHJlc3M=');

@$core.Deprecated('Use votecoinBalanceResponseDescriptor instead')
const VotecoinBalanceResponse$json = {
  '1': 'VotecoinBalanceResponse',
  '2': [
    {'1': 'balance', '3': 1, '4': 1, '5': 3, '10': 'balance'},
  ],
};

/// Descriptor for `VotecoinBalanceResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List votecoinBalanceResponseDescriptor =
    $convert.base64Decode('ChdWb3RlY29pbkJhbGFuY2VSZXNwb25zZRIYCgdiYWxhbmNlGAEgASgDUgdiYWxhbmNl');

@$core.Deprecated('Use transferVotecoinRequestDescriptor instead')
const TransferVotecoinRequest$json = {
  '1': 'TransferVotecoinRequest',
  '2': [
    {'1': 'dest', '3': 1, '4': 1, '5': 9, '10': 'dest'},
    {'1': 'amount', '3': 2, '4': 1, '5': 3, '10': 'amount'},
    {'1': 'fee_sats', '3': 3, '4': 1, '5': 3, '10': 'feeSats'},
    {'1': 'memo', '3': 4, '4': 1, '5': 9, '9': 0, '10': 'memo', '17': true},
  ],
  '8': [
    {'1': '_memo'},
  ],
};

/// Descriptor for `TransferVotecoinRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transferVotecoinRequestDescriptor =
    $convert.base64Decode('ChdUcmFuc2ZlclZvdGVjb2luUmVxdWVzdBISCgRkZXN0GAEgASgJUgRkZXN0EhYKBmFtb3VudB'
        'gCIAEoA1IGYW1vdW50EhkKCGZlZV9zYXRzGAMgASgDUgdmZWVTYXRzEhcKBG1lbW8YBCABKAlI'
        'AFIEbWVtb4gBAUIHCgVfbWVtbw==');

@$core.Deprecated('Use transferVotecoinResponseDescriptor instead')
const TransferVotecoinResponse$json = {
  '1': 'TransferVotecoinResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `TransferVotecoinResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transferVotecoinResponseDescriptor =
    $convert.base64Decode('ChhUcmFuc2ZlclZvdGVjb2luUmVzcG9uc2USEgoEdHhpZBgBIAEoCVIEdHhpZA==');

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
    {'1': 'dst', '3': 4, '4': 1, '5': 9, '10': 'dst'},
  ],
};

/// Descriptor for `VerifySignatureRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List verifySignatureRequestDescriptor =
    $convert.base64Decode('ChZWZXJpZnlTaWduYXR1cmVSZXF1ZXN0EhAKA21zZxgBIAEoCVIDbXNnEhwKCXNpZ25hdHVyZR'
        'gCIAEoCVIJc2lnbmF0dXJlEiMKDXZlcmlmeWluZ19rZXkYAyABKAlSDHZlcmlmeWluZ0tleRIQ'
        'CgNkc3QYBCABKAlSA2RzdA==');

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

const $core.Map<$core.String, $core.dynamic> TruthcoinServiceBase$json = {
  '1': 'TruthcoinService',
  '2': [
    {'1': 'GetBalance', '2': '.truthcoin.v1.GetBalanceRequest', '3': '.truthcoin.v1.GetBalanceResponse'},
    {'1': 'GetBlockCount', '2': '.truthcoin.v1.GetBlockCountRequest', '3': '.truthcoin.v1.GetBlockCountResponse'},
    {'1': 'Stop', '2': '.truthcoin.v1.StopRequest', '3': '.truthcoin.v1.StopResponse'},
    {'1': 'GetNewAddress', '2': '.truthcoin.v1.GetNewAddressRequest', '3': '.truthcoin.v1.GetNewAddressResponse'},
    {'1': 'Withdraw', '2': '.truthcoin.v1.WithdrawRequest', '3': '.truthcoin.v1.WithdrawResponse'},
    {'1': 'Transfer', '2': '.truthcoin.v1.TransferRequest', '3': '.truthcoin.v1.TransferResponse'},
    {
      '1': 'GetSidechainWealth',
      '2': '.truthcoin.v1.GetSidechainWealthRequest',
      '3': '.truthcoin.v1.GetSidechainWealthResponse'
    },
    {'1': 'CreateDeposit', '2': '.truthcoin.v1.CreateDepositRequest', '3': '.truthcoin.v1.CreateDepositResponse'},
    {
      '1': 'GetPendingWithdrawalBundle',
      '2': '.truthcoin.v1.GetPendingWithdrawalBundleRequest',
      '3': '.truthcoin.v1.GetPendingWithdrawalBundleResponse'
    },
    {'1': 'ConnectPeer', '2': '.truthcoin.v1.ConnectPeerRequest', '3': '.truthcoin.v1.ConnectPeerResponse'},
    {'1': 'ListPeers', '2': '.truthcoin.v1.ListPeersRequest', '3': '.truthcoin.v1.ListPeersResponse'},
    {'1': 'Mine', '2': '.truthcoin.v1.MineRequest', '3': '.truthcoin.v1.MineResponse'},
    {'1': 'GetBlock', '2': '.truthcoin.v1.GetBlockRequest', '3': '.truthcoin.v1.GetBlockResponse'},
    {
      '1': 'GetBestMainchainBlockHash',
      '2': '.truthcoin.v1.GetBestMainchainBlockHashRequest',
      '3': '.truthcoin.v1.GetBestMainchainBlockHashResponse'
    },
    {
      '1': 'GetBestSidechainBlockHash',
      '2': '.truthcoin.v1.GetBestSidechainBlockHashRequest',
      '3': '.truthcoin.v1.GetBestSidechainBlockHashResponse'
    },
    {
      '1': 'GetBmmInclusions',
      '2': '.truthcoin.v1.GetBmmInclusionsRequest',
      '3': '.truthcoin.v1.GetBmmInclusionsResponse'
    },
    {'1': 'GetWalletUtxos', '2': '.truthcoin.v1.GetWalletUtxosRequest', '3': '.truthcoin.v1.GetWalletUtxosResponse'},
    {'1': 'ListUtxos', '2': '.truthcoin.v1.ListUtxosRequest', '3': '.truthcoin.v1.ListUtxosResponse'},
    {
      '1': 'RemoveFromMempool',
      '2': '.truthcoin.v1.RemoveFromMempoolRequest',
      '3': '.truthcoin.v1.RemoveFromMempoolResponse'
    },
    {
      '1': 'GetLatestFailedWithdrawalBundleHeight',
      '2': '.truthcoin.v1.GetLatestFailedWithdrawalBundleHeightRequest',
      '3': '.truthcoin.v1.GetLatestFailedWithdrawalBundleHeightResponse'
    },
    {
      '1': 'GenerateMnemonic',
      '2': '.truthcoin.v1.GenerateMnemonicRequest',
      '3': '.truthcoin.v1.GenerateMnemonicResponse'
    },
    {
      '1': 'SetSeedFromMnemonic',
      '2': '.truthcoin.v1.SetSeedFromMnemonicRequest',
      '3': '.truthcoin.v1.SetSeedFromMnemonicResponse'
    },
    {'1': 'CallRaw', '2': '.truthcoin.v1.CallRawRequest', '3': '.truthcoin.v1.CallRawResponse'},
    {'1': 'RefreshWallet', '2': '.truthcoin.v1.RefreshWalletRequest', '3': '.truthcoin.v1.RefreshWalletResponse'},
    {'1': 'GetTransaction', '2': '.truthcoin.v1.GetTransactionRequest', '3': '.truthcoin.v1.GetTransactionResponse'},
    {
      '1': 'GetTransactionInfo',
      '2': '.truthcoin.v1.GetTransactionInfoRequest',
      '3': '.truthcoin.v1.GetTransactionInfoResponse'
    },
    {
      '1': 'GetWalletAddresses',
      '2': '.truthcoin.v1.GetWalletAddressesRequest',
      '3': '.truthcoin.v1.GetWalletAddressesResponse'
    },
    {'1': 'MyUtxos', '2': '.truthcoin.v1.MyUtxosRequest', '3': '.truthcoin.v1.MyUtxosResponse'},
    {
      '1': 'MyUnconfirmedUtxos',
      '2': '.truthcoin.v1.MyUnconfirmedUtxosRequest',
      '3': '.truthcoin.v1.MyUnconfirmedUtxosResponse'
    },
    {
      '1': 'CalculateInitialLiquidity',
      '2': '.truthcoin.v1.CalculateInitialLiquidityRequest',
      '3': '.truthcoin.v1.CalculateInitialLiquidityResponse'
    },
    {'1': 'MarketCreate', '2': '.truthcoin.v1.MarketCreateRequest', '3': '.truthcoin.v1.MarketCreateResponse'},
    {'1': 'MarketList', '2': '.truthcoin.v1.MarketListRequest', '3': '.truthcoin.v1.MarketListResponse'},
    {'1': 'MarketGet', '2': '.truthcoin.v1.MarketGetRequest', '3': '.truthcoin.v1.MarketGetResponse'},
    {'1': 'MarketBuy', '2': '.truthcoin.v1.MarketBuyRequest', '3': '.truthcoin.v1.MarketBuyResponse'},
    {'1': 'MarketSell', '2': '.truthcoin.v1.MarketSellRequest', '3': '.truthcoin.v1.MarketSellResponse'},
    {'1': 'MarketPositions', '2': '.truthcoin.v1.MarketPositionsRequest', '3': '.truthcoin.v1.MarketPositionsResponse'},
    {'1': 'SlotStatus', '2': '.truthcoin.v1.SlotStatusRequest', '3': '.truthcoin.v1.SlotStatusResponse'},
    {'1': 'SlotList', '2': '.truthcoin.v1.SlotListRequest', '3': '.truthcoin.v1.SlotListResponse'},
    {'1': 'SlotGet', '2': '.truthcoin.v1.SlotGetRequest', '3': '.truthcoin.v1.SlotGetResponse'},
    {'1': 'SlotClaim', '2': '.truthcoin.v1.SlotClaimRequest', '3': '.truthcoin.v1.SlotClaimResponse'},
    {
      '1': 'SlotClaimCategory',
      '2': '.truthcoin.v1.SlotClaimCategoryRequest',
      '3': '.truthcoin.v1.SlotClaimCategoryResponse'
    },
    {'1': 'VoteRegister', '2': '.truthcoin.v1.VoteRegisterRequest', '3': '.truthcoin.v1.VoteRegisterResponse'},
    {'1': 'VoteVoter', '2': '.truthcoin.v1.VoteVoterRequest', '3': '.truthcoin.v1.VoteVoterResponse'},
    {'1': 'VoteVoters', '2': '.truthcoin.v1.VoteVotersRequest', '3': '.truthcoin.v1.VoteVotersResponse'},
    {'1': 'VoteSubmit', '2': '.truthcoin.v1.VoteSubmitRequest', '3': '.truthcoin.v1.VoteSubmitResponse'},
    {'1': 'VoteList', '2': '.truthcoin.v1.VoteListRequest', '3': '.truthcoin.v1.VoteListResponse'},
    {'1': 'VotePeriod', '2': '.truthcoin.v1.VotePeriodRequest', '3': '.truthcoin.v1.VotePeriodResponse'},
    {
      '1': 'VotecoinTransfer',
      '2': '.truthcoin.v1.VotecoinTransferRequest',
      '3': '.truthcoin.v1.VotecoinTransferResponse'
    },
    {'1': 'VotecoinBalance', '2': '.truthcoin.v1.VotecoinBalanceRequest', '3': '.truthcoin.v1.VotecoinBalanceResponse'},
    {
      '1': 'TransferVotecoin',
      '2': '.truthcoin.v1.TransferVotecoinRequest',
      '3': '.truthcoin.v1.TransferVotecoinResponse'
    },
    {
      '1': 'GetNewEncryptionKey',
      '2': '.truthcoin.v1.GetNewEncryptionKeyRequest',
      '3': '.truthcoin.v1.GetNewEncryptionKeyResponse'
    },
    {
      '1': 'GetNewVerifyingKey',
      '2': '.truthcoin.v1.GetNewVerifyingKeyRequest',
      '3': '.truthcoin.v1.GetNewVerifyingKeyResponse'
    },
    {'1': 'EncryptMsg', '2': '.truthcoin.v1.EncryptMsgRequest', '3': '.truthcoin.v1.EncryptMsgResponse'},
    {'1': 'DecryptMsg', '2': '.truthcoin.v1.DecryptMsgRequest', '3': '.truthcoin.v1.DecryptMsgResponse'},
    {
      '1': 'SignArbitraryMsg',
      '2': '.truthcoin.v1.SignArbitraryMsgRequest',
      '3': '.truthcoin.v1.SignArbitraryMsgResponse'
    },
    {
      '1': 'SignArbitraryMsgAsAddr',
      '2': '.truthcoin.v1.SignArbitraryMsgAsAddrRequest',
      '3': '.truthcoin.v1.SignArbitraryMsgAsAddrResponse'
    },
    {'1': 'VerifySignature', '2': '.truthcoin.v1.VerifySignatureRequest', '3': '.truthcoin.v1.VerifySignatureResponse'},
  ],
};

@$core.Deprecated('Use truthcoinServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> TruthcoinServiceBase$messageJson = {
  '.truthcoin.v1.GetBalanceRequest': GetBalanceRequest$json,
  '.truthcoin.v1.GetBalanceResponse': GetBalanceResponse$json,
  '.truthcoin.v1.GetBlockCountRequest': GetBlockCountRequest$json,
  '.truthcoin.v1.GetBlockCountResponse': GetBlockCountResponse$json,
  '.truthcoin.v1.StopRequest': StopRequest$json,
  '.truthcoin.v1.StopResponse': StopResponse$json,
  '.truthcoin.v1.GetNewAddressRequest': GetNewAddressRequest$json,
  '.truthcoin.v1.GetNewAddressResponse': GetNewAddressResponse$json,
  '.truthcoin.v1.WithdrawRequest': WithdrawRequest$json,
  '.truthcoin.v1.WithdrawResponse': WithdrawResponse$json,
  '.truthcoin.v1.TransferRequest': TransferRequest$json,
  '.truthcoin.v1.TransferResponse': TransferResponse$json,
  '.truthcoin.v1.GetSidechainWealthRequest': GetSidechainWealthRequest$json,
  '.truthcoin.v1.GetSidechainWealthResponse': GetSidechainWealthResponse$json,
  '.truthcoin.v1.CreateDepositRequest': CreateDepositRequest$json,
  '.truthcoin.v1.CreateDepositResponse': CreateDepositResponse$json,
  '.truthcoin.v1.GetPendingWithdrawalBundleRequest': GetPendingWithdrawalBundleRequest$json,
  '.truthcoin.v1.GetPendingWithdrawalBundleResponse': GetPendingWithdrawalBundleResponse$json,
  '.truthcoin.v1.ConnectPeerRequest': ConnectPeerRequest$json,
  '.truthcoin.v1.ConnectPeerResponse': ConnectPeerResponse$json,
  '.truthcoin.v1.ListPeersRequest': ListPeersRequest$json,
  '.truthcoin.v1.ListPeersResponse': ListPeersResponse$json,
  '.truthcoin.v1.MineRequest': MineRequest$json,
  '.truthcoin.v1.MineResponse': MineResponse$json,
  '.truthcoin.v1.GetBlockRequest': GetBlockRequest$json,
  '.truthcoin.v1.GetBlockResponse': GetBlockResponse$json,
  '.truthcoin.v1.GetBestMainchainBlockHashRequest': GetBestMainchainBlockHashRequest$json,
  '.truthcoin.v1.GetBestMainchainBlockHashResponse': GetBestMainchainBlockHashResponse$json,
  '.truthcoin.v1.GetBestSidechainBlockHashRequest': GetBestSidechainBlockHashRequest$json,
  '.truthcoin.v1.GetBestSidechainBlockHashResponse': GetBestSidechainBlockHashResponse$json,
  '.truthcoin.v1.GetBmmInclusionsRequest': GetBmmInclusionsRequest$json,
  '.truthcoin.v1.GetBmmInclusionsResponse': GetBmmInclusionsResponse$json,
  '.truthcoin.v1.GetWalletUtxosRequest': GetWalletUtxosRequest$json,
  '.truthcoin.v1.GetWalletUtxosResponse': GetWalletUtxosResponse$json,
  '.truthcoin.v1.ListUtxosRequest': ListUtxosRequest$json,
  '.truthcoin.v1.ListUtxosResponse': ListUtxosResponse$json,
  '.truthcoin.v1.RemoveFromMempoolRequest': RemoveFromMempoolRequest$json,
  '.truthcoin.v1.RemoveFromMempoolResponse': RemoveFromMempoolResponse$json,
  '.truthcoin.v1.GetLatestFailedWithdrawalBundleHeightRequest': GetLatestFailedWithdrawalBundleHeightRequest$json,
  '.truthcoin.v1.GetLatestFailedWithdrawalBundleHeightResponse': GetLatestFailedWithdrawalBundleHeightResponse$json,
  '.truthcoin.v1.GenerateMnemonicRequest': GenerateMnemonicRequest$json,
  '.truthcoin.v1.GenerateMnemonicResponse': GenerateMnemonicResponse$json,
  '.truthcoin.v1.SetSeedFromMnemonicRequest': SetSeedFromMnemonicRequest$json,
  '.truthcoin.v1.SetSeedFromMnemonicResponse': SetSeedFromMnemonicResponse$json,
  '.truthcoin.v1.CallRawRequest': CallRawRequest$json,
  '.truthcoin.v1.CallRawResponse': CallRawResponse$json,
  '.truthcoin.v1.RefreshWalletRequest': RefreshWalletRequest$json,
  '.truthcoin.v1.RefreshWalletResponse': RefreshWalletResponse$json,
  '.truthcoin.v1.GetTransactionRequest': GetTransactionRequest$json,
  '.truthcoin.v1.GetTransactionResponse': GetTransactionResponse$json,
  '.truthcoin.v1.GetTransactionInfoRequest': GetTransactionInfoRequest$json,
  '.truthcoin.v1.GetTransactionInfoResponse': GetTransactionInfoResponse$json,
  '.truthcoin.v1.GetWalletAddressesRequest': GetWalletAddressesRequest$json,
  '.truthcoin.v1.GetWalletAddressesResponse': GetWalletAddressesResponse$json,
  '.truthcoin.v1.MyUtxosRequest': MyUtxosRequest$json,
  '.truthcoin.v1.MyUtxosResponse': MyUtxosResponse$json,
  '.truthcoin.v1.MyUnconfirmedUtxosRequest': MyUnconfirmedUtxosRequest$json,
  '.truthcoin.v1.MyUnconfirmedUtxosResponse': MyUnconfirmedUtxosResponse$json,
  '.truthcoin.v1.CalculateInitialLiquidityRequest': CalculateInitialLiquidityRequest$json,
  '.truthcoin.v1.CalculateInitialLiquidityResponse': CalculateInitialLiquidityResponse$json,
  '.truthcoin.v1.MarketCreateRequest': MarketCreateRequest$json,
  '.truthcoin.v1.MarketCreateResponse': MarketCreateResponse$json,
  '.truthcoin.v1.MarketListRequest': MarketListRequest$json,
  '.truthcoin.v1.MarketListResponse': MarketListResponse$json,
  '.truthcoin.v1.MarketGetRequest': MarketGetRequest$json,
  '.truthcoin.v1.MarketGetResponse': MarketGetResponse$json,
  '.truthcoin.v1.MarketBuyRequest': MarketBuyRequest$json,
  '.truthcoin.v1.MarketBuyResponse': MarketBuyResponse$json,
  '.truthcoin.v1.MarketSellRequest': MarketSellRequest$json,
  '.truthcoin.v1.MarketSellResponse': MarketSellResponse$json,
  '.truthcoin.v1.MarketPositionsRequest': MarketPositionsRequest$json,
  '.truthcoin.v1.MarketPositionsResponse': MarketPositionsResponse$json,
  '.truthcoin.v1.SlotStatusRequest': SlotStatusRequest$json,
  '.truthcoin.v1.SlotStatusResponse': SlotStatusResponse$json,
  '.truthcoin.v1.SlotListRequest': SlotListRequest$json,
  '.truthcoin.v1.SlotListResponse': SlotListResponse$json,
  '.truthcoin.v1.SlotGetRequest': SlotGetRequest$json,
  '.truthcoin.v1.SlotGetResponse': SlotGetResponse$json,
  '.truthcoin.v1.SlotClaimRequest': SlotClaimRequest$json,
  '.truthcoin.v1.SlotClaimResponse': SlotClaimResponse$json,
  '.truthcoin.v1.SlotClaimCategoryRequest': SlotClaimCategoryRequest$json,
  '.truthcoin.v1.SlotClaimCategoryResponse': SlotClaimCategoryResponse$json,
  '.truthcoin.v1.VoteRegisterRequest': VoteRegisterRequest$json,
  '.truthcoin.v1.VoteRegisterResponse': VoteRegisterResponse$json,
  '.truthcoin.v1.VoteVoterRequest': VoteVoterRequest$json,
  '.truthcoin.v1.VoteVoterResponse': VoteVoterResponse$json,
  '.truthcoin.v1.VoteVotersRequest': VoteVotersRequest$json,
  '.truthcoin.v1.VoteVotersResponse': VoteVotersResponse$json,
  '.truthcoin.v1.VoteSubmitRequest': VoteSubmitRequest$json,
  '.truthcoin.v1.VoteSubmitResponse': VoteSubmitResponse$json,
  '.truthcoin.v1.VoteListRequest': VoteListRequest$json,
  '.truthcoin.v1.VoteListResponse': VoteListResponse$json,
  '.truthcoin.v1.VotePeriodRequest': VotePeriodRequest$json,
  '.truthcoin.v1.VotePeriodResponse': VotePeriodResponse$json,
  '.truthcoin.v1.VotecoinTransferRequest': VotecoinTransferRequest$json,
  '.truthcoin.v1.VotecoinTransferResponse': VotecoinTransferResponse$json,
  '.truthcoin.v1.VotecoinBalanceRequest': VotecoinBalanceRequest$json,
  '.truthcoin.v1.VotecoinBalanceResponse': VotecoinBalanceResponse$json,
  '.truthcoin.v1.TransferVotecoinRequest': TransferVotecoinRequest$json,
  '.truthcoin.v1.TransferVotecoinResponse': TransferVotecoinResponse$json,
  '.truthcoin.v1.GetNewEncryptionKeyRequest': GetNewEncryptionKeyRequest$json,
  '.truthcoin.v1.GetNewEncryptionKeyResponse': GetNewEncryptionKeyResponse$json,
  '.truthcoin.v1.GetNewVerifyingKeyRequest': GetNewVerifyingKeyRequest$json,
  '.truthcoin.v1.GetNewVerifyingKeyResponse': GetNewVerifyingKeyResponse$json,
  '.truthcoin.v1.EncryptMsgRequest': EncryptMsgRequest$json,
  '.truthcoin.v1.EncryptMsgResponse': EncryptMsgResponse$json,
  '.truthcoin.v1.DecryptMsgRequest': DecryptMsgRequest$json,
  '.truthcoin.v1.DecryptMsgResponse': DecryptMsgResponse$json,
  '.truthcoin.v1.SignArbitraryMsgRequest': SignArbitraryMsgRequest$json,
  '.truthcoin.v1.SignArbitraryMsgResponse': SignArbitraryMsgResponse$json,
  '.truthcoin.v1.SignArbitraryMsgAsAddrRequest': SignArbitraryMsgAsAddrRequest$json,
  '.truthcoin.v1.SignArbitraryMsgAsAddrResponse': SignArbitraryMsgAsAddrResponse$json,
  '.truthcoin.v1.VerifySignatureRequest': VerifySignatureRequest$json,
  '.truthcoin.v1.VerifySignatureResponse': VerifySignatureResponse$json,
};

/// Descriptor for `TruthcoinService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List truthcoinServiceDescriptor =
    $convert.base64Decode('ChBUcnV0aGNvaW5TZXJ2aWNlEk8KCkdldEJhbGFuY2USHy50cnV0aGNvaW4udjEuR2V0QmFsYW'
        '5jZVJlcXVlc3QaIC50cnV0aGNvaW4udjEuR2V0QmFsYW5jZVJlc3BvbnNlElgKDUdldEJsb2Nr'
        'Q291bnQSIi50cnV0aGNvaW4udjEuR2V0QmxvY2tDb3VudFJlcXVlc3QaIy50cnV0aGNvaW4udj'
        'EuR2V0QmxvY2tDb3VudFJlc3BvbnNlEj0KBFN0b3ASGS50cnV0aGNvaW4udjEuU3RvcFJlcXVl'
        'c3QaGi50cnV0aGNvaW4udjEuU3RvcFJlc3BvbnNlElgKDUdldE5ld0FkZHJlc3MSIi50cnV0aG'
        'NvaW4udjEuR2V0TmV3QWRkcmVzc1JlcXVlc3QaIy50cnV0aGNvaW4udjEuR2V0TmV3QWRkcmVz'
        'c1Jlc3BvbnNlEkkKCFdpdGhkcmF3Eh0udHJ1dGhjb2luLnYxLldpdGhkcmF3UmVxdWVzdBoeLn'
        'RydXRoY29pbi52MS5XaXRoZHJhd1Jlc3BvbnNlEkkKCFRyYW5zZmVyEh0udHJ1dGhjb2luLnYx'
        'LlRyYW5zZmVyUmVxdWVzdBoeLnRydXRoY29pbi52MS5UcmFuc2ZlclJlc3BvbnNlEmcKEkdldF'
        'NpZGVjaGFpbldlYWx0aBInLnRydXRoY29pbi52MS5HZXRTaWRlY2hhaW5XZWFsdGhSZXF1ZXN0'
        'GigudHJ1dGhjb2luLnYxLkdldFNpZGVjaGFpbldlYWx0aFJlc3BvbnNlElgKDUNyZWF0ZURlcG'
        '9zaXQSIi50cnV0aGNvaW4udjEuQ3JlYXRlRGVwb3NpdFJlcXVlc3QaIy50cnV0aGNvaW4udjEu'
        'Q3JlYXRlRGVwb3NpdFJlc3BvbnNlEn8KGkdldFBlbmRpbmdXaXRoZHJhd2FsQnVuZGxlEi8udH'
        'J1dGhjb2luLnYxLkdldFBlbmRpbmdXaXRoZHJhd2FsQnVuZGxlUmVxdWVzdBowLnRydXRoY29p'
        'bi52MS5HZXRQZW5kaW5nV2l0aGRyYXdhbEJ1bmRsZVJlc3BvbnNlElIKC0Nvbm5lY3RQZWVyEi'
        'AudHJ1dGhjb2luLnYxLkNvbm5lY3RQZWVyUmVxdWVzdBohLnRydXRoY29pbi52MS5Db25uZWN0'
        'UGVlclJlc3BvbnNlEkwKCUxpc3RQZWVycxIeLnRydXRoY29pbi52MS5MaXN0UGVlcnNSZXF1ZX'
        'N0Gh8udHJ1dGhjb2luLnYxLkxpc3RQZWVyc1Jlc3BvbnNlEj0KBE1pbmUSGS50cnV0aGNvaW4u'
        'djEuTWluZVJlcXVlc3QaGi50cnV0aGNvaW4udjEuTWluZVJlc3BvbnNlEkkKCEdldEJsb2NrEh'
        '0udHJ1dGhjb2luLnYxLkdldEJsb2NrUmVxdWVzdBoeLnRydXRoY29pbi52MS5HZXRCbG9ja1Jl'
        'c3BvbnNlEnwKGUdldEJlc3RNYWluY2hhaW5CbG9ja0hhc2gSLi50cnV0aGNvaW4udjEuR2V0Qm'
        'VzdE1haW5jaGFpbkJsb2NrSGFzaFJlcXVlc3QaLy50cnV0aGNvaW4udjEuR2V0QmVzdE1haW5j'
        'aGFpbkJsb2NrSGFzaFJlc3BvbnNlEnwKGUdldEJlc3RTaWRlY2hhaW5CbG9ja0hhc2gSLi50cn'
        'V0aGNvaW4udjEuR2V0QmVzdFNpZGVjaGFpbkJsb2NrSGFzaFJlcXVlc3QaLy50cnV0aGNvaW4u'
        'djEuR2V0QmVzdFNpZGVjaGFpbkJsb2NrSGFzaFJlc3BvbnNlEmEKEEdldEJtbUluY2x1c2lvbn'
        'MSJS50cnV0aGNvaW4udjEuR2V0Qm1tSW5jbHVzaW9uc1JlcXVlc3QaJi50cnV0aGNvaW4udjEu'
        'R2V0Qm1tSW5jbHVzaW9uc1Jlc3BvbnNlElsKDkdldFdhbGxldFV0eG9zEiMudHJ1dGhjb2luLn'
        'YxLkdldFdhbGxldFV0eG9zUmVxdWVzdBokLnRydXRoY29pbi52MS5HZXRXYWxsZXRVdHhvc1Jl'
        'c3BvbnNlEkwKCUxpc3RVdHhvcxIeLnRydXRoY29pbi52MS5MaXN0VXR4b3NSZXF1ZXN0Gh8udH'
        'J1dGhjb2luLnYxLkxpc3RVdHhvc1Jlc3BvbnNlEmQKEVJlbW92ZUZyb21NZW1wb29sEiYudHJ1'
        'dGhjb2luLnYxLlJlbW92ZUZyb21NZW1wb29sUmVxdWVzdBonLnRydXRoY29pbi52MS5SZW1vdm'
        'VGcm9tTWVtcG9vbFJlc3BvbnNlEqABCiVHZXRMYXRlc3RGYWlsZWRXaXRoZHJhd2FsQnVuZGxl'
        'SGVpZ2h0EjoudHJ1dGhjb2luLnYxLkdldExhdGVzdEZhaWxlZFdpdGhkcmF3YWxCdW5kbGVIZW'
        'lnaHRSZXF1ZXN0GjsudHJ1dGhjb2luLnYxLkdldExhdGVzdEZhaWxlZFdpdGhkcmF3YWxCdW5k'
        'bGVIZWlnaHRSZXNwb25zZRJhChBHZW5lcmF0ZU1uZW1vbmljEiUudHJ1dGhjb2luLnYxLkdlbm'
        'VyYXRlTW5lbW9uaWNSZXF1ZXN0GiYudHJ1dGhjb2luLnYxLkdlbmVyYXRlTW5lbW9uaWNSZXNw'
        'b25zZRJqChNTZXRTZWVkRnJvbU1uZW1vbmljEigudHJ1dGhjb2luLnYxLlNldFNlZWRGcm9tTW'
        '5lbW9uaWNSZXF1ZXN0GikudHJ1dGhjb2luLnYxLlNldFNlZWRGcm9tTW5lbW9uaWNSZXNwb25z'
        'ZRJGCgdDYWxsUmF3EhwudHJ1dGhjb2luLnYxLkNhbGxSYXdSZXF1ZXN0Gh0udHJ1dGhjb2luLn'
        'YxLkNhbGxSYXdSZXNwb25zZRJYCg1SZWZyZXNoV2FsbGV0EiIudHJ1dGhjb2luLnYxLlJlZnJl'
        'c2hXYWxsZXRSZXF1ZXN0GiMudHJ1dGhjb2luLnYxLlJlZnJlc2hXYWxsZXRSZXNwb25zZRJbCg'
        '5HZXRUcmFuc2FjdGlvbhIjLnRydXRoY29pbi52MS5HZXRUcmFuc2FjdGlvblJlcXVlc3QaJC50'
        'cnV0aGNvaW4udjEuR2V0VHJhbnNhY3Rpb25SZXNwb25zZRJnChJHZXRUcmFuc2FjdGlvbkluZm'
        '8SJy50cnV0aGNvaW4udjEuR2V0VHJhbnNhY3Rpb25JbmZvUmVxdWVzdBooLnRydXRoY29pbi52'
        'MS5HZXRUcmFuc2FjdGlvbkluZm9SZXNwb25zZRJnChJHZXRXYWxsZXRBZGRyZXNzZXMSJy50cn'
        'V0aGNvaW4udjEuR2V0V2FsbGV0QWRkcmVzc2VzUmVxdWVzdBooLnRydXRoY29pbi52MS5HZXRX'
        'YWxsZXRBZGRyZXNzZXNSZXNwb25zZRJGCgdNeVV0eG9zEhwudHJ1dGhjb2luLnYxLk15VXR4b3'
        'NSZXF1ZXN0Gh0udHJ1dGhjb2luLnYxLk15VXR4b3NSZXNwb25zZRJnChJNeVVuY29uZmlybWVk'
        'VXR4b3MSJy50cnV0aGNvaW4udjEuTXlVbmNvbmZpcm1lZFV0eG9zUmVxdWVzdBooLnRydXRoY2'
        '9pbi52MS5NeVVuY29uZmlybWVkVXR4b3NSZXNwb25zZRJ8ChlDYWxjdWxhdGVJbml0aWFsTGlx'
        'dWlkaXR5Ei4udHJ1dGhjb2luLnYxLkNhbGN1bGF0ZUluaXRpYWxMaXF1aWRpdHlSZXF1ZXN0Gi'
        '8udHJ1dGhjb2luLnYxLkNhbGN1bGF0ZUluaXRpYWxMaXF1aWRpdHlSZXNwb25zZRJVCgxNYXJr'
        'ZXRDcmVhdGUSIS50cnV0aGNvaW4udjEuTWFya2V0Q3JlYXRlUmVxdWVzdBoiLnRydXRoY29pbi'
        '52MS5NYXJrZXRDcmVhdGVSZXNwb25zZRJPCgpNYXJrZXRMaXN0Eh8udHJ1dGhjb2luLnYxLk1h'
        'cmtldExpc3RSZXF1ZXN0GiAudHJ1dGhjb2luLnYxLk1hcmtldExpc3RSZXNwb25zZRJMCglNYX'
        'JrZXRHZXQSHi50cnV0aGNvaW4udjEuTWFya2V0R2V0UmVxdWVzdBofLnRydXRoY29pbi52MS5N'
        'YXJrZXRHZXRSZXNwb25zZRJMCglNYXJrZXRCdXkSHi50cnV0aGNvaW4udjEuTWFya2V0QnV5Um'
        'VxdWVzdBofLnRydXRoY29pbi52MS5NYXJrZXRCdXlSZXNwb25zZRJPCgpNYXJrZXRTZWxsEh8u'
        'dHJ1dGhjb2luLnYxLk1hcmtldFNlbGxSZXF1ZXN0GiAudHJ1dGhjb2luLnYxLk1hcmtldFNlbG'
        'xSZXNwb25zZRJeCg9NYXJrZXRQb3NpdGlvbnMSJC50cnV0aGNvaW4udjEuTWFya2V0UG9zaXRp'
        'b25zUmVxdWVzdBolLnRydXRoY29pbi52MS5NYXJrZXRQb3NpdGlvbnNSZXNwb25zZRJPCgpTbG'
        '90U3RhdHVzEh8udHJ1dGhjb2luLnYxLlNsb3RTdGF0dXNSZXF1ZXN0GiAudHJ1dGhjb2luLnYx'
        'LlNsb3RTdGF0dXNSZXNwb25zZRJJCghTbG90TGlzdBIdLnRydXRoY29pbi52MS5TbG90TGlzdF'
        'JlcXVlc3QaHi50cnV0aGNvaW4udjEuU2xvdExpc3RSZXNwb25zZRJGCgdTbG90R2V0EhwudHJ1'
        'dGhjb2luLnYxLlNsb3RHZXRSZXF1ZXN0Gh0udHJ1dGhjb2luLnYxLlNsb3RHZXRSZXNwb25zZR'
        'JMCglTbG90Q2xhaW0SHi50cnV0aGNvaW4udjEuU2xvdENsYWltUmVxdWVzdBofLnRydXRoY29p'
        'bi52MS5TbG90Q2xhaW1SZXNwb25zZRJkChFTbG90Q2xhaW1DYXRlZ29yeRImLnRydXRoY29pbi'
        '52MS5TbG90Q2xhaW1DYXRlZ29yeVJlcXVlc3QaJy50cnV0aGNvaW4udjEuU2xvdENsYWltQ2F0'
        'ZWdvcnlSZXNwb25zZRJVCgxWb3RlUmVnaXN0ZXISIS50cnV0aGNvaW4udjEuVm90ZVJlZ2lzdG'
        'VyUmVxdWVzdBoiLnRydXRoY29pbi52MS5Wb3RlUmVnaXN0ZXJSZXNwb25zZRJMCglWb3RlVm90'
        'ZXISHi50cnV0aGNvaW4udjEuVm90ZVZvdGVyUmVxdWVzdBofLnRydXRoY29pbi52MS5Wb3RlVm'
        '90ZXJSZXNwb25zZRJPCgpWb3RlVm90ZXJzEh8udHJ1dGhjb2luLnYxLlZvdGVWb3RlcnNSZXF1'
        'ZXN0GiAudHJ1dGhjb2luLnYxLlZvdGVWb3RlcnNSZXNwb25zZRJPCgpWb3RlU3VibWl0Eh8udH'
        'J1dGhjb2luLnYxLlZvdGVTdWJtaXRSZXF1ZXN0GiAudHJ1dGhjb2luLnYxLlZvdGVTdWJtaXRS'
        'ZXNwb25zZRJJCghWb3RlTGlzdBIdLnRydXRoY29pbi52MS5Wb3RlTGlzdFJlcXVlc3QaHi50cn'
        'V0aGNvaW4udjEuVm90ZUxpc3RSZXNwb25zZRJPCgpWb3RlUGVyaW9kEh8udHJ1dGhjb2luLnYx'
        'LlZvdGVQZXJpb2RSZXF1ZXN0GiAudHJ1dGhjb2luLnYxLlZvdGVQZXJpb2RSZXNwb25zZRJhCh'
        'BWb3RlY29pblRyYW5zZmVyEiUudHJ1dGhjb2luLnYxLlZvdGVjb2luVHJhbnNmZXJSZXF1ZXN0'
        'GiYudHJ1dGhjb2luLnYxLlZvdGVjb2luVHJhbnNmZXJSZXNwb25zZRJeCg9Wb3RlY29pbkJhbG'
        'FuY2USJC50cnV0aGNvaW4udjEuVm90ZWNvaW5CYWxhbmNlUmVxdWVzdBolLnRydXRoY29pbi52'
        'MS5Wb3RlY29pbkJhbGFuY2VSZXNwb25zZRJhChBUcmFuc2ZlclZvdGVjb2luEiUudHJ1dGhjb2'
        'luLnYxLlRyYW5zZmVyVm90ZWNvaW5SZXF1ZXN0GiYudHJ1dGhjb2luLnYxLlRyYW5zZmVyVm90'
        'ZWNvaW5SZXNwb25zZRJqChNHZXROZXdFbmNyeXB0aW9uS2V5EigudHJ1dGhjb2luLnYxLkdldE'
        '5ld0VuY3J5cHRpb25LZXlSZXF1ZXN0GikudHJ1dGhjb2luLnYxLkdldE5ld0VuY3J5cHRpb25L'
        'ZXlSZXNwb25zZRJnChJHZXROZXdWZXJpZnlpbmdLZXkSJy50cnV0aGNvaW4udjEuR2V0TmV3Vm'
        'VyaWZ5aW5nS2V5UmVxdWVzdBooLnRydXRoY29pbi52MS5HZXROZXdWZXJpZnlpbmdLZXlSZXNw'
        'b25zZRJPCgpFbmNyeXB0TXNnEh8udHJ1dGhjb2luLnYxLkVuY3J5cHRNc2dSZXF1ZXN0GiAudH'
        'J1dGhjb2luLnYxLkVuY3J5cHRNc2dSZXNwb25zZRJPCgpEZWNyeXB0TXNnEh8udHJ1dGhjb2lu'
        'LnYxLkRlY3J5cHRNc2dSZXF1ZXN0GiAudHJ1dGhjb2luLnYxLkRlY3J5cHRNc2dSZXNwb25zZR'
        'JhChBTaWduQXJiaXRyYXJ5TXNnEiUudHJ1dGhjb2luLnYxLlNpZ25BcmJpdHJhcnlNc2dSZXF1'
        'ZXN0GiYudHJ1dGhjb2luLnYxLlNpZ25BcmJpdHJhcnlNc2dSZXNwb25zZRJzChZTaWduQXJiaX'
        'RyYXJ5TXNnQXNBZGRyEisudHJ1dGhjb2luLnYxLlNpZ25BcmJpdHJhcnlNc2dBc0FkZHJSZXF1'
        'ZXN0GiwudHJ1dGhjb2luLnYxLlNpZ25BcmJpdHJhcnlNc2dBc0FkZHJSZXNwb25zZRJeCg9WZX'
        'JpZnlTaWduYXR1cmUSJC50cnV0aGNvaW4udjEuVmVyaWZ5U2lnbmF0dXJlUmVxdWVzdBolLnRy'
        'dXRoY29pbi52MS5WZXJpZnlTaWduYXR1cmVSZXNwb25zZQ==');
