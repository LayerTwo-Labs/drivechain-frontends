//
//  Generated code. Do not modify.
//  source: orchestrator/v1/orchestrator.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use sidechainTypeDescriptor instead')
const SidechainType$json = {
  '1': 'SidechainType',
  '2': [
    {'1': 'SIDECHAIN_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'SIDECHAIN_TYPE_THUNDER', '2': 1},
    {'1': 'SIDECHAIN_TYPE_ZSIDE', '2': 2},
    {'1': 'SIDECHAIN_TYPE_BITNAMES', '2': 3},
    {'1': 'SIDECHAIN_TYPE_BITASSETS', '2': 4},
    {'1': 'SIDECHAIN_TYPE_TRUTHCOIN', '2': 5},
    {'1': 'SIDECHAIN_TYPE_PHOTON', '2': 6},
    {'1': 'SIDECHAIN_TYPE_COINSHIFT', '2': 7},
  ],
};

/// Descriptor for `SidechainType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List sidechainTypeDescriptor =
    $convert.base64Decode('Cg1TaWRlY2hhaW5UeXBlEh4KGlNJREVDSEFJTl9UWVBFX1VOU1BFQ0lGSUVEEAASGgoWU0lERU'
        'NIQUlOX1RZUEVfVEhVTkRFUhABEhgKFFNJREVDSEFJTl9UWVBFX1pTSURFEAISGwoXU0lERUNI'
        'QUlOX1RZUEVfQklUTkFNRVMQAxIcChhTSURFQ0hBSU5fVFlQRV9CSVRBU1NFVFMQBBIcChhTSU'
        'RFQ0hBSU5fVFlQRV9UUlVUSENPSU4QBRIZChVTSURFQ0hBSU5fVFlQRV9QSE9UT04QBhIcChhT'
        'SURFQ0hBSU5fVFlQRV9DT0lOU0hJRlQQBw==');

@$core.Deprecated('Use binaryStatusMsgDescriptor instead')
const BinaryStatusMsg$json = {
  '1': 'BinaryStatusMsg',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'display_name', '3': 2, '4': 1, '5': 9, '10': 'displayName'},
    {'1': 'running', '3': 3, '4': 1, '5': 8, '10': 'running'},
    {'1': 'healthy', '3': 4, '4': 1, '5': 8, '10': 'healthy'},
    {'1': 'pid', '3': 5, '4': 1, '5': 5, '10': 'pid'},
    {'1': 'uptime_seconds', '3': 6, '4': 1, '5': 3, '10': 'uptimeSeconds'},
    {'1': 'chain_layer', '3': 7, '4': 1, '5': 5, '10': 'chainLayer'},
    {'1': 'port', '3': 8, '4': 1, '5': 5, '10': 'port'},
    {'1': 'error', '3': 9, '4': 1, '5': 9, '10': 'error'},
    {'1': 'connected', '3': 10, '4': 1, '5': 8, '10': 'connected'},
    {'1': 'startup_error', '3': 11, '4': 1, '5': 9, '10': 'startupError'},
    {'1': 'connection_error', '3': 12, '4': 1, '5': 9, '10': 'connectionError'},
    {'1': 'stopping', '3': 13, '4': 1, '5': 8, '10': 'stopping'},
    {'1': 'initializing', '3': 14, '4': 1, '5': 8, '10': 'initializing'},
    {'1': 'connect_mode_only', '3': 15, '4': 1, '5': 8, '10': 'connectModeOnly'},
    {'1': 'downloadable', '3': 16, '4': 1, '5': 8, '10': 'downloadable'},
    {'1': 'description', '3': 17, '4': 1, '5': 9, '10': 'description'},
    {'1': 'downloaded', '3': 18, '4': 1, '5': 8, '10': 'downloaded'},
    {'1': 'port_in_use', '3': 19, '4': 1, '5': 8, '10': 'portInUse'},
    {'1': 'version', '3': 20, '4': 1, '5': 9, '10': 'version'},
    {'1': 'repo_url', '3': 21, '4': 1, '5': 9, '10': 'repoUrl'},
    {'1': 'startup_logs', '3': 22, '4': 3, '5': 11, '6': '.orchestrator.v1.StartupLogEntryMsg', '10': 'startupLogs'},
    {'1': 'binary_path', '3': 23, '4': 1, '5': 9, '10': 'binaryPath'},
  ],
};

/// Descriptor for `BinaryStatusMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List binaryStatusMsgDescriptor =
    $convert.base64Decode('Cg9CaW5hcnlTdGF0dXNNc2cSEgoEbmFtZRgBIAEoCVIEbmFtZRIhCgxkaXNwbGF5X25hbWUYAi'
        'ABKAlSC2Rpc3BsYXlOYW1lEhgKB3J1bm5pbmcYAyABKAhSB3J1bm5pbmcSGAoHaGVhbHRoeRgE'
        'IAEoCFIHaGVhbHRoeRIQCgNwaWQYBSABKAVSA3BpZBIlCg51cHRpbWVfc2Vjb25kcxgGIAEoA1'
        'INdXB0aW1lU2Vjb25kcxIfCgtjaGFpbl9sYXllchgHIAEoBVIKY2hhaW5MYXllchISCgRwb3J0'
        'GAggASgFUgRwb3J0EhQKBWVycm9yGAkgASgJUgVlcnJvchIcCgljb25uZWN0ZWQYCiABKAhSCW'
        'Nvbm5lY3RlZBIjCg1zdGFydHVwX2Vycm9yGAsgASgJUgxzdGFydHVwRXJyb3ISKQoQY29ubmVj'
        'dGlvbl9lcnJvchgMIAEoCVIPY29ubmVjdGlvbkVycm9yEhoKCHN0b3BwaW5nGA0gASgIUghzdG'
        '9wcGluZxIiCgxpbml0aWFsaXppbmcYDiABKAhSDGluaXRpYWxpemluZxIqChFjb25uZWN0X21v'
        'ZGVfb25seRgPIAEoCFIPY29ubmVjdE1vZGVPbmx5EiIKDGRvd25sb2FkYWJsZRgQIAEoCFIMZG'
        '93bmxvYWRhYmxlEiAKC2Rlc2NyaXB0aW9uGBEgASgJUgtkZXNjcmlwdGlvbhIeCgpkb3dubG9h'
        'ZGVkGBIgASgIUgpkb3dubG9hZGVkEh4KC3BvcnRfaW5fdXNlGBMgASgIUglwb3J0SW5Vc2USGA'
        'oHdmVyc2lvbhgUIAEoCVIHdmVyc2lvbhIZCghyZXBvX3VybBgVIAEoCVIHcmVwb1VybBJGCgxz'
        'dGFydHVwX2xvZ3MYFiADKAsyIy5vcmNoZXN0cmF0b3IudjEuU3RhcnR1cExvZ0VudHJ5TXNnUg'
        'tzdGFydHVwTG9ncxIfCgtiaW5hcnlfcGF0aBgXIAEoCVIKYmluYXJ5UGF0aA==');

