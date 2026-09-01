//
//  Generated code. Do not modify.
//  source: bmm/v1/bmm.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use startRequestDescriptor instead')
const StartRequest$json = {
  '1': 'StartRequest',
  '2': [
    {'1': 'sidechain', '3': 1, '4': 1, '5': 14, '6': '.orchestrator.v1.BinaryType', '10': 'sidechain'},
    {'1': 'max_bid_sats', '3': 3, '4': 1, '5': 3, '10': 'maxBidSats'},
    {'1': 'wallet_id', '3': 4, '4': 1, '5': 9, '10': 'walletId'},
  ],
  '9': [
    {'1': 2, '2': 3},
  ],
};

/// Descriptor for `StartRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List startRequestDescriptor = $convert.base64Decode(
    'CgxTdGFydFJlcXVlc3QSOQoJc2lkZWNoYWluGAEgASgOMhsub3JjaGVzdHJhdG9yLnYxLkJpbm'
    'FyeVR5cGVSCXNpZGVjaGFpbhIgCgxtYXhfYmlkX3NhdHMYAyABKANSCm1heEJpZFNhdHMSGwoJ'
    'd2FsbGV0X2lkGAQgASgJUgh3YWxsZXRJZEoECAIQAw==');

@$core.Deprecated('Use startResponseDescriptor instead')
const StartResponse$json = {
  '1': 'StartResponse',
};

/// Descriptor for `StartResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List startResponseDescriptor = $convert.base64Decode(
    'Cg1TdGFydFJlc3BvbnNl');

@$core.Deprecated('Use stopRequestDescriptor instead')
const StopRequest$json = {
  '1': 'StopRequest',
  '2': [
    {'1': 'sidechain', '3': 1, '4': 1, '5': 14, '6': '.orchestrator.v1.BinaryType', '10': 'sidechain'},
  ],
};

/// Descriptor for `StopRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List stopRequestDescriptor = $convert.base64Decode(
    'CgtTdG9wUmVxdWVzdBI5CglzaWRlY2hhaW4YASABKA4yGy5vcmNoZXN0cmF0b3IudjEuQmluYX'
    'J5VHlwZVIJc2lkZWNoYWlu');

@$core.Deprecated('Use stopResponseDescriptor instead')
const StopResponse$json = {
  '1': 'StopResponse',
};

/// Descriptor for `StopResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List stopResponseDescriptor = $convert.base64Decode(
    'CgxTdG9wUmVzcG9uc2U=');

@$core.Deprecated('Use clearHistoryRequestDescriptor instead')
const ClearHistoryRequest$json = {
  '1': 'ClearHistoryRequest',
  '2': [
    {'1': 'sidechain', '3': 1, '4': 1, '5': 14, '6': '.orchestrator.v1.BinaryType', '10': 'sidechain'},
  ],
};

/// Descriptor for `ClearHistoryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clearHistoryRequestDescriptor = $convert.base64Decode(
    'ChNDbGVhckhpc3RvcnlSZXF1ZXN0EjkKCXNpZGVjaGFpbhgBIAEoDjIbLm9yY2hlc3RyYXRvci'
    '52MS5CaW5hcnlUeXBlUglzaWRlY2hhaW4=');

@$core.Deprecated('Use clearHistoryResponseDescriptor instead')
const ClearHistoryResponse$json = {
  '1': 'ClearHistoryResponse',
};

/// Descriptor for `ClearHistoryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clearHistoryResponseDescriptor = $convert.base64Decode(
    'ChRDbGVhckhpc3RvcnlSZXNwb25zZQ==');

@$core.Deprecated('Use watchRequestDescriptor instead')
const WatchRequest$json = {
  '1': 'WatchRequest',
  '2': [
    {'1': 'sidechain', '3': 1, '4': 1, '5': 14, '6': '.orchestrator.v1.BinaryType', '10': 'sidechain'},
  ],
};

/// Descriptor for `WatchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List watchRequestDescriptor = $convert.base64Decode(
    'CgxXYXRjaFJlcXVlc3QSOQoJc2lkZWNoYWluGAEgASgOMhsub3JjaGVzdHJhdG9yLnYxLkJpbm'
    'FyeVR5cGVSCXNpZGVjaGFpbg==');

