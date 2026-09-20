//
//  Generated code. Do not modify.
//  source: stratum/v1/stratum.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

import '../../google/protobuf/timestamp.pbjson.dart' as $14;

@$core.Deprecated('Use targetKindDescriptor instead')
const TargetKind$json = {
  '1': 'TargetKind',
  '2': [
    {'1': 'TARGET_KIND_UNSPECIFIED', '2': 0},
    {'1': 'TARGET_KIND_SOLO', '2': 1},
    {'1': 'TARGET_KIND_POOL', '2': 2},
    {'1': 'TARGET_KIND_CUSTOM', '2': 3},
  ],
};

/// Descriptor for `TargetKind`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List targetKindDescriptor = $convert.base64Decode(
    'CgpUYXJnZXRLaW5kEhsKF1RBUkdFVF9LSU5EX1VOU1BFQ0lGSUVEEAASFAoQVEFSR0VUX0tJTk'
    'RfU09MTxABEhQKEFRBUkdFVF9LSU5EX1BPT0wQAhIWChJUQVJHRVRfS0lORF9DVVNUT00QAw==');

@$core.Deprecated('Use workModeDescriptor instead')
const WorkMode$json = {
  '1': 'WorkMode',
  '2': [
    {'1': 'WORK_MODE_UNSPECIFIED', '2': 0},
    {'1': 'WORK_MODE_LOW', '2': 1},
    {'1': 'WORK_MODE_MID', '2': 2},
    {'1': 'WORK_MODE_HIGH', '2': 3},
  ],
};

/// Descriptor for `WorkMode`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List workModeDescriptor = $convert.base64Decode(
    'CghXb3JrTW9kZRIZChVXT1JLX01PREVfVU5TUEVDSUZJRUQQABIRCg1XT1JLX01PREVfTE9XEA'
    'ESEQoNV09SS19NT0RFX01JRBACEhIKDldPUktfTU9ERV9ISUdIEAM=');

@$core.Deprecated('Use hashrateRangeDescriptor instead')
const HashrateRange$json = {
  '1': 'HashrateRange',
  '2': [
    {'1': 'HASHRATE_RANGE_UNSPECIFIED', '2': 0},
    {'1': 'HASHRATE_RANGE_HOUR', '2': 1},
    {'1': 'HASHRATE_RANGE_DAY', '2': 2},
    {'1': 'HASHRATE_RANGE_WEEK', '2': 3},
  ],
};

/// Descriptor for `HashrateRange`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List hashrateRangeDescriptor = $convert.base64Decode(
    'Cg1IYXNocmF0ZVJhbmdlEh4KGkhBU0hSQVRFX1JBTkdFX1VOU1BFQ0lGSUVEEAASFwoTSEFTSF'
    'JBVEVfUkFOR0VfSE9VUhABEhYKEkhBU0hSQVRFX1JBTkdFX0RBWRACEhcKE0hBU0hSQVRFX1JB'
    'TkdFX1dFRUsQAw==');

@$core.Deprecated('Use startStratumRequestDescriptor instead')
const StartStratumRequest$json = {
  '1': 'StartStratumRequest',
  '2': [
    {'1': 'port', '3': 1, '4': 1, '5': 13, '10': 'port'},
  ],
};

/// Descriptor for `StartStratumRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List startStratumRequestDescriptor = $convert.base64Decode(
    'ChNTdGFydFN0cmF0dW1SZXF1ZXN0EhIKBHBvcnQYASABKA1SBHBvcnQ=');

@$core.Deprecated('Use startStratumResponseDescriptor instead')
const StartStratumResponse$json = {
  '1': 'StartStratumResponse',
};

/// Descriptor for `StartStratumResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List startStratumResponseDescriptor = $convert.base64Decode(
    'ChRTdGFydFN0cmF0dW1SZXNwb25zZQ==');

@$core.Deprecated('Use stopStratumRequestDescriptor instead')
const StopStratumRequest$json = {
  '1': 'StopStratumRequest',
};

/// Descriptor for `StopStratumRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List stopStratumRequestDescriptor = $convert.base64Decode(
    'ChJTdG9wU3RyYXR1bVJlcXVlc3Q=');

@$core.Deprecated('Use stopStratumResponseDescriptor instead')
const StopStratumResponse$json = {
  '1': 'StopStratumResponse',
};

/// Descriptor for `StopStratumResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List stopStratumResponseDescriptor = $convert.base64Decode(
    'ChNTdG9wU3RyYXR1bVJlc3BvbnNl');

@$core.Deprecated('Use getStratumStatusRequestDescriptor instead')
const GetStratumStatusRequest$json = {
  '1': 'GetStratumStatusRequest',
};

/// Descriptor for `GetStratumStatusRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getStratumStatusRequestDescriptor = $convert.base64Decode(
    'ChdHZXRTdHJhdHVtU3RhdHVzUmVxdWVzdA==');

