//
//  Generated code. Do not modify.
//  source: misc/v1/misc.proto
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

@$core.Deprecated('Use listOPReturnResponseDescriptor instead')
const ListOPReturnResponse$json = {
  '1': 'ListOPReturnResponse',
  '2': [
    {'1': 'op_returns', '3': 1, '4': 3, '5': 11, '6': '.misc.v1.OPReturn', '10': 'opReturns'},
  ],
};

/// Descriptor for `ListOPReturnResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listOPReturnResponseDescriptor = $convert.base64Decode(
    'ChRMaXN0T1BSZXR1cm5SZXNwb25zZRIwCgpvcF9yZXR1cm5zGAEgAygLMhEubWlzYy52MS5PUF'
    'JldHVyblIJb3BSZXR1cm5z');

@$core.Deprecated('Use oPReturnDescriptor instead')
const OPReturn$json = {
  '1': 'OPReturn',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'txid', '3': 3, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'vout', '3': 4, '4': 1, '5': 5, '10': 'vout'},
    {'1': 'height', '3': 5, '4': 1, '5': 5, '9': 0, '10': 'height', '17': true},
    {'1': 'create_time', '3': 7, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'createTime'},
  ],
  '8': [
    {'1': '_height'},
  ],
};

/// Descriptor for `OPReturn`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List oPReturnDescriptor = $convert.base64Decode(
    'CghPUFJldHVybhIOCgJpZBgBIAEoA1ICaWQSGAoHbWVzc2FnZRgCIAEoCVIHbWVzc2FnZRISCg'
    'R0eGlkGAMgASgJUgR0eGlkEhIKBHZvdXQYBCABKAVSBHZvdXQSGwoGaGVpZ2h0GAUgASgFSABS'
    'BmhlaWdodIgBARI7CgtjcmVhdGVfdGltZRgHIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3'
    'RhbXBSCmNyZWF0ZVRpbWVCCQoHX2hlaWdodA==');

@$core.Deprecated('Use broadcastNewsRequestDescriptor instead')
const BroadcastNewsRequest$json = {
  '1': 'BroadcastNewsRequest',
  '2': [
    {'1': 'topic', '3': 1, '4': 1, '5': 9, '10': 'topic'},
    {'1': 'headline', '3': 2, '4': 1, '5': 9, '10': 'headline'},
    {'1': 'content', '3': 3, '4': 1, '5': 9, '10': 'content'},
  ],
};

/// Descriptor for `BroadcastNewsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List broadcastNewsRequestDescriptor = $convert.base64Decode(
    'ChRCcm9hZGNhc3ROZXdzUmVxdWVzdBIUCgV0b3BpYxgBIAEoCVIFdG9waWMSGgoIaGVhZGxpbm'
    'UYAiABKAlSCGhlYWRsaW5lEhgKB2NvbnRlbnQYAyABKAlSB2NvbnRlbnQ=');

@$core.Deprecated('Use broadcastNewsResponseDescriptor instead')
const BroadcastNewsResponse$json = {
  '1': 'BroadcastNewsResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `BroadcastNewsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List broadcastNewsResponseDescriptor = $convert.base64Decode(
    'ChVCcm9hZGNhc3ROZXdzUmVzcG9uc2USEgoEdHhpZBgBIAEoCVIEdHhpZA==');

