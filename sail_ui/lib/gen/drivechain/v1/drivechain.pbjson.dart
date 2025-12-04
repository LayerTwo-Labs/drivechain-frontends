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

@$core.Deprecated('Use proposeSidechainRequestDescriptor instead')
const ProposeSidechainRequest$json = {
  '1': 'ProposeSidechainRequest',
  '2': [
    {'1': 'slot', '3': 1, '4': 1, '5': 13, '10': 'slot'},
    {'1': 'title', '3': 2, '4': 1, '5': 9, '10': 'title'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    {'1': 'version', '3': 4, '4': 1, '5': 13, '10': 'version'},
    {'1': 'hashid1', '3': 5, '4': 1, '5': 9, '10': 'hashid1'},
    {'1': 'hashid2', '3': 6, '4': 1, '5': 9, '10': 'hashid2'},
  ],
};

/// Descriptor for `ProposeSidechainRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List proposeSidechainRequestDescriptor = $convert.base64Decode(
    'ChdQcm9wb3NlU2lkZWNoYWluUmVxdWVzdBISCgRzbG90GAEgASgNUgRzbG90EhQKBXRpdGxlGA'
    'IgASgJUgV0aXRsZRIgCgtkZXNjcmlwdGlvbhgDIAEoCVILZGVzY3JpcHRpb24SGAoHdmVyc2lv'
    'bhgEIAEoDVIHdmVyc2lvbhIYCgdoYXNoaWQxGAUgASgJUgdoYXNoaWQxEhgKB2hhc2hpZDIYBi'
    'ABKAlSB2hhc2hpZDI=');

@$core.Deprecated('Use proposeSidechainResponseDescriptor instead')
const ProposeSidechainResponse$json = {
  '1': 'ProposeSidechainResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'proposal_hash', '3': 2, '4': 1, '5': 9, '10': 'proposalHash'},
    {'1': 'message', '3': 3, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `ProposeSidechainResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List proposeSidechainResponseDescriptor = $convert.base64Decode(
    'ChhQcm9wb3NlU2lkZWNoYWluUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxIjCg'
    '1wcm9wb3NhbF9oYXNoGAIgASgJUgxwcm9wb3NhbEhhc2gSGAoHbWVzc2FnZRgDIAEoCVIHbWVz'
    'c2FnZQ==');

@$core.Deprecated('Use listWithdrawalsRequestDescriptor instead')
const ListWithdrawalsRequest$json = {
  '1': 'ListWithdrawalsRequest',
  '2': [
    {'1': 'sidechain_id', '3': 1, '4': 1, '5': 13, '10': 'sidechainId'},
    {'1': 'start_block_height', '3': 2, '4': 1, '5': 13, '10': 'startBlockHeight'},
    {'1': 'end_block_height', '3': 3, '4': 1, '5': 13, '10': 'endBlockHeight'},
  ],
};

/// Descriptor for `ListWithdrawalsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listWithdrawalsRequestDescriptor = $convert.base64Decode(
    'ChZMaXN0V2l0aGRyYXdhbHNSZXF1ZXN0EiEKDHNpZGVjaGFpbl9pZBgBIAEoDVILc2lkZWNoYW'
    'luSWQSLAoSc3RhcnRfYmxvY2tfaGVpZ2h0GAIgASgNUhBzdGFydEJsb2NrSGVpZ2h0EigKEGVu'
    'ZF9ibG9ja19oZWlnaHQYAyABKA1SDmVuZEJsb2NrSGVpZ2h0');

@$core.Deprecated('Use withdrawalBundleDescriptor instead')
const WithdrawalBundle$json = {
  '1': 'WithdrawalBundle',
  '2': [
    {'1': 'm6id', '3': 1, '4': 1, '5': 9, '10': 'm6id'},
    {'1': 'sidechain_id', '3': 2, '4': 1, '5': 13, '10': 'sidechainId'},
    {'1': 'status', '3': 3, '4': 1, '5': 9, '10': 'status'},
    {'1': 'sequence_number', '3': 4, '4': 1, '5': 4, '10': 'sequenceNumber'},
    {'1': 'transaction_hex', '3': 5, '4': 1, '5': 9, '10': 'transactionHex'},
    {'1': 'block_height', '3': 6, '4': 1, '5': 13, '10': 'blockHeight'},
    {'1': 'age', '3': 7, '4': 1, '5': 13, '10': 'age'},
    {'1': 'max_age', '3': 8, '4': 1, '5': 13, '10': 'maxAge'},
    {'1': 'blocks_left', '3': 9, '4': 1, '5': 13, '10': 'blocksLeft'},
  ],
};

/// Descriptor for `WithdrawalBundle`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List withdrawalBundleDescriptor = $convert.base64Decode(
    'ChBXaXRoZHJhd2FsQnVuZGxlEhIKBG02aWQYASABKAlSBG02aWQSIQoMc2lkZWNoYWluX2lkGA'
    'IgASgNUgtzaWRlY2hhaW5JZBIWCgZzdGF0dXMYAyABKAlSBnN0YXR1cxInCg9zZXF1ZW5jZV9u'
    'dW1iZXIYBCABKARSDnNlcXVlbmNlTnVtYmVyEicKD3RyYW5zYWN0aW9uX2hleBgFIAEoCVIOdH'
    'JhbnNhY3Rpb25IZXgSIQoMYmxvY2tfaGVpZ2h0GAYgASgNUgtibG9ja0hlaWdodBIQCgNhZ2UY'
    'ByABKA1SA2FnZRIXCgdtYXhfYWdlGAggASgNUgZtYXhBZ2USHwoLYmxvY2tzX2xlZnQYCSABKA'
    '1SCmJsb2Nrc0xlZnQ=');

@$core.Deprecated('Use listWithdrawalsResponseDescriptor instead')
const ListWithdrawalsResponse$json = {
  '1': 'ListWithdrawalsResponse',
  '2': [
    {'1': 'bundles', '3': 1, '4': 3, '5': 11, '6': '.drivechain.v1.WithdrawalBundle', '10': 'bundles'},
  ],
};

/// Descriptor for `ListWithdrawalsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listWithdrawalsResponseDescriptor = $convert.base64Decode(
    'ChdMaXN0V2l0aGRyYXdhbHNSZXNwb25zZRI5CgdidW5kbGVzGAEgAygLMh8uZHJpdmVjaGFpbi'
    '52MS5XaXRoZHJhd2FsQnVuZGxlUgdidW5kbGVz');

