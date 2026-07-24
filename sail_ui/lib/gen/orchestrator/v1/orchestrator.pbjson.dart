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
final $typed_data.Uint8List sidechainTypeDescriptor = $convert.base64Decode(
    'Cg1TaWRlY2hhaW5UeXBlEh4KGlNJREVDSEFJTl9UWVBFX1VOU1BFQ0lGSUVEEAASGgoWU0lERU'
    'NIQUlOX1RZUEVfVEhVTkRFUhABEhgKFFNJREVDSEFJTl9UWVBFX1pTSURFEAISGwoXU0lERUNI'
    'QUlOX1RZUEVfQklUTkFNRVMQAxIcChhTSURFQ0hBSU5fVFlQRV9CSVRBU1NFVFMQBBIcChhTSU'
    'RFQ0hBSU5fVFlQRV9UUlVUSENPSU4QBRIZChVTSURFQ0hBSU5fVFlQRV9QSE9UT04QBhIcChhT'
    'SURFQ0hBSU5fVFlQRV9DT0lOU0hJRlQQBw==');

@$core.Deprecated('Use binaryTypeDescriptor instead')
const BinaryType$json = {
  '1': 'BinaryType',
  '2': [
    {'1': 'BINARY_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'BINARY_TYPE_BITCOIND', '2': 1},
    {'1': 'BINARY_TYPE_ENFORCER', '2': 2},
    {'1': 'BINARY_TYPE_BITWINDOWD', '2': 3},
    {'1': 'BINARY_TYPE_THUNDER', '2': 4},
    {'1': 'BINARY_TYPE_ZSIDE', '2': 5},
    {'1': 'BINARY_TYPE_BITNAMES', '2': 6},
    {'1': 'BINARY_TYPE_BITASSETS', '2': 7},
    {'1': 'BINARY_TYPE_TRUTHCOIN', '2': 8},
    {'1': 'BINARY_TYPE_PHOTON', '2': 9},
    {'1': 'BINARY_TYPE_COINSHIFT', '2': 10},
    {'1': 'BINARY_TYPE_GRPCURL', '2': 11},
    {'1': 'BINARY_TYPE_ORCHESTRATORD', '2': 12},
    {'1': 'BINARY_TYPE_ZSIDED', '2': 13},
    {'1': 'BINARY_TYPE_LIQUID_SIGNET', '2': 14},
  ],
};

/// Descriptor for `BinaryType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List binaryTypeDescriptor = $convert.base64Decode(
    'CgpCaW5hcnlUeXBlEhsKF0JJTkFSWV9UWVBFX1VOU1BFQ0lGSUVEEAASGAoUQklOQVJZX1RZUE'
    'VfQklUQ09JTkQQARIYChRCSU5BUllfVFlQRV9FTkZPUkNFUhACEhoKFkJJTkFSWV9UWVBFX0JJ'
    'VFdJTkRPV0QQAxIXChNCSU5BUllfVFlQRV9USFVOREVSEAQSFQoRQklOQVJZX1RZUEVfWlNJRE'
    'UQBRIYChRCSU5BUllfVFlQRV9CSVROQU1FUxAGEhkKFUJJTkFSWV9UWVBFX0JJVEFTU0VUUxAH'
    'EhkKFUJJTkFSWV9UWVBFX1RSVVRIQ09JThAIEhYKEkJJTkFSWV9UWVBFX1BIT1RPThAJEhkKFU'
    'JJTkFSWV9UWVBFX0NPSU5TSElGVBAKEhcKE0JJTkFSWV9UWVBFX0dSUENVUkwQCxIdChlCSU5B'
    'UllfVFlQRV9PUkNIRVNUUkFUT1JEEAwSFgoSQklOQVJZX1RZUEVfWlNJREVEEA0SHQoZQklOQV'
    'JZX1RZUEVfTElRVUlEX1NJR05FVBAO');

@$core.Deprecated('Use deletionTypeDescriptor instead')
const DeletionType$json = {
  '1': 'DeletionType',
  '2': [
    {'1': 'DELETION_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'DELETION_TYPE_DATA', '2': 1},
    {'1': 'DELETION_TYPE_WALLET', '2': 2},
    {'1': 'DELETION_TYPE_SETTINGS', '2': 3},
    {'1': 'DELETION_TYPE_LOGS', '2': 4},
    {'1': 'DELETION_TYPE_SOFTWARE', '2': 5},
  ],
};

/// Descriptor for `DeletionType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List deletionTypeDescriptor = $convert.base64Decode(
    'CgxEZWxldGlvblR5cGUSHQoZREVMRVRJT05fVFlQRV9VTlNQRUNJRklFRBAAEhYKEkRFTEVUSU'
    '9OX1RZUEVfREFUQRABEhgKFERFTEVUSU9OX1RZUEVfV0FMTEVUEAISGgoWREVMRVRJT05fVFlQ'
    'RV9TRVRUSU5HUxADEhYKEkRFTEVUSU9OX1RZUEVfTE9HUxAEEhoKFkRFTEVUSU9OX1RZUEVfU0'
    '9GVFdBUkUQBQ==');

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
final $typed_data.Uint8List binaryStatusMsgDescriptor = $convert.base64Decode(
    'Cg9CaW5hcnlTdGF0dXNNc2cSEgoEbmFtZRgBIAEoCVIEbmFtZRIhCgxkaXNwbGF5X25hbWUYAi'
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
final $typed_data.Uint8List startupLogEntryMsgDescriptor = $convert.base64Decode(
    'ChJTdGFydHVwTG9nRW50cnlNc2cSJQoOdGltZXN0YW1wX3VuaXgYASABKANSDXRpbWVzdGFtcF'
    'VuaXgSGAoHbWVzc2FnZRgCIAEoCVIHbWVzc2FnZQ==');

@$core.Deprecated('Use listBinariesRequestDescriptor instead')
const ListBinariesRequest$json = {
  '1': 'ListBinariesRequest',
};

/// Descriptor for `ListBinariesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listBinariesRequestDescriptor = $convert.base64Decode(
    'ChNMaXN0QmluYXJpZXNSZXF1ZXN0');

@$core.Deprecated('Use listBinariesResponseDescriptor instead')
const ListBinariesResponse$json = {
  '1': 'ListBinariesResponse',
  '2': [
    {'1': 'binaries', '3': 1, '4': 3, '5': 11, '6': '.orchestrator.v1.BinaryStatusMsg', '10': 'binaries'},
  ],
};

/// Descriptor for `ListBinariesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listBinariesResponseDescriptor = $convert.base64Decode(
    'ChRMaXN0QmluYXJpZXNSZXNwb25zZRI8CghiaW5hcmllcxgBIAMoCzIgLm9yY2hlc3RyYXRvci'
    '52MS5CaW5hcnlTdGF0dXNNc2dSCGJpbmFyaWVz');

@$core.Deprecated('Use getBinaryStatusRequestDescriptor instead')
const GetBinaryStatusRequest$json = {
  '1': 'GetBinaryStatusRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `GetBinaryStatusRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBinaryStatusRequestDescriptor = $convert.base64Decode(
    'ChZHZXRCaW5hcnlTdGF0dXNSZXF1ZXN0EhIKBG5hbWUYASABKAlSBG5hbWU=');

@$core.Deprecated('Use getBinaryStatusResponseDescriptor instead')
const GetBinaryStatusResponse$json = {
  '1': 'GetBinaryStatusResponse',
  '2': [
    {'1': 'status', '3': 1, '4': 1, '5': 11, '6': '.orchestrator.v1.BinaryStatusMsg', '10': 'status'},
  ],
};

/// Descriptor for `GetBinaryStatusResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBinaryStatusResponseDescriptor = $convert.base64Decode(
    'ChdHZXRCaW5hcnlTdGF0dXNSZXNwb25zZRI4CgZzdGF0dXMYASABKAsyIC5vcmNoZXN0cmF0b3'
    'IudjEuQmluYXJ5U3RhdHVzTXNnUgZzdGF0dXM=');

@$core.Deprecated('Use getBinaryVersionRequestDescriptor instead')
const GetBinaryVersionRequest$json = {
  '1': 'GetBinaryVersionRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'force_backend', '3': 2, '4': 1, '5': 8, '10': 'forceBackend'},
  ],
};