@$core.Deprecated('Use startupLogEntryMsgDescriptor instead')
const StartupLogEntryMsg$json = {
  '1': 'StartupLogEntryMsg',
  '2': [
    {'1': 'timestamp_unix', '3': 1, '4': 1, '5': 3, '10': 'timestampUnix'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `StartupLogEntryMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List startupLogEntryMsgDescriptor =
    $convert.base64Decode('ChJTdGFydHVwTG9nRW50cnlNc2cSJQoOdGltZXN0YW1wX3VuaXgYASABKANSDXRpbWVzdGFtcF'
        'VuaXgSGAoHbWVzc2FnZRgCIAEoCVIHbWVzc2FnZQ==');

@$core.Deprecated('Use listBinariesRequestDescriptor instead')
const ListBinariesRequest$json = {
  '1': 'ListBinariesRequest',
};

/// Descriptor for `ListBinariesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listBinariesRequestDescriptor = $convert.base64Decode('ChNMaXN0QmluYXJpZXNSZXF1ZXN0');

@$core.Deprecated('Use listBinariesResponseDescriptor instead')
const ListBinariesResponse$json = {
  '1': 'ListBinariesResponse',
  '2': [
    {'1': 'binaries', '3': 1, '4': 3, '5': 11, '6': '.orchestrator.v1.BinaryStatusMsg', '10': 'binaries'},
  ],
};

/// Descriptor for `ListBinariesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listBinariesResponseDescriptor =
    $convert.base64Decode('ChRMaXN0QmluYXJpZXNSZXNwb25zZRI8CghiaW5hcmllcxgBIAMoCzIgLm9yY2hlc3RyYXRvci'
        '52MS5CaW5hcnlTdGF0dXNNc2dSCGJpbmFyaWVz');

@$core.Deprecated('Use getBinaryStatusRequestDescriptor instead')
const GetBinaryStatusRequest$json = {
  '1': 'GetBinaryStatusRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `GetBinaryStatusRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBinaryStatusRequestDescriptor =
    $convert.base64Decode('ChZHZXRCaW5hcnlTdGF0dXNSZXF1ZXN0EhIKBG5hbWUYASABKAlSBG5hbWU=');

@$core.Deprecated('Use getBinaryStatusResponseDescriptor instead')
const GetBinaryStatusResponse$json = {
  '1': 'GetBinaryStatusResponse',
  '2': [
    {'1': 'status', '3': 1, '4': 1, '5': 11, '6': '.orchestrator.v1.BinaryStatusMsg', '10': 'status'},
  ],
};

/// Descriptor for `GetBinaryStatusResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBinaryStatusResponseDescriptor =
    $convert.base64Decode('ChdHZXRCaW5hcnlTdGF0dXNSZXNwb25zZRI4CgZzdGF0dXMYASABKAsyIC5vcmNoZXN0cmF0b3'
        'IudjEuQmluYXJ5U3RhdHVzTXNnUgZzdGF0dXM=');

@$core.Deprecated('Use downloadBinaryRequestDescriptor instead')
const DownloadBinaryRequest$json = {
  '1': 'DownloadBinaryRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'force', '3': 2, '4': 1, '5': 8, '10': 'force'},
  ],
};

/// Descriptor for `DownloadBinaryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List downloadBinaryRequestDescriptor =
    $convert.base64Decode('ChVEb3dubG9hZEJpbmFyeVJlcXVlc3QSEgoEbmFtZRgBIAEoCVIEbmFtZRIUCgVmb3JjZRgCIA'
        'EoCFIFZm9yY2U=');

@$core.Deprecated('Use downloadBinaryResponseDescriptor instead')
const DownloadBinaryResponse$json = {
  '1': 'DownloadBinaryResponse',
};

/// Descriptor for `DownloadBinaryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List downloadBinaryResponseDescriptor =
    $convert.base64Decode('ChZEb3dubG9hZEJpbmFyeVJlc3BvbnNl');

@$core.Deprecated('Use startBinaryRequestDescriptor instead')
const StartBinaryRequest$json = {
  '1': 'StartBinaryRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'extra_args', '3': 2, '4': 3, '5': 9, '10': 'extraArgs'},
    {'1': 'env', '3': 3, '4': 3, '5': 11, '6': '.orchestrator.v1.StartBinaryRequest.EnvEntry', '10': 'env'},
  ],
  '3': [StartBinaryRequest_EnvEntry$json],
};

@$core.Deprecated('Use startBinaryRequestDescriptor instead')
const StartBinaryRequest_EnvEntry$json = {
  '1': 'EnvEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `StartBinaryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List startBinaryRequestDescriptor =
    $convert.base64Decode('ChJTdGFydEJpbmFyeVJlcXVlc3QSEgoEbmFtZRgBIAEoCVIEbmFtZRIdCgpleHRyYV9hcmdzGA'
        'IgAygJUglleHRyYUFyZ3MSPgoDZW52GAMgAygLMiwub3JjaGVzdHJhdG9yLnYxLlN0YXJ0Qmlu'
        'YXJ5UmVxdWVzdC5FbnZFbnRyeVIDZW52GjYKCEVudkVudHJ5EhAKA2tleRgBIAEoCVIDa2V5Eh'
        'QKBXZhbHVlGAIgASgJUgV2YWx1ZToCOAE=');

@$core.Deprecated('Use startBinaryResponseDescriptor instead')
const StartBinaryResponse$json = {
  '1': 'StartBinaryResponse',
  '2': [
    {'1': 'pid', '3': 1, '4': 1, '5': 5, '10': 'pid'},
  ],
};

/// Descriptor for `StartBinaryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List startBinaryResponseDescriptor =
    $convert.base64Decode('ChNTdGFydEJpbmFyeVJlc3BvbnNlEhAKA3BpZBgBIAEoBVIDcGlk');

@$core.Deprecated('Use stopBinaryRequestDescriptor instead')
const StopBinaryRequest$json = {
  '1': 'StopBinaryRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'force', '3': 2, '4': 1, '5': 8, '10': 'force'},
  ],
};

/// Descriptor for `StopBinaryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List stopBinaryRequestDescriptor =
    $convert.base64Decode('ChFTdG9wQmluYXJ5UmVxdWVzdBISCgRuYW1lGAEgASgJUgRuYW1lEhQKBWZvcmNlGAIgASgIUg'
        'Vmb3JjZQ==');

@$core.Deprecated('Use stopBinaryResponseDescriptor instead')
const StopBinaryResponse$json = {
  '1': 'StopBinaryResponse',
};

/// Descriptor for `StopBinaryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List stopBinaryResponseDescriptor = $convert.base64Decode('ChJTdG9wQmluYXJ5UmVzcG9uc2U=');

@$core.Deprecated('Use streamLogsRequestDescriptor instead')
const StreamLogsRequest$json = {
  '1': 'StreamLogsRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'tail', '3': 2, '4': 1, '5': 5, '10': 'tail'},
  ],
};

/// Descriptor for `StreamLogsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamLogsRequestDescriptor =
    $convert.base64Decode('ChFTdHJlYW1Mb2dzUmVxdWVzdBISCgRuYW1lGAEgASgJUgRuYW1lEhIKBHRhaWwYAiABKAVSBH'
        'RhaWw=');

@$core.Deprecated('Use streamLogsResponseDescriptor instead')
const StreamLogsResponse$json = {
  '1': 'StreamLogsResponse',
  '2': [
    {'1': 'stream', '3': 1, '4': 1, '5': 9, '10': 'stream'},
    {'1': 'line', '3': 2, '4': 1, '5': 9, '10': 'line'},
    {'1': 'timestamp_unix', '3': 3, '4': 1, '5': 3, '10': 'timestampUnix'},
  ],
};

/// Descriptor for `StreamLogsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamLogsResponseDescriptor =
    $convert.base64Decode('ChJTdHJlYW1Mb2dzUmVzcG9uc2USFgoGc3RyZWFtGAEgASgJUgZzdHJlYW0SEgoEbGluZRgCIA'
        'EoCVIEbGluZRIlCg50aW1lc3RhbXBfdW5peBgDIAEoA1INdGltZXN0YW1wVW5peA==');

@$core.Deprecated('Use startWithL1RequestDescriptor instead')
const StartWithL1Request$json = {
  '1': 'StartWithL1Request',
  '2': [
    {'1': 'target', '3': 1, '4': 1, '5': 9, '10': 'target'},
    {'1': 'target_args', '3': 2, '4': 3, '5': 9, '10': 'targetArgs'},
    {
      '1': 'target_env',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.orchestrator.v1.StartWithL1Request.TargetEnvEntry',
      '10': 'targetEnv'
    },
    {'1': 'core_args', '3': 4, '4': 3, '5': 9, '10': 'coreArgs'},
    {'1': 'enforcer_args', '3': 5, '4': 3, '5': 9, '10': 'enforcerArgs'},
    {'1': 'immediate', '3': 6, '4': 1, '5': 8, '10': 'immediate'},
  ],
  '3': [StartWithL1Request_TargetEnvEntry$json],
};

@$core.Deprecated('Use startWithL1RequestDescriptor instead')
const StartWithL1Request_TargetEnvEntry$json = {
  '1': 'TargetEnvEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `StartWithL1Request`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List startWithL1RequestDescriptor =
    $convert.base64Decode('ChJTdGFydFdpdGhMMVJlcXVlc3QSFgoGdGFyZ2V0GAEgASgJUgZ0YXJnZXQSHwoLdGFyZ2V0X2'
        'FyZ3MYAiADKAlSCnRhcmdldEFyZ3MSUQoKdGFyZ2V0X2VudhgDIAMoCzIyLm9yY2hlc3RyYXRv'
        'ci52MS5TdGFydFdpdGhMMVJlcXVlc3QuVGFyZ2V0RW52RW50cnlSCXRhcmdldEVudhIbCgljb3'
        'JlX2FyZ3MYBCADKAlSCGNvcmVBcmdzEiMKDWVuZm9yY2VyX2FyZ3MYBSADKAlSDGVuZm9yY2Vy'
        'QXJncxIcCglpbW1lZGlhdGUYBiABKAhSCWltbWVkaWF0ZRo8Cg5UYXJnZXRFbnZFbnRyeRIQCg'
        'NrZXkYASABKAlSA2tleRIUCgV2YWx1ZRgCIAEoCVIFdmFsdWU6AjgB');

@$core.Deprecated('Use startWithL1ResponseDescriptor instead')
const StartWithL1Response$json = {
  '1': 'StartWithL1Response',
};

/// Descriptor for `StartWithL1Response`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List startWithL1ResponseDescriptor = $convert.base64Decode('ChNTdGFydFdpdGhMMVJlc3BvbnNl');

@$core.Deprecated('Use shutdownAllRequestDescriptor instead')
const ShutdownAllRequest$json = {
  '1': 'ShutdownAllRequest',
  '2': [
    {'1': 'force', '3': 1, '4': 1, '5': 8, '10': 'force'},
  ],
};

/// Descriptor for `ShutdownAllRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List shutdownAllRequestDescriptor =
    $convert.base64Decode('ChJTaHV0ZG93bkFsbFJlcXVlc3QSFAoFZm9yY2UYASABKAhSBWZvcmNl');

@$core.Deprecated('Use shutdownAllResponseDescriptor instead')
const ShutdownAllResponse$json = {
  '1': 'ShutdownAllResponse',
  '2': [
    {'1': 'total_count', '3': 1, '4': 1, '5': 5, '10': 'totalCount'},
    {'1': 'completed_count', '3': 2, '4': 1, '5': 5, '10': 'completedCount'},
    {'1': 'current_binary', '3': 3, '4': 1, '5': 9, '10': 'currentBinary'},
    {'1': 'done', '3': 4, '4': 1, '5': 8, '10': 'done'},
    {'1': 'error', '3': 5, '4': 1, '5': 9, '10': 'error'},
  ],
};

/// Descriptor for `ShutdownAllResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List shutdownAllResponseDescriptor =
    $convert.base64Decode('ChNTaHV0ZG93bkFsbFJlc3BvbnNlEh8KC3RvdGFsX2NvdW50GAEgASgFUgp0b3RhbENvdW50Ei'
        'cKD2NvbXBsZXRlZF9jb3VudBgCIAEoBVIOY29tcGxldGVkQ291bnQSJQoOY3VycmVudF9iaW5h'
        'cnkYAyABKAlSDWN1cnJlbnRCaW5hcnkSEgoEZG9uZRgEIAEoCFIEZG9uZRIUCgVlcnJvchgFIA'
        'EoCVIFZXJyb3I=');

@$core.Deprecated('Use getBTCPriceRequestDescriptor instead')
const GetBTCPriceRequest$json = {
  '1': 'GetBTCPriceRequest',
};

/// Descriptor for `GetBTCPriceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBTCPriceRequestDescriptor = $convert.base64Decode('ChJHZXRCVENQcmljZVJlcXVlc3Q=');

@$core.Deprecated('Use getBTCPriceResponseDescriptor instead')
const GetBTCPriceResponse$json = {
  '1': 'GetBTCPriceResponse',
  '2': [
    {'1': 'btcusd', '3': 1, '4': 1, '5': 1, '10': 'btcusd'},
    {'1': 'last_updated_unix', '3': 2, '4': 1, '5': 3, '10': 'lastUpdatedUnix'},
  ],
};

/// Descriptor for `GetBTCPriceResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBTCPriceResponseDescriptor =
    $convert.base64Decode('ChNHZXRCVENQcmljZVJlc3BvbnNlEhYKBmJ0Y3VzZBgBIAEoAVIGYnRjdXNkEioKEWxhc3RfdX'
        'BkYXRlZF91bml4GAIgASgDUg9sYXN0VXBkYXRlZFVuaXg=');

@$core.Deprecated('Use getMainchainBlockchainInfoRequestDescriptor instead')
const GetMainchainBlockchainInfoRequest$json = {
  '1': 'GetMainchainBlockchainInfoRequest',
};

/// Descriptor for `GetMainchainBlockchainInfoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMainchainBlockchainInfoRequestDescriptor =
    $convert.base64Decode('CiFHZXRNYWluY2hhaW5CbG9ja2NoYWluSW5mb1JlcXVlc3Q=');

@$core.Deprecated('Use getMainchainBlockchainInfoResponseDescriptor instead')
const GetMainchainBlockchainInfoResponse$json = {
  '1': 'GetMainchainBlockchainInfoResponse',
  '2': [
    {'1': 'chain', '3': 1, '4': 1, '5': 9, '10': 'chain'},
    {'1': 'blocks', '3': 2, '4': 1, '5': 5, '10': 'blocks'},
    {'1': 'headers', '3': 3, '4': 1, '5': 5, '10': 'headers'},
    {'1': 'best_block_hash', '3': 4, '4': 1, '5': 9, '10': 'bestBlockHash'},
    {'1': 'difficulty', '3': 5, '4': 1, '5': 1, '10': 'difficulty'},
    {'1': 'time', '3': 6, '4': 1, '5': 3, '10': 'time'},
    {'1': 'median_time', '3': 7, '4': 1, '5': 3, '10': 'medianTime'},
    {'1': 'verification_progress', '3': 8, '4': 1, '5': 1, '10': 'verificationProgress'},
    {'1': 'initial_block_download', '3': 9, '4': 1, '5': 8, '10': 'initialBlockDownload'},
    {'1': 'chain_work', '3': 10, '4': 1, '5': 9, '10': 'chainWork'},
    {'1': 'size_on_disk', '3': 11, '4': 1, '5': 3, '10': 'sizeOnDisk'},
    {'1': 'pruned', '3': 12, '4': 1, '5': 8, '10': 'pruned'},
  ],
};

/// Descriptor for `GetMainchainBlockchainInfoResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMainchainBlockchainInfoResponseDescriptor =
    $convert.base64Decode('CiJHZXRNYWluY2hhaW5CbG9ja2NoYWluSW5mb1Jlc3BvbnNlEhQKBWNoYWluGAEgASgJUgVjaG'
        'FpbhIWCgZibG9ja3MYAiABKAVSBmJsb2NrcxIYCgdoZWFkZXJzGAMgASgFUgdoZWFkZXJzEiYK'
        'D2Jlc3RfYmxvY2tfaGFzaBgEIAEoCVINYmVzdEJsb2NrSGFzaBIeCgpkaWZmaWN1bHR5GAUgAS'
        'gBUgpkaWZmaWN1bHR5EhIKBHRpbWUYBiABKANSBHRpbWUSHwoLbWVkaWFuX3RpbWUYByABKANS'
        'Cm1lZGlhblRpbWUSMwoVdmVyaWZpY2F0aW9uX3Byb2dyZXNzGAggASgBUhR2ZXJpZmljYXRpb2'
        '5Qcm9ncmVzcxI0ChZpbml0aWFsX2Jsb2NrX2Rvd25sb2FkGAkgASgIUhRpbml0aWFsQmxvY2tE'
        'b3dubG9hZBIdCgpjaGFpbl93b3JrGAogASgJUgljaGFpbldvcmsSIAoMc2l6ZV9vbl9kaXNrGA'
        'sgASgDUgpzaXplT25EaXNrEhYKBnBydW5lZBgMIAEoCFIGcHJ1bmVk');

@$core.Deprecated('Use getEnforcerBlockchainInfoRequestDescriptor instead')
const GetEnforcerBlockchainInfoRequest$json = {
  '1': 'GetEnforcerBlockchainInfoRequest',
};

/// Descriptor for `GetEnforcerBlockchainInfoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getEnforcerBlockchainInfoRequestDescriptor =
    $convert.base64Decode('CiBHZXRFbmZvcmNlckJsb2NrY2hhaW5JbmZvUmVxdWVzdA==');

@$core.Deprecated('Use getEnforcerBlockchainInfoResponseDescriptor instead')
const GetEnforcerBlockchainInfoResponse$json = {
  '1': 'GetEnforcerBlockchainInfoResponse',
  '2': [
    {'1': 'blocks', '3': 1, '4': 1, '5': 5, '10': 'blocks'},
    {'1': 'headers', '3': 2, '4': 1, '5': 5, '10': 'headers'},
    {'1': 'time', '3': 3, '4': 1, '5': 3, '10': 'time'},
  ],
};

/// Descriptor for `GetEnforcerBlockchainInfoResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getEnforcerBlockchainInfoResponseDescriptor =
    $convert.base64Decode('CiFHZXRFbmZvcmNlckJsb2NrY2hhaW5JbmZvUmVzcG9uc2USFgoGYmxvY2tzGAEgASgFUgZibG'
        '9ja3MSGAoHaGVhZGVycxgCIAEoBVIHaGVhZGVycxISCgR0aW1lGAMgASgDUgR0aW1l');

@$core.Deprecated('Use getSyncStatusRequestDescriptor instead')
const GetSyncStatusRequest$json = {
  '1': 'GetSyncStatusRequest',
};

/// Descriptor for `GetSyncStatusRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSyncStatusRequestDescriptor = $convert.base64Decode('ChRHZXRTeW5jU3RhdHVzUmVxdWVzdA==');

@$core.Deprecated('Use getSyncStatusResponseDescriptor instead')
const GetSyncStatusResponse$json = {
  '1': 'GetSyncStatusResponse',
  '2': [
    {'1': 'mainchain', '3': 1, '4': 1, '5': 11, '6': '.orchestrator.v1.ChainSync', '10': 'mainchain'},
    {'1': 'enforcer', '3': 2, '4': 1, '5': 11, '6': '.orchestrator.v1.ChainSync', '10': 'enforcer'},
    {'1': 'sidechains', '3': 3, '4': 3, '5': 11, '6': '.orchestrator.v1.SidechainStatus', '10': 'sidechains'},
  ],
};

/// Descriptor for `GetSyncStatusResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSyncStatusResponseDescriptor =
    $convert.base64Decode('ChVHZXRTeW5jU3RhdHVzUmVzcG9uc2USOAoJbWFpbmNoYWluGAEgASgLMhoub3JjaGVzdHJhdG'
        '9yLnYxLkNoYWluU3luY1IJbWFpbmNoYWluEjYKCGVuZm9yY2VyGAIgASgLMhoub3JjaGVzdHJh'
        'dG9yLnYxLkNoYWluU3luY1IIZW5mb3JjZXISQAoKc2lkZWNoYWlucxgDIAMoCzIgLm9yY2hlc3'
        'RyYXRvci52MS5TaWRlY2hhaW5TdGF0dXNSCnNpZGVjaGFpbnM=');

@$core.Deprecated('Use sidechainStatusDescriptor instead')
const SidechainStatus$json = {
  '1': 'SidechainStatus',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 14, '6': '.orchestrator.v1.SidechainType', '10': 'type'},
    {'1': 'sync', '3': 2, '4': 1, '5': 11, '6': '.orchestrator.v1.ChainSync', '10': 'sync'},
  ],
};