@$core.Deprecated('Use targetDescriptor instead')
const Target$json = {
  '1': 'Target',
  '2': [
    {'1': 'kind', '3': 1, '4': 1, '5': 14, '6': '.stratum.v1.TargetKind', '10': 'kind'},
    {'1': 'pool_id', '3': 2, '4': 1, '5': 9, '10': 'poolId'},
    {'1': 'url', '3': 3, '4': 1, '5': 9, '10': 'url'},
    {'1': 'worker', '3': 4, '4': 1, '5': 9, '10': 'worker'},
    {'1': 'password', '3': 5, '4': 1, '5': 9, '10': 'password'},
  ],
};

/// Descriptor for `Target`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List targetDescriptor = $convert.base64Decode(
    'CgZUYXJnZXQSKgoEa2luZBgBIAEoDjIWLnN0cmF0dW0udjEuVGFyZ2V0S2luZFIEa2luZBIXCg'
    'dwb29sX2lkGAIgASgJUgZwb29sSWQSEAoDdXJsGAMgASgJUgN1cmwSFgoGd29ya2VyGAQgASgJ'
    'UgZ3b3JrZXISGgoIcGFzc3dvcmQYBSABKAlSCHBhc3N3b3Jk');

@$core.Deprecated('Use miningSettingsDescriptor instead')
const MiningSettings$json = {
  '1': 'MiningSettings',
  '2': [
    {'1': 'port', '3': 1, '4': 1, '5': 13, '10': 'port'},
    {'1': 'cpu_mining', '3': 2, '4': 1, '5': 8, '10': 'cpuMining'},
    {'1': 'cpu_threads', '3': 3, '4': 1, '5': 13, '10': 'cpuThreads'},
    {'1': 'keep_mining_on_close', '3': 4, '4': 1, '5': 8, '10': 'keepMiningOnClose'},
  ],
};

/// Descriptor for `MiningSettings`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List miningSettingsDescriptor = $convert.base64Decode(
    'Cg5NaW5pbmdTZXR0aW5ncxISCgRwb3J0GAEgASgNUgRwb3J0Eh0KCmNwdV9taW5pbmcYAiABKA'
    'hSCWNwdU1pbmluZxIfCgtjcHVfdGhyZWFkcxgDIAEoDVIKY3B1VGhyZWFkcxIvChRrZWVwX21p'
    'bmluZ19vbl9jbG9zZRgEIAEoCFIRa2VlcE1pbmluZ09uQ2xvc2U=');

@$core.Deprecated('Use setMiningSettingsRequestDescriptor instead')
const SetMiningSettingsRequest$json = {
  '1': 'SetMiningSettingsRequest',
  '2': [
    {'1': 'port', '3': 1, '4': 1, '5': 13, '9': 0, '10': 'port', '17': true},
    {'1': 'cpu_mining', '3': 2, '4': 1, '5': 8, '9': 1, '10': 'cpuMining', '17': true},
    {'1': 'cpu_threads', '3': 3, '4': 1, '5': 13, '9': 2, '10': 'cpuThreads', '17': true},
    {'1': 'keep_mining_on_close', '3': 4, '4': 1, '5': 8, '9': 3, '10': 'keepMiningOnClose', '17': true},
  ],
  '8': [
    {'1': '_port'},
    {'1': '_cpu_mining'},
    {'1': '_cpu_threads'},
    {'1': '_keep_mining_on_close'},
  ],
};

/// Descriptor for `SetMiningSettingsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setMiningSettingsRequestDescriptor = $convert.base64Decode(
    'ChhTZXRNaW5pbmdTZXR0aW5nc1JlcXVlc3QSFwoEcG9ydBgBIAEoDUgAUgRwb3J0iAEBEiIKCm'
    'NwdV9taW5pbmcYAiABKAhIAVIJY3B1TWluaW5niAEBEiQKC2NwdV90aHJlYWRzGAMgASgNSAJS'
    'CmNwdVRocmVhZHOIAQESNAoUa2VlcF9taW5pbmdfb25fY2xvc2UYBCABKAhIA1IRa2VlcE1pbm'
    'luZ09uQ2xvc2WIAQFCBwoFX3BvcnRCDQoLX2NwdV9taW5pbmdCDgoMX2NwdV90aHJlYWRzQhcK'
    'FV9rZWVwX21pbmluZ19vbl9jbG9zZQ==');

@$core.Deprecated('Use setMiningSettingsResponseDescriptor instead')
const SetMiningSettingsResponse$json = {
  '1': 'SetMiningSettingsResponse',
};

/// Descriptor for `SetMiningSettingsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setMiningSettingsResponseDescriptor = $convert.base64Decode(
    'ChlTZXRNaW5pbmdTZXR0aW5nc1Jlc3BvbnNl');

