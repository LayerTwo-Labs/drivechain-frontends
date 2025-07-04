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

import '../../../google/protobuf/timestamp.pbjson.dart' as $5;
import '../../../google/protobuf/wrappers.pbjson.dart' as $0;
import '../../common/v1/common.pbjson.dart' as $1;
import 'common.pbjson.dart' as $3;

@$core.Deprecated('Use walletTransactionDescriptor instead')
const WalletTransaction$json = {
  '1': 'WalletTransaction',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 11, '6': '.cusf.common.v1.ReverseHex', '10': 'txid'},
    {'1': 'raw_transaction', '3': 6, '4': 1, '5': 11, '6': '.cusf.common.v1.ConsensusHex', '10': 'rawTransaction'},
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
    'JzZUhleFIEdHhpZBJFCg9yYXdfdHJhbnNhY3Rpb24YBiABKAsyHC5jdXNmLmNvbW1vbi52MS5D'
    'b25zZW5zdXNIZXhSDnJhd1RyYW5zYWN0aW9uEhkKCGZlZV9zYXRzGAIgASgEUgdmZWVTYXRzEi'
    'MKDXJlY2VpdmVkX3NhdHMYAyABKARSDHJlY2VpdmVkU2F0cxIbCglzZW50X3NhdHMYBCABKARS'
    'CHNlbnRTYXRzEl4KEWNvbmZpcm1hdGlvbl9pbmZvGAUgASgLMjEuY3VzZi5tYWluY2hhaW4udj'
    'EuV2FsbGV0VHJhbnNhY3Rpb24uQ29uZmlybWF0aW9uUhBjb25maXJtYXRpb25JbmZvGpsBCgxD'
    'b25maXJtYXRpb24SFgoGaGVpZ2h0GAEgASgNUgZoZWlnaHQSOQoKYmxvY2tfaGFzaBgCIAEoCz'
    'IaLmN1c2YuY29tbW9uLnYxLlJldmVyc2VIZXhSCWJsb2NrSGFzaBI4Cgl0aW1lc3RhbXAYAyAB'
    'KAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgl0aW1lc3RhbXA=');

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
    {'1': 'address', '3': 2, '4': 1, '5': 11, '6': '.google.protobuf.StringValue', '10': 'address'},
    {'1': 'value_sats', '3': 3, '4': 1, '5': 11, '6': '.google.protobuf.UInt64Value', '10': 'valueSats'},
    {'1': 'fee_sats', '3': 4, '4': 1, '5': 11, '6': '.google.protobuf.UInt64Value', '10': 'feeSats'},
  ],
};

/// Descriptor for `CreateDepositTransactionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createDepositTransactionRequestDescriptor = $convert.base64Decode(
    'Ch9DcmVhdGVEZXBvc2l0VHJhbnNhY3Rpb25SZXF1ZXN0Ej8KDHNpZGVjaGFpbl9pZBgBIAEoCz'
    'IcLmdvb2dsZS5wcm90b2J1Zi5VSW50MzJWYWx1ZVILc2lkZWNoYWluSWQSNgoHYWRkcmVzcxgC'
    'IAEoCzIcLmdvb2dsZS5wcm90b2J1Zi5TdHJpbmdWYWx1ZVIHYWRkcmVzcxI7Cgp2YWx1ZV9zYX'
    'RzGAMgASgLMhwuZ29vZ2xlLnByb3RvYnVmLlVJbnQ2NFZhbHVlUgl2YWx1ZVNhdHMSNwoIZmVl'
    'X3NhdHMYBCABKAsyHC5nb29nbGUucHJvdG9idWYuVUludDY0VmFsdWVSB2ZlZVNhdHM=');

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
    {'1': 'has_synced', '3': 3, '4': 1, '5': 8, '10': 'hasSynced'},
  ],
};

