//
//  Generated code. Do not modify.
//  source: bbc/v1/bbc.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

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

@$core.Deprecated('Use getBlockchainInfoRequestDescriptor instead')
const GetBlockchainInfoRequest$json = {
  '1': 'GetBlockchainInfoRequest',
};

/// Descriptor for `GetBlockchainInfoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBlockchainInfoRequestDescriptor = $convert.base64Decode(
    'ChhHZXRCbG9ja2NoYWluSW5mb1JlcXVlc3Q=');

@$core.Deprecated('Use getBlockchainInfoResponseDescriptor instead')
const GetBlockchainInfoResponse$json = {
  '1': 'GetBlockchainInfoResponse',
  '2': [
    {'1': 'chain', '3': 1, '4': 1, '5': 9, '10': 'chain'},
    {'1': 'blocks', '3': 2, '4': 1, '5': 3, '10': 'blocks'},
    {'1': 'headers', '3': 3, '4': 1, '5': 3, '10': 'headers'},
    {'1': 'best_block_hash', '3': 4, '4': 1, '5': 9, '10': 'bestBlockHash'},
    {'1': 'difficulty', '3': 5, '4': 1, '5': 1, '10': 'difficulty'},
    {'1': 'time', '3': 6, '4': 1, '5': 3, '10': 'time'},
    {'1': 'median_time', '3': 7, '4': 1, '5': 3, '10': 'medianTime'},
    {'1': 'verification_progress', '3': 8, '4': 1, '5': 1, '10': 'verificationProgress'},
    {'1': 'initial_block_download', '3': 9, '4': 1, '5': 8, '10': 'initialBlockDownload'},
    {'1': 'chain_work', '3': 10, '4': 1, '5': 9, '10': 'chainWork'},
    {'1': 'size_on_disk', '3': 11, '4': 1, '5': 3, '10': 'sizeOnDisk'},
    {'1': 'pruned', '3': 12, '4': 1, '5': 8, '10': 'pruned'},
    {'1': 'warnings', '3': 13, '4': 3, '5': 9, '10': 'warnings'},
  ],
};

/// Descriptor for `GetBlockchainInfoResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBlockchainInfoResponseDescriptor = $convert.base64Decode(
    'ChlHZXRCbG9ja2NoYWluSW5mb1Jlc3BvbnNlEhQKBWNoYWluGAEgASgJUgVjaGFpbhIWCgZibG'
    '9ja3MYAiABKANSBmJsb2NrcxIYCgdoZWFkZXJzGAMgASgDUgdoZWFkZXJzEiYKD2Jlc3RfYmxv'
    'Y2tfaGFzaBgEIAEoCVINYmVzdEJsb2NrSGFzaBIeCgpkaWZmaWN1bHR5GAUgASgBUgpkaWZmaW'
    'N1bHR5EhIKBHRpbWUYBiABKANSBHRpbWUSHwoLbWVkaWFuX3RpbWUYByABKANSCm1lZGlhblRp'
    'bWUSMwoVdmVyaWZpY2F0aW9uX3Byb2dyZXNzGAggASgBUhR2ZXJpZmljYXRpb25Qcm9ncmVzcx'
    'I0ChZpbml0aWFsX2Jsb2NrX2Rvd25sb2FkGAkgASgIUhRpbml0aWFsQmxvY2tEb3dubG9hZBId'
    'CgpjaGFpbl93b3JrGAogASgJUgljaGFpbldvcmsSIAoMc2l6ZV9vbl9kaXNrGAsgASgDUgpzaX'
    'plT25EaXNrEhYKBnBydW5lZBgMIAEoCFIGcHJ1bmVkEhoKCHdhcm5pbmdzGA0gAygJUgh3YXJu'
    'aW5ncw==');

@$core.Deprecated('Use getSidechainInfoRequestDescriptor instead')
const GetSidechainInfoRequest$json = {
  '1': 'GetSidechainInfoRequest',
};

/// Descriptor for `GetSidechainInfoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSidechainInfoRequestDescriptor = $convert.base64Decode(
    'ChdHZXRTaWRlY2hhaW5JbmZvUmVxdWVzdA==');

