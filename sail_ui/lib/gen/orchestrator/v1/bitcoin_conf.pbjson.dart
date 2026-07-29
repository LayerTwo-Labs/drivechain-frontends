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

@$core.Deprecated('Use walletBackendDescriptor instead')
const WalletBackend$json = {
  '1': 'WalletBackend',
  '2': [
    {'1': 'WALLET_BACKEND_UNSPECIFIED', '2': 0},
    {'1': 'WALLET_BACKEND_ELECTRUM', '2': 1},
    {'1': 'WALLET_BACKEND_CORE', '2': 2},
    {'1': 'WALLET_BACKEND_ENFORCER', '2': 3},
  ],
};

/// Descriptor for `WalletBackend`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List walletBackendDescriptor = $convert.base64Decode(
    'Cg1XYWxsZXRCYWNrZW5kEh4KGldBTExFVF9CQUNLRU5EX1VOU1BFQ0lGSUVEEAASGwoXV0FMTE'
    'VUX0JBQ0tFTkRfRUxFQ1RSVU0QARIXChNXQUxMRVRfQkFDS0VORF9DT1JFEAISGwoXV0FMTEVU'
    'X0JBQ0tFTkRfRU5GT1JDRVIQAw==');

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
    {'1': 'default_datadir', '3': 11, '4': 1, '5': 9, '10': 'defaultDatadir'},
    {'1': 'forknet_datadir', '3': 12, '4': 1, '5': 9, '10': 'forknetDatadir'},
    {'1': 'drynet_datadir', '3': 13, '4': 1, '5': 9, '10': 'drynetDatadir'},
    {'1': 'drynet_generation', '3': 14, '4': 1, '5': 9, '10': 'drynetGeneration'},
    {'1': 'must_select_datadir', '3': 15, '4': 1, '5': 8, '10': 'mustSelectDatadir'},
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
    'NQYXNzd29yZBInCg9kZWZhdWx0X2RhdGFkaXIYCyABKAlSDmRlZmF1bHREYXRhZGlyEicKD2Zv'
    'cmtuZXRfZGF0YWRpchgMIAEoCVIOZm9ya25ldERhdGFkaXISJQoOZHJ5bmV0X2RhdGFkaXIYDS'
    'ABKAlSDWRyeW5ldERhdGFkaXISKwoRZHJ5bmV0X2dlbmVyYXRpb24YDiABKAlSEGRyeW5ldEdl'
    'bmVyYXRpb24SLgoTbXVzdF9zZWxlY3RfZGF0YWRpchgPIAEoCFIRbXVzdFNlbGVjdERhdGFkaX'
    'I=');

@$core.Deprecated('Use prepareNetworkChangeRequestDescriptor instead')
const PrepareNetworkChangeRequest$json = {
  '1': 'PrepareNetworkChangeRequest',
  '2': [
    {'1': 'network', '3': 1, '4': 1, '5': 9, '10': 'network'},
    {'1': 'wallet_backend', '3': 2, '4': 1, '5': 14, '6': '.orchestrator.v1.WalletBackend', '10': 'walletBackend'},
    {'1': 'wallet_id', '3': 3, '4': 1, '5': 9, '10': 'walletId'},
  ],
};

/// Descriptor for `PrepareNetworkChangeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List prepareNetworkChangeRequestDescriptor = $convert.base64Decode(
    'ChtQcmVwYXJlTmV0d29ya0NoYW5nZVJlcXVlc3QSGAoHbmV0d29yaxgBIAEoCVIHbmV0d29yax'
    'JFCg53YWxsZXRfYmFja2VuZBgCIAEoDjIeLm9yY2hlc3RyYXRvci52MS5XYWxsZXRCYWNrZW5k'
    'Ug13YWxsZXRCYWNrZW5kEhsKCXdhbGxldF9pZBgDIAEoCVIId2FsbGV0SWQ=');