/// Descriptor for `GetBinaryVersionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBinaryVersionRequestDescriptor = $convert.base64Decode(
    'ChdHZXRCaW5hcnlWZXJzaW9uUmVxdWVzdBISCgRuYW1lGAEgASgJUgRuYW1lEiMKDWZvcmNlX2'
    'JhY2tlbmQYAiABKAhSDGZvcmNlQmFja2VuZA==');

@$core.Deprecated('Use getBinaryVersionResponseDescriptor instead')
const GetBinaryVersionResponse$json = {
  '1': 'GetBinaryVersionResponse',
  '2': [
    {'1': 'version', '3': 1, '4': 1, '5': 9, '10': 'version'},
    {'1': 'binary_path', '3': 2, '4': 1, '5': 9, '10': 'binaryPath'},
    {'1': 'is_test_build', '3': 3, '4': 1, '5': 8, '10': 'isTestBuild'},
  ],
};

/// Descriptor for `GetBinaryVersionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBinaryVersionResponseDescriptor = $convert.base64Decode(
    'ChhHZXRCaW5hcnlWZXJzaW9uUmVzcG9uc2USGAoHdmVyc2lvbhgBIAEoCVIHdmVyc2lvbhIfCg'
    'tiaW5hcnlfcGF0aBgCIAEoCVIKYmluYXJ5UGF0aBIiCg1pc190ZXN0X2J1aWxkGAMgASgIUgtp'
    'c1Rlc3RCdWlsZA==');

@$core.Deprecated('Use downloadBinaryRequestDescriptor instead')
const DownloadBinaryRequest$json = {
  '1': 'DownloadBinaryRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'force', '3': 2, '4': 1, '5': 8, '10': 'force'},
  ],
};

/// Descriptor for `DownloadBinaryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List downloadBinaryRequestDescriptor = $convert.base64Decode(
    'ChVEb3dubG9hZEJpbmFyeVJlcXVlc3QSEgoEbmFtZRgBIAEoCVIEbmFtZRIUCgVmb3JjZRgCIA'
    'EoCFIFZm9yY2U=');

@$core.Deprecated('Use downloadBinaryResponseDescriptor instead')
const DownloadBinaryResponse$json = {
  '1': 'DownloadBinaryResponse',
};

/// Descriptor for `DownloadBinaryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List downloadBinaryResponseDescriptor = $convert.base64Decode(
    'ChZEb3dubG9hZEJpbmFyeVJlc3BvbnNl');

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
final $typed_data.Uint8List startBinaryRequestDescriptor = $convert.base64Decode(
    'ChJTdGFydEJpbmFyeVJlcXVlc3QSEgoEbmFtZRgBIAEoCVIEbmFtZRIdCgpleHRyYV9hcmdzGA'
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
final $typed_data.Uint8List startBinaryResponseDescriptor = $convert.base64Decode(
    'ChNTdGFydEJpbmFyeVJlc3BvbnNlEhAKA3BpZBgBIAEoBVIDcGlk');

@$core.Deprecated('Use stopBinaryRequestDescriptor instead')
const StopBinaryRequest$json = {
  '1': 'StopBinaryRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'force', '3': 2, '4': 1, '5': 8, '10': 'force'},
  ],
};

/// Descriptor for `StopBinaryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List stopBinaryRequestDescriptor = $convert.base64Decode(
    'ChFTdG9wQmluYXJ5UmVxdWVzdBISCgRuYW1lGAEgASgJUgRuYW1lEhQKBWZvcmNlGAIgASgIUg'
    'Vmb3JjZQ==');

@$core.Deprecated('Use stopBinaryResponseDescriptor instead')
const StopBinaryResponse$json = {
  '1': 'StopBinaryResponse',
};

/// Descriptor for `StopBinaryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List stopBinaryResponseDescriptor = $convert.base64Decode(
    'ChJTdG9wQmluYXJ5UmVzcG9uc2U=');

@$core.Deprecated('Use streamLogsRequestDescriptor instead')
const StreamLogsRequest$json = {
  '1': 'StreamLogsRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'tail', '3': 2, '4': 1, '5': 5, '10': 'tail'},
  ],
};

/// Descriptor for `StreamLogsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamLogsRequestDescriptor = $convert.base64Decode(
    'ChFTdHJlYW1Mb2dzUmVxdWVzdBISCgRuYW1lGAEgASgJUgRuYW1lEhIKBHRhaWwYAiABKAVSBH'
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
final $typed_data.Uint8List streamLogsResponseDescriptor = $convert.base64Decode(
    'ChJTdHJlYW1Mb2dzUmVzcG9uc2USFgoGc3RyZWFtGAEgASgJUgZzdHJlYW0SEgoEbGluZRgCIA'
    'EoCVIEbGluZRIlCg50aW1lc3RhbXBfdW5peBgDIAEoA1INdGltZXN0YW1wVW5peA==');

@$core.Deprecated('Use startWithL1RequestDescriptor instead')
const StartWithL1Request$json = {
  '1': 'StartWithL1Request',
  '2': [
    {'1': 'target', '3': 1, '4': 1, '5': 9, '10': 'target'},
    {'1': 'target_args', '3': 2, '4': 3, '5': 9, '10': 'targetArgs'},
    {'1': 'target_env', '3': 3, '4': 3, '5': 11, '6': '.orchestrator.v1.StartWithL1Request.TargetEnvEntry', '10': 'targetEnv'},
    {'1': 'core_args', '3': 4, '4': 3, '5': 9, '10': 'coreArgs'},
    {'1': 'enforcer_args', '3': 5, '4': 3, '5': 9, '10': 'enforcerArgs'},
    {'1': 'immediate', '3': 6, '4': 1, '5': 8, '10': 'immediate'},
    {'1': 'force_backend', '3': 7, '4': 1, '5': 8, '10': 'forceBackend'},
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
final $typed_data.Uint8List startWithL1RequestDescriptor = $convert.base64Decode(
    'ChJTdGFydFdpdGhMMVJlcXVlc3QSFgoGdGFyZ2V0GAEgASgJUgZ0YXJnZXQSHwoLdGFyZ2V0X2'
    'FyZ3MYAiADKAlSCnRhcmdldEFyZ3MSUQoKdGFyZ2V0X2VudhgDIAMoCzIyLm9yY2hlc3RyYXRv'
    'ci52MS5TdGFydFdpdGhMMVJlcXVlc3QuVGFyZ2V0RW52RW50cnlSCXRhcmdldEVudhIbCgljb3'
    'JlX2FyZ3MYBCADKAlSCGNvcmVBcmdzEiMKDWVuZm9yY2VyX2FyZ3MYBSADKAlSDGVuZm9yY2Vy'
    'QXJncxIcCglpbW1lZGlhdGUYBiABKAhSCWltbWVkaWF0ZRIjCg1mb3JjZV9iYWNrZW5kGAcgAS'
    'gIUgxmb3JjZUJhY2tlbmQaPAoOVGFyZ2V0RW52RW50cnkSEAoDa2V5GAEgASgJUgNrZXkSFAoF'
    'dmFsdWUYAiABKAlSBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use startWithL1ResponseDescriptor instead')
const StartWithL1Response$json = {
  '1': 'StartWithL1Response',
};

/// Descriptor for `StartWithL1Response`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List startWithL1ResponseDescriptor = $convert.base64Decode(
    'ChNTdGFydFdpdGhMMVJlc3BvbnNl');

@$core.Deprecated('Use restartDaemonRequestDescriptor instead')
const RestartDaemonRequest$json = {
  '1': 'RestartDaemonRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `RestartDaemonRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List restartDaemonRequestDescriptor = $convert.base64Decode(
    'ChRSZXN0YXJ0RGFlbW9uUmVxdWVzdBISCgRuYW1lGAEgASgJUgRuYW1l');

@$core.Deprecated('Use restartDaemonResponseDescriptor instead')
const RestartDaemonResponse$json = {
  '1': 'RestartDaemonResponse',
};

/// Descriptor for `RestartDaemonResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List restartDaemonResponseDescriptor = $convert.base64Decode(
    'ChVSZXN0YXJ0RGFlbW9uUmVzcG9uc2U=');

