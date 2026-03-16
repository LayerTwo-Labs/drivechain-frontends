//
//  Generated code. Do not modify.
//  source: orchestrator/v1/enforcer_conf.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use getEnforcerConfigRequestDescriptor instead')
const GetEnforcerConfigRequest$json = {
  '1': 'GetEnforcerConfigRequest',
};

/// Descriptor for `GetEnforcerConfigRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getEnforcerConfigRequestDescriptor = $convert.base64Decode(
    'ChhHZXRFbmZvcmNlckNvbmZpZ1JlcXVlc3Q=');

@$core.Deprecated('Use getEnforcerConfigResponseDescriptor instead')
const GetEnforcerConfigResponse$json = {
  '1': 'GetEnforcerConfigResponse',
  '2': [
    {'1': 'config_content', '3': 1, '4': 1, '5': 9, '10': 'configContent'},
    {'1': 'config_path', '3': 2, '4': 1, '5': 9, '10': 'configPath'},
    {'1': 'node_rpc_differs', '3': 3, '4': 1, '5': 8, '10': 'nodeRpcDiffers'},
    {'1': 'default_config', '3': 4, '4': 1, '5': 9, '10': 'defaultConfig'},
    {'1': 'cli_args', '3': 5, '4': 3, '5': 9, '10': 'cliArgs'},
    {'1': 'expected_node_rpc_settings', '3': 6, '4': 3, '5': 11, '6': '.orchestrator.v1.GetEnforcerConfigResponse.ExpectedNodeRpcSettingsEntry', '10': 'expectedNodeRpcSettings'},
  ],
  '3': [GetEnforcerConfigResponse_ExpectedNodeRpcSettingsEntry$json],
};

@$core.Deprecated('Use getEnforcerConfigResponseDescriptor instead')
const GetEnforcerConfigResponse_ExpectedNodeRpcSettingsEntry$json = {
  '1': 'ExpectedNodeRpcSettingsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `GetEnforcerConfigResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getEnforcerConfigResponseDescriptor = $convert.base64Decode(
    'ChlHZXRFbmZvcmNlckNvbmZpZ1Jlc3BvbnNlEiUKDmNvbmZpZ19jb250ZW50GAEgASgJUg1jb2'
    '5maWdDb250ZW50Eh8KC2NvbmZpZ19wYXRoGAIgASgJUgpjb25maWdQYXRoEigKEG5vZGVfcnBj'
    'X2RpZmZlcnMYAyABKAhSDm5vZGVScGNEaWZmZXJzEiUKDmRlZmF1bHRfY29uZmlnGAQgASgJUg'
    '1kZWZhdWx0Q29uZmlnEhkKCGNsaV9hcmdzGAUgAygJUgdjbGlBcmdzEoQBChpleHBlY3RlZF9u'
    'b2RlX3JwY19zZXR0aW5ncxgGIAMoCzJHLm9yY2hlc3RyYXRvci52MS5HZXRFbmZvcmNlckNvbm'
    'ZpZ1Jlc3BvbnNlLkV4cGVjdGVkTm9kZVJwY1NldHRpbmdzRW50cnlSF2V4cGVjdGVkTm9kZVJw'
    'Y1NldHRpbmdzGkoKHEV4cGVjdGVkTm9kZVJwY1NldHRpbmdzRW50cnkSEAoDa2V5GAEgASgJUg'
    'NrZXkSFAoFdmFsdWUYAiABKAlSBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use writeEnforcerConfigRequestDescriptor instead')
const WriteEnforcerConfigRequest$json = {
  '1': 'WriteEnforcerConfigRequest',
  '2': [
    {'1': 'config_content', '3': 1, '4': 1, '5': 9, '10': 'configContent'},
  ],
};

/// Descriptor for `WriteEnforcerConfigRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List writeEnforcerConfigRequestDescriptor = $convert.base64Decode(
    'ChpXcml0ZUVuZm9yY2VyQ29uZmlnUmVxdWVzdBIlCg5jb25maWdfY29udGVudBgBIAEoCVINY2'
    '9uZmlnQ29udGVudA==');

@$core.Deprecated('Use writeEnforcerConfigResponseDescriptor instead')
const WriteEnforcerConfigResponse$json = {
  '1': 'WriteEnforcerConfigResponse',
};

/// Descriptor for `WriteEnforcerConfigResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List writeEnforcerConfigResponseDescriptor = $convert.base64Decode(
    'ChtXcml0ZUVuZm9yY2VyQ29uZmlnUmVzcG9uc2U=');

