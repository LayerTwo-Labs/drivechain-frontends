//
//  Generated code. Do not modify.
//  source: bitwindowd/v1/bitwindowd.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

import '../../google/protobuf/empty.pbjson.dart' as $1;
import '../../google/protobuf/timestamp.pbjson.dart' as $0;

@$core.Deprecated('Use directionDescriptor instead')
const Direction$json = {
  '1': 'Direction',
  '2': [
    {'1': 'DIRECTION_UNSPECIFIED', '2': 0},
    {'1': 'DIRECTION_SEND', '2': 1},
    {'1': 'DIRECTION_RECEIVE', '2': 2},
  ],
};

/// Descriptor for `Direction`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List directionDescriptor = $convert.base64Decode(
    'CglEaXJlY3Rpb24SGQoVRElSRUNUSU9OX1VOU1BFQ0lGSUVEEAASEgoORElSRUNUSU9OX1NFTk'
    'QQARIVChFESVJFQ1RJT05fUkVDRUlWRRAC');

@$core.Deprecated('Use createDenialRequestDescriptor instead')
const CreateDenialRequest$json = {
  '1': 'CreateDenialRequest',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'vout', '3': 2, '4': 1, '5': 13, '10': 'vout'},
    {'1': 'delay_seconds', '3': 3, '4': 1, '5': 5, '10': 'delaySeconds'},
    {'1': 'num_hops', '3': 4, '4': 1, '5': 5, '10': 'numHops'},
  ],
};

/// Descriptor for `CreateDenialRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createDenialRequestDescriptor = $convert.base64Decode(
    'ChNDcmVhdGVEZW5pYWxSZXF1ZXN0EhIKBHR4aWQYASABKAlSBHR4aWQSEgoEdm91dBgCIAEoDV'
    'IEdm91dBIjCg1kZWxheV9zZWNvbmRzGAMgASgFUgxkZWxheVNlY29uZHMSGQoIbnVtX2hvcHMY'
    'BCABKAVSB251bUhvcHM=');

@$core.Deprecated('Use denialInfoDescriptor instead')
const DenialInfo$json = {
  '1': 'DenialInfo',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'num_hops', '3': 2, '4': 1, '5': 5, '10': 'numHops'},
    {'1': 'delay_seconds', '3': 3, '4': 1, '5': 5, '10': 'delaySeconds'},
    {'1': 'create_time', '3': 4, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'createTime'},
    {'1': 'cancel_time', '3': 5, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '9': 0, '10': 'cancelTime', '17': true},
    {'1': 'cancel_reason', '3': 6, '4': 1, '5': 9, '9': 1, '10': 'cancelReason', '17': true},
    {'1': 'next_execution_time', '3': 7, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '9': 2, '10': 'nextExecutionTime', '17': true},
    {'1': 'executions', '3': 8, '4': 3, '5': 11, '6': '.bitwindowd.v1.ExecutedDenial', '10': 'executions'},
    {'1': 'hops_completed', '3': 9, '4': 1, '5': 13, '10': 'hopsCompleted'},
    {'1': 'is_change', '3': 10, '4': 1, '5': 8, '10': 'isChange'},
  ],
  '8': [
    {'1': '_cancel_time'},
    {'1': '_cancel_reason'},
    {'1': '_next_execution_time'},
  ],
};

/// Descriptor for `DenialInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List denialInfoDescriptor = $convert.base64Decode(
    'CgpEZW5pYWxJbmZvEg4KAmlkGAEgASgDUgJpZBIZCghudW1faG9wcxgCIAEoBVIHbnVtSG9wcx'
    'IjCg1kZWxheV9zZWNvbmRzGAMgASgFUgxkZWxheVNlY29uZHMSOwoLY3JlYXRlX3RpbWUYBCAB'
    'KAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgpjcmVhdGVUaW1lEkAKC2NhbmNlbF90aW'
    '1lGAUgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcEgAUgpjYW5jZWxUaW1liAEBEigK'
    'DWNhbmNlbF9yZWFzb24YBiABKAlIAVIMY2FuY2VsUmVhc29uiAEBEk8KE25leHRfZXhlY3V0aW'
    '9uX3RpbWUYByABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wSAJSEW5leHRFeGVjdXRp'
    'b25UaW1liAEBEj0KCmV4ZWN1dGlvbnMYCCADKAsyHS5iaXR3aW5kb3dkLnYxLkV4ZWN1dGVkRG'
    'VuaWFsUgpleGVjdXRpb25zEiUKDmhvcHNfY29tcGxldGVkGAkgASgNUg1ob3BzQ29tcGxldGVk'
    'EhsKCWlzX2NoYW5nZRgKIAEoCFIIaXNDaGFuZ2VCDgoMX2NhbmNlbF90aW1lQhAKDl9jYW5jZW'
    'xfcmVhc29uQhYKFF9uZXh0X2V4ZWN1dGlvbl90aW1l');