@$core.Deprecated('Use hashratePointDescriptor instead')
const HashratePoint$json = {
  '1': 'HashratePoint',
  '2': [
    {'1': 'time', '3': 1, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'time'},
    {'1': 'hashrate', '3': 2, '4': 1, '5': 1, '10': 'hashrate'},
  ],
};

/// Descriptor for `HashratePoint`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List hashratePointDescriptor = $convert.base64Decode(
    'Cg1IYXNocmF0ZVBvaW50Ei4KBHRpbWUYASABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW'
    '1wUgR0aW1lEhoKCGhhc2hyYXRlGAIgASgBUghoYXNocmF0ZQ==');

@$core.Deprecated('Use getHashrateHistoryRequestDescriptor instead')
const GetHashrateHistoryRequest$json = {
  '1': 'GetHashrateHistoryRequest',
  '2': [
    {'1': 'range', '3': 1, '4': 1, '5': 14, '6': '.stratum.v1.HashrateRange', '10': 'range'},
  ],
};

/// Descriptor for `GetHashrateHistoryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getHashrateHistoryRequestDescriptor = $convert.base64Decode(
    'ChlHZXRIYXNocmF0ZUhpc3RvcnlSZXF1ZXN0Ei8KBXJhbmdlGAEgASgOMhkuc3RyYXR1bS52MS'
    '5IYXNocmF0ZVJhbmdlUgVyYW5nZQ==');

@$core.Deprecated('Use getHashrateHistoryResponseDescriptor instead')
const GetHashrateHistoryResponse$json = {
  '1': 'GetHashrateHistoryResponse',
  '2': [
    {'1': 'points', '3': 1, '4': 3, '5': 11, '6': '.stratum.v1.HashratePoint', '10': 'points'},
    {'1': 'peak', '3': 2, '4': 1, '5': 1, '10': 'peak'},
    {'1': 'current', '3': 3, '4': 1, '5': 1, '10': 'current'},
  ],
};

/// Descriptor for `GetHashrateHistoryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getHashrateHistoryResponseDescriptor = $convert.base64Decode(
    'ChpHZXRIYXNocmF0ZUhpc3RvcnlSZXNwb25zZRIxCgZwb2ludHMYASADKAsyGS5zdHJhdHVtLn'
    'YxLkhhc2hyYXRlUG9pbnRSBnBvaW50cxISCgRwZWFrGAIgASgBUgRwZWFrEhgKB2N1cnJlbnQY'
    'AyABKAFSB2N1cnJlbnQ=');

@$core.Deprecated('Use poolBlockDescriptor instead')
const PoolBlock$json = {
  '1': 'PoolBlock',
  '2': [
    {'1': 'height', '3': 1, '4': 1, '5': 13, '10': 'height'},
    {'1': 'hash', '3': 2, '4': 1, '5': 9, '10': 'hash'},
    {'1': 'reward_sats', '3': 3, '4': 1, '5': 3, '10': 'rewardSats'},
    {'1': 'fee_sats', '3': 4, '4': 1, '5': 3, '10': 'feeSats'},
    {'1': 'finder', '3': 5, '4': 1, '5': 9, '10': 'finder'},
    {'1': 'my_payout_sats', '3': 6, '4': 1, '5': 3, '9': 0, '10': 'myPayoutSats', '17': true},
    {'1': 'mine', '3': 7, '4': 1, '5': 8, '10': 'mine'},
    {'1': 'confirmations', '3': 8, '4': 1, '5': 5, '9': 1, '10': 'confirmations', '17': true},
    {'1': 'found_time', '3': 9, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'foundTime'},
  ],
  '8': [
    {'1': '_my_payout_sats'},
    {'1': '_confirmations'},
  ],
};

/// Descriptor for `PoolBlock`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List poolBlockDescriptor = $convert.base64Decode(
    'CglQb29sQmxvY2sSFgoGaGVpZ2h0GAEgASgNUgZoZWlnaHQSEgoEaGFzaBgCIAEoCVIEaGFzaB'
    'IfCgtyZXdhcmRfc2F0cxgDIAEoA1IKcmV3YXJkU2F0cxIZCghmZWVfc2F0cxgEIAEoA1IHZmVl'
    'U2F0cxIWCgZmaW5kZXIYBSABKAlSBmZpbmRlchIpCg5teV9wYXlvdXRfc2F0cxgGIAEoA0gAUg'
    'xteVBheW91dFNhdHOIAQESEgoEbWluZRgHIAEoCFIEbWluZRIpCg1jb25maXJtYXRpb25zGAgg'
    'ASgFSAFSDWNvbmZpcm1hdGlvbnOIAQESOQoKZm91bmRfdGltZRgJIAEoCzIaLmdvb2dsZS5wcm'
    '90b2J1Zi5UaW1lc3RhbXBSCWZvdW5kVGltZUIRCg9fbXlfcGF5b3V0X3NhdHNCEAoOX2NvbmZp'
    'cm1hdGlvbnM=');

