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
    {'1': 'wallet_id', '3': 6, '4': 1, '5': 9, '10': 'walletId'},
  ],
};

/// Descriptor for `AddressBookEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addressBookEntryDescriptor = $convert.base64Decode(
    'ChBBZGRyZXNzQm9va0VudHJ5Eg4KAmlkGAEgASgDUgJpZBIUCgVsYWJlbBgCIAEoCVIFbGFiZW'
    'wSGAoHYWRkcmVzcxgDIAEoCVIHYWRkcmVzcxI2CglkaXJlY3Rpb24YBCABKA4yGC5iaXR3aW5k'
    'b3dkLnYxLkRpcmVjdGlvblIJZGlyZWN0aW9uEjsKC2NyZWF0ZV90aW1lGAUgASgLMhouZ29vZ2'
    'xlLnByb3RvYnVmLlRpbWVzdGFtcFIKY3JlYXRlVGltZRIbCgl3YWxsZXRfaWQYBiABKAlSCHdh'
    'bGxldElk');

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

@$core.Deprecated('Use listRecentTransactionsRequestDescriptor instead')
const ListRecentTransactionsRequest$json = {
  '1': 'ListRecentTransactionsRequest',
  '2': [
    {'1': 'count', '3': 1, '4': 1, '5': 3, '10': 'count'},
  ],
};

/// Descriptor for `ListRecentTransactionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listRecentTransactionsRequestDescriptor = $convert.base64Decode(
    'Ch1MaXN0UmVjZW50VHJhbnNhY3Rpb25zUmVxdWVzdBIUCgVjb3VudBgBIAEoA1IFY291bnQ=');

@$core.Deprecated('Use listRecentTransactionsResponseDescriptor instead')
const ListRecentTransactionsResponse$json = {
  '1': 'ListRecentTransactionsResponse',
  '2': [
    {'1': 'transactions', '3': 1, '4': 3, '5': 11, '6': '.bitwindowd.v1.RecentTransaction', '10': 'transactions'},
  ],
};

/// Descriptor for `ListRecentTransactionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listRecentTransactionsResponseDescriptor = $convert.base64Decode(
    'Ch5MaXN0UmVjZW50VHJhbnNhY3Rpb25zUmVzcG9uc2USRAoMdHJhbnNhY3Rpb25zGAEgAygLMi'
    'AuYml0d2luZG93ZC52MS5SZWNlbnRUcmFuc2FjdGlvblIMdHJhbnNhY3Rpb25z');

@$core.Deprecated('Use recentTransactionDescriptor instead')
const RecentTransaction$json = {
  '1': 'RecentTransaction',
  '2': [
    {'1': 'virtual_size', '3': 1, '4': 1, '5': 13, '10': 'virtualSize'},
    {'1': 'time', '3': 2, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'time'},
    {'1': 'txid', '3': 3, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'fee_sats', '3': 4, '4': 1, '5': 4, '10': 'feeSats'},
    {'1': 'confirmed_in_block', '3': 5, '4': 1, '5': 13, '9': 0, '10': 'confirmedInBlock', '17': true},
  ],
  '8': [
    {'1': '_confirmed_in_block'},
  ],
};

/// Descriptor for `RecentTransaction`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List recentTransactionDescriptor = $convert.base64Decode(
    'ChFSZWNlbnRUcmFuc2FjdGlvbhIhCgx2aXJ0dWFsX3NpemUYASABKA1SC3ZpcnR1YWxTaXplEi'
    '4KBHRpbWUYAiABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgR0aW1lEhIKBHR4aWQY'
    'AyABKAlSBHR4aWQSGQoIZmVlX3NhdHMYBCABKARSB2ZlZVNhdHMSMQoSY29uZmlybWVkX2luX2'
    'Jsb2NrGAUgASgNSABSEGNvbmZpcm1lZEluQmxvY2uIAQFCFQoTX2NvbmZpcm1lZF9pbl9ibG9j'
    'aw==');

@$core.Deprecated('Use listBlocksRequestDescriptor instead')
const ListBlocksRequest$json = {
  '1': 'ListBlocksRequest',
  '2': [
    {'1': 'start_height', '3': 1, '4': 1, '5': 13, '10': 'startHeight'},
    {'1': 'page_size', '3': 2, '4': 1, '5': 13, '10': 'pageSize'},
  ],
};