@$core.Deprecated('Use restartL1RequestDescriptor instead')
const RestartL1Request$json = {
  '1': 'RestartL1Request',
};

/// Descriptor for `RestartL1Request`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List restartL1RequestDescriptor = $convert.base64Decode(
    'ChBSZXN0YXJ0TDFSZXF1ZXN0');

@$core.Deprecated('Use restartL1ResponseDescriptor instead')
const RestartL1Response$json = {
  '1': 'RestartL1Response',
};

/// Descriptor for `RestartL1Response`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List restartL1ResponseDescriptor = $convert.base64Decode(
    'ChFSZXN0YXJ0TDFSZXNwb25zZQ==');

@$core.Deprecated('Use applyUTXOSnapshotRequestDescriptor instead')
const ApplyUTXOSnapshotRequest$json = {
  '1': 'ApplyUTXOSnapshotRequest',
  '2': [
    {'1': 'url', '3': 1, '4': 1, '5': 9, '10': 'url'},
    {'1': 'path', '3': 2, '4': 1, '5': 9, '10': 'path'},
    {'1': 'sha256', '3': 3, '4': 1, '5': 9, '10': 'sha256'},
  ],
};

/// Descriptor for `ApplyUTXOSnapshotRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List applyUTXOSnapshotRequestDescriptor = $convert.base64Decode(
    'ChhBcHBseVVUWE9TbmFwc2hvdFJlcXVlc3QSEAoDdXJsGAEgASgJUgN1cmwSEgoEcGF0aBgCIA'
    'EoCVIEcGF0aBIWCgZzaGEyNTYYAyABKAlSBnNoYTI1Ng==');

@$core.Deprecated('Use applyUTXOSnapshotResponseDescriptor instead')
const ApplyUTXOSnapshotResponse$json = {
  '1': 'ApplyUTXOSnapshotResponse',
  '2': [
    {'1': 'message', '3': 1, '4': 1, '5': 9, '10': 'message'},
    {'1': 'download_percent', '3': 2, '4': 1, '5': 5, '10': 'downloadPercent'},
    {'1': 'done', '3': 3, '4': 1, '5': 8, '10': 'done'},
  ],
};

/// Descriptor for `ApplyUTXOSnapshotResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List applyUTXOSnapshotResponseDescriptor = $convert.base64Decode(
    'ChlBcHBseVVUWE9TbmFwc2hvdFJlc3BvbnNlEhgKB21lc3NhZ2UYASABKAlSB21lc3NhZ2USKQ'
    'oQZG93bmxvYWRfcGVyY2VudBgCIAEoBVIPZG93bmxvYWRQZXJjZW50EhIKBGRvbmUYAyABKAhS'
    'BGRvbmU=');

@$core.Deprecated('Use getSnapshotStatusRequestDescriptor instead')
const GetSnapshotStatusRequest$json = {
  '1': 'GetSnapshotStatusRequest',
};

/// Descriptor for `GetSnapshotStatusRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSnapshotStatusRequestDescriptor = $convert.base64Decode(
    'ChhHZXRTbmFwc2hvdFN0YXR1c1JlcXVlc3Q=');

@$core.Deprecated('Use getSnapshotStatusResponseDescriptor instead')
const GetSnapshotStatusResponse$json = {
  '1': 'GetSnapshotStatusResponse',
  '2': [
    {'1': 'available_url', '3': 1, '4': 1, '5': 9, '10': 'availableUrl'},
    {'1': 'available_height', '3': 2, '4': 1, '5': 3, '10': 'availableHeight'},
    {'1': 'available_sha256', '3': 3, '4': 1, '5': 9, '10': 'availableSha256'},
    {'1': 'has_active_snapshot', '3': 4, '4': 1, '5': 8, '10': 'hasActiveSnapshot'},
    {'1': 'active_blockhash', '3': 5, '4': 1, '5': 9, '10': 'activeBlockhash'},
    {'1': 'active_height', '3': 6, '4': 1, '5': 3, '10': 'activeHeight'},
    {'1': 'active_validated', '3': 7, '4': 1, '5': 8, '10': 'activeValidated'},
    {'1': 'active_verification_progress', '3': 8, '4': 1, '5': 1, '10': 'activeVerificationProgress'},
  ],
};

/// Descriptor for `GetSnapshotStatusResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSnapshotStatusResponseDescriptor = $convert.base64Decode(
    'ChlHZXRTbmFwc2hvdFN0YXR1c1Jlc3BvbnNlEiMKDWF2YWlsYWJsZV91cmwYASABKAlSDGF2YW'
    'lsYWJsZVVybBIpChBhdmFpbGFibGVfaGVpZ2h0GAIgASgDUg9hdmFpbGFibGVIZWlnaHQSKQoQ'
    'YXZhaWxhYmxlX3NoYTI1NhgDIAEoCVIPYXZhaWxhYmxlU2hhMjU2Ei4KE2hhc19hY3RpdmVfc2'
    '5hcHNob3QYBCABKAhSEWhhc0FjdGl2ZVNuYXBzaG90EikKEGFjdGl2ZV9ibG9ja2hhc2gYBSAB'
    'KAlSD2FjdGl2ZUJsb2NraGFzaBIjCg1hY3RpdmVfaGVpZ2h0GAYgASgDUgxhY3RpdmVIZWlnaH'
    'QSKQoQYWN0aXZlX3ZhbGlkYXRlZBgHIAEoCFIPYWN0aXZlVmFsaWRhdGVkEkAKHGFjdGl2ZV92'
    'ZXJpZmljYXRpb25fcHJvZ3Jlc3MYCCABKAFSGmFjdGl2ZVZlcmlmaWNhdGlvblByb2dyZXNz');

@$core.Deprecated('Use shutdownAllRequestDescriptor instead')
const ShutdownAllRequest$json = {
  '1': 'ShutdownAllRequest',
  '2': [
    {'1': 'force', '3': 1, '4': 1, '5': 8, '10': 'force'},
  ],
};

/// Descriptor for `ShutdownAllRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List shutdownAllRequestDescriptor = $convert.base64Decode(
    'ChJTaHV0ZG93bkFsbFJlcXVlc3QSFAoFZm9yY2UYASABKAhSBWZvcmNl');

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
final $typed_data.Uint8List shutdownAllResponseDescriptor = $convert.base64Decode(
    'ChNTaHV0ZG93bkFsbFJlc3BvbnNlEh8KC3RvdGFsX2NvdW50GAEgASgFUgp0b3RhbENvdW50Ei'
    'cKD2NvbXBsZXRlZF9jb3VudBgCIAEoBVIOY29tcGxldGVkQ291bnQSJQoOY3VycmVudF9iaW5h'
    'cnkYAyABKAlSDWN1cnJlbnRCaW5hcnkSEgoEZG9uZRgEIAEoCFIEZG9uZRIUCgVlcnJvchgFIA'
    'EoCVIFZXJyb3I=');

@$core.Deprecated('Use getBTCPriceRequestDescriptor instead')
const GetBTCPriceRequest$json = {
  '1': 'GetBTCPriceRequest',
};

/// Descriptor for `GetBTCPriceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBTCPriceRequestDescriptor = $convert.base64Decode(
    'ChJHZXRCVENQcmljZVJlcXVlc3Q=');

@$core.Deprecated('Use getBTCPriceResponseDescriptor instead')
const GetBTCPriceResponse$json = {
  '1': 'GetBTCPriceResponse',
  '2': [
    {'1': 'btcusd', '3': 1, '4': 1, '5': 1, '10': 'btcusd'},
    {'1': 'last_updated_unix', '3': 2, '4': 1, '5': 3, '10': 'lastUpdatedUnix'},
  ],
};

/// Descriptor for `GetBTCPriceResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBTCPriceResponseDescriptor = $convert.base64Decode(
    'ChNHZXRCVENQcmljZVJlc3BvbnNlEhYKBmJ0Y3VzZBgBIAEoAVIGYnRjdXNkEioKEWxhc3RfdX'
    'BkYXRlZF91bml4GAIgASgDUg9sYXN0VXBkYXRlZFVuaXg=');

