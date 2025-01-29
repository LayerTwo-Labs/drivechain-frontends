//
//  Generated code. Do not modify.
//  source: cusf/sidechain/v1/sidechain.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use sequenceIdDescriptor instead')
const SequenceId$json = {
  '1': 'SequenceId',
  '2': [
    {'1': 'sequence_id', '3': 1, '4': 1, '5': 4, '10': 'sequenceId'},
  ],
};

/// Descriptor for `SequenceId`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sequenceIdDescriptor = $convert.base64Decode(
    'CgpTZXF1ZW5jZUlkEh8KC3NlcXVlbmNlX2lkGAEgASgEUgpzZXF1ZW5jZUlk');

@$core.Deprecated('Use blockHeaderInfoDescriptor instead')
const BlockHeaderInfo$json = {
  '1': 'BlockHeaderInfo',
  '2': [
    {'1': 'block_hash', '3': 1, '4': 1, '5': 12, '10': 'blockHash'},
    {'1': 'prev_block_hash', '3': 2, '4': 1, '5': 12, '10': 'prevBlockHash'},
    {'1': 'prev_main_block_hash', '3': 3, '4': 1, '5': 12, '10': 'prevMainBlockHash'},
    {'1': 'height', '3': 4, '4': 1, '5': 13, '10': 'height'},
  ],
};

/// Descriptor for `BlockHeaderInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List blockHeaderInfoDescriptor = $convert.base64Decode(
    'Cg9CbG9ja0hlYWRlckluZm8SHQoKYmxvY2tfaGFzaBgBIAEoDFIJYmxvY2tIYXNoEiYKD3ByZX'
    'ZfYmxvY2tfaGFzaBgCIAEoDFINcHJldkJsb2NrSGFzaBIvChRwcmV2X21haW5fYmxvY2tfaGFz'
    'aBgDIAEoDFIRcHJldk1haW5CbG9ja0hhc2gSFgoGaGVpZ2h0GAQgASgNUgZoZWlnaHQ=');

@$core.Deprecated('Use blockInfoDescriptor instead')
const BlockInfo$json = {
  '1': 'BlockInfo',
};

/// Descriptor for `BlockInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List blockInfoDescriptor = $convert.base64Decode(
    'CglCbG9ja0luZm8=');

@$core.Deprecated('Use getMempoolTxsRequestDescriptor instead')
const GetMempoolTxsRequest$json = {
  '1': 'GetMempoolTxsRequest',
};

/// Descriptor for `GetMempoolTxsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMempoolTxsRequestDescriptor = $convert.base64Decode(
    'ChRHZXRNZW1wb29sVHhzUmVxdWVzdA==');

@$core.Deprecated('Use getMempoolTxsResponseDescriptor instead')
const GetMempoolTxsResponse$json = {
  '1': 'GetMempoolTxsResponse',
  '2': [
    {'1': 'sequence_id', '3': 1, '4': 1, '5': 11, '6': '.cusf.sidechain.v1.SequenceId', '10': 'sequenceId'},
  ],
};

/// Descriptor for `GetMempoolTxsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMempoolTxsResponseDescriptor = $convert.base64Decode(
    'ChVHZXRNZW1wb29sVHhzUmVzcG9uc2USPgoLc2VxdWVuY2VfaWQYASABKAsyHS5jdXNmLnNpZG'
    'VjaGFpbi52MS5TZXF1ZW5jZUlkUgpzZXF1ZW5jZUlk');

@$core.Deprecated('Use getUtxosRequestDescriptor instead')
const GetUtxosRequest$json = {
  '1': 'GetUtxosRequest',
};

/// Descriptor for `GetUtxosRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getUtxosRequestDescriptor = $convert.base64Decode(
    'Cg9HZXRVdHhvc1JlcXVlc3Q=');

@$core.Deprecated('Use getUtxosResponseDescriptor instead')
const GetUtxosResponse$json = {
  '1': 'GetUtxosResponse',
};

/// Descriptor for `GetUtxosResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getUtxosResponseDescriptor = $convert.base64Decode(
    'ChBHZXRVdHhvc1Jlc3BvbnNl');