/// Descriptor for `ListBlocksRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listBlocksRequestDescriptor = $convert.base64Decode(
    'ChFMaXN0QmxvY2tzUmVxdWVzdBIhCgxzdGFydF9oZWlnaHQYASABKA1SC3N0YXJ0SGVpZ2h0Eh'
    'sKCXBhZ2Vfc2l6ZRgCIAEoDVIIcGFnZVNpemU=');

@$core.Deprecated('Use blockDescriptor instead')
const Block$json = {
  '1': 'Block',
  '2': [
    {'1': 'block_time', '3': 1, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'blockTime'},
    {'1': 'height', '3': 2, '4': 1, '5': 13, '10': 'height'},
    {'1': 'hash', '3': 3, '4': 1, '5': 9, '10': 'hash'},
    {'1': 'confirmations', '3': 4, '4': 1, '5': 5, '10': 'confirmations'},
    {'1': 'version', '3': 5, '4': 1, '5': 5, '10': 'version'},
    {'1': 'version_hex', '3': 6, '4': 1, '5': 9, '10': 'versionHex'},
    {'1': 'merkle_root', '3': 7, '4': 1, '5': 9, '10': 'merkleRoot'},
    {'1': 'nonce', '3': 8, '4': 1, '5': 13, '10': 'nonce'},
    {'1': 'bits', '3': 9, '4': 1, '5': 9, '10': 'bits'},
    {'1': 'difficulty', '3': 10, '4': 1, '5': 1, '10': 'difficulty'},
    {'1': 'previous_block_hash', '3': 11, '4': 1, '5': 9, '10': 'previousBlockHash'},
    {'1': 'next_block_hash', '3': 12, '4': 1, '5': 9, '10': 'nextBlockHash'},
    {'1': 'stripped_size', '3': 13, '4': 1, '5': 5, '10': 'strippedSize'},
    {'1': 'size', '3': 14, '4': 1, '5': 5, '10': 'size'},
    {'1': 'weight', '3': 15, '4': 1, '5': 5, '10': 'weight'},
    {'1': 'txids', '3': 16, '4': 3, '5': 9, '10': 'txids'},
  ],
};

/// Descriptor for `Block`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List blockDescriptor = $convert.base64Decode(
    'CgVCbG9jaxI5CgpibG9ja190aW1lGAEgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcF'
    'IJYmxvY2tUaW1lEhYKBmhlaWdodBgCIAEoDVIGaGVpZ2h0EhIKBGhhc2gYAyABKAlSBGhhc2gS'
    'JAoNY29uZmlybWF0aW9ucxgEIAEoBVINY29uZmlybWF0aW9ucxIYCgd2ZXJzaW9uGAUgASgFUg'
    'd2ZXJzaW9uEh8KC3ZlcnNpb25faGV4GAYgASgJUgp2ZXJzaW9uSGV4Eh8KC21lcmtsZV9yb290'
    'GAcgASgJUgptZXJrbGVSb290EhQKBW5vbmNlGAggASgNUgVub25jZRISCgRiaXRzGAkgASgJUg'
    'RiaXRzEh4KCmRpZmZpY3VsdHkYCiABKAFSCmRpZmZpY3VsdHkSLgoTcHJldmlvdXNfYmxvY2tf'
    'aGFzaBgLIAEoCVIRcHJldmlvdXNCbG9ja0hhc2gSJgoPbmV4dF9ibG9ja19oYXNoGAwgASgJUg'
    '1uZXh0QmxvY2tIYXNoEiMKDXN0cmlwcGVkX3NpemUYDSABKAVSDHN0cmlwcGVkU2l6ZRISCgRz'
    'aXplGA4gASgFUgRzaXplEhYKBndlaWdodBgPIAEoBVIGd2VpZ2h0EhQKBXR4aWRzGBAgAygJUg'
    'V0eGlkcw==');

@$core.Deprecated('Use listBlocksResponseDescriptor instead')
const ListBlocksResponse$json = {
  '1': 'ListBlocksResponse',
  '2': [
    {'1': 'recent_blocks', '3': 4, '4': 3, '5': 11, '6': '.bitwindowd.v1.Block', '10': 'recentBlocks'},
    {'1': 'has_more', '3': 5, '4': 1, '5': 8, '10': 'hasMore'},
  ],
};

