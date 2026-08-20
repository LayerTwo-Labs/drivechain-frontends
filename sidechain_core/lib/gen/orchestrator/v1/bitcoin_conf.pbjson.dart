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
final $typed_data.Uint8List walletBackendDescriptor =
    $convert.base64Decode('Cg1XYWxsZXRCYWNrZW5kEh4KGldBTExFVF9CQUNLRU5EX1VOU1BFQ0lGSUVEEAASGwoXV0FMTE'
        'VUX0JBQ0tFTkRfRUxFQ1RSVU0QARIXChNXQUxMRVRfQkFDS0VORF9DT1JFEAISGwoXV0FMTEVU'
        'X0JBQ0tFTkRfRU5GT1JDRVIQAw==');

@$core.Deprecated('Use getBitcoinConfigRequestDescriptor instead')
const GetBitcoinConfigRequest$json = {
  '1': 'GetBitcoinConfigRequest',
};

/// Descriptor for `GetBitcoinConfigRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBitcoinConfigRequestDescriptor =
    $convert.base64Decode('ChdHZXRCaXRjb2luQ29uZmlnUmVxdWVzdA==');

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
    {'1': 'ecash_datadir', '3': 13, '4': 1, '5': 9, '10': 'ecashDatadir'},
    {'1': 'ecash_network_id', '3': 14, '4': 1, '5': 9, '10': 'ecashNetworkId'},
    {'1': 'must_select_datadir', '3': 15, '4': 1, '5': 8, '10': 'mustSelectDatadir'},
    {'1': 'ecash_esplora_url', '3': 16, '4': 1, '5': 9, '10': 'ecashEsploraUrl'},
    {'1': 'ecash_explorer_host', '3': 17, '4': 1, '5': 9, '10': 'ecashExplorerHost'},
  ],
};

/// Descriptor for `GetBitcoinConfigResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBitcoinConfigResponseDescriptor =
    $convert.base64Decode('ChhHZXRCaXRjb2luQ29uZmlnUmVzcG9uc2USGAoHbmV0d29yaxgBIAEoCVIHbmV0d29yaxIZCg'
        'hycGNfcG9ydBgCIAEoBVIHcnBjUG9ydBIoChBoYXNfcHJpdmF0ZV9jb25mGAMgASgIUg5oYXNQ'
        'cml2YXRlQ29uZhIfCgtjb25maWdfcGF0aBgEIAEoCVIKY29uZmlnUGF0aBIqChFkZXRlY3RlZF'
        '9kYXRhX2RpchgFIAEoCVIPZGV0ZWN0ZWREYXRhRGlyEiUKDmNvbmZpZ19jb250ZW50GAYgASgJ'
        'Ug1jb25maWdDb250ZW50Ej4KG25ldHdvcmtfc3VwcG9ydHNfc2lkZWNoYWlucxgHIAEoCFIZbm'
        'V0d29ya1N1cHBvcnRzU2lkZWNoYWlucxIgCgxpc19kZW1vX21vZGUYCCABKAhSCmlzRGVtb01v'
        'ZGUSGQoIcnBjX3VzZXIYCSABKAlSB3JwY1VzZXISIQoMcnBjX3Bhc3N3b3JkGAogASgJUgtycG'
        'NQYXNzd29yZBInCg9kZWZhdWx0X2RhdGFkaXIYCyABKAlSDmRlZmF1bHREYXRhZGlyEicKD2Zv'
        'cmtuZXRfZGF0YWRpchgMIAEoCVIOZm9ya25ldERhdGFkaXISIwoNZWNhc2hfZGF0YWRpchgNIA'
        'EoCVIMZWNhc2hEYXRhZGlyEigKEGVjYXNoX25ldHdvcmtfaWQYDiABKAlSDmVjYXNoTmV0d29y'
        'a0lkEi4KE211c3Rfc2VsZWN0X2RhdGFkaXIYDyABKAhSEW11c3RTZWxlY3REYXRhZGlyEioKEW'
        'VjYXNoX2VzcGxvcmFfdXJsGBAgASgJUg9lY2FzaEVzcGxvcmFVcmwSLgoTZWNhc2hfZXhwbG9y'
        'ZXJfaG9zdBgRIAEoCVIRZWNhc2hFeHBsb3Jlckhvc3Q=');

