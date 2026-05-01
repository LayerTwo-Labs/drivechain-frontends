//
//  Generated code. Do not modify.
//  source: orchestrator/v1/bitcoin_conf.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use getBitcoinConfigRequestDescriptor instead')
const GetBitcoinConfigRequest$json = {
  '1': 'GetBitcoinConfigRequest',
};

/// Descriptor for `GetBitcoinConfigRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBitcoinConfigRequestDescriptor = $convert.base64Decode(
    'ChdHZXRCaXRjb2luQ29uZmlnUmVxdWVzdA==');

@$core.Deprecated('Use getBitcoinConfigResponseDescriptor instead')
const GetBitcoinConfigResponse$json = {
  '1': 'GetBitcoinConfigResponse',
  '2': [
    {'1': 'network', '3': 1, '4': 1, '5': 9, '10': 'network'},
    {'1': 'rpc_port', '3': 2, '4': 1, '5': 5, '10': 'rpcPort'},
    {'1': 'has_private_conf', '3': 3, '4': 1, '5': 8, '10': 'hasPrivateConf'},
    {'1': 'config_path', '3': 4, '4': 1, '5': 9, '10': 'configPath'},
    {'1': 'detected_data_dir', '3': 5, '4': 1, '5': 9, '10': 'detectedDataDir'},
    {'1': 'config_content', '3': 6, '4': 1, '5': 9, '10': 'configContent'},
    {'1': 'network_supports_sidechains', '3': 7, '4': 1, '5': 8, '10': 'networkSupportsSidechains'},
    {'1': 'is_demo_mode', '3': 8, '4': 1, '5': 8, '10': 'isDemoMode'},
    {'1': 'rpc_user', '3': 9, '4': 1, '5': 9, '10': 'rpcUser'},
    {'1': 'rpc_password', '3': 10, '4': 1, '5': 9, '10': 'rpcPassword'},
  ],
};

/// Descriptor for `GetBitcoinConfigResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBitcoinConfigResponseDescriptor = $convert.base64Decode(
    'ChhHZXRCaXRjb2luQ29uZmlnUmVzcG9uc2USGAoHbmV0d29yaxgBIAEoCVIHbmV0d29yaxIZCg'
    'hycGNfcG9ydBgCIAEoBVIHcnBjUG9ydBIoChBoYXNfcHJpdmF0ZV9jb25mGAMgASgIUg5oYXNQ'
    'cml2YXRlQ29uZhIfCgtjb25maWdfcGF0aBgEIAEoCVIKY29uZmlnUGF0aBIqChFkZXRlY3RlZF'
    '9kYXRhX2RpchgFIAEoCVIPZGV0ZWN0ZWREYXRhRGlyEiUKDmNvbmZpZ19jb250ZW50GAYgASgJ'
    'Ug1jb25maWdDb250ZW50Ej4KG25ldHdvcmtfc3VwcG9ydHNfc2lkZWNoYWlucxgHIAEoCFIZbm'
    'V0d29ya1N1cHBvcnRzU2lkZWNoYWlucxIgCgxpc19kZW1vX21vZGUYCCABKAhSCmlzRGVtb01v'
    'ZGUSGQoIcnBjX3VzZXIYCSABKAlSB3JwY1VzZXISIQoMcnBjX3Bhc3N3b3JkGAogASgJUgtycG'
    'NQYXNzd29yZA==');

@$core.Deprecated('Use setBitcoinConfigNetworkRequestDescriptor instead')
const SetBitcoinConfigNetworkRequest$json = {
  '1': 'SetBitcoinConfigNetworkRequest',
  '2': [
    {'1': 'network', '3': 1, '4': 1, '5': 9, '10': 'network'},
  ],
};

/// Descriptor for `SetBitcoinConfigNetworkRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setBitcoinConfigNetworkRequestDescriptor = $convert.base64Decode(
    'Ch5TZXRCaXRjb2luQ29uZmlnTmV0d29ya1JlcXVlc3QSGAoHbmV0d29yaxgBIAEoCVIHbmV0d2'
    '9yaw==');

@$core.Deprecated('Use setBitcoinConfigNetworkResponseDescriptor instead')
const SetBitcoinConfigNetworkResponse$json = {
  '1': 'SetBitcoinConfigNetworkResponse',
};

/// Descriptor for `SetBitcoinConfigNetworkResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setBitcoinConfigNetworkResponseDescriptor = $convert.base64Decode(
    'Ch9TZXRCaXRjb2luQ29uZmlnTmV0d29ya1Jlc3BvbnNl');

@$core.Deprecated('Use setBitcoinConfigDataDirRequestDescriptor instead')
const SetBitcoinConfigDataDirRequest$json = {
  '1': 'SetBitcoinConfigDataDirRequest',
  '2': [
    {'1': 'data_dir', '3': 1, '4': 1, '5': 9, '10': 'dataDir'},
    {'1': 'network', '3': 2, '4': 1, '5': 9, '10': 'network'},
  ],
};

/// Descriptor for `SetBitcoinConfigDataDirRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setBitcoinConfigDataDirRequestDescriptor = $convert.base64Decode(
    'Ch5TZXRCaXRjb2luQ29uZmlnRGF0YURpclJlcXVlc3QSGQoIZGF0YV9kaXIYASABKAlSB2RhdG'
    'FEaXISGAoHbmV0d29yaxgCIAEoCVIHbmV0d29yaw==');