/// Descriptor for `ListBlocksResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listBlocksResponseDescriptor = $convert.base64Decode(
    'ChJMaXN0QmxvY2tzUmVzcG9uc2USOQoNcmVjZW50X2Jsb2NrcxgEIAMoCzIULmJpdHdpbmRvd2'
    'QudjEuQmxvY2tSDHJlY2VudEJsb2NrcxIZCghoYXNfbW9yZRgFIAEoCFIHaGFzTW9yZQ==');

@$core.Deprecated('Use mineBlocksResponseDescriptor instead')
const MineBlocksResponse$json = {
  '1': 'MineBlocksResponse',
  '2': [
    {'1': 'block_found', '3': 1, '4': 1, '5': 11, '6': '.bitwindowd.v1.MineBlocksResponse.BlockFound', '9': 0, '10': 'blockFound'},
    {'1': 'hash_rate', '3': 2, '4': 1, '5': 11, '6': '.bitwindowd.v1.MineBlocksResponse.HashRate', '9': 0, '10': 'hashRate'},
  ],
  '3': [MineBlocksResponse_HashRate$json, MineBlocksResponse_BlockFound$json],
  '8': [
    {'1': 'event'},
  ],
};

@$core.Deprecated('Use mineBlocksResponseDescriptor instead')
const MineBlocksResponse_HashRate$json = {
  '1': 'HashRate',
  '2': [
    {'1': 'hash_rate', '3': 1, '4': 1, '5': 1, '10': 'hashRate'},
  ],
};

@$core.Deprecated('Use mineBlocksResponseDescriptor instead')
const MineBlocksResponse_BlockFound$json = {
  '1': 'BlockFound',
  '2': [
    {'1': 'block_hash', '3': 1, '4': 1, '5': 9, '10': 'blockHash'},
  ],
};

/// Descriptor for `MineBlocksResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mineBlocksResponseDescriptor = $convert.base64Decode(
    'ChJNaW5lQmxvY2tzUmVzcG9uc2USTwoLYmxvY2tfZm91bmQYASABKAsyLC5iaXR3aW5kb3dkLn'
    'YxLk1pbmVCbG9ja3NSZXNwb25zZS5CbG9ja0ZvdW5kSABSCmJsb2NrRm91bmQSSQoJaGFzaF9y'
    'YXRlGAIgASgLMiouYml0d2luZG93ZC52MS5NaW5lQmxvY2tzUmVzcG9uc2UuSGFzaFJhdGVIAF'
    'IIaGFzaFJhdGUaJwoISGFzaFJhdGUSGwoJaGFzaF9yYXRlGAEgASgBUghoYXNoUmF0ZRorCgpC'
    'bG9ja0ZvdW5kEh0KCmJsb2NrX2hhc2gYASABKAlSCWJsb2NrSGFzaEIHCgVldmVudA==');

@$core.Deprecated('Use getNetworkStatsResponseDescriptor instead')
const GetNetworkStatsResponse$json = {
  '1': 'GetNetworkStatsResponse',
  '2': [
    {'1': 'network_hashrate', '3': 1, '4': 1, '5': 1, '10': 'networkHashrate'},
    {'1': 'difficulty', '3': 2, '4': 1, '5': 1, '10': 'difficulty'},
    {'1': 'peer_count', '3': 3, '4': 1, '5': 5, '10': 'peerCount'},
    {'1': 'total_bytes_received', '3': 4, '4': 1, '5': 4, '10': 'totalBytesReceived'},
    {'1': 'total_bytes_sent', '3': 5, '4': 1, '5': 4, '10': 'totalBytesSent'},
    {'1': 'block_height', '3': 6, '4': 1, '5': 3, '10': 'blockHeight'},
    {'1': 'avg_block_time', '3': 7, '4': 1, '5': 1, '10': 'avgBlockTime'},
    {'1': 'network_version', '3': 8, '4': 1, '5': 5, '10': 'networkVersion'},
    {'1': 'subversion', '3': 9, '4': 1, '5': 9, '10': 'subversion'},
    {'1': 'connections_in', '3': 10, '4': 1, '5': 5, '10': 'connectionsIn'},
    {'1': 'connections_out', '3': 11, '4': 1, '5': 5, '10': 'connectionsOut'},
    {'1': 'bitcoind_bandwidth', '3': 12, '4': 1, '5': 11, '6': '.bitwindowd.v1.ProcessBandwidth', '10': 'bitcoindBandwidth'},
    {'1': 'enforcer_bandwidth', '3': 13, '4': 1, '5': 11, '6': '.bitwindowd.v1.ProcessBandwidth', '10': 'enforcerBandwidth'},
  ],
};