/// Descriptor for `SidechainStatus`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sidechainStatusDescriptor =
    $convert.base64Decode('Cg9TaWRlY2hhaW5TdGF0dXMSMgoEdHlwZRgBIAEoDjIeLm9yY2hlc3RyYXRvci52MS5TaWRlY2'
        'hhaW5UeXBlUgR0eXBlEi4KBHN5bmMYAiABKAsyGi5vcmNoZXN0cmF0b3IudjEuQ2hhaW5TeW5j'
        'UgRzeW5j');

@$core.Deprecated('Use chainSyncDescriptor instead')
const ChainSync$json = {
  '1': 'ChainSync',
  '2': [
    {'1': 'blocks', '3': 1, '4': 1, '5': 5, '10': 'blocks'},
    {'1': 'headers', '3': 2, '4': 1, '5': 5, '10': 'headers'},
    {'1': 'time', '3': 3, '4': 1, '5': 3, '10': 'time'},
    {'1': 'error', '3': 4, '4': 1, '5': 9, '10': 'error'},
    {'1': 'is_downloading', '3': 5, '4': 1, '5': 8, '10': 'isDownloading'},
  ],
};

/// Descriptor for `ChainSync`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chainSyncDescriptor =
    $convert.base64Decode('CglDaGFpblN5bmMSFgoGYmxvY2tzGAEgASgFUgZibG9ja3MSGAoHaGVhZGVycxgCIAEoBVIHaG'
        'VhZGVycxISCgR0aW1lGAMgASgDUgR0aW1lEhQKBWVycm9yGAQgASgJUgVlcnJvchIlCg5pc19k'
        'b3dubG9hZGluZxgFIAEoCFINaXNEb3dubG9hZGluZw==');

