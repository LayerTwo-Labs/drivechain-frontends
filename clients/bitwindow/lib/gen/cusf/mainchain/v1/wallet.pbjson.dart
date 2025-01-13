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

@$core.Deprecated('Use walletTransactionDescriptor instead')
const WalletTransaction$json = {
  '1': 'WalletTransaction',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 11, '6': '.cusf.common.v1.ReverseHex', '10': 'txid'},
    {'1': 'fee_sats', '3': 2, '4': 1, '5': 4, '10': 'feeSats'},
    {'1': 'received_sats', '3': 3, '4': 1, '5': 4, '10': 'receivedSats'},
    {'1': 'sent_sats', '3': 4, '4': 1, '5': 4, '10': 'sentSats'},
    {'1': 'confirmation_info', '3': 5, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.WalletTransaction.Confirmation', '10': 'confirmationInfo'},
  ],
  '3': [WalletTransaction_Confirmation$json],
};

@$core.Deprecated('Use walletTransactionDescriptor instead')
const WalletTransaction_Confirmation$json = {
  '1': 'Confirmation',
  '2': [
    {'1': 'height', '3': 1, '4': 1, '5': 13, '10': 'height'},
    {'1': 'block_hash', '3': 2, '4': 1, '5': 11, '6': '.cusf.common.v1.ReverseHex', '10': 'blockHash'},
    {'1': 'timestamp', '3': 3, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'timestamp'},
  ],
};

/// Descriptor for `WalletTransaction`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List walletTransactionDescriptor = $convert.base64Decode(
    'ChFXYWxsZXRUcmFuc2FjdGlvbhIuCgR0eGlkGAEgASgLMhouY3VzZi5jb21tb24udjEuUmV2ZX'
    'JzZUhleFIEdHhpZBIZCghmZWVfc2F0cxgCIAEoBFIHZmVlU2F0cxIjCg1yZWNlaXZlZF9zYXRz'
    'GAMgASgEUgxyZWNlaXZlZFNhdHMSGwoJc2VudF9zYXRzGAQgASgEUghzZW50U2F0cxJeChFjb2'
    '5maXJtYXRpb25faW5mbxgFIAEoCzIxLmN1c2YubWFpbmNoYWluLnYxLldhbGxldFRyYW5zYWN0'
    'aW9uLkNvbmZpcm1hdGlvblIQY29uZmlybWF0aW9uSW5mbxqbAQoMQ29uZmlybWF0aW9uEhYKBm'
    'hlaWdodBgBIAEoDVIGaGVpZ2h0EjkKCmJsb2NrX2hhc2gYAiABKAsyGi5jdXNmLmNvbW1vbi52'
    'MS5SZXZlcnNlSGV4UglibG9ja0hhc2gSOAoJdGltZXN0YW1wGAMgASgLMhouZ29vZ2xlLnByb3'
    'RvYnVmLlRpbWVzdGFtcFIJdGltZXN0YW1w');

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

@$core.Deprecated('Use unlockWalletResponseDescriptor instead')
const UnlockWalletResponse$json = {
  '1': 'UnlockWalletResponse',
};

/// Descriptor for `UnlockWalletResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unlockWalletResponseDescriptor = $convert.base64Decode(
    'ChRVbmxvY2tXYWxsZXRSZXNwb25zZQ==');

@$core.Deprecated('Use createWalletRequestDescriptor instead')
const CreateWalletRequest$json = {
  '1': 'CreateWalletRequest',
  '2': [
    {'1': 'mnemonic_words', '3': 1, '4': 3, '5': 9, '10': 'mnemonicWords'},
    {'1': 'mnemonic_path', '3': 2, '4': 1, '5': 9, '10': 'mnemonicPath'},
    {'1': 'password', '3': 3, '4': 1, '5': 9, '10': 'password'},
  ],
};