/// Descriptor for `GetNetworkStatsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNetworkStatsResponseDescriptor = $convert.base64Decode(
    'ChdHZXROZXR3b3JrU3RhdHNSZXNwb25zZRIpChBuZXR3b3JrX2hhc2hyYXRlGAEgASgBUg9uZX'
    'R3b3JrSGFzaHJhdGUSHgoKZGlmZmljdWx0eRgCIAEoAVIKZGlmZmljdWx0eRIdCgpwZWVyX2Nv'
    'dW50GAMgASgFUglwZWVyQ291bnQSMAoUdG90YWxfYnl0ZXNfcmVjZWl2ZWQYBCABKARSEnRvdG'
    'FsQnl0ZXNSZWNlaXZlZBIoChB0b3RhbF9ieXRlc19zZW50GAUgASgEUg50b3RhbEJ5dGVzU2Vu'
    'dBIhCgxibG9ja19oZWlnaHQYBiABKANSC2Jsb2NrSGVpZ2h0EiQKDmF2Z19ibG9ja190aW1lGA'
    'cgASgBUgxhdmdCbG9ja1RpbWUSJwoPbmV0d29ya192ZXJzaW9uGAggASgFUg5uZXR3b3JrVmVy'
    'c2lvbhIeCgpzdWJ2ZXJzaW9uGAkgASgJUgpzdWJ2ZXJzaW9uEiUKDmNvbm5lY3Rpb25zX2luGA'
    'ogASgFUg1jb25uZWN0aW9uc0luEicKD2Nvbm5lY3Rpb25zX291dBgLIAEoBVIOY29ubmVjdGlv'
    'bnNPdXQSTgoSYml0Y29pbmRfYmFuZHdpZHRoGAwgASgLMh8uYml0d2luZG93ZC52MS5Qcm9jZX'
    'NzQmFuZHdpZHRoUhFiaXRjb2luZEJhbmR3aWR0aBJOChJlbmZvcmNlcl9iYW5kd2lkdGgYDSAB'
    'KAsyHy5iaXR3aW5kb3dkLnYxLlByb2Nlc3NCYW5kd2lkdGhSEWVuZm9yY2VyQmFuZHdpZHRo');

@$core.Deprecated('Use processBandwidthDescriptor instead')
const ProcessBandwidth$json = {
  '1': 'ProcessBandwidth',
  '2': [
    {'1': 'process_name', '3': 1, '4': 1, '5': 9, '10': 'processName'},
    {'1': 'pid', '3': 2, '4': 1, '5': 5, '10': 'pid'},
    {'1': 'rx_bytes_per_sec', '3': 3, '4': 1, '5': 1, '10': 'rxBytesPerSec'},
    {'1': 'tx_bytes_per_sec', '3': 4, '4': 1, '5': 1, '10': 'txBytesPerSec'},
    {'1': 'total_rx_bytes', '3': 5, '4': 1, '5': 4, '10': 'totalRxBytes'},
    {'1': 'total_tx_bytes', '3': 6, '4': 1, '5': 4, '10': 'totalTxBytes'},
    {'1': 'connection_count', '3': 7, '4': 1, '5': 5, '10': 'connectionCount'},
  ],
};

/// Descriptor for `ProcessBandwidth`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List processBandwidthDescriptor = $convert.base64Decode(
    'ChBQcm9jZXNzQmFuZHdpZHRoEiEKDHByb2Nlc3NfbmFtZRgBIAEoCVILcHJvY2Vzc05hbWUSEA'
    'oDcGlkGAIgASgFUgNwaWQSJwoQcnhfYnl0ZXNfcGVyX3NlYxgDIAEoAVINcnhCeXRlc1BlclNl'
    'YxInChB0eF9ieXRlc19wZXJfc2VjGAQgASgBUg10eEJ5dGVzUGVyU2VjEiQKDnRvdGFsX3J4X2'
    'J5dGVzGAUgASgEUgx0b3RhbFJ4Qnl0ZXMSJAoOdG90YWxfdHhfYnl0ZXMYBiABKARSDHRvdGFs'
    'VHhCeXRlcxIpChBjb25uZWN0aW9uX2NvdW50GAcgASgFUg9jb25uZWN0aW9uQ291bnQ=');