@$core.Deprecated('Use watchResponseDescriptor instead')
const WatchResponse$json = {
  '1': 'WatchResponse',
  '2': [
    {'1': 'running', '3': 1, '4': 1, '5': 8, '10': 'running'},
    {'1': 'max_bid_sats', '3': 3, '4': 1, '5': 3, '10': 'maxBidSats'},
    {'1': 'current', '3': 4, '4': 1, '5': 11, '6': '.bmm.v1.Round', '10': 'current'},
    {'1': 'history', '3': 5, '4': 3, '5': 11, '6': '.bmm.v1.Round', '10': 'history'},
    {'1': 'wallet_id', '3': 6, '4': 1, '5': 9, '10': 'walletId'},
    {'1': 'next_block_fee_rate_sat_vb', '3': 7, '4': 1, '5': 1, '10': 'nextBlockFeeRateSatVb'},
  ],
  '9': [
    {'1': 2, '2': 3},
  ],
};

/// Descriptor for `WatchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List watchResponseDescriptor = $convert.base64Decode(
    'Cg1XYXRjaFJlc3BvbnNlEhgKB3J1bm5pbmcYASABKAhSB3J1bm5pbmcSIAoMbWF4X2JpZF9zYX'
    'RzGAMgASgDUgptYXhCaWRTYXRzEicKB2N1cnJlbnQYBCABKAsyDS5ibW0udjEuUm91bmRSB2N1'
    'cnJlbnQSJwoHaGlzdG9yeRgFIAMoCzINLmJtbS52MS5Sb3VuZFIHaGlzdG9yeRIbCgl3YWxsZX'
    'RfaWQYBiABKAlSCHdhbGxldElkEjkKGm5leHRfYmxvY2tfZmVlX3JhdGVfc2F0X3ZiGAcgASgB'
    'UhVuZXh0QmxvY2tGZWVSYXRlU2F0VmJKBAgCEAM=');

@$core.Deprecated('Use roundDescriptor instead')
const Round$json = {
  '1': 'Round',
  '2': [
    {'1': 'prev_main_hash', '3': 1, '4': 1, '5': 9, '10': 'prevMainHash'},
    {'1': 'prev_main_height', '3': 2, '4': 1, '5': 5, '10': 'prevMainHeight'},
    {'1': 'result', '3': 3, '4': 1, '5': 9, '10': 'result'},
    {'1': 'block_worth_sats', '3': 4, '4': 1, '5': 3, '10': 'blockWorthSats'},
    {'1': 'our_bids', '3': 5, '4': 3, '5': 11, '6': '.bmm.v1.Bid', '10': 'ourBids'},
    {'1': 'other_bids', '3': 6, '4': 3, '5': 11, '6': '.bmm.v1.Bid', '10': 'otherBids'},
    {'1': 'winner_critical_hash', '3': 7, '4': 1, '5': 9, '10': 'winnerCriticalHash'},
    {'1': 'winner_txid', '3': 8, '4': 1, '5': 9, '10': 'winnerTxid'},
    {'1': 'winner_bid_sats', '3': 9, '4': 1, '5': 3, '10': 'winnerBidSats'},
    {'1': 'included_in_block', '3': 10, '4': 1, '5': 9, '10': 'includedInBlock'},
    {'1': 'included_in_height', '3': 14, '4': 1, '5': 5, '10': 'includedInHeight'},
    {'1': 'profit_sats', '3': 11, '4': 1, '5': 3, '10': 'profitSats'},
    {'1': 'has_profit', '3': 12, '4': 1, '5': 8, '10': 'hasProfit'},
    {'1': 'started_at_unix', '3': 13, '4': 1, '5': 3, '10': 'startedAtUnix'},
  ],
};