@$core.Deprecated('Use listNetworksRequestDescriptor instead')
const ListNetworksRequest$json = {
  '1': 'ListNetworksRequest',
};

/// Descriptor for `ListNetworksRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listNetworksRequestDescriptor = $convert.base64Decode('ChNMaXN0TmV0d29ya3NSZXF1ZXN0');

@$core.Deprecated('Use networkOptionDescriptor instead')
const NetworkOption$json = {
  '1': 'NetworkOption',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'display_name', '3': 2, '4': 1, '5': 9, '10': 'displayName'},
    {'1': 'network', '3': 3, '4': 1, '5': 9, '10': 'network'},
    {'1': 'is_current', '3': 4, '4': 1, '5': 8, '10': 'isCurrent'},
  ],
};

/// Descriptor for `NetworkOption`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List networkOptionDescriptor =
    $convert.base64Decode('Cg1OZXR3b3JrT3B0aW9uEg4KAmlkGAEgASgJUgJpZBIhCgxkaXNwbGF5X25hbWUYAiABKAlSC2'
        'Rpc3BsYXlOYW1lEhgKB25ldHdvcmsYAyABKAlSB25ldHdvcmsSHQoKaXNfY3VycmVudBgEIAEo'
        'CFIJaXNDdXJyZW50');

@$core.Deprecated('Use listNetworksResponseDescriptor instead')
const ListNetworksResponse$json = {
  '1': 'ListNetworksResponse',
  '2': [
    {'1': 'networks', '3': 1, '4': 3, '5': 11, '6': '.orchestrator.v1.NetworkOption', '10': 'networks'},
  ],
};

/// Descriptor for `ListNetworksResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listNetworksResponseDescriptor =
    $convert.base64Decode('ChRMaXN0TmV0d29ya3NSZXNwb25zZRI6CghuZXR3b3JrcxgBIAMoCzIeLm9yY2hlc3RyYXRvci'
        '52MS5OZXR3b3JrT3B0aW9uUghuZXR3b3Jrcw==');

@$core.Deprecated('Use planECashSwitchRequestDescriptor instead')
const PlanECashSwitchRequest$json = {
  '1': 'PlanECashSwitchRequest',
  '2': [
    {'1': 'network_id', '3': 1, '4': 1, '5': 9, '10': 'networkId'},
  ],
};

/// Descriptor for `PlanECashSwitchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List planECashSwitchRequestDescriptor =
    $convert.base64Decode('ChZQbGFuRUNhc2hTd2l0Y2hSZXF1ZXN0Eh0KCm5ldHdvcmtfaWQYASABKAlSCW5ldHdvcmtJZA'
        '==');

@$core.Deprecated('Use planECashSwitchResponseDescriptor instead')
const PlanECashSwitchResponse$json = {
  '1': 'PlanECashSwitchResponse',
  '2': [
    {'1': 'from_id', '3': 1, '4': 1, '5': 9, '10': 'fromId'},
    {'1': 'to_id', '3': 2, '4': 1, '5': 9, '10': 'toId'},
    {'1': 'rewind_height', '3': 3, '4': 1, '5': 13, '10': 'rewindHeight'},
    {'1': 'needs_rollback', '3': 4, '4': 1, '5': 8, '10': 'needsRollback'},
  ],
};

/// Descriptor for `PlanECashSwitchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List planECashSwitchResponseDescriptor =
    $convert.base64Decode('ChdQbGFuRUNhc2hTd2l0Y2hSZXNwb25zZRIXCgdmcm9tX2lkGAEgASgJUgZmcm9tSWQSEwoFdG'
        '9faWQYAiABKAlSBHRvSWQSIwoNcmV3aW5kX2hlaWdodBgDIAEoDVIMcmV3aW5kSGVpZ2h0EiUK'
        'Dm5lZWRzX3JvbGxiYWNrGAQgASgIUg1uZWVkc1JvbGxiYWNr');