@$core.Deprecated('Use getSidechainInfoResponseDescriptor instead')
const GetSidechainInfoResponse$json = {
  '1': 'GetSidechainInfoResponse',
  '2': [
    {'1': 'synced', '3': 1, '4': 1, '5': 8, '10': 'synced'},
    {'1': 'mainchain_tip', '3': 2, '4': 1, '5': 9, '10': 'mainchainTip'},
    {'1': 'last_error', '3': 3, '4': 1, '5': 9, '10': 'lastError'},
  ],
};

/// Descriptor for `GetSidechainInfoResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSidechainInfoResponseDescriptor = $convert.base64Decode(
    'ChhHZXRTaWRlY2hhaW5JbmZvUmVzcG9uc2USFgoGc3luY2VkGAEgASgIUgZzeW5jZWQSIwoNbW'
    'FpbmNoYWluX3RpcBgCIAEoCVIMbWFpbmNoYWluVGlwEh0KCmxhc3RfZXJyb3IYAyABKAlSCWxh'
    'c3RFcnJvcg==');

@$core.Deprecated('Use getMainchainTipRequestDescriptor instead')
const GetMainchainTipRequest$json = {
  '1': 'GetMainchainTipRequest',
};

/// Descriptor for `GetMainchainTipRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMainchainTipRequestDescriptor = $convert.base64Decode(
    'ChZHZXRNYWluY2hhaW5UaXBSZXF1ZXN0');

@$core.Deprecated('Use getMainchainTipResponseDescriptor instead')
const GetMainchainTipResponse$json = {
  '1': 'GetMainchainTipResponse',
  '2': [
    {'1': 'block_hash', '3': 1, '4': 1, '5': 9, '10': 'blockHash'},
  ],
};

/// Descriptor for `GetMainchainTipResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMainchainTipResponseDescriptor = $convert.base64Decode(
    'ChdHZXRNYWluY2hhaW5UaXBSZXNwb25zZRIdCgpibG9ja19oYXNoGAEgASgJUglibG9ja0hhc2'
    'g=');

@$core.Deprecated('Use getBmmCommitmentRequestDescriptor instead')
const GetBmmCommitmentRequest$json = {
  '1': 'GetBmmCommitmentRequest',
  '2': [
    {'1': 'mainchain_block_hash', '3': 1, '4': 1, '5': 9, '10': 'mainchainBlockHash'},
  ],
};

/// Descriptor for `GetBmmCommitmentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBmmCommitmentRequestDescriptor = $convert.base64Decode(
    'ChdHZXRCbW1Db21taXRtZW50UmVxdWVzdBIwChRtYWluY2hhaW5fYmxvY2tfaGFzaBgBIAEoCV'
    'ISbWFpbmNoYWluQmxvY2tIYXNo');

@$core.Deprecated('Use getBmmCommitmentResponseDescriptor instead')
const GetBmmCommitmentResponse$json = {
  '1': 'GetBmmCommitmentResponse',
  '2': [
    {'1': 'commitment', '3': 1, '4': 1, '5': 9, '10': 'commitment'},
  ],
};

/// Descriptor for `GetBmmCommitmentResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBmmCommitmentResponseDescriptor = $convert.base64Decode(
    'ChhHZXRCbW1Db21taXRtZW50UmVzcG9uc2USHgoKY29tbWl0bWVudBgBIAEoCVIKY29tbWl0bW'
    'VudA==');

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

@$core.Deprecated('Use sendRequestDescriptor instead')
const SendRequest$json = {
  '1': 'SendRequest',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'amount_sats', '3': 2, '4': 1, '5': 3, '10': 'amountSats'},
    {'1': 'subtract_fee_from_amount', '3': 3, '4': 1, '5': 8, '10': 'subtractFeeFromAmount'},
  ],
};

/// Descriptor for `SendRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendRequestDescriptor = $convert.base64Decode(
    'CgtTZW5kUmVxdWVzdBIYCgdhZGRyZXNzGAEgASgJUgdhZGRyZXNzEh8KC2Ftb3VudF9zYXRzGA'
    'IgASgDUgphbW91bnRTYXRzEjcKGHN1YnRyYWN0X2ZlZV9mcm9tX2Ftb3VudBgDIAEoCFIVc3Vi'
    'dHJhY3RGZWVGcm9tQW1vdW50');

