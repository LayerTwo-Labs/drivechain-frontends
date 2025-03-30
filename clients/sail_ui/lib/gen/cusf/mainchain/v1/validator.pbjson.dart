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

import '../../../google/protobuf/wrappers.pbjson.dart' as $0;
import '../../common/v1/common.pbjson.dart' as $1;
import 'common.pbjson.dart' as $3;

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

@$core.Deprecated('Use blockHeaderInfoDescriptor instead')
const BlockHeaderInfo$json = {
  '1': 'BlockHeaderInfo',
  '2': [
    {'1': 'block_hash', '3': 1, '4': 1, '5': 11, '6': '.cusf.common.v1.ReverseHex', '10': 'blockHash'},
    {'1': 'prev_block_hash', '3': 2, '4': 1, '5': 11, '6': '.cusf.common.v1.ReverseHex', '10': 'prevBlockHash'},
    {'1': 'height', '3': 3, '4': 1, '5': 13, '10': 'height'},
    {'1': 'work', '3': 4, '4': 1, '5': 11, '6': '.cusf.common.v1.ConsensusHex', '10': 'work'},
  ],
};

/// Descriptor for `BlockHeaderInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List blockHeaderInfoDescriptor = $convert.base64Decode(
    'Cg9CbG9ja0hlYWRlckluZm8SOQoKYmxvY2tfaGFzaBgBIAEoCzIaLmN1c2YuY29tbW9uLnYxLl'
    'JldmVyc2VIZXhSCWJsb2NrSGFzaBJCCg9wcmV2X2Jsb2NrX2hhc2gYAiABKAsyGi5jdXNmLmNv'
    'bW1vbi52MS5SZXZlcnNlSGV4Ug1wcmV2QmxvY2tIYXNoEhYKBmhlaWdodBgDIAEoDVIGaGVpZ2'
    'h0EjAKBHdvcmsYBCABKAsyHC5jdXNmLmNvbW1vbi52MS5Db25zZW5zdXNIZXhSBHdvcms=');