@$core.Deprecated('Use getMainchainBlockchainInfoRequestDescriptor instead')
const GetMainchainBlockchainInfoRequest$json = {
  '1': 'GetMainchainBlockchainInfoRequest',
};

/// Descriptor for `GetMainchainBlockchainInfoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMainchainBlockchainInfoRequestDescriptor = $convert.base64Decode(
    'CiFHZXRNYWluY2hhaW5CbG9ja2NoYWluSW5mb1JlcXVlc3Q=');

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
final $typed_data.Uint8List getMainchainBlockchainInfoResponseDescriptor = $convert.base64Decode(
    'CiJHZXRNYWluY2hhaW5CbG9ja2NoYWluSW5mb1Jlc3BvbnNlEhQKBWNoYWluGAEgASgJUgVjaG'
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
final $typed_data.Uint8List getEnforcerBlockchainInfoRequestDescriptor = $convert.base64Decode(
    'CiBHZXRFbmZvcmNlckJsb2NrY2hhaW5JbmZvUmVxdWVzdA==');

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
final $typed_data.Uint8List getEnforcerBlockchainInfoResponseDescriptor = $convert.base64Decode(
    'CiFHZXRFbmZvcmNlckJsb2NrY2hhaW5JbmZvUmVzcG9uc2USFgoGYmxvY2tzGAEgASgFUgZibG'
    '9ja3MSGAoHaGVhZGVycxgCIAEoBVIHaGVhZGVycxISCgR0aW1lGAMgASgDUgR0aW1l');

@$core.Deprecated('Use getSyncStatusRequestDescriptor instead')
const GetSyncStatusRequest$json = {
  '1': 'GetSyncStatusRequest',
};

/// Descriptor for `GetSyncStatusRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSyncStatusRequestDescriptor = $convert.base64Decode(
    'ChRHZXRTeW5jU3RhdHVzUmVxdWVzdA==');

@$core.Deprecated('Use getSyncStatusResponseDescriptor instead')
const GetSyncStatusResponse$json = {
  '1': 'GetSyncStatusResponse',
  '2': [
    {'1': 'mainchain', '3': 1, '4': 1, '5': 11, '6': '.orchestrator.v1.ChainSync', '10': 'mainchain'},
    {'1': 'enforcer', '3': 2, '4': 1, '5': 11, '6': '.orchestrator.v1.ChainSync', '10': 'enforcer'},
    {'1': 'sidechains', '3': 3, '4': 3, '5': 11, '6': '.orchestrator.v1.SidechainStatus', '10': 'sidechains'},
    {'1': 'wallet_sync_status', '3': 4, '4': 1, '5': 9, '10': 'walletSyncStatus'},
  ],
};

/// Descriptor for `GetSyncStatusResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSyncStatusResponseDescriptor = $convert.base64Decode(
    'ChVHZXRTeW5jU3RhdHVzUmVzcG9uc2USOAoJbWFpbmNoYWluGAEgASgLMhoub3JjaGVzdHJhdG'
    '9yLnYxLkNoYWluU3luY1IJbWFpbmNoYWluEjYKCGVuZm9yY2VyGAIgASgLMhoub3JjaGVzdHJh'
    'dG9yLnYxLkNoYWluU3luY1IIZW5mb3JjZXISQAoKc2lkZWNoYWlucxgDIAMoCzIgLm9yY2hlc3'
    'RyYXRvci52MS5TaWRlY2hhaW5TdGF0dXNSCnNpZGVjaGFpbnMSLAoSd2FsbGV0X3N5bmNfc3Rh'
    'dHVzGAQgASgJUhB3YWxsZXRTeW5jU3RhdHVz');

@$core.Deprecated('Use sidechainStatusDescriptor instead')
const SidechainStatus$json = {
  '1': 'SidechainStatus',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 14, '6': '.orchestrator.v1.SidechainType', '10': 'type'},
    {'1': 'sync', '3': 2, '4': 1, '5': 11, '6': '.orchestrator.v1.ChainSync', '10': 'sync'},
  ],
};

/// Descriptor for `SidechainStatus`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sidechainStatusDescriptor = $convert.base64Decode(
    'Cg9TaWRlY2hhaW5TdGF0dXMSMgoEdHlwZRgBIAEoDjIeLm9yY2hlc3RyYXRvci52MS5TaWRlY2'
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
  ],
};

/// Descriptor for `ChainSync`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chainSyncDescriptor = $convert.base64Decode(
    'CglDaGFpblN5bmMSFgoGYmxvY2tzGAEgASgFUgZibG9ja3MSGAoHaGVhZGVycxgCIAEoBVIHaG'
    'VhZGVycxISCgR0aW1lGAMgASgDUgR0aW1lEhQKBWVycm9yGAQgASgJUgVlcnJvcg==');

@$core.Deprecated('Use getDownloadStatusRequestDescriptor instead')
const GetDownloadStatusRequest$json = {
  '1': 'GetDownloadStatusRequest',
};

/// Descriptor for `GetDownloadStatusRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getDownloadStatusRequestDescriptor = $convert.base64Decode(
    'ChhHZXREb3dubG9hZFN0YXR1c1JlcXVlc3Q=');

@$core.Deprecated('Use getDownloadStatusResponseDescriptor instead')
const GetDownloadStatusResponse$json = {
  '1': 'GetDownloadStatusResponse',
  '2': [
    {'1': 'downloads', '3': 1, '4': 3, '5': 11, '6': '.orchestrator.v1.DownloadStatus', '10': 'downloads'},
  ],
};

/// Descriptor for `GetDownloadStatusResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getDownloadStatusResponseDescriptor = $convert.base64Decode(
    'ChlHZXREb3dubG9hZFN0YXR1c1Jlc3BvbnNlEj0KCWRvd25sb2FkcxgBIAMoCzIfLm9yY2hlc3'
    'RyYXRvci52MS5Eb3dubG9hZFN0YXR1c1IJZG93bmxvYWRz');

@$core.Deprecated('Use downloadStatusDescriptor instead')
const DownloadStatus$json = {
  '1': 'DownloadStatus',
  '2': [
    {'1': 'binary', '3': 1, '4': 1, '5': 14, '6': '.orchestrator.v1.BinaryType', '10': 'binary'},
    {'1': 'mb_downloaded', '3': 2, '4': 1, '5': 3, '10': 'mbDownloaded'},
    {'1': 'mb_total', '3': 3, '4': 1, '5': 3, '10': 'mbTotal'},
    {'1': 'message', '3': 4, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `DownloadStatus`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List downloadStatusDescriptor = $convert.base64Decode(
    'Cg5Eb3dubG9hZFN0YXR1cxIzCgZiaW5hcnkYASABKA4yGy5vcmNoZXN0cmF0b3IudjEuQmluYX'
    'J5VHlwZVIGYmluYXJ5EiMKDW1iX2Rvd25sb2FkZWQYAiABKANSDG1iRG93bmxvYWRlZBIZCght'
    'Yl90b3RhbBgDIAEoA1IHbWJUb3RhbBIYCgdtZXNzYWdlGAQgASgJUgdtZXNzYWdl');

@$core.Deprecated('Use getMainchainBalanceRequestDescriptor instead')
const GetMainchainBalanceRequest$json = {
  '1': 'GetMainchainBalanceRequest',
};

/// Descriptor for `GetMainchainBalanceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMainchainBalanceRequestDescriptor = $convert.base64Decode(
    'ChpHZXRNYWluY2hhaW5CYWxhbmNlUmVxdWVzdA==');

@$core.Deprecated('Use getMainchainBalanceResponseDescriptor instead')
const GetMainchainBalanceResponse$json = {
  '1': 'GetMainchainBalanceResponse',
  '2': [
    {'1': 'confirmed', '3': 1, '4': 1, '5': 1, '10': 'confirmed'},
    {'1': 'unconfirmed', '3': 2, '4': 1, '5': 1, '10': 'unconfirmed'},
  ],
};

/// Descriptor for `GetMainchainBalanceResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMainchainBalanceResponseDescriptor = $convert.base64Decode(
    'ChtHZXRNYWluY2hhaW5CYWxhbmNlUmVzcG9uc2USHAoJY29uZmlybWVkGAEgASgBUgljb25maX'
    'JtZWQSIAoLdW5jb25maXJtZWQYAiABKAFSC3VuY29uZmlybWVk');

@$core.Deprecated('Use getSidechainBalanceRequestDescriptor instead')
const GetSidechainBalanceRequest$json = {
  '1': 'GetSidechainBalanceRequest',
  '2': [
    {'1': 'sidechain', '3': 1, '4': 1, '5': 14, '6': '.orchestrator.v1.BinaryType', '10': 'sidechain'},
  ],
};

/// Descriptor for `GetSidechainBalanceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSidechainBalanceRequestDescriptor = $convert.base64Decode(
    'ChpHZXRTaWRlY2hhaW5CYWxhbmNlUmVxdWVzdBI5CglzaWRlY2hhaW4YASABKA4yGy5vcmNoZX'
    'N0cmF0b3IudjEuQmluYXJ5VHlwZVIJc2lkZWNoYWlu');