@$core.Deprecated('Use getMainchainBalanceRequestDescriptor instead')
const GetMainchainBalanceRequest$json = {
  '1': 'GetMainchainBalanceRequest',
};

/// Descriptor for `GetMainchainBalanceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMainchainBalanceRequestDescriptor =
    $convert.base64Decode('ChpHZXRNYWluY2hhaW5CYWxhbmNlUmVxdWVzdA==');

@$core.Deprecated('Use getMainchainBalanceResponseDescriptor instead')
const GetMainchainBalanceResponse$json = {
  '1': 'GetMainchainBalanceResponse',
  '2': [
    {'1': 'confirmed', '3': 1, '4': 1, '5': 1, '10': 'confirmed'},
    {'1': 'unconfirmed', '3': 2, '4': 1, '5': 1, '10': 'unconfirmed'},
  ],
};

/// Descriptor for `GetMainchainBalanceResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMainchainBalanceResponseDescriptor =
    $convert.base64Decode('ChtHZXRNYWluY2hhaW5CYWxhbmNlUmVzcG9uc2USHAoJY29uZmlybWVkGAEgASgBUgljb25maX'
        'JtZWQSIAoLdW5jb25maXJtZWQYAiABKAFSC3VuY29uZmlybWVk');

@$core.Deprecated('Use previewResetDataRequestDescriptor instead')
const PreviewResetDataRequest$json = {
  '1': 'PreviewResetDataRequest',
  '2': [
    {'1': 'delete_blockchain_data', '3': 1, '4': 1, '5': 8, '10': 'deleteBlockchainData'},
    {'1': 'delete_node_software', '3': 2, '4': 1, '5': 8, '10': 'deleteNodeSoftware'},
    {'1': 'delete_logs', '3': 3, '4': 1, '5': 8, '10': 'deleteLogs'},
    {'1': 'delete_settings', '3': 4, '4': 1, '5': 8, '10': 'deleteSettings'},
    {'1': 'delete_wallet_files', '3': 5, '4': 1, '5': 8, '10': 'deleteWalletFiles'},
    {'1': 'also_reset_sidechains', '3': 6, '4': 1, '5': 8, '10': 'alsoResetSidechains'},
  ],
};