@$core.Deprecated('Use createTopicRequestDescriptor instead')
const CreateTopicRequest$json = {
  '1': 'CreateTopicRequest',
  '2': [
    {'1': 'topic', '3': 1, '4': 1, '5': 9, '10': 'topic'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `CreateTopicRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createTopicRequestDescriptor = $convert.base64Decode(
    'ChJDcmVhdGVUb3BpY1JlcXVlc3QSFAoFdG9waWMYASABKAlSBXRvcGljEhIKBG5hbWUYAiABKA'
    'lSBG5hbWU=');

@$core.Deprecated('Use createTopicResponseDescriptor instead')
const CreateTopicResponse$json = {
  '1': 'CreateTopicResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `CreateTopicResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createTopicResponseDescriptor = $convert.base64Decode(
    'ChNDcmVhdGVUb3BpY1Jlc3BvbnNlEhIKBHR4aWQYASABKAlSBHR4aWQ=');

@$core.Deprecated('Use topicDescriptor instead')
const Topic$json = {
  '1': 'Topic',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'topic', '3': 2, '4': 1, '5': 9, '10': 'topic'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'create_time', '3': 4, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'createTime'},
  ],
};

/// Descriptor for `Topic`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List topicDescriptor = $convert.base64Decode(
    'CgVUb3BpYxIOCgJpZBgBIAEoA1ICaWQSFAoFdG9waWMYAiABKAlSBXRvcGljEhIKBG5hbWUYAy'
    'ABKAlSBG5hbWUSOwoLY3JlYXRlX3RpbWUYBCABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0'
    'YW1wUgpjcmVhdGVUaW1l');

@$core.Deprecated('Use listTopicsResponseDescriptor instead')
const ListTopicsResponse$json = {
  '1': 'ListTopicsResponse',
  '2': [
    {'1': 'topics', '3': 1, '4': 3, '5': 11, '6': '.misc.v1.Topic', '10': 'topics'},
  ],
};

/// Descriptor for `ListTopicsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listTopicsResponseDescriptor = $convert.base64Decode(
    'ChJMaXN0VG9waWNzUmVzcG9uc2USJgoGdG9waWNzGAEgAygLMg4ubWlzYy52MS5Ub3BpY1IGdG'
    '9waWNz');

@$core.Deprecated('Use listCoinNewsRequestDescriptor instead')
const ListCoinNewsRequest$json = {
  '1': 'ListCoinNewsRequest',
  '2': [
    {'1': 'topic', '3': 1, '4': 1, '5': 9, '9': 0, '10': 'topic', '17': true},
  ],
  '8': [
    {'1': '_topic'},
  ],
};

/// Descriptor for `ListCoinNewsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listCoinNewsRequestDescriptor = $convert.base64Decode(
    'ChNMaXN0Q29pbk5ld3NSZXF1ZXN0EhkKBXRvcGljGAEgASgJSABSBXRvcGljiAEBQggKBl90b3'
    'BpYw==');

@$core.Deprecated('Use coinNewsDescriptor instead')
const CoinNews$json = {
  '1': 'CoinNews',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'topic', '3': 2, '4': 1, '5': 9, '10': 'topic'},
    {'1': 'headline', '3': 3, '4': 1, '5': 9, '10': 'headline'},
    {'1': 'content', '3': 4, '4': 1, '5': 9, '10': 'content'},
    {'1': 'fee_sats', '3': 5, '4': 1, '5': 3, '10': 'feeSats'},
    {'1': 'create_time', '3': 6, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'createTime'},
  ],
};

/// Descriptor for `CoinNews`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List coinNewsDescriptor = $convert.base64Decode(
    'CghDb2luTmV3cxIOCgJpZBgBIAEoA1ICaWQSFAoFdG9waWMYAiABKAlSBXRvcGljEhoKCGhlYW'
    'RsaW5lGAMgASgJUghoZWFkbGluZRIYCgdjb250ZW50GAQgASgJUgdjb250ZW50EhkKCGZlZV9z'
    'YXRzGAUgASgDUgdmZWVTYXRzEjsKC2NyZWF0ZV90aW1lGAYgASgLMhouZ29vZ2xlLnByb3RvYn'
    'VmLlRpbWVzdGFtcFIKY3JlYXRlVGltZQ==');

@$core.Deprecated('Use listCoinNewsResponseDescriptor instead')
const ListCoinNewsResponse$json = {
  '1': 'ListCoinNewsResponse',
  '2': [
    {'1': 'coin_news', '3': 1, '4': 3, '5': 11, '6': '.misc.v1.CoinNews', '10': 'coinNews'},
  ],
};