@$core.Deprecated('Use takeNewNetworksRequestDescriptor instead')
const TakeNewNetworksRequest$json = {
  '1': 'TakeNewNetworksRequest',
};

/// Descriptor for `TakeNewNetworksRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List takeNewNetworksRequestDescriptor =
    $convert.base64Decode('ChZUYWtlTmV3TmV0d29ya3NSZXF1ZXN0');

@$core.Deprecated('Use takeNewNetworksResponseDescriptor instead')
const TakeNewNetworksResponse$json = {
  '1': 'TakeNewNetworksResponse',
  '2': [
    {'1': 'networks', '3': 1, '4': 3, '5': 11, '6': '.orchestrator.v1.NetworkOption', '10': 'networks'},
  ],
};

/// Descriptor for `TakeNewNetworksResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List takeNewNetworksResponseDescriptor =
    $convert.base64Decode('ChdUYWtlTmV3TmV0d29ya3NSZXNwb25zZRI6CghuZXR3b3JrcxgBIAMoCzIeLm9yY2hlc3RyYX'
        'Rvci52MS5OZXR3b3JrT3B0aW9uUghuZXR3b3Jrcw==');

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
final $typed_data.Uint8List prepareNetworkChangeRequestDescriptor =
    $convert.base64Decode('ChtQcmVwYXJlTmV0d29ya0NoYW5nZVJlcXVlc3QSGAoHbmV0d29yaxgBIAEoCVIHbmV0d29yax'
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
final $typed_data.Uint8List networkChangePlanDescriptor =
    $convert.base64Decode('ChFOZXR3b3JrQ2hhbmdlUGxhbhIYCgduZXR3b3JrGAEgASgJUgduZXR3b3JrEkUKDndhbGxldF'
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
final $typed_data.Uint8List setBitcoinConfigNetworkRequestDescriptor =
    $convert.base64Decode('Ch5TZXRCaXRjb2luQ29uZmlnTmV0d29ya1JlcXVlc3QSGAoHbmV0d29yaxgBIAEoCVIHbmV0d2'
        '9yaxIZCghkYXRhX2RpchgCIAEoCVIHZGF0YURpcg==');

@$core.Deprecated('Use setBitcoinConfigNetworkResponseDescriptor instead')
const SetBitcoinConfigNetworkResponse$json = {
  '1': 'SetBitcoinConfigNetworkResponse',
  '2': [
    {'1': 'applied', '3': 1, '4': 1, '5': 11, '6': '.orchestrator.v1.NetworkChangePlan', '10': 'applied'},
  ],
};

/// Descriptor for `SetBitcoinConfigNetworkResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setBitcoinConfigNetworkResponseDescriptor =
    $convert.base64Decode('Ch9TZXRCaXRjb2luQ29uZmlnTmV0d29ya1Jlc3BvbnNlEjwKB2FwcGxpZWQYASABKAsyIi5vcm'
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
final $typed_data.Uint8List setBitcoinConfigDataDirRequestDescriptor =
    $convert.base64Decode('Ch5TZXRCaXRjb2luQ29uZmlnRGF0YURpclJlcXVlc3QSGQoIZGF0YV9kaXIYASABKAlSB2RhdG'
        'FEaXISGAoHbmV0d29yaxgCIAEoCVIHbmV0d29yaw==');

@$core.Deprecated('Use setBitcoinConfigDataDirResponseDescriptor instead')
const SetBitcoinConfigDataDirResponse$json = {
  '1': 'SetBitcoinConfigDataDirResponse',
};

/// Descriptor for `SetBitcoinConfigDataDirResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setBitcoinConfigDataDirResponseDescriptor =
    $convert.base64Decode('Ch9TZXRCaXRjb2luQ29uZmlnRGF0YURpclJlc3BvbnNl');

@$core.Deprecated('Use writeBitcoinConfigRequestDescriptor instead')
const WriteBitcoinConfigRequest$json = {
  '1': 'WriteBitcoinConfigRequest',
  '2': [
    {'1': 'config_content', '3': 1, '4': 1, '5': 9, '10': 'configContent'},
  ],
};

/// Descriptor for `WriteBitcoinConfigRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List writeBitcoinConfigRequestDescriptor =
    $convert.base64Decode('ChlXcml0ZUJpdGNvaW5Db25maWdSZXF1ZXN0EiUKDmNvbmZpZ19jb250ZW50GAEgASgJUg1jb2'
        '5maWdDb250ZW50');

@$core.Deprecated('Use writeBitcoinConfigResponseDescriptor instead')
const WriteBitcoinConfigResponse$json = {
  '1': 'WriteBitcoinConfigResponse',
};

/// Descriptor for `WriteBitcoinConfigResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List writeBitcoinConfigResponseDescriptor =
    $convert.base64Decode('ChpXcml0ZUJpdGNvaW5Db25maWdSZXNwb25zZQ==');

const $core.Map<$core.String, $core.dynamic> BitcoinConfServiceBase$json = {
  '1': 'BitcoinConfService',
  '2': [
    {
      '1': 'GetBitcoinConfig',
      '2': '.orchestrator.v1.GetBitcoinConfigRequest',
      '3': '.orchestrator.v1.GetBitcoinConfigResponse'
    },
    {
      '1': 'PrepareNetworkChange',
      '2': '.orchestrator.v1.PrepareNetworkChangeRequest',
      '3': '.orchestrator.v1.NetworkChangePlan'
    },
    {'1': 'ListNetworks', '2': '.orchestrator.v1.ListNetworksRequest', '3': '.orchestrator.v1.ListNetworksResponse'},
    {
      '1': 'TakeNewNetworks',
      '2': '.orchestrator.v1.TakeNewNetworksRequest',
      '3': '.orchestrator.v1.TakeNewNetworksResponse'
    },
    {
      '1': 'PlanECashSwitch',
      '2': '.orchestrator.v1.PlanECashSwitchRequest',
      '3': '.orchestrator.v1.PlanECashSwitchResponse'
    },
    {
      '1': 'SetBitcoinConfigNetwork',
      '2': '.orchestrator.v1.SetBitcoinConfigNetworkRequest',
      '3': '.orchestrator.v1.SetBitcoinConfigNetworkResponse'
    },
    {
      '1': 'SetBitcoinConfigDataDir',
      '2': '.orchestrator.v1.SetBitcoinConfigDataDirRequest',
      '3': '.orchestrator.v1.SetBitcoinConfigDataDirResponse'
    },
    {
      '1': 'WriteBitcoinConfig',
      '2': '.orchestrator.v1.WriteBitcoinConfigRequest',
      '3': '.orchestrator.v1.WriteBitcoinConfigResponse'
    },
  ],
};

@$core.Deprecated('Use bitcoinConfServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> BitcoinConfServiceBase$messageJson = {
  '.orchestrator.v1.GetBitcoinConfigRequest': GetBitcoinConfigRequest$json,
  '.orchestrator.v1.GetBitcoinConfigResponse': GetBitcoinConfigResponse$json,
  '.orchestrator.v1.PrepareNetworkChangeRequest': PrepareNetworkChangeRequest$json,
  '.orchestrator.v1.NetworkChangePlan': NetworkChangePlan$json,
  '.orchestrator.v1.ListNetworksRequest': ListNetworksRequest$json,
  '.orchestrator.v1.ListNetworksResponse': ListNetworksResponse$json,
  '.orchestrator.v1.NetworkOption': NetworkOption$json,
  '.orchestrator.v1.TakeNewNetworksRequest': TakeNewNetworksRequest$json,
  '.orchestrator.v1.TakeNewNetworksResponse': TakeNewNetworksResponse$json,
  '.orchestrator.v1.PlanECashSwitchRequest': PlanECashSwitchRequest$json,
  '.orchestrator.v1.PlanECashSwitchResponse': PlanECashSwitchResponse$json,
  '.orchestrator.v1.SetBitcoinConfigNetworkRequest': SetBitcoinConfigNetworkRequest$json,
  '.orchestrator.v1.SetBitcoinConfigNetworkResponse': SetBitcoinConfigNetworkResponse$json,
  '.orchestrator.v1.SetBitcoinConfigDataDirRequest': SetBitcoinConfigDataDirRequest$json,
  '.orchestrator.v1.SetBitcoinConfigDataDirResponse': SetBitcoinConfigDataDirResponse$json,
  '.orchestrator.v1.WriteBitcoinConfigRequest': WriteBitcoinConfigRequest$json,
  '.orchestrator.v1.WriteBitcoinConfigResponse': WriteBitcoinConfigResponse$json,
};

/// Descriptor for `BitcoinConfService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List bitcoinConfServiceDescriptor =
    $convert.base64Decode('ChJCaXRjb2luQ29uZlNlcnZpY2USZwoQR2V0Qml0Y29pbkNvbmZpZxIoLm9yY2hlc3RyYXRvci'
        '52MS5HZXRCaXRjb2luQ29uZmlnUmVxdWVzdBopLm9yY2hlc3RyYXRvci52MS5HZXRCaXRjb2lu'
        'Q29uZmlnUmVzcG9uc2USaAoUUHJlcGFyZU5ldHdvcmtDaGFuZ2USLC5vcmNoZXN0cmF0b3Iudj'
        'EuUHJlcGFyZU5ldHdvcmtDaGFuZ2VSZXF1ZXN0GiIub3JjaGVzdHJhdG9yLnYxLk5ldHdvcmtD'
        'aGFuZ2VQbGFuElsKDExpc3ROZXR3b3JrcxIkLm9yY2hlc3RyYXRvci52MS5MaXN0TmV0d29ya3'
        'NSZXF1ZXN0GiUub3JjaGVzdHJhdG9yLnYxLkxpc3ROZXR3b3Jrc1Jlc3BvbnNlEmQKD1Rha2VO'
        'ZXdOZXR3b3JrcxInLm9yY2hlc3RyYXRvci52MS5UYWtlTmV3TmV0d29ya3NSZXF1ZXN0Gigub3'
        'JjaGVzdHJhdG9yLnYxLlRha2VOZXdOZXR3b3Jrc1Jlc3BvbnNlEmQKD1BsYW5FQ2FzaFN3aXRj'
        'aBInLm9yY2hlc3RyYXRvci52MS5QbGFuRUNhc2hTd2l0Y2hSZXF1ZXN0Gigub3JjaGVzdHJhdG'
        '9yLnYxLlBsYW5FQ2FzaFN3aXRjaFJlc3BvbnNlEnwKF1NldEJpdGNvaW5Db25maWdOZXR3b3Jr'
        'Ei8ub3JjaGVzdHJhdG9yLnYxLlNldEJpdGNvaW5Db25maWdOZXR3b3JrUmVxdWVzdBowLm9yY2'
        'hlc3RyYXRvci52MS5TZXRCaXRjb2luQ29uZmlnTmV0d29ya1Jlc3BvbnNlEnwKF1NldEJpdGNv'
        'aW5Db25maWdEYXRhRGlyEi8ub3JjaGVzdHJhdG9yLnYxLlNldEJpdGNvaW5Db25maWdEYXRhRG'
        'lyUmVxdWVzdBowLm9yY2hlc3RyYXRvci52MS5TZXRCaXRjb2luQ29uZmlnRGF0YURpclJlc3Bv'
        'bnNlEm0KEldyaXRlQml0Y29pbkNvbmZpZxIqLm9yY2hlc3RyYXRvci52MS5Xcml0ZUJpdGNvaW'
        '5Db25maWdSZXF1ZXN0Gisub3JjaGVzdHJhdG9yLnYxLldyaXRlQml0Y29pbkNvbmZpZ1Jlc3Bv'
        'bnNl');
