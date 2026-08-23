//
//  Generated code. Do not modify.
//  source: m4/v1/m4.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use m4VoteDescriptor instead')
const M4Vote$json = {
  '1': 'M4Vote',
  '2': [
    {'1': 'sidechain_slot', '3': 1, '4': 1, '5': 13, '10': 'sidechainSlot'},
    {'1': 'vote_type', '3': 2, '4': 1, '5': 9, '10': 'voteType'},
    {'1': 'bundle_hash', '3': 3, '4': 1, '5': 9, '9': 0, '10': 'bundleHash', '17': true},
    {'1': 'bundle_index', '3': 4, '4': 1, '5': 13, '9': 1, '10': 'bundleIndex', '17': true},
  ],
  '8': [
    {'1': '_bundle_hash'},
    {'1': '_bundle_index'},
  ],
};

/// Descriptor for `M4Vote`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List m4VoteDescriptor = $convert.base64Decode(
    'CgZNNFZvdGUSJQoOc2lkZWNoYWluX3Nsb3QYASABKA1SDXNpZGVjaGFpblNsb3QSGwoJdm90ZV'
    '90eXBlGAIgASgJUgh2b3RlVHlwZRIkCgtidW5kbGVfaGFzaBgDIAEoCUgAUgpidW5kbGVIYXNo'
    'iAEBEiYKDGJ1bmRsZV9pbmRleBgEIAEoDUgBUgtidW5kbGVJbmRleIgBAUIOCgxfYnVuZGxlX2'
    'hhc2hCDwoNX2J1bmRsZV9pbmRleA==');

@$core.Deprecated('Use m4HistoryEntryDescriptor instead')
const M4HistoryEntry$json = {
  '1': 'M4HistoryEntry',
  '2': [
    {'1': 'block_height', '3': 1, '4': 1, '5': 13, '10': 'blockHeight'},
    {'1': 'block_hash', '3': 2, '4': 1, '5': 9, '10': 'blockHash'},
    {'1': 'block_time', '3': 3, '4': 1, '5': 3, '10': 'blockTime'},
    {'1': 'version', '3': 4, '4': 1, '5': 13, '10': 'version'},
    {'1': 'votes', '3': 5, '4': 3, '5': 11, '6': '.m4.v1.M4Vote', '10': 'votes'},
  ],
};

/// Descriptor for `M4HistoryEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List m4HistoryEntryDescriptor = $convert.base64Decode(
    'Cg5NNEhpc3RvcnlFbnRyeRIhCgxibG9ja19oZWlnaHQYASABKA1SC2Jsb2NrSGVpZ2h0Eh0KCm'
    'Jsb2NrX2hhc2gYAiABKAlSCWJsb2NrSGFzaBIdCgpibG9ja190aW1lGAMgASgDUglibG9ja1Rp'
    'bWUSGAoHdmVyc2lvbhgEIAEoDVIHdmVyc2lvbhIjCgV2b3RlcxgFIAMoCzINLm00LnYxLk00Vm'
    '90ZVIFdm90ZXM=');

@$core.Deprecated('Use getM4HistoryRequestDescriptor instead')
const GetM4HistoryRequest$json = {
  '1': 'GetM4HistoryRequest',
  '2': [
    {'1': 'limit', '3': 1, '4': 1, '5': 13, '10': 'limit'},
  ],
};

/// Descriptor for `GetM4HistoryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getM4HistoryRequestDescriptor = $convert.base64Decode(
    'ChNHZXRNNEhpc3RvcnlSZXF1ZXN0EhQKBWxpbWl0GAEgASgNUgVsaW1pdA==');

@$core.Deprecated('Use getM4HistoryResponseDescriptor instead')
const GetM4HistoryResponse$json = {
  '1': 'GetM4HistoryResponse',
  '2': [
    {'1': 'history', '3': 1, '4': 3, '5': 11, '6': '.m4.v1.M4HistoryEntry', '10': 'history'},
  ],
};

/// Descriptor for `GetM4HistoryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getM4HistoryResponseDescriptor = $convert.base64Decode(
    'ChRHZXRNNEhpc3RvcnlSZXNwb25zZRIvCgdoaXN0b3J5GAEgAygLMhUubTQudjEuTTRIaXN0b3'
    'J5RW50cnlSB2hpc3Rvcnk=');

@$core.Deprecated('Use getVotePreferencesRequestDescriptor instead')
const GetVotePreferencesRequest$json = {
  '1': 'GetVotePreferencesRequest',
};

/// Descriptor for `GetVotePreferencesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getVotePreferencesRequestDescriptor = $convert.base64Decode(
    'ChlHZXRWb3RlUHJlZmVyZW5jZXNSZXF1ZXN0');

@$core.Deprecated('Use getVotePreferencesResponseDescriptor instead')
const GetVotePreferencesResponse$json = {
  '1': 'GetVotePreferencesResponse',
  '2': [
    {'1': 'preferences', '3': 1, '4': 3, '5': 11, '6': '.m4.v1.M4Vote', '10': 'preferences'},
  ],
};

/// Descriptor for `GetVotePreferencesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getVotePreferencesResponseDescriptor = $convert.base64Decode(
    'ChpHZXRWb3RlUHJlZmVyZW5jZXNSZXNwb25zZRIvCgtwcmVmZXJlbmNlcxgBIAMoCzINLm00Ln'
    'YxLk00Vm90ZVILcHJlZmVyZW5jZXM=');