/// Descriptor for `CreateWalletRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createWalletRequestDescriptor = $convert.base64Decode(
    'ChNDcmVhdGVXYWxsZXRSZXF1ZXN0EiUKDm1uZW1vbmljX3dvcmRzGAEgAygJUg1tbmVtb25pY1'
    'dvcmRzEiMKDW1uZW1vbmljX3BhdGgYAiABKAlSDG1uZW1vbmljUGF0aBIaCghwYXNzd29yZBgD'
    'IAEoCVIIcGFzc3dvcmQ=');

@$core.Deprecated('Use createWalletResponseDescriptor instead')
const CreateWalletResponse$json = {
  '1': 'CreateWalletResponse',
};

/// Descriptor for `CreateWalletResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createWalletResponseDescriptor = $convert.base64Decode(
    'ChRDcmVhdGVXYWxsZXRSZXNwb25zZQ==');

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
    {'1': 'critical_hash', '3': 4, '4': 1, '5': 11, '6': '.cusf.common.v1.ConsensusHex', '10': 'criticalHash'},
    {'1': 'prev_bytes', '3': 5, '4': 1, '5': 11, '6': '.cusf.common.v1.ReverseHex', '10': 'prevBytes'},
  ],
};

/// Descriptor for `CreateBmmCriticalDataTransactionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createBmmCriticalDataTransactionRequestDescriptor = $convert.base64Decode(
    'CidDcmVhdGVCbW1Dcml0aWNhbERhdGFUcmFuc2FjdGlvblJlcXVlc3QSPwoMc2lkZWNoYWluX2'
    'lkGAEgASgLMhwuZ29vZ2xlLnByb3RvYnVmLlVJbnQzMlZhbHVlUgtzaWRlY2hhaW5JZBI7Cgp2'
    'YWx1ZV9zYXRzGAIgASgLMhwuZ29vZ2xlLnByb3RvYnVmLlVJbnQ2NFZhbHVlUgl2YWx1ZVNhdH'
    'MSNAoGaGVpZ2h0GAMgASgLMhwuZ29vZ2xlLnByb3RvYnVmLlVJbnQzMlZhbHVlUgZoZWlnaHQS'
    'QQoNY3JpdGljYWxfaGFzaBgEIAEoCzIcLmN1c2YuY29tbW9uLnYxLkNvbnNlbnN1c0hleFIMY3'
    'JpdGljYWxIYXNoEjkKCnByZXZfYnl0ZXMYBSABKAsyGi5jdXNmLmNvbW1vbi52MS5SZXZlcnNl'
    'SGV4UglwcmV2Qnl0ZXM=');

@$core.Deprecated('Use createBmmCriticalDataTransactionResponseDescriptor instead')
const CreateBmmCriticalDataTransactionResponse$json = {
  '1': 'CreateBmmCriticalDataTransactionResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 11, '6': '.cusf.common.v1.ReverseHex', '10': 'txid'},
  ],
};

/// Descriptor for `CreateBmmCriticalDataTransactionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createBmmCriticalDataTransactionResponseDescriptor = $convert.base64Decode(
    'CihDcmVhdGVCbW1Dcml0aWNhbERhdGFUcmFuc2FjdGlvblJlc3BvbnNlEi4KBHR4aWQYASABKA'
    'syGi5jdXNmLmNvbW1vbi52MS5SZXZlcnNlSGV4UgR0eGlk');

@$core.Deprecated('Use createDepositTransactionRequestDescriptor instead')
const CreateDepositTransactionRequest$json = {
  '1': 'CreateDepositTransactionRequest',
  '2': [
    {'1': 'sidechain_id', '3': 1, '4': 1, '5': 11, '6': '.google.protobuf.UInt32Value', '10': 'sidechainId'},
    {'1': 'address', '3': 2, '4': 1, '5': 11, '6': '.cusf.common.v1.Hex', '10': 'address'},
    {'1': 'value_sats', '3': 3, '4': 1, '5': 11, '6': '.google.protobuf.UInt64Value', '10': 'valueSats'},
    {'1': 'fee_sats', '3': 4, '4': 1, '5': 11, '6': '.google.protobuf.UInt64Value', '10': 'feeSats'},
  ],
};