/// Descriptor for `GetBalanceResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBalanceResponseDescriptor = $convert.base64Decode(
    'ChJHZXRCYWxhbmNlUmVzcG9uc2USJQoOY29uZmlybWVkX3NhdHMYASABKARSDWNvbmZpcm1lZF'
    'NhdHMSIQoMcGVuZGluZ19zYXRzGAIgASgEUgtwZW5kaW5nU2F0cxIdCgpoYXNfc3luY2VkGAMg'
    'ASgIUgloYXNTeW5jZWQ=');

@$core.Deprecated('Use listSidechainDepositTransactionsRequestDescriptor instead')
const ListSidechainDepositTransactionsRequest$json = {
  '1': 'ListSidechainDepositTransactionsRequest',
};

/// Descriptor for `ListSidechainDepositTransactionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listSidechainDepositTransactionsRequestDescriptor = $convert.base64Decode(
    'CidMaXN0U2lkZWNoYWluRGVwb3NpdFRyYW5zYWN0aW9uc1JlcXVlc3Q=');

@$core.Deprecated('Use listSidechainDepositTransactionsResponseDescriptor instead')
const ListSidechainDepositTransactionsResponse$json = {
  '1': 'ListSidechainDepositTransactionsResponse',
  '2': [
    {'1': 'transactions', '3': 1, '4': 3, '5': 11, '6': '.cusf.mainchain.v1.ListSidechainDepositTransactionsResponse.SidechainDepositTransaction', '10': 'transactions'},
  ],
  '3': [ListSidechainDepositTransactionsResponse_SidechainDepositTransaction$json],
};

@$core.Deprecated('Use listSidechainDepositTransactionsResponseDescriptor instead')
const ListSidechainDepositTransactionsResponse_SidechainDepositTransaction$json = {
  '1': 'SidechainDepositTransaction',
  '2': [
    {'1': 'sidechain_number', '3': 1, '4': 1, '5': 11, '6': '.google.protobuf.UInt32Value', '10': 'sidechainNumber'},
    {'1': 'tx', '3': 2, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.WalletTransaction', '10': 'tx'},
  ],
};

/// Descriptor for `ListSidechainDepositTransactionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listSidechainDepositTransactionsResponseDescriptor = $convert.base64Decode(
    'CihMaXN0U2lkZWNoYWluRGVwb3NpdFRyYW5zYWN0aW9uc1Jlc3BvbnNlEnsKDHRyYW5zYWN0aW'
    '9ucxgBIAMoCzJXLmN1c2YubWFpbmNoYWluLnYxLkxpc3RTaWRlY2hhaW5EZXBvc2l0VHJhbnNh'
    'Y3Rpb25zUmVzcG9uc2UuU2lkZWNoYWluRGVwb3NpdFRyYW5zYWN0aW9uUgx0cmFuc2FjdGlvbn'
    'ManAEKG1NpZGVjaGFpbkRlcG9zaXRUcmFuc2FjdGlvbhJHChBzaWRlY2hhaW5fbnVtYmVyGAEg'
    'ASgLMhwuZ29vZ2xlLnByb3RvYnVmLlVJbnQzMlZhbHVlUg9zaWRlY2hhaW5OdW1iZXISNAoCdH'
    'gYAiABKAsyJC5jdXNmLm1haW5jaGFpbi52MS5XYWxsZXRUcmFuc2FjdGlvblICdHg=');

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
    {'1': 'required_utxos', '3': 4, '4': 3, '5': 11, '6': '.cusf.mainchain.v1.SendTransactionRequest.RequiredUtxo', '10': 'requiredUtxos'},
    {'1': 'drain_wallet_to', '3': 5, '4': 1, '5': 9, '9': 2, '10': 'drainWalletTo', '17': true},
  ],
  '3': [SendTransactionRequest_FeeRate$json, SendTransactionRequest_RequiredUtxo$json, SendTransactionRequest_DestinationsEntry$json],
  '8': [
    {'1': '_fee_rate'},
    {'1': '_op_return_message'},
    {'1': '_drain_wallet_to'},
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
const SendTransactionRequest_RequiredUtxo$json = {
  '1': 'RequiredUtxo',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 11, '6': '.cusf.common.v1.ReverseHex', '10': 'txid'},
    {'1': 'vout', '3': 2, '4': 1, '5': 13, '10': 'vout'},
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
    'YWdlGAMgASgLMhMuY3VzZi5jb21tb24udjEuSGV4SAFSD29wUmV0dXJuTWVzc2FnZYgBARJdCg'
    '5yZXF1aXJlZF91dHhvcxgEIAMoCzI2LmN1c2YubWFpbmNoYWluLnYxLlNlbmRUcmFuc2FjdGlv'
    'blJlcXVlc3QuUmVxdWlyZWRVdHhvUg1yZXF1aXJlZFV0eG9zEisKD2RyYWluX3dhbGxldF90bx'
    'gFIAEoCUgCUg1kcmFpbldhbGxldFRviAEBGkwKB0ZlZVJhdGUSJAoNc2F0X3Blcl92Ynl0ZRgB'
    'IAEoBEgAUgtzYXRQZXJWYnl0ZRIUCgRzYXRzGAIgASgESABSBHNhdHNCBQoDZmVlGlIKDFJlcX'
    'VpcmVkVXR4bxIuCgR0eGlkGAEgASgLMhouY3VzZi5jb21tb24udjEuUmV2ZXJzZUhleFIEdHhp'
    'ZBISCgR2b3V0GAIgASgNUgR2b3V0Gj8KEURlc3RpbmF0aW9uc0VudHJ5EhAKA2tleRgBIAEoCV'
    'IDa2V5EhQKBXZhbHVlGAIgASgEUgV2YWx1ZToCOAFCCwoJX2ZlZV9yYXRlQhQKEl9vcF9yZXR1'
    'cm5fbWVzc2FnZUISChBfZHJhaW5fd2FsbGV0X3Rv');

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

