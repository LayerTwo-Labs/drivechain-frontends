//
//  Generated code. Do not modify.
//  source: orchestrator/v1/zside_conf.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use getZSideConfigRequestDescriptor instead')
const GetZSideConfigRequest$json = {
  '1': 'GetZSideConfigRequest',
};

/// Descriptor for `GetZSideConfigRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getZSideConfigRequestDescriptor = $convert.base64Decode(
    'ChVHZXRaU2lkZUNvbmZpZ1JlcXVlc3Q=');

@$core.Deprecated('Use getZSideConfigResponseDescriptor instead')
const GetZSideConfigResponse$json = {
  '1': 'GetZSideConfigResponse',
  '2': [
    {'1': 'config_content', '3': 1, '4': 1, '5': 9, '10': 'configContent'},
    {'1': 'config_path', '3': 2, '4': 1, '5': 9, '10': 'configPath'},
    {'1': 'default_config', '3': 3, '4': 1, '5': 9, '10': 'defaultConfig'},
    {'1': 'cli_args', '3': 4, '4': 3, '5': 9, '10': 'cliArgs'},
    {'1': 'network', '3': 5, '4': 1, '5': 9, '10': 'network'},
  ],
};

/// Descriptor for `GetZSideConfigResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getZSideConfigResponseDescriptor = $convert.base64Decode(
    'ChZHZXRaU2lkZUNvbmZpZ1Jlc3BvbnNlEiUKDmNvbmZpZ19jb250ZW50GAEgASgJUg1jb25maW'
    'dDb250ZW50Eh8KC2NvbmZpZ19wYXRoGAIgASgJUgpjb25maWdQYXRoEiUKDmRlZmF1bHRfY29u'
    'ZmlnGAMgASgJUg1kZWZhdWx0Q29uZmlnEhkKCGNsaV9hcmdzGAQgAygJUgdjbGlBcmdzEhgKB2'
    '5ldHdvcmsYBSABKAlSB25ldHdvcms=');

@$core.Deprecated('Use writeZSideConfigRequestDescriptor instead')
const WriteZSideConfigRequest$json = {
  '1': 'WriteZSideConfigRequest',
  '2': [
    {'1': 'config_content', '3': 1, '4': 1, '5': 9, '10': 'configContent'},
  ],
};

/// Descriptor for `WriteZSideConfigRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List writeZSideConfigRequestDescriptor = $convert.base64Decode(
    'ChdXcml0ZVpTaWRlQ29uZmlnUmVxdWVzdBIlCg5jb25maWdfY29udGVudBgBIAEoCVINY29uZm'
    'lnQ29udGVudA==');

@$core.Deprecated('Use writeZSideConfigResponseDescriptor instead')
const WriteZSideConfigResponse$json = {
  '1': 'WriteZSideConfigResponse',
};

/// Descriptor for `WriteZSideConfigResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List writeZSideConfigResponseDescriptor = $convert.base64Decode(
    'ChhXcml0ZVpTaWRlQ29uZmlnUmVzcG9uc2U=');

@$core.Deprecated('Use zSideSyncNetworkFromBitcoinConfRequestDescriptor instead')
const ZSideSyncNetworkFromBitcoinConfRequest$json = {
  '1': 'ZSideSyncNetworkFromBitcoinConfRequest',
};

/// Descriptor for `ZSideSyncNetworkFromBitcoinConfRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List zSideSyncNetworkFromBitcoinConfRequestDescriptor = $convert.base64Decode(
    'CiZaU2lkZVN5bmNOZXR3b3JrRnJvbUJpdGNvaW5Db25mUmVxdWVzdA==');

@$core.Deprecated('Use zSideSyncNetworkFromBitcoinConfResponseDescriptor instead')
const ZSideSyncNetworkFromBitcoinConfResponse$json = {
  '1': 'ZSideSyncNetworkFromBitcoinConfResponse',
};

/// Descriptor for `ZSideSyncNetworkFromBitcoinConfResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List zSideSyncNetworkFromBitcoinConfResponseDescriptor = $convert.base64Decode(
    'CidaU2lkZVN5bmNOZXR3b3JrRnJvbUJpdGNvaW5Db25mUmVzcG9uc2U=');

const $core.Map<$core.String, $core.dynamic> ZSideConfServiceBase$json = {
  '1': 'ZSideConfService',
  '2': [
    {'1': 'GetZSideConfig', '2': '.orchestrator.v1.GetZSideConfigRequest', '3': '.orchestrator.v1.GetZSideConfigResponse'},
    {'1': 'WriteZSideConfig', '2': '.orchestrator.v1.WriteZSideConfigRequest', '3': '.orchestrator.v1.WriteZSideConfigResponse'},
    {'1': 'SyncNetworkFromBitcoinConf', '2': '.orchestrator.v1.ZSideSyncNetworkFromBitcoinConfRequest', '3': '.orchestrator.v1.ZSideSyncNetworkFromBitcoinConfResponse'},
  ],
};

@$core.Deprecated('Use zSideConfServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> ZSideConfServiceBase$messageJson = {
  '.orchestrator.v1.GetZSideConfigRequest': GetZSideConfigRequest$json,
  '.orchestrator.v1.GetZSideConfigResponse': GetZSideConfigResponse$json,
  '.orchestrator.v1.WriteZSideConfigRequest': WriteZSideConfigRequest$json,
  '.orchestrator.v1.WriteZSideConfigResponse': WriteZSideConfigResponse$json,
  '.orchestrator.v1.ZSideSyncNetworkFromBitcoinConfRequest': ZSideSyncNetworkFromBitcoinConfRequest$json,
  '.orchestrator.v1.ZSideSyncNetworkFromBitcoinConfResponse': ZSideSyncNetworkFromBitcoinConfResponse$json,
};

/// Descriptor for `ZSideConfService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List zSideConfServiceDescriptor = $convert.base64Decode(
    'ChBaU2lkZUNvbmZTZXJ2aWNlEmEKDkdldFpTaWRlQ29uZmlnEiYub3JjaGVzdHJhdG9yLnYxLk'
    'dldFpTaWRlQ29uZmlnUmVxdWVzdBonLm9yY2hlc3RyYXRvci52MS5HZXRaU2lkZUNvbmZpZ1Jl'
    'c3BvbnNlEmcKEFdyaXRlWlNpZGVDb25maWcSKC5vcmNoZXN0cmF0b3IudjEuV3JpdGVaU2lkZU'
    'NvbmZpZ1JlcXVlc3QaKS5vcmNoZXN0cmF0b3IudjEuV3JpdGVaU2lkZUNvbmZpZ1Jlc3BvbnNl'
    'Eo8BChpTeW5jTmV0d29ya0Zyb21CaXRjb2luQ29uZhI3Lm9yY2hlc3RyYXRvci52MS5aU2lkZV'
    'N5bmNOZXR3b3JrRnJvbUJpdGNvaW5Db25mUmVxdWVzdBo4Lm9yY2hlc3RyYXRvci52MS5aU2lk'
    'ZVN5bmNOZXR3b3JrRnJvbUJpdGNvaW5Db25mUmVzcG9uc2U=');