@$core.Deprecated('Use sendResponseDescriptor instead')
const SendResponse$json = {
  '1': 'SendResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `SendResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendResponseDescriptor = $convert.base64Decode(
    'CgxTZW5kUmVzcG9uc2USEgoEdHhpZBgBIAEoCVIEdHhpZA==');

@$core.Deprecated('Use estimateFeeRequestDescriptor instead')
const EstimateFeeRequest$json = {
  '1': 'EstimateFeeRequest',
};

/// Descriptor for `EstimateFeeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List estimateFeeRequestDescriptor = $convert.base64Decode(
    'ChJFc3RpbWF0ZUZlZVJlcXVlc3Q=');

@$core.Deprecated('Use estimateFeeResponseDescriptor instead')
const EstimateFeeResponse$json = {
  '1': 'EstimateFeeResponse',
  '2': [
    {'1': 'sats_per_kvb', '3': 1, '4': 1, '5': 3, '10': 'satsPerKvb'},
  ],
};

/// Descriptor for `EstimateFeeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List estimateFeeResponseDescriptor = $convert.base64Decode(
    'ChNFc3RpbWF0ZUZlZVJlc3BvbnNlEiAKDHNhdHNfcGVyX2t2YhgBIAEoA1IKc2F0c1Blckt2Yg'
    '==');

@$core.Deprecated('Use listUtxosRequestDescriptor instead')
const ListUtxosRequest$json = {
  '1': 'ListUtxosRequest',
};

/// Descriptor for `ListUtxosRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listUtxosRequestDescriptor = $convert.base64Decode(
    'ChBMaXN0VXR4b3NSZXF1ZXN0');

@$core.Deprecated('Use utxoDescriptor instead')
const Utxo$json = {
  '1': 'Utxo',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'vout', '3': 2, '4': 1, '5': 3, '10': 'vout'},
    {'1': 'address', '3': 3, '4': 1, '5': 9, '10': 'address'},
    {'1': 'value_sats', '3': 4, '4': 1, '5': 3, '10': 'valueSats'},
    {'1': 'confirmations', '3': 5, '4': 1, '5': 3, '10': 'confirmations'},
  ],
};

/// Descriptor for `Utxo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List utxoDescriptor = $convert.base64Decode(
    'CgRVdHhvEhIKBHR4aWQYASABKAlSBHR4aWQSEgoEdm91dBgCIAEoA1IEdm91dBIYCgdhZGRyZX'
    'NzGAMgASgJUgdhZGRyZXNzEh0KCnZhbHVlX3NhdHMYBCABKANSCXZhbHVlU2F0cxIkCg1jb25m'
    'aXJtYXRpb25zGAUgASgDUg1jb25maXJtYXRpb25z');

@$core.Deprecated('Use listUtxosResponseDescriptor instead')
const ListUtxosResponse$json = {
  '1': 'ListUtxosResponse',
  '2': [
    {'1': 'utxos', '3': 1, '4': 3, '5': 11, '6': '.bbc.v1.Utxo', '10': 'utxos'},
  ],
};

/// Descriptor for `ListUtxosResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listUtxosResponseDescriptor = $convert.base64Decode(
    'ChFMaXN0VXR4b3NSZXNwb25zZRIiCgV1dHhvcxgBIAMoCzIMLmJiYy52MS5VdHhvUgV1dHhvcw'
    '==');

@$core.Deprecated('Use listTransactionsRequestDescriptor instead')
const ListTransactionsRequest$json = {
  '1': 'ListTransactionsRequest',
  '2': [
    {'1': 'count', '3': 1, '4': 1, '5': 3, '10': 'count'},
  ],
};

/// Descriptor for `ListTransactionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listTransactionsRequestDescriptor = $convert.base64Decode(
    'ChdMaXN0VHJhbnNhY3Rpb25zUmVxdWVzdBIUCgVjb3VudBgBIAEoA1IFY291bnQ=');

@$core.Deprecated('Use transactionDescriptor instead')
const Transaction$json = {
  '1': 'Transaction',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'amount_sats', '3': 2, '4': 1, '5': 3, '10': 'amountSats'},
    {'1': 'confirmations', '3': 3, '4': 1, '5': 3, '10': 'confirmations'},
    {'1': 'time', '3': 4, '4': 1, '5': 3, '10': 'time'},
    {'1': 'address', '3': 5, '4': 1, '5': 9, '10': 'address'},
    {'1': 'category', '3': 6, '4': 1, '5': 9, '10': 'category'},
  ],
};