/// Descriptor for `PreviewResetDataRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List previewResetDataRequestDescriptor =
    $convert.base64Decode('ChdQcmV2aWV3UmVzZXREYXRhUmVxdWVzdBI0ChZkZWxldGVfYmxvY2tjaGFpbl9kYXRhGAEgAS'
        'gIUhRkZWxldGVCbG9ja2NoYWluRGF0YRIwChRkZWxldGVfbm9kZV9zb2Z0d2FyZRgCIAEoCFIS'
        'ZGVsZXRlTm9kZVNvZnR3YXJlEh8KC2RlbGV0ZV9sb2dzGAMgASgIUgpkZWxldGVMb2dzEicKD2'
        'RlbGV0ZV9zZXR0aW5ncxgEIAEoCFIOZGVsZXRlU2V0dGluZ3MSLgoTZGVsZXRlX3dhbGxldF9m'
        'aWxlcxgFIAEoCFIRZGVsZXRlV2FsbGV0RmlsZXMSMgoVYWxzb19yZXNldF9zaWRlY2hhaW5zGA'
        'YgASgIUhNhbHNvUmVzZXRTaWRlY2hhaW5z');

@$core.Deprecated('Use previewResetDataResponseDescriptor instead')
const PreviewResetDataResponse$json = {
  '1': 'PreviewResetDataResponse',
  '2': [
    {'1': 'files', '3': 1, '4': 3, '5': 11, '6': '.orchestrator.v1.ResetFileInfo', '10': 'files'},
  ],
};

/// Descriptor for `PreviewResetDataResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List previewResetDataResponseDescriptor =
    $convert.base64Decode('ChhQcmV2aWV3UmVzZXREYXRhUmVzcG9uc2USNAoFZmlsZXMYASADKAsyHi5vcmNoZXN0cmF0b3'
        'IudjEuUmVzZXRGaWxlSW5mb1IFZmlsZXM=');

@$core.Deprecated('Use resetFileInfoDescriptor instead')
const ResetFileInfo$json = {
  '1': 'ResetFileInfo',
  '2': [
    {'1': 'path', '3': 1, '4': 1, '5': 9, '10': 'path'},
    {'1': 'category', '3': 2, '4': 1, '5': 9, '10': 'category'},
    {'1': 'size_bytes', '3': 3, '4': 1, '5': 3, '10': 'sizeBytes'},
    {'1': 'is_directory', '3': 4, '4': 1, '5': 8, '10': 'isDirectory'},
  ],
};

/// Descriptor for `ResetFileInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List resetFileInfoDescriptor =
    $convert.base64Decode('Cg1SZXNldEZpbGVJbmZvEhIKBHBhdGgYASABKAlSBHBhdGgSGgoIY2F0ZWdvcnkYAiABKAlSCG'
        'NhdGVnb3J5Eh0KCnNpemVfYnl0ZXMYAyABKANSCXNpemVCeXRlcxIhCgxpc19kaXJlY3RvcnkY'
        'BCABKAhSC2lzRGlyZWN0b3J5');

@$core.Deprecated('Use streamResetDataRequestDescriptor instead')
const StreamResetDataRequest$json = {
  '1': 'StreamResetDataRequest',
  '2': [
    {'1': 'delete_blockchain_data', '3': 1, '4': 1, '5': 8, '10': 'deleteBlockchainData'},
    {'1': 'delete_node_software', '3': 2, '4': 1, '5': 8, '10': 'deleteNodeSoftware'},
    {'1': 'delete_logs', '3': 3, '4': 1, '5': 8, '10': 'deleteLogs'},
    {'1': 'delete_settings', '3': 4, '4': 1, '5': 8, '10': 'deleteSettings'},
    {'1': 'delete_wallet_files', '3': 5, '4': 1, '5': 8, '10': 'deleteWalletFiles'},
    {'1': 'also_reset_sidechains', '3': 6, '4': 1, '5': 8, '10': 'alsoResetSidechains'},
  ],
};