@$core.Deprecated('Use listPoolBlocksRequestDescriptor instead')
const ListPoolBlocksRequest$json = {
  '1': 'ListPoolBlocksRequest',
  '2': [
    {'1': 'limit', '3': 1, '4': 1, '5': 13, '10': 'limit'},
  ],
};

/// Descriptor for `ListPoolBlocksRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listPoolBlocksRequestDescriptor = $convert.base64Decode(
    'ChVMaXN0UG9vbEJsb2Nrc1JlcXVlc3QSFAoFbGltaXQYASABKA1SBWxpbWl0');

@$core.Deprecated('Use listPoolBlocksResponseDescriptor instead')
const ListPoolBlocksResponse$json = {
  '1': 'ListPoolBlocksResponse',
  '2': [
    {'1': 'blocks', '3': 1, '4': 3, '5': 11, '6': '.stratum.v1.PoolBlock', '10': 'blocks'},
    {'1': 'unavailable', '3': 2, '4': 1, '5': 9, '10': 'unavailable'},
  ],
};

/// Descriptor for `ListPoolBlocksResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listPoolBlocksResponseDescriptor = $convert.base64Decode(
    'ChZMaXN0UG9vbEJsb2Nrc1Jlc3BvbnNlEi0KBmJsb2NrcxgBIAMoCzIVLnN0cmF0dW0udjEuUG'
    '9vbEJsb2NrUgZibG9ja3MSIAoLdW5hdmFpbGFibGUYAiABKAlSC3VuYXZhaWxhYmxl');

@$core.Deprecated('Use acceptedShareDescriptor instead')
const AcceptedShare$json = {
  '1': 'AcceptedShare',
  '2': [
    {'1': 'time', '3': 1, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'time'},
    {'1': 'worker', '3': 2, '4': 1, '5': 9, '10': 'worker'},
    {'1': 'target', '3': 3, '4': 1, '5': 1, '10': 'target'},
    {'1': 'actual', '3': 4, '4': 1, '5': 1, '10': 'actual'},
    {'1': 'hash', '3': 5, '4': 1, '5': 9, '10': 'hash'},
    {'1': 'block', '3': 6, '4': 1, '5': 8, '10': 'block'},
  ],
};

/// Descriptor for `AcceptedShare`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List acceptedShareDescriptor = $convert.base64Decode(
    'Cg1BY2NlcHRlZFNoYXJlEi4KBHRpbWUYASABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW'
    '1wUgR0aW1lEhYKBndvcmtlchgCIAEoCVIGd29ya2VyEhYKBnRhcmdldBgDIAEoAVIGdGFyZ2V0'
    'EhYKBmFjdHVhbBgEIAEoAVIGYWN0dWFsEhIKBGhhc2gYBSABKAlSBGhhc2gSFAoFYmxvY2sYBi'
    'ABKAhSBWJsb2Nr');

@$core.Deprecated('Use connectedMinerDescriptor instead')
const ConnectedMiner$json = {
  '1': 'ConnectedMiner',
  '2': [
    {'1': 'worker', '3': 1, '4': 1, '5': 9, '10': 'worker'},
    {'1': 'address', '3': 2, '4': 1, '5': 9, '10': 'address'},
    {'1': 'hashrate', '3': 3, '4': 1, '5': 1, '10': 'hashrate'},
    {'1': 'best_share', '3': 4, '4': 1, '5': 1, '10': 'bestShare'},
    {'1': 'accepted_shares', '3': 5, '4': 1, '5': 4, '10': 'acceptedShares'},
    {'1': 'rejected_shares', '3': 6, '4': 1, '5': 4, '10': 'rejectedShares'},
    {'1': 'last_share_time', '3': 7, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'lastShareTime'},
    {'1': 'temperature_celsius', '3': 8, '4': 1, '5': 1, '9': 0, '10': 'temperatureCelsius', '17': true},
    {'1': 'fan_percent', '3': 9, '4': 1, '5': 1, '9': 1, '10': 'fanPercent', '17': true},
    {'1': 'power_watts', '3': 10, '4': 1, '5': 1, '9': 2, '10': 'powerWatts', '17': true},
    {'1': 'work_mode', '3': 11, '4': 1, '5': 14, '6': '.stratum.v1.WorkMode', '10': 'workMode'},
  ],
  '8': [
    {'1': '_temperature_celsius'},
    {'1': '_fan_percent'},
    {'1': '_power_watts'},
  ],
};

