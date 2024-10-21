//
//  Generated code. Do not modify.
//  source: cusf/mainchain/v1/validator.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use networkDescriptor instead')
const Network$json = {
  '1': 'Network',
  '2': [
    {'1': 'NETWORK_UNSPECIFIED', '2': 0},
    {'1': 'NETWORK_UNKNOWN', '2': 1},
    {'1': 'NETWORK_MAINNET', '2': 2},
    {'1': 'NETWORK_REGTEST', '2': 3},
    {'1': 'NETWORK_SIGNET', '2': 4},
    {'1': 'NETWORK_TESTNET', '2': 5},
  ],
};

/// Descriptor for `Network`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List networkDescriptor = $convert.base64Decode(
    'CgdOZXR3b3JrEhcKE05FVFdPUktfVU5TUEVDSUZJRUQQABITCg9ORVRXT1JLX1VOS05PV04QAR'
    'ITCg9ORVRXT1JLX01BSU5ORVQQAhITCg9ORVRXT1JLX1JFR1RFU1QQAxISCg5ORVRXT1JLX1NJ'
    'R05FVBAEEhMKD05FVFdPUktfVEVTVE5FVBAF');

@$core.Deprecated('Use withdrawalBundleEventTypeDescriptor instead')
const WithdrawalBundleEventType$json = {
  '1': 'WithdrawalBundleEventType',
  '2': [
    {'1': 'WITHDRAWAL_BUNDLE_EVENT_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'WITHDRAWAL_BUNDLE_EVENT_TYPE_SUBMITTED', '2': 1},
    {'1': 'WITHDRAWAL_BUNDLE_EVENT_TYPE_FAILED', '2': 2},
    {'1': 'WITHDRAWAL_BUNDLE_EVENT_TYPE_SUCCEDED', '2': 3},
  ],
};

/// Descriptor for `WithdrawalBundleEventType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List withdrawalBundleEventTypeDescriptor = $convert.base64Decode(
    'ChlXaXRoZHJhd2FsQnVuZGxlRXZlbnRUeXBlEiwKKFdJVEhEUkFXQUxfQlVORExFX0VWRU5UX1'
    'RZUEVfVU5TUEVDSUZJRUQQABIqCiZXSVRIRFJBV0FMX0JVTkRMRV9FVkVOVF9UWVBFX1NVQk1J'
    'VFRFRBABEicKI1dJVEhEUkFXQUxfQlVORExFX0VWRU5UX1RZUEVfRkFJTEVEEAISKQolV0lUSE'
    'RSQVdBTF9CVU5ETEVfRVZFTlRfVFlQRV9TVUNDRURFRBAD');

@$core.Deprecated('Use blockHeaderInfoDescriptor instead')
const BlockHeaderInfo$json = {
  '1': 'BlockHeaderInfo',
  '2': [
    {'1': 'block_hash', '3': 1, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.ReverseHex', '10': 'blockHash'},
    {'1': 'prev_block_hash', '3': 2, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.ReverseHex', '10': 'prevBlockHash'},
    {'1': 'height', '3': 3, '4': 1, '5': 13, '10': 'height'},
    {'1': 'work', '3': 4, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.ConsensusHex', '10': 'work'},
  ],
};

/// Descriptor for `BlockHeaderInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List blockHeaderInfoDescriptor = $convert.base64Decode(
    'Cg9CbG9ja0hlYWRlckluZm8SPAoKYmxvY2tfaGFzaBgBIAEoCzIdLmN1c2YubWFpbmNoYWluLn'
    'YxLlJldmVyc2VIZXhSCWJsb2NrSGFzaBJFCg9wcmV2X2Jsb2NrX2hhc2gYAiABKAsyHS5jdXNm'
    'Lm1haW5jaGFpbi52MS5SZXZlcnNlSGV4Ug1wcmV2QmxvY2tIYXNoEhYKBmhlaWdodBgDIAEoDV'
    'IGaGVpZ2h0EjMKBHdvcmsYBCABKAsyHy5jdXNmLm1haW5jaGFpbi52MS5Db25zZW5zdXNIZXhS'
    'BHdvcms=');

@$core.Deprecated('Use outPointDescriptor instead')
const OutPoint$json = {
  '1': 'OutPoint',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.ConsensusHex', '10': 'txid'},
    {'1': 'vout', '3': 2, '4': 1, '5': 13, '10': 'vout'},
  ],
};

/// Descriptor for `OutPoint`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List outPointDescriptor = $convert.base64Decode(
    'CghPdXRQb2ludBIzCgR0eGlkGAEgASgLMh8uY3VzZi5tYWluY2hhaW4udjEuQ29uc2Vuc3VzSG'
    'V4UgR0eGlkEhIKBHZvdXQYAiABKA1SBHZvdXQ=');

@$core.Deprecated('Use outputDescriptor instead')
const Output$json = {
  '1': 'Output',
  '2': [
    {'1': 'address', '3': 2, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.ConsensusHex', '10': 'address'},
    {'1': 'value_sats', '3': 3, '4': 1, '5': 4, '10': 'valueSats'},
  ],
};

/// Descriptor for `Output`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List outputDescriptor = $convert.base64Decode(
    'CgZPdXRwdXQSOQoHYWRkcmVzcxgCIAEoCzIfLmN1c2YubWFpbmNoYWluLnYxLkNvbnNlbnN1c0'
    'hleFIHYWRkcmVzcxIdCgp2YWx1ZV9zYXRzGAMgASgEUgl2YWx1ZVNhdHM=');

