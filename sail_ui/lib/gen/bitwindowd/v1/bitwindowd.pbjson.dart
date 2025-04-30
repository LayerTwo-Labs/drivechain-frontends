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

@$core.Deprecated('Use listDenialsResponseDescriptor instead')
const ListDenialsResponse$json = {
  '1': 'ListDenialsResponse',
  '2': [
    {'1': 'utxos', '3': 1, '4': 3, '5': 11, '6': '.bitwindowd.v1.DeniabilityUTXO', '10': 'utxos'},
  ],
};

/// Descriptor for `ListDenialsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listDenialsResponseDescriptor = $convert.base64Decode(
    'ChNMaXN0RGVuaWFsc1Jlc3BvbnNlEjQKBXV0eG9zGAEgAygLMh4uYml0d2luZG93ZC52MS5EZW'
    '5pYWJpbGl0eVVUWE9SBXV0eG9z');

@$core.Deprecated('Use deniabilityUTXODescriptor instead')
const DeniabilityUTXO$json = {
  '1': 'DeniabilityUTXO',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'vout', '3': 2, '4': 1, '5': 13, '10': 'vout'},
    {'1': 'value_sats', '3': 3, '4': 1, '5': 4, '10': 'valueSats'},
    {'1': 'is_internal', '3': 4, '4': 1, '5': 8, '10': 'isInternal'},
    {'1': 'deniability', '3': 5, '4': 1, '5': 11, '6': '.bitwindowd.v1.DeniabilityInfo', '9': 0, '10': 'deniability', '17': true},
  ],
  '8': [
    {'1': '_deniability'},
  ],
};

/// Descriptor for `DeniabilityUTXO`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deniabilityUTXODescriptor = $convert.base64Decode(
    'Cg9EZW5pYWJpbGl0eVVUWE8SEgoEdHhpZBgBIAEoCVIEdHhpZBISCgR2b3V0GAIgASgNUgR2b3'
    'V0Eh0KCnZhbHVlX3NhdHMYAyABKARSCXZhbHVlU2F0cxIfCgtpc19pbnRlcm5hbBgEIAEoCFIK'
    'aXNJbnRlcm5hbBJFCgtkZW5pYWJpbGl0eRgFIAEoCzIeLmJpdHdpbmRvd2QudjEuRGVuaWFiaW'
    'xpdHlJbmZvSABSC2RlbmlhYmlsaXR5iAEBQg4KDF9kZW5pYWJpbGl0eQ==');

@$core.Deprecated('Use deniabilityInfoDescriptor instead')
const DeniabilityInfo$json = {
  '1': 'DeniabilityInfo',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'num_hops', '3': 2, '4': 1, '5': 5, '10': 'numHops'},
    {'1': 'delay_seconds', '3': 3, '4': 1, '5': 5, '10': 'delaySeconds'},
    {'1': 'create_time', '3': 4, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'createTime'},
    {'1': 'cancel_time', '3': 5, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '9': 0, '10': 'cancelTime', '17': true},
    {'1': 'cancel_reason', '3': 6, '4': 1, '5': 9, '9': 1, '10': 'cancelReason', '17': true},
    {'1': 'next_execution', '3': 7, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '9': 2, '10': 'nextExecution', '17': true},
    {'1': 'executions', '3': 8, '4': 3, '5': 11, '6': '.bitwindowd.v1.ExecutedDenial', '10': 'executions'},
    {'1': 'hops_completed', '3': 9, '4': 1, '5': 13, '10': 'hopsCompleted'},
    {'1': 'is_active', '3': 10, '4': 1, '5': 8, '10': 'isActive'},
  ],
  '8': [
    {'1': '_cancel_time'},
    {'1': '_cancel_reason'},
    {'1': '_next_execution'},
  ],
};