/// Descriptor for `Round`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List roundDescriptor = $convert.base64Decode(
    'CgVSb3VuZBIkCg5wcmV2X21haW5faGFzaBgBIAEoCVIMcHJldk1haW5IYXNoEigKEHByZXZfbW'
    'Fpbl9oZWlnaHQYAiABKAVSDnByZXZNYWluSGVpZ2h0EhYKBnJlc3VsdBgDIAEoCVIGcmVzdWx0'
    'EigKEGJsb2NrX3dvcnRoX3NhdHMYBCABKANSDmJsb2NrV29ydGhTYXRzEiYKCG91cl9iaWRzGA'
    'UgAygLMgsuYm1tLnYxLkJpZFIHb3VyQmlkcxIqCgpvdGhlcl9iaWRzGAYgAygLMgsuYm1tLnYx'
    'LkJpZFIJb3RoZXJCaWRzEjAKFHdpbm5lcl9jcml0aWNhbF9oYXNoGAcgASgJUhJ3aW5uZXJDcm'
    'l0aWNhbEhhc2gSHwoLd2lubmVyX3R4aWQYCCABKAlSCndpbm5lclR4aWQSJgoPd2lubmVyX2Jp'
    'ZF9zYXRzGAkgASgDUg13aW5uZXJCaWRTYXRzEioKEWluY2x1ZGVkX2luX2Jsb2NrGAogASgJUg'
    '9pbmNsdWRlZEluQmxvY2sSLAoSaW5jbHVkZWRfaW5faGVpZ2h0GA4gASgFUhBpbmNsdWRlZElu'
    'SGVpZ2h0Eh8KC3Byb2ZpdF9zYXRzGAsgASgDUgpwcm9maXRTYXRzEh0KCmhhc19wcm9maXQYDC'
    'ABKAhSCWhhc1Byb2ZpdBImCg9zdGFydGVkX2F0X3VuaXgYDSABKANSDXN0YXJ0ZWRBdFVuaXg=');

@$core.Deprecated('Use bidDescriptor instead')
const Bid$json = {
  '1': 'Bid',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'critical_hash', '3': 2, '4': 1, '5': 9, '10': 'criticalHash'},
    {'1': 'bid_sats', '3': 3, '4': 1, '5': 3, '10': 'bidSats'},
    {'1': 'is_ours', '3': 4, '4': 1, '5': 8, '10': 'isOurs'},
    {'1': 'replaced_by_txid', '3': 5, '4': 1, '5': 9, '10': 'replacedByTxid'},
    {'1': 'state', '3': 6, '4': 1, '5': 9, '10': 'state'},
    {'1': 'error', '3': 7, '4': 1, '5': 9, '10': 'error'},
    {'1': 'prev_main_hash', '3': 8, '4': 1, '5': 9, '10': 'prevMainHash'},
  ],
};

/// Descriptor for `Bid`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List bidDescriptor = $convert.base64Decode(
    'CgNCaWQSEgoEdHhpZBgBIAEoCVIEdHhpZBIjCg1jcml0aWNhbF9oYXNoGAIgASgJUgxjcml0aW'
    'NhbEhhc2gSGQoIYmlkX3NhdHMYAyABKANSB2JpZFNhdHMSFwoHaXNfb3VycxgEIAEoCFIGaXNP'
    'dXJzEigKEHJlcGxhY2VkX2J5X3R4aWQYBSABKAlSDnJlcGxhY2VkQnlUeGlkEhQKBXN0YXRlGA'
    'YgASgJUgVzdGF0ZRIUCgVlcnJvchgHIAEoCVIFZXJyb3ISJAoOcHJldl9tYWluX2hhc2gYCCAB'
    'KAlSDHByZXZNYWluSGFzaA==');

@$core.Deprecated('Use getRoundBidsRequestDescriptor instead')
const GetRoundBidsRequest$json = {
  '1': 'GetRoundBidsRequest',
  '2': [
    {'1': 'sidechain', '3': 1, '4': 1, '5': 14, '6': '.orchestrator.v1.BinaryType', '10': 'sidechain'},
    {'1': 'prev_main_hash', '3': 2, '4': 1, '5': 9, '10': 'prevMainHash'},
  ],
};

/// Descriptor for `GetRoundBidsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getRoundBidsRequestDescriptor = $convert.base64Decode(
    'ChNHZXRSb3VuZEJpZHNSZXF1ZXN0EjkKCXNpZGVjaGFpbhgBIAEoDjIbLm9yY2hlc3RyYXRvci'
    '52MS5CaW5hcnlUeXBlUglzaWRlY2hhaW4SJAoOcHJldl9tYWluX2hhc2gYAiABKAlSDHByZXZN'
    'YWluSGFzaA==');