@$core.Deprecated('Use getInfoRequestDescriptor instead')
const GetInfoRequest$json = {
  '1': 'GetInfoRequest',
};

/// Descriptor for `GetInfoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getInfoRequestDescriptor = $convert.base64Decode(
    'Cg5HZXRJbmZvUmVxdWVzdA==');

@$core.Deprecated('Use getInfoResponseDescriptor instead')
const GetInfoResponse$json = {
  '1': 'GetInfoResponse',
  '2': [
    {'1': 'network', '3': 1, '4': 1, '5': 9, '10': 'network'},
    {'1': 'transaction_count', '3': 2, '4': 1, '5': 13, '10': 'transactionCount'},
    {'1': 'unspent_output_count', '3': 3, '4': 1, '5': 13, '10': 'unspentOutputCount'},
    {'1': 'descriptors', '3': 4, '4': 3, '5': 11, '6': '.cusf.mainchain.v1.GetInfoResponse.DescriptorsEntry', '10': 'descriptors'},
    {'1': 'tip', '3': 5, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.GetInfoResponse.Tip', '10': 'tip'},
  ],
  '3': [GetInfoResponse_DescriptorsEntry$json, GetInfoResponse_Tip$json],
};

@$core.Deprecated('Use getInfoResponseDescriptor instead')
const GetInfoResponse_DescriptorsEntry$json = {
  '1': 'DescriptorsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use getInfoResponseDescriptor instead')
const GetInfoResponse_Tip$json = {
  '1': 'Tip',
  '2': [
    {'1': 'height', '3': 1, '4': 1, '5': 13, '10': 'height'},
    {'1': 'hash', '3': 2, '4': 1, '5': 11, '6': '.cusf.common.v1.ReverseHex', '10': 'hash'},
  ],
};

/// Descriptor for `GetInfoResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getInfoResponseDescriptor = $convert.base64Decode(
    'Cg9HZXRJbmZvUmVzcG9uc2USGAoHbmV0d29yaxgBIAEoCVIHbmV0d29yaxIrChF0cmFuc2FjdG'
    'lvbl9jb3VudBgCIAEoDVIQdHJhbnNhY3Rpb25Db3VudBIwChR1bnNwZW50X291dHB1dF9jb3Vu'
    'dBgDIAEoDVISdW5zcGVudE91dHB1dENvdW50ElUKC2Rlc2NyaXB0b3JzGAQgAygLMjMuY3VzZi'
    '5tYWluY2hhaW4udjEuR2V0SW5mb1Jlc3BvbnNlLkRlc2NyaXB0b3JzRW50cnlSC2Rlc2NyaXB0'
    'b3JzEjgKA3RpcBgFIAEoCzImLmN1c2YubWFpbmNoYWluLnYxLkdldEluZm9SZXNwb25zZS5UaX'
    'BSA3RpcBo+ChBEZXNjcmlwdG9yc0VudHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGAIg'
    'ASgJUgV2YWx1ZToCOAEaTQoDVGlwEhYKBmhlaWdodBgBIAEoDVIGaGVpZ2h0Ei4KBGhhc2gYAi'
    'ABKAsyGi5jdXNmLmNvbW1vbi52MS5SZXZlcnNlSGV4UgRoYXNo');