@$core.Deprecated('Use depositDescriptor instead')
const Deposit$json = {
  '1': 'Deposit',
  '2': [
    {'1': 'sequence_number', '3': 1, '4': 1, '5': 11, '6': '.google.protobuf.UInt64Value', '10': 'sequenceNumber'},
    {'1': 'outpoint', '3': 2, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.OutPoint', '10': 'outpoint'},
    {'1': 'output', '3': 3, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.Deposit.Output', '10': 'output'},
  ],
  '3': [Deposit_Output$json],
};

@$core.Deprecated('Use depositDescriptor instead')
const Deposit_Output$json = {
  '1': 'Output',
  '2': [
    {'1': 'address', '3': 2, '4': 1, '5': 11, '6': '.cusf.common.v1.Hex', '10': 'address'},
    {'1': 'value_sats', '3': 3, '4': 1, '5': 11, '6': '.google.protobuf.UInt64Value', '10': 'valueSats'},
  ],
};

/// Descriptor for `Deposit`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List depositDescriptor = $convert.base64Decode(
    'CgdEZXBvc2l0EkUKD3NlcXVlbmNlX251bWJlchgBIAEoCzIcLmdvb2dsZS5wcm90b2J1Zi5VSW'
    '50NjRWYWx1ZVIOc2VxdWVuY2VOdW1iZXISNwoIb3V0cG9pbnQYAiABKAsyGy5jdXNmLm1haW5j'
    'aGFpbi52MS5PdXRQb2ludFIIb3V0cG9pbnQSOQoGb3V0cHV0GAMgASgLMiEuY3VzZi5tYWluY2'
    'hhaW4udjEuRGVwb3NpdC5PdXRwdXRSBm91dHB1dBp0CgZPdXRwdXQSLQoHYWRkcmVzcxgCIAEo'
    'CzITLmN1c2YuY29tbW9uLnYxLkhleFIHYWRkcmVzcxI7Cgp2YWx1ZV9zYXRzGAMgASgLMhwuZ2'
    '9vZ2xlLnByb3RvYnVmLlVJbnQ2NFZhbHVlUgl2YWx1ZVNhdHM=');

@$core.Deprecated('Use withdrawalBundleEventDescriptor instead')
const WithdrawalBundleEvent$json = {
  '1': 'WithdrawalBundleEvent',
  '2': [
    {'1': 'm6id', '3': 1, '4': 1, '5': 11, '6': '.cusf.common.v1.ConsensusHex', '10': 'm6id'},
    {'1': 'event', '3': 2, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.WithdrawalBundleEvent.Event', '10': 'event'},
  ],
  '3': [WithdrawalBundleEvent_Event$json],
};

@$core.Deprecated('Use withdrawalBundleEventDescriptor instead')
const WithdrawalBundleEvent_Event$json = {
  '1': 'Event',
  '2': [
    {'1': 'failed', '3': 1, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.WithdrawalBundleEvent.Event.Failed', '9': 0, '10': 'failed'},
    {'1': 'succeeded', '3': 2, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.WithdrawalBundleEvent.Event.Succeeded', '9': 0, '10': 'succeeded'},
    {'1': 'submitted', '3': 3, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.WithdrawalBundleEvent.Event.Submitted', '9': 0, '10': 'submitted'},
  ],
  '3': [WithdrawalBundleEvent_Event_Failed$json, WithdrawalBundleEvent_Event_Succeeded$json, WithdrawalBundleEvent_Event_Submitted$json],
  '8': [
    {'1': 'event'},
  ],
};

@$core.Deprecated('Use withdrawalBundleEventDescriptor instead')
const WithdrawalBundleEvent_Event_Failed$json = {
  '1': 'Failed',
};

@$core.Deprecated('Use withdrawalBundleEventDescriptor instead')
const WithdrawalBundleEvent_Event_Succeeded$json = {
  '1': 'Succeeded',
  '2': [
    {'1': 'sequence_number', '3': 1, '4': 1, '5': 11, '6': '.google.protobuf.UInt64Value', '10': 'sequenceNumber'},
    {'1': 'transaction', '3': 2, '4': 1, '5': 11, '6': '.cusf.common.v1.ConsensusHex', '10': 'transaction'},
  ],
};

@$core.Deprecated('Use withdrawalBundleEventDescriptor instead')
const WithdrawalBundleEvent_Event_Submitted$json = {
  '1': 'Submitted',
};

/// Descriptor for `WithdrawalBundleEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List withdrawalBundleEventDescriptor = $convert.base64Decode(
    'ChVXaXRoZHJhd2FsQnVuZGxlRXZlbnQSMAoEbTZpZBgBIAEoCzIcLmN1c2YuY29tbW9uLnYxLk'
    'NvbnNlbnN1c0hleFIEbTZpZBJECgVldmVudBgCIAEoCzIuLmN1c2YubWFpbmNoYWluLnYxLldp'
    'dGhkcmF3YWxCdW5kbGVFdmVudC5FdmVudFIFZXZlbnQawQMKBUV2ZW50Ek8KBmZhaWxlZBgBIA'
    'EoCzI1LmN1c2YubWFpbmNoYWluLnYxLldpdGhkcmF3YWxCdW5kbGVFdmVudC5FdmVudC5GYWls'
    'ZWRIAFIGZmFpbGVkElgKCXN1Y2NlZWRlZBgCIAEoCzI4LmN1c2YubWFpbmNoYWluLnYxLldpdG'
    'hkcmF3YWxCdW5kbGVFdmVudC5FdmVudC5TdWNjZWVkZWRIAFIJc3VjY2VlZGVkElgKCXN1Ym1p'
    'dHRlZBgDIAEoCzI4LmN1c2YubWFpbmNoYWluLnYxLldpdGhkcmF3YWxCdW5kbGVFdmVudC5Fdm'
    'VudC5TdWJtaXR0ZWRIAFIJc3VibWl0dGVkGggKBkZhaWxlZBqSAQoJU3VjY2VlZGVkEkUKD3Nl'
    'cXVlbmNlX251bWJlchgBIAEoCzIcLmdvb2dsZS5wcm90b2J1Zi5VSW50NjRWYWx1ZVIOc2VxdW'
    'VuY2VOdW1iZXISPgoLdHJhbnNhY3Rpb24YAiABKAsyHC5jdXNmLmNvbW1vbi52MS5Db25zZW5z'
    'dXNIZXhSC3RyYW5zYWN0aW9uGgsKCVN1Ym1pdHRlZEIHCgVldmVudA==');

@$core.Deprecated('Use blockInfoDescriptor instead')
const BlockInfo$json = {
  '1': 'BlockInfo',
  '2': [
    {'1': 'bmm_commitment', '3': 1, '4': 1, '5': 11, '6': '.cusf.common.v1.ConsensusHex', '9': 0, '10': 'bmmCommitment', '17': true},
    {'1': 'events', '3': 2, '4': 3, '5': 11, '6': '.cusf.mainchain.v1.BlockInfo.Event', '10': 'events'},
  ],
  '3': [BlockInfo_Event$json],
  '8': [
    {'1': '_bmm_commitment'},
  ],
};

@$core.Deprecated('Use blockInfoDescriptor instead')
const BlockInfo_Event$json = {
  '1': 'Event',
  '2': [
    {'1': 'deposit', '3': 1, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.Deposit', '9': 0, '10': 'deposit'},
    {'1': 'withdrawal_bundle', '3': 2, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.WithdrawalBundleEvent', '9': 0, '10': 'withdrawalBundle'},
  ],
  '8': [
    {'1': 'event'},
  ],
};

/// Descriptor for `BlockInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List blockInfoDescriptor = $convert.base64Decode(
    'CglCbG9ja0luZm8SSAoOYm1tX2NvbW1pdG1lbnQYASABKAsyHC5jdXNmLmNvbW1vbi52MS5Db2'
    '5zZW5zdXNIZXhIAFINYm1tQ29tbWl0bWVudIgBARI6CgZldmVudHMYAiADKAsyIi5jdXNmLm1h'
    'aW5jaGFpbi52MS5CbG9ja0luZm8uRXZlbnRSBmV2ZW50cxqhAQoFRXZlbnQSNgoHZGVwb3NpdB'
    'gBIAEoCzIaLmN1c2YubWFpbmNoYWluLnYxLkRlcG9zaXRIAFIHZGVwb3NpdBJXChF3aXRoZHJh'
    'd2FsX2J1bmRsZRgCIAEoCzIoLmN1c2YubWFpbmNoYWluLnYxLldpdGhkcmF3YWxCdW5kbGVFdm'
    'VudEgAUhB3aXRoZHJhd2FsQnVuZGxlQgcKBWV2ZW50QhEKD19ibW1fY29tbWl0bWVudA==');

@$core.Deprecated('Use getBlockHeaderInfoRequestDescriptor instead')
const GetBlockHeaderInfoRequest$json = {
  '1': 'GetBlockHeaderInfoRequest',
  '2': [
    {'1': 'block_hash', '3': 1, '4': 1, '5': 11, '6': '.cusf.common.v1.ReverseHex', '10': 'blockHash'},
  ],
};

/// Descriptor for `GetBlockHeaderInfoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBlockHeaderInfoRequestDescriptor = $convert.base64Decode(
    'ChlHZXRCbG9ja0hlYWRlckluZm9SZXF1ZXN0EjkKCmJsb2NrX2hhc2gYASABKAsyGi5jdXNmLm'
    'NvbW1vbi52MS5SZXZlcnNlSGV4UglibG9ja0hhc2g=');

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
    {'1': 'block_hash', '3': 1, '4': 1, '5': 11, '6': '.cusf.common.v1.ReverseHex', '10': 'blockHash'},
    {'1': 'sidechain_id', '3': 2, '4': 1, '5': 11, '6': '.google.protobuf.UInt32Value', '10': 'sidechainId'},
  ],
};

/// Descriptor for `GetBlockInfoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBlockInfoRequestDescriptor = $convert.base64Decode(
    'ChNHZXRCbG9ja0luZm9SZXF1ZXN0EjkKCmJsb2NrX2hhc2gYASABKAsyGi5jdXNmLmNvbW1vbi'
    '52MS5SZXZlcnNlSGV4UglibG9ja0hhc2gSPwoMc2lkZWNoYWluX2lkGAIgASgLMhwuZ29vZ2xl'
    'LnByb3RvYnVmLlVJbnQzMlZhbHVlUgtzaWRlY2hhaW5JZA==');

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
    {'1': 'block_hash', '3': 1, '4': 1, '5': 11, '6': '.cusf.common.v1.ReverseHex', '10': 'blockHash'},
    {'1': 'sidechain_id', '3': 2, '4': 1, '5': 11, '6': '.google.protobuf.UInt32Value', '10': 'sidechainId'},
  ],
};