@$core.Deprecated('Use depositDescriptor instead')
const Deposit$json = {
  '1': 'Deposit',
  '2': [
    {'1': 'sequence_number', '3': 1, '4': 1, '5': 4, '10': 'sequenceNumber'},
    {'1': 'outpoint', '3': 2, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.OutPoint', '10': 'outpoint'},
    {'1': 'output', '3': 3, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.Output', '10': 'output'},
  ],
};

/// Descriptor for `Deposit`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List depositDescriptor = $convert.base64Decode(
    'CgdEZXBvc2l0EicKD3NlcXVlbmNlX251bWJlchgBIAEoBFIOc2VxdWVuY2VOdW1iZXISNwoIb3'
    'V0cG9pbnQYAiABKAsyGy5jdXNmLm1haW5jaGFpbi52MS5PdXRQb2ludFIIb3V0cG9pbnQSMQoG'
    'b3V0cHV0GAMgASgLMhkuY3VzZi5tYWluY2hhaW4udjEuT3V0cHV0UgZvdXRwdXQ=');

@$core.Deprecated('Use withdrawalBundleEventDescriptor instead')
const WithdrawalBundleEvent$json = {
  '1': 'WithdrawalBundleEvent',
  '2': [
    {'1': 'm6id', '3': 1, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.ConsensusHex', '10': 'm6id'},
    {'1': 'withdrawal_bundle_event_type', '3': 2, '4': 1, '5': 14, '6': '.cusf.mainchain.v1.WithdrawalBundleEventType', '10': 'withdrawalBundleEventType'},
  ],
};

/// Descriptor for `WithdrawalBundleEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List withdrawalBundleEventDescriptor = $convert.base64Decode(
    'ChVXaXRoZHJhd2FsQnVuZGxlRXZlbnQSMwoEbTZpZBgBIAEoCzIfLmN1c2YubWFpbmNoYWluLn'
    'YxLkNvbnNlbnN1c0hleFIEbTZpZBJtChx3aXRoZHJhd2FsX2J1bmRsZV9ldmVudF90eXBlGAIg'
    'ASgOMiwuY3VzZi5tYWluY2hhaW4udjEuV2l0aGRyYXdhbEJ1bmRsZUV2ZW50VHlwZVIZd2l0aG'
    'RyYXdhbEJ1bmRsZUV2ZW50VHlwZQ==');

@$core.Deprecated('Use blockInfoDescriptor instead')
const BlockInfo$json = {
  '1': 'BlockInfo',
  '2': [
    {'1': 'deposits', '3': 1, '4': 3, '5': 11, '6': '.cusf.mainchain.v1.Deposit', '10': 'deposits'},
    {'1': 'withdrawal_bundle_events', '3': 2, '4': 3, '5': 11, '6': '.cusf.mainchain.v1.WithdrawalBundleEvent', '10': 'withdrawalBundleEvents'},
    {'1': 'bmm_commitment', '3': 3, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.ConsensusHex', '9': 0, '10': 'bmmCommitment', '17': true},
  ],
  '8': [
    {'1': '_bmm_commitment'},
  ],
};

/// Descriptor for `BlockInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List blockInfoDescriptor = $convert.base64Decode(
    'CglCbG9ja0luZm8SNgoIZGVwb3NpdHMYASADKAsyGi5jdXNmLm1haW5jaGFpbi52MS5EZXBvc2'
    'l0UghkZXBvc2l0cxJiChh3aXRoZHJhd2FsX2J1bmRsZV9ldmVudHMYAiADKAsyKC5jdXNmLm1h'
    'aW5jaGFpbi52MS5XaXRoZHJhd2FsQnVuZGxlRXZlbnRSFndpdGhkcmF3YWxCdW5kbGVFdmVudH'
    'MSSwoOYm1tX2NvbW1pdG1lbnQYAyABKAsyHy5jdXNmLm1haW5jaGFpbi52MS5Db25zZW5zdXNI'
    'ZXhIAFINYm1tQ29tbWl0bWVudIgBAUIRCg9fYm1tX2NvbW1pdG1lbnQ=');

@$core.Deprecated('Use getBlockHeaderInfoRequestDescriptor instead')
const GetBlockHeaderInfoRequest$json = {
  '1': 'GetBlockHeaderInfoRequest',
  '2': [
    {'1': 'block_hash', '3': 1, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.ReverseHex', '10': 'blockHash'},
  ],
};

/// Descriptor for `GetBlockHeaderInfoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBlockHeaderInfoRequestDescriptor = $convert.base64Decode(
    'ChlHZXRCbG9ja0hlYWRlckluZm9SZXF1ZXN0EjwKCmJsb2NrX2hhc2gYASABKAsyHS5jdXNmLm'
    '1haW5jaGFpbi52MS5SZXZlcnNlSGV4UglibG9ja0hhc2g=');

@$core.Deprecated('Use getBlockHeaderInfoResponseDescriptor instead')
const GetBlockHeaderInfoResponse$json = {
  '1': 'GetBlockHeaderInfoResponse',
  '2': [
    {'1': 'header_info', '3': 1, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.BlockHeaderInfo', '10': 'headerInfo'},
  ],
};

/// Descriptor for `GetBlockHeaderInfoResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBlockHeaderInfoResponseDescriptor = $convert.base64Decode(
    'ChpHZXRCbG9ja0hlYWRlckluZm9SZXNwb25zZRJDCgtoZWFkZXJfaW5mbxgBIAEoCzIiLmN1c2'
    'YubWFpbmNoYWluLnYxLkJsb2NrSGVhZGVySW5mb1IKaGVhZGVySW5mbw==');

@$core.Deprecated('Use getBlockInfoRequestDescriptor instead')
const GetBlockInfoRequest$json = {
  '1': 'GetBlockInfoRequest',
  '2': [
    {'1': 'block_hash', '3': 1, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.ReverseHex', '10': 'blockHash'},
    {'1': 'sidechain_id', '3': 2, '4': 1, '5': 11, '6': '.google.protobuf.UInt32Value', '10': 'sidechainId'},
  ],
};

/// Descriptor for `GetBlockInfoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBlockInfoRequestDescriptor = $convert.base64Decode(
    'ChNHZXRCbG9ja0luZm9SZXF1ZXN0EjwKCmJsb2NrX2hhc2gYASABKAsyHS5jdXNmLm1haW5jaG'
    'Fpbi52MS5SZXZlcnNlSGV4UglibG9ja0hhc2gSPwoMc2lkZWNoYWluX2lkGAIgASgLMhwuZ29v'
    'Z2xlLnByb3RvYnVmLlVJbnQzMlZhbHVlUgtzaWRlY2hhaW5JZA==');

@$core.Deprecated('Use getBlockInfoResponseDescriptor instead')
const GetBlockInfoResponse$json = {
  '1': 'GetBlockInfoResponse',
  '2': [
    {'1': 'header_info', '3': 1, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.BlockHeaderInfo', '10': 'headerInfo'},
    {'1': 'block_info', '3': 2, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.BlockInfo', '10': 'blockInfo'},
  ],
};

/// Descriptor for `GetBlockInfoResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBlockInfoResponseDescriptor = $convert.base64Decode(
    'ChRHZXRCbG9ja0luZm9SZXNwb25zZRJDCgtoZWFkZXJfaW5mbxgBIAEoCzIiLmN1c2YubWFpbm'
    'NoYWluLnYxLkJsb2NrSGVhZGVySW5mb1IKaGVhZGVySW5mbxI7CgpibG9ja19pbmZvGAIgASgL'
    'MhwuY3VzZi5tYWluY2hhaW4udjEuQmxvY2tJbmZvUglibG9ja0luZm8=');

@$core.Deprecated('Use getBmmHStarCommitmentRequestDescriptor instead')
const GetBmmHStarCommitmentRequest$json = {
  '1': 'GetBmmHStarCommitmentRequest',
  '2': [
    {'1': 'block_hash', '3': 1, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.ReverseHex', '10': 'blockHash'},
    {'1': 'sidechain_id', '3': 2, '4': 1, '5': 11, '6': '.google.protobuf.UInt32Value', '10': 'sidechainId'},
  ],
};

/// Descriptor for `GetBmmHStarCommitmentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBmmHStarCommitmentRequestDescriptor = $convert.base64Decode(
    'ChxHZXRCbW1IU3RhckNvbW1pdG1lbnRSZXF1ZXN0EjwKCmJsb2NrX2hhc2gYASABKAsyHS5jdX'
    'NmLm1haW5jaGFpbi52MS5SZXZlcnNlSGV4UglibG9ja0hhc2gSPwoMc2lkZWNoYWluX2lkGAIg'
    'ASgLMhwuZ29vZ2xlLnByb3RvYnVmLlVJbnQzMlZhbHVlUgtzaWRlY2hhaW5JZA==');

@$core.Deprecated('Use getBmmHStarCommitmentResponseDescriptor instead')
const GetBmmHStarCommitmentResponse$json = {
  '1': 'GetBmmHStarCommitmentResponse',
  '2': [
    {'1': 'block_not_found', '3': 1, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.GetBmmHStarCommitmentResponse.BlockNotFoundError', '9': 0, '10': 'blockNotFound'},
    {'1': 'commitment', '3': 2, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.GetBmmHStarCommitmentResponse.Commitment', '9': 0, '10': 'commitment'},
  ],
  '3': [GetBmmHStarCommitmentResponse_BlockNotFoundError$json, GetBmmHStarCommitmentResponse_Commitment$json],
  '8': [
    {'1': 'result'},
  ],
};

@$core.Deprecated('Use getBmmHStarCommitmentResponseDescriptor instead')
const GetBmmHStarCommitmentResponse_BlockNotFoundError$json = {
  '1': 'BlockNotFoundError',
  '2': [
    {'1': 'block_hash', '3': 1, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.ReverseHex', '10': 'blockHash'},
  ],
};

@$core.Deprecated('Use getBmmHStarCommitmentResponseDescriptor instead')
const GetBmmHStarCommitmentResponse_Commitment$json = {
  '1': 'Commitment',
  '2': [
    {'1': 'commitment', '3': 1, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.ConsensusHex', '9': 0, '10': 'commitment', '17': true},
  ],
  '8': [
    {'1': '_commitment'},
  ],
};

/// Descriptor for `GetBmmHStarCommitmentResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBmmHStarCommitmentResponseDescriptor = $convert.base64Decode(
    'Ch1HZXRCbW1IU3RhckNvbW1pdG1lbnRSZXNwb25zZRJtCg9ibG9ja19ub3RfZm91bmQYASABKA'
    'syQy5jdXNmLm1haW5jaGFpbi52MS5HZXRCbW1IU3RhckNvbW1pdG1lbnRSZXNwb25zZS5CbG9j'
    'a05vdEZvdW5kRXJyb3JIAFINYmxvY2tOb3RGb3VuZBJdCgpjb21taXRtZW50GAIgASgLMjsuY3'
    'VzZi5tYWluY2hhaW4udjEuR2V0Qm1tSFN0YXJDb21taXRtZW50UmVzcG9uc2UuQ29tbWl0bWVu'
    'dEgAUgpjb21taXRtZW50GlIKEkJsb2NrTm90Rm91bmRFcnJvchI8CgpibG9ja19oYXNoGAEgAS'
    'gLMh0uY3VzZi5tYWluY2hhaW4udjEuUmV2ZXJzZUhleFIJYmxvY2tIYXNoGmEKCkNvbW1pdG1l'
    'bnQSRAoKY29tbWl0bWVudBgBIAEoCzIfLmN1c2YubWFpbmNoYWluLnYxLkNvbnNlbnN1c0hleE'
    'gAUgpjb21taXRtZW50iAEBQg0KC19jb21taXRtZW50QggKBnJlc3VsdA==');

@$core.Deprecated('Use getChainInfoRequestDescriptor instead')
const GetChainInfoRequest$json = {
  '1': 'GetChainInfoRequest',
};

/// Descriptor for `GetChainInfoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getChainInfoRequestDescriptor = $convert.base64Decode(
    'ChNHZXRDaGFpbkluZm9SZXF1ZXN0');

@$core.Deprecated('Use getChainInfoResponseDescriptor instead')
const GetChainInfoResponse$json = {
  '1': 'GetChainInfoResponse',
  '2': [
    {'1': 'network', '3': 1, '4': 1, '5': 14, '6': '.cusf.mainchain.v1.Network', '10': 'network'},
  ],
};

/// Descriptor for `GetChainInfoResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getChainInfoResponseDescriptor = $convert.base64Decode(
    'ChRHZXRDaGFpbkluZm9SZXNwb25zZRI0CgduZXR3b3JrGAEgASgOMhouY3VzZi5tYWluY2hhaW'
    '4udjEuTmV0d29ya1IHbmV0d29yaw==');

@$core.Deprecated('Use getChainTipRequestDescriptor instead')
const GetChainTipRequest$json = {
  '1': 'GetChainTipRequest',
};

/// Descriptor for `GetChainTipRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getChainTipRequestDescriptor = $convert.base64Decode(
    'ChJHZXRDaGFpblRpcFJlcXVlc3Q=');

@$core.Deprecated('Use getChainTipResponseDescriptor instead')
const GetChainTipResponse$json = {
  '1': 'GetChainTipResponse',
  '2': [
    {'1': 'block_header_info', '3': 1, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.BlockHeaderInfo', '10': 'blockHeaderInfo'},
  ],
};

/// Descriptor for `GetChainTipResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getChainTipResponseDescriptor = $convert.base64Decode(
    'ChNHZXRDaGFpblRpcFJlc3BvbnNlEk4KEWJsb2NrX2hlYWRlcl9pbmZvGAEgASgLMiIuY3VzZi'
    '5tYWluY2hhaW4udjEuQmxvY2tIZWFkZXJJbmZvUg9ibG9ja0hlYWRlckluZm8=');

@$core.Deprecated('Use getCoinbasePSBTRequestDescriptor instead')
const GetCoinbasePSBTRequest$json = {
  '1': 'GetCoinbasePSBTRequest',
  '2': [
    {'1': 'propose_sidechains', '3': 1, '4': 3, '5': 11, '6': '.cusf.mainchain.v1.GetCoinbasePSBTRequest.ProposeSidechain', '10': 'proposeSidechains'},
    {'1': 'ack_sidechains', '3': 2, '4': 3, '5': 11, '6': '.cusf.mainchain.v1.GetCoinbasePSBTRequest.AckSidechain', '10': 'ackSidechains'},
    {'1': 'propose_bundles', '3': 3, '4': 3, '5': 11, '6': '.cusf.mainchain.v1.GetCoinbasePSBTRequest.ProposeBundle', '10': 'proposeBundles'},
    {'1': 'ack_bundles', '3': 4, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.GetCoinbasePSBTRequest.AckBundles', '10': 'ackBundles'},
  ],
  '3': [GetCoinbasePSBTRequest_ProposeSidechain$json, GetCoinbasePSBTRequest_AckSidechain$json, GetCoinbasePSBTRequest_ProposeBundle$json, GetCoinbasePSBTRequest_AckBundles$json],
};

@$core.Deprecated('Use getCoinbasePSBTRequestDescriptor instead')
const GetCoinbasePSBTRequest_ProposeSidechain$json = {
  '1': 'ProposeSidechain',
  '2': [
    {'1': 'sidechain_number', '3': 1, '4': 1, '5': 11, '6': '.google.protobuf.UInt32Value', '10': 'sidechainNumber'},
    {'1': 'data', '3': 2, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.ConsensusHex', '10': 'data'},
  ],
};

@$core.Deprecated('Use getCoinbasePSBTRequestDescriptor instead')
const GetCoinbasePSBTRequest_AckSidechain$json = {
  '1': 'AckSidechain',
  '2': [
    {'1': 'sidechain_number', '3': 1, '4': 1, '5': 11, '6': '.google.protobuf.UInt32Value', '10': 'sidechainNumber'},
    {'1': 'data_hash', '3': 2, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.ConsensusHex', '10': 'dataHash'},
  ],
};

@$core.Deprecated('Use getCoinbasePSBTRequestDescriptor instead')
const GetCoinbasePSBTRequest_ProposeBundle$json = {
  '1': 'ProposeBundle',
  '2': [
    {'1': 'sidechain_number', '3': 1, '4': 1, '5': 11, '6': '.google.protobuf.UInt32Value', '10': 'sidechainNumber'},
    {'1': 'bundle_txid', '3': 2, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.ConsensusHex', '10': 'bundleTxid'},
  ],
};

@$core.Deprecated('Use getCoinbasePSBTRequestDescriptor instead')
const GetCoinbasePSBTRequest_AckBundles$json = {
  '1': 'AckBundles',
  '2': [
    {'1': 'repeat_previous', '3': 1, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.GetCoinbasePSBTRequest.AckBundles.RepeatPrevious', '9': 0, '10': 'repeatPrevious'},
    {'1': 'leading_by_50', '3': 2, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.GetCoinbasePSBTRequest.AckBundles.LeadingBy50', '9': 0, '10': 'leadingBy50'},
    {'1': 'upvotes', '3': 3, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.GetCoinbasePSBTRequest.AckBundles.Upvotes', '9': 0, '10': 'upvotes'},
  ],
  '3': [GetCoinbasePSBTRequest_AckBundles_RepeatPrevious$json, GetCoinbasePSBTRequest_AckBundles_LeadingBy50$json, GetCoinbasePSBTRequest_AckBundles_Upvotes$json],
  '8': [
    {'1': 'ack_bundles'},
  ],
};

@$core.Deprecated('Use getCoinbasePSBTRequestDescriptor instead')
const GetCoinbasePSBTRequest_AckBundles_RepeatPrevious$json = {
  '1': 'RepeatPrevious',
};

@$core.Deprecated('Use getCoinbasePSBTRequestDescriptor instead')
const GetCoinbasePSBTRequest_AckBundles_LeadingBy50$json = {
  '1': 'LeadingBy50',
};

@$core.Deprecated('Use getCoinbasePSBTRequestDescriptor instead')
const GetCoinbasePSBTRequest_AckBundles_Upvotes$json = {
  '1': 'Upvotes',
  '2': [
    {'1': 'upvotes', '3': 1, '4': 3, '5': 13, '10': 'upvotes'},
  ],
};

/// Descriptor for `GetCoinbasePSBTRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCoinbasePSBTRequestDescriptor = $convert.base64Decode(
    'ChZHZXRDb2luYmFzZVBTQlRSZXF1ZXN0EmkKEnByb3Bvc2Vfc2lkZWNoYWlucxgBIAMoCzI6Lm'
    'N1c2YubWFpbmNoYWluLnYxLkdldENvaW5iYXNlUFNCVFJlcXVlc3QuUHJvcG9zZVNpZGVjaGFp'
    'blIRcHJvcG9zZVNpZGVjaGFpbnMSXQoOYWNrX3NpZGVjaGFpbnMYAiADKAsyNi5jdXNmLm1haW'
    '5jaGFpbi52MS5HZXRDb2luYmFzZVBTQlRSZXF1ZXN0LkFja1NpZGVjaGFpblINYWNrU2lkZWNo'
    'YWlucxJgCg9wcm9wb3NlX2J1bmRsZXMYAyADKAsyNy5jdXNmLm1haW5jaGFpbi52MS5HZXRDb2'
    'luYmFzZVBTQlRSZXF1ZXN0LlByb3Bvc2VCdW5kbGVSDnByb3Bvc2VCdW5kbGVzElUKC2Fja19i'
    'dW5kbGVzGAQgASgLMjQuY3VzZi5tYWluY2hhaW4udjEuR2V0Q29pbmJhc2VQU0JUUmVxdWVzdC'
    '5BY2tCdW5kbGVzUgphY2tCdW5kbGVzGpABChBQcm9wb3NlU2lkZWNoYWluEkcKEHNpZGVjaGFp'
    'bl9udW1iZXIYASABKAsyHC5nb29nbGUucHJvdG9idWYuVUludDMyVmFsdWVSD3NpZGVjaGFpbk'
    '51bWJlchIzCgRkYXRhGAIgASgLMh8uY3VzZi5tYWluY2hhaW4udjEuQ29uc2Vuc3VzSGV4UgRk'
    'YXRhGpUBCgxBY2tTaWRlY2hhaW4SRwoQc2lkZWNoYWluX251bWJlchgBIAEoCzIcLmdvb2dsZS'
    '5wcm90b2J1Zi5VSW50MzJWYWx1ZVIPc2lkZWNoYWluTnVtYmVyEjwKCWRhdGFfaGFzaBgCIAEo'
    'CzIfLmN1c2YubWFpbmNoYWluLnYxLkNvbnNlbnN1c0hleFIIZGF0YUhhc2gamgEKDVByb3Bvc2'
    'VCdW5kbGUSRwoQc2lkZWNoYWluX251bWJlchgBIAEoCzIcLmdvb2dsZS5wcm90b2J1Zi5VSW50'
    'MzJWYWx1ZVIPc2lkZWNoYWluTnVtYmVyEkAKC2J1bmRsZV90eGlkGAIgASgLMh8uY3VzZi5tYW'
    'luY2hhaW4udjEuQ29uc2Vuc3VzSGV4UgpidW5kbGVUeGlkGpMDCgpBY2tCdW5kbGVzEm4KD3Jl'
    'cGVhdF9wcmV2aW91cxgBIAEoCzJDLmN1c2YubWFpbmNoYWluLnYxLkdldENvaW5iYXNlUFNCVF'
    'JlcXVlc3QuQWNrQnVuZGxlcy5SZXBlYXRQcmV2aW91c0gAUg5yZXBlYXRQcmV2aW91cxJmCg1s'
    'ZWFkaW5nX2J5XzUwGAIgASgLMkAuY3VzZi5tYWluY2hhaW4udjEuR2V0Q29pbmJhc2VQU0JUUm'
    'VxdWVzdC5BY2tCdW5kbGVzLkxlYWRpbmdCeTUwSABSC2xlYWRpbmdCeTUwElgKB3Vwdm90ZXMY'
    'AyABKAsyPC5jdXNmLm1haW5jaGFpbi52MS5HZXRDb2luYmFzZVBTQlRSZXF1ZXN0LkFja0J1bm'
    'RsZXMuVXB2b3Rlc0gAUgd1cHZvdGVzGhAKDlJlcGVhdFByZXZpb3VzGg0KC0xlYWRpbmdCeTUw'
    'GiMKB1Vwdm90ZXMSGAoHdXB2b3RlcxgBIAMoDVIHdXB2b3Rlc0INCgthY2tfYnVuZGxlcw==');

@$core.Deprecated('Use getCoinbasePSBTResponseDescriptor instead')
const GetCoinbasePSBTResponse$json = {
  '1': 'GetCoinbasePSBTResponse',
  '2': [
    {'1': 'psbt', '3': 1, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.ConsensusHex', '10': 'psbt'},
  ],
};

/// Descriptor for `GetCoinbasePSBTResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCoinbasePSBTResponseDescriptor = $convert.base64Decode(
    'ChdHZXRDb2luYmFzZVBTQlRSZXNwb25zZRIzCgRwc2J0GAEgASgLMh8uY3VzZi5tYWluY2hhaW'
    '4udjEuQ29uc2Vuc3VzSGV4UgRwc2J0');

@$core.Deprecated('Use getCtipRequestDescriptor instead')
const GetCtipRequest$json = {
  '1': 'GetCtipRequest',
  '2': [
    {'1': 'sidechain_number', '3': 1, '4': 1, '5': 11, '6': '.google.protobuf.UInt32Value', '10': 'sidechainNumber'},
  ],
};

/// Descriptor for `GetCtipRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCtipRequestDescriptor = $convert.base64Decode(
    'Cg5HZXRDdGlwUmVxdWVzdBJHChBzaWRlY2hhaW5fbnVtYmVyGAEgASgLMhwuZ29vZ2xlLnByb3'
    'RvYnVmLlVJbnQzMlZhbHVlUg9zaWRlY2hhaW5OdW1iZXI=');

@$core.Deprecated('Use getCtipResponseDescriptor instead')
const GetCtipResponse$json = {
  '1': 'GetCtipResponse',
  '2': [
    {'1': 'ctip', '3': 1, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.GetCtipResponse.Ctip', '9': 0, '10': 'ctip', '17': true},
  ],
  '3': [GetCtipResponse_Ctip$json],
  '8': [
    {'1': '_ctip'},
  ],
};

@$core.Deprecated('Use getCtipResponseDescriptor instead')
const GetCtipResponse_Ctip$json = {
  '1': 'Ctip',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.ConsensusHex', '10': 'txid'},
    {'1': 'vout', '3': 2, '4': 1, '5': 13, '10': 'vout'},
    {'1': 'value', '3': 3, '4': 1, '5': 4, '10': 'value'},
    {'1': 'sequence_number', '3': 4, '4': 1, '5': 4, '10': 'sequenceNumber'},
  ],
};

/// Descriptor for `GetCtipResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCtipResponseDescriptor = $convert.base64Decode(
    'Cg9HZXRDdGlwUmVzcG9uc2USQAoEY3RpcBgBIAEoCzInLmN1c2YubWFpbmNoYWluLnYxLkdldE'
    'N0aXBSZXNwb25zZS5DdGlwSABSBGN0aXCIAQEajgEKBEN0aXASMwoEdHhpZBgBIAEoCzIfLmN1'
    'c2YubWFpbmNoYWluLnYxLkNvbnNlbnN1c0hleFIEdHhpZBISCgR2b3V0GAIgASgNUgR2b3V0Eh'
    'QKBXZhbHVlGAMgASgEUgV2YWx1ZRInCg9zZXF1ZW5jZV9udW1iZXIYBCABKARSDnNlcXVlbmNl'
    'TnVtYmVyQgcKBV9jdGlw');

@$core.Deprecated('Use getSidechainProposalsRequestDescriptor instead')
const GetSidechainProposalsRequest$json = {
  '1': 'GetSidechainProposalsRequest',
};

/// Descriptor for `GetSidechainProposalsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSidechainProposalsRequestDescriptor = $convert.base64Decode(
    'ChxHZXRTaWRlY2hhaW5Qcm9wb3NhbHNSZXF1ZXN0');

@$core.Deprecated('Use getSidechainProposalsResponseDescriptor instead')
const GetSidechainProposalsResponse$json = {
  '1': 'GetSidechainProposalsResponse',
  '2': [
    {'1': 'sidechain_proposals', '3': 1, '4': 3, '5': 11, '6': '.cusf.mainchain.v1.GetSidechainProposalsResponse.SidechainProposal', '10': 'sidechainProposals'},
  ],
  '3': [GetSidechainProposalsResponse_SidechainProposal$json],
};

@$core.Deprecated('Use getSidechainProposalsResponseDescriptor instead')
const GetSidechainProposalsResponse_SidechainProposal$json = {
  '1': 'SidechainProposal',
  '2': [
    {'1': 'sidechain_number', '3': 1, '4': 1, '5': 13, '10': 'sidechainNumber'},
    {'1': 'data', '3': 2, '4': 1, '5': 11, '6': '.google.protobuf.BytesValue', '10': 'data'},
    {'1': 'data_hash', '3': 3, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.ConsensusHex', '10': 'dataHash'},
    {'1': 'vote_count', '3': 4, '4': 1, '5': 13, '10': 'voteCount'},
    {'1': 'proposal_height', '3': 5, '4': 1, '5': 13, '10': 'proposalHeight'},
    {'1': 'proposal_age', '3': 6, '4': 1, '5': 13, '10': 'proposalAge'},
  ],
};

/// Descriptor for `GetSidechainProposalsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSidechainProposalsResponseDescriptor = $convert.base64Decode(
    'Ch1HZXRTaWRlY2hhaW5Qcm9wb3NhbHNSZXNwb25zZRJzChNzaWRlY2hhaW5fcHJvcG9zYWxzGA'
    'EgAygLMkIuY3VzZi5tYWluY2hhaW4udjEuR2V0U2lkZWNoYWluUHJvcG9zYWxzUmVzcG9uc2Uu'
    'U2lkZWNoYWluUHJvcG9zYWxSEnNpZGVjaGFpblByb3Bvc2FscxqYAgoRU2lkZWNoYWluUHJvcG'
    '9zYWwSKQoQc2lkZWNoYWluX251bWJlchgBIAEoDVIPc2lkZWNoYWluTnVtYmVyEi8KBGRhdGEY'
    'AiABKAsyGy5nb29nbGUucHJvdG9idWYuQnl0ZXNWYWx1ZVIEZGF0YRI8CglkYXRhX2hhc2gYAy'
    'ABKAsyHy5jdXNmLm1haW5jaGFpbi52MS5Db25zZW5zdXNIZXhSCGRhdGFIYXNoEh0KCnZvdGVf'
    'Y291bnQYBCABKA1SCXZvdGVDb3VudBInCg9wcm9wb3NhbF9oZWlnaHQYBSABKA1SDnByb3Bvc2'
    'FsSGVpZ2h0EiEKDHByb3Bvc2FsX2FnZRgGIAEoDVILcHJvcG9zYWxBZ2U=');

@$core.Deprecated('Use getSidechainsRequestDescriptor instead')
const GetSidechainsRequest$json = {
  '1': 'GetSidechainsRequest',
};

/// Descriptor for `GetSidechainsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSidechainsRequestDescriptor = $convert.base64Decode(
    'ChRHZXRTaWRlY2hhaW5zUmVxdWVzdA==');

@$core.Deprecated('Use getSidechainsResponseDescriptor instead')
const GetSidechainsResponse$json = {
  '1': 'GetSidechainsResponse',
  '2': [
    {'1': 'sidechains', '3': 1, '4': 3, '5': 11, '6': '.cusf.mainchain.v1.GetSidechainsResponse.SidechainInfo', '10': 'sidechains'},
  ],
  '3': [GetSidechainsResponse_SidechainInfo$json],
};

@$core.Deprecated('Use getSidechainsResponseDescriptor instead')
const GetSidechainsResponse_SidechainInfo$json = {
  '1': 'SidechainInfo',
  '2': [
    {'1': 'sidechain_number', '3': 1, '4': 1, '5': 13, '10': 'sidechainNumber'},
    {'1': 'data', '3': 2, '4': 1, '5': 11, '6': '.google.protobuf.BytesValue', '10': 'data'},
    {'1': 'vote_count', '3': 3, '4': 1, '5': 13, '10': 'voteCount'},
    {'1': 'proposal_height', '3': 4, '4': 1, '5': 13, '10': 'proposalHeight'},
    {'1': 'activation_height', '3': 5, '4': 1, '5': 13, '10': 'activationHeight'},
  ],
};

/// Descriptor for `GetSidechainsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSidechainsResponseDescriptor = $convert.base64Decode(
    'ChVHZXRTaWRlY2hhaW5zUmVzcG9uc2USVgoKc2lkZWNoYWlucxgBIAMoCzI2LmN1c2YubWFpbm'
    'NoYWluLnYxLkdldFNpZGVjaGFpbnNSZXNwb25zZS5TaWRlY2hhaW5JbmZvUgpzaWRlY2hhaW5z'
    'GuABCg1TaWRlY2hhaW5JbmZvEikKEHNpZGVjaGFpbl9udW1iZXIYASABKA1SD3NpZGVjaGFpbk'
    '51bWJlchIvCgRkYXRhGAIgASgLMhsuZ29vZ2xlLnByb3RvYnVmLkJ5dGVzVmFsdWVSBGRhdGES'
    'HQoKdm90ZV9jb3VudBgDIAEoDVIJdm90ZUNvdW50EicKD3Byb3Bvc2FsX2hlaWdodBgEIAEoDV'
    'IOcHJvcG9zYWxIZWlnaHQSKwoRYWN0aXZhdGlvbl9oZWlnaHQYBSABKA1SEGFjdGl2YXRpb25I'
    'ZWlnaHQ=');

@$core.Deprecated('Use getTwoWayPegDataRequestDescriptor instead')
const GetTwoWayPegDataRequest$json = {
  '1': 'GetTwoWayPegDataRequest',
  '2': [
    {'1': 'sidechain_id', '3': 1, '4': 1, '5': 11, '6': '.google.protobuf.UInt32Value', '10': 'sidechainId'},
    {'1': 'start_block_hash', '3': 2, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.ReverseHex', '9': 0, '10': 'startBlockHash', '17': true},
    {'1': 'end_block_hash', '3': 3, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.ReverseHex', '10': 'endBlockHash'},
  ],
  '8': [
    {'1': '_start_block_hash'},
  ],
};

/// Descriptor for `GetTwoWayPegDataRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTwoWayPegDataRequestDescriptor = $convert.base64Decode(
    'ChdHZXRUd29XYXlQZWdEYXRhUmVxdWVzdBI/CgxzaWRlY2hhaW5faWQYASABKAsyHC5nb29nbG'
    'UucHJvdG9idWYuVUludDMyVmFsdWVSC3NpZGVjaGFpbklkEkwKEHN0YXJ0X2Jsb2NrX2hhc2gY'
    'AiABKAsyHS5jdXNmLm1haW5jaGFpbi52MS5SZXZlcnNlSGV4SABSDnN0YXJ0QmxvY2tIYXNoiA'
    'EBEkMKDmVuZF9ibG9ja19oYXNoGAMgASgLMh0uY3VzZi5tYWluY2hhaW4udjEuUmV2ZXJzZUhl'
    'eFIMZW5kQmxvY2tIYXNoQhMKEV9zdGFydF9ibG9ja19oYXNo');

@$core.Deprecated('Use getTwoWayPegDataResponseDescriptor instead')
const GetTwoWayPegDataResponse$json = {
  '1': 'GetTwoWayPegDataResponse',
  '2': [
    {'1': 'blocks', '3': 1, '4': 3, '5': 11, '6': '.cusf.mainchain.v1.GetTwoWayPegDataResponse.ResponseItem', '10': 'blocks'},
  ],
  '3': [GetTwoWayPegDataResponse_ResponseItem$json],
};

@$core.Deprecated('Use getTwoWayPegDataResponseDescriptor instead')
const GetTwoWayPegDataResponse_ResponseItem$json = {
  '1': 'ResponseItem',
  '2': [
    {'1': 'block_header_info', '3': 1, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.BlockHeaderInfo', '10': 'blockHeaderInfo'},
    {'1': 'block_info', '3': 2, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.BlockInfo', '10': 'blockInfo'},
  ],
};

/// Descriptor for `GetTwoWayPegDataResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTwoWayPegDataResponseDescriptor = $convert.base64Decode(
    'ChhHZXRUd29XYXlQZWdEYXRhUmVzcG9uc2USUAoGYmxvY2tzGAEgAygLMjguY3VzZi5tYWluY2'
    'hhaW4udjEuR2V0VHdvV2F5UGVnRGF0YVJlc3BvbnNlLlJlc3BvbnNlSXRlbVIGYmxvY2tzGpsB'
    'CgxSZXNwb25zZUl0ZW0STgoRYmxvY2tfaGVhZGVyX2luZm8YASABKAsyIi5jdXNmLm1haW5jaG'
    'Fpbi52MS5CbG9ja0hlYWRlckluZm9SD2Jsb2NrSGVhZGVySW5mbxI7CgpibG9ja19pbmZvGAIg'
    'ASgLMhwuY3VzZi5tYWluY2hhaW4udjEuQmxvY2tJbmZvUglibG9ja0luZm8=');

@$core.Deprecated('Use subscribeEventsRequestDescriptor instead')
const SubscribeEventsRequest$json = {
  '1': 'SubscribeEventsRequest',
  '2': [
    {'1': 'sidechain_id', '3': 1, '4': 1, '5': 11, '6': '.google.protobuf.UInt32Value', '10': 'sidechainId'},
  ],
};

/// Descriptor for `SubscribeEventsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List subscribeEventsRequestDescriptor = $convert.base64Decode(
    'ChZTdWJzY3JpYmVFdmVudHNSZXF1ZXN0Ej8KDHNpZGVjaGFpbl9pZBgBIAEoCzIcLmdvb2dsZS'
    '5wcm90b2J1Zi5VSW50MzJWYWx1ZVILc2lkZWNoYWluSWQ=');

@$core.Deprecated('Use subscribeEventsResponseDescriptor instead')
const SubscribeEventsResponse$json = {
  '1': 'SubscribeEventsResponse',
  '2': [
    {'1': 'event', '3': 1, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.SubscribeEventsResponse.Event', '10': 'event'},
  ],
  '3': [SubscribeEventsResponse_Event$json],
};

@$core.Deprecated('Use subscribeEventsResponseDescriptor instead')
const SubscribeEventsResponse_Event$json = {
  '1': 'Event',
  '2': [
    {'1': 'connect_block', '3': 1, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.SubscribeEventsResponse.Event.ConnectBlock', '9': 0, '10': 'connectBlock'},
    {'1': 'disconnect_block', '3': 2, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.SubscribeEventsResponse.Event.DisconnectBlock', '9': 0, '10': 'disconnectBlock'},
  ],
  '3': [SubscribeEventsResponse_Event_ConnectBlock$json, SubscribeEventsResponse_Event_DisconnectBlock$json],
  '8': [
    {'1': 'event'},
  ],
};

@$core.Deprecated('Use subscribeEventsResponseDescriptor instead')
const SubscribeEventsResponse_Event_ConnectBlock$json = {
  '1': 'ConnectBlock',
  '2': [
    {'1': 'header_info', '3': 1, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.BlockHeaderInfo', '10': 'headerInfo'},
    {'1': 'block_info', '3': 2, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.BlockInfo', '10': 'blockInfo'},
  ],
};

@$core.Deprecated('Use subscribeEventsResponseDescriptor instead')
const SubscribeEventsResponse_Event_DisconnectBlock$json = {
  '1': 'DisconnectBlock',
  '2': [
    {'1': 'block_hash', '3': 1, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.ReverseHex', '10': 'blockHash'},
  ],
};

/// Descriptor for `SubscribeEventsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List subscribeEventsResponseDescriptor = $convert.base64Decode(
    'ChdTdWJzY3JpYmVFdmVudHNSZXNwb25zZRJGCgVldmVudBgBIAEoCzIwLmN1c2YubWFpbmNoYW'
    'luLnYxLlN1YnNjcmliZUV2ZW50c1Jlc3BvbnNlLkV2ZW50UgVldmVudBrJAwoFRXZlbnQSZAoN'
    'Y29ubmVjdF9ibG9jaxgBIAEoCzI9LmN1c2YubWFpbmNoYWluLnYxLlN1YnNjcmliZUV2ZW50c1'
    'Jlc3BvbnNlLkV2ZW50LkNvbm5lY3RCbG9ja0gAUgxjb25uZWN0QmxvY2sSbQoQZGlzY29ubmVj'
    'dF9ibG9jaxgCIAEoCzJALmN1c2YubWFpbmNoYWluLnYxLlN1YnNjcmliZUV2ZW50c1Jlc3Bvbn'
    'NlLkV2ZW50LkRpc2Nvbm5lY3RCbG9ja0gAUg9kaXNjb25uZWN0QmxvY2sakAEKDENvbm5lY3RC'
    'bG9jaxJDCgtoZWFkZXJfaW5mbxgBIAEoCzIiLmN1c2YubWFpbmNoYWluLnYxLkJsb2NrSGVhZG'
    'VySW5mb1IKaGVhZGVySW5mbxI7CgpibG9ja19pbmZvGAIgASgLMhwuY3VzZi5tYWluY2hhaW4u'
    'djEuQmxvY2tJbmZvUglibG9ja0luZm8aTwoPRGlzY29ubmVjdEJsb2NrEjwKCmJsb2NrX2hhc2'
    'gYASABKAsyHS5jdXNmLm1haW5jaGFpbi52MS5SZXZlcnNlSGV4UglibG9ja0hhc2hCBwoFZXZl'
    'bnQ=');