@$core.Deprecated('Use listUnspentOutputsRequestDescriptor instead')
const ListUnspentOutputsRequest$json = {
  '1': 'ListUnspentOutputsRequest',
};

/// Descriptor for `ListUnspentOutputsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listUnspentOutputsRequestDescriptor = $convert.base64Decode(
    'ChlMaXN0VW5zcGVudE91dHB1dHNSZXF1ZXN0');

@$core.Deprecated('Use listUnspentOutputsResponseDescriptor instead')
const ListUnspentOutputsResponse$json = {
  '1': 'ListUnspentOutputsResponse',
  '2': [
    {'1': 'outputs', '3': 1, '4': 3, '5': 11, '6': '.cusf.mainchain.v1.ListUnspentOutputsResponse.Output', '10': 'outputs'},
  ],
  '3': [ListUnspentOutputsResponse_Output$json],
};

@$core.Deprecated('Use listUnspentOutputsResponseDescriptor instead')
const ListUnspentOutputsResponse_Output$json = {
  '1': 'Output',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 11, '6': '.cusf.common.v1.ReverseHex', '10': 'txid'},
    {'1': 'vout', '3': 2, '4': 1, '5': 13, '10': 'vout'},
    {'1': 'value_sats', '3': 3, '4': 1, '5': 4, '10': 'valueSats'},
    {'1': 'is_internal', '3': 4, '4': 1, '5': 8, '10': 'isInternal'},
    {'1': 'is_confirmed', '3': 5, '4': 1, '5': 8, '10': 'isConfirmed'},
    {'1': 'confirmed_at_block', '3': 6, '4': 1, '5': 13, '10': 'confirmedAtBlock'},
    {'1': 'confirmed_at_time', '3': 7, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'confirmedAtTime'},
    {'1': 'confirmed_transitively', '3': 8, '4': 1, '5': 11, '6': '.cusf.common.v1.ReverseHex', '10': 'confirmedTransitively'},
    {'1': 'unconfirmed_last_seen', '3': 9, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'unconfirmedLastSeen'},
    {'1': 'address', '3': 10, '4': 1, '5': 11, '6': '.google.protobuf.StringValue', '10': 'address'},
  ],
};