/// Descriptor for `DeniabilityInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deniabilityInfoDescriptor = $convert.base64Decode(
    'Cg9EZW5pYWJpbGl0eUluZm8SDgoCaWQYASABKANSAmlkEhkKCG51bV9ob3BzGAIgASgFUgdudW'
    '1Ib3BzEiMKDWRlbGF5X3NlY29uZHMYAyABKAVSDGRlbGF5U2Vjb25kcxI7CgtjcmVhdGVfdGlt'
    'ZRgEIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCmNyZWF0ZVRpbWUSQAoLY2FuY2'
    'VsX3RpbWUYBSABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wSABSCmNhbmNlbFRpbWWI'
    'AQESKAoNY2FuY2VsX3JlYXNvbhgGIAEoCUgBUgxjYW5jZWxSZWFzb26IAQESRgoObmV4dF9leG'
    'VjdXRpb24YByABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wSAJSDW5leHRFeGVjdXRp'
    'b26IAQESPQoKZXhlY3V0aW9ucxgIIAMoCzIdLmJpdHdpbmRvd2QudjEuRXhlY3V0ZWREZW5pYW'
    'xSCmV4ZWN1dGlvbnMSJQoOaG9wc19jb21wbGV0ZWQYCSABKA1SDWhvcHNDb21wbGV0ZWQSGwoJ'
    'aXNfYWN0aXZlGAogASgIUghpc0FjdGl2ZUIOCgxfY2FuY2VsX3RpbWVCEAoOX2NhbmNlbF9yZW'
    'Fzb25CEQoPX25leHRfZXhlY3V0aW9u');

@$core.Deprecated('Use executedDenialDescriptor instead')
const ExecutedDenial$json = {
  '1': 'ExecutedDenial',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'denial_id', '3': 2, '4': 1, '5': 3, '10': 'denialId'},
    {'1': 'from_txid', '3': 3, '4': 1, '5': 9, '10': 'fromTxid'},
    {'1': 'from_vout', '3': 4, '4': 1, '5': 13, '10': 'fromVout'},
    {'1': 'to_txid', '3': 5, '4': 1, '5': 9, '10': 'toTxid'},
    {'1': 'to_vout', '3': 6, '4': 1, '5': 13, '10': 'toVout'},
    {'1': 'create_time', '3': 7, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'createTime'},
  ],
};

/// Descriptor for `ExecutedDenial`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List executedDenialDescriptor = $convert.base64Decode(
    'Cg5FeGVjdXRlZERlbmlhbBIOCgJpZBgBIAEoA1ICaWQSGwoJZGVuaWFsX2lkGAIgASgDUghkZW'
    '5pYWxJZBIbCglmcm9tX3R4aWQYAyABKAlSCGZyb21UeGlkEhsKCWZyb21fdm91dBgEIAEoDVII'
    'ZnJvbVZvdXQSFwoHdG9fdHhpZBgFIAEoCVIGdG9UeGlkEhcKB3RvX3ZvdXQYBiABKA1SBnRvVm'
    '91dBI7CgtjcmVhdGVfdGltZRgHIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCmNy'
    'ZWF0ZVRpbWU=');

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

const $core.Map<$core.String, $core.dynamic> BitwindowdServiceBase$json = {
  '1': 'BitwindowdService',
  '2': [
    {'1': 'Stop', '2': '.google.protobuf.Empty', '3': '.google.protobuf.Empty'},
    {'1': 'CreateDenial', '2': '.bitwindowd.v1.CreateDenialRequest', '3': '.google.protobuf.Empty'},
    {'1': 'ListDenials', '2': '.google.protobuf.Empty', '3': '.bitwindowd.v1.ListDenialsResponse'},
    {'1': 'CancelDenial', '2': '.bitwindowd.v1.CancelDenialRequest', '3': '.google.protobuf.Empty'},
    {'1': 'CreateAddressBookEntry', '2': '.bitwindowd.v1.CreateAddressBookEntryRequest', '3': '.google.protobuf.Empty'},
    {'1': 'ListAddressBook', '2': '.google.protobuf.Empty', '3': '.bitwindowd.v1.ListAddressBookResponse'},
    {'1': 'UpdateAddressBookEntry', '2': '.bitwindowd.v1.UpdateAddressBookEntryRequest', '3': '.google.protobuf.Empty'},
    {'1': 'DeleteAddressBookEntry', '2': '.bitwindowd.v1.DeleteAddressBookEntryRequest', '3': '.google.protobuf.Empty'},
    {'1': 'GetSyncInfo', '2': '.google.protobuf.Empty', '3': '.bitwindowd.v1.GetSyncInfoResponse'},
    {'1': 'SetTransactionNote', '2': '.bitwindowd.v1.SetTransactionNoteRequest', '3': '.google.protobuf.Empty'},
  ],
};