/// Descriptor for `ConnectedMiner`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List connectedMinerDescriptor = $convert.base64Decode(
    'Cg5Db25uZWN0ZWRNaW5lchIWCgZ3b3JrZXIYASABKAlSBndvcmtlchIYCgdhZGRyZXNzGAIgAS'
    'gJUgdhZGRyZXNzEhoKCGhhc2hyYXRlGAMgASgBUghoYXNocmF0ZRIdCgpiZXN0X3NoYXJlGAQg'
    'ASgBUgliZXN0U2hhcmUSJwoPYWNjZXB0ZWRfc2hhcmVzGAUgASgEUg5hY2NlcHRlZFNoYXJlcx'
    'InCg9yZWplY3RlZF9zaGFyZXMYBiABKARSDnJlamVjdGVkU2hhcmVzEkIKD2xhc3Rfc2hhcmVf'
    'dGltZRgHIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSDWxhc3RTaGFyZVRpbWUSNA'
    'oTdGVtcGVyYXR1cmVfY2Vsc2l1cxgIIAEoAUgAUhJ0ZW1wZXJhdHVyZUNlbHNpdXOIAQESJAoL'
    'ZmFuX3BlcmNlbnQYCSABKAFIAVIKZmFuUGVyY2VudIgBARIkCgtwb3dlcl93YXR0cxgKIAEoAU'
    'gCUgpwb3dlcldhdHRziAEBEjEKCXdvcmtfbW9kZRgLIAEoDjIULnN0cmF0dW0udjEuV29ya01v'
    'ZGVSCHdvcmtNb2RlQhYKFF90ZW1wZXJhdHVyZV9jZWxzaXVzQg4KDF9mYW5fcGVyY2VudEIOCg'
    'xfcG93ZXJfd2F0dHM=');

@$core.Deprecated('Use foundBlockDescriptor instead')
const FoundBlock$json = {
  '1': 'FoundBlock',
  '2': [
    {'1': 'height', '3': 1, '4': 1, '5': 13, '10': 'height'},
    {'1': 'hash', '3': 2, '4': 1, '5': 9, '10': 'hash'},
    {'1': 'reward_sats', '3': 3, '4': 1, '5': 3, '10': 'rewardSats'},
    {'1': 'worker', '3': 4, '4': 1, '5': 9, '10': 'worker'},
    {'1': 'found_time', '3': 5, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'foundTime'},
    {'1': 'confirmations', '3': 6, '4': 1, '5': 5, '9': 0, '10': 'confirmations', '17': true},
  ],
  '8': [
    {'1': '_confirmations'},
  ],
};

/// Descriptor for `FoundBlock`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List foundBlockDescriptor = $convert.base64Decode(
    'CgpGb3VuZEJsb2NrEhYKBmhlaWdodBgBIAEoDVIGaGVpZ2h0EhIKBGhhc2gYAiABKAlSBGhhc2'
    'gSHwoLcmV3YXJkX3NhdHMYAyABKANSCnJld2FyZFNhdHMSFgoGd29ya2VyGAQgASgJUgZ3b3Jr'
    'ZXISOQoKZm91bmRfdGltZRgFIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWZvdW'
    '5kVGltZRIpCg1jb25maXJtYXRpb25zGAYgASgFSABSDWNvbmZpcm1hdGlvbnOIAQFCEAoOX2Nv'
    'bmZpcm1hdGlvbnM=');

@$core.Deprecated('Use getStratumStatusResponseDescriptor instead')
const GetStratumStatusResponse$json = {
  '1': 'GetStratumStatusResponse',
  '2': [
    {'1': 'running', '3': 1, '4': 1, '5': 8, '10': 'running'},
    {'1': 'port', '3': 2, '4': 1, '5': 13, '10': 'port'},
    {'1': 'pool_url', '3': 3, '4': 1, '5': 9, '10': 'poolUrl'},
    {'1': 'hashrate', '3': 4, '4': 1, '5': 1, '10': 'hashrate'},
    {'1': 'best_share', '3': 5, '4': 1, '5': 1, '10': 'bestShare'},
    {'1': 'network_difficulty', '3': 6, '4': 1, '5': 1, '10': 'networkDifficulty'},
    {'1': 'blocks_found', '3': 7, '4': 3, '5': 11, '6': '.stratum.v1.FoundBlock', '10': 'blocksFound'},
    {'1': 'miners', '3': 8, '4': 3, '5': 11, '6': '.stratum.v1.ConnectedMiner', '10': 'miners'},
    {'1': 'error', '3': 9, '4': 1, '5': 9, '10': 'error'},
    {'1': 'target', '3': 10, '4': 1, '5': 11, '6': '.stratum.v1.Target', '10': 'target'},
    {'1': 'pool_connected', '3': 11, '4': 1, '5': 8, '10': 'poolConnected'},
    {'1': 'pool_host', '3': 12, '4': 1, '5': 9, '10': 'poolHost'},
    {'1': 'payout_address', '3': 13, '4': 1, '5': 9, '10': 'payoutAddress'},
    {'1': 'accepted_shares', '3': 14, '4': 1, '5': 4, '10': 'acceptedShares'},
    {'1': 'rejected_shares', '3': 15, '4': 1, '5': 4, '10': 'rejectedShares'},
    {'1': 'settings', '3': 16, '4': 1, '5': 11, '6': '.stratum.v1.MiningSettings', '10': 'settings'},
    {'1': 'recent_shares', '3': 17, '4': 3, '5': 11, '6': '.stratum.v1.AcceptedShare', '10': 'recentShares'},
    {'1': 'network_hashrate', '3': 18, '4': 1, '5': 1, '10': 'networkHashrate'},
    {'1': 'best_share_won', '3': 19, '4': 1, '5': 8, '10': 'bestShareWon'},
  ],
};