/// Descriptor for `StreamResetDataRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamResetDataRequestDescriptor =
    $convert.base64Decode('ChZTdHJlYW1SZXNldERhdGFSZXF1ZXN0EjQKFmRlbGV0ZV9ibG9ja2NoYWluX2RhdGEYASABKA'
        'hSFGRlbGV0ZUJsb2NrY2hhaW5EYXRhEjAKFGRlbGV0ZV9ub2RlX3NvZnR3YXJlGAIgASgIUhJk'
        'ZWxldGVOb2RlU29mdHdhcmUSHwoLZGVsZXRlX2xvZ3MYAyABKAhSCmRlbGV0ZUxvZ3MSJwoPZG'
        'VsZXRlX3NldHRpbmdzGAQgASgIUg5kZWxldGVTZXR0aW5ncxIuChNkZWxldGVfd2FsbGV0X2Zp'
        'bGVzGAUgASgIUhFkZWxldGVXYWxsZXRGaWxlcxIyChVhbHNvX3Jlc2V0X3NpZGVjaGFpbnMYBi'
        'ABKAhSE2Fsc29SZXNldFNpZGVjaGFpbnM=');

@$core.Deprecated('Use streamResetDataResponseDescriptor instead')
const StreamResetDataResponse$json = {
  '1': 'StreamResetDataResponse',
  '2': [
    {'1': 'path', '3': 1, '4': 1, '5': 9, '10': 'path'},
    {'1': 'category', '3': 2, '4': 1, '5': 9, '10': 'category'},
    {'1': 'success', '3': 3, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 4, '4': 1, '5': 9, '10': 'error'},
    {'1': 'done', '3': 5, '4': 1, '5': 8, '10': 'done'},
    {'1': 'deleted_count', '3': 6, '4': 1, '5': 5, '10': 'deletedCount'},
    {'1': 'failed_count', '3': 7, '4': 1, '5': 5, '10': 'failedCount'},
  ],
};

/// Descriptor for `StreamResetDataResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamResetDataResponseDescriptor =
    $convert.base64Decode('ChdTdHJlYW1SZXNldERhdGFSZXNwb25zZRISCgRwYXRoGAEgASgJUgRwYXRoEhoKCGNhdGVnb3'
        'J5GAIgASgJUghjYXRlZ29yeRIYCgdzdWNjZXNzGAMgASgIUgdzdWNjZXNzEhQKBWVycm9yGAQg'
        'ASgJUgVlcnJvchISCgRkb25lGAUgASgIUgRkb25lEiMKDWRlbGV0ZWRfY291bnQYBiABKAVSDG'
        'RlbGV0ZWRDb3VudBIhCgxmYWlsZWRfY291bnQYByABKAVSC2ZhaWxlZENvdW50');

@$core.Deprecated('Use getCoreMempoolInfoRequestDescriptor instead')
const GetCoreMempoolInfoRequest$json = {
  '1': 'GetCoreMempoolInfoRequest',
};

/// Descriptor for `GetCoreMempoolInfoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCoreMempoolInfoRequestDescriptor =
    $convert.base64Decode('ChlHZXRDb3JlTWVtcG9vbEluZm9SZXF1ZXN0');

@$core.Deprecated('Use getCoreMempoolInfoResponseDescriptor instead')
const GetCoreMempoolInfoResponse$json = {
  '1': 'GetCoreMempoolInfoResponse',
  '2': [
    {'1': 'loaded', '3': 1, '4': 1, '5': 8, '10': 'loaded'},
    {'1': 'size', '3': 2, '4': 1, '5': 3, '10': 'size'},
    {'1': 'bytes', '3': 3, '4': 1, '5': 3, '10': 'bytes'},
    {'1': 'usage', '3': 4, '4': 1, '5': 3, '10': 'usage'},
    {'1': 'total_fee', '3': 5, '4': 1, '5': 1, '10': 'totalFee'},
    {'1': 'max_mempool', '3': 6, '4': 1, '5': 3, '10': 'maxMempool'},
    {'1': 'mempool_min_fee', '3': 7, '4': 1, '5': 1, '10': 'mempoolMinFee'},
    {'1': 'min_relay_tx_fee', '3': 8, '4': 1, '5': 1, '10': 'minRelayTxFee'},
    {'1': 'incremental_relay_fee', '3': 9, '4': 1, '5': 1, '10': 'incrementalRelayFee'},
    {'1': 'unbroadcast_count', '3': 10, '4': 1, '5': 3, '10': 'unbroadcastCount'},
    {'1': 'full_rbf', '3': 11, '4': 1, '5': 8, '10': 'fullRbf'},
  ],
};

/// Descriptor for `GetCoreMempoolInfoResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCoreMempoolInfoResponseDescriptor =
    $convert.base64Decode('ChpHZXRDb3JlTWVtcG9vbEluZm9SZXNwb25zZRIWCgZsb2FkZWQYASABKAhSBmxvYWRlZBISCg'
        'RzaXplGAIgASgDUgRzaXplEhQKBWJ5dGVzGAMgASgDUgVieXRlcxIUCgV1c2FnZRgEIAEoA1IF'
        'dXNhZ2USGwoJdG90YWxfZmVlGAUgASgBUgh0b3RhbEZlZRIfCgttYXhfbWVtcG9vbBgGIAEoA1'
        'IKbWF4TWVtcG9vbBImCg9tZW1wb29sX21pbl9mZWUYByABKAFSDW1lbXBvb2xNaW5GZWUSJwoQ'
        'bWluX3JlbGF5X3R4X2ZlZRgIIAEoAVINbWluUmVsYXlUeEZlZRIyChVpbmNyZW1lbnRhbF9yZW'
        'xheV9mZWUYCSABKAFSE2luY3JlbWVudGFsUmVsYXlGZWUSKwoRdW5icm9hZGNhc3RfY291bnQY'
        'CiABKANSEHVuYnJvYWRjYXN0Q291bnQSGQoIZnVsbF9yYmYYCyABKAhSB2Z1bGxSYmY=');

@$core.Deprecated('Use coreRawCallRequestDescriptor instead')
const CoreRawCallRequest$json = {
  '1': 'CoreRawCallRequest',
  '2': [
    {'1': 'method', '3': 1, '4': 1, '5': 9, '10': 'method'},
    {'1': 'params_json', '3': 2, '4': 1, '5': 9, '10': 'paramsJson'},
    {'1': 'wallet', '3': 3, '4': 1, '5': 9, '10': 'wallet'},
  ],
};

/// Descriptor for `CoreRawCallRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List coreRawCallRequestDescriptor =
    $convert.base64Decode('ChJDb3JlUmF3Q2FsbFJlcXVlc3QSFgoGbWV0aG9kGAEgASgJUgZtZXRob2QSHwoLcGFyYW1zX2'
        'pzb24YAiABKAlSCnBhcmFtc0pzb24SFgoGd2FsbGV0GAMgASgJUgZ3YWxsZXQ=');