/// Descriptor for `ListUnspentOutputsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listUnspentOutputsResponseDescriptor = $convert.base64Decode(
    'ChpMaXN0VW5zcGVudE91dHB1dHNSZXNwb25zZRJOCgdvdXRwdXRzGAEgAygLMjQuY3VzZi5tYW'
    'luY2hhaW4udjEuTGlzdFVuc3BlbnRPdXRwdXRzUmVzcG9uc2UuT3V0cHV0UgdvdXRwdXRzGoAE'
    'CgZPdXRwdXQSLgoEdHhpZBgBIAEoCzIaLmN1c2YuY29tbW9uLnYxLlJldmVyc2VIZXhSBHR4aW'
    'QSEgoEdm91dBgCIAEoDVIEdm91dBIdCgp2YWx1ZV9zYXRzGAMgASgEUgl2YWx1ZVNhdHMSHwoL'
    'aXNfaW50ZXJuYWwYBCABKAhSCmlzSW50ZXJuYWwSIQoMaXNfY29uZmlybWVkGAUgASgIUgtpc0'
    'NvbmZpcm1lZBIsChJjb25maXJtZWRfYXRfYmxvY2sYBiABKA1SEGNvbmZpcm1lZEF0QmxvY2sS'
    'RgoRY29uZmlybWVkX2F0X3RpbWUYByABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUg'
    '9jb25maXJtZWRBdFRpbWUSUQoWY29uZmlybWVkX3RyYW5zaXRpdmVseRgIIAEoCzIaLmN1c2Yu'
    'Y29tbW9uLnYxLlJldmVyc2VIZXhSFWNvbmZpcm1lZFRyYW5zaXRpdmVseRJOChV1bmNvbmZpcm'
    '1lZF9sYXN0X3NlZW4YCSABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUhN1bmNvbmZp'
    'cm1lZExhc3RTZWVuEjYKB2FkZHJlc3MYCiABKAsyHC5nb29nbGUucHJvdG9idWYuU3RyaW5nVm'
    'FsdWVSB2FkZHJlc3M=');

const $core.Map<$core.String, $core.dynamic> WalletServiceBase$json = {
  '1': 'WalletService',
  '2': [
    {'1': 'BroadcastWithdrawalBundle', '2': '.cusf.mainchain.v1.BroadcastWithdrawalBundleRequest', '3': '.cusf.mainchain.v1.BroadcastWithdrawalBundleResponse'},
    {'1': 'CreateBmmCriticalDataTransaction', '2': '.cusf.mainchain.v1.CreateBmmCriticalDataTransactionRequest', '3': '.cusf.mainchain.v1.CreateBmmCriticalDataTransactionResponse'},
    {'1': 'CreateDepositTransaction', '2': '.cusf.mainchain.v1.CreateDepositTransactionRequest', '3': '.cusf.mainchain.v1.CreateDepositTransactionResponse'},
    {'1': 'CreateNewAddress', '2': '.cusf.mainchain.v1.CreateNewAddressRequest', '3': '.cusf.mainchain.v1.CreateNewAddressResponse'},
    {'1': 'CreateSidechainProposal', '2': '.cusf.mainchain.v1.CreateSidechainProposalRequest', '3': '.cusf.mainchain.v1.CreateSidechainProposalResponse', '6': true},
    {'1': 'CreateWallet', '2': '.cusf.mainchain.v1.CreateWalletRequest', '3': '.cusf.mainchain.v1.CreateWalletResponse'},
    {'1': 'GetBalance', '2': '.cusf.mainchain.v1.GetBalanceRequest', '3': '.cusf.mainchain.v1.GetBalanceResponse'},
    {'1': 'ListSidechainDepositTransactions', '2': '.cusf.mainchain.v1.ListSidechainDepositTransactionsRequest', '3': '.cusf.mainchain.v1.ListSidechainDepositTransactionsResponse'},
    {'1': 'ListTransactions', '2': '.cusf.mainchain.v1.ListTransactionsRequest', '3': '.cusf.mainchain.v1.ListTransactionsResponse'},
    {'1': 'ListUnspentOutputs', '2': '.cusf.mainchain.v1.ListUnspentOutputsRequest', '3': '.cusf.mainchain.v1.ListUnspentOutputsResponse'},
    {'1': 'GetInfo', '2': '.cusf.mainchain.v1.GetInfoRequest', '3': '.cusf.mainchain.v1.GetInfoResponse'},
    {'1': 'SendTransaction', '2': '.cusf.mainchain.v1.SendTransactionRequest', '3': '.cusf.mainchain.v1.SendTransactionResponse'},
    {'1': 'UnlockWallet', '2': '.cusf.mainchain.v1.UnlockWalletRequest', '3': '.cusf.mainchain.v1.UnlockWalletResponse'},
    {'1': 'GenerateBlocks', '2': '.cusf.mainchain.v1.GenerateBlocksRequest', '3': '.cusf.mainchain.v1.GenerateBlocksResponse', '6': true},
  ],
};

