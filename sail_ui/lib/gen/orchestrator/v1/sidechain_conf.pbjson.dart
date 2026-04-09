//
//  Generated code. Do not modify.
//  source: orchestrator/v1/sidechain_conf.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use getSidechainConfigRequestDescriptor instead')
const GetSidechainConfigRequest$json = {
  '1': 'GetSidechainConfigRequest',
  '2': [
    {'1': 'sidechain_name', '3': 1, '4': 1, '5': 9, '10': 'sidechainName'},
  ],
};

/// Descriptor for `GetSidechainConfigRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSidechainConfigRequestDescriptor = $convert.base64Decode(
    'ChlHZXRTaWRlY2hhaW5Db25maWdSZXF1ZXN0EiUKDnNpZGVjaGFpbl9uYW1lGAEgASgJUg1zaW'
    'RlY2hhaW5OYW1l');

@$core.Deprecated('Use getSidechainConfigResponseDescriptor instead')
const GetSidechainConfigResponse$json = {
  '1': 'GetSidechainConfigResponse',
  '2': [
    {'1': 'config_content', '3': 1, '4': 1, '5': 9, '10': 'configContent'},
    {'1': 'config_path', '3': 2, '4': 1, '5': 9, '10': 'configPath'},
    {'1': 'default_config', '3': 3, '4': 1, '5': 9, '10': 'defaultConfig'},
    {'1': 'cli_args', '3': 4, '4': 3, '5': 9, '10': 'cliArgs'},
    {'1': 'network', '3': 5, '4': 1, '5': 9, '10': 'network'},
  ],
};

/// Descriptor for `GetSidechainConfigResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSidechainConfigResponseDescriptor = $convert.base64Decode(
    'ChpHZXRTaWRlY2hhaW5Db25maWdSZXNwb25zZRIlCg5jb25maWdfY29udGVudBgBIAEoCVINY2'
    '9uZmlnQ29udGVudBIfCgtjb25maWdfcGF0aBgCIAEoCVIKY29uZmlnUGF0aBIlCg5kZWZhdWx0'
    'X2NvbmZpZxgDIAEoCVINZGVmYXVsdENvbmZpZxIZCghjbGlfYXJncxgEIAMoCVIHY2xpQXJncx'
    'IYCgduZXR3b3JrGAUgASgJUgduZXR3b3Jr');

@$core.Deprecated('Use writeSidechainConfigRequestDescriptor instead')
const WriteSidechainConfigRequest$json = {
  '1': 'WriteSidechainConfigRequest',
  '2': [
    {'1': 'sidechain_name', '3': 1, '4': 1, '5': 9, '10': 'sidechainName'},
    {'1': 'config_content', '3': 2, '4': 1, '5': 9, '10': 'configContent'},
  ],
};

/// Descriptor for `WriteSidechainConfigRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List writeSidechainConfigRequestDescriptor = $convert.base64Decode(
    'ChtXcml0ZVNpZGVjaGFpbkNvbmZpZ1JlcXVlc3QSJQoOc2lkZWNoYWluX25hbWUYASABKAlSDX'
    'NpZGVjaGFpbk5hbWUSJQoOY29uZmlnX2NvbnRlbnQYAiABKAlSDWNvbmZpZ0NvbnRlbnQ=');

@$core.Deprecated('Use writeSidechainConfigResponseDescriptor instead')
const WriteSidechainConfigResponse$json = {
  '1': 'WriteSidechainConfigResponse',
};

/// Descriptor for `WriteSidechainConfigResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List writeSidechainConfigResponseDescriptor = $convert.base64Decode(
    'ChxXcml0ZVNpZGVjaGFpbkNvbmZpZ1Jlc3BvbnNl');

@$core.Deprecated('Use syncSidechainNetworkFromBitcoinConfRequestDescriptor instead')
const SyncSidechainNetworkFromBitcoinConfRequest$json = {
  '1': 'SyncSidechainNetworkFromBitcoinConfRequest',
  '2': [
    {'1': 'sidechain_name', '3': 1, '4': 1, '5': 9, '10': 'sidechainName'},
  ],
};