/// Descriptor for `GetBmmHStarCommitmentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBmmHStarCommitmentRequestDescriptor = $convert.base64Decode(
    'ChxHZXRCbW1IU3RhckNvbW1pdG1lbnRSZXF1ZXN0EjkKCmJsb2NrX2hhc2gYASABKAsyGi5jdX'
    'NmLmNvbW1vbi52MS5SZXZlcnNlSGV4UglibG9ja0hhc2gSPwoMc2lkZWNoYWluX2lkGAIgASgL'
    'MhwuZ29vZ2xlLnByb3RvYnVmLlVJbnQzMlZhbHVlUgtzaWRlY2hhaW5JZA==');

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
    {'1': 'block_hash', '3': 1, '4': 1, '5': 11, '6': '.cusf.common.v1.ReverseHex', '10': 'blockHash'},
  ],
};

@$core.Deprecated('Use getBmmHStarCommitmentResponseDescriptor instead')
const GetBmmHStarCommitmentResponse_Commitment$json = {
  '1': 'Commitment',
  '2': [
    {'1': 'commitment', '3': 1, '4': 1, '5': 11, '6': '.cusf.common.v1.ConsensusHex', '9': 0, '10': 'commitment', '17': true},
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
    'dEgAUgpjb21taXRtZW50Gk8KEkJsb2NrTm90Rm91bmRFcnJvchI5CgpibG9ja19oYXNoGAEgAS'
    'gLMhouY3VzZi5jb21tb24udjEuUmV2ZXJzZUhleFIJYmxvY2tIYXNoGl4KCkNvbW1pdG1lbnQS'
    'QQoKY29tbWl0bWVudBgBIAEoCzIcLmN1c2YuY29tbW9uLnYxLkNvbnNlbnN1c0hleEgAUgpjb2'
    '1taXRtZW50iAEBQg0KC19jb21taXRtZW50QggKBnJlc3VsdA==');

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
    {'1': 'data', '3': 2, '4': 1, '5': 11, '6': '.cusf.common.v1.ConsensusHex', '10': 'data'},
  ],
};

@$core.Deprecated('Use getCoinbasePSBTRequestDescriptor instead')
const GetCoinbasePSBTRequest_AckSidechain$json = {
  '1': 'AckSidechain',
  '2': [
    {'1': 'sidechain_number', '3': 1, '4': 1, '5': 11, '6': '.google.protobuf.UInt32Value', '10': 'sidechainNumber'},
    {'1': 'data_hash', '3': 2, '4': 1, '5': 11, '6': '.cusf.common.v1.ConsensusHex', '10': 'dataHash'},
  ],
};