@$core.Deprecated('Use getRoundBidsResponseDescriptor instead')
const GetRoundBidsResponse$json = {
  '1': 'GetRoundBidsResponse',
  '2': [
    {'1': 'round', '3': 1, '4': 1, '5': 11, '6': '.bmm.v1.Round', '10': 'round'},
  ],
};

/// Descriptor for `GetRoundBidsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getRoundBidsResponseDescriptor = $convert.base64Decode(
    'ChRHZXRSb3VuZEJpZHNSZXNwb25zZRIjCgVyb3VuZBgBIAEoCzINLmJtbS52MS5Sb3VuZFIFcm'
    '91bmQ=');

@$core.Deprecated('Use createBidRequestDescriptor instead')
const CreateBidRequest$json = {
  '1': 'CreateBidRequest',
  '2': [
    {'1': 'sidechain', '3': 1, '4': 1, '5': 14, '6': '.orchestrator.v1.BinaryType', '10': 'sidechain'},
    {'1': 'wallet_id', '3': 2, '4': 1, '5': 9, '10': 'walletId'},
    {'1': 'bid_sats', '3': 3, '4': 1, '5': 3, '10': 'bidSats'},
    {'1': 'replace_txid', '3': 4, '4': 1, '5': 9, '10': 'replaceTxid'},
    {'1': 'expect_prev_main_hash', '3': 5, '4': 1, '5': 9, '10': 'expectPrevMainHash'},
    {'1': 'cap_to_block_worth', '3': 6, '4': 1, '5': 8, '10': 'capToBlockWorth'},
    {'1': 'fee_rate_sat_vb', '3': 7, '4': 1, '5': 1, '10': 'feeRateSatVb'},
    {'1': 'max_bid_sats', '3': 8, '4': 1, '5': 3, '10': 'maxBidSats'},
  ],
};

/// Descriptor for `CreateBidRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createBidRequestDescriptor = $convert.base64Decode(
    'ChBDcmVhdGVCaWRSZXF1ZXN0EjkKCXNpZGVjaGFpbhgBIAEoDjIbLm9yY2hlc3RyYXRvci52MS'
    '5CaW5hcnlUeXBlUglzaWRlY2hhaW4SGwoJd2FsbGV0X2lkGAIgASgJUgh3YWxsZXRJZBIZCghi'
    'aWRfc2F0cxgDIAEoA1IHYmlkU2F0cxIhCgxyZXBsYWNlX3R4aWQYBCABKAlSC3JlcGxhY2VUeG'
    'lkEjEKFWV4cGVjdF9wcmV2X21haW5faGFzaBgFIAEoCVISZXhwZWN0UHJldk1haW5IYXNoEisK'
    'EmNhcF90b19ibG9ja193b3J0aBgGIAEoCFIPY2FwVG9CbG9ja1dvcnRoEiUKD2ZlZV9yYXRlX3'
    'NhdF92YhgHIAEoAVIMZmVlUmF0ZVNhdFZiEiAKDG1heF9iaWRfc2F0cxgIIAEoA1IKbWF4Qmlk'
    'U2F0cw==');

@$core.Deprecated('Use createBidResponseDescriptor instead')
const CreateBidResponse$json = {
  '1': 'CreateBidResponse',
  '2': [
    {'1': 'critical_hash', '3': 1, '4': 1, '5': 9, '10': 'criticalHash'},
    {'1': 'bmm_txid', '3': 2, '4': 1, '5': 9, '10': 'bmmTxid'},
    {'1': 'fees_sats', '3': 3, '4': 1, '5': 3, '10': 'feesSats'},
    {'1': 'block_json', '3': 4, '4': 1, '5': 9, '10': 'blockJson'},
    {'1': 'prev_main_hash', '3': 5, '4': 1, '5': 9, '10': 'prevMainHash'},
    {'1': 'bid_sats', '3': 6, '4': 1, '5': 3, '10': 'bidSats'},
  ],
};

