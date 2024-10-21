//
//  Generated code. Do not modify.
//  source: cusf/mainchain/v1/wallet.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use broadcastWithdrawalBundleRequestDescriptor instead')
const BroadcastWithdrawalBundleRequest$json = {
  '1': 'BroadcastWithdrawalBundleRequest',
  '2': [
    {'1': 'sidechain_id', '3': 1, '4': 1, '5': 11, '6': '.google.protobuf.UInt32Value', '10': 'sidechainId'},
    {'1': 'transaction', '3': 2, '4': 1, '5': 11, '6': '.google.protobuf.BytesValue', '10': 'transaction'},
  ],
};

/// Descriptor for `BroadcastWithdrawalBundleRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List broadcastWithdrawalBundleRequestDescriptor = $convert.base64Decode(
    'CiBCcm9hZGNhc3RXaXRoZHJhd2FsQnVuZGxlUmVxdWVzdBI/CgxzaWRlY2hhaW5faWQYASABKA'
    'syHC5nb29nbGUucHJvdG9idWYuVUludDMyVmFsdWVSC3NpZGVjaGFpbklkEj0KC3RyYW5zYWN0'
    'aW9uGAIgASgLMhsuZ29vZ2xlLnByb3RvYnVmLkJ5dGVzVmFsdWVSC3RyYW5zYWN0aW9u');

@$core.Deprecated('Use broadcastWithdrawalBundleResponseDescriptor instead')
const BroadcastWithdrawalBundleResponse$json = {
  '1': 'BroadcastWithdrawalBundleResponse',
};

/// Descriptor for `BroadcastWithdrawalBundleResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List broadcastWithdrawalBundleResponseDescriptor = $convert.base64Decode(
    'CiFCcm9hZGNhc3RXaXRoZHJhd2FsQnVuZGxlUmVzcG9uc2U=');

@$core.Deprecated('Use createBmmCriticalDataTransactionRequestDescriptor instead')
const CreateBmmCriticalDataTransactionRequest$json = {
  '1': 'CreateBmmCriticalDataTransactionRequest',
  '2': [
    {'1': 'sidechain_id', '3': 1, '4': 1, '5': 11, '6': '.google.protobuf.UInt32Value', '10': 'sidechainId'},
    {'1': 'value_sats', '3': 2, '4': 1, '5': 11, '6': '.google.protobuf.UInt64Value', '10': 'valueSats'},
    {'1': 'height', '3': 3, '4': 1, '5': 11, '6': '.google.protobuf.UInt32Value', '10': 'height'},
    {'1': 'critical_hash', '3': 4, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.ConsensusHex', '10': 'criticalHash'},
    {'1': 'prev_bytes', '3': 5, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.ReverseHex', '10': 'prevBytes'},
  ],
};

/// Descriptor for `CreateBmmCriticalDataTransactionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createBmmCriticalDataTransactionRequestDescriptor = $convert.base64Decode(
    'CidDcmVhdGVCbW1Dcml0aWNhbERhdGFUcmFuc2FjdGlvblJlcXVlc3QSPwoMc2lkZWNoYWluX2'
    'lkGAEgASgLMhwuZ29vZ2xlLnByb3RvYnVmLlVJbnQzMlZhbHVlUgtzaWRlY2hhaW5JZBI7Cgp2'
    'YWx1ZV9zYXRzGAIgASgLMhwuZ29vZ2xlLnByb3RvYnVmLlVJbnQ2NFZhbHVlUgl2YWx1ZVNhdH'
    'MSNAoGaGVpZ2h0GAMgASgLMhwuZ29vZ2xlLnByb3RvYnVmLlVJbnQzMlZhbHVlUgZoZWlnaHQS'
    'RAoNY3JpdGljYWxfaGFzaBgEIAEoCzIfLmN1c2YubWFpbmNoYWluLnYxLkNvbnNlbnN1c0hleF'
    'IMY3JpdGljYWxIYXNoEjwKCnByZXZfYnl0ZXMYBSABKAsyHS5jdXNmLm1haW5jaGFpbi52MS5S'
    'ZXZlcnNlSGV4UglwcmV2Qnl0ZXM=');

@$core.Deprecated('Use createBmmCriticalDataTransactionResponseDescriptor instead')
const CreateBmmCriticalDataTransactionResponse$json = {
  '1': 'CreateBmmCriticalDataTransactionResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.ConsensusHex', '10': 'txid'},
  ],
};

