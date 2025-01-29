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
    {'1': 'fee_sats', '3': 6, '4': 1, '5': 3, '10': 'feeSats'},
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
    'BmhlaWdodIgBARIZCghmZWVfc2F0cxgGIAEoA1IHZmVlU2F0cxI7CgtjcmVhdGVfdGltZRgHIA'
    'EoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCmNyZWF0ZVRpbWVCCQoHX2hlaWdodA==');

@$core.Deprecated('Use broadcastNewsRequestDescriptor instead')
const BroadcastNewsRequest$json = {
  '1': 'BroadcastNewsRequest',
  '2': [
    {'1': 'topic', '3': 1, '4': 1, '5': 9, '10': 'topic'},
    {'1': 'headline', '3': 2, '4': 1, '5': 9, '10': 'headline'},
  ],
};

/// Descriptor for `BroadcastNewsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List broadcastNewsRequestDescriptor = $convert.base64Decode(
    'ChRCcm9hZGNhc3ROZXdzUmVxdWVzdBIUCgV0b3BpYxgBIAEoCVIFdG9waWMSGgoIaGVhZGxpbm'
    'UYAiABKAlSCGhlYWRsaW5l');

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