@$core.Deprecated('Use coreRawCallResponseDescriptor instead')
const CoreRawCallResponse$json = {
  '1': 'CoreRawCallResponse',
  '2': [
    {'1': 'result_json', '3': 1, '4': 1, '5': 9, '10': 'resultJson'},
  ],
};

/// Descriptor for `CoreRawCallResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List coreRawCallResponseDescriptor =
    $convert.base64Decode('ChNDb3JlUmF3Q2FsbFJlc3BvbnNlEh8KC3Jlc3VsdF9qc29uGAEgASgJUgpyZXN1bHRKc29u');

const $core.Map<$core.String, $core.dynamic> OrchestratorServiceBase$json = {
  '1': 'OrchestratorService',
  '2': [
    {'1': 'ListBinaries', '2': '.orchestrator.v1.ListBinariesRequest', '3': '.orchestrator.v1.ListBinariesResponse'},
    {
      '1': 'GetBinaryStatus',
      '2': '.orchestrator.v1.GetBinaryStatusRequest',
      '3': '.orchestrator.v1.GetBinaryStatusResponse'
    },
    {
      '1': 'DownloadBinary',
      '2': '.orchestrator.v1.DownloadBinaryRequest',
      '3': '.orchestrator.v1.DownloadBinaryResponse'
    },
    {'1': 'StartBinary', '2': '.orchestrator.v1.StartBinaryRequest', '3': '.orchestrator.v1.StartBinaryResponse'},
    {'1': 'StopBinary', '2': '.orchestrator.v1.StopBinaryRequest', '3': '.orchestrator.v1.StopBinaryResponse'},
    {
      '1': 'StreamLogs',
      '2': '.orchestrator.v1.StreamLogsRequest',
      '3': '.orchestrator.v1.StreamLogsResponse',
      '6': true
    },
    {'1': 'StartWithL1', '2': '.orchestrator.v1.StartWithL1Request', '3': '.orchestrator.v1.StartWithL1Response'},
    {
      '1': 'ShutdownAll',
      '2': '.orchestrator.v1.ShutdownAllRequest',
      '3': '.orchestrator.v1.ShutdownAllResponse',
      '6': true
    },
    {'1': 'GetBTCPrice', '2': '.orchestrator.v1.GetBTCPriceRequest', '3': '.orchestrator.v1.GetBTCPriceResponse'},
    {
      '1': 'GetMainchainBlockchainInfo',
      '2': '.orchestrator.v1.GetMainchainBlockchainInfoRequest',
      '3': '.orchestrator.v1.GetMainchainBlockchainInfoResponse'
    },
    {
      '1': 'GetEnforcerBlockchainInfo',
      '2': '.orchestrator.v1.GetEnforcerBlockchainInfoRequest',
      '3': '.orchestrator.v1.GetEnforcerBlockchainInfoResponse'
    },
    {'1': 'GetSyncStatus', '2': '.orchestrator.v1.GetSyncStatusRequest', '3': '.orchestrator.v1.GetSyncStatusResponse'},
    {
      '1': 'GetMainchainBalance',
      '2': '.orchestrator.v1.GetMainchainBalanceRequest',
      '3': '.orchestrator.v1.GetMainchainBalanceResponse'
    },
    {
      '1': 'PreviewResetData',
      '2': '.orchestrator.v1.PreviewResetDataRequest',
      '3': '.orchestrator.v1.PreviewResetDataResponse'
    },
    {
      '1': 'StreamResetData',
      '2': '.orchestrator.v1.StreamResetDataRequest',
      '3': '.orchestrator.v1.StreamResetDataResponse',
      '6': true
    },
    {
      '1': 'GetCoreMempoolInfo',
      '2': '.orchestrator.v1.GetCoreMempoolInfoRequest',
      '3': '.orchestrator.v1.GetCoreMempoolInfoResponse'
    },
    {'1': 'CoreRawCall', '2': '.orchestrator.v1.CoreRawCallRequest', '3': '.orchestrator.v1.CoreRawCallResponse'},
  ],
};

@$core.Deprecated('Use orchestratorServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> OrchestratorServiceBase$messageJson = {
  '.orchestrator.v1.ListBinariesRequest': ListBinariesRequest$json,
  '.orchestrator.v1.ListBinariesResponse': ListBinariesResponse$json,
  '.orchestrator.v1.BinaryStatusMsg': BinaryStatusMsg$json,
  '.orchestrator.v1.StartupLogEntryMsg': StartupLogEntryMsg$json,
  '.orchestrator.v1.GetBinaryStatusRequest': GetBinaryStatusRequest$json,
  '.orchestrator.v1.GetBinaryStatusResponse': GetBinaryStatusResponse$json,
  '.orchestrator.v1.DownloadBinaryRequest': DownloadBinaryRequest$json,
  '.orchestrator.v1.DownloadBinaryResponse': DownloadBinaryResponse$json,
  '.orchestrator.v1.StartBinaryRequest': StartBinaryRequest$json,
  '.orchestrator.v1.StartBinaryRequest.EnvEntry': StartBinaryRequest_EnvEntry$json,
  '.orchestrator.v1.StartBinaryResponse': StartBinaryResponse$json,
  '.orchestrator.v1.StopBinaryRequest': StopBinaryRequest$json,
  '.orchestrator.v1.StopBinaryResponse': StopBinaryResponse$json,
  '.orchestrator.v1.StreamLogsRequest': StreamLogsRequest$json,
  '.orchestrator.v1.StreamLogsResponse': StreamLogsResponse$json,
  '.orchestrator.v1.StartWithL1Request': StartWithL1Request$json,
  '.orchestrator.v1.StartWithL1Request.TargetEnvEntry': StartWithL1Request_TargetEnvEntry$json,
  '.orchestrator.v1.StartWithL1Response': StartWithL1Response$json,
  '.orchestrator.v1.ShutdownAllRequest': ShutdownAllRequest$json,
  '.orchestrator.v1.ShutdownAllResponse': ShutdownAllResponse$json,
  '.orchestrator.v1.GetBTCPriceRequest': GetBTCPriceRequest$json,
  '.orchestrator.v1.GetBTCPriceResponse': GetBTCPriceResponse$json,
  '.orchestrator.v1.GetMainchainBlockchainInfoRequest': GetMainchainBlockchainInfoRequest$json,
  '.orchestrator.v1.GetMainchainBlockchainInfoResponse': GetMainchainBlockchainInfoResponse$json,
  '.orchestrator.v1.GetEnforcerBlockchainInfoRequest': GetEnforcerBlockchainInfoRequest$json,
  '.orchestrator.v1.GetEnforcerBlockchainInfoResponse': GetEnforcerBlockchainInfoResponse$json,
  '.orchestrator.v1.GetSyncStatusRequest': GetSyncStatusRequest$json,
  '.orchestrator.v1.GetSyncStatusResponse': GetSyncStatusResponse$json,
  '.orchestrator.v1.ChainSync': ChainSync$json,
  '.orchestrator.v1.SidechainStatus': SidechainStatus$json,
  '.orchestrator.v1.GetMainchainBalanceRequest': GetMainchainBalanceRequest$json,
  '.orchestrator.v1.GetMainchainBalanceResponse': GetMainchainBalanceResponse$json,
  '.orchestrator.v1.PreviewResetDataRequest': PreviewResetDataRequest$json,
  '.orchestrator.v1.PreviewResetDataResponse': PreviewResetDataResponse$json,
  '.orchestrator.v1.ResetFileInfo': ResetFileInfo$json,
  '.orchestrator.v1.StreamResetDataRequest': StreamResetDataRequest$json,
  '.orchestrator.v1.StreamResetDataResponse': StreamResetDataResponse$json,
  '.orchestrator.v1.GetCoreMempoolInfoRequest': GetCoreMempoolInfoRequest$json,
  '.orchestrator.v1.GetCoreMempoolInfoResponse': GetCoreMempoolInfoResponse$json,
  '.orchestrator.v1.CoreRawCallRequest': CoreRawCallRequest$json,
  '.orchestrator.v1.CoreRawCallResponse': CoreRawCallResponse$json,
};