@$core.Deprecated('Use bitwindowdServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> BitwindowdServiceBase$messageJson = {
  '.google.protobuf.Empty': $1.Empty$json,
  '.bitwindowd.v1.CreateDenialRequest': CreateDenialRequest$json,
  '.bitwindowd.v1.ListDenialsResponse': ListDenialsResponse$json,
  '.bitwindowd.v1.DeniabilityUTXO': DeniabilityUTXO$json,
  '.bitwindowd.v1.DeniabilityInfo': DeniabilityInfo$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.bitwindowd.v1.ExecutedDenial': ExecutedDenial$json,
  '.bitwindowd.v1.CancelDenialRequest': CancelDenialRequest$json,
  '.bitwindowd.v1.CreateAddressBookEntryRequest': CreateAddressBookEntryRequest$json,
  '.bitwindowd.v1.ListAddressBookResponse': ListAddressBookResponse$json,
  '.bitwindowd.v1.AddressBookEntry': AddressBookEntry$json,
  '.bitwindowd.v1.UpdateAddressBookEntryRequest': UpdateAddressBookEntryRequest$json,
  '.bitwindowd.v1.DeleteAddressBookEntryRequest': DeleteAddressBookEntryRequest$json,
  '.bitwindowd.v1.GetSyncInfoResponse': GetSyncInfoResponse$json,
  '.bitwindowd.v1.SetTransactionNoteRequest': SetTransactionNoteRequest$json,
};

/// Descriptor for `BitwindowdService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List bitwindowdServiceDescriptor = $convert.base64Decode(
    'ChFCaXR3aW5kb3dkU2VydmljZRI2CgRTdG9wEhYuZ29vZ2xlLnByb3RvYnVmLkVtcHR5GhYuZ2'
    '9vZ2xlLnByb3RvYnVmLkVtcHR5EkoKDENyZWF0ZURlbmlhbBIiLmJpdHdpbmRvd2QudjEuQ3Jl'
    'YXRlRGVuaWFsUmVxdWVzdBoWLmdvb2dsZS5wcm90b2J1Zi5FbXB0eRJJCgtMaXN0RGVuaWFscx'
    'IWLmdvb2dsZS5wcm90b2J1Zi5FbXB0eRoiLmJpdHdpbmRvd2QudjEuTGlzdERlbmlhbHNSZXNw'
    'b25zZRJKCgxDYW5jZWxEZW5pYWwSIi5iaXR3aW5kb3dkLnYxLkNhbmNlbERlbmlhbFJlcXVlc3'
    'QaFi5nb29nbGUucHJvdG9idWYuRW1wdHkSXgoWQ3JlYXRlQWRkcmVzc0Jvb2tFbnRyeRIsLmJp'
    'dHdpbmRvd2QudjEuQ3JlYXRlQWRkcmVzc0Jvb2tFbnRyeVJlcXVlc3QaFi5nb29nbGUucHJvdG'
    '9idWYuRW1wdHkSUQoPTGlzdEFkZHJlc3NCb29rEhYuZ29vZ2xlLnByb3RvYnVmLkVtcHR5GiYu'
    'Yml0d2luZG93ZC52MS5MaXN0QWRkcmVzc0Jvb2tSZXNwb25zZRJeChZVcGRhdGVBZGRyZXNzQm'
    '9va0VudHJ5EiwuYml0d2luZG93ZC52MS5VcGRhdGVBZGRyZXNzQm9va0VudHJ5UmVxdWVzdBoW'
    'Lmdvb2dsZS5wcm90b2J1Zi5FbXB0eRJeChZEZWxldGVBZGRyZXNzQm9va0VudHJ5EiwuYml0d2'
    'luZG93ZC52MS5EZWxldGVBZGRyZXNzQm9va0VudHJ5UmVxdWVzdBoWLmdvb2dsZS5wcm90b2J1'
    'Zi5FbXB0eRJJCgtHZXRTeW5jSW5mbxIWLmdvb2dsZS5wcm90b2J1Zi5FbXB0eRoiLmJpdHdpbm'
    'Rvd2QudjEuR2V0U3luY0luZm9SZXNwb25zZRJWChJTZXRUcmFuc2FjdGlvbk5vdGUSKC5iaXR3'
    'aW5kb3dkLnYxLlNldFRyYW5zYWN0aW9uTm90ZVJlcXVlc3QaFi5nb29nbGUucHJvdG9idWYuRW'
    '1wdHk=');