/// Descriptor for `GetStratumStatusResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getStratumStatusResponseDescriptor = $convert.base64Decode(
    'ChhHZXRTdHJhdHVtU3RhdHVzUmVzcG9uc2USGAoHcnVubmluZxgBIAEoCFIHcnVubmluZxISCg'
    'Rwb3J0GAIgASgNUgRwb3J0EhkKCHBvb2xfdXJsGAMgASgJUgdwb29sVXJsEhoKCGhhc2hyYXRl'
    'GAQgASgBUghoYXNocmF0ZRIdCgpiZXN0X3NoYXJlGAUgASgBUgliZXN0U2hhcmUSLQoSbmV0d2'
    '9ya19kaWZmaWN1bHR5GAYgASgBUhFuZXR3b3JrRGlmZmljdWx0eRI5CgxibG9ja3NfZm91bmQY'
    'ByADKAsyFi5zdHJhdHVtLnYxLkZvdW5kQmxvY2tSC2Jsb2Nrc0ZvdW5kEjIKBm1pbmVycxgIIA'
    'MoCzIaLnN0cmF0dW0udjEuQ29ubmVjdGVkTWluZXJSBm1pbmVycxIUCgVlcnJvchgJIAEoCVIF'
    'ZXJyb3ISKgoGdGFyZ2V0GAogASgLMhIuc3RyYXR1bS52MS5UYXJnZXRSBnRhcmdldBIlCg5wb2'
    '9sX2Nvbm5lY3RlZBgLIAEoCFINcG9vbENvbm5lY3RlZBIbCglwb29sX2hvc3QYDCABKAlSCHBv'
    'b2xIb3N0EiUKDnBheW91dF9hZGRyZXNzGA0gASgJUg1wYXlvdXRBZGRyZXNzEicKD2FjY2VwdG'
    'VkX3NoYXJlcxgOIAEoBFIOYWNjZXB0ZWRTaGFyZXMSJwoPcmVqZWN0ZWRfc2hhcmVzGA8gASgE'
    'Ug5yZWplY3RlZFNoYXJlcxI2CghzZXR0aW5ncxgQIAEoCzIaLnN0cmF0dW0udjEuTWluaW5nU2'
    'V0dGluZ3NSCHNldHRpbmdzEj4KDXJlY2VudF9zaGFyZXMYESADKAsyGS5zdHJhdHVtLnYxLkFj'
    'Y2VwdGVkU2hhcmVSDHJlY2VudFNoYXJlcxIpChBuZXR3b3JrX2hhc2hyYXRlGBIgASgBUg9uZX'
    'R3b3JrSGFzaHJhdGUSJAoOYmVzdF9zaGFyZV93b24YEyABKAhSDGJlc3RTaGFyZVdvbg==');

@$core.Deprecated('Use setTargetRequestDescriptor instead')
const SetTargetRequest$json = {
  '1': 'SetTargetRequest',
  '2': [
    {'1': 'target', '3': 1, '4': 1, '5': 11, '6': '.stratum.v1.Target', '10': 'target'},
  ],
};

/// Descriptor for `SetTargetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setTargetRequestDescriptor = $convert.base64Decode(
    'ChBTZXRUYXJnZXRSZXF1ZXN0EioKBnRhcmdldBgBIAEoCzISLnN0cmF0dW0udjEuVGFyZ2V0Ug'
    'Z0YXJnZXQ=');

@$core.Deprecated('Use setTargetResponseDescriptor instead')
const SetTargetResponse$json = {
  '1': 'SetTargetResponse',
};

/// Descriptor for `SetTargetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setTargetResponseDescriptor = $convert.base64Decode(
    'ChFTZXRUYXJnZXRSZXNwb25zZQ==');

@$core.Deprecated('Use listTargetsRequestDescriptor instead')
const ListTargetsRequest$json = {
  '1': 'ListTargetsRequest',
};

/// Descriptor for `ListTargetsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listTargetsRequestDescriptor = $convert.base64Decode(
    'ChJMaXN0VGFyZ2V0c1JlcXVlc3Q=');