@$core.Deprecated('Use getCoinbasePSBTRequestDescriptor instead')
const GetCoinbasePSBTRequest_ProposeBundle$json = {
  '1': 'ProposeBundle',
  '2': [
    {'1': 'sidechain_number', '3': 1, '4': 1, '5': 11, '6': '.google.protobuf.UInt32Value', '10': 'sidechainNumber'},
    {'1': 'bundle_txid', '3': 2, '4': 1, '5': 11, '6': '.cusf.common.v1.ReverseHex', '10': 'bundleTxid'},
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
    '5BY2tCdW5kbGVzUgphY2tCdW5kbGVzGo0BChBQcm9wb3NlU2lkZWNoYWluEkcKEHNpZGVjaGFp'
    'bl9udW1iZXIYASABKAsyHC5nb29nbGUucHJvdG9idWYuVUludDMyVmFsdWVSD3NpZGVjaGFpbk'
    '51bWJlchIwCgRkYXRhGAIgASgLMhwuY3VzZi5jb21tb24udjEuQ29uc2Vuc3VzSGV4UgRkYXRh'
    'GpIBCgxBY2tTaWRlY2hhaW4SRwoQc2lkZWNoYWluX251bWJlchgBIAEoCzIcLmdvb2dsZS5wcm'
    '90b2J1Zi5VSW50MzJWYWx1ZVIPc2lkZWNoYWluTnVtYmVyEjkKCWRhdGFfaGFzaBgCIAEoCzIc'
    'LmN1c2YuY29tbW9uLnYxLkNvbnNlbnN1c0hleFIIZGF0YUhhc2galQEKDVByb3Bvc2VCdW5kbG'
    'USRwoQc2lkZWNoYWluX251bWJlchgBIAEoCzIcLmdvb2dsZS5wcm90b2J1Zi5VSW50MzJWYWx1'
    'ZVIPc2lkZWNoYWluTnVtYmVyEjsKC2J1bmRsZV90eGlkGAIgASgLMhouY3VzZi5jb21tb24udj'
    'EuUmV2ZXJzZUhleFIKYnVuZGxlVHhpZBqTAwoKQWNrQnVuZGxlcxJuCg9yZXBlYXRfcHJldmlv'
    'dXMYASABKAsyQy5jdXNmLm1haW5jaGFpbi52MS5HZXRDb2luYmFzZVBTQlRSZXF1ZXN0LkFja0'
    'J1bmRsZXMuUmVwZWF0UHJldmlvdXNIAFIOcmVwZWF0UHJldmlvdXMSZgoNbGVhZGluZ19ieV81'
    'MBgCIAEoCzJALmN1c2YubWFpbmNoYWluLnYxLkdldENvaW5iYXNlUFNCVFJlcXVlc3QuQWNrQn'
    'VuZGxlcy5MZWFkaW5nQnk1MEgAUgtsZWFkaW5nQnk1MBJYCgd1cHZvdGVzGAMgASgLMjwuY3Vz'
    'Zi5tYWluY2hhaW4udjEuR2V0Q29pbmJhc2VQU0JUUmVxdWVzdC5BY2tCdW5kbGVzLlVwdm90ZX'
    'NIAFIHdXB2b3RlcxoQCg5SZXBlYXRQcmV2aW91cxoNCgtMZWFkaW5nQnk1MBojCgdVcHZvdGVz'
    'EhgKB3Vwdm90ZXMYASADKA1SB3Vwdm90ZXNCDQoLYWNrX2J1bmRsZXM=');

@$core.Deprecated('Use getCoinbasePSBTResponseDescriptor instead')
const GetCoinbasePSBTResponse$json = {
  '1': 'GetCoinbasePSBTResponse',
  '2': [
    {'1': 'psbt', '3': 1, '4': 1, '5': 11, '6': '.cusf.common.v1.ConsensusHex', '10': 'psbt'},
  ],
};

/// Descriptor for `GetCoinbasePSBTResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCoinbasePSBTResponseDescriptor = $convert.base64Decode(
    'ChdHZXRDb2luYmFzZVBTQlRSZXNwb25zZRIwCgRwc2J0GAEgASgLMhwuY3VzZi5jb21tb24udj'
    'EuQ29uc2Vuc3VzSGV4UgRwc2J0');

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
    {'1': 'txid', '3': 1, '4': 1, '5': 11, '6': '.cusf.common.v1.ReverseHex', '10': 'txid'},
    {'1': 'vout', '3': 2, '4': 1, '5': 13, '10': 'vout'},
    {'1': 'value', '3': 3, '4': 1, '5': 4, '10': 'value'},
    {'1': 'sequence_number', '3': 4, '4': 1, '5': 4, '10': 'sequenceNumber'},
  ],
};

/// Descriptor for `GetCtipResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCtipResponseDescriptor = $convert.base64Decode(
    'Cg9HZXRDdGlwUmVzcG9uc2USQAoEY3RpcBgBIAEoCzInLmN1c2YubWFpbmNoYWluLnYxLkdldE'
    'N0aXBSZXNwb25zZS5DdGlwSABSBGN0aXCIAQEaiQEKBEN0aXASLgoEdHhpZBgBIAEoCzIaLmN1'
    'c2YuY29tbW9uLnYxLlJldmVyc2VIZXhSBHR4aWQSEgoEdm91dBgCIAEoDVIEdm91dBIUCgV2YW'
    'x1ZRgDIAEoBFIFdmFsdWUSJwoPc2VxdWVuY2VfbnVtYmVyGAQgASgEUg5zZXF1ZW5jZU51bWJl'
    'ckIHCgVfY3RpcA==');

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
    {'1': 'sidechain_number', '3': 1, '4': 1, '5': 11, '6': '.google.protobuf.UInt32Value', '10': 'sidechainNumber'},
    {'1': 'description', '3': 2, '4': 1, '5': 11, '6': '.cusf.common.v1.ConsensusHex', '10': 'description'},
    {'1': 'declaration', '3': 7, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.SidechainDeclaration', '9': 0, '10': 'declaration', '17': true},
    {'1': 'description_sha256d_hash', '3': 3, '4': 1, '5': 11, '6': '.cusf.common.v1.ReverseHex', '10': 'descriptionSha256dHash'},
    {'1': 'vote_count', '3': 4, '4': 1, '5': 11, '6': '.google.protobuf.UInt32Value', '10': 'voteCount'},
    {'1': 'proposal_height', '3': 5, '4': 1, '5': 11, '6': '.google.protobuf.UInt32Value', '10': 'proposalHeight'},
    {'1': 'proposal_age', '3': 6, '4': 1, '5': 11, '6': '.google.protobuf.UInt32Value', '10': 'proposalAge'},
  ],
  '8': [
    {'1': '_declaration'},
  ],
};