@$core.Deprecated('Use executedDenialDescriptor instead')
const ExecutedDenial$json = {
  '1': 'ExecutedDenial',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'denial_id', '3': 2, '4': 1, '5': 3, '10': 'denialId'},
    {'1': 'from_txid', '3': 3, '4': 1, '5': 9, '10': 'fromTxid'},
    {'1': 'from_vout', '3': 4, '4': 1, '5': 13, '10': 'fromVout'},
    {'1': 'to_txid', '3': 5, '4': 1, '5': 9, '10': 'toTxid'},
    {'1': 'create_time', '3': 6, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'createTime'},
  ],
};

/// Descriptor for `ExecutedDenial`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List executedDenialDescriptor = $convert.base64Decode(
    'Cg5FeGVjdXRlZERlbmlhbBIOCgJpZBgBIAEoA1ICaWQSGwoJZGVuaWFsX2lkGAIgASgDUghkZW'
    '5pYWxJZBIbCglmcm9tX3R4aWQYAyABKAlSCGZyb21UeGlkEhsKCWZyb21fdm91dBgEIAEoDVII'
    'ZnJvbVZvdXQSFwoHdG9fdHhpZBgFIAEoCVIGdG9UeGlkEjsKC2NyZWF0ZV90aW1lGAYgASgLMh'
    'ouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIKY3JlYXRlVGltZQ==');

@$core.Deprecated('Use cancelDenialRequestDescriptor instead')
const CancelDenialRequest$json = {
  '1': 'CancelDenialRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
  ],
};

/// Descriptor for `CancelDenialRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cancelDenialRequestDescriptor = $convert.base64Decode(
    'ChNDYW5jZWxEZW5pYWxSZXF1ZXN0Eg4KAmlkGAEgASgDUgJpZA==');

@$core.Deprecated('Use createAddressBookEntryRequestDescriptor instead')
const CreateAddressBookEntryRequest$json = {
  '1': 'CreateAddressBookEntryRequest',
  '2': [
    {'1': 'label', '3': 1, '4': 1, '5': 9, '10': 'label'},
    {'1': 'address', '3': 2, '4': 1, '5': 9, '10': 'address'},
    {'1': 'direction', '3': 3, '4': 1, '5': 14, '6': '.bitwindowd.v1.Direction', '10': 'direction'},
  ],
};

/// Descriptor for `CreateAddressBookEntryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createAddressBookEntryRequestDescriptor = $convert.base64Decode(
    'Ch1DcmVhdGVBZGRyZXNzQm9va0VudHJ5UmVxdWVzdBIUCgVsYWJlbBgBIAEoCVIFbGFiZWwSGA'
    'oHYWRkcmVzcxgCIAEoCVIHYWRkcmVzcxI2CglkaXJlY3Rpb24YAyABKA4yGC5iaXR3aW5kb3dk'
    'LnYxLkRpcmVjdGlvblIJZGlyZWN0aW9u');

@$core.Deprecated('Use createAddressBookEntryResponseDescriptor instead')
const CreateAddressBookEntryResponse$json = {
  '1': 'CreateAddressBookEntryResponse',
  '2': [
    {'1': 'entry', '3': 1, '4': 1, '5': 11, '6': '.bitwindowd.v1.AddressBookEntry', '10': 'entry'},
  ],
};

/// Descriptor for `CreateAddressBookEntryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createAddressBookEntryResponseDescriptor = $convert.base64Decode(
    'Ch5DcmVhdGVBZGRyZXNzQm9va0VudHJ5UmVzcG9uc2USNQoFZW50cnkYASABKAsyHy5iaXR3aW'
    '5kb3dkLnYxLkFkZHJlc3NCb29rRW50cnlSBWVudHJ5');