@$core.Deprecated('Use setBitcoinConfigDataDirResponseDescriptor instead')
const SetBitcoinConfigDataDirResponse$json = {
  '1': 'SetBitcoinConfigDataDirResponse',
};

/// Descriptor for `SetBitcoinConfigDataDirResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setBitcoinConfigDataDirResponseDescriptor = $convert.base64Decode(
    'Ch9TZXRCaXRjb2luQ29uZmlnRGF0YURpclJlc3BvbnNl');

@$core.Deprecated('Use writeBitcoinConfigRequestDescriptor instead')
const WriteBitcoinConfigRequest$json = {
  '1': 'WriteBitcoinConfigRequest',
  '2': [
    {'1': 'config_content', '3': 1, '4': 1, '5': 9, '10': 'configContent'},
  ],
};

/// Descriptor for `WriteBitcoinConfigRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List writeBitcoinConfigRequestDescriptor = $convert.base64Decode(
    'ChlXcml0ZUJpdGNvaW5Db25maWdSZXF1ZXN0EiUKDmNvbmZpZ19jb250ZW50GAEgASgJUg1jb2'
    '5maWdDb250ZW50');

@$core.Deprecated('Use writeBitcoinConfigResponseDescriptor instead')
const WriteBitcoinConfigResponse$json = {
  '1': 'WriteBitcoinConfigResponse',
};

/// Descriptor for `WriteBitcoinConfigResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List writeBitcoinConfigResponseDescriptor = $convert.base64Decode(
    'ChpXcml0ZUJpdGNvaW5Db25maWdSZXNwb25zZQ==');

const $core.Map<$core.String, $core.dynamic> BitcoinConfServiceBase$json = {
  '1': 'BitcoinConfService',
  '2': [
    {'1': 'GetBitcoinConfig', '2': '.orchestrator.v1.GetBitcoinConfigRequest', '3': '.orchestrator.v1.GetBitcoinConfigResponse'},
    {'1': 'SetBitcoinConfigNetwork', '2': '.orchestrator.v1.SetBitcoinConfigNetworkRequest', '3': '.orchestrator.v1.SetBitcoinConfigNetworkResponse'},
    {'1': 'SetBitcoinConfigDataDir', '2': '.orchestrator.v1.SetBitcoinConfigDataDirRequest', '3': '.orchestrator.v1.SetBitcoinConfigDataDirResponse'},
    {'1': 'WriteBitcoinConfig', '2': '.orchestrator.v1.WriteBitcoinConfigRequest', '3': '.orchestrator.v1.WriteBitcoinConfigResponse'},
  ],
};

@$core.Deprecated('Use bitcoinConfServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> BitcoinConfServiceBase$messageJson = {
  '.orchestrator.v1.GetBitcoinConfigRequest': GetBitcoinConfigRequest$json,
  '.orchestrator.v1.GetBitcoinConfigResponse': GetBitcoinConfigResponse$json,
  '.orchestrator.v1.SetBitcoinConfigNetworkRequest': SetBitcoinConfigNetworkRequest$json,
  '.orchestrator.v1.SetBitcoinConfigNetworkResponse': SetBitcoinConfigNetworkResponse$json,
  '.orchestrator.v1.SetBitcoinConfigDataDirRequest': SetBitcoinConfigDataDirRequest$json,
  '.orchestrator.v1.SetBitcoinConfigDataDirResponse': SetBitcoinConfigDataDirResponse$json,
  '.orchestrator.v1.WriteBitcoinConfigRequest': WriteBitcoinConfigRequest$json,
  '.orchestrator.v1.WriteBitcoinConfigResponse': WriteBitcoinConfigResponse$json,
};

/// Descriptor for `BitcoinConfService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List bitcoinConfServiceDescriptor = $convert.base64Decode(
    'ChJCaXRjb2luQ29uZlNlcnZpY2USZwoQR2V0Qml0Y29pbkNvbmZpZxIoLm9yY2hlc3RyYXRvci'
    '52MS5HZXRCaXRjb2luQ29uZmlnUmVxdWVzdBopLm9yY2hlc3RyYXRvci52MS5HZXRCaXRjb2lu'
    'Q29uZmlnUmVzcG9uc2USfAoXU2V0Qml0Y29pbkNvbmZpZ05ldHdvcmsSLy5vcmNoZXN0cmF0b3'
    'IudjEuU2V0Qml0Y29pbkNvbmZpZ05ldHdvcmtSZXF1ZXN0GjAub3JjaGVzdHJhdG9yLnYxLlNl'
    'dEJpdGNvaW5Db25maWdOZXR3b3JrUmVzcG9uc2USfAoXU2V0Qml0Y29pbkNvbmZpZ0RhdGFEaX'
    'ISLy5vcmNoZXN0cmF0b3IudjEuU2V0Qml0Y29pbkNvbmZpZ0RhdGFEaXJSZXF1ZXN0GjAub3Jj'
    'aGVzdHJhdG9yLnYxLlNldEJpdGNvaW5Db25maWdEYXRhRGlyUmVzcG9uc2USbQoSV3JpdGVCaX'
    'Rjb2luQ29uZmlnEioub3JjaGVzdHJhdG9yLnYxLldyaXRlQml0Y29pbkNvbmZpZ1JlcXVlc3Qa'
    'Ky5vcmNoZXN0cmF0b3IudjEuV3JpdGVCaXRjb2luQ29uZmlnUmVzcG9uc2U=');