const $core.Map<$core.String, $core.dynamic> BitwindowdServiceBase$json = {
  '1': 'BitwindowdService',
  '2': [
    {'1': 'Stop', '2': '.google.protobuf.Empty', '3': '.google.protobuf.Empty'},
    {'1': 'MineBlocks', '2': '.google.protobuf.Empty', '3': '.bitwindowd.v1.MineBlocksResponse', '6': true},
    {'1': 'CreateDenial', '2': '.bitwindowd.v1.CreateDenialRequest', '3': '.google.protobuf.Empty'},
    {'1': 'CancelDenial', '2': '.bitwindowd.v1.CancelDenialRequest', '3': '.google.protobuf.Empty'},
    {'1': 'CreateAddressBookEntry', '2': '.bitwindowd.v1.CreateAddressBookEntryRequest', '3': '.bitwindowd.v1.CreateAddressBookEntryResponse'},
    {'1': 'ListAddressBook', '2': '.google.protobuf.Empty', '3': '.bitwindowd.v1.ListAddressBookResponse'},
    {'1': 'UpdateAddressBookEntry', '2': '.bitwindowd.v1.UpdateAddressBookEntryRequest', '3': '.google.protobuf.Empty'},
    {'1': 'DeleteAddressBookEntry', '2': '.bitwindowd.v1.DeleteAddressBookEntryRequest', '3': '.google.protobuf.Empty'},
    {'1': 'GetSyncInfo', '2': '.google.protobuf.Empty', '3': '.bitwindowd.v1.GetSyncInfoResponse'},
    {'1': 'SetTransactionNote', '2': '.bitwindowd.v1.SetTransactionNoteRequest', '3': '.google.protobuf.Empty'},
    {'1': 'GetFireplaceStats', '2': '.google.protobuf.Empty', '3': '.bitwindowd.v1.GetFireplaceStatsResponse'},
    {'1': 'ListRecentTransactions', '2': '.bitwindowd.v1.ListRecentTransactionsRequest', '3': '.bitwindowd.v1.ListRecentTransactionsResponse'},
    {'1': 'ListBlocks', '2': '.bitwindowd.v1.ListBlocksRequest', '3': '.bitwindowd.v1.ListBlocksResponse'},
    {'1': 'GetNetworkStats', '2': '.google.protobuf.Empty', '3': '.bitwindowd.v1.GetNetworkStatsResponse'},
  ],
};

@$core.Deprecated('Use bitwindowdServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> BitwindowdServiceBase$messageJson = {
  '.google.protobuf.Empty': $1.Empty$json,
  '.bitwindowd.v1.MineBlocksResponse': MineBlocksResponse$json,
  '.bitwindowd.v1.MineBlocksResponse.BlockFound': MineBlocksResponse_BlockFound$json,
  '.bitwindowd.v1.MineBlocksResponse.HashRate': MineBlocksResponse_HashRate$json,
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
  '.bitwindowd.v1.ListRecentTransactionsRequest': ListRecentTransactionsRequest$json,
  '.bitwindowd.v1.ListRecentTransactionsResponse': ListRecentTransactionsResponse$json,
  '.bitwindowd.v1.RecentTransaction': RecentTransaction$json,
  '.bitwindowd.v1.ListBlocksRequest': ListBlocksRequest$json,
  '.bitwindowd.v1.ListBlocksResponse': ListBlocksResponse$json,
  '.bitwindowd.v1.Block': Block$json,
  '.bitwindowd.v1.GetNetworkStatsResponse': GetNetworkStatsResponse$json,
  '.bitwindowd.v1.ProcessBandwidth': ProcessBandwidth$json,
};