/// Descriptor for `SyncSidechainNetworkFromBitcoinConfRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List syncSidechainNetworkFromBitcoinConfRequestDescriptor = $convert.base64Decode(
    'CipTeW5jU2lkZWNoYWluTmV0d29ya0Zyb21CaXRjb2luQ29uZlJlcXVlc3QSJQoOc2lkZWNoYW'
    'luX25hbWUYASABKAlSDXNpZGVjaGFpbk5hbWU=');

@$core.Deprecated('Use syncSidechainNetworkFromBitcoinConfResponseDescriptor instead')
const SyncSidechainNetworkFromBitcoinConfResponse$json = {
  '1': 'SyncSidechainNetworkFromBitcoinConfResponse',
};

/// Descriptor for `SyncSidechainNetworkFromBitcoinConfResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List syncSidechainNetworkFromBitcoinConfResponseDescriptor = $convert.base64Decode(
    'CitTeW5jU2lkZWNoYWluTmV0d29ya0Zyb21CaXRjb2luQ29uZlJlc3BvbnNl');

const $core.Map<$core.String, $core.dynamic> SidechainConfServiceBase$json = {
  '1': 'SidechainConfService',
  '2': [
    {'1': 'GetSidechainConfig', '2': '.orchestrator.v1.GetSidechainConfigRequest', '3': '.orchestrator.v1.GetSidechainConfigResponse'},
    {'1': 'WriteSidechainConfig', '2': '.orchestrator.v1.WriteSidechainConfigRequest', '3': '.orchestrator.v1.WriteSidechainConfigResponse'},
    {'1': 'SyncSidechainNetworkFromBitcoinConf', '2': '.orchestrator.v1.SyncSidechainNetworkFromBitcoinConfRequest', '3': '.orchestrator.v1.SyncSidechainNetworkFromBitcoinConfResponse'},
  ],
};

@$core.Deprecated('Use sidechainConfServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> SidechainConfServiceBase$messageJson = {
  '.orchestrator.v1.GetSidechainConfigRequest': GetSidechainConfigRequest$json,
  '.orchestrator.v1.GetSidechainConfigResponse': GetSidechainConfigResponse$json,
  '.orchestrator.v1.WriteSidechainConfigRequest': WriteSidechainConfigRequest$json,
  '.orchestrator.v1.WriteSidechainConfigResponse': WriteSidechainConfigResponse$json,
  '.orchestrator.v1.SyncSidechainNetworkFromBitcoinConfRequest': SyncSidechainNetworkFromBitcoinConfRequest$json,
  '.orchestrator.v1.SyncSidechainNetworkFromBitcoinConfResponse': SyncSidechainNetworkFromBitcoinConfResponse$json,
};

/// Descriptor for `SidechainConfService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List sidechainConfServiceDescriptor = $convert.base64Decode(
    'ChRTaWRlY2hhaW5Db25mU2VydmljZRJtChJHZXRTaWRlY2hhaW5Db25maWcSKi5vcmNoZXN0cm'
    'F0b3IudjEuR2V0U2lkZWNoYWluQ29uZmlnUmVxdWVzdBorLm9yY2hlc3RyYXRvci52MS5HZXRT'
    'aWRlY2hhaW5Db25maWdSZXNwb25zZRJzChRXcml0ZVNpZGVjaGFpbkNvbmZpZxIsLm9yY2hlc3'
    'RyYXRvci52MS5Xcml0ZVNpZGVjaGFpbkNvbmZpZ1JlcXVlc3QaLS5vcmNoZXN0cmF0b3IudjEu'
    'V3JpdGVTaWRlY2hhaW5Db25maWdSZXNwb25zZRKgAQojU3luY1NpZGVjaGFpbk5ldHdvcmtGcm'
    '9tQml0Y29pbkNvbmYSOy5vcmNoZXN0cmF0b3IudjEuU3luY1NpZGVjaGFpbk5ldHdvcmtGcm9t'
    'Qml0Y29pbkNvbmZSZXF1ZXN0Gjwub3JjaGVzdHJhdG9yLnYxLlN5bmNTaWRlY2hhaW5OZXR3b3'
    'JrRnJvbUJpdGNvaW5Db25mUmVzcG9uc2U=');

