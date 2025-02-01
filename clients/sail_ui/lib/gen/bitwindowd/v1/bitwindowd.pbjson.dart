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

@$core.Deprecated('Use createDenialRequestDescriptor instead')
const CreateDenialRequest$json = {
  '1': 'CreateDenialRequest',
  '2': [
    {'1': 'delay_seconds', '3': 1, '4': 1, '5': 5, '10': 'delaySeconds'},
    {'1': 'num_hops', '3': 2, '4': 1, '5': 5, '10': 'numHops'},
  ],
};

/// Descriptor for `CreateDenialRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createDenialRequestDescriptor = $convert.base64Decode(
    'ChNDcmVhdGVEZW5pYWxSZXF1ZXN0EiMKDWRlbGF5X3NlY29uZHMYASABKAVSDGRlbGF5U2Vjb2'
    '5kcxIZCghudW1faG9wcxgCIAEoBVIHbnVtSG9wcw==');

@$core.Deprecated('Use createDenialResponseDescriptor instead')
const CreateDenialResponse$json = {
  '1': 'CreateDenialResponse',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
  ],
};

/// Descriptor for `CreateDenialResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createDenialResponseDescriptor = $convert.base64Decode(
    'ChRDcmVhdGVEZW5pYWxSZXNwb25zZRIOCgJpZBgBIAEoA1ICaWQ=');

@$core.Deprecated('Use denialDescriptor instead')
const Denial$json = {
  '1': 'Denial',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'delay_seconds', '3': 2, '4': 1, '5': 5, '10': 'delaySeconds'},
    {'1': 'num_hops', '3': 3, '4': 1, '5': 5, '10': 'numHops'},
    {'1': 'created_at', '3': 4, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'createdAt'},
    {'1': 'cancelled_at', '3': 5, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '9': 0, '10': 'cancelledAt', '17': true},
    {'1': 'next_execution', '3': 6, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '9': 1, '10': 'nextExecution', '17': true},
    {'1': 'executions', '3': 7, '4': 3, '5': 11, '6': '.bitwindowd.v1.ExecutedDenial', '10': 'executions'},
  ],
  '8': [
    {'1': '_cancelled_at'},
    {'1': '_next_execution'},
  ],
};

/// Descriptor for `Denial`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List denialDescriptor = $convert.base64Decode(
    'CgZEZW5pYWwSDgoCaWQYASABKANSAmlkEiMKDWRlbGF5X3NlY29uZHMYAiABKAVSDGRlbGF5U2'
    'Vjb25kcxIZCghudW1faG9wcxgDIAEoBVIHbnVtSG9wcxI5CgpjcmVhdGVkX2F0GAQgASgLMhou'
    'Z29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJY3JlYXRlZEF0EkIKDGNhbmNlbGxlZF9hdBgFIA'
    'EoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBIAFILY2FuY2VsbGVkQXSIAQESRgoObmV4'
    'dF9leGVjdXRpb24YBiABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wSAFSDW5leHRFeG'
    'VjdXRpb26IAQESPQoKZXhlY3V0aW9ucxgHIAMoCzIdLmJpdHdpbmRvd2QudjEuRXhlY3V0ZWRE'
    'ZW5pYWxSCmV4ZWN1dGlvbnNCDwoNX2NhbmNlbGxlZF9hdEIRCg9fbmV4dF9leGVjdXRpb24=');

@$core.Deprecated('Use listDenialsResponseDescriptor instead')
const ListDenialsResponse$json = {
  '1': 'ListDenialsResponse',
  '2': [
    {'1': 'denials', '3': 1, '4': 3, '5': 11, '6': '.bitwindowd.v1.Denial', '10': 'denials'},
  ],
};

/// Descriptor for `ListDenialsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listDenialsResponseDescriptor = $convert.base64Decode(
    'ChNMaXN0RGVuaWFsc1Jlc3BvbnNlEi8KB2RlbmlhbHMYASADKAsyFS5iaXR3aW5kb3dkLnYxLk'
    'RlbmlhbFIHZGVuaWFscw==');

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

@$core.Deprecated('Use executedDenialDescriptor instead')
const ExecutedDenial$json = {
  '1': 'ExecutedDenial',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'denial_id', '3': 2, '4': 1, '5': 3, '10': 'denialId'},
    {'1': 'transaction_id', '3': 3, '4': 1, '5': 9, '10': 'transactionId'},
    {'1': 'created_at', '3': 4, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'createdAt'},
  ],
};

/// Descriptor for `ExecutedDenial`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List executedDenialDescriptor = $convert.base64Decode(
    'Cg5FeGVjdXRlZERlbmlhbBIOCgJpZBgBIAEoA1ICaWQSGwoJZGVuaWFsX2lkGAIgASgDUghkZW'
    '5pYWxJZBIlCg50cmFuc2FjdGlvbl9pZBgDIAEoCVINdHJhbnNhY3Rpb25JZBI5CgpjcmVhdGVk'
    'X2F0GAQgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJY3JlYXRlZEF0');

const $core.Map<$core.String, $core.dynamic> BitwindowdServiceBase$json = {
  '1': 'BitwindowdService',
  '2': [
    {'1': 'Stop', '2': '.google.protobuf.Empty', '3': '.google.protobuf.Empty'},
    {'1': 'CreateDenial', '2': '.bitwindowd.v1.CreateDenialRequest', '3': '.bitwindowd.v1.CreateDenialResponse'},
    {'1': 'ListDenials', '2': '.google.protobuf.Empty', '3': '.bitwindowd.v1.ListDenialsResponse'},
    {'1': 'CancelDenial', '2': '.bitwindowd.v1.CancelDenialRequest', '3': '.google.protobuf.Empty'},
  ],
};

@$core.Deprecated('Use bitwindowdServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> BitwindowdServiceBase$messageJson = {
  '.google.protobuf.Empty': $1.Empty$json,
  '.bitwindowd.v1.CreateDenialRequest': CreateDenialRequest$json,
  '.bitwindowd.v1.CreateDenialResponse': CreateDenialResponse$json,
  '.bitwindowd.v1.ListDenialsResponse': ListDenialsResponse$json,
  '.bitwindowd.v1.Denial': Denial$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.bitwindowd.v1.ExecutedDenial': ExecutedDenial$json,
  '.bitwindowd.v1.CancelDenialRequest': CancelDenialRequest$json,
};

/// Descriptor for `BitwindowdService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List bitwindowdServiceDescriptor = $convert.base64Decode(
    'ChFCaXR3aW5kb3dkU2VydmljZRI2CgRTdG9wEhYuZ29vZ2xlLnByb3RvYnVmLkVtcHR5GhYuZ2'
    '9vZ2xlLnByb3RvYnVmLkVtcHR5ElcKDENyZWF0ZURlbmlhbBIiLmJpdHdpbmRvd2QudjEuQ3Jl'
    'YXRlRGVuaWFsUmVxdWVzdBojLmJpdHdpbmRvd2QudjEuQ3JlYXRlRGVuaWFsUmVzcG9uc2USSQ'
    'oLTGlzdERlbmlhbHMSFi5nb29nbGUucHJvdG9idWYuRW1wdHkaIi5iaXR3aW5kb3dkLnYxLkxp'
    'c3REZW5pYWxzUmVzcG9uc2USSgoMQ2FuY2VsRGVuaWFsEiIuYml0d2luZG93ZC52MS5DYW5jZW'
    'xEZW5pYWxSZXF1ZXN0GhYuZ29vZ2xlLnByb3RvYnVmLkVtcHR5');