/// Descriptor for `OrchestratorService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List orchestratorServiceDescriptor =
    $convert.base64Decode('ChNPcmNoZXN0cmF0b3JTZXJ2aWNlElsKDExpc3RCaW5hcmllcxIkLm9yY2hlc3RyYXRvci52MS'
        '5MaXN0QmluYXJpZXNSZXF1ZXN0GiUub3JjaGVzdHJhdG9yLnYxLkxpc3RCaW5hcmllc1Jlc3Bv'
        'bnNlEmQKD0dldEJpbmFyeVN0YXR1cxInLm9yY2hlc3RyYXRvci52MS5HZXRCaW5hcnlTdGF0dX'
        'NSZXF1ZXN0Gigub3JjaGVzdHJhdG9yLnYxLkdldEJpbmFyeVN0YXR1c1Jlc3BvbnNlEmEKDkRv'
        'd25sb2FkQmluYXJ5EiYub3JjaGVzdHJhdG9yLnYxLkRvd25sb2FkQmluYXJ5UmVxdWVzdBonLm'
        '9yY2hlc3RyYXRvci52MS5Eb3dubG9hZEJpbmFyeVJlc3BvbnNlElgKC1N0YXJ0QmluYXJ5EiMu'
        'b3JjaGVzdHJhdG9yLnYxLlN0YXJ0QmluYXJ5UmVxdWVzdBokLm9yY2hlc3RyYXRvci52MS5TdG'
        'FydEJpbmFyeVJlc3BvbnNlElUKClN0b3BCaW5hcnkSIi5vcmNoZXN0cmF0b3IudjEuU3RvcEJp'
        'bmFyeVJlcXVlc3QaIy5vcmNoZXN0cmF0b3IudjEuU3RvcEJpbmFyeVJlc3BvbnNlElcKClN0cm'
        'VhbUxvZ3MSIi5vcmNoZXN0cmF0b3IudjEuU3RyZWFtTG9nc1JlcXVlc3QaIy5vcmNoZXN0cmF0'
        'b3IudjEuU3RyZWFtTG9nc1Jlc3BvbnNlMAESWAoLU3RhcnRXaXRoTDESIy5vcmNoZXN0cmF0b3'
        'IudjEuU3RhcnRXaXRoTDFSZXF1ZXN0GiQub3JjaGVzdHJhdG9yLnYxLlN0YXJ0V2l0aEwxUmVz'
        'cG9uc2USWgoLU2h1dGRvd25BbGwSIy5vcmNoZXN0cmF0b3IudjEuU2h1dGRvd25BbGxSZXF1ZX'
        'N0GiQub3JjaGVzdHJhdG9yLnYxLlNodXRkb3duQWxsUmVzcG9uc2UwARJYCgtHZXRCVENQcmlj'
        'ZRIjLm9yY2hlc3RyYXRvci52MS5HZXRCVENQcmljZVJlcXVlc3QaJC5vcmNoZXN0cmF0b3Iudj'
        'EuR2V0QlRDUHJpY2VSZXNwb25zZRKFAQoaR2V0TWFpbmNoYWluQmxvY2tjaGFpbkluZm8SMi5v'
        'cmNoZXN0cmF0b3IudjEuR2V0TWFpbmNoYWluQmxvY2tjaGFpbkluZm9SZXF1ZXN0GjMub3JjaG'
        'VzdHJhdG9yLnYxLkdldE1haW5jaGFpbkJsb2NrY2hhaW5JbmZvUmVzcG9uc2USggEKGUdldEVu'
        'Zm9yY2VyQmxvY2tjaGFpbkluZm8SMS5vcmNoZXN0cmF0b3IudjEuR2V0RW5mb3JjZXJCbG9ja2'
        'NoYWluSW5mb1JlcXVlc3QaMi5vcmNoZXN0cmF0b3IudjEuR2V0RW5mb3JjZXJCbG9ja2NoYWlu'
        'SW5mb1Jlc3BvbnNlEl4KDUdldFN5bmNTdGF0dXMSJS5vcmNoZXN0cmF0b3IudjEuR2V0U3luY1'
        'N0YXR1c1JlcXVlc3QaJi5vcmNoZXN0cmF0b3IudjEuR2V0U3luY1N0YXR1c1Jlc3BvbnNlEnAK'
        'E0dldE1haW5jaGFpbkJhbGFuY2USKy5vcmNoZXN0cmF0b3IudjEuR2V0TWFpbmNoYWluQmFsYW'
        '5jZVJlcXVlc3QaLC5vcmNoZXN0cmF0b3IudjEuR2V0TWFpbmNoYWluQmFsYW5jZVJlc3BvbnNl'
        'EmcKEFByZXZpZXdSZXNldERhdGESKC5vcmNoZXN0cmF0b3IudjEuUHJldmlld1Jlc2V0RGF0YV'
        'JlcXVlc3QaKS5vcmNoZXN0cmF0b3IudjEuUHJldmlld1Jlc2V0RGF0YVJlc3BvbnNlEmYKD1N0'
        'cmVhbVJlc2V0RGF0YRInLm9yY2hlc3RyYXRvci52MS5TdHJlYW1SZXNldERhdGFSZXF1ZXN0Gi'
        'gub3JjaGVzdHJhdG9yLnYxLlN0cmVhbVJlc2V0RGF0YVJlc3BvbnNlMAESbQoSR2V0Q29yZU1l'
        'bXBvb2xJbmZvEioub3JjaGVzdHJhdG9yLnYxLkdldENvcmVNZW1wb29sSW5mb1JlcXVlc3QaKy'
        '5vcmNoZXN0cmF0b3IudjEuR2V0Q29yZU1lbXBvb2xJbmZvUmVzcG9uc2USWAoLQ29yZVJhd0Nh'
        'bGwSIy5vcmNoZXN0cmF0b3IudjEuQ29yZVJhd0NhbGxSZXF1ZXN0GiQub3JjaGVzdHJhdG9yLn'
        'YxLkNvcmVSYXdDYWxsUmVzcG9uc2U=');