@$core.Deprecated('Use getSidechainBalanceResponseDescriptor instead')
const GetSidechainBalanceResponse$json = {
  '1': 'GetSidechainBalanceResponse',
  '2': [
    {'1': 'confirmed_sats', '3': 1, '4': 1, '5': 4, '10': 'confirmedSats'},
    {'1': 'pending_sats', '3': 2, '4': 1, '5': 4, '10': 'pendingSats'},
  ],
};

/// Descriptor for `GetSidechainBalanceResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSidechainBalanceResponseDescriptor = $convert.base64Decode(
    'ChtHZXRTaWRlY2hhaW5CYWxhbmNlUmVzcG9uc2USJQoOY29uZmlybWVkX3NhdHMYASABKARSDW'
    'NvbmZpcm1lZFNhdHMSIQoMcGVuZGluZ19zYXRzGAIgASgEUgtwZW5kaW5nU2F0cw==');

@$core.Deprecated('Use singleDeletionDescriptor instead')
const SingleDeletion$json = {
  '1': 'SingleDeletion',
  '2': [
    {'1': 'binary', '3': 1, '4': 1, '5': 14, '6': '.orchestrator.v1.BinaryType', '10': 'binary'},
    {'1': 'deletions', '3': 2, '4': 3, '5': 14, '6': '.orchestrator.v1.DeletionType', '10': 'deletions'},
  ],
};

/// Descriptor for `SingleDeletion`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List singleDeletionDescriptor = $convert.base64Decode(
    'Cg5TaW5nbGVEZWxldGlvbhIzCgZiaW5hcnkYASABKA4yGy5vcmNoZXN0cmF0b3IudjEuQmluYX'
    'J5VHlwZVIGYmluYXJ5EjsKCWRlbGV0aW9ucxgCIAMoDjIdLm9yY2hlc3RyYXRvci52MS5EZWxl'
    'dGlvblR5cGVSCWRlbGV0aW9ucw==');

@$core.Deprecated('Use gatherFilesToDeleteRequestDescriptor instead')
const GatherFilesToDeleteRequest$json = {
  '1': 'GatherFilesToDeleteRequest',
  '2': [
    {'1': 'items', '3': 1, '4': 3, '5': 11, '6': '.orchestrator.v1.SingleDeletion', '10': 'items'},
  ],
};

/// Descriptor for `GatherFilesToDeleteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List gatherFilesToDeleteRequestDescriptor = $convert.base64Decode(
    'ChpHYXRoZXJGaWxlc1RvRGVsZXRlUmVxdWVzdBI1CgVpdGVtcxgBIAMoCzIfLm9yY2hlc3RyYX'
    'Rvci52MS5TaW5nbGVEZWxldGlvblIFaXRlbXM=');

@$core.Deprecated('Use gatherFilesToDeleteResponseDescriptor instead')
const GatherFilesToDeleteResponse$json = {
  '1': 'GatherFilesToDeleteResponse',
  '2': [
    {'1': 'files', '3': 1, '4': 3, '5': 11, '6': '.orchestrator.v1.ResetFileInfo', '10': 'files'},
  ],
};

/// Descriptor for `GatherFilesToDeleteResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List gatherFilesToDeleteResponseDescriptor = $convert.base64Decode(
    'ChtHYXRoZXJGaWxlc1RvRGVsZXRlUmVzcG9uc2USNAoFZmlsZXMYASADKAsyHi5vcmNoZXN0cm'
    'F0b3IudjEuUmVzZXRGaWxlSW5mb1IFZmlsZXM=');

@$core.Deprecated('Use resetFileInfoDescriptor instead')
const ResetFileInfo$json = {
  '1': 'ResetFileInfo',
  '2': [
    {'1': 'path', '3': 1, '4': 1, '5': 9, '10': 'path'},
    {'1': 'deletion_type', '3': 2, '4': 1, '5': 14, '6': '.orchestrator.v1.DeletionType', '10': 'deletionType'},
    {'1': 'binary', '3': 3, '4': 1, '5': 14, '6': '.orchestrator.v1.BinaryType', '10': 'binary'},
    {'1': 'size_bytes', '3': 4, '4': 1, '5': 3, '10': 'sizeBytes'},
    {'1': 'is_directory', '3': 5, '4': 1, '5': 8, '10': 'isDirectory'},
  ],
};

/// Descriptor for `ResetFileInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List resetFileInfoDescriptor = $convert.base64Decode(
    'Cg1SZXNldEZpbGVJbmZvEhIKBHBhdGgYASABKAlSBHBhdGgSQgoNZGVsZXRpb25fdHlwZRgCIA'
    'EoDjIdLm9yY2hlc3RyYXRvci52MS5EZWxldGlvblR5cGVSDGRlbGV0aW9uVHlwZRIzCgZiaW5h'
    'cnkYAyABKA4yGy5vcmNoZXN0cmF0b3IudjEuQmluYXJ5VHlwZVIGYmluYXJ5Eh0KCnNpemVfYn'
    'l0ZXMYBCABKANSCXNpemVCeXRlcxIhCgxpc19kaXJlY3RvcnkYBSABKAhSC2lzRGlyZWN0b3J5');

@$core.Deprecated('Use deleteFilesRequestDescriptor instead')
const DeleteFilesRequest$json = {
  '1': 'DeleteFilesRequest',
  '2': [
    {'1': 'items', '3': 1, '4': 3, '5': 11, '6': '.orchestrator.v1.SingleDeletion', '10': 'items'},
    {'1': 'except', '3': 2, '4': 3, '5': 9, '10': 'except'},
  ],
};

/// Descriptor for `DeleteFilesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteFilesRequestDescriptor = $convert.base64Decode(
    'ChJEZWxldGVGaWxlc1JlcXVlc3QSNQoFaXRlbXMYASADKAsyHy5vcmNoZXN0cmF0b3IudjEuU2'
    'luZ2xlRGVsZXRpb25SBWl0ZW1zEhYKBmV4Y2VwdBgCIAMoCVIGZXhjZXB0');

@$core.Deprecated('Use deleteFilesResponseDescriptor instead')
const DeleteFilesResponse$json = {
  '1': 'DeleteFilesResponse',
  '2': [
    {'1': 'path', '3': 1, '4': 1, '5': 9, '10': 'path'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
  ],
};

/// Descriptor for `DeleteFilesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteFilesResponseDescriptor = $convert.base64Decode(
    'ChNEZWxldGVGaWxlc1Jlc3BvbnNlEhIKBHBhdGgYASABKAlSBHBhdGgSFAoFZXJyb3IYAiABKA'
    'lSBWVycm9y');

@$core.Deprecated('Use getCoreMempoolInfoRequestDescriptor instead')
const GetCoreMempoolInfoRequest$json = {
  '1': 'GetCoreMempoolInfoRequest',
};