/// Descriptor for `GetSidechainProposalsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSidechainProposalsResponseDescriptor = $convert.base64Decode(
    'Ch1HZXRTaWRlY2hhaW5Qcm9wb3NhbHNSZXNwb25zZRJzChNzaWRlY2hhaW5fcHJvcG9zYWxzGA'
    'EgAygLMkIuY3VzZi5tYWluY2hhaW4udjEuR2V0U2lkZWNoYWluUHJvcG9zYWxzUmVzcG9uc2Uu'
    'U2lkZWNoYWluUHJvcG9zYWxSEnNpZGVjaGFpblByb3Bvc2FscxqXBAoRU2lkZWNoYWluUHJvcG'
    '9zYWwSRwoQc2lkZWNoYWluX251bWJlchgBIAEoCzIcLmdvb2dsZS5wcm90b2J1Zi5VSW50MzJW'
    'YWx1ZVIPc2lkZWNoYWluTnVtYmVyEj4KC2Rlc2NyaXB0aW9uGAIgASgLMhwuY3VzZi5jb21tb2'
    '4udjEuQ29uc2Vuc3VzSGV4UgtkZXNjcmlwdGlvbhJOCgtkZWNsYXJhdGlvbhgHIAEoCzInLmN1'
    'c2YubWFpbmNoYWluLnYxLlNpZGVjaGFpbkRlY2xhcmF0aW9uSABSC2RlY2xhcmF0aW9uiAEBEl'
    'QKGGRlc2NyaXB0aW9uX3NoYTI1NmRfaGFzaBgDIAEoCzIaLmN1c2YuY29tbW9uLnYxLlJldmVy'
    'c2VIZXhSFmRlc2NyaXB0aW9uU2hhMjU2ZEhhc2gSOwoKdm90ZV9jb3VudBgEIAEoCzIcLmdvb2'
    'dsZS5wcm90b2J1Zi5VSW50MzJWYWx1ZVIJdm90ZUNvdW50EkUKD3Byb3Bvc2FsX2hlaWdodBgF'
    'IAEoCzIcLmdvb2dsZS5wcm90b2J1Zi5VSW50MzJWYWx1ZVIOcHJvcG9zYWxIZWlnaHQSPwoMcH'
    'JvcG9zYWxfYWdlGAYgASgLMhwuZ29vZ2xlLnByb3RvYnVmLlVJbnQzMlZhbHVlUgtwcm9wb3Nh'
    'bEFnZUIOCgxfZGVjbGFyYXRpb24=');

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
    {'1': 'sidechain_number', '3': 1, '4': 1, '5': 11, '6': '.google.protobuf.UInt32Value', '10': 'sidechainNumber'},
    {'1': 'description', '3': 2, '4': 1, '5': 11, '6': '.cusf.common.v1.ConsensusHex', '10': 'description'},
    {'1': 'vote_count', '3': 3, '4': 1, '5': 11, '6': '.google.protobuf.UInt32Value', '10': 'voteCount'},
    {'1': 'proposal_height', '3': 4, '4': 1, '5': 11, '6': '.google.protobuf.UInt32Value', '10': 'proposalHeight'},
    {'1': 'activation_height', '3': 5, '4': 1, '5': 11, '6': '.google.protobuf.UInt32Value', '10': 'activationHeight'},
    {'1': 'declaration', '3': 6, '4': 1, '5': 11, '6': '.cusf.mainchain.v1.SidechainDeclaration', '9': 0, '10': 'declaration', '17': true},
  ],
  '8': [
    {'1': '_declaration'},
  ],
};

/// Descriptor for `GetSidechainsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSidechainsResponseDescriptor = $convert.base64Decode(
    'ChVHZXRTaWRlY2hhaW5zUmVzcG9uc2USVgoKc2lkZWNoYWlucxgBIAMoCzI2LmN1c2YubWFpbm'
    'NoYWluLnYxLkdldFNpZGVjaGFpbnNSZXNwb25zZS5TaWRlY2hhaW5JbmZvUgpzaWRlY2hhaW5z'
    'GscDCg1TaWRlY2hhaW5JbmZvEkcKEHNpZGVjaGFpbl9udW1iZXIYASABKAsyHC5nb29nbGUucH'
    'JvdG9idWYuVUludDMyVmFsdWVSD3NpZGVjaGFpbk51bWJlchI+CgtkZXNjcmlwdGlvbhgCIAEo'
    'CzIcLmN1c2YuY29tbW9uLnYxLkNvbnNlbnN1c0hleFILZGVzY3JpcHRpb24SOwoKdm90ZV9jb3'
    'VudBgDIAEoCzIcLmdvb2dsZS5wcm90b2J1Zi5VSW50MzJWYWx1ZVIJdm90ZUNvdW50EkUKD3By'
    'b3Bvc2FsX2hlaWdodBgEIAEoCzIcLmdvb2dsZS5wcm90b2J1Zi5VSW50MzJWYWx1ZVIOcHJvcG'
    '9zYWxIZWlnaHQSSQoRYWN0aXZhdGlvbl9oZWlnaHQYBSABKAsyHC5nb29nbGUucHJvdG9idWYu'
    'VUludDMyVmFsdWVSEGFjdGl2YXRpb25IZWlnaHQSTgoLZGVjbGFyYXRpb24YBiABKAsyJy5jdX'
    'NmLm1haW5jaGFpbi52MS5TaWRlY2hhaW5EZWNsYXJhdGlvbkgAUgtkZWNsYXJhdGlvbogBAUIO'
    'CgxfZGVjbGFyYXRpb24=');