@$core.Deprecated('Use catalogPoolDescriptor instead')
const CatalogPool$json = {
  '1': 'CatalogPool',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'url', '3': 3, '4': 1, '5': 9, '10': 'url'},
    {'1': 'fee', '3': 4, '4': 1, '5': 9, '10': 'fee'},
    {'1': 'hashrate', '3': 5, '4': 1, '5': 1, '9': 0, '10': 'hashrate', '17': true},
  ],
  '8': [
    {'1': '_hashrate'},
  ],
};

/// Descriptor for `CatalogPool`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List catalogPoolDescriptor = $convert.base64Decode(
    'CgtDYXRhbG9nUG9vbBIOCgJpZBgBIAEoCVICaWQSEgoEbmFtZRgCIAEoCVIEbmFtZRIQCgN1cm'
    'wYAyABKAlSA3VybBIQCgNmZWUYBCABKAlSA2ZlZRIfCghoYXNocmF0ZRgFIAEoAUgAUghoYXNo'
    'cmF0ZYgBAUILCglfaGFzaHJhdGU=');

@$core.Deprecated('Use listTargetsResponseDescriptor instead')
const ListTargetsResponse$json = {
  '1': 'ListTargetsResponse',
  '2': [
    {'1': 'pools', '3': 1, '4': 3, '5': 11, '6': '.stratum.v1.CatalogPool', '10': 'pools'},
  ],
};

/// Descriptor for `ListTargetsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listTargetsResponseDescriptor = $convert.base64Decode(
    'ChNMaXN0VGFyZ2V0c1Jlc3BvbnNlEi0KBXBvb2xzGAEgAygLMhcuc3RyYXR1bS52MS5DYXRhbG'
    '9nUG9vbFIFcG9vbHM=');

@$core.Deprecated('Use setWorkModeRequestDescriptor instead')
const SetWorkModeRequest$json = {
  '1': 'SetWorkModeRequest',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'mode', '3': 2, '4': 1, '5': 14, '6': '.stratum.v1.WorkMode', '10': 'mode'},
  ],
};

/// Descriptor for `SetWorkModeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setWorkModeRequestDescriptor = $convert.base64Decode(
    'ChJTZXRXb3JrTW9kZVJlcXVlc3QSGAoHYWRkcmVzcxgBIAEoCVIHYWRkcmVzcxIoCgRtb2RlGA'
    'IgASgOMhQuc3RyYXR1bS52MS5Xb3JrTW9kZVIEbW9kZQ==');

@$core.Deprecated('Use setWorkModeResponseDescriptor instead')
const SetWorkModeResponse$json = {
  '1': 'SetWorkModeResponse',
};

/// Descriptor for `SetWorkModeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setWorkModeResponseDescriptor = $convert.base64Decode(
    'ChNTZXRXb3JrTW9kZVJlc3BvbnNl');

const $core.Map<$core.String, $core.dynamic> StratumServiceBase$json = {
  '1': 'StratumService',
  '2': [
    {'1': 'StartStratum', '2': '.stratum.v1.StartStratumRequest', '3': '.stratum.v1.StartStratumResponse'},
    {'1': 'StopStratum', '2': '.stratum.v1.StopStratumRequest', '3': '.stratum.v1.StopStratumResponse'},
    {'1': 'GetStratumStatus', '2': '.stratum.v1.GetStratumStatusRequest', '3': '.stratum.v1.GetStratumStatusResponse'},
    {'1': 'SetTarget', '2': '.stratum.v1.SetTargetRequest', '3': '.stratum.v1.SetTargetResponse'},
    {'1': 'ListTargets', '2': '.stratum.v1.ListTargetsRequest', '3': '.stratum.v1.ListTargetsResponse'},
    {'1': 'SetWorkMode', '2': '.stratum.v1.SetWorkModeRequest', '3': '.stratum.v1.SetWorkModeResponse'},
    {'1': 'SetMiningSettings', '2': '.stratum.v1.SetMiningSettingsRequest', '3': '.stratum.v1.SetMiningSettingsResponse'},
    {'1': 'GetHashrateHistory', '2': '.stratum.v1.GetHashrateHistoryRequest', '3': '.stratum.v1.GetHashrateHistoryResponse'},
    {'1': 'ListPoolBlocks', '2': '.stratum.v1.ListPoolBlocksRequest', '3': '.stratum.v1.ListPoolBlocksResponse'},
  ],
};