/// Descriptor for `BitwindowdService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List bitwindowdServiceDescriptor = $convert.base64Decode(
    'ChFCaXR3aW5kb3dkU2VydmljZRI2CgRTdG9wEhYuZ29vZ2xlLnByb3RvYnVmLkVtcHR5GhYuZ2'
    '9vZ2xlLnByb3RvYnVmLkVtcHR5EkkKCk1pbmVCbG9ja3MSFi5nb29nbGUucHJvdG9idWYuRW1w'
    'dHkaIS5iaXR3aW5kb3dkLnYxLk1pbmVCbG9ja3NSZXNwb25zZTABEkoKDENyZWF0ZURlbmlhbB'
    'IiLmJpdHdpbmRvd2QudjEuQ3JlYXRlRGVuaWFsUmVxdWVzdBoWLmdvb2dsZS5wcm90b2J1Zi5F'
    'bXB0eRJKCgxDYW5jZWxEZW5pYWwSIi5iaXR3aW5kb3dkLnYxLkNhbmNlbERlbmlhbFJlcXVlc3'
    'QaFi5nb29nbGUucHJvdG9idWYuRW1wdHkSdQoWQ3JlYXRlQWRkcmVzc0Jvb2tFbnRyeRIsLmJp'
    'dHdpbmRvd2QudjEuQ3JlYXRlQWRkcmVzc0Jvb2tFbnRyeVJlcXVlc3QaLS5iaXR3aW5kb3dkLn'
    'YxLkNyZWF0ZUFkZHJlc3NCb29rRW50cnlSZXNwb25zZRJRCg9MaXN0QWRkcmVzc0Jvb2sSFi5n'
    'b29nbGUucHJvdG9idWYuRW1wdHkaJi5iaXR3aW5kb3dkLnYxLkxpc3RBZGRyZXNzQm9va1Jlc3'
    'BvbnNlEl4KFlVwZGF0ZUFkZHJlc3NCb29rRW50cnkSLC5iaXR3aW5kb3dkLnYxLlVwZGF0ZUFk'
    'ZHJlc3NCb29rRW50cnlSZXF1ZXN0GhYuZ29vZ2xlLnByb3RvYnVmLkVtcHR5El4KFkRlbGV0ZU'
    'FkZHJlc3NCb29rRW50cnkSLC5iaXR3aW5kb3dkLnYxLkRlbGV0ZUFkZHJlc3NCb29rRW50cnlS'
    'ZXF1ZXN0GhYuZ29vZ2xlLnByb3RvYnVmLkVtcHR5EkkKC0dldFN5bmNJbmZvEhYuZ29vZ2xlLn'
    'Byb3RvYnVmLkVtcHR5GiIuYml0d2luZG93ZC52MS5HZXRTeW5jSW5mb1Jlc3BvbnNlElYKElNl'
    'dFRyYW5zYWN0aW9uTm90ZRIoLmJpdHdpbmRvd2QudjEuU2V0VHJhbnNhY3Rpb25Ob3RlUmVxdW'
    'VzdBoWLmdvb2dsZS5wcm90b2J1Zi5FbXB0eRJVChFHZXRGaXJlcGxhY2VTdGF0cxIWLmdvb2ds'
    'ZS5wcm90b2J1Zi5FbXB0eRooLmJpdHdpbmRvd2QudjEuR2V0RmlyZXBsYWNlU3RhdHNSZXNwb2'
    '5zZRJ1ChZMaXN0UmVjZW50VHJhbnNhY3Rpb25zEiwuYml0d2luZG93ZC52MS5MaXN0UmVjZW50'
    'VHJhbnNhY3Rpb25zUmVxdWVzdBotLmJpdHdpbmRvd2QudjEuTGlzdFJlY2VudFRyYW5zYWN0aW'
    '9uc1Jlc3BvbnNlElEKCkxpc3RCbG9ja3MSIC5iaXR3aW5kb3dkLnYxLkxpc3RCbG9ja3NSZXF1'
    'ZXN0GiEuYml0d2luZG93ZC52MS5MaXN0QmxvY2tzUmVzcG9uc2USUQoPR2V0TmV0d29ya1N0YX'
    'RzEhYuZ29vZ2xlLnByb3RvYnVmLkVtcHR5GiYuYml0d2luZG93ZC52MS5HZXROZXR3b3JrU3Rh'
    'dHNSZXNwb25zZQ==');