/// Descriptor for `ListCoinNewsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listCoinNewsResponseDescriptor = $convert.base64Decode(
    'ChRMaXN0Q29pbk5ld3NSZXNwb25zZRIuCgljb2luX25ld3MYASADKAsyES5taXNjLnYxLkNvaW'
    '5OZXdzUghjb2luTmV3cw==');

@$core.Deprecated('Use timestampFileRequestDescriptor instead')
const TimestampFileRequest$json = {
  '1': 'TimestampFileRequest',
  '2': [
    {'1': 'filename', '3': 1, '4': 1, '5': 9, '10': 'filename'},
    {'1': 'file_data', '3': 2, '4': 1, '5': 12, '10': 'fileData'},
  ],
};

/// Descriptor for `TimestampFileRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timestampFileRequestDescriptor = $convert.base64Decode(
    'ChRUaW1lc3RhbXBGaWxlUmVxdWVzdBIaCghmaWxlbmFtZRgBIAEoCVIIZmlsZW5hbWUSGwoJZm'
    'lsZV9kYXRhGAIgASgMUghmaWxlRGF0YQ==');

@$core.Deprecated('Use timestampFileResponseDescriptor instead')
const TimestampFileResponse$json = {
  '1': 'TimestampFileResponse',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'file_hash', '3': 2, '4': 1, '5': 9, '10': 'fileHash'},
    {'1': 'txid', '3': 3, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `TimestampFileResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timestampFileResponseDescriptor = $convert.base64Decode(
    'ChVUaW1lc3RhbXBGaWxlUmVzcG9uc2USDgoCaWQYASABKANSAmlkEhsKCWZpbGVfaGFzaBgCIA'
    'EoCVIIZmlsZUhhc2gSEgoEdHhpZBgDIAEoCVIEdHhpZA==');

@$core.Deprecated('Use fileTimestampDescriptor instead')
const FileTimestamp$json = {
  '1': 'FileTimestamp',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'filename', '3': 2, '4': 1, '5': 9, '10': 'filename'},
    {'1': 'file_hash', '3': 3, '4': 1, '5': 9, '10': 'fileHash'},
    {'1': 'txid', '3': 4, '4': 1, '5': 9, '9': 0, '10': 'txid', '17': true},
    {'1': 'block_height', '3': 5, '4': 1, '5': 3, '9': 1, '10': 'blockHeight', '17': true},
    {'1': 'status', '3': 6, '4': 1, '5': 9, '10': 'status'},
    {'1': 'created_at', '3': 7, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'createdAt'},
    {'1': 'confirmed_at', '3': 8, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '9': 2, '10': 'confirmedAt', '17': true},
    {'1': 'confirmations', '3': 9, '4': 1, '5': 13, '10': 'confirmations'},
  ],
  '8': [
    {'1': '_txid'},
    {'1': '_block_height'},
    {'1': '_confirmed_at'},
  ],
};

/// Descriptor for `FileTimestamp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fileTimestampDescriptor = $convert.base64Decode(
    'Cg1GaWxlVGltZXN0YW1wEg4KAmlkGAEgASgDUgJpZBIaCghmaWxlbmFtZRgCIAEoCVIIZmlsZW'
    '5hbWUSGwoJZmlsZV9oYXNoGAMgASgJUghmaWxlSGFzaBIXCgR0eGlkGAQgASgJSABSBHR4aWSI'
    'AQESJgoMYmxvY2tfaGVpZ2h0GAUgASgDSAFSC2Jsb2NrSGVpZ2h0iAEBEhYKBnN0YXR1cxgGIA'
    'EoCVIGc3RhdHVzEjkKCmNyZWF0ZWRfYXQYByABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0'
    'YW1wUgljcmVhdGVkQXQSQgoMY29uZmlybWVkX2F0GAggASgLMhouZ29vZ2xlLnByb3RvYnVmLl'
    'RpbWVzdGFtcEgCUgtjb25maXJtZWRBdIgBARIkCg1jb25maXJtYXRpb25zGAkgASgNUg1jb25m'
    'aXJtYXRpb25zQgcKBV90eGlkQg8KDV9ibG9ja19oZWlnaHRCDwoNX2NvbmZpcm1lZF9hdA==');

@$core.Deprecated('Use listTimestampsResponseDescriptor instead')
const ListTimestampsResponse$json = {
  '1': 'ListTimestampsResponse',
  '2': [
    {'1': 'timestamps', '3': 1, '4': 3, '5': 11, '6': '.misc.v1.FileTimestamp', '10': 'timestamps'},
  ],
};

/// Descriptor for `ListTimestampsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listTimestampsResponseDescriptor = $convert.base64Decode(
    'ChZMaXN0VGltZXN0YW1wc1Jlc3BvbnNlEjYKCnRpbWVzdGFtcHMYASADKAsyFi5taXNjLnYxLk'
    'ZpbGVUaW1lc3RhbXBSCnRpbWVzdGFtcHM=');