/// Descriptor for `CreateDepositTransactionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createDepositTransactionRequestDescriptor = $convert.base64Decode(
    'Ch9DcmVhdGVEZXBvc2l0VHJhbnNhY3Rpb25SZXF1ZXN0Ej8KDHNpZGVjaGFpbl9pZBgBIAEoCz'
    'IcLmdvb2dsZS5wcm90b2J1Zi5VSW50MzJWYWx1ZVILc2lkZWNoYWluSWQSLQoHYWRkcmVzcxgC'
    'IAEoCzITLmN1c2YuY29tbW9uLnYxLkhleFIHYWRkcmVzcxI7Cgp2YWx1ZV9zYXRzGAMgASgLMh'
    'wuZ29vZ2xlLnByb3RvYnVmLlVJbnQ2NFZhbHVlUgl2YWx1ZVNhdHMSNwoIZmVlX3NhdHMYBCAB'
    'KAsyHC5nb29nbGUucHJvdG9idWYuVUludDY0VmFsdWVSB2ZlZVNhdHM=');

@$core.Deprecated('Use createDepositTransactionResponseDescriptor instead')
const CreateDepositTransactionResponse$json = {
  '1': 'CreateDepositTransactionResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 11, '6': '.cusf.common.v1.ReverseHex', '10': 'txid'},
  ],
};

/// Descriptor for `CreateDepositTransactionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createDepositTransactionResponseDescriptor = $convert.base64Decode(
    'CiBDcmVhdGVEZXBvc2l0VHJhbnNhY3Rpb25SZXNwb25zZRIuCgR0eGlkGAEgASgLMhouY3VzZi'
    '5jb21tb24udjEuUmV2ZXJzZUhleFIEdHhpZA==');

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

@$core.Deprecated('Use createSidechainProposalRequestDescriptor instead')
const CreateSidechainProposalRequest$json = {
  '1': 'CreateSidechainProposalRequest',
  '2': [
    {'1': 'sidechain_id', '3': 1, '4': 1, '5': 11, '6': '.google.protobuf.UInt32Value', '10': 'sidechainId'},
    {'1': 'declaration', '3': 2, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.SidechainDeclaration', '10': 'declaration'},
  ],
};

/// Descriptor for `CreateSidechainProposalRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createSidechainProposalRequestDescriptor = $convert.base64Decode(
    'Ch5DcmVhdGVTaWRlY2hhaW5Qcm9wb3NhbFJlcXVlc3QSPwoMc2lkZWNoYWluX2lkGAEgASgLMh'
    'wuZ29vZ2xlLnByb3RvYnVmLlVJbnQzMlZhbHVlUgtzaWRlY2hhaW5JZBJJCgtkZWNsYXJhdGlv'
    'bhgCIAEoCzInLmN1c2YubWFpbmNoYWluLnYxLlNpZGVjaGFpbkRlY2xhcmF0aW9uUgtkZWNsYX'
    'JhdGlvbg==');