@$core.Deprecated('Use submitTransactionRequestDescriptor instead')
const SubmitTransactionRequest$json = {
  '1': 'SubmitTransactionRequest',
  '2': [
    {'1': 'transaction', '3': 1, '4': 1, '5': 12, '10': 'transaction'},
  ],
};

/// Descriptor for `SubmitTransactionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List submitTransactionRequestDescriptor = $convert.base64Decode(
    'ChhTdWJtaXRUcmFuc2FjdGlvblJlcXVlc3QSIAoLdHJhbnNhY3Rpb24YASABKAxSC3RyYW5zYW'
    'N0aW9u');

@$core.Deprecated('Use submitTransactionResponseDescriptor instead')
const SubmitTransactionResponse$json = {
  '1': 'SubmitTransactionResponse',
};

/// Descriptor for `SubmitTransactionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List submitTransactionResponseDescriptor = $convert.base64Decode(
    'ChlTdWJtaXRUcmFuc2FjdGlvblJlc3BvbnNl');

@$core.Deprecated('Use subscribeEventsRequestDescriptor instead')
const SubscribeEventsRequest$json = {
  '1': 'SubscribeEventsRequest',
};

/// Descriptor for `SubscribeEventsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List subscribeEventsRequestDescriptor = $convert.base64Decode(
    'ChZTdWJzY3JpYmVFdmVudHNSZXF1ZXN0');

@$core.Deprecated('Use subscribeEventsResponseDescriptor instead')
const SubscribeEventsResponse$json = {
  '1': 'SubscribeEventsResponse',
  '2': [
    {'1': 'sequence_id', '3': 1, '4': 1, '5': 11, '6': '.cusf.sidechain.v1.SequenceId', '10': 'sequenceId'},
    {'1': 'event', '3': 2, '4': 1, '5': 11, '6': '.cusf.sidechain.v1.SubscribeEventsResponse.Event', '10': 'event'},
  ],
  '3': [SubscribeEventsResponse_Event$json],
};

@$core.Deprecated('Use subscribeEventsResponseDescriptor instead')
const SubscribeEventsResponse_Event$json = {
  '1': 'Event',
  '2': [
    {'1': 'connect_block', '3': 1, '4': 1, '5': 11, '6': '.cusf.sidechain.v1.SubscribeEventsResponse.Event.ConnectBlock', '9': 0, '10': 'connectBlock'},
    {'1': 'disconnect_block', '3': 2, '4': 1, '5': 11, '6': '.cusf.sidechain.v1.SubscribeEventsResponse.Event.DisconnectBlock', '9': 0, '10': 'disconnectBlock'},
    {'1': 'mempool_tx_added', '3': 3, '4': 1, '5': 11, '6': '.cusf.sidechain.v1.SubscribeEventsResponse.Event.MempoolTxAdded', '9': 0, '10': 'mempoolTxAdded'},
    {'1': 'mempool_tx_removed', '3': 4, '4': 1, '5': 11, '6': '.cusf.sidechain.v1.SubscribeEventsResponse.Event.MempoolTxRemoved', '9': 0, '10': 'mempoolTxRemoved'},
  ],
  '3': [SubscribeEventsResponse_Event_ConnectBlock$json, SubscribeEventsResponse_Event_DisconnectBlock$json, SubscribeEventsResponse_Event_MempoolTxAdded$json, SubscribeEventsResponse_Event_MempoolTxRemoved$json],
  '8': [
    {'1': 'event'},
  ],
};

@$core.Deprecated('Use subscribeEventsResponseDescriptor instead')
const SubscribeEventsResponse_Event_ConnectBlock$json = {
  '1': 'ConnectBlock',
  '2': [
    {'1': 'header_info', '3': 1, '4': 1, '5': 11, '6': '.cusf.sidechain.v1.BlockHeaderInfo', '10': 'headerInfo'},
    {'1': 'block_info', '3': 2, '4': 1, '5': 11, '6': '.cusf.sidechain.v1.BlockInfo', '10': 'blockInfo'},
  ],
};