const $core.Map<$core.String, $core.dynamic> DrivechainServiceBase$json = {
  '1': 'DrivechainService',
  '2': [
    {'1': 'ListSidechains', '2': '.drivechain.v1.ListSidechainsRequest', '3': '.drivechain.v1.ListSidechainsResponse'},
    {'1': 'ListSidechainProposals', '2': '.drivechain.v1.ListSidechainProposalsRequest', '3': '.drivechain.v1.ListSidechainProposalsResponse'},
    {'1': 'ProposeSidechain', '2': '.drivechain.v1.ProposeSidechainRequest', '3': '.drivechain.v1.ProposeSidechainResponse'},
    {'1': 'ListWithdrawals', '2': '.drivechain.v1.ListWithdrawalsRequest', '3': '.drivechain.v1.ListWithdrawalsResponse'},
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
  '.drivechain.v1.ProposeSidechainRequest': ProposeSidechainRequest$json,
  '.drivechain.v1.ProposeSidechainResponse': ProposeSidechainResponse$json,
  '.drivechain.v1.ListWithdrawalsRequest': ListWithdrawalsRequest$json,
  '.drivechain.v1.ListWithdrawalsResponse': ListWithdrawalsResponse$json,
  '.drivechain.v1.WithdrawalBundle': WithdrawalBundle$json,
};

/// Descriptor for `DrivechainService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List drivechainServiceDescriptor = $convert.base64Decode(
    'ChFEcml2ZWNoYWluU2VydmljZRJdCg5MaXN0U2lkZWNoYWlucxIkLmRyaXZlY2hhaW4udjEuTG'
    'lzdFNpZGVjaGFpbnNSZXF1ZXN0GiUuZHJpdmVjaGFpbi52MS5MaXN0U2lkZWNoYWluc1Jlc3Bv'
    'bnNlEnUKFkxpc3RTaWRlY2hhaW5Qcm9wb3NhbHMSLC5kcml2ZWNoYWluLnYxLkxpc3RTaWRlY2'
    'hhaW5Qcm9wb3NhbHNSZXF1ZXN0Gi0uZHJpdmVjaGFpbi52MS5MaXN0U2lkZWNoYWluUHJvcG9z'
    'YWxzUmVzcG9uc2USYwoQUHJvcG9zZVNpZGVjaGFpbhImLmRyaXZlY2hhaW4udjEuUHJvcG9zZV'
    'NpZGVjaGFpblJlcXVlc3QaJy5kcml2ZWNoYWluLnYxLlByb3Bvc2VTaWRlY2hhaW5SZXNwb25z'
    'ZRJgCg9MaXN0V2l0aGRyYXdhbHMSJS5kcml2ZWNoYWluLnYxLkxpc3RXaXRoZHJhd2Fsc1JlcX'
    'Vlc3QaJi5kcml2ZWNoYWluLnYxLkxpc3RXaXRoZHJhd2Fsc1Jlc3BvbnNl');