@$core.Deprecated('Use createSidechainProposalResponseDescriptor instead')
const CreateSidechainProposalResponse$json = {
  '1': 'CreateSidechainProposalResponse',
  '2': [
    {'1': 'confirmed', '3': 1, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.CreateSidechainProposalResponse.Confirmed', '9': 0, '10': 'confirmed'},
    {'1': 'not_confirmed', '3': 2, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.CreateSidechainProposalResponse.NotConfirmed', '9': 0, '10': 'notConfirmed'},
  ],
  '3': [CreateSidechainProposalResponse_Confirmed$json, CreateSidechainProposalResponse_NotConfirmed$json],
  '8': [
    {'1': 'event'},
  ],
};

@$core.Deprecated('Use createSidechainProposalResponseDescriptor instead')
const CreateSidechainProposalResponse_Confirmed$json = {
  '1': 'Confirmed',
  '2': [
    {'1': 'block_hash', '3': 1, '4': 1, '5': 11, '6': '.cusf.common.v1.ReverseHex', '10': 'blockHash'},
    {'1': 'confirmations', '3': 2, '4': 1, '5': 11, '6': '.google.protobuf.UInt32Value', '10': 'confirmations'},
    {'1': 'height', '3': 3, '4': 1, '5': 11, '6': '.google.protobuf.UInt32Value', '10': 'height'},
    {'1': 'outpoint', '3': 4, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.OutPoint', '10': 'outpoint'},
    {'1': 'prev_block_hash', '3': 5, '4': 1, '5': 11, '6': '.cusf.common.v1.ReverseHex', '10': 'prevBlockHash'},
  ],
};

@$core.Deprecated('Use createSidechainProposalResponseDescriptor instead')
const CreateSidechainProposalResponse_NotConfirmed$json = {
  '1': 'NotConfirmed',
  '2': [
    {'1': 'block_hash', '3': 1, '4': 1, '5': 11, '6': '.cusf.common.v1.ReverseHex', '10': 'blockHash'},
    {'1': 'height', '3': 2, '4': 1, '5': 11, '6': '.google.protobuf.UInt32Value', '10': 'height'},
    {'1': 'prev_block_hash', '3': 3, '4': 1, '5': 11, '6': '.cusf.common.v1.ReverseHex', '10': 'prevBlockHash'},
  ],
};

/// Descriptor for `CreateSidechainProposalResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createSidechainProposalResponseDescriptor = $convert.base64Decode(
    'Ch9DcmVhdGVTaWRlY2hhaW5Qcm9wb3NhbFJlc3BvbnNlElwKCWNvbmZpcm1lZBgBIAEoCzI8Lm'
    'N1c2YubWFpbmNoYWluLnYxLkNyZWF0ZVNpZGVjaGFpblByb3Bvc2FsUmVzcG9uc2UuQ29uZmly'
    'bWVkSABSCWNvbmZpcm1lZBJmCg1ub3RfY29uZmlybWVkGAIgASgLMj8uY3VzZi5tYWluY2hhaW'
    '4udjEuQ3JlYXRlU2lkZWNoYWluUHJvcG9zYWxSZXNwb25zZS5Ob3RDb25maXJtZWRIAFIMbm90'
    'Q29uZmlybWVkGr0CCglDb25maXJtZWQSOQoKYmxvY2tfaGFzaBgBIAEoCzIaLmN1c2YuY29tbW'
    '9uLnYxLlJldmVyc2VIZXhSCWJsb2NrSGFzaBJCCg1jb25maXJtYXRpb25zGAIgASgLMhwuZ29v'
    'Z2xlLnByb3RvYnVmLlVJbnQzMlZhbHVlUg1jb25maXJtYXRpb25zEjQKBmhlaWdodBgDIAEoCz'
    'IcLmdvb2dsZS5wcm90b2J1Zi5VSW50MzJWYWx1ZVIGaGVpZ2h0EjcKCG91dHBvaW50GAQgASgL'
    'MhsuY3VzZi5tYWluY2hhaW4udjEuT3V0UG9pbnRSCG91dHBvaW50EkIKD3ByZXZfYmxvY2tfaG'
    'FzaBgFIAEoCzIaLmN1c2YuY29tbW9uLnYxLlJldmVyc2VIZXhSDXByZXZCbG9ja0hhc2gawwEK'
    'DE5vdENvbmZpcm1lZBI5CgpibG9ja19oYXNoGAEgASgLMhouY3VzZi5jb21tb24udjEuUmV2ZX'
    'JzZUhleFIJYmxvY2tIYXNoEjQKBmhlaWdodBgCIAEoCzIcLmdvb2dsZS5wcm90b2J1Zi5VSW50'
    'MzJWYWx1ZVIGaGVpZ2h0EkIKD3ByZXZfYmxvY2tfaGFzaBgDIAEoCzIaLmN1c2YuY29tbW9uLn'
    'YxLlJldmVyc2VIZXhSDXByZXZCbG9ja0hhc2hCBwoFZXZlbnQ=');

@$core.Deprecated('Use generateBlocksRequestDescriptor instead')
const GenerateBlocksRequest$json = {
  '1': 'GenerateBlocksRequest',
  '2': [
    {'1': 'blocks', '3': 1, '4': 1, '5': 11, '6': '.google.protobuf.UInt32Value', '10': 'blocks'},
    {'1': 'ack_all_proposals', '3': 2, '4': 1, '5': 8, '10': 'ackAllProposals'},
  ],
};

/// Descriptor for `GenerateBlocksRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List generateBlocksRequestDescriptor = $convert.base64Decode(
    'ChVHZW5lcmF0ZUJsb2Nrc1JlcXVlc3QSNAoGYmxvY2tzGAEgASgLMhwuZ29vZ2xlLnByb3RvYn'
    'VmLlVJbnQzMlZhbHVlUgZibG9ja3MSKgoRYWNrX2FsbF9wcm9wb3NhbHMYAiABKAhSD2Fja0Fs'
    'bFByb3Bvc2Fscw==');

@$core.Deprecated('Use generateBlocksResponseDescriptor instead')
const GenerateBlocksResponse$json = {
  '1': 'GenerateBlocksResponse',
  '2': [
    {'1': 'block_hash', '3': 1, '4': 1, '5': 11, '6': '.cusf.common.v1.ReverseHex', '10': 'blockHash'},
  ],
};

/// Descriptor for `GenerateBlocksResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List generateBlocksResponseDescriptor = $convert.base64Decode(
    'ChZHZW5lcmF0ZUJsb2Nrc1Jlc3BvbnNlEjkKCmJsb2NrX2hhc2gYASABKAsyGi5jdXNmLmNvbW'
    '1vbi52MS5SZXZlcnNlSGV4UglibG9ja0hhc2g=');

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
    {'1': 'confirmed_sats', '3': 1, '4': 1, '5': 4, '10': 'confirmedSats'},
    {'1': 'pending_sats', '3': 2, '4': 1, '5': 4, '10': 'pendingSats'},
  ],
};