@$core.Deprecated('Use networkChangePlanDescriptor instead')
const NetworkChangePlan$json = {
  '1': 'NetworkChangePlan',
  '2': [
    {'1': 'network', '3': 1, '4': 1, '5': 9, '10': 'network'},
    {'1': 'wallet_backend', '3': 2, '4': 1, '5': 14, '6': '.orchestrator.v1.WalletBackend', '10': 'walletBackend'},
    {'1': 'must_select_datadir', '3': 3, '4': 1, '5': 8, '10': 'mustSelectDatadir'},
    {'1': 'datadir', '3': 4, '4': 1, '5': 9, '10': 'datadir'},
    {'1': 'datadir_group', '3': 5, '4': 1, '5': 9, '10': 'datadirGroup'},
    {'1': 'needs_local_backends', '3': 6, '4': 1, '5': 8, '10': 'needsLocalBackends'},
    {'1': 'implies_chain_download', '3': 7, '4': 1, '5': 8, '10': 'impliesChainDownload'},
    {'1': 'missing_binaries', '3': 8, '4': 3, '5': 9, '10': 'missingBinaries'},
    {'1': 'needs_binary_download', '3': 9, '4': 1, '5': 8, '10': 'needsBinaryDownload'},
    {'1': 'no_op', '3': 10, '4': 1, '5': 8, '10': 'noOp'},
  ],
};

/// Descriptor for `NetworkChangePlan`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List networkChangePlanDescriptor = $convert.base64Decode(
    'ChFOZXR3b3JrQ2hhbmdlUGxhbhIYCgduZXR3b3JrGAEgASgJUgduZXR3b3JrEkUKDndhbGxldF'
    '9iYWNrZW5kGAIgASgOMh4ub3JjaGVzdHJhdG9yLnYxLldhbGxldEJhY2tlbmRSDXdhbGxldEJh'
    'Y2tlbmQSLgoTbXVzdF9zZWxlY3RfZGF0YWRpchgDIAEoCFIRbXVzdFNlbGVjdERhdGFkaXISGA'
    'oHZGF0YWRpchgEIAEoCVIHZGF0YWRpchIjCg1kYXRhZGlyX2dyb3VwGAUgASgJUgxkYXRhZGly'
    'R3JvdXASMAoUbmVlZHNfbG9jYWxfYmFja2VuZHMYBiABKAhSEm5lZWRzTG9jYWxCYWNrZW5kcx'
    'I0ChZpbXBsaWVzX2NoYWluX2Rvd25sb2FkGAcgASgIUhRpbXBsaWVzQ2hhaW5Eb3dubG9hZBIp'
    'ChBtaXNzaW5nX2JpbmFyaWVzGAggAygJUg9taXNzaW5nQmluYXJpZXMSMgoVbmVlZHNfYmluYX'
    'J5X2Rvd25sb2FkGAkgASgIUhNuZWVkc0JpbmFyeURvd25sb2FkEhMKBW5vX29wGAogASgIUgRu'
    'b09w');

@$core.Deprecated('Use setBitcoinConfigNetworkRequestDescriptor instead')
const SetBitcoinConfigNetworkRequest$json = {
  '1': 'SetBitcoinConfigNetworkRequest',
  '2': [
    {'1': 'network', '3': 1, '4': 1, '5': 9, '10': 'network'},
    {'1': 'data_dir', '3': 2, '4': 1, '5': 9, '10': 'dataDir'},
  ],
};

/// Descriptor for `SetBitcoinConfigNetworkRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setBitcoinConfigNetworkRequestDescriptor = $convert.base64Decode(
    'Ch5TZXRCaXRjb2luQ29uZmlnTmV0d29ya1JlcXVlc3QSGAoHbmV0d29yaxgBIAEoCVIHbmV0d2'
    '9yaxIZCghkYXRhX2RpchgCIAEoCVIHZGF0YURpcg==');