/// Descriptor for `GetCoreMempoolInfoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCoreMempoolInfoRequestDescriptor = $convert.base64Decode(
    'ChlHZXRDb3JlTWVtcG9vbEluZm9SZXF1ZXN0');

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
final $typed_data.Uint8List getCoreMempoolInfoResponseDescriptor = $convert.base64Decode(
    'ChpHZXRDb3JlTWVtcG9vbEluZm9SZXNwb25zZRIWCgZsb2FkZWQYASABKAhSBmxvYWRlZBISCg'
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
final $typed_data.Uint8List coreRawCallRequestDescriptor = $convert.base64Decode(
    'ChJDb3JlUmF3Q2FsbFJlcXVlc3QSFgoGbWV0aG9kGAEgASgJUgZtZXRob2QSHwoLcGFyYW1zX2'
    'pzb24YAiABKAlSCnBhcmFtc0pzb24SFgoGd2FsbGV0GAMgASgJUgZ3YWxsZXQ=');

@$core.Deprecated('Use coreRawCallResponseDescriptor instead')
const CoreRawCallResponse$json = {
  '1': 'CoreRawCallResponse',
  '2': [
    {'1': 'result_json', '3': 1, '4': 1, '5': 9, '10': 'resultJson'},
  ],
};

/// Descriptor for `CoreRawCallResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List coreRawCallResponseDescriptor = $convert.base64Decode(
    'ChNDb3JlUmF3Q2FsbFJlc3BvbnNlEh8KC3Jlc3VsdF9qc29uGAEgASgJUgpyZXN1bHRKc29u');

@$core.Deprecated('Use getForkStatusRequestDescriptor instead')
const GetForkStatusRequest$json = {
  '1': 'GetForkStatusRequest',
};

/// Descriptor for `GetForkStatusRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getForkStatusRequestDescriptor = $convert.base64Decode(
    'ChRHZXRGb3JrU3RhdHVzUmVxdWVzdA==');

@$core.Deprecated('Use getForkStatusResponseDescriptor instead')
const GetForkStatusResponse$json = {
  '1': 'GetForkStatusResponse',
  '2': [
    {'1': 'fork_height', '3': 1, '4': 1, '5': 5, '10': 'forkHeight'},
    {'1': 'current_height', '3': 2, '4': 1, '5': 5, '10': 'currentHeight'},
    {'1': 'current_headers', '3': 4, '4': 1, '5': 5, '10': 'currentHeaders'},
    {'1': 'claim_boundary', '3': 5, '4': 1, '5': 5, '10': 'claimBoundary'},
    {'1': 'simulated', '3': 6, '4': 1, '5': 8, '10': 'simulated'},
    {'1': 'has_funds_to_claim', '3': 7, '4': 1, '5': 8, '10': 'hasFundsToClaim'},
    {'1': 'show_countdown', '3': 8, '4': 1, '5': 8, '10': 'showCountdown'},
    {'1': 'claims', '3': 9, '4': 3, '5': 11, '6': '.orchestrator.v1.ForkWalletClaim', '10': 'claims'},
  ],
  '9': [
    {'1': 3, '2': 4},
  ],
};

/// Descriptor for `GetForkStatusResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getForkStatusResponseDescriptor = $convert.base64Decode(
    'ChVHZXRGb3JrU3RhdHVzUmVzcG9uc2USHwoLZm9ya19oZWlnaHQYASABKAVSCmZvcmtIZWlnaH'
    'QSJQoOY3VycmVudF9oZWlnaHQYAiABKAVSDWN1cnJlbnRIZWlnaHQSJwoPY3VycmVudF9oZWFk'
    'ZXJzGAQgASgFUg5jdXJyZW50SGVhZGVycxIlCg5jbGFpbV9ib3VuZGFyeRgFIAEoBVINY2xhaW'
    '1Cb3VuZGFyeRIcCglzaW11bGF0ZWQYBiABKAhSCXNpbXVsYXRlZBIrChJoYXNfZnVuZHNfdG9f'
    'Y2xhaW0YByABKAhSD2hhc0Z1bmRzVG9DbGFpbRIlCg5zaG93X2NvdW50ZG93bhgIIAEoCFINc2'
    'hvd0NvdW50ZG93bhI4CgZjbGFpbXMYCSADKAsyIC5vcmNoZXN0cmF0b3IudjEuRm9ya1dhbGxl'
    'dENsYWltUgZjbGFpbXNKBAgDEAQ=');

@$core.Deprecated('Use forkWalletClaimDescriptor instead')
const ForkWalletClaim$json = {
  '1': 'ForkWalletClaim',
  '2': [
    {'1': 'wallet_id', '3': 1, '4': 1, '5': 9, '10': 'walletId'},
    {'1': 'wallet_name', '3': 2, '4': 1, '5': 9, '10': 'walletName'},
    {'1': 'claimable_sats', '3': 3, '4': 1, '5': 4, '10': 'claimableSats'},
    {'1': 'utxos', '3': 4, '4': 3, '5': 11, '6': '.orchestrator.v1.ForkClaimUtxo', '10': 'utxos'},
    {'1': 'replay_protectable', '3': 5, '4': 1, '5': 8, '10': 'replayProtectable'},
  ],
};

/// Descriptor for `ForkWalletClaim`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List forkWalletClaimDescriptor = $convert.base64Decode(
    'Cg9Gb3JrV2FsbGV0Q2xhaW0SGwoJd2FsbGV0X2lkGAEgASgJUgh3YWxsZXRJZBIfCgt3YWxsZX'
    'RfbmFtZRgCIAEoCVIKd2FsbGV0TmFtZRIlCg5jbGFpbWFibGVfc2F0cxgDIAEoBFINY2xhaW1h'
    'YmxlU2F0cxI0CgV1dHhvcxgEIAMoCzIeLm9yY2hlc3RyYXRvci52MS5Gb3JrQ2xhaW1VdHhvUg'
    'V1dHhvcxItChJyZXBsYXlfcHJvdGVjdGFibGUYBSABKAhSEXJlcGxheVByb3RlY3RhYmxl');

@$core.Deprecated('Use forkClaimUtxoDescriptor instead')
const ForkClaimUtxo$json = {
  '1': 'ForkClaimUtxo',
  '2': [
    {'1': 'outpoint', '3': 1, '4': 1, '5': 9, '10': 'outpoint'},
    {'1': 'address', '3': 2, '4': 1, '5': 9, '10': 'address'},
    {'1': 'sats', '3': 3, '4': 1, '5': 4, '10': 'sats'},
    {'1': 'label', '3': 4, '4': 1, '5': 9, '10': 'label'},
  ],
};

/// Descriptor for `ForkClaimUtxo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List forkClaimUtxoDescriptor = $convert.base64Decode(
    'Cg1Gb3JrQ2xhaW1VdHhvEhoKCG91dHBvaW50GAEgASgJUghvdXRwb2ludBIYCgdhZGRyZXNzGA'
    'IgASgJUgdhZGRyZXNzEhIKBHNhdHMYAyABKARSBHNhdHMSFAoFbGFiZWwYBCABKAlSBWxhYmVs');

@$core.Deprecated('Use shutdownRequestDescriptor instead')
const ShutdownRequest$json = {
  '1': 'ShutdownRequest',
};

/// Descriptor for `ShutdownRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List shutdownRequestDescriptor = $convert.base64Decode(
    'Cg9TaHV0ZG93blJlcXVlc3Q=');

@$core.Deprecated('Use shutdownResponseDescriptor instead')
const ShutdownResponse$json = {
  '1': 'ShutdownResponse',
};

/// Descriptor for `ShutdownResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List shutdownResponseDescriptor = $convert.base64Decode(
    'ChBTaHV0ZG93blJlc3BvbnNl');