@$core.Deprecated('Use getTwoWayPegDataRequestDescriptor instead')
const GetTwoWayPegDataRequest$json = {
  '1': 'GetTwoWayPegDataRequest',
  '2': [
    {'1': 'sidechain_id', '3': 1, '4': 1, '5': 11, '6': '.google.protobuf.UInt32Value', '10': 'sidechainId'},
    {'1': 'start_block_hash', '3': 2, '4': 1, '5': 11, '6': '.cusf.common.v1.ReverseHex', '9': 0, '10': 'startBlockHash', '17': true},
    {'1': 'end_block_hash', '3': 3, '4': 1, '5': 11, '6': '.cusf.common.v1.ReverseHex', '10': 'endBlockHash'},
  ],
  '8': [
    {'1': '_start_block_hash'},
  ],
};

/// Descriptor for `GetTwoWayPegDataRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTwoWayPegDataRequestDescriptor = $convert.base64Decode(
    'ChdHZXRUd29XYXlQZWdEYXRhUmVxdWVzdBI/CgxzaWRlY2hhaW5faWQYASABKAsyHC5nb29nbG'
    'UucHJvdG9idWYuVUludDMyVmFsdWVSC3NpZGVjaGFpbklkEkkKEHN0YXJ0X2Jsb2NrX2hhc2gY'
    'AiABKAsyGi5jdXNmLmNvbW1vbi52MS5SZXZlcnNlSGV4SABSDnN0YXJ0QmxvY2tIYXNoiAEBEk'
    'AKDmVuZF9ibG9ja19oYXNoGAMgASgLMhouY3VzZi5jb21tb24udjEuUmV2ZXJzZUhleFIMZW5k'
    'QmxvY2tIYXNoQhMKEV9zdGFydF9ibG9ja19oYXNo');

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
    {'1': 'block_hash', '3': 1, '4': 1, '5': 11, '6': '.cusf.common.v1.ReverseHex', '10': 'blockHash'},
  ],
};

/// Descriptor for `SubscribeEventsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List subscribeEventsResponseDescriptor = $convert.base64Decode(
    'ChdTdWJzY3JpYmVFdmVudHNSZXNwb25zZRJGCgVldmVudBgBIAEoCzIwLmN1c2YubWFpbmNoYW'
    'luLnYxLlN1YnNjcmliZUV2ZW50c1Jlc3BvbnNlLkV2ZW50UgVldmVudBrGAwoFRXZlbnQSZAoN'
    'Y29ubmVjdF9ibG9jaxgBIAEoCzI9LmN1c2YubWFpbmNoYWluLnYxLlN1YnNjcmliZUV2ZW50c1'
    'Jlc3BvbnNlLkV2ZW50LkNvbm5lY3RCbG9ja0gAUgxjb25uZWN0QmxvY2sSbQoQZGlzY29ubmVj'
    'dF9ibG9jaxgCIAEoCzJALmN1c2YubWFpbmNoYWluLnYxLlN1YnNjcmliZUV2ZW50c1Jlc3Bvbn'
    'NlLkV2ZW50LkRpc2Nvbm5lY3RCbG9ja0gAUg9kaXNjb25uZWN0QmxvY2sakAEKDENvbm5lY3RC'
    'bG9jaxJDCgtoZWFkZXJfaW5mbxgBIAEoCzIiLmN1c2YubWFpbmNoYWluLnYxLkJsb2NrSGVhZG'
    'VySW5mb1IKaGVhZGVySW5mbxI7CgpibG9ja19pbmZvGAIgASgLMhwuY3VzZi5tYWluY2hhaW4u'
    'djEuQmxvY2tJbmZvUglibG9ja0luZm8aTAoPRGlzY29ubmVjdEJsb2NrEjkKCmJsb2NrX2hhc2'
    'gYASABKAsyGi5jdXNmLmNvbW1vbi52MS5SZXZlcnNlSGV4UglibG9ja0hhc2hCBwoFZXZlbnQ=');

const $core.Map<$core.String, $core.dynamic> ValidatorServiceBase$json = {
  '1': 'ValidatorService',
  '2': [
    {'1': 'GetBlockHeaderInfo', '2': '.cusf.mainchain.v1.GetBlockHeaderInfoRequest', '3': '.cusf.mainchain.v1.GetBlockHeaderInfoResponse'},
    {'1': 'GetBlockInfo', '2': '.cusf.mainchain.v1.GetBlockInfoRequest', '3': '.cusf.mainchain.v1.GetBlockInfoResponse'},
    {'1': 'GetBmmHStarCommitment', '2': '.cusf.mainchain.v1.GetBmmHStarCommitmentRequest', '3': '.cusf.mainchain.v1.GetBmmHStarCommitmentResponse'},
    {'1': 'GetChainInfo', '2': '.cusf.mainchain.v1.GetChainInfoRequest', '3': '.cusf.mainchain.v1.GetChainInfoResponse'},
    {'1': 'GetChainTip', '2': '.cusf.mainchain.v1.GetChainTipRequest', '3': '.cusf.mainchain.v1.GetChainTipResponse'},
    {'1': 'GetCoinbasePSBT', '2': '.cusf.mainchain.v1.GetCoinbasePSBTRequest', '3': '.cusf.mainchain.v1.GetCoinbasePSBTResponse'},
    {'1': 'GetCtip', '2': '.cusf.mainchain.v1.GetCtipRequest', '3': '.cusf.mainchain.v1.GetCtipResponse'},
    {'1': 'GetSidechainProposals', '2': '.cusf.mainchain.v1.GetSidechainProposalsRequest', '3': '.cusf.mainchain.v1.GetSidechainProposalsResponse'},
    {'1': 'GetSidechains', '2': '.cusf.mainchain.v1.GetSidechainsRequest', '3': '.cusf.mainchain.v1.GetSidechainsResponse'},
    {'1': 'GetTwoWayPegData', '2': '.cusf.mainchain.v1.GetTwoWayPegDataRequest', '3': '.cusf.mainchain.v1.GetTwoWayPegDataResponse'},
    {'1': 'SubscribeEvents', '2': '.cusf.mainchain.v1.SubscribeEventsRequest', '3': '.cusf.mainchain.v1.SubscribeEventsResponse', '6': true},
  ],
};