@$core.Deprecated('Use walletServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> WalletServiceBase$messageJson = {
  '.cusf.mainchain.v1.BroadcastWithdrawalBundleRequest': BroadcastWithdrawalBundleRequest$json,
  '.google.protobuf.UInt32Value': $0.UInt32Value$json,
  '.google.protobuf.BytesValue': $0.BytesValue$json,
  '.cusf.mainchain.v1.BroadcastWithdrawalBundleResponse': BroadcastWithdrawalBundleResponse$json,
  '.cusf.mainchain.v1.CreateBmmCriticalDataTransactionRequest': CreateBmmCriticalDataTransactionRequest$json,
  '.google.protobuf.UInt64Value': $0.UInt64Value$json,
  '.cusf.common.v1.ConsensusHex': $1.ConsensusHex$json,
  '.google.protobuf.StringValue': $0.StringValue$json,
  '.cusf.common.v1.ReverseHex': $1.ReverseHex$json,
  '.cusf.mainchain.v1.CreateBmmCriticalDataTransactionResponse': CreateBmmCriticalDataTransactionResponse$json,
  '.cusf.mainchain.v1.CreateDepositTransactionRequest': CreateDepositTransactionRequest$json,
  '.cusf.mainchain.v1.CreateDepositTransactionResponse': CreateDepositTransactionResponse$json,
  '.cusf.mainchain.v1.CreateNewAddressRequest': CreateNewAddressRequest$json,
  '.cusf.mainchain.v1.CreateNewAddressResponse': CreateNewAddressResponse$json,
  '.cusf.mainchain.v1.CreateSidechainProposalRequest': CreateSidechainProposalRequest$json,
  '.cusf.mainchain.v1.SidechainDeclaration': $3.SidechainDeclaration$json,
  '.cusf.mainchain.v1.SidechainDeclaration.V0': $3.SidechainDeclaration_V0$json,
  '.cusf.common.v1.Hex': $1.Hex$json,
  '.cusf.mainchain.v1.CreateSidechainProposalResponse': CreateSidechainProposalResponse$json,
  '.cusf.mainchain.v1.CreateSidechainProposalResponse.Confirmed': CreateSidechainProposalResponse_Confirmed$json,
  '.cusf.mainchain.v1.OutPoint': $3.OutPoint$json,
  '.cusf.mainchain.v1.CreateSidechainProposalResponse.NotConfirmed': CreateSidechainProposalResponse_NotConfirmed$json,
  '.cusf.mainchain.v1.CreateWalletRequest': CreateWalletRequest$json,
  '.cusf.mainchain.v1.CreateWalletResponse': CreateWalletResponse$json,
  '.cusf.mainchain.v1.GetBalanceRequest': GetBalanceRequest$json,
  '.cusf.mainchain.v1.GetBalanceResponse': GetBalanceResponse$json,
  '.cusf.mainchain.v1.ListSidechainDepositTransactionsRequest': ListSidechainDepositTransactionsRequest$json,
  '.cusf.mainchain.v1.ListSidechainDepositTransactionsResponse': ListSidechainDepositTransactionsResponse$json,
  '.cusf.mainchain.v1.ListSidechainDepositTransactionsResponse.SidechainDepositTransaction': ListSidechainDepositTransactionsResponse_SidechainDepositTransaction$json,
  '.cusf.mainchain.v1.WalletTransaction': WalletTransaction$json,
  '.cusf.mainchain.v1.WalletTransaction.Confirmation': WalletTransaction_Confirmation$json,
  '.google.protobuf.Timestamp': $5.Timestamp$json,
  '.cusf.mainchain.v1.ListTransactionsRequest': ListTransactionsRequest$json,
  '.cusf.mainchain.v1.ListTransactionsResponse': ListTransactionsResponse$json,
  '.cusf.mainchain.v1.ListUnspentOutputsRequest': ListUnspentOutputsRequest$json,
  '.cusf.mainchain.v1.ListUnspentOutputsResponse': ListUnspentOutputsResponse$json,
  '.cusf.mainchain.v1.ListUnspentOutputsResponse.Output': ListUnspentOutputsResponse_Output$json,
  '.cusf.mainchain.v1.GetInfoRequest': GetInfoRequest$json,
  '.cusf.mainchain.v1.GetInfoResponse': GetInfoResponse$json,
  '.cusf.mainchain.v1.GetInfoResponse.DescriptorsEntry': GetInfoResponse_DescriptorsEntry$json,
  '.cusf.mainchain.v1.GetInfoResponse.Tip': GetInfoResponse_Tip$json,
  '.cusf.mainchain.v1.SendTransactionRequest': SendTransactionRequest$json,
  '.cusf.mainchain.v1.SendTransactionRequest.DestinationsEntry': SendTransactionRequest_DestinationsEntry$json,
  '.cusf.mainchain.v1.SendTransactionRequest.FeeRate': SendTransactionRequest_FeeRate$json,
  '.cusf.mainchain.v1.SendTransactionRequest.RequiredUtxo': SendTransactionRequest_RequiredUtxo$json,
  '.cusf.mainchain.v1.SendTransactionResponse': SendTransactionResponse$json,
  '.cusf.mainchain.v1.UnlockWalletRequest': UnlockWalletRequest$json,
  '.cusf.mainchain.v1.UnlockWalletResponse': UnlockWalletResponse$json,
  '.cusf.mainchain.v1.GenerateBlocksRequest': GenerateBlocksRequest$json,
  '.cusf.mainchain.v1.GenerateBlocksResponse': GenerateBlocksResponse$json,
};