/// Descriptor for `GetBalanceResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBalanceResponseDescriptor = $convert.base64Decode(
    'ChJHZXRCYWxhbmNlUmVzcG9uc2USJQoOY29uZmlybWVkX3NhdHMYASABKARSDWNvbmZpcm1lZF'
    'NhdHMSIQoMcGVuZGluZ19zYXRzGAIgASgEUgtwZW5kaW5nU2F0cw==');

@$core.Deprecated('Use listTransactionsRequestDescriptor instead')
const ListTransactionsRequest$json = {
  '1': 'ListTransactionsRequest',
};

/// Descriptor for `ListTransactionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listTransactionsRequestDescriptor = $convert.base64Decode(
    'ChdMaXN0VHJhbnNhY3Rpb25zUmVxdWVzdA==');

@$core.Deprecated('Use listTransactionsResponseDescriptor instead')
const ListTransactionsResponse$json = {
  '1': 'ListTransactionsResponse',
  '2': [
    {'1': 'transactions', '3': 1, '4': 3, '5': 11, '6': '.cusf.mainchain.v1.WalletTransaction', '10': 'transactions'},
  ],
};

/// Descriptor for `ListTransactionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listTransactionsResponseDescriptor = $convert.base64Decode(
    'ChhMaXN0VHJhbnNhY3Rpb25zUmVzcG9uc2USSAoMdHJhbnNhY3Rpb25zGAEgAygLMiQuY3VzZi'
    '5tYWluY2hhaW4udjEuV2FsbGV0VHJhbnNhY3Rpb25SDHRyYW5zYWN0aW9ucw==');