@$core.Deprecated('Use addressBookEntryDescriptor instead')
const AddressBookEntry$json = {
  '1': 'AddressBookEntry',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'label', '3': 2, '4': 1, '5': 9, '10': 'label'},
    {'1': 'address', '3': 3, '4': 1, '5': 9, '10': 'address'},
    {'1': 'direction', '3': 4, '4': 1, '5': 14, '6': '.bitwindowd.v1.Direction', '10': 'direction'},
    {'1': 'create_time', '3': 5, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'createTime'},
  ],
};

/// Descriptor for `AddressBookEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addressBookEntryDescriptor = $convert.base64Decode(
    'ChBBZGRyZXNzQm9va0VudHJ5Eg4KAmlkGAEgASgDUgJpZBIUCgVsYWJlbBgCIAEoCVIFbGFiZW'
    'wSGAoHYWRkcmVzcxgDIAEoCVIHYWRkcmVzcxI2CglkaXJlY3Rpb24YBCABKA4yGC5iaXR3aW5k'
    'b3dkLnYxLkRpcmVjdGlvblIJZGlyZWN0aW9uEjsKC2NyZWF0ZV90aW1lGAUgASgLMhouZ29vZ2'
    'xlLnByb3RvYnVmLlRpbWVzdGFtcFIKY3JlYXRlVGltZQ==');

@$core.Deprecated('Use listAddressBookResponseDescriptor instead')
const ListAddressBookResponse$json = {
  '1': 'ListAddressBookResponse',
  '2': [
    {'1': 'entries', '3': 1, '4': 3, '5': 11, '6': '.bitwindowd.v1.AddressBookEntry', '10': 'entries'},
  ],
};

/// Descriptor for `ListAddressBookResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listAddressBookResponseDescriptor = $convert.base64Decode(
    'ChdMaXN0QWRkcmVzc0Jvb2tSZXNwb25zZRI5CgdlbnRyaWVzGAEgAygLMh8uYml0d2luZG93ZC'
    '52MS5BZGRyZXNzQm9va0VudHJ5UgdlbnRyaWVz');

@$core.Deprecated('Use updateAddressBookEntryRequestDescriptor instead')
const UpdateAddressBookEntryRequest$json = {
  '1': 'UpdateAddressBookEntryRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'label', '3': 2, '4': 1, '5': 9, '10': 'label'},
    {'1': 'address', '3': 3, '4': 1, '5': 9, '10': 'address'},
  ],
};

/// Descriptor for `UpdateAddressBookEntryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateAddressBookEntryRequestDescriptor = $convert.base64Decode(
    'Ch1VcGRhdGVBZGRyZXNzQm9va0VudHJ5UmVxdWVzdBIOCgJpZBgBIAEoA1ICaWQSFAoFbGFiZW'
    'wYAiABKAlSBWxhYmVsEhgKB2FkZHJlc3MYAyABKAlSB2FkZHJlc3M=');

@$core.Deprecated('Use deleteAddressBookEntryRequestDescriptor instead')
const DeleteAddressBookEntryRequest$json = {
  '1': 'DeleteAddressBookEntryRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
  ],
};

/// Descriptor for `DeleteAddressBookEntryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteAddressBookEntryRequestDescriptor = $convert.base64Decode(
    'Ch1EZWxldGVBZGRyZXNzQm9va0VudHJ5UmVxdWVzdBIOCgJpZBgBIAEoA1ICaWQ=');

@$core.Deprecated('Use getSyncInfoResponseDescriptor instead')
const GetSyncInfoResponse$json = {
  '1': 'GetSyncInfoResponse',
  '2': [
    {'1': 'tip_block_height', '3': 1, '4': 1, '5': 3, '10': 'tipBlockHeight'},
    {'1': 'tip_block_time', '3': 2, '4': 1, '5': 3, '10': 'tipBlockTime'},
    {'1': 'tip_block_hash', '3': 3, '4': 1, '5': 9, '10': 'tipBlockHash'},
    {'1': 'tip_block_processed_at', '3': 4, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'tipBlockProcessedAt'},
    {'1': 'header_height', '3': 5, '4': 1, '5': 3, '10': 'headerHeight'},
    {'1': 'sync_progress', '3': 6, '4': 1, '5': 1, '10': 'syncProgress'},
  ],
};