@$core.Deprecated('Use syncNodeRpcFromBitcoinConfRequestDescriptor instead')
const SyncNodeRpcFromBitcoinConfRequest$json = {
  '1': 'SyncNodeRpcFromBitcoinConfRequest',
};

/// Descriptor for `SyncNodeRpcFromBitcoinConfRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List syncNodeRpcFromBitcoinConfRequestDescriptor = $convert.base64Decode(
    'CiFTeW5jTm9kZVJwY0Zyb21CaXRjb2luQ29uZlJlcXVlc3Q=');

@$core.Deprecated('Use syncNodeRpcFromBitcoinConfResponseDescriptor instead')
const SyncNodeRpcFromBitcoinConfResponse$json = {
  '1': 'SyncNodeRpcFromBitcoinConfResponse',
};

/// Descriptor for `SyncNodeRpcFromBitcoinConfResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List syncNodeRpcFromBitcoinConfResponseDescriptor = $convert.base64Decode(
    'CiJTeW5jTm9kZVJwY0Zyb21CaXRjb2luQ29uZlJlc3BvbnNl');

const $core.Map<$core.String, $core.dynamic> EnforcerConfServiceBase$json = {
  '1': 'EnforcerConfService',
  '2': [
    {'1': 'GetEnforcerConfig', '2': '.orchestrator.v1.GetEnforcerConfigRequest', '3': '.orchestrator.v1.GetEnforcerConfigResponse'},
    {'1': 'WriteEnforcerConfig', '2': '.orchestrator.v1.WriteEnforcerConfigRequest', '3': '.orchestrator.v1.WriteEnforcerConfigResponse'},
    {'1': 'SyncNodeRpcFromBitcoinConf', '2': '.orchestrator.v1.SyncNodeRpcFromBitcoinConfRequest', '3': '.orchestrator.v1.SyncNodeRpcFromBitcoinConfResponse'},
  ],
};

@$core.Deprecated('Use enforcerConfServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> EnforcerConfServiceBase$messageJson = {
  '.orchestrator.v1.GetEnforcerConfigRequest': GetEnforcerConfigRequest$json,
  '.orchestrator.v1.GetEnforcerConfigResponse': GetEnforcerConfigResponse$json,
  '.orchestrator.v1.GetEnforcerConfigResponse.ExpectedNodeRpcSettingsEntry': GetEnforcerConfigResponse_ExpectedNodeRpcSettingsEntry$json,
  '.orchestrator.v1.WriteEnforcerConfigRequest': WriteEnforcerConfigRequest$json,
  '.orchestrator.v1.WriteEnforcerConfigResponse': WriteEnforcerConfigResponse$json,
  '.orchestrator.v1.SyncNodeRpcFromBitcoinConfRequest': SyncNodeRpcFromBitcoinConfRequest$json,
  '.orchestrator.v1.SyncNodeRpcFromBitcoinConfResponse': SyncNodeRpcFromBitcoinConfResponse$json,
};

/// Descriptor for `EnforcerConfService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List enforcerConfServiceDescriptor = $convert.base64Decode(
    'ChNFbmZvcmNlckNvbmZTZXJ2aWNlEmoKEUdldEVuZm9yY2VyQ29uZmlnEikub3JjaGVzdHJhdG'
    '9yLnYxLkdldEVuZm9yY2VyQ29uZmlnUmVxdWVzdBoqLm9yY2hlc3RyYXRvci52MS5HZXRFbmZv'
    'cmNlckNvbmZpZ1Jlc3BvbnNlEnAKE1dyaXRlRW5mb3JjZXJDb25maWcSKy5vcmNoZXN0cmF0b3'
    'IudjEuV3JpdGVFbmZvcmNlckNvbmZpZ1JlcXVlc3QaLC5vcmNoZXN0cmF0b3IudjEuV3JpdGVF'
    'bmZvcmNlckNvbmZpZ1Jlc3BvbnNlEoUBChpTeW5jTm9kZVJwY0Zyb21CaXRjb2luQ29uZhIyLm'
    '9yY2hlc3RyYXRvci52MS5TeW5jTm9kZVJwY0Zyb21CaXRjb2luQ29uZlJlcXVlc3QaMy5vcmNo'
    'ZXN0cmF0b3IudjEuU3luY05vZGVScGNGcm9tQml0Y29pbkNvbmZSZXNwb25zZQ==');