@$core.Deprecated('Use verifyTimestampRequestDescriptor instead')
const VerifyTimestampRequest$json = {
  '1': 'VerifyTimestampRequest',
  '2': [
    {'1': 'file_data', '3': 1, '4': 1, '5': 12, '10': 'fileData'},
    {'1': 'filename', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'filename', '17': true},
  ],
  '8': [
    {'1': '_filename'},
  ],
};

/// Descriptor for `VerifyTimestampRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List verifyTimestampRequestDescriptor = $convert.base64Decode(
    'ChZWZXJpZnlUaW1lc3RhbXBSZXF1ZXN0EhsKCWZpbGVfZGF0YRgBIAEoDFIIZmlsZURhdGESHw'
    'oIZmlsZW5hbWUYAiABKAlIAFIIZmlsZW5hbWWIAQFCCwoJX2ZpbGVuYW1l');

@$core.Deprecated('Use verifyTimestampResponseDescriptor instead')
const VerifyTimestampResponse$json = {
  '1': 'VerifyTimestampResponse',
  '2': [
    {'1': 'timestamp', '3': 1, '4': 1, '5': 11, '6': '.misc.v1.FileTimestamp', '10': 'timestamp'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `VerifyTimestampResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List verifyTimestampResponseDescriptor = $convert.base64Decode(
    'ChdWZXJpZnlUaW1lc3RhbXBSZXNwb25zZRI0Cgl0aW1lc3RhbXAYASABKAsyFi5taXNjLnYxLk'
    'ZpbGVUaW1lc3RhbXBSCXRpbWVzdGFtcBIYCgdtZXNzYWdlGAIgASgJUgdtZXNzYWdl');

const $core.Map<$core.String, $core.dynamic> MiscServiceBase$json = {
  '1': 'MiscService',
  '2': [
    {'1': 'ListOPReturn', '2': '.google.protobuf.Empty', '3': '.misc.v1.ListOPReturnResponse'},
    {'1': 'BroadcastNews', '2': '.misc.v1.BroadcastNewsRequest', '3': '.misc.v1.BroadcastNewsResponse'},
    {'1': 'CreateTopic', '2': '.misc.v1.CreateTopicRequest', '3': '.misc.v1.CreateTopicResponse'},
    {'1': 'ListTopics', '2': '.google.protobuf.Empty', '3': '.misc.v1.ListTopicsResponse'},
    {'1': 'ListCoinNews', '2': '.misc.v1.ListCoinNewsRequest', '3': '.misc.v1.ListCoinNewsResponse'},
    {'1': 'TimestampFile', '2': '.misc.v1.TimestampFileRequest', '3': '.misc.v1.TimestampFileResponse'},
    {'1': 'ListTimestamps', '2': '.google.protobuf.Empty', '3': '.misc.v1.ListTimestampsResponse'},
    {'1': 'VerifyTimestamp', '2': '.misc.v1.VerifyTimestampRequest', '3': '.misc.v1.VerifyTimestampResponse'},
  ],
};

@$core.Deprecated('Use miscServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> MiscServiceBase$messageJson = {
  '.google.protobuf.Empty': $1.Empty$json,
  '.misc.v1.ListOPReturnResponse': ListOPReturnResponse$json,
  '.misc.v1.OPReturn': OPReturn$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.misc.v1.BroadcastNewsRequest': BroadcastNewsRequest$json,
  '.misc.v1.BroadcastNewsResponse': BroadcastNewsResponse$json,
  '.misc.v1.CreateTopicRequest': CreateTopicRequest$json,
  '.misc.v1.CreateTopicResponse': CreateTopicResponse$json,
  '.misc.v1.ListTopicsResponse': ListTopicsResponse$json,
  '.misc.v1.Topic': Topic$json,
  '.misc.v1.ListCoinNewsRequest': ListCoinNewsRequest$json,
  '.misc.v1.ListCoinNewsResponse': ListCoinNewsResponse$json,
  '.misc.v1.CoinNews': CoinNews$json,
  '.misc.v1.TimestampFileRequest': TimestampFileRequest$json,
  '.misc.v1.TimestampFileResponse': TimestampFileResponse$json,
  '.misc.v1.ListTimestampsResponse': ListTimestampsResponse$json,
  '.misc.v1.FileTimestamp': FileTimestamp$json,
  '.misc.v1.VerifyTimestampRequest': VerifyTimestampRequest$json,
  '.misc.v1.VerifyTimestampResponse': VerifyTimestampResponse$json,
};

/// Descriptor for `MiscService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List miscServiceDescriptor = $convert.base64Decode(
    'CgtNaXNjU2VydmljZRJFCgxMaXN0T1BSZXR1cm4SFi5nb29nbGUucHJvdG9idWYuRW1wdHkaHS'
    '5taXNjLnYxLkxpc3RPUFJldHVyblJlc3BvbnNlEk4KDUJyb2FkY2FzdE5ld3MSHS5taXNjLnYx'
    'LkJyb2FkY2FzdE5ld3NSZXF1ZXN0Gh4ubWlzYy52MS5Ccm9hZGNhc3ROZXdzUmVzcG9uc2USSA'
    'oLQ3JlYXRlVG9waWMSGy5taXNjLnYxLkNyZWF0ZVRvcGljUmVxdWVzdBocLm1pc2MudjEuQ3Jl'
    'YXRlVG9waWNSZXNwb25zZRJBCgpMaXN0VG9waWNzEhYuZ29vZ2xlLnByb3RvYnVmLkVtcHR5Gh'
    'subWlzYy52MS5MaXN0VG9waWNzUmVzcG9uc2USSwoMTGlzdENvaW5OZXdzEhwubWlzYy52MS5M'
    'aXN0Q29pbk5ld3NSZXF1ZXN0Gh0ubWlzYy52MS5MaXN0Q29pbk5ld3NSZXNwb25zZRJOCg1UaW'
    '1lc3RhbXBGaWxlEh0ubWlzYy52MS5UaW1lc3RhbXBGaWxlUmVxdWVzdBoeLm1pc2MudjEuVGlt'
    'ZXN0YW1wRmlsZVJlc3BvbnNlEkkKDkxpc3RUaW1lc3RhbXBzEhYuZ29vZ2xlLnByb3RvYnVmLk'
    'VtcHR5Gh8ubWlzYy52MS5MaXN0VGltZXN0YW1wc1Jlc3BvbnNlElQKD1ZlcmlmeVRpbWVzdGFt'
    'cBIfLm1pc2MudjEuVmVyaWZ5VGltZXN0YW1wUmVxdWVzdBogLm1pc2MudjEuVmVyaWZ5VGltZX'
    'N0YW1wUmVzcG9uc2U=');