const $core.Map<$core.String, $core.dynamic> OrchestratorServiceBase$json = {
  '1': 'OrchestratorService',
  '2': [
    {'1': 'ListBinaries', '2': '.orchestrator.v1.ListBinariesRequest', '3': '.orchestrator.v1.ListBinariesResponse'},
    {'1': 'GetBinaryStatus', '2': '.orchestrator.v1.GetBinaryStatusRequest', '3': '.orchestrator.v1.GetBinaryStatusResponse'},
    {'1': 'GetBinaryVersion', '2': '.orchestrator.v1.GetBinaryVersionRequest', '3': '.orchestrator.v1.GetBinaryVersionResponse'},
    {'1': 'DownloadBinary', '2': '.orchestrator.v1.DownloadBinaryRequest', '3': '.orchestrator.v1.DownloadBinaryResponse'},
    {'1': 'StartBinary', '2': '.orchestrator.v1.StartBinaryRequest', '3': '.orchestrator.v1.StartBinaryResponse'},
    {'1': 'StopBinary', '2': '.orchestrator.v1.StopBinaryRequest', '3': '.orchestrator.v1.StopBinaryResponse'},
    {'1': 'StreamLogs', '2': '.orchestrator.v1.StreamLogsRequest', '3': '.orchestrator.v1.StreamLogsResponse', '6': true},
    {'1': 'StartWithL1', '2': '.orchestrator.v1.StartWithL1Request', '3': '.orchestrator.v1.StartWithL1Response'},
    {'1': 'RestartDaemon', '2': '.orchestrator.v1.RestartDaemonRequest', '3': '.orchestrator.v1.RestartDaemonResponse'},
    {'1': 'RestartL1', '2': '.orchestrator.v1.RestartL1Request', '3': '.orchestrator.v1.RestartL1Response'},
    {'1': 'ApplyUTXOSnapshot', '2': '.orchestrator.v1.ApplyUTXOSnapshotRequest', '3': '.orchestrator.v1.ApplyUTXOSnapshotResponse', '6': true},
    {'1': 'GetSnapshotStatus', '2': '.orchestrator.v1.GetSnapshotStatusRequest', '3': '.orchestrator.v1.GetSnapshotStatusResponse'},
    {'1': 'ShutdownAll', '2': '.orchestrator.v1.ShutdownAllRequest', '3': '.orchestrator.v1.ShutdownAllResponse', '6': true},
    {'1': 'Shutdown', '2': '.orchestrator.v1.ShutdownRequest', '3': '.orchestrator.v1.ShutdownResponse'},
    {'1': 'GetBTCPrice', '2': '.orchestrator.v1.GetBTCPriceRequest', '3': '.orchestrator.v1.GetBTCPriceResponse'},
    {'1': 'GetMainchainBlockchainInfo', '2': '.orchestrator.v1.GetMainchainBlockchainInfoRequest', '3': '.orchestrator.v1.GetMainchainBlockchainInfoResponse'},
    {'1': 'GetEnforcerBlockchainInfo', '2': '.orchestrator.v1.GetEnforcerBlockchainInfoRequest', '3': '.orchestrator.v1.GetEnforcerBlockchainInfoResponse'},
    {'1': 'GetSyncStatus', '2': '.orchestrator.v1.GetSyncStatusRequest', '3': '.orchestrator.v1.GetSyncStatusResponse'},
    {'1': 'GetDownloadStatus', '2': '.orchestrator.v1.GetDownloadStatusRequest', '3': '.orchestrator.v1.GetDownloadStatusResponse'},
    {'1': 'GetMainchainBalance', '2': '.orchestrator.v1.GetMainchainBalanceRequest', '3': '.orchestrator.v1.GetMainchainBalanceResponse'},
    {'1': 'GetSidechainBalance', '2': '.orchestrator.v1.GetSidechainBalanceRequest', '3': '.orchestrator.v1.GetSidechainBalanceResponse'},
    {'1': 'GatherFilesToDelete', '2': '.orchestrator.v1.GatherFilesToDeleteRequest', '3': '.orchestrator.v1.GatherFilesToDeleteResponse'},
    {'1': 'DeleteFiles', '2': '.orchestrator.v1.DeleteFilesRequest', '3': '.orchestrator.v1.DeleteFilesResponse', '6': true},
    {'1': 'GetCoreMempoolInfo', '2': '.orchestrator.v1.GetCoreMempoolInfoRequest', '3': '.orchestrator.v1.GetCoreMempoolInfoResponse'},
    {'1': 'CoreRawCall', '2': '.orchestrator.v1.CoreRawCallRequest', '3': '.orchestrator.v1.CoreRawCallResponse'},
    {'1': 'GetForkStatus', '2': '.orchestrator.v1.GetForkStatusRequest', '3': '.orchestrator.v1.GetForkStatusResponse'},
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
  '.orchestrator.v1.GetBinaryVersionRequest': GetBinaryVersionRequest$json,
  '.orchestrator.v1.GetBinaryVersionResponse': GetBinaryVersionResponse$json,
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
  '.orchestrator.v1.RestartDaemonRequest': RestartDaemonRequest$json,
  '.orchestrator.v1.RestartDaemonResponse': RestartDaemonResponse$json,
  '.orchestrator.v1.RestartL1Request': RestartL1Request$json,
  '.orchestrator.v1.RestartL1Response': RestartL1Response$json,
  '.orchestrator.v1.ApplyUTXOSnapshotRequest': ApplyUTXOSnapshotRequest$json,
  '.orchestrator.v1.ApplyUTXOSnapshotResponse': ApplyUTXOSnapshotResponse$json,
  '.orchestrator.v1.GetSnapshotStatusRequest': GetSnapshotStatusRequest$json,
  '.orchestrator.v1.GetSnapshotStatusResponse': GetSnapshotStatusResponse$json,
  '.orchestrator.v1.ShutdownAllRequest': ShutdownAllRequest$json,
  '.orchestrator.v1.ShutdownAllResponse': ShutdownAllResponse$json,
  '.orchestrator.v1.ShutdownRequest': ShutdownRequest$json,
  '.orchestrator.v1.ShutdownResponse': ShutdownResponse$json,
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
  '.orchestrator.v1.GetDownloadStatusRequest': GetDownloadStatusRequest$json,
  '.orchestrator.v1.GetDownloadStatusResponse': GetDownloadStatusResponse$json,
  '.orchestrator.v1.DownloadStatus': DownloadStatus$json,
  '.orchestrator.v1.GetMainchainBalanceRequest': GetMainchainBalanceRequest$json,
  '.orchestrator.v1.GetMainchainBalanceResponse': GetMainchainBalanceResponse$json,
  '.orchestrator.v1.GetSidechainBalanceRequest': GetSidechainBalanceRequest$json,
  '.orchestrator.v1.GetSidechainBalanceResponse': GetSidechainBalanceResponse$json,
  '.orchestrator.v1.GatherFilesToDeleteRequest': GatherFilesToDeleteRequest$json,
  '.orchestrator.v1.SingleDeletion': SingleDeletion$json,
  '.orchestrator.v1.GatherFilesToDeleteResponse': GatherFilesToDeleteResponse$json,
  '.orchestrator.v1.ResetFileInfo': ResetFileInfo$json,
  '.orchestrator.v1.DeleteFilesRequest': DeleteFilesRequest$json,
  '.orchestrator.v1.DeleteFilesResponse': DeleteFilesResponse$json,
  '.orchestrator.v1.GetCoreMempoolInfoRequest': GetCoreMempoolInfoRequest$json,
  '.orchestrator.v1.GetCoreMempoolInfoResponse': GetCoreMempoolInfoResponse$json,
  '.orchestrator.v1.CoreRawCallRequest': CoreRawCallRequest$json,
  '.orchestrator.v1.CoreRawCallResponse': CoreRawCallResponse$json,
  '.orchestrator.v1.GetForkStatusRequest': GetForkStatusRequest$json,
  '.orchestrator.v1.GetForkStatusResponse': GetForkStatusResponse$json,
  '.orchestrator.v1.ForkWalletClaim': ForkWalletClaim$json,
  '.orchestrator.v1.ForkClaimUtxo': ForkClaimUtxo$json,
};

/// Descriptor for `OrchestratorService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List orchestratorServiceDescriptor = $convert.base64Decode(
    'ChNPcmNoZXN0cmF0b3JTZXJ2aWNlElsKDExpc3RCaW5hcmllcxIkLm9yY2hlc3RyYXRvci52MS'
    '5MaXN0QmluYXJpZXNSZXF1ZXN0GiUub3JjaGVzdHJhdG9yLnYxLkxpc3RCaW5hcmllc1Jlc3Bv'
    'bnNlEmQKD0dldEJpbmFyeVN0YXR1cxInLm9yY2hlc3RyYXRvci52MS5HZXRCaW5hcnlTdGF0dX'
    'NSZXF1ZXN0Gigub3JjaGVzdHJhdG9yLnYxLkdldEJpbmFyeVN0YXR1c1Jlc3BvbnNlEmcKEEdl'
    'dEJpbmFyeVZlcnNpb24SKC5vcmNoZXN0cmF0b3IudjEuR2V0QmluYXJ5VmVyc2lvblJlcXVlc3'
    'QaKS5vcmNoZXN0cmF0b3IudjEuR2V0QmluYXJ5VmVyc2lvblJlc3BvbnNlEmEKDkRvd25sb2Fk'
    'QmluYXJ5EiYub3JjaGVzdHJhdG9yLnYxLkRvd25sb2FkQmluYXJ5UmVxdWVzdBonLm9yY2hlc3'
    'RyYXRvci52MS5Eb3dubG9hZEJpbmFyeVJlc3BvbnNlElgKC1N0YXJ0QmluYXJ5EiMub3JjaGVz'
    'dHJhdG9yLnYxLlN0YXJ0QmluYXJ5UmVxdWVzdBokLm9yY2hlc3RyYXRvci52MS5TdGFydEJpbm'
    'FyeVJlc3BvbnNlElUKClN0b3BCaW5hcnkSIi5vcmNoZXN0cmF0b3IudjEuU3RvcEJpbmFyeVJl'
    'cXVlc3QaIy5vcmNoZXN0cmF0b3IudjEuU3RvcEJpbmFyeVJlc3BvbnNlElcKClN0cmVhbUxvZ3'
    'MSIi5vcmNoZXN0cmF0b3IudjEuU3RyZWFtTG9nc1JlcXVlc3QaIy5vcmNoZXN0cmF0b3IudjEu'
    'U3RyZWFtTG9nc1Jlc3BvbnNlMAESWAoLU3RhcnRXaXRoTDESIy5vcmNoZXN0cmF0b3IudjEuU3'
    'RhcnRXaXRoTDFSZXF1ZXN0GiQub3JjaGVzdHJhdG9yLnYxLlN0YXJ0V2l0aEwxUmVzcG9uc2US'
    'XgoNUmVzdGFydERhZW1vbhIlLm9yY2hlc3RyYXRvci52MS5SZXN0YXJ0RGFlbW9uUmVxdWVzdB'
    'omLm9yY2hlc3RyYXRvci52MS5SZXN0YXJ0RGFlbW9uUmVzcG9uc2USUgoJUmVzdGFydEwxEiEu'
    'b3JjaGVzdHJhdG9yLnYxLlJlc3RhcnRMMVJlcXVlc3QaIi5vcmNoZXN0cmF0b3IudjEuUmVzdG'
    'FydEwxUmVzcG9uc2USbAoRQXBwbHlVVFhPU25hcHNob3QSKS5vcmNoZXN0cmF0b3IudjEuQXBw'
    'bHlVVFhPU25hcHNob3RSZXF1ZXN0Gioub3JjaGVzdHJhdG9yLnYxLkFwcGx5VVRYT1NuYXBzaG'
    '90UmVzcG9uc2UwARJqChFHZXRTbmFwc2hvdFN0YXR1cxIpLm9yY2hlc3RyYXRvci52MS5HZXRT'
    'bmFwc2hvdFN0YXR1c1JlcXVlc3QaKi5vcmNoZXN0cmF0b3IudjEuR2V0U25hcHNob3RTdGF0dX'
    'NSZXNwb25zZRJaCgtTaHV0ZG93bkFsbBIjLm9yY2hlc3RyYXRvci52MS5TaHV0ZG93bkFsbFJl'
    'cXVlc3QaJC5vcmNoZXN0cmF0b3IudjEuU2h1dGRvd25BbGxSZXNwb25zZTABEk8KCFNodXRkb3'
    'duEiAub3JjaGVzdHJhdG9yLnYxLlNodXRkb3duUmVxdWVzdBohLm9yY2hlc3RyYXRvci52MS5T'
    'aHV0ZG93blJlc3BvbnNlElgKC0dldEJUQ1ByaWNlEiMub3JjaGVzdHJhdG9yLnYxLkdldEJUQ1'
    'ByaWNlUmVxdWVzdBokLm9yY2hlc3RyYXRvci52MS5HZXRCVENQcmljZVJlc3BvbnNlEoUBChpH'
    'ZXRNYWluY2hhaW5CbG9ja2NoYWluSW5mbxIyLm9yY2hlc3RyYXRvci52MS5HZXRNYWluY2hhaW'
    '5CbG9ja2NoYWluSW5mb1JlcXVlc3QaMy5vcmNoZXN0cmF0b3IudjEuR2V0TWFpbmNoYWluQmxv'
    'Y2tjaGFpbkluZm9SZXNwb25zZRKCAQoZR2V0RW5mb3JjZXJCbG9ja2NoYWluSW5mbxIxLm9yY2'
    'hlc3RyYXRvci52MS5HZXRFbmZvcmNlckJsb2NrY2hhaW5JbmZvUmVxdWVzdBoyLm9yY2hlc3Ry'
    'YXRvci52MS5HZXRFbmZvcmNlckJsb2NrY2hhaW5JbmZvUmVzcG9uc2USXgoNR2V0U3luY1N0YX'
    'R1cxIlLm9yY2hlc3RyYXRvci52MS5HZXRTeW5jU3RhdHVzUmVxdWVzdBomLm9yY2hlc3RyYXRv'
    'ci52MS5HZXRTeW5jU3RhdHVzUmVzcG9uc2USagoRR2V0RG93bmxvYWRTdGF0dXMSKS5vcmNoZX'
    'N0cmF0b3IudjEuR2V0RG93bmxvYWRTdGF0dXNSZXF1ZXN0Gioub3JjaGVzdHJhdG9yLnYxLkdl'
    'dERvd25sb2FkU3RhdHVzUmVzcG9uc2UScAoTR2V0TWFpbmNoYWluQmFsYW5jZRIrLm9yY2hlc3'
    'RyYXRvci52MS5HZXRNYWluY2hhaW5CYWxhbmNlUmVxdWVzdBosLm9yY2hlc3RyYXRvci52MS5H'
    'ZXRNYWluY2hhaW5CYWxhbmNlUmVzcG9uc2UScAoTR2V0U2lkZWNoYWluQmFsYW5jZRIrLm9yY2'
    'hlc3RyYXRvci52MS5HZXRTaWRlY2hhaW5CYWxhbmNlUmVxdWVzdBosLm9yY2hlc3RyYXRvci52'
    'MS5HZXRTaWRlY2hhaW5CYWxhbmNlUmVzcG9uc2UScAoTR2F0aGVyRmlsZXNUb0RlbGV0ZRIrLm'
    '9yY2hlc3RyYXRvci52MS5HYXRoZXJGaWxlc1RvRGVsZXRlUmVxdWVzdBosLm9yY2hlc3RyYXRv'
    'ci52MS5HYXRoZXJGaWxlc1RvRGVsZXRlUmVzcG9uc2USWgoLRGVsZXRlRmlsZXMSIy5vcmNoZX'
    'N0cmF0b3IudjEuRGVsZXRlRmlsZXNSZXF1ZXN0GiQub3JjaGVzdHJhdG9yLnYxLkRlbGV0ZUZp'
    'bGVzUmVzcG9uc2UwARJtChJHZXRDb3JlTWVtcG9vbEluZm8SKi5vcmNoZXN0cmF0b3IudjEuR2'
    'V0Q29yZU1lbXBvb2xJbmZvUmVxdWVzdBorLm9yY2hlc3RyYXRvci52MS5HZXRDb3JlTWVtcG9v'
    'bEluZm9SZXNwb25zZRJYCgtDb3JlUmF3Q2FsbBIjLm9yY2hlc3RyYXRvci52MS5Db3JlUmF3Q2'
    'FsbFJlcXVlc3QaJC5vcmNoZXN0cmF0b3IudjEuQ29yZVJhd0NhbGxSZXNwb25zZRJeCg1HZXRG'
    'b3JrU3RhdHVzEiUub3JjaGVzdHJhdG9yLnYxLkdldEZvcmtTdGF0dXNSZXF1ZXN0GiYub3JjaG'
    'VzdHJhdG9yLnYxLkdldEZvcmtTdGF0dXNSZXNwb25zZQ==');