/// Descriptor for `CreateBidResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createBidResponseDescriptor = $convert.base64Decode(
    'ChFDcmVhdGVCaWRSZXNwb25zZRIjCg1jcml0aWNhbF9oYXNoGAEgASgJUgxjcml0aWNhbEhhc2'
    'gSGQoIYm1tX3R4aWQYAiABKAlSB2JtbVR4aWQSGwoJZmVlc19zYXRzGAMgASgDUghmZWVzU2F0'
    'cxIdCgpibG9ja19qc29uGAQgASgJUglibG9ja0pzb24SJAoOcHJldl9tYWluX2hhc2gYBSABKA'
    'lSDHByZXZNYWluSGFzaBIZCghiaWRfc2F0cxgGIAEoA1IHYmlkU2F0cw==');

@$core.Deprecated('Use connectBidRequestDescriptor instead')
const ConnectBidRequest$json = {
  '1': 'ConnectBidRequest',
  '2': [
    {'1': 'sidechain', '3': 1, '4': 1, '5': 14, '6': '.orchestrator.v1.BinaryType', '10': 'sidechain'},
    {'1': 'critical_hash', '3': 2, '4': 1, '5': 9, '10': 'criticalHash'},
    {'1': 'block_json', '3': 3, '4': 1, '5': 9, '10': 'blockJson'},
    {'1': 'main_block_hash', '3': 4, '4': 1, '5': 9, '10': 'mainBlockHash'},
  ],
};

/// Descriptor for `ConnectBidRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List connectBidRequestDescriptor = $convert.base64Decode(
    'ChFDb25uZWN0QmlkUmVxdWVzdBI5CglzaWRlY2hhaW4YASABKA4yGy5vcmNoZXN0cmF0b3Iudj'
    'EuQmluYXJ5VHlwZVIJc2lkZWNoYWluEiMKDWNyaXRpY2FsX2hhc2gYAiABKAlSDGNyaXRpY2Fs'
    'SGFzaBIdCgpibG9ja19qc29uGAMgASgJUglibG9ja0pzb24SJgoPbWFpbl9ibG9ja19oYXNoGA'
    'QgASgJUg1tYWluQmxvY2tIYXNo');

@$core.Deprecated('Use connectBidResponseDescriptor instead')
const ConnectBidResponse$json = {
  '1': 'ConnectBidResponse',
  '2': [
    {'1': 'connected', '3': 1, '4': 1, '5': 8, '10': 'connected'},
    {'1': 'main_block_hash', '3': 2, '4': 1, '5': 9, '10': 'mainBlockHash'},
  ],
};

/// Descriptor for `ConnectBidResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List connectBidResponseDescriptor = $convert.base64Decode(
    'ChJDb25uZWN0QmlkUmVzcG9uc2USHAoJY29ubmVjdGVkGAEgASgIUgljb25uZWN0ZWQSJgoPbW'
    'Fpbl9ibG9ja19oYXNoGAIgASgJUg1tYWluQmxvY2tIYXNo');

@$core.Deprecated('Use listBidsRequestDescriptor instead')
const ListBidsRequest$json = {
  '1': 'ListBidsRequest',
  '2': [
    {'1': 'sidechain', '3': 1, '4': 1, '5': 14, '6': '.orchestrator.v1.BinaryType', '10': 'sidechain'},
  ],
};

/// Descriptor for `ListBidsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listBidsRequestDescriptor = $convert.base64Decode(
    'Cg9MaXN0Qmlkc1JlcXVlc3QSOQoJc2lkZWNoYWluGAEgASgOMhsub3JjaGVzdHJhdG9yLnYxLk'
    'JpbmFyeVR5cGVSCXNpZGVjaGFpbg==');

@$core.Deprecated('Use listBidsResponseDescriptor instead')
const ListBidsResponse$json = {
  '1': 'ListBidsResponse',
  '2': [
    {'1': 'bids', '3': 1, '4': 3, '5': 11, '6': '.bmm.v1.Bid', '10': 'bids'},
  ],
};

/// Descriptor for `ListBidsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listBidsResponseDescriptor = $convert.base64Decode(
    'ChBMaXN0Qmlkc1Jlc3BvbnNlEh8KBGJpZHMYASADKAsyCy5ibW0udjEuQmlkUgRiaWRz');