/// Descriptor for `GetSyncInfoResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSyncInfoResponseDescriptor = $convert.base64Decode(
    'ChNHZXRTeW5jSW5mb1Jlc3BvbnNlEigKEHRpcF9ibG9ja19oZWlnaHQYASABKANSDnRpcEJsb2'
    'NrSGVpZ2h0EiQKDnRpcF9ibG9ja190aW1lGAIgASgDUgx0aXBCbG9ja1RpbWUSJAoOdGlwX2Js'
    'b2NrX2hhc2gYAyABKAlSDHRpcEJsb2NrSGFzaBJPChZ0aXBfYmxvY2tfcHJvY2Vzc2VkX2F0GA'
    'QgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFITdGlwQmxvY2tQcm9jZXNzZWRBdBIj'
    'Cg1oZWFkZXJfaGVpZ2h0GAUgASgDUgxoZWFkZXJIZWlnaHQSIwoNc3luY19wcm9ncmVzcxgGIA'
    'EoAVIMc3luY1Byb2dyZXNz');

@$core.Deprecated('Use setTransactionNoteRequestDescriptor instead')
const SetTransactionNoteRequest$json = {
  '1': 'SetTransactionNoteRequest',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'note', '3': 2, '4': 1, '5': 9, '10': 'note'},
  ],
};

/// Descriptor for `SetTransactionNoteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setTransactionNoteRequestDescriptor = $convert.base64Decode(
    'ChlTZXRUcmFuc2FjdGlvbk5vdGVSZXF1ZXN0EhIKBHR4aWQYASABKAlSBHR4aWQSEgoEbm90ZR'
    'gCIAEoCVIEbm90ZQ==');

@$core.Deprecated('Use getFireplaceStatsResponseDescriptor instead')
const GetFireplaceStatsResponse$json = {
  '1': 'GetFireplaceStatsResponse',
  '2': [
    {'1': 'transaction_count_24h', '3': 1, '4': 1, '5': 3, '10': 'transactionCount24h'},
    {'1': 'coinnews_count_7d', '3': 2, '4': 1, '5': 3, '10': 'coinnewsCount7d'},
    {'1': 'block_count_24h', '3': 3, '4': 1, '5': 3, '10': 'blockCount24h'},
  ],
};

/// Descriptor for `GetFireplaceStatsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFireplaceStatsResponseDescriptor = $convert.base64Decode(
    'ChlHZXRGaXJlcGxhY2VTdGF0c1Jlc3BvbnNlEjIKFXRyYW5zYWN0aW9uX2NvdW50XzI0aBgBIA'
    'EoA1ITdHJhbnNhY3Rpb25Db3VudDI0aBIqChFjb2lubmV3c19jb3VudF83ZBgCIAEoA1IPY29p'
    'bm5ld3NDb3VudDdkEiYKD2Jsb2NrX2NvdW50XzI0aBgDIAEoA1INYmxvY2tDb3VudDI0aA==');

const $core.Map<$core.String, $core.dynamic> BitwindowdServiceBase$json = {
  '1': 'BitwindowdService',
  '2': [
    {'1': 'Stop', '2': '.google.protobuf.Empty', '3': '.google.protobuf.Empty'},
    {'1': 'CreateDenial', '2': '.bitwindowd.v1.CreateDenialRequest', '3': '.google.protobuf.Empty'},
    {'1': 'CancelDenial', '2': '.bitwindowd.v1.CancelDenialRequest', '3': '.google.protobuf.Empty'},
    {'1': 'CreateAddressBookEntry', '2': '.bitwindowd.v1.CreateAddressBookEntryRequest', '3': '.bitwindowd.v1.CreateAddressBookEntryResponse'},
    {'1': 'ListAddressBook', '2': '.google.protobuf.Empty', '3': '.bitwindowd.v1.ListAddressBookResponse'},
    {'1': 'UpdateAddressBookEntry', '2': '.bitwindowd.v1.UpdateAddressBookEntryRequest', '3': '.google.protobuf.Empty'},
    {'1': 'DeleteAddressBookEntry', '2': '.bitwindowd.v1.DeleteAddressBookEntryRequest', '3': '.google.protobuf.Empty'},
    {'1': 'GetSyncInfo', '2': '.google.protobuf.Empty', '3': '.bitwindowd.v1.GetSyncInfoResponse'},
    {'1': 'SetTransactionNote', '2': '.bitwindowd.v1.SetTransactionNoteRequest', '3': '.google.protobuf.Empty'},
    {'1': 'GetFireplaceStats', '2': '.google.protobuf.Empty', '3': '.bitwindowd.v1.GetFireplaceStatsResponse'},
  ],
};