@$core.Deprecated('Use subscribeEventsResponseDescriptor instead')
const SubscribeEventsResponse_Event_DisconnectBlock$json = {
  '1': 'DisconnectBlock',
  '2': [
    {'1': 'block_hash', '3': 1, '4': 1, '5': 12, '10': 'blockHash'},
  ],
};

@$core.Deprecated('Use subscribeEventsResponseDescriptor instead')
const SubscribeEventsResponse_Event_MempoolTxAdded$json = {
  '1': 'MempoolTxAdded',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 12, '10': 'txid'},
  ],
};

@$core.Deprecated('Use subscribeEventsResponseDescriptor instead')
const SubscribeEventsResponse_Event_MempoolTxRemoved$json = {
  '1': 'MempoolTxRemoved',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 12, '10': 'txid'},
  ],
};

/// Descriptor for `SubscribeEventsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List subscribeEventsResponseDescriptor = $convert.base64Decode(
    'ChdTdWJzY3JpYmVFdmVudHNSZXNwb25zZRI+CgtzZXF1ZW5jZV9pZBgBIAEoCzIdLmN1c2Yuc2'
    'lkZWNoYWluLnYxLlNlcXVlbmNlSWRSCnNlcXVlbmNlSWQSRgoFZXZlbnQYAiABKAsyMC5jdXNm'
    'LnNpZGVjaGFpbi52MS5TdWJzY3JpYmVFdmVudHNSZXNwb25zZS5FdmVudFIFZXZlbnQa2AUKBU'
    'V2ZW50EmQKDWNvbm5lY3RfYmxvY2sYASABKAsyPS5jdXNmLnNpZGVjaGFpbi52MS5TdWJzY3Jp'
    'YmVFdmVudHNSZXNwb25zZS5FdmVudC5Db25uZWN0QmxvY2tIAFIMY29ubmVjdEJsb2NrEm0KEG'
    'Rpc2Nvbm5lY3RfYmxvY2sYAiABKAsyQC5jdXNmLnNpZGVjaGFpbi52MS5TdWJzY3JpYmVFdmVu'
    'dHNSZXNwb25zZS5FdmVudC5EaXNjb25uZWN0QmxvY2tIAFIPZGlzY29ubmVjdEJsb2NrEmsKEG'
    '1lbXBvb2xfdHhfYWRkZWQYAyABKAsyPy5jdXNmLnNpZGVjaGFpbi52MS5TdWJzY3JpYmVFdmVu'
    'dHNSZXNwb25zZS5FdmVudC5NZW1wb29sVHhBZGRlZEgAUg5tZW1wb29sVHhBZGRlZBJxChJtZW'
    '1wb29sX3R4X3JlbW92ZWQYBCABKAsyQS5jdXNmLnNpZGVjaGFpbi52MS5TdWJzY3JpYmVFdmVu'
    'dHNSZXNwb25zZS5FdmVudC5NZW1wb29sVHhSZW1vdmVkSABSEG1lbXBvb2xUeFJlbW92ZWQakA'
    'EKDENvbm5lY3RCbG9jaxJDCgtoZWFkZXJfaW5mbxgBIAEoCzIiLmN1c2Yuc2lkZWNoYWluLnYx'
    'LkJsb2NrSGVhZGVySW5mb1IKaGVhZGVySW5mbxI7CgpibG9ja19pbmZvGAIgASgLMhwuY3VzZi'
    '5zaWRlY2hhaW4udjEuQmxvY2tJbmZvUglibG9ja0luZm8aMAoPRGlzY29ubmVjdEJsb2NrEh0K'
    'CmJsb2NrX2hhc2gYASABKAxSCWJsb2NrSGFzaBokCg5NZW1wb29sVHhBZGRlZBISCgR0eGlkGA'
    'EgASgMUgR0eGlkGiYKEE1lbXBvb2xUeFJlbW92ZWQSEgoEdHhpZBgBIAEoDFIEdHhpZEIHCgVl'
    'dmVudA==');

