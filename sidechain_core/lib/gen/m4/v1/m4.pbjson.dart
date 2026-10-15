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

@$core.Deprecated('Use votePolicyDescriptor instead')
const VotePolicy$json = {
  '1': 'VotePolicy',
  '2': [
    {'1': 'VOTE_POLICY_UNSPECIFIED', '2': 0},
    {'1': 'VOTE_POLICY_ABSTAIN', '2': 1},
    {'1': 'VOTE_POLICY_UPVOTE_KNOWN', '2': 2},
    {'1': 'VOTE_POLICY_UPVOTE_ALL', '2': 3},
    {'1': 'VOTE_POLICY_ALARM', '2': 4},
  ],
};

/// Descriptor for `VotePolicy`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List votePolicyDescriptor = $convert.base64Decode(
    'CgpWb3RlUG9saWN5EhsKF1ZPVEVfUE9MSUNZX1VOU1BFQ0lGSUVEEAASFwoTVk9URV9QT0xJQ1'
    'lfQUJTVEFJThABEhwKGFZPVEVfUE9MSUNZX1VQVk9URV9LTk9XThACEhoKFlZPVEVfUE9MSUNZ'
    'X1VQVk9URV9BTEwQAxIVChFWT1RFX1BPTElDWV9BTEFSTRAE');

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

@$core.Deprecated('Use bundleUpvoteDescriptor instead')
const BundleUpvote$json = {
  '1': 'BundleUpvote',
  '2': [
    {'1': 'sidechain_slot', '3': 1, '4': 1, '5': 13, '10': 'sidechainSlot'},
    {'1': 'm6id', '3': 2, '4': 1, '5': 9, '10': 'm6id'},
  ],
};

/// Descriptor for `BundleUpvote`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List bundleUpvoteDescriptor = $convert.base64Decode(
    'CgxCdW5kbGVVcHZvdGUSJQoOc2lkZWNoYWluX3Nsb3QYASABKA1SDXNpZGVjaGFpblNsb3QSEg'
    'oEbTZpZBgCIAEoCVIEbTZpZA==');

@$core.Deprecated('Use getVotesRequestDescriptor instead')
const GetVotesRequest$json = {
  '1': 'GetVotesRequest',
};

/// Descriptor for `GetVotesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getVotesRequestDescriptor = $convert.base64Decode(
    'Cg9HZXRWb3Rlc1JlcXVlc3Q=');

@$core.Deprecated('Use getVotesResponseDescriptor instead')
const GetVotesResponse$json = {
  '1': 'GetVotesResponse',
  '2': [
    {'1': 'policy', '3': 1, '4': 1, '5': 14, '6': '.m4.v1.VotePolicy', '10': 'policy'},
    {'1': 'upvotes', '3': 2, '4': 3, '5': 11, '6': '.m4.v1.BundleUpvote', '10': 'upvotes'},
  ],
};

/// Descriptor for `GetVotesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getVotesResponseDescriptor = $convert.base64Decode(
    'ChBHZXRWb3Rlc1Jlc3BvbnNlEikKBnBvbGljeRgBIAEoDjIRLm00LnYxLlZvdGVQb2xpY3lSBn'
    'BvbGljeRItCgd1cHZvdGVzGAIgAygLMhMubTQudjEuQnVuZGxlVXB2b3RlUgd1cHZvdGVz');

@$core.Deprecated('Use setBundleUpvoteRequestDescriptor instead')
const SetBundleUpvoteRequest$json = {
  '1': 'SetBundleUpvoteRequest',
  '2': [
    {'1': 'sidechain_slot', '3': 1, '4': 1, '5': 13, '10': 'sidechainSlot'},
    {'1': 'm6id', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'm6id', '17': true},
  ],
  '8': [
    {'1': '_m6id'},
  ],
};

/// Descriptor for `SetBundleUpvoteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setBundleUpvoteRequestDescriptor = $convert.base64Decode(
    'ChZTZXRCdW5kbGVVcHZvdGVSZXF1ZXN0EiUKDnNpZGVjaGFpbl9zbG90GAEgASgNUg1zaWRlY2'
    'hhaW5TbG90EhcKBG02aWQYAiABKAlIAFIEbTZpZIgBAUIHCgVfbTZpZA==');

