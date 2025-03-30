//
//  Generated code. Do not modify.
//  source: drivechain/v1/drivechain.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use listSidechainsRequestDescriptor instead')
const ListSidechainsRequest$json = {
  '1': 'ListSidechainsRequest',
};

/// Descriptor for `ListSidechainsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listSidechainsRequestDescriptor = $convert.base64Decode(
    'ChVMaXN0U2lkZWNoYWluc1JlcXVlc3Q=');

@$core.Deprecated('Use listSidechainsResponseDescriptor instead')
const ListSidechainsResponse$json = {
  '1': 'ListSidechainsResponse',
  '2': [
    {'1': 'sidechains', '3': 1, '4': 3, '5': 11, '6': '.drivechain.v1.ListSidechainsResponse.Sidechain', '10': 'sidechains'},
  ],
  '3': [ListSidechainsResponse_Sidechain$json],
};

@$core.Deprecated('Use listSidechainsResponseDescriptor instead')
const ListSidechainsResponse_Sidechain$json = {
  '1': 'Sidechain',
  '2': [
    {'1': 'title', '3': 1, '4': 1, '5': 9, '10': 'title'},
    {'1': 'description', '3': 2, '4': 1, '5': 9, '10': 'description'},
    {'1': 'nversion', '3': 3, '4': 1, '5': 13, '10': 'nversion'},
    {'1': 'hashid1', '3': 4, '4': 1, '5': 9, '10': 'hashid1'},
    {'1': 'hashid2', '3': 5, '4': 1, '5': 9, '10': 'hashid2'},
    {'1': 'slot', '3': 6, '4': 1, '5': 13, '10': 'slot'},
    {'1': 'vote_count', '3': 7, '4': 1, '5': 13, '10': 'voteCount'},
    {'1': 'proposal_height', '3': 8, '4': 1, '5': 13, '10': 'proposalHeight'},
    {'1': 'activation_height', '3': 9, '4': 1, '5': 13, '10': 'activationHeight'},
    {'1': 'description_hex', '3': 10, '4': 1, '5': 9, '10': 'descriptionHex'},
    {'1': 'balance_satoshi', '3': 11, '4': 1, '5': 3, '10': 'balanceSatoshi'},
    {'1': 'chaintip_txid', '3': 12, '4': 1, '5': 9, '10': 'chaintipTxid'},
    {'1': 'chaintip_vout', '3': 13, '4': 1, '5': 13, '10': 'chaintipVout'},
  ],
};

/// Descriptor for `ListSidechainsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listSidechainsResponseDescriptor = $convert.base64Decode(
    'ChZMaXN0U2lkZWNoYWluc1Jlc3BvbnNlEk8KCnNpZGVjaGFpbnMYASADKAsyLy5kcml2ZWNoYW'
    'luLnYxLkxpc3RTaWRlY2hhaW5zUmVzcG9uc2UuU2lkZWNoYWluUgpzaWRlY2hhaW5zGrgDCglT'
    'aWRlY2hhaW4SFAoFdGl0bGUYASABKAlSBXRpdGxlEiAKC2Rlc2NyaXB0aW9uGAIgASgJUgtkZX'
    'NjcmlwdGlvbhIaCghudmVyc2lvbhgDIAEoDVIIbnZlcnNpb24SGAoHaGFzaGlkMRgEIAEoCVIH'
    'aGFzaGlkMRIYCgdoYXNoaWQyGAUgASgJUgdoYXNoaWQyEhIKBHNsb3QYBiABKA1SBHNsb3QSHQ'
    'oKdm90ZV9jb3VudBgHIAEoDVIJdm90ZUNvdW50EicKD3Byb3Bvc2FsX2hlaWdodBgIIAEoDVIO'
    'cHJvcG9zYWxIZWlnaHQSKwoRYWN0aXZhdGlvbl9oZWlnaHQYCSABKA1SEGFjdGl2YXRpb25IZW'
    'lnaHQSJwoPZGVzY3JpcHRpb25faGV4GAogASgJUg5kZXNjcmlwdGlvbkhleBInCg9iYWxhbmNl'
    'X3NhdG9zaGkYCyABKANSDmJhbGFuY2VTYXRvc2hpEiMKDWNoYWludGlwX3R4aWQYDCABKAlSDG'
    'NoYWludGlwVHhpZBIjCg1jaGFpbnRpcF92b3V0GA0gASgNUgxjaGFpbnRpcFZvdXQ=');

@$core.Deprecated('Use listSidechainProposalsRequestDescriptor instead')
const ListSidechainProposalsRequest$json = {
  '1': 'ListSidechainProposalsRequest',
};