@$core.Deprecated('Use sendTransactionRequestDescriptor instead')
const SendTransactionRequest$json = {
  '1': 'SendTransactionRequest',
  '2': [
    {'1': 'destinations', '3': 1, '4': 3, '5': 11, '6': '.cusf.mainchain.v1.SendTransactionRequest.DestinationsEntry', '10': 'destinations'},
    {'1': 'fee_rate', '3': 2, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.SendTransactionRequest.FeeRate', '9': 0, '10': 'feeRate', '17': true},
    {'1': 'op_return_message', '3': 3, '4': 1, '5': 11, '6': '.cusf.common.v1.Hex', '9': 1, '10': 'opReturnMessage', '17': true},
  ],
  '3': [SendTransactionRequest_FeeRate$json, SendTransactionRequest_DestinationsEntry$json],
  '8': [
    {'1': '_fee_rate'},
    {'1': '_op_return_message'},
  ],
};

@$core.Deprecated('Use sendTransactionRequestDescriptor instead')
const SendTransactionRequest_FeeRate$json = {
  '1': 'FeeRate',
  '2': [
    {'1': 'sat_per_vbyte', '3': 1, '4': 1, '5': 4, '9': 0, '10': 'satPerVbyte'},
    {'1': 'sats', '3': 2, '4': 1, '5': 4, '9': 0, '10': 'sats'},
  ],
  '8': [
    {'1': 'fee'},
  ],
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
    'ChZTZW5kVHJhbnNhY3Rpb25SZXF1ZXN0El8KDGRlc3RpbmF0aW9ucxgBIAMoCzI7LmN1c2YubW'
    'FpbmNoYWluLnYxLlNlbmRUcmFuc2FjdGlvblJlcXVlc3QuRGVzdGluYXRpb25zRW50cnlSDGRl'
    'c3RpbmF0aW9ucxJRCghmZWVfcmF0ZRgCIAEoCzIxLmN1c2YubWFpbmNoYWluLnYxLlNlbmRUcm'
    'Fuc2FjdGlvblJlcXVlc3QuRmVlUmF0ZUgAUgdmZWVSYXRliAEBEkQKEW9wX3JldHVybl9tZXNz'
    'YWdlGAMgASgLMhMuY3VzZi5jb21tb24udjEuSGV4SAFSD29wUmV0dXJuTWVzc2FnZYgBARpMCg'
    'dGZWVSYXRlEiQKDXNhdF9wZXJfdmJ5dGUYASABKARIAFILc2F0UGVyVmJ5dGUSFAoEc2F0cxgC'
    'IAEoBEgAUgRzYXRzQgUKA2ZlZRo/ChFEZXN0aW5hdGlvbnNFbnRyeRIQCgNrZXkYASABKAlSA2'
    'tleRIUCgV2YWx1ZRgCIAEoBFIFdmFsdWU6AjgBQgsKCV9mZWVfcmF0ZUIUChJfb3BfcmV0dXJu'
    'X21lc3NhZ2U=');

@$core.Deprecated('Use sendTransactionResponseDescriptor instead')
const SendTransactionResponse$json = {
  '1': 'SendTransactionResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 11, '6': '.cusf.common.v1.ReverseHex', '10': 'txid'},
  ],
};

/// Descriptor for `SendTransactionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendTransactionResponseDescriptor = $convert.base64Decode(
    'ChdTZW5kVHJhbnNhY3Rpb25SZXNwb25zZRIuCgR0eGlkGAEgASgLMhouY3VzZi5jb21tb24udj'
    'EuUmV2ZXJzZUhleFIEdHhpZA==');