@$core.Deprecated('Use bitwindowdServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> BitwindowdServiceBase$messageJson = {
  '.google.protobuf.Empty': $1.Empty$json,
  '.bitwindowd.v1.CreateDenialRequest': CreateDenialRequest$json,
  '.bitwindowd.v1.CancelDenialRequest': CancelDenialRequest$json,
  '.bitwindowd.v1.CreateAddressBookEntryRequest': CreateAddressBookEntryRequest$json,
  '.bitwindowd.v1.CreateAddressBookEntryResponse': CreateAddressBookEntryResponse$json,
  '.bitwindowd.v1.AddressBookEntry': AddressBookEntry$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.bitwindowd.v1.ListAddressBookResponse': ListAddressBookResponse$json,
  '.bitwindowd.v1.UpdateAddressBookEntryRequest': UpdateAddressBookEntryRequest$json,
  '.bitwindowd.v1.DeleteAddressBookEntryRequest': DeleteAddressBookEntryRequest$json,
  '.bitwindowd.v1.GetSyncInfoResponse': GetSyncInfoResponse$json,
  '.bitwindowd.v1.SetTransactionNoteRequest': SetTransactionNoteRequest$json,
  '.bitwindowd.v1.GetFireplaceStatsResponse': GetFireplaceStatsResponse$json,
};

/// Descriptor for `BitwindowdService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List bitwindowdServiceDescriptor = $convert.base64Decode(
    'ChFCaXR3aW5kb3dkU2VydmljZRI2CgRTdG9wEhYuZ29vZ2xlLnByb3RvYnVmLkVtcHR5GhYuZ2'
    '9vZ2xlLnByb3RvYnVmLkVtcHR5EkoKDENyZWF0ZURlbmlhbBIiLmJpdHdpbmRvd2QudjEuQ3Jl'
    'YXRlRGVuaWFsUmVxdWVzdBoWLmdvb2dsZS5wcm90b2J1Zi5FbXB0eRJKCgxDYW5jZWxEZW5pYW'
    'wSIi5iaXR3aW5kb3dkLnYxLkNhbmNlbERlbmlhbFJlcXVlc3QaFi5nb29nbGUucHJvdG9idWYu'
    'RW1wdHkSdQoWQ3JlYXRlQWRkcmVzc0Jvb2tFbnRyeRIsLmJpdHdpbmRvd2QudjEuQ3JlYXRlQW'
    'RkcmVzc0Jvb2tFbnRyeVJlcXVlc3QaLS5iaXR3aW5kb3dkLnYxLkNyZWF0ZUFkZHJlc3NCb29r'
    'RW50cnlSZXNwb25zZRJRCg9MaXN0QWRkcmVzc0Jvb2sSFi5nb29nbGUucHJvdG9idWYuRW1wdH'
    'kaJi5iaXR3aW5kb3dkLnYxLkxpc3RBZGRyZXNzQm9va1Jlc3BvbnNlEl4KFlVwZGF0ZUFkZHJl'
    'c3NCb29rRW50cnkSLC5iaXR3aW5kb3dkLnYxLlVwZGF0ZUFkZHJlc3NCb29rRW50cnlSZXF1ZX'
    'N0GhYuZ29vZ2xlLnByb3RvYnVmLkVtcHR5El4KFkRlbGV0ZUFkZHJlc3NCb29rRW50cnkSLC5i'
    'aXR3aW5kb3dkLnYxLkRlbGV0ZUFkZHJlc3NCb29rRW50cnlSZXF1ZXN0GhYuZ29vZ2xlLnByb3'
    'RvYnVmLkVtcHR5EkkKC0dldFN5bmNJbmZvEhYuZ29vZ2xlLnByb3RvYnVmLkVtcHR5GiIuYml0'
    'd2luZG93ZC52MS5HZXRTeW5jSW5mb1Jlc3BvbnNlElYKElNldFRyYW5zYWN0aW9uTm90ZRIoLm'
    'JpdHdpbmRvd2QudjEuU2V0VHJhbnNhY3Rpb25Ob3RlUmVxdWVzdBoWLmdvb2dsZS5wcm90b2J1'
    'Zi5FbXB0eRJVChFHZXRGaXJlcGxhY2VTdGF0cxIWLmdvb2dsZS5wcm90b2J1Zi5FbXB0eRooLm'
    'JpdHdpbmRvd2QudjEuR2V0RmlyZXBsYWNlU3RhdHNSZXNwb25zZQ==');