/// Descriptor for `Transaction`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transactionDescriptor = $convert.base64Decode(
    'CgtUcmFuc2FjdGlvbhISCgR0eGlkGAEgASgJUgR0eGlkEh8KC2Ftb3VudF9zYXRzGAIgASgDUg'
    'phbW91bnRTYXRzEiQKDWNvbmZpcm1hdGlvbnMYAyABKANSDWNvbmZpcm1hdGlvbnMSEgoEdGlt'
    'ZRgEIAEoA1IEdGltZRIYCgdhZGRyZXNzGAUgASgJUgdhZGRyZXNzEhoKCGNhdGVnb3J5GAYgAS'
    'gJUghjYXRlZ29yeQ==');

@$core.Deprecated('Use listTransactionsResponseDescriptor instead')
const ListTransactionsResponse$json = {
  '1': 'ListTransactionsResponse',
  '2': [
    {'1': 'transactions', '3': 1, '4': 3, '5': 11, '6': '.bbc.v1.Transaction', '10': 'transactions'},
  ],
};

/// Descriptor for `ListTransactionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listTransactionsResponseDescriptor = $convert.base64Decode(
    'ChhMaXN0VHJhbnNhY3Rpb25zUmVzcG9uc2USNwoMdHJhbnNhY3Rpb25zGAEgAygLMhMuYmJjLn'
    'YxLlRyYW5zYWN0aW9uUgx0cmFuc2FjdGlvbnM=');

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

const $core.Map<$core.String, $core.dynamic> BbcServiceBase$json = {
  '1': 'BbcService',
  '2': [
    {'1': 'GetBlockCount', '2': '.bbc.v1.GetBlockCountRequest', '3': '.bbc.v1.GetBlockCountResponse'},
    {'1': 'GetBlockchainInfo', '2': '.bbc.v1.GetBlockchainInfoRequest', '3': '.bbc.v1.GetBlockchainInfoResponse'},
    {'1': 'GetSidechainInfo', '2': '.bbc.v1.GetSidechainInfoRequest', '3': '.bbc.v1.GetSidechainInfoResponse'},
    {'1': 'GetMainchainTip', '2': '.bbc.v1.GetMainchainTipRequest', '3': '.bbc.v1.GetMainchainTipResponse'},
    {'1': 'GetBmmCommitment', '2': '.bbc.v1.GetBmmCommitmentRequest', '3': '.bbc.v1.GetBmmCommitmentResponse'},
    {'1': 'GetNewAddress', '2': '.bbc.v1.GetNewAddressRequest', '3': '.bbc.v1.GetNewAddressResponse'},
    {'1': 'Send', '2': '.bbc.v1.SendRequest', '3': '.bbc.v1.SendResponse'},
    {'1': 'EstimateFee', '2': '.bbc.v1.EstimateFeeRequest', '3': '.bbc.v1.EstimateFeeResponse'},
    {'1': 'ListUtxos', '2': '.bbc.v1.ListUtxosRequest', '3': '.bbc.v1.ListUtxosResponse'},
    {'1': 'ListTransactions', '2': '.bbc.v1.ListTransactionsRequest', '3': '.bbc.v1.ListTransactionsResponse'},
    {'1': 'Stop', '2': '.bbc.v1.StopRequest', '3': '.bbc.v1.StopResponse'},
  ],
};