/// Descriptor for `WalletService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List walletServiceDescriptor = $convert.base64Decode(
    'Cg1XYWxsZXRTZXJ2aWNlEoYBChlCcm9hZGNhc3RXaXRoZHJhd2FsQnVuZGxlEjMuY3VzZi5tYW'
    'luY2hhaW4udjEuQnJvYWRjYXN0V2l0aGRyYXdhbEJ1bmRsZVJlcXVlc3QaNC5jdXNmLm1haW5j'
    'aGFpbi52MS5Ccm9hZGNhc3RXaXRoZHJhd2FsQnVuZGxlUmVzcG9uc2USmwEKIENyZWF0ZUJtbU'
    'NyaXRpY2FsRGF0YVRyYW5zYWN0aW9uEjouY3VzZi5tYWluY2hhaW4udjEuQ3JlYXRlQm1tQ3Jp'
    'dGljYWxEYXRhVHJhbnNhY3Rpb25SZXF1ZXN0GjsuY3VzZi5tYWluY2hhaW4udjEuQ3JlYXRlQm'
    '1tQ3JpdGljYWxEYXRhVHJhbnNhY3Rpb25SZXNwb25zZRKDAQoYQ3JlYXRlRGVwb3NpdFRyYW5z'
    'YWN0aW9uEjIuY3VzZi5tYWluY2hhaW4udjEuQ3JlYXRlRGVwb3NpdFRyYW5zYWN0aW9uUmVxdW'
    'VzdBozLmN1c2YubWFpbmNoYWluLnYxLkNyZWF0ZURlcG9zaXRUcmFuc2FjdGlvblJlc3BvbnNl'
    'EmsKEENyZWF0ZU5ld0FkZHJlc3MSKi5jdXNmLm1haW5jaGFpbi52MS5DcmVhdGVOZXdBZGRyZX'
    'NzUmVxdWVzdBorLmN1c2YubWFpbmNoYWluLnYxLkNyZWF0ZU5ld0FkZHJlc3NSZXNwb25zZRKC'
    'AQoXQ3JlYXRlU2lkZWNoYWluUHJvcG9zYWwSMS5jdXNmLm1haW5jaGFpbi52MS5DcmVhdGVTaW'
    'RlY2hhaW5Qcm9wb3NhbFJlcXVlc3QaMi5jdXNmLm1haW5jaGFpbi52MS5DcmVhdGVTaWRlY2hh'
    'aW5Qcm9wb3NhbFJlc3BvbnNlMAESXwoMQ3JlYXRlV2FsbGV0EiYuY3VzZi5tYWluY2hhaW4udj'
    'EuQ3JlYXRlV2FsbGV0UmVxdWVzdBonLmN1c2YubWFpbmNoYWluLnYxLkNyZWF0ZVdhbGxldFJl'
    'c3BvbnNlElkKCkdldEJhbGFuY2USJC5jdXNmLm1haW5jaGFpbi52MS5HZXRCYWxhbmNlUmVxdW'
    'VzdBolLmN1c2YubWFpbmNoYWluLnYxLkdldEJhbGFuY2VSZXNwb25zZRKbAQogTGlzdFNpZGVj'
    'aGFpbkRlcG9zaXRUcmFuc2FjdGlvbnMSOi5jdXNmLm1haW5jaGFpbi52MS5MaXN0U2lkZWNoYW'
    'luRGVwb3NpdFRyYW5zYWN0aW9uc1JlcXVlc3QaOy5jdXNmLm1haW5jaGFpbi52MS5MaXN0U2lk'
    'ZWNoYWluRGVwb3NpdFRyYW5zYWN0aW9uc1Jlc3BvbnNlEmsKEExpc3RUcmFuc2FjdGlvbnMSKi'
    '5jdXNmLm1haW5jaGFpbi52MS5MaXN0VHJhbnNhY3Rpb25zUmVxdWVzdBorLmN1c2YubWFpbmNo'
    'YWluLnYxLkxpc3RUcmFuc2FjdGlvbnNSZXNwb25zZRJxChJMaXN0VW5zcGVudE91dHB1dHMSLC'
    '5jdXNmLm1haW5jaGFpbi52MS5MaXN0VW5zcGVudE91dHB1dHNSZXF1ZXN0Gi0uY3VzZi5tYWlu'
    'Y2hhaW4udjEuTGlzdFVuc3BlbnRPdXRwdXRzUmVzcG9uc2USUAoHR2V0SW5mbxIhLmN1c2YubW'
    'FpbmNoYWluLnYxLkdldEluZm9SZXF1ZXN0GiIuY3VzZi5tYWluY2hhaW4udjEuR2V0SW5mb1Jl'
    'c3BvbnNlEmgKD1NlbmRUcmFuc2FjdGlvbhIpLmN1c2YubWFpbmNoYWluLnYxLlNlbmRUcmFuc2'
    'FjdGlvblJlcXVlc3QaKi5jdXNmLm1haW5jaGFpbi52MS5TZW5kVHJhbnNhY3Rpb25SZXNwb25z'
    'ZRJfCgxVbmxvY2tXYWxsZXQSJi5jdXNmLm1haW5jaGFpbi52MS5VbmxvY2tXYWxsZXRSZXF1ZX'
    'N0GicuY3VzZi5tYWluY2hhaW4udjEuVW5sb2NrV2FsbGV0UmVzcG9uc2USZwoOR2VuZXJhdGVC'
    'bG9ja3MSKC5jdXNmLm1haW5jaGFpbi52MS5HZW5lcmF0ZUJsb2Nrc1JlcXVlc3QaKS5jdXNmLm'
    '1haW5jaGFpbi52MS5HZW5lcmF0ZUJsb2Nrc1Jlc3BvbnNlMAE=');