@$core.Deprecated('Use setBitcoinConfigNetworkResponseDescriptor instead')
const SetBitcoinConfigNetworkResponse$json = {
  '1': 'SetBitcoinConfigNetworkResponse',
  '2': [
    {'1': 'applied', '3': 1, '4': 1, '5': 11, '6': '.orchestrator.v1.NetworkChangePlan', '10': 'applied'},
  ],
};

/// Descriptor for `SetBitcoinConfigNetworkResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setBitcoinConfigNetworkResponseDescriptor = $convert.base64Decode(
    'Ch9TZXRCaXRjb2luQ29uZmlnTmV0d29ya1Jlc3BvbnNlEjwKB2FwcGxpZWQYASABKAsyIi5vcm'
    'NoZXN0cmF0b3IudjEuTmV0d29ya0NoYW5nZVBsYW5SB2FwcGxpZWQ=');

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
    {'1': 'PrepareNetworkChange', '2': '.orchestrator.v1.PrepareNetworkChangeRequest', '3': '.orchestrator.v1.NetworkChangePlan'},
    {'1': 'SetBitcoinConfigNetwork', '2': '.orchestrator.v1.SetBitcoinConfigNetworkRequest', '3': '.orchestrator.v1.SetBitcoinConfigNetworkResponse'},
    {'1': 'SetBitcoinConfigDataDir', '2': '.orchestrator.v1.SetBitcoinConfigDataDirRequest', '3': '.orchestrator.v1.SetBitcoinConfigDataDirResponse'},
    {'1': 'WriteBitcoinConfig', '2': '.orchestrator.v1.WriteBitcoinConfigRequest', '3': '.orchestrator.v1.WriteBitcoinConfigResponse'},
  ],
};

@$core.Deprecated('Use bitcoinConfServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> BitcoinConfServiceBase$messageJson = {
  '.orchestrator.v1.GetBitcoinConfigRequest': GetBitcoinConfigRequest$json,
  '.orchestrator.v1.GetBitcoinConfigResponse': GetBitcoinConfigResponse$json,
  '.orchestrator.v1.PrepareNetworkChangeRequest': PrepareNetworkChangeRequest$json,
  '.orchestrator.v1.NetworkChangePlan': NetworkChangePlan$json,
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
    'Q29uZmlnUmVzcG9uc2USaAoUUHJlcGFyZU5ldHdvcmtDaGFuZ2USLC5vcmNoZXN0cmF0b3Iudj'
    'EuUHJlcGFyZU5ldHdvcmtDaGFuZ2VSZXF1ZXN0GiIub3JjaGVzdHJhdG9yLnYxLk5ldHdvcmtD'
    'aGFuZ2VQbGFuEnwKF1NldEJpdGNvaW5Db25maWdOZXR3b3JrEi8ub3JjaGVzdHJhdG9yLnYxLl'
    'NldEJpdGNvaW5Db25maWdOZXR3b3JrUmVxdWVzdBowLm9yY2hlc3RyYXRvci52MS5TZXRCaXRj'
    'b2luQ29uZmlnTmV0d29ya1Jlc3BvbnNlEnwKF1NldEJpdGNvaW5Db25maWdEYXRhRGlyEi8ub3'
    'JjaGVzdHJhdG9yLnYxLlNldEJpdGNvaW5Db25maWdEYXRhRGlyUmVxdWVzdBowLm9yY2hlc3Ry'
    'YXRvci52MS5TZXRCaXRjb2luQ29uZmlnRGF0YURpclJlc3BvbnNlEm0KEldyaXRlQml0Y29pbk'
    'NvbmZpZxIqLm9yY2hlc3RyYXRvci52MS5Xcml0ZUJpdGNvaW5Db25maWdSZXF1ZXN0Gisub3Jj'
    'aGVzdHJhdG9yLnYxLldyaXRlQml0Y29pbkNvbmZpZ1Jlc3BvbnNl');