@$core.Deprecated('Use bbcServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> BbcServiceBase$messageJson = {
  '.bbc.v1.GetBlockCountRequest': GetBlockCountRequest$json,
  '.bbc.v1.GetBlockCountResponse': GetBlockCountResponse$json,
  '.bbc.v1.GetBlockchainInfoRequest': GetBlockchainInfoRequest$json,
  '.bbc.v1.GetBlockchainInfoResponse': GetBlockchainInfoResponse$json,
  '.bbc.v1.GetSidechainInfoRequest': GetSidechainInfoRequest$json,
  '.bbc.v1.GetSidechainInfoResponse': GetSidechainInfoResponse$json,
  '.bbc.v1.GetMainchainTipRequest': GetMainchainTipRequest$json,
  '.bbc.v1.GetMainchainTipResponse': GetMainchainTipResponse$json,
  '.bbc.v1.GetBmmCommitmentRequest': GetBmmCommitmentRequest$json,
  '.bbc.v1.GetBmmCommitmentResponse': GetBmmCommitmentResponse$json,
  '.bbc.v1.GetNewAddressRequest': GetNewAddressRequest$json,
  '.bbc.v1.GetNewAddressResponse': GetNewAddressResponse$json,
  '.bbc.v1.SendRequest': SendRequest$json,
  '.bbc.v1.SendResponse': SendResponse$json,
  '.bbc.v1.EstimateFeeRequest': EstimateFeeRequest$json,
  '.bbc.v1.EstimateFeeResponse': EstimateFeeResponse$json,
  '.bbc.v1.ListUtxosRequest': ListUtxosRequest$json,
  '.bbc.v1.ListUtxosResponse': ListUtxosResponse$json,
  '.bbc.v1.Utxo': Utxo$json,
  '.bbc.v1.ListTransactionsRequest': ListTransactionsRequest$json,
  '.bbc.v1.ListTransactionsResponse': ListTransactionsResponse$json,
  '.bbc.v1.Transaction': Transaction$json,
  '.bbc.v1.StopRequest': StopRequest$json,
  '.bbc.v1.StopResponse': StopResponse$json,
};

/// Descriptor for `BbcService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List bbcServiceDescriptor = $convert.base64Decode(
    'CgpCYmNTZXJ2aWNlEkwKDUdldEJsb2NrQ291bnQSHC5iYmMudjEuR2V0QmxvY2tDb3VudFJlcX'
    'Vlc3QaHS5iYmMudjEuR2V0QmxvY2tDb3VudFJlc3BvbnNlElgKEUdldEJsb2NrY2hhaW5JbmZv'
    'EiAuYmJjLnYxLkdldEJsb2NrY2hhaW5JbmZvUmVxdWVzdBohLmJiYy52MS5HZXRCbG9ja2NoYW'
    'luSW5mb1Jlc3BvbnNlElUKEEdldFNpZGVjaGFpbkluZm8SHy5iYmMudjEuR2V0U2lkZWNoYWlu'
    'SW5mb1JlcXVlc3QaIC5iYmMudjEuR2V0U2lkZWNoYWluSW5mb1Jlc3BvbnNlElIKD0dldE1haW'
    '5jaGFpblRpcBIeLmJiYy52MS5HZXRNYWluY2hhaW5UaXBSZXF1ZXN0Gh8uYmJjLnYxLkdldE1h'
    'aW5jaGFpblRpcFJlc3BvbnNlElUKEEdldEJtbUNvbW1pdG1lbnQSHy5iYmMudjEuR2V0Qm1tQ2'
    '9tbWl0bWVudFJlcXVlc3QaIC5iYmMudjEuR2V0Qm1tQ29tbWl0bWVudFJlc3BvbnNlEkwKDUdl'
    'dE5ld0FkZHJlc3MSHC5iYmMudjEuR2V0TmV3QWRkcmVzc1JlcXVlc3QaHS5iYmMudjEuR2V0Tm'
    'V3QWRkcmVzc1Jlc3BvbnNlEjEKBFNlbmQSEy5iYmMudjEuU2VuZFJlcXVlc3QaFC5iYmMudjEu'
    'U2VuZFJlc3BvbnNlEkYKC0VzdGltYXRlRmVlEhouYmJjLnYxLkVzdGltYXRlRmVlUmVxdWVzdB'
    'obLmJiYy52MS5Fc3RpbWF0ZUZlZVJlc3BvbnNlEkAKCUxpc3RVdHhvcxIYLmJiYy52MS5MaXN0'
    'VXR4b3NSZXF1ZXN0GhkuYmJjLnYxLkxpc3RVdHhvc1Jlc3BvbnNlElUKEExpc3RUcmFuc2FjdG'
    'lvbnMSHy5iYmMudjEuTGlzdFRyYW5zYWN0aW9uc1JlcXVlc3QaIC5iYmMudjEuTGlzdFRyYW5z'
    'YWN0aW9uc1Jlc3BvbnNlEjEKBFN0b3ASEy5iYmMudjEuU3RvcFJlcXVlc3QaFC5iYmMudjEuU3'
    'RvcFJlc3BvbnNl');