@$core.Deprecated('Use setBundleUpvoteResponseDescriptor instead')
const SetBundleUpvoteResponse$json = {
  '1': 'SetBundleUpvoteResponse',
};

/// Descriptor for `SetBundleUpvoteResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setBundleUpvoteResponseDescriptor = $convert.base64Decode(
    'ChdTZXRCdW5kbGVVcHZvdGVSZXNwb25zZQ==');

@$core.Deprecated('Use setVotePolicyRequestDescriptor instead')
const SetVotePolicyRequest$json = {
  '1': 'SetVotePolicyRequest',
  '2': [
    {'1': 'policy', '3': 1, '4': 1, '5': 14, '6': '.m4.v1.VotePolicy', '10': 'policy'},
  ],
};

/// Descriptor for `SetVotePolicyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setVotePolicyRequestDescriptor = $convert.base64Decode(
    'ChRTZXRWb3RlUG9saWN5UmVxdWVzdBIpCgZwb2xpY3kYASABKA4yES5tNC52MS5Wb3RlUG9saW'
    'N5UgZwb2xpY3k=');

@$core.Deprecated('Use setVotePolicyResponseDescriptor instead')
const SetVotePolicyResponse$json = {
  '1': 'SetVotePolicyResponse',
};

/// Descriptor for `SetVotePolicyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setVotePolicyResponseDescriptor = $convert.base64Decode(
    'ChVTZXRWb3RlUG9saWN5UmVzcG9uc2U=');

const $core.Map<$core.String, $core.dynamic> M4ServiceBase$json = {
  '1': 'M4Service',
  '2': [
    {'1': 'GetM4History', '2': '.m4.v1.GetM4HistoryRequest', '3': '.m4.v1.GetM4HistoryResponse'},
    {'1': 'GetVotes', '2': '.m4.v1.GetVotesRequest', '3': '.m4.v1.GetVotesResponse'},
    {'1': 'SetBundleUpvote', '2': '.m4.v1.SetBundleUpvoteRequest', '3': '.m4.v1.SetBundleUpvoteResponse'},
    {'1': 'SetVotePolicy', '2': '.m4.v1.SetVotePolicyRequest', '3': '.m4.v1.SetVotePolicyResponse'},
  ],
};

@$core.Deprecated('Use m4ServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> M4ServiceBase$messageJson = {
  '.m4.v1.GetM4HistoryRequest': GetM4HistoryRequest$json,
  '.m4.v1.GetM4HistoryResponse': GetM4HistoryResponse$json,
  '.m4.v1.M4HistoryEntry': M4HistoryEntry$json,
  '.m4.v1.M4Vote': M4Vote$json,
  '.m4.v1.GetVotesRequest': GetVotesRequest$json,
  '.m4.v1.GetVotesResponse': GetVotesResponse$json,
  '.m4.v1.BundleUpvote': BundleUpvote$json,
  '.m4.v1.SetBundleUpvoteRequest': SetBundleUpvoteRequest$json,
  '.m4.v1.SetBundleUpvoteResponse': SetBundleUpvoteResponse$json,
  '.m4.v1.SetVotePolicyRequest': SetVotePolicyRequest$json,
  '.m4.v1.SetVotePolicyResponse': SetVotePolicyResponse$json,
};

/// Descriptor for `M4Service`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List m4ServiceDescriptor = $convert.base64Decode(
    'CglNNFNlcnZpY2USRwoMR2V0TTRIaXN0b3J5EhoubTQudjEuR2V0TTRIaXN0b3J5UmVxdWVzdB'
    'obLm00LnYxLkdldE00SGlzdG9yeVJlc3BvbnNlEjsKCEdldFZvdGVzEhYubTQudjEuR2V0Vm90'
    'ZXNSZXF1ZXN0GhcubTQudjEuR2V0Vm90ZXNSZXNwb25zZRJQCg9TZXRCdW5kbGVVcHZvdGUSHS'
    '5tNC52MS5TZXRCdW5kbGVVcHZvdGVSZXF1ZXN0Gh4ubTQudjEuU2V0QnVuZGxlVXB2b3RlUmVz'
    'cG9uc2USSgoNU2V0Vm90ZVBvbGljeRIbLm00LnYxLlNldFZvdGVQb2xpY3lSZXF1ZXN0GhwubT'
    'QudjEuU2V0Vm90ZVBvbGljeVJlc3BvbnNl');