@$core.Deprecated('Use validatorServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> ValidatorServiceBase$messageJson = {
  '.cusf.mainchain.v1.GetBlockHeaderInfoRequest': GetBlockHeaderInfoRequest$json,
  '.cusf.common.v1.ReverseHex': $1.ReverseHex$json,
  '.google.protobuf.StringValue': $0.StringValue$json,
  '.cusf.mainchain.v1.GetBlockHeaderInfoResponse': GetBlockHeaderInfoResponse$json,
  '.cusf.mainchain.v1.BlockHeaderInfo': BlockHeaderInfo$json,
  '.cusf.common.v1.ConsensusHex': $1.ConsensusHex$json,
  '.cusf.mainchain.v1.GetBlockInfoRequest': GetBlockInfoRequest$json,
  '.google.protobuf.UInt32Value': $0.UInt32Value$json,
  '.cusf.mainchain.v1.GetBlockInfoResponse': GetBlockInfoResponse$json,
  '.cusf.mainchain.v1.BlockInfo': BlockInfo$json,
  '.cusf.mainchain.v1.BlockInfo.Event': BlockInfo_Event$json,
  '.cusf.mainchain.v1.Deposit': Deposit$json,
  '.google.protobuf.UInt64Value': $0.UInt64Value$json,
  '.cusf.mainchain.v1.OutPoint': $3.OutPoint$json,
  '.cusf.mainchain.v1.Deposit.Output': Deposit_Output$json,
  '.cusf.common.v1.Hex': $1.Hex$json,
  '.cusf.mainchain.v1.WithdrawalBundleEvent': WithdrawalBundleEvent$json,
  '.cusf.mainchain.v1.WithdrawalBundleEvent.Event': WithdrawalBundleEvent_Event$json,
  '.cusf.mainchain.v1.WithdrawalBundleEvent.Event.Failed': WithdrawalBundleEvent_Event_Failed$json,
  '.cusf.mainchain.v1.WithdrawalBundleEvent.Event.Succeeded': WithdrawalBundleEvent_Event_Succeeded$json,
  '.cusf.mainchain.v1.WithdrawalBundleEvent.Event.Submitted': WithdrawalBundleEvent_Event_Submitted$json,
  '.cusf.mainchain.v1.GetBmmHStarCommitmentRequest': GetBmmHStarCommitmentRequest$json,
  '.cusf.mainchain.v1.GetBmmHStarCommitmentResponse': GetBmmHStarCommitmentResponse$json,
  '.cusf.mainchain.v1.GetBmmHStarCommitmentResponse.BlockNotFoundError': GetBmmHStarCommitmentResponse_BlockNotFoundError$json,
  '.cusf.mainchain.v1.GetBmmHStarCommitmentResponse.Commitment': GetBmmHStarCommitmentResponse_Commitment$json,
  '.cusf.mainchain.v1.GetChainInfoRequest': GetChainInfoRequest$json,
  '.cusf.mainchain.v1.GetChainInfoResponse': GetChainInfoResponse$json,
  '.cusf.mainchain.v1.GetChainTipRequest': GetChainTipRequest$json,
  '.cusf.mainchain.v1.GetChainTipResponse': GetChainTipResponse$json,
  '.cusf.mainchain.v1.GetCoinbasePSBTRequest': GetCoinbasePSBTRequest$json,
  '.cusf.mainchain.v1.GetCoinbasePSBTRequest.ProposeSidechain': GetCoinbasePSBTRequest_ProposeSidechain$json,
  '.cusf.mainchain.v1.GetCoinbasePSBTRequest.AckSidechain': GetCoinbasePSBTRequest_AckSidechain$json,
  '.cusf.mainchain.v1.GetCoinbasePSBTRequest.ProposeBundle': GetCoinbasePSBTRequest_ProposeBundle$json,
  '.cusf.mainchain.v1.GetCoinbasePSBTRequest.AckBundles': GetCoinbasePSBTRequest_AckBundles$json,
  '.cusf.mainchain.v1.GetCoinbasePSBTRequest.AckBundles.RepeatPrevious': GetCoinbasePSBTRequest_AckBundles_RepeatPrevious$json,
  '.cusf.mainchain.v1.GetCoinbasePSBTRequest.AckBundles.LeadingBy50': GetCoinbasePSBTRequest_AckBundles_LeadingBy50$json,
  '.cusf.mainchain.v1.GetCoinbasePSBTRequest.AckBundles.Upvotes': GetCoinbasePSBTRequest_AckBundles_Upvotes$json,
  '.cusf.mainchain.v1.GetCoinbasePSBTResponse': GetCoinbasePSBTResponse$json,
  '.cusf.mainchain.v1.GetCtipRequest': GetCtipRequest$json,
  '.cusf.mainchain.v1.GetCtipResponse': GetCtipResponse$json,
  '.cusf.mainchain.v1.GetCtipResponse.Ctip': GetCtipResponse_Ctip$json,
  '.cusf.mainchain.v1.GetSidechainProposalsRequest': GetSidechainProposalsRequest$json,
  '.cusf.mainchain.v1.GetSidechainProposalsResponse': GetSidechainProposalsResponse$json,
  '.cusf.mainchain.v1.GetSidechainProposalsResponse.SidechainProposal': GetSidechainProposalsResponse_SidechainProposal$json,
  '.cusf.mainchain.v1.SidechainDeclaration': $3.SidechainDeclaration$json,
  '.cusf.mainchain.v1.SidechainDeclaration.V0': $3.SidechainDeclaration_V0$json,
  '.cusf.mainchain.v1.GetSidechainsRequest': GetSidechainsRequest$json,
  '.cusf.mainchain.v1.GetSidechainsResponse': GetSidechainsResponse$json,
  '.cusf.mainchain.v1.GetSidechainsResponse.SidechainInfo': GetSidechainsResponse_SidechainInfo$json,
  '.cusf.mainchain.v1.GetTwoWayPegDataRequest': GetTwoWayPegDataRequest$json,
  '.cusf.mainchain.v1.GetTwoWayPegDataResponse': GetTwoWayPegDataResponse$json,
  '.cusf.mainchain.v1.GetTwoWayPegDataResponse.ResponseItem': GetTwoWayPegDataResponse_ResponseItem$json,
  '.cusf.mainchain.v1.SubscribeEventsRequest': SubscribeEventsRequest$json,
  '.cusf.mainchain.v1.SubscribeEventsResponse': SubscribeEventsResponse$json,
  '.cusf.mainchain.v1.SubscribeEventsResponse.Event': SubscribeEventsResponse_Event$json,
  '.cusf.mainchain.v1.SubscribeEventsResponse.Event.ConnectBlock': SubscribeEventsResponse_Event_ConnectBlock$json,
  '.cusf.mainchain.v1.SubscribeEventsResponse.Event.DisconnectBlock': SubscribeEventsResponse_Event_DisconnectBlock$json,
};