@$core.Deprecated('Use stratumServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> StratumServiceBase$messageJson = {
  '.stratum.v1.StartStratumRequest': StartStratumRequest$json,
  '.stratum.v1.StartStratumResponse': StartStratumResponse$json,
  '.stratum.v1.StopStratumRequest': StopStratumRequest$json,
  '.stratum.v1.StopStratumResponse': StopStratumResponse$json,
  '.stratum.v1.GetStratumStatusRequest': GetStratumStatusRequest$json,
  '.stratum.v1.GetStratumStatusResponse': GetStratumStatusResponse$json,
  '.stratum.v1.FoundBlock': FoundBlock$json,
  '.google.protobuf.Timestamp': $14.Timestamp$json,
  '.stratum.v1.ConnectedMiner': ConnectedMiner$json,
  '.stratum.v1.Target': Target$json,
  '.stratum.v1.MiningSettings': MiningSettings$json,
  '.stratum.v1.AcceptedShare': AcceptedShare$json,
  '.stratum.v1.SetTargetRequest': SetTargetRequest$json,
  '.stratum.v1.SetTargetResponse': SetTargetResponse$json,
  '.stratum.v1.ListTargetsRequest': ListTargetsRequest$json,
  '.stratum.v1.ListTargetsResponse': ListTargetsResponse$json,
  '.stratum.v1.CatalogPool': CatalogPool$json,
  '.stratum.v1.SetWorkModeRequest': SetWorkModeRequest$json,
  '.stratum.v1.SetWorkModeResponse': SetWorkModeResponse$json,
  '.stratum.v1.SetMiningSettingsRequest': SetMiningSettingsRequest$json,
  '.stratum.v1.SetMiningSettingsResponse': SetMiningSettingsResponse$json,
  '.stratum.v1.GetHashrateHistoryRequest': GetHashrateHistoryRequest$json,
  '.stratum.v1.GetHashrateHistoryResponse': GetHashrateHistoryResponse$json,
  '.stratum.v1.HashratePoint': HashratePoint$json,
  '.stratum.v1.ListPoolBlocksRequest': ListPoolBlocksRequest$json,
  '.stratum.v1.ListPoolBlocksResponse': ListPoolBlocksResponse$json,
  '.stratum.v1.PoolBlock': PoolBlock$json,
};

/// Descriptor for `StratumService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List stratumServiceDescriptor = $convert.base64Decode(
    'Cg5TdHJhdHVtU2VydmljZRJRCgxTdGFydFN0cmF0dW0SHy5zdHJhdHVtLnYxLlN0YXJ0U3RyYX'
    'R1bVJlcXVlc3QaIC5zdHJhdHVtLnYxLlN0YXJ0U3RyYXR1bVJlc3BvbnNlEk4KC1N0b3BTdHJh'
    'dHVtEh4uc3RyYXR1bS52MS5TdG9wU3RyYXR1bVJlcXVlc3QaHy5zdHJhdHVtLnYxLlN0b3BTdH'
    'JhdHVtUmVzcG9uc2USXQoQR2V0U3RyYXR1bVN0YXR1cxIjLnN0cmF0dW0udjEuR2V0U3RyYXR1'
    'bVN0YXR1c1JlcXVlc3QaJC5zdHJhdHVtLnYxLkdldFN0cmF0dW1TdGF0dXNSZXNwb25zZRJICg'
    'lTZXRUYXJnZXQSHC5zdHJhdHVtLnYxLlNldFRhcmdldFJlcXVlc3QaHS5zdHJhdHVtLnYxLlNl'
    'dFRhcmdldFJlc3BvbnNlEk4KC0xpc3RUYXJnZXRzEh4uc3RyYXR1bS52MS5MaXN0VGFyZ2V0c1'
    'JlcXVlc3QaHy5zdHJhdHVtLnYxLkxpc3RUYXJnZXRzUmVzcG9uc2USTgoLU2V0V29ya01vZGUS'
    'Hi5zdHJhdHVtLnYxLlNldFdvcmtNb2RlUmVxdWVzdBofLnN0cmF0dW0udjEuU2V0V29ya01vZG'
    'VSZXNwb25zZRJgChFTZXRNaW5pbmdTZXR0aW5ncxIkLnN0cmF0dW0udjEuU2V0TWluaW5nU2V0'
    'dGluZ3NSZXF1ZXN0GiUuc3RyYXR1bS52MS5TZXRNaW5pbmdTZXR0aW5nc1Jlc3BvbnNlEmMKEk'
    'dldEhhc2hyYXRlSGlzdG9yeRIlLnN0cmF0dW0udjEuR2V0SGFzaHJhdGVIaXN0b3J5UmVxdWVz'
    'dBomLnN0cmF0dW0udjEuR2V0SGFzaHJhdGVIaXN0b3J5UmVzcG9uc2USVwoOTGlzdFBvb2xCbG'
    '9ja3MSIS5zdHJhdHVtLnYxLkxpc3RQb29sQmxvY2tzUmVxdWVzdBoiLnN0cmF0dW0udjEuTGlz'
    'dFBvb2xCbG9ja3NSZXNwb25zZQ==');