/// Descriptor for `CreateBmmCriticalDataTransactionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createBmmCriticalDataTransactionResponseDescriptor = $convert.base64Decode(
    'CihDcmVhdGVCbW1Dcml0aWNhbERhdGFUcmFuc2FjdGlvblJlc3BvbnNlEjMKBHR4aWQYASABKA'
    'syHy5jdXNmLm1haW5jaGFpbi52MS5Db25zZW5zdXNIZXhSBHR4aWQ=');

@$core.Deprecated('Use createDepositTransactionRequestDescriptor instead')
const CreateDepositTransactionRequest$json = {
  '1': 'CreateDepositTransactionRequest',
  '2': [
    {'1': 'sidechain_id', '3': 1, '4': 1, '5': 13, '10': 'sidechainId'},
    {'1': 'address', '3': 2, '4': 1, '5': 9, '10': 'address'},
    {'1': 'value_sats', '3': 3, '4': 1, '5': 4, '10': 'valueSats'},
    {'1': 'fee_sats', '3': 4, '4': 1, '5': 4, '10': 'feeSats'},
  ],
};

/// Descriptor for `CreateDepositTransactionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createDepositTransactionRequestDescriptor = $convert.base64Decode(
    'Ch9DcmVhdGVEZXBvc2l0VHJhbnNhY3Rpb25SZXF1ZXN0EiEKDHNpZGVjaGFpbl9pZBgBIAEoDV'
    'ILc2lkZWNoYWluSWQSGAoHYWRkcmVzcxgCIAEoCVIHYWRkcmVzcxIdCgp2YWx1ZV9zYXRzGAMg'
    'ASgEUgl2YWx1ZVNhdHMSGQoIZmVlX3NhdHMYBCABKARSB2ZlZVNhdHM=');

@$core.Deprecated('Use createDepositTransactionResponseDescriptor instead')
const CreateDepositTransactionResponse$json = {
  '1': 'CreateDepositTransactionResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.ConsensusHex', '10': 'txid'},
  ],
};

/// Descriptor for `CreateDepositTransactionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createDepositTransactionResponseDescriptor = $convert.base64Decode(
    'CiBDcmVhdGVEZXBvc2l0VHJhbnNhY3Rpb25SZXNwb25zZRIzCgR0eGlkGAEgASgLMh8uY3VzZi'
    '5tYWluY2hhaW4udjEuQ29uc2Vuc3VzSGV4UgR0eGlk');

@$core.Deprecated('Use createNewAddressRequestDescriptor instead')
const CreateNewAddressRequest$json = {
  '1': 'CreateNewAddressRequest',
};

/// Descriptor for `CreateNewAddressRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createNewAddressRequestDescriptor = $convert.base64Decode(
    'ChdDcmVhdGVOZXdBZGRyZXNzUmVxdWVzdA==');

@$core.Deprecated('Use createNewAddressResponseDescriptor instead')
const CreateNewAddressResponse$json = {
  '1': 'CreateNewAddressResponse',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
  ],
};

/// Descriptor for `CreateNewAddressResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createNewAddressResponseDescriptor = $convert.base64Decode(
    'ChhDcmVhdGVOZXdBZGRyZXNzUmVzcG9uc2USGAoHYWRkcmVzcxgBIAEoCVIHYWRkcmVzcw==');

@$core.Deprecated('Use generateBlocksRequestDescriptor instead')
const GenerateBlocksRequest$json = {
  '1': 'GenerateBlocksRequest',
  '2': [
    {'1': 'blocks', '3': 1, '4': 1, '5': 11, '6': '.google.protobuf.UInt32Value', '10': 'blocks'},
  ],
};

/// Descriptor for `GenerateBlocksRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List generateBlocksRequestDescriptor = $convert.base64Decode(
    'ChVHZW5lcmF0ZUJsb2Nrc1JlcXVlc3QSNAoGYmxvY2tzGAEgASgLMhwuZ29vZ2xlLnByb3RvYn'
    'VmLlVJbnQzMlZhbHVlUgZibG9ja3M=');

@$core.Deprecated('Use generateBlocksResponseDescriptor instead')
const GenerateBlocksResponse$json = {
  '1': 'GenerateBlocksResponse',
};

/// Descriptor for `GenerateBlocksResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List generateBlocksResponseDescriptor = $convert.base64Decode(
    'ChZHZW5lcmF0ZUJsb2Nrc1Jlc3BvbnNl');