/// Descriptor for `ListSidechainProposalsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listSidechainProposalsRequestDescriptor = $convert.base64Decode(
    'Ch1MaXN0U2lkZWNoYWluUHJvcG9zYWxzUmVxdWVzdA==');

@$core.Deprecated('Use sidechainProposalDescriptor instead')
const SidechainProposal$json = {
  '1': 'SidechainProposal',
  '2': [
    {'1': 'slot', '3': 1, '4': 1, '5': 13, '10': 'slot'},
    {'1': 'data', '3': 2, '4': 1, '5': 12, '10': 'data'},
    {'1': 'data_hash', '3': 3, '4': 1, '5': 9, '10': 'dataHash'},
    {'1': 'vote_count', '3': 4, '4': 1, '5': 13, '10': 'voteCount'},
    {'1': 'proposal_height', '3': 5, '4': 1, '5': 13, '10': 'proposalHeight'},
    {'1': 'proposal_age', '3': 6, '4': 1, '5': 13, '10': 'proposalAge'},
  ],
};

/// Descriptor for `SidechainProposal`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sidechainProposalDescriptor = $convert.base64Decode(
    'ChFTaWRlY2hhaW5Qcm9wb3NhbBISCgRzbG90GAEgASgNUgRzbG90EhIKBGRhdGEYAiABKAxSBG'
    'RhdGESGwoJZGF0YV9oYXNoGAMgASgJUghkYXRhSGFzaBIdCgp2b3RlX2NvdW50GAQgASgNUgl2'
    'b3RlQ291bnQSJwoPcHJvcG9zYWxfaGVpZ2h0GAUgASgNUg5wcm9wb3NhbEhlaWdodBIhCgxwcm'
    '9wb3NhbF9hZ2UYBiABKA1SC3Byb3Bvc2FsQWdl');

@$core.Deprecated('Use listSidechainProposalsResponseDescriptor instead')
const ListSidechainProposalsResponse$json = {
  '1': 'ListSidechainProposalsResponse',
  '2': [
    {'1': 'proposals', '3': 1, '4': 3, '5': 11, '6': '.drivechain.v1.SidechainProposal', '10': 'proposals'},
  ],
};

/// Descriptor for `ListSidechainProposalsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listSidechainProposalsResponseDescriptor = $convert.base64Decode(
    'Ch5MaXN0U2lkZWNoYWluUHJvcG9zYWxzUmVzcG9uc2USPgoJcHJvcG9zYWxzGAEgAygLMiAuZH'
    'JpdmVjaGFpbi52MS5TaWRlY2hhaW5Qcm9wb3NhbFIJcHJvcG9zYWxz');

const $core.Map<$core.String, $core.dynamic> DrivechainServiceBase$json = {
  '1': 'DrivechainService',
  '2': [
    {'1': 'ListSidechains', '2': '.drivechain.v1.ListSidechainsRequest', '3': '.drivechain.v1.ListSidechainsResponse'},
    {'1': 'ListSidechainProposals', '2': '.drivechain.v1.ListSidechainProposalsRequest', '3': '.drivechain.v1.ListSidechainProposalsResponse'},
  ],
};

@$core.Deprecated('Use drivechainServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> DrivechainServiceBase$messageJson = {
  '.drivechain.v1.ListSidechainsRequest': ListSidechainsRequest$json,
  '.drivechain.v1.ListSidechainsResponse': ListSidechainsResponse$json,
  '.drivechain.v1.ListSidechainsResponse.Sidechain': ListSidechainsResponse_Sidechain$json,
  '.drivechain.v1.ListSidechainProposalsRequest': ListSidechainProposalsRequest$json,
  '.drivechain.v1.ListSidechainProposalsResponse': ListSidechainProposalsResponse$json,
  '.drivechain.v1.SidechainProposal': SidechainProposal$json,
};

/// Descriptor for `DrivechainService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List drivechainServiceDescriptor = $convert.base64Decode(
    'ChFEcml2ZWNoYWluU2VydmljZRJdCg5MaXN0U2lkZWNoYWlucxIkLmRyaXZlY2hhaW4udjEuTG'
    'lzdFNpZGVjaGFpbnNSZXF1ZXN0GiUuZHJpdmVjaGFpbi52MS5MaXN0U2lkZWNoYWluc1Jlc3Bv'
    'bnNlEnUKFkxpc3RTaWRlY2hhaW5Qcm9wb3NhbHMSLC5kcml2ZWNoYWluLnYxLkxpc3RTaWRlY2'
    'hhaW5Qcm9wb3NhbHNSZXF1ZXN0Gi0uZHJpdmVjaGFpbi52MS5MaXN0U2lkZWNoYWluUHJvcG9z'
    'YWxzUmVzcG9uc2U=');