/// Descriptor for `ValidatorService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List validatorServiceDescriptor = $convert.base64Decode(
    'ChBWYWxpZGF0b3JTZXJ2aWNlEnEKEkdldEJsb2NrSGVhZGVySW5mbxIsLmN1c2YubWFpbmNoYW'
    'luLnYxLkdldEJsb2NrSGVhZGVySW5mb1JlcXVlc3QaLS5jdXNmLm1haW5jaGFpbi52MS5HZXRC'
    'bG9ja0hlYWRlckluZm9SZXNwb25zZRJfCgxHZXRCbG9ja0luZm8SJi5jdXNmLm1haW5jaGFpbi'
    '52MS5HZXRCbG9ja0luZm9SZXF1ZXN0GicuY3VzZi5tYWluY2hhaW4udjEuR2V0QmxvY2tJbmZv'
    'UmVzcG9uc2USegoVR2V0Qm1tSFN0YXJDb21taXRtZW50Ei8uY3VzZi5tYWluY2hhaW4udjEuR2'
    'V0Qm1tSFN0YXJDb21taXRtZW50UmVxdWVzdBowLmN1c2YubWFpbmNoYWluLnYxLkdldEJtbUhT'
    'dGFyQ29tbWl0bWVudFJlc3BvbnNlEl8KDEdldENoYWluSW5mbxImLmN1c2YubWFpbmNoYWluLn'
    'YxLkdldENoYWluSW5mb1JlcXVlc3QaJy5jdXNmLm1haW5jaGFpbi52MS5HZXRDaGFpbkluZm9S'
    'ZXNwb25zZRJcCgtHZXRDaGFpblRpcBIlLmN1c2YubWFpbmNoYWluLnYxLkdldENoYWluVGlwUm'
    'VxdWVzdBomLmN1c2YubWFpbmNoYWluLnYxLkdldENoYWluVGlwUmVzcG9uc2USaAoPR2V0Q29p'
    'bmJhc2VQU0JUEikuY3VzZi5tYWluY2hhaW4udjEuR2V0Q29pbmJhc2VQU0JUUmVxdWVzdBoqLm'
    'N1c2YubWFpbmNoYWluLnYxLkdldENvaW5iYXNlUFNCVFJlc3BvbnNlElAKB0dldEN0aXASIS5j'
    'dXNmLm1haW5jaGFpbi52MS5HZXRDdGlwUmVxdWVzdBoiLmN1c2YubWFpbmNoYWluLnYxLkdldE'
    'N0aXBSZXNwb25zZRJ6ChVHZXRTaWRlY2hhaW5Qcm9wb3NhbHMSLy5jdXNmLm1haW5jaGFpbi52'
    'MS5HZXRTaWRlY2hhaW5Qcm9wb3NhbHNSZXF1ZXN0GjAuY3VzZi5tYWluY2hhaW4udjEuR2V0U2'
    'lkZWNoYWluUHJvcG9zYWxzUmVzcG9uc2USYgoNR2V0U2lkZWNoYWlucxInLmN1c2YubWFpbmNo'
    'YWluLnYxLkdldFNpZGVjaGFpbnNSZXF1ZXN0GiguY3VzZi5tYWluY2hhaW4udjEuR2V0U2lkZW'
    'NoYWluc1Jlc3BvbnNlEmsKEEdldFR3b1dheVBlZ0RhdGESKi5jdXNmLm1haW5jaGFpbi52MS5H'
    'ZXRUd29XYXlQZWdEYXRhUmVxdWVzdBorLmN1c2YubWFpbmNoYWluLnYxLkdldFR3b1dheVBlZ0'
    'RhdGFSZXNwb25zZRJqCg9TdWJzY3JpYmVFdmVudHMSKS5jdXNmLm1haW5jaGFpbi52MS5TdWJz'
    'Y3JpYmVFdmVudHNSZXF1ZXN0GiouY3VzZi5tYWluY2hhaW4udjEuU3Vic2NyaWJlRXZlbnRzUm'
    'VzcG9uc2UwAQ==');