@$core.Deprecated('Use setVotePreferenceRequestDescriptor instead')
const SetVotePreferenceRequest$json = {
  '1': 'SetVotePreferenceRequest',
  '2': [
    {'1': 'sidechain_slot', '3': 1, '4': 1, '5': 13, '10': 'sidechainSlot'},
    {'1': 'vote_type', '3': 2, '4': 1, '5': 9, '10': 'voteType'},
    {'1': 'bundle_hash', '3': 3, '4': 1, '5': 9, '9': 0, '10': 'bundleHash', '17': true},
  ],
  '8': [
    {'1': '_bundle_hash'},
  ],
};

/// Descriptor for `SetVotePreferenceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setVotePreferenceRequestDescriptor = $convert.base64Decode(
    'ChhTZXRWb3RlUHJlZmVyZW5jZVJlcXVlc3QSJQoOc2lkZWNoYWluX3Nsb3QYASABKA1SDXNpZG'
    'VjaGFpblNsb3QSGwoJdm90ZV90eXBlGAIgASgJUgh2b3RlVHlwZRIkCgtidW5kbGVfaGFzaBgD'
    'IAEoCUgAUgpidW5kbGVIYXNoiAEBQg4KDF9idW5kbGVfaGFzaA==');

@$core.Deprecated('Use setVotePreferenceResponseDescriptor instead')
const SetVotePreferenceResponse$json = {
  '1': 'SetVotePreferenceResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
  ],
};

/// Descriptor for `SetVotePreferenceResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setVotePreferenceResponseDescriptor = $convert.base64Decode(
    'ChlTZXRWb3RlUHJlZmVyZW5jZVJlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3M=');

@$core.Deprecated('Use generateM4BytesRequestDescriptor instead')
const GenerateM4BytesRequest$json = {
  '1': 'GenerateM4BytesRequest',
};

/// Descriptor for `GenerateM4BytesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List generateM4BytesRequestDescriptor = $convert.base64Decode(
    'ChZHZW5lcmF0ZU00Qnl0ZXNSZXF1ZXN0');

@$core.Deprecated('Use generateM4BytesResponseDescriptor instead')
const GenerateM4BytesResponse$json = {
  '1': 'GenerateM4BytesResponse',
  '2': [
    {'1': 'hex', '3': 1, '4': 1, '5': 9, '10': 'hex'},
    {'1': 'interpretation', '3': 2, '4': 1, '5': 9, '10': 'interpretation'},
  ],
};

/// Descriptor for `GenerateM4BytesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List generateM4BytesResponseDescriptor = $convert.base64Decode(
    'ChdHZW5lcmF0ZU00Qnl0ZXNSZXNwb25zZRIQCgNoZXgYASABKAlSA2hleBImCg5pbnRlcnByZX'
    'RhdGlvbhgCIAEoCVIOaW50ZXJwcmV0YXRpb24=');

const $core.Map<$core.String, $core.dynamic> M4ServiceBase$json = {
  '1': 'M4Service',
  '2': [
    {'1': 'GetM4History', '2': '.m4.v1.GetM4HistoryRequest', '3': '.m4.v1.GetM4HistoryResponse'},
    {'1': 'GetVotePreferences', '2': '.m4.v1.GetVotePreferencesRequest', '3': '.m4.v1.GetVotePreferencesResponse'},
    {'1': 'SetVotePreference', '2': '.m4.v1.SetVotePreferenceRequest', '3': '.m4.v1.SetVotePreferenceResponse'},
    {'1': 'GenerateM4Bytes', '2': '.m4.v1.GenerateM4BytesRequest', '3': '.m4.v1.GenerateM4BytesResponse'},
  ],
};

@$core.Deprecated('Use m4ServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> M4ServiceBase$messageJson = {
  '.m4.v1.GetM4HistoryRequest': GetM4HistoryRequest$json,
  '.m4.v1.GetM4HistoryResponse': GetM4HistoryResponse$json,
  '.m4.v1.M4HistoryEntry': M4HistoryEntry$json,
  '.m4.v1.M4Vote': M4Vote$json,
  '.m4.v1.GetVotePreferencesRequest': GetVotePreferencesRequest$json,
  '.m4.v1.GetVotePreferencesResponse': GetVotePreferencesResponse$json,
  '.m4.v1.SetVotePreferenceRequest': SetVotePreferenceRequest$json,
  '.m4.v1.SetVotePreferenceResponse': SetVotePreferenceResponse$json,
  '.m4.v1.GenerateM4BytesRequest': GenerateM4BytesRequest$json,
  '.m4.v1.GenerateM4BytesResponse': GenerateM4BytesResponse$json,
};

/// Descriptor for `M4Service`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List m4ServiceDescriptor = $convert.base64Decode(
    'CglNNFNlcnZpY2USRwoMR2V0TTRIaXN0b3J5EhoubTQudjEuR2V0TTRIaXN0b3J5UmVxdWVzdB'
    'obLm00LnYxLkdldE00SGlzdG9yeVJlc3BvbnNlElkKEkdldFZvdGVQcmVmZXJlbmNlcxIgLm00'
    'LnYxLkdldFZvdGVQcmVmZXJlbmNlc1JlcXVlc3QaIS5tNC52MS5HZXRWb3RlUHJlZmVyZW5jZX'
    'NSZXNwb25zZRJWChFTZXRWb3RlUHJlZmVyZW5jZRIfLm00LnYxLlNldFZvdGVQcmVmZXJlbmNl'
    'UmVxdWVzdBogLm00LnYxLlNldFZvdGVQcmVmZXJlbmNlUmVzcG9uc2USUAoPR2VuZXJhdGVNNE'
    'J5dGVzEh0ubTQudjEuR2VuZXJhdGVNNEJ5dGVzUmVxdWVzdBoeLm00LnYxLkdlbmVyYXRlTTRC'
    'eXRlc1Jlc3BvbnNl');

