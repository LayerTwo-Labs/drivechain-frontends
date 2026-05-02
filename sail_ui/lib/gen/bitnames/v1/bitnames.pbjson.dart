//
//  Generated code. Do not modify.
//  source: bitnames/v1/bitnames.proto
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

@$core.Deprecated('Use getBitNameDataRequestDescriptor instead')
const GetBitNameDataRequest$json = {
  '1': 'GetBitNameDataRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `GetBitNameDataRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBitNameDataRequestDescriptor =
    $convert.base64Decode('ChVHZXRCaXROYW1lRGF0YVJlcXVlc3QSEgoEbmFtZRgBIAEoCVIEbmFtZQ==');

@$core.Deprecated('Use getBitNameDataResponseDescriptor instead')
const GetBitNameDataResponse$json = {
  '1': 'GetBitNameDataResponse',
  '2': [
    {'1': 'data_json', '3': 1, '4': 1, '5': 9, '10': 'dataJson'},
  ],
};

/// Descriptor for `GetBitNameDataResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBitNameDataResponseDescriptor =
    $convert.base64Decode('ChZHZXRCaXROYW1lRGF0YVJlc3BvbnNlEhsKCWRhdGFfanNvbhgBIAEoCVIIZGF0YUpzb24=');

@$core.Deprecated('Use listBitNamesRequestDescriptor instead')
const ListBitNamesRequest$json = {
  '1': 'ListBitNamesRequest',
};

/// Descriptor for `ListBitNamesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listBitNamesRequestDescriptor = $convert.base64Decode('ChNMaXN0Qml0TmFtZXNSZXF1ZXN0');

@$core.Deprecated('Use listBitNamesResponseDescriptor instead')
const ListBitNamesResponse$json = {
  '1': 'ListBitNamesResponse',
  '2': [
    {'1': 'bitnames_json', '3': 1, '4': 1, '5': 9, '10': 'bitnamesJson'},
  ],
};

/// Descriptor for `ListBitNamesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listBitNamesResponseDescriptor =
    $convert.base64Decode('ChRMaXN0Qml0TmFtZXNSZXNwb25zZRIjCg1iaXRuYW1lc19qc29uGAEgASgJUgxiaXRuYW1lc0'
        'pzb24=');

@$core.Deprecated('Use registerBitNameRequestDescriptor instead')
const RegisterBitNameRequest$json = {
  '1': 'RegisterBitNameRequest',
  '2': [
    {'1': 'plain_name', '3': 1, '4': 1, '5': 9, '10': 'plainName'},
    {'1': 'data_json', '3': 2, '4': 1, '5': 9, '10': 'dataJson'},
  ],
};

/// Descriptor for `RegisterBitNameRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerBitNameRequestDescriptor =
    $convert.base64Decode('ChZSZWdpc3RlckJpdE5hbWVSZXF1ZXN0Eh0KCnBsYWluX25hbWUYASABKAlSCXBsYWluTmFtZR'
        'IbCglkYXRhX2pzb24YAiABKAlSCGRhdGFKc29u');

@$core.Deprecated('Use registerBitNameResponseDescriptor instead')
const RegisterBitNameResponse$json = {
  '1': 'RegisterBitNameResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `RegisterBitNameResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerBitNameResponseDescriptor =
    $convert.base64Decode('ChdSZWdpc3RlckJpdE5hbWVSZXNwb25zZRISCgR0eGlkGAEgASgJUgR0eGlk');

@$core.Deprecated('Use reserveBitNameRequestDescriptor instead')
const ReserveBitNameRequest$json = {
  '1': 'ReserveBitNameRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `ReserveBitNameRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reserveBitNameRequestDescriptor =
    $convert.base64Decode('ChVSZXNlcnZlQml0TmFtZVJlcXVlc3QSEgoEbmFtZRgBIAEoCVIEbmFtZQ==');

@$core.Deprecated('Use reserveBitNameResponseDescriptor instead')
const ReserveBitNameResponse$json = {
  '1': 'ReserveBitNameResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `ReserveBitNameResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reserveBitNameResponseDescriptor =
    $convert.base64Decode('ChZSZXNlcnZlQml0TmFtZVJlc3BvbnNlEhIKBHR4aWQYASABKAlSBHR4aWQ=');

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

@$core.Deprecated('Use getPaymailRequestDescriptor instead')
const GetPaymailRequest$json = {
  '1': 'GetPaymailRequest',
};

/// Descriptor for `GetPaymailRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPaymailRequestDescriptor = $convert.base64Decode('ChFHZXRQYXltYWlsUmVxdWVzdA==');

@$core.Deprecated('Use getPaymailResponseDescriptor instead')
const GetPaymailResponse$json = {
  '1': 'GetPaymailResponse',
  '2': [
    {'1': 'paymail_json', '3': 1, '4': 1, '5': 9, '10': 'paymailJson'},
  ],
};

/// Descriptor for `GetPaymailResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPaymailResponseDescriptor =
    $convert.base64Decode('ChJHZXRQYXltYWlsUmVzcG9uc2USIQoMcGF5bWFpbF9qc29uGAEgASgJUgtwYXltYWlsSnNvbg'
        '==');

@$core.Deprecated('Use resolveCommitRequestDescriptor instead')
const ResolveCommitRequest$json = {
  '1': 'ResolveCommitRequest',
  '2': [
    {'1': 'bitname', '3': 1, '4': 1, '5': 9, '10': 'bitname'},
  ],
};

/// Descriptor for `ResolveCommitRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List resolveCommitRequestDescriptor =
    $convert.base64Decode('ChRSZXNvbHZlQ29tbWl0UmVxdWVzdBIYCgdiaXRuYW1lGAEgASgJUgdiaXRuYW1l');

@$core.Deprecated('Use resolveCommitResponseDescriptor instead')
const ResolveCommitResponse$json = {
  '1': 'ResolveCommitResponse',
  '2': [
    {'1': 'commitment', '3': 1, '4': 1, '5': 9, '10': 'commitment'},
  ],
};

/// Descriptor for `ResolveCommitResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List resolveCommitResponseDescriptor =
    $convert.base64Decode('ChVSZXNvbHZlQ29tbWl0UmVzcG9uc2USHgoKY29tbWl0bWVudBgBIAEoCVIKY29tbWl0bWVudA'
        '==');

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

const $core.Map<$core.String, $core.dynamic> BitnamesServiceBase$json = {
  '1': 'BitnamesService',
  '2': [
    {'1': 'GetBalance', '2': '.bitnames.v1.GetBalanceRequest', '3': '.bitnames.v1.GetBalanceResponse'},
    {'1': 'GetBlockCount', '2': '.bitnames.v1.GetBlockCountRequest', '3': '.bitnames.v1.GetBlockCountResponse'},
    {'1': 'Stop', '2': '.bitnames.v1.StopRequest', '3': '.bitnames.v1.StopResponse'},
    {'1': 'GetNewAddress', '2': '.bitnames.v1.GetNewAddressRequest', '3': '.bitnames.v1.GetNewAddressResponse'},
    {'1': 'Withdraw', '2': '.bitnames.v1.WithdrawRequest', '3': '.bitnames.v1.WithdrawResponse'},
    {'1': 'Transfer', '2': '.bitnames.v1.TransferRequest', '3': '.bitnames.v1.TransferResponse'},
    {
      '1': 'GetSidechainWealth',
      '2': '.bitnames.v1.GetSidechainWealthRequest',
      '3': '.bitnames.v1.GetSidechainWealthResponse'
    },
    {'1': 'CreateDeposit', '2': '.bitnames.v1.CreateDepositRequest', '3': '.bitnames.v1.CreateDepositResponse'},
    {
      '1': 'GetPendingWithdrawalBundle',
      '2': '.bitnames.v1.GetPendingWithdrawalBundleRequest',
      '3': '.bitnames.v1.GetPendingWithdrawalBundleResponse'
    },
    {'1': 'ConnectPeer', '2': '.bitnames.v1.ConnectPeerRequest', '3': '.bitnames.v1.ConnectPeerResponse'},
    {'1': 'ListPeers', '2': '.bitnames.v1.ListPeersRequest', '3': '.bitnames.v1.ListPeersResponse'},
    {'1': 'Mine', '2': '.bitnames.v1.MineRequest', '3': '.bitnames.v1.MineResponse'},
    {'1': 'GetBlock', '2': '.bitnames.v1.GetBlockRequest', '3': '.bitnames.v1.GetBlockResponse'},
    {
      '1': 'GetBestMainchainBlockHash',
      '2': '.bitnames.v1.GetBestMainchainBlockHashRequest',
      '3': '.bitnames.v1.GetBestMainchainBlockHashResponse'
    },
    {
      '1': 'GetBestSidechainBlockHash',
      '2': '.bitnames.v1.GetBestSidechainBlockHashRequest',
      '3': '.bitnames.v1.GetBestSidechainBlockHashResponse'
    },
    {
      '1': 'GetBmmInclusions',
      '2': '.bitnames.v1.GetBmmInclusionsRequest',
      '3': '.bitnames.v1.GetBmmInclusionsResponse'
    },
    {'1': 'GetWalletUtxos', '2': '.bitnames.v1.GetWalletUtxosRequest', '3': '.bitnames.v1.GetWalletUtxosResponse'},
    {'1': 'ListUtxos', '2': '.bitnames.v1.ListUtxosRequest', '3': '.bitnames.v1.ListUtxosResponse'},
    {
      '1': 'GetLatestFailedWithdrawalBundleHeight',
      '2': '.bitnames.v1.GetLatestFailedWithdrawalBundleHeightRequest',
      '3': '.bitnames.v1.GetLatestFailedWithdrawalBundleHeightResponse'
    },
    {
      '1': 'GenerateMnemonic',
      '2': '.bitnames.v1.GenerateMnemonicRequest',
      '3': '.bitnames.v1.GenerateMnemonicResponse'
    },
    {
      '1': 'SetSeedFromMnemonic',
      '2': '.bitnames.v1.SetSeedFromMnemonicRequest',
      '3': '.bitnames.v1.SetSeedFromMnemonicResponse'
    },
    {'1': 'CallRaw', '2': '.bitnames.v1.CallRawRequest', '3': '.bitnames.v1.CallRawResponse'},
    {'1': 'GetBitNameData', '2': '.bitnames.v1.GetBitNameDataRequest', '3': '.bitnames.v1.GetBitNameDataResponse'},
    {'1': 'ListBitNames', '2': '.bitnames.v1.ListBitNamesRequest', '3': '.bitnames.v1.ListBitNamesResponse'},
    {'1': 'RegisterBitName', '2': '.bitnames.v1.RegisterBitNameRequest', '3': '.bitnames.v1.RegisterBitNameResponse'},
    {'1': 'ReserveBitName', '2': '.bitnames.v1.ReserveBitNameRequest', '3': '.bitnames.v1.ReserveBitNameResponse'},
    {
      '1': 'GetNewEncryptionKey',
      '2': '.bitnames.v1.GetNewEncryptionKeyRequest',
      '3': '.bitnames.v1.GetNewEncryptionKeyResponse'
    },
    {
      '1': 'GetNewVerifyingKey',
      '2': '.bitnames.v1.GetNewVerifyingKeyRequest',
      '3': '.bitnames.v1.GetNewVerifyingKeyResponse'
    },
    {'1': 'DecryptMsg', '2': '.bitnames.v1.DecryptMsgRequest', '3': '.bitnames.v1.DecryptMsgResponse'},
    {'1': 'EncryptMsg', '2': '.bitnames.v1.EncryptMsgRequest', '3': '.bitnames.v1.EncryptMsgResponse'},
    {'1': 'GetPaymail', '2': '.bitnames.v1.GetPaymailRequest', '3': '.bitnames.v1.GetPaymailResponse'},
    {'1': 'ResolveCommit', '2': '.bitnames.v1.ResolveCommitRequest', '3': '.bitnames.v1.ResolveCommitResponse'},
    {
      '1': 'SignArbitraryMsg',
      '2': '.bitnames.v1.SignArbitraryMsgRequest',
      '3': '.bitnames.v1.SignArbitraryMsgResponse'
    },
    {
      '1': 'SignArbitraryMsgAsAddr',
      '2': '.bitnames.v1.SignArbitraryMsgAsAddrRequest',
      '3': '.bitnames.v1.SignArbitraryMsgAsAddrResponse'
    },
    {
      '1': 'GetWalletAddresses',
      '2': '.bitnames.v1.GetWalletAddressesRequest',
      '3': '.bitnames.v1.GetWalletAddressesResponse'
    },
    {'1': 'MyUtxos', '2': '.bitnames.v1.MyUtxosRequest', '3': '.bitnames.v1.MyUtxosResponse'},
    {'1': 'OpenapiSchema', '2': '.bitnames.v1.OpenapiSchemaRequest', '3': '.bitnames.v1.OpenapiSchemaResponse'},
  ],
};

@$core.Deprecated('Use bitnamesServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> BitnamesServiceBase$messageJson = {
  '.bitnames.v1.GetBalanceRequest': GetBalanceRequest$json,
  '.bitnames.v1.GetBalanceResponse': GetBalanceResponse$json,
  '.bitnames.v1.GetBlockCountRequest': GetBlockCountRequest$json,
  '.bitnames.v1.GetBlockCountResponse': GetBlockCountResponse$json,
  '.bitnames.v1.StopRequest': StopRequest$json,
  '.bitnames.v1.StopResponse': StopResponse$json,
  '.bitnames.v1.GetNewAddressRequest': GetNewAddressRequest$json,
  '.bitnames.v1.GetNewAddressResponse': GetNewAddressResponse$json,
  '.bitnames.v1.WithdrawRequest': WithdrawRequest$json,
  '.bitnames.v1.WithdrawResponse': WithdrawResponse$json,
  '.bitnames.v1.TransferRequest': TransferRequest$json,
  '.bitnames.v1.TransferResponse': TransferResponse$json,
  '.bitnames.v1.GetSidechainWealthRequest': GetSidechainWealthRequest$json,
  '.bitnames.v1.GetSidechainWealthResponse': GetSidechainWealthResponse$json,
  '.bitnames.v1.CreateDepositRequest': CreateDepositRequest$json,
  '.bitnames.v1.CreateDepositResponse': CreateDepositResponse$json,
  '.bitnames.v1.GetPendingWithdrawalBundleRequest': GetPendingWithdrawalBundleRequest$json,
  '.bitnames.v1.GetPendingWithdrawalBundleResponse': GetPendingWithdrawalBundleResponse$json,
  '.bitnames.v1.ConnectPeerRequest': ConnectPeerRequest$json,
  '.bitnames.v1.ConnectPeerResponse': ConnectPeerResponse$json,
  '.bitnames.v1.ListPeersRequest': ListPeersRequest$json,
  '.bitnames.v1.ListPeersResponse': ListPeersResponse$json,
  '.bitnames.v1.MineRequest': MineRequest$json,
  '.bitnames.v1.MineResponse': MineResponse$json,
  '.bitnames.v1.GetBlockRequest': GetBlockRequest$json,
  '.bitnames.v1.GetBlockResponse': GetBlockResponse$json,
  '.bitnames.v1.GetBestMainchainBlockHashRequest': GetBestMainchainBlockHashRequest$json,
  '.bitnames.v1.GetBestMainchainBlockHashResponse': GetBestMainchainBlockHashResponse$json,
  '.bitnames.v1.GetBestSidechainBlockHashRequest': GetBestSidechainBlockHashRequest$json,
  '.bitnames.v1.GetBestSidechainBlockHashResponse': GetBestSidechainBlockHashResponse$json,
  '.bitnames.v1.GetBmmInclusionsRequest': GetBmmInclusionsRequest$json,
  '.bitnames.v1.GetBmmInclusionsResponse': GetBmmInclusionsResponse$json,
  '.bitnames.v1.GetWalletUtxosRequest': GetWalletUtxosRequest$json,
  '.bitnames.v1.GetWalletUtxosResponse': GetWalletUtxosResponse$json,
  '.bitnames.v1.ListUtxosRequest': ListUtxosRequest$json,
  '.bitnames.v1.ListUtxosResponse': ListUtxosResponse$json,
  '.bitnames.v1.GetLatestFailedWithdrawalBundleHeightRequest': GetLatestFailedWithdrawalBundleHeightRequest$json,
  '.bitnames.v1.GetLatestFailedWithdrawalBundleHeightResponse': GetLatestFailedWithdrawalBundleHeightResponse$json,
  '.bitnames.v1.GenerateMnemonicRequest': GenerateMnemonicRequest$json,
  '.bitnames.v1.GenerateMnemonicResponse': GenerateMnemonicResponse$json,
  '.bitnames.v1.SetSeedFromMnemonicRequest': SetSeedFromMnemonicRequest$json,
  '.bitnames.v1.SetSeedFromMnemonicResponse': SetSeedFromMnemonicResponse$json,
  '.bitnames.v1.CallRawRequest': CallRawRequest$json,
  '.bitnames.v1.CallRawResponse': CallRawResponse$json,
  '.bitnames.v1.GetBitNameDataRequest': GetBitNameDataRequest$json,
  '.bitnames.v1.GetBitNameDataResponse': GetBitNameDataResponse$json,
  '.bitnames.v1.ListBitNamesRequest': ListBitNamesRequest$json,
  '.bitnames.v1.ListBitNamesResponse': ListBitNamesResponse$json,
  '.bitnames.v1.RegisterBitNameRequest': RegisterBitNameRequest$json,
  '.bitnames.v1.RegisterBitNameResponse': RegisterBitNameResponse$json,
  '.bitnames.v1.ReserveBitNameRequest': ReserveBitNameRequest$json,
  '.bitnames.v1.ReserveBitNameResponse': ReserveBitNameResponse$json,
  '.bitnames.v1.GetNewEncryptionKeyRequest': GetNewEncryptionKeyRequest$json,
  '.bitnames.v1.GetNewEncryptionKeyResponse': GetNewEncryptionKeyResponse$json,
  '.bitnames.v1.GetNewVerifyingKeyRequest': GetNewVerifyingKeyRequest$json,
  '.bitnames.v1.GetNewVerifyingKeyResponse': GetNewVerifyingKeyResponse$json,
  '.bitnames.v1.DecryptMsgRequest': DecryptMsgRequest$json,
  '.bitnames.v1.DecryptMsgResponse': DecryptMsgResponse$json,
  '.bitnames.v1.EncryptMsgRequest': EncryptMsgRequest$json,
  '.bitnames.v1.EncryptMsgResponse': EncryptMsgResponse$json,
  '.bitnames.v1.GetPaymailRequest': GetPaymailRequest$json,
  '.bitnames.v1.GetPaymailResponse': GetPaymailResponse$json,
  '.bitnames.v1.ResolveCommitRequest': ResolveCommitRequest$json,
  '.bitnames.v1.ResolveCommitResponse': ResolveCommitResponse$json,
  '.bitnames.v1.SignArbitraryMsgRequest': SignArbitraryMsgRequest$json,
  '.bitnames.v1.SignArbitraryMsgResponse': SignArbitraryMsgResponse$json,
  '.bitnames.v1.SignArbitraryMsgAsAddrRequest': SignArbitraryMsgAsAddrRequest$json,
  '.bitnames.v1.SignArbitraryMsgAsAddrResponse': SignArbitraryMsgAsAddrResponse$json,
  '.bitnames.v1.GetWalletAddressesRequest': GetWalletAddressesRequest$json,
  '.bitnames.v1.GetWalletAddressesResponse': GetWalletAddressesResponse$json,
  '.bitnames.v1.MyUtxosRequest': MyUtxosRequest$json,
  '.bitnames.v1.MyUtxosResponse': MyUtxosResponse$json,
  '.bitnames.v1.OpenapiSchemaRequest': OpenapiSchemaRequest$json,
  '.bitnames.v1.OpenapiSchemaResponse': OpenapiSchemaResponse$json,
};

/// Descriptor for `BitnamesService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List bitnamesServiceDescriptor =
    $convert.base64Decode('Cg9CaXRuYW1lc1NlcnZpY2USTQoKR2V0QmFsYW5jZRIeLmJpdG5hbWVzLnYxLkdldEJhbGFuY2'
        'VSZXF1ZXN0Gh8uYml0bmFtZXMudjEuR2V0QmFsYW5jZVJlc3BvbnNlElYKDUdldEJsb2NrQ291'
        'bnQSIS5iaXRuYW1lcy52MS5HZXRCbG9ja0NvdW50UmVxdWVzdBoiLmJpdG5hbWVzLnYxLkdldE'
        'Jsb2NrQ291bnRSZXNwb25zZRI7CgRTdG9wEhguYml0bmFtZXMudjEuU3RvcFJlcXVlc3QaGS5i'
        'aXRuYW1lcy52MS5TdG9wUmVzcG9uc2USVgoNR2V0TmV3QWRkcmVzcxIhLmJpdG5hbWVzLnYxLk'
        'dldE5ld0FkZHJlc3NSZXF1ZXN0GiIuYml0bmFtZXMudjEuR2V0TmV3QWRkcmVzc1Jlc3BvbnNl'
        'EkcKCFdpdGhkcmF3EhwuYml0bmFtZXMudjEuV2l0aGRyYXdSZXF1ZXN0Gh0uYml0bmFtZXMudj'
        'EuV2l0aGRyYXdSZXNwb25zZRJHCghUcmFuc2ZlchIcLmJpdG5hbWVzLnYxLlRyYW5zZmVyUmVx'
        'dWVzdBodLmJpdG5hbWVzLnYxLlRyYW5zZmVyUmVzcG9uc2USZQoSR2V0U2lkZWNoYWluV2VhbH'
        'RoEiYuYml0bmFtZXMudjEuR2V0U2lkZWNoYWluV2VhbHRoUmVxdWVzdBonLmJpdG5hbWVzLnYx'
        'LkdldFNpZGVjaGFpbldlYWx0aFJlc3BvbnNlElYKDUNyZWF0ZURlcG9zaXQSIS5iaXRuYW1lcy'
        '52MS5DcmVhdGVEZXBvc2l0UmVxdWVzdBoiLmJpdG5hbWVzLnYxLkNyZWF0ZURlcG9zaXRSZXNw'
        'b25zZRJ9ChpHZXRQZW5kaW5nV2l0aGRyYXdhbEJ1bmRsZRIuLmJpdG5hbWVzLnYxLkdldFBlbm'
        'RpbmdXaXRoZHJhd2FsQnVuZGxlUmVxdWVzdBovLmJpdG5hbWVzLnYxLkdldFBlbmRpbmdXaXRo'
        'ZHJhd2FsQnVuZGxlUmVzcG9uc2USUAoLQ29ubmVjdFBlZXISHy5iaXRuYW1lcy52MS5Db25uZW'
        'N0UGVlclJlcXVlc3QaIC5iaXRuYW1lcy52MS5Db25uZWN0UGVlclJlc3BvbnNlEkoKCUxpc3RQ'
        'ZWVycxIdLmJpdG5hbWVzLnYxLkxpc3RQZWVyc1JlcXVlc3QaHi5iaXRuYW1lcy52MS5MaXN0UG'
        'VlcnNSZXNwb25zZRI7CgRNaW5lEhguYml0bmFtZXMudjEuTWluZVJlcXVlc3QaGS5iaXRuYW1l'
        'cy52MS5NaW5lUmVzcG9uc2USRwoIR2V0QmxvY2sSHC5iaXRuYW1lcy52MS5HZXRCbG9ja1JlcX'
        'Vlc3QaHS5iaXRuYW1lcy52MS5HZXRCbG9ja1Jlc3BvbnNlEnoKGUdldEJlc3RNYWluY2hhaW5C'
        'bG9ja0hhc2gSLS5iaXRuYW1lcy52MS5HZXRCZXN0TWFpbmNoYWluQmxvY2tIYXNoUmVxdWVzdB'
        'ouLmJpdG5hbWVzLnYxLkdldEJlc3RNYWluY2hhaW5CbG9ja0hhc2hSZXNwb25zZRJ6ChlHZXRC'
        'ZXN0U2lkZWNoYWluQmxvY2tIYXNoEi0uYml0bmFtZXMudjEuR2V0QmVzdFNpZGVjaGFpbkJsb2'
        'NrSGFzaFJlcXVlc3QaLi5iaXRuYW1lcy52MS5HZXRCZXN0U2lkZWNoYWluQmxvY2tIYXNoUmVz'
        'cG9uc2USXwoQR2V0Qm1tSW5jbHVzaW9ucxIkLmJpdG5hbWVzLnYxLkdldEJtbUluY2x1c2lvbn'
        'NSZXF1ZXN0GiUuYml0bmFtZXMudjEuR2V0Qm1tSW5jbHVzaW9uc1Jlc3BvbnNlElkKDkdldFdh'
        'bGxldFV0eG9zEiIuYml0bmFtZXMudjEuR2V0V2FsbGV0VXR4b3NSZXF1ZXN0GiMuYml0bmFtZX'
        'MudjEuR2V0V2FsbGV0VXR4b3NSZXNwb25zZRJKCglMaXN0VXR4b3MSHS5iaXRuYW1lcy52MS5M'
        'aXN0VXR4b3NSZXF1ZXN0Gh4uYml0bmFtZXMudjEuTGlzdFV0eG9zUmVzcG9uc2USngEKJUdldE'
        'xhdGVzdEZhaWxlZFdpdGhkcmF3YWxCdW5kbGVIZWlnaHQSOS5iaXRuYW1lcy52MS5HZXRMYXRl'
        'c3RGYWlsZWRXaXRoZHJhd2FsQnVuZGxlSGVpZ2h0UmVxdWVzdBo6LmJpdG5hbWVzLnYxLkdldE'
        'xhdGVzdEZhaWxlZFdpdGhkcmF3YWxCdW5kbGVIZWlnaHRSZXNwb25zZRJfChBHZW5lcmF0ZU1u'
        'ZW1vbmljEiQuYml0bmFtZXMudjEuR2VuZXJhdGVNbmVtb25pY1JlcXVlc3QaJS5iaXRuYW1lcy'
        '52MS5HZW5lcmF0ZU1uZW1vbmljUmVzcG9uc2USaAoTU2V0U2VlZEZyb21NbmVtb25pYxInLmJp'
        'dG5hbWVzLnYxLlNldFNlZWRGcm9tTW5lbW9uaWNSZXF1ZXN0GiguYml0bmFtZXMudjEuU2V0U2'
        'VlZEZyb21NbmVtb25pY1Jlc3BvbnNlEkQKB0NhbGxSYXcSGy5iaXRuYW1lcy52MS5DYWxsUmF3'
        'UmVxdWVzdBocLmJpdG5hbWVzLnYxLkNhbGxSYXdSZXNwb25zZRJZCg5HZXRCaXROYW1lRGF0YR'
        'IiLmJpdG5hbWVzLnYxLkdldEJpdE5hbWVEYXRhUmVxdWVzdBojLmJpdG5hbWVzLnYxLkdldEJp'
        'dE5hbWVEYXRhUmVzcG9uc2USUwoMTGlzdEJpdE5hbWVzEiAuYml0bmFtZXMudjEuTGlzdEJpdE'
        '5hbWVzUmVxdWVzdBohLmJpdG5hbWVzLnYxLkxpc3RCaXROYW1lc1Jlc3BvbnNlElwKD1JlZ2lz'
        'dGVyQml0TmFtZRIjLmJpdG5hbWVzLnYxLlJlZ2lzdGVyQml0TmFtZVJlcXVlc3QaJC5iaXRuYW'
        '1lcy52MS5SZWdpc3RlckJpdE5hbWVSZXNwb25zZRJZCg5SZXNlcnZlQml0TmFtZRIiLmJpdG5h'
        'bWVzLnYxLlJlc2VydmVCaXROYW1lUmVxdWVzdBojLmJpdG5hbWVzLnYxLlJlc2VydmVCaXROYW'
        '1lUmVzcG9uc2USaAoTR2V0TmV3RW5jcnlwdGlvbktleRInLmJpdG5hbWVzLnYxLkdldE5ld0Vu'
        'Y3J5cHRpb25LZXlSZXF1ZXN0GiguYml0bmFtZXMudjEuR2V0TmV3RW5jcnlwdGlvbktleVJlc3'
        'BvbnNlEmUKEkdldE5ld1ZlcmlmeWluZ0tleRImLmJpdG5hbWVzLnYxLkdldE5ld1ZlcmlmeWlu'
        'Z0tleVJlcXVlc3QaJy5iaXRuYW1lcy52MS5HZXROZXdWZXJpZnlpbmdLZXlSZXNwb25zZRJNCg'
        'pEZWNyeXB0TXNnEh4uYml0bmFtZXMudjEuRGVjcnlwdE1zZ1JlcXVlc3QaHy5iaXRuYW1lcy52'
        'MS5EZWNyeXB0TXNnUmVzcG9uc2USTQoKRW5jcnlwdE1zZxIeLmJpdG5hbWVzLnYxLkVuY3J5cH'
        'RNc2dSZXF1ZXN0Gh8uYml0bmFtZXMudjEuRW5jcnlwdE1zZ1Jlc3BvbnNlEk0KCkdldFBheW1h'
        'aWwSHi5iaXRuYW1lcy52MS5HZXRQYXltYWlsUmVxdWVzdBofLmJpdG5hbWVzLnYxLkdldFBheW'
        '1haWxSZXNwb25zZRJWCg1SZXNvbHZlQ29tbWl0EiEuYml0bmFtZXMudjEuUmVzb2x2ZUNvbW1p'
        'dFJlcXVlc3QaIi5iaXRuYW1lcy52MS5SZXNvbHZlQ29tbWl0UmVzcG9uc2USXwoQU2lnbkFyYm'
        'l0cmFyeU1zZxIkLmJpdG5hbWVzLnYxLlNpZ25BcmJpdHJhcnlNc2dSZXF1ZXN0GiUuYml0bmFt'
        'ZXMudjEuU2lnbkFyYml0cmFyeU1zZ1Jlc3BvbnNlEnEKFlNpZ25BcmJpdHJhcnlNc2dBc0FkZH'
        'ISKi5iaXRuYW1lcy52MS5TaWduQXJiaXRyYXJ5TXNnQXNBZGRyUmVxdWVzdBorLmJpdG5hbWVz'
        'LnYxLlNpZ25BcmJpdHJhcnlNc2dBc0FkZHJSZXNwb25zZRJlChJHZXRXYWxsZXRBZGRyZXNzZX'
        'MSJi5iaXRuYW1lcy52MS5HZXRXYWxsZXRBZGRyZXNzZXNSZXF1ZXN0GicuYml0bmFtZXMudjEu'
        'R2V0V2FsbGV0QWRkcmVzc2VzUmVzcG9uc2USRAoHTXlVdHhvcxIbLmJpdG5hbWVzLnYxLk15VX'
        'R4b3NSZXF1ZXN0GhwuYml0bmFtZXMudjEuTXlVdHhvc1Jlc3BvbnNlElYKDU9wZW5hcGlTY2hl'
        'bWESIS5iaXRuYW1lcy52MS5PcGVuYXBpU2NoZW1hUmVxdWVzdBoiLmJpdG5hbWVzLnYxLk9wZW'
        '5hcGlTY2hlbWFSZXNwb25zZQ==');
