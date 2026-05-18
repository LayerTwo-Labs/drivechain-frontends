//
//  Generated code. Do not modify.
//  source: orchestrator/v1/thunder_conf.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use getThunderConfigRequestDescriptor instead')
const GetThunderConfigRequest$json = {
  '1': 'GetThunderConfigRequest',
};

/// Descriptor for `GetThunderConfigRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getThunderConfigRequestDescriptor =
    $convert.base64Decode('ChdHZXRUaHVuZGVyQ29uZmlnUmVxdWVzdA==');

@$core.Deprecated('Use getThunderConfigResponseDescriptor instead')
const GetThunderConfigResponse$json = {
  '1': 'GetThunderConfigResponse',
  '2': [
    {'1': 'config_content', '3': 1, '4': 1, '5': 9, '10': 'configContent'},
    {'1': 'config_path', '3': 2, '4': 1, '5': 9, '10': 'configPath'},
    {'1': 'default_config', '3': 3, '4': 1, '5': 9, '10': 'defaultConfig'},
    {'1': 'cli_args', '3': 4, '4': 3, '5': 9, '10': 'cliArgs'},
    {'1': 'network', '3': 5, '4': 1, '5': 9, '10': 'network'},
  ],
};

/// Descriptor for `GetThunderConfigResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getThunderConfigResponseDescriptor =
    $convert.base64Decode('ChhHZXRUaHVuZGVyQ29uZmlnUmVzcG9uc2USJQoOY29uZmlnX2NvbnRlbnQYASABKAlSDWNvbm'
        'ZpZ0NvbnRlbnQSHwoLY29uZmlnX3BhdGgYAiABKAlSCmNvbmZpZ1BhdGgSJQoOZGVmYXVsdF9j'
        'b25maWcYAyABKAlSDWRlZmF1bHRDb25maWcSGQoIY2xpX2FyZ3MYBCADKAlSB2NsaUFyZ3MSGA'
        'oHbmV0d29yaxgFIAEoCVIHbmV0d29yaw==');

@$core.Deprecated('Use writeThunderConfigRequestDescriptor instead')
const WriteThunderConfigRequest$json = {
  '1': 'WriteThunderConfigRequest',
  '2': [
    {'1': 'config_content', '3': 1, '4': 1, '5': 9, '10': 'configContent'},
  ],
};

/// Descriptor for `WriteThunderConfigRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List writeThunderConfigRequestDescriptor =
    $convert.base64Decode('ChlXcml0ZVRodW5kZXJDb25maWdSZXF1ZXN0EiUKDmNvbmZpZ19jb250ZW50GAEgASgJUg1jb2'
        '5maWdDb250ZW50');

@$core.Deprecated('Use writeThunderConfigResponseDescriptor instead')
const WriteThunderConfigResponse$json = {
  '1': 'WriteThunderConfigResponse',
};

/// Descriptor for `WriteThunderConfigResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List writeThunderConfigResponseDescriptor =
    $convert.base64Decode('ChpXcml0ZVRodW5kZXJDb25maWdSZXNwb25zZQ==');

@$core.Deprecated('Use syncNetworkFromBitcoinConfRequestDescriptor instead')
const SyncNetworkFromBitcoinConfRequest$json = {
  '1': 'SyncNetworkFromBitcoinConfRequest',
};

/// Descriptor for `SyncNetworkFromBitcoinConfRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List syncNetworkFromBitcoinConfRequestDescriptor =
    $convert.base64Decode('CiFTeW5jTmV0d29ya0Zyb21CaXRjb2luQ29uZlJlcXVlc3Q=');

@$core.Deprecated('Use syncNetworkFromBitcoinConfResponseDescriptor instead')
const SyncNetworkFromBitcoinConfResponse$json = {
  '1': 'SyncNetworkFromBitcoinConfResponse',
};

/// Descriptor for `SyncNetworkFromBitcoinConfResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List syncNetworkFromBitcoinConfResponseDescriptor =
    $convert.base64Decode('CiJTeW5jTmV0d29ya0Zyb21CaXRjb2luQ29uZlJlc3BvbnNl');

const $core.Map<$core.String, $core.dynamic> ThunderConfServiceBase$json = {
  '1': 'ThunderConfService',
  '2': [
    {
      '1': 'GetThunderConfig',
      '2': '.orchestrator.v1.GetThunderConfigRequest',
      '3': '.orchestrator.v1.GetThunderConfigResponse'
    },
    {
      '1': 'WriteThunderConfig',
      '2': '.orchestrator.v1.WriteThunderConfigRequest',
      '3': '.orchestrator.v1.WriteThunderConfigResponse'
    },
    {
      '1': 'SyncNetworkFromBitcoinConf',
      '2': '.orchestrator.v1.SyncNetworkFromBitcoinConfRequest',
      '3': '.orchestrator.v1.SyncNetworkFromBitcoinConfResponse'
    },
  ],
};

@$core.Deprecated('Use thunderConfServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> ThunderConfServiceBase$messageJson = {
  '.orchestrator.v1.GetThunderConfigRequest': GetThunderConfigRequest$json,
  '.orchestrator.v1.GetThunderConfigResponse': GetThunderConfigResponse$json,
  '.orchestrator.v1.WriteThunderConfigRequest': WriteThunderConfigRequest$json,
  '.orchestrator.v1.WriteThunderConfigResponse': WriteThunderConfigResponse$json,
  '.orchestrator.v1.SyncNetworkFromBitcoinConfRequest': SyncNetworkFromBitcoinConfRequest$json,
  '.orchestrator.v1.SyncNetworkFromBitcoinConfResponse': SyncNetworkFromBitcoinConfResponse$json,
};

/// Descriptor for `ThunderConfService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List thunderConfServiceDescriptor =
    $convert.base64Decode('ChJUaHVuZGVyQ29uZlNlcnZpY2USZwoQR2V0VGh1bmRlckNvbmZpZxIoLm9yY2hlc3RyYXRvci'
        '52MS5HZXRUaHVuZGVyQ29uZmlnUmVxdWVzdBopLm9yY2hlc3RyYXRvci52MS5HZXRUaHVuZGVy'
        'Q29uZmlnUmVzcG9uc2USbQoSV3JpdGVUaHVuZGVyQ29uZmlnEioub3JjaGVzdHJhdG9yLnYxLl'
        'dyaXRlVGh1bmRlckNvbmZpZ1JlcXVlc3QaKy5vcmNoZXN0cmF0b3IudjEuV3JpdGVUaHVuZGVy'
        'Q29uZmlnUmVzcG9uc2UShQEKGlN5bmNOZXR3b3JrRnJvbUJpdGNvaW5Db25mEjIub3JjaGVzdH'
        'JhdG9yLnYxLlN5bmNOZXR3b3JrRnJvbUJpdGNvaW5Db25mUmVxdWVzdBozLm9yY2hlc3RyYXRv'
        'ci52MS5TeW5jTmV0d29ya0Zyb21CaXRjb2luQ29uZlJlc3BvbnNl');