const $core.Map<$core.String, $core.dynamic> BMMServiceBase$json = {
  '1': 'BMMService',
  '2': [
    {'1': 'Start', '2': '.bmm.v1.StartRequest', '3': '.bmm.v1.StartResponse'},
    {'1': 'Stop', '2': '.bmm.v1.StopRequest', '3': '.bmm.v1.StopResponse'},
    {'1': 'ClearHistory', '2': '.bmm.v1.ClearHistoryRequest', '3': '.bmm.v1.ClearHistoryResponse'},
    {'1': 'Watch', '2': '.bmm.v1.WatchRequest', '3': '.bmm.v1.WatchResponse', '6': true},
    {'1': 'GetRoundBids', '2': '.bmm.v1.GetRoundBidsRequest', '3': '.bmm.v1.GetRoundBidsResponse'},
    {'1': 'CreateBid', '2': '.bmm.v1.CreateBidRequest', '3': '.bmm.v1.CreateBidResponse'},
    {'1': 'ConnectBid', '2': '.bmm.v1.ConnectBidRequest', '3': '.bmm.v1.ConnectBidResponse'},
    {'1': 'ListBids', '2': '.bmm.v1.ListBidsRequest', '3': '.bmm.v1.ListBidsResponse'},
  ],
};

@$core.Deprecated('Use bMMServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> BMMServiceBase$messageJson = {
  '.bmm.v1.StartRequest': StartRequest$json,
  '.bmm.v1.StartResponse': StartResponse$json,
  '.bmm.v1.StopRequest': StopRequest$json,
  '.bmm.v1.StopResponse': StopResponse$json,
  '.bmm.v1.ClearHistoryRequest': ClearHistoryRequest$json,
  '.bmm.v1.ClearHistoryResponse': ClearHistoryResponse$json,
  '.bmm.v1.WatchRequest': WatchRequest$json,
  '.bmm.v1.WatchResponse': WatchResponse$json,
  '.bmm.v1.Round': Round$json,
  '.bmm.v1.Bid': Bid$json,
  '.bmm.v1.GetRoundBidsRequest': GetRoundBidsRequest$json,
  '.bmm.v1.GetRoundBidsResponse': GetRoundBidsResponse$json,
  '.bmm.v1.CreateBidRequest': CreateBidRequest$json,
  '.bmm.v1.CreateBidResponse': CreateBidResponse$json,
  '.bmm.v1.ConnectBidRequest': ConnectBidRequest$json,
  '.bmm.v1.ConnectBidResponse': ConnectBidResponse$json,
  '.bmm.v1.ListBidsRequest': ListBidsRequest$json,
  '.bmm.v1.ListBidsResponse': ListBidsResponse$json,
};

/// Descriptor for `BMMService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List bMMServiceDescriptor = $convert.base64Decode(
    'CgpCTU1TZXJ2aWNlEjQKBVN0YXJ0EhQuYm1tLnYxLlN0YXJ0UmVxdWVzdBoVLmJtbS52MS5TdG'
    'FydFJlc3BvbnNlEjEKBFN0b3ASEy5ibW0udjEuU3RvcFJlcXVlc3QaFC5ibW0udjEuU3RvcFJl'
    'c3BvbnNlEkkKDENsZWFySGlzdG9yeRIbLmJtbS52MS5DbGVhckhpc3RvcnlSZXF1ZXN0GhwuYm'
    '1tLnYxLkNsZWFySGlzdG9yeVJlc3BvbnNlEjYKBVdhdGNoEhQuYm1tLnYxLldhdGNoUmVxdWVz'
    'dBoVLmJtbS52MS5XYXRjaFJlc3BvbnNlMAESSQoMR2V0Um91bmRCaWRzEhsuYm1tLnYxLkdldF'
    'JvdW5kQmlkc1JlcXVlc3QaHC5ibW0udjEuR2V0Um91bmRCaWRzUmVzcG9uc2USQAoJQ3JlYXRl'
    'QmlkEhguYm1tLnYxLkNyZWF0ZUJpZFJlcXVlc3QaGS5ibW0udjEuQ3JlYXRlQmlkUmVzcG9uc2'
    'USQwoKQ29ubmVjdEJpZBIZLmJtbS52MS5Db25uZWN0QmlkUmVxdWVzdBoaLmJtbS52MS5Db25u'
    'ZWN0QmlkUmVzcG9uc2USPQoITGlzdEJpZHMSFy5ibW0udjEuTGlzdEJpZHNSZXF1ZXN0GhguYm'
    '1tLnYxLkxpc3RCaWRzUmVzcG9uc2U=');

