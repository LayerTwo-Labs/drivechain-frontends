//
//  Generated code. Do not modify.
//  source: walletmanager/v1/walletmanager.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

import '../../google/protobuf/empty.pbjson.dart' as $12;

@$core.Deprecated('Use getWalletStatusRequestDescriptor instead')
const GetWalletStatusRequest$json = {
  '1': 'GetWalletStatusRequest',
};

/// Descriptor for `GetWalletStatusRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getWalletStatusRequestDescriptor = $convert.base64Decode(
    'ChZHZXRXYWxsZXRTdGF0dXNSZXF1ZXN0');

@$core.Deprecated('Use getWalletStatusResponseDescriptor instead')
const GetWalletStatusResponse$json = {
  '1': 'GetWalletStatusResponse',
  '2': [
    {'1': 'has_wallet', '3': 1, '4': 1, '5': 8, '10': 'hasWallet'},
    {'1': 'encrypted', '3': 2, '4': 1, '5': 8, '10': 'encrypted'},
    {'1': 'unlocked', '3': 3, '4': 1, '5': 8, '10': 'unlocked'},
    {'1': 'active_wallet_id', '3': 4, '4': 1, '5': 9, '10': 'activeWalletId'},
    {'1': 'active_wallet_name', '3': 5, '4': 1, '5': 9, '10': 'activeWalletName'},
  ],
};

/// Descriptor for `GetWalletStatusResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getWalletStatusResponseDescriptor = $convert.base64Decode(
    'ChdHZXRXYWxsZXRTdGF0dXNSZXNwb25zZRIdCgpoYXNfd2FsbGV0GAEgASgIUgloYXNXYWxsZX'
    'QSHAoJZW5jcnlwdGVkGAIgASgIUgllbmNyeXB0ZWQSGgoIdW5sb2NrZWQYAyABKAhSCHVubG9j'
    'a2VkEigKEGFjdGl2ZV93YWxsZXRfaWQYBCABKAlSDmFjdGl2ZVdhbGxldElkEiwKEmFjdGl2ZV'
    '93YWxsZXRfbmFtZRgFIAEoCVIQYWN0aXZlV2FsbGV0TmFtZQ==');

@$core.Deprecated('Use generateWalletRequestDescriptor instead')
const GenerateWalletRequest$json = {
  '1': 'GenerateWalletRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'custom_mnemonic', '3': 2, '4': 1, '5': 9, '10': 'customMnemonic'},
    {'1': 'passphrase', '3': 3, '4': 1, '5': 9, '10': 'passphrase'},
  ],
};

/// Descriptor for `GenerateWalletRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List generateWalletRequestDescriptor = $convert.base64Decode(
    'ChVHZW5lcmF0ZVdhbGxldFJlcXVlc3QSEgoEbmFtZRgBIAEoCVIEbmFtZRInCg9jdXN0b21fbW'
    '5lbW9uaWMYAiABKAlSDmN1c3RvbU1uZW1vbmljEh4KCnBhc3NwaHJhc2UYAyABKAlSCnBhc3Nw'
    'aHJhc2U=');

@$core.Deprecated('Use generateWalletResponseDescriptor instead')
const GenerateWalletResponse$json = {
  '1': 'GenerateWalletResponse',
  '2': [
    {'1': 'wallet_id', '3': 1, '4': 1, '5': 9, '10': 'walletId'},
    {'1': 'mnemonic', '3': 2, '4': 1, '5': 9, '10': 'mnemonic'},
  ],
};

/// Descriptor for `GenerateWalletResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List generateWalletResponseDescriptor = $convert.base64Decode(
    'ChZHZW5lcmF0ZVdhbGxldFJlc3BvbnNlEhsKCXdhbGxldF9pZBgBIAEoCVIId2FsbGV0SWQSGg'
    'oIbW5lbW9uaWMYAiABKAlSCG1uZW1vbmlj');

@$core.Deprecated('Use unlockWalletRequestDescriptor instead')
const UnlockWalletRequest$json = {
  '1': 'UnlockWalletRequest',
  '2': [
    {'1': 'password', '3': 1, '4': 1, '5': 9, '10': 'password'},
  ],
};

/// Descriptor for `UnlockWalletRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unlockWalletRequestDescriptor = $convert.base64Decode(
    'ChNVbmxvY2tXYWxsZXRSZXF1ZXN0EhoKCHBhc3N3b3JkGAEgASgJUghwYXNzd29yZA==');

@$core.Deprecated('Use unlockWalletResponseDescriptor instead')
const UnlockWalletResponse$json = {
  '1': 'UnlockWalletResponse',
};

/// Descriptor for `UnlockWalletResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unlockWalletResponseDescriptor = $convert.base64Decode(
    'ChRVbmxvY2tXYWxsZXRSZXNwb25zZQ==');

@$core.Deprecated('Use lockWalletRequestDescriptor instead')
const LockWalletRequest$json = {
  '1': 'LockWalletRequest',
};

/// Descriptor for `LockWalletRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List lockWalletRequestDescriptor = $convert.base64Decode(
    'ChFMb2NrV2FsbGV0UmVxdWVzdA==');

@$core.Deprecated('Use lockWalletResponseDescriptor instead')
const LockWalletResponse$json = {
  '1': 'LockWalletResponse',
};

/// Descriptor for `LockWalletResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List lockWalletResponseDescriptor = $convert.base64Decode(
    'ChJMb2NrV2FsbGV0UmVzcG9uc2U=');

@$core.Deprecated('Use encryptWalletRequestDescriptor instead')
const EncryptWalletRequest$json = {
  '1': 'EncryptWalletRequest',
  '2': [
    {'1': 'password', '3': 1, '4': 1, '5': 9, '10': 'password'},
  ],
};

/// Descriptor for `EncryptWalletRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List encryptWalletRequestDescriptor = $convert.base64Decode(
    'ChRFbmNyeXB0V2FsbGV0UmVxdWVzdBIaCghwYXNzd29yZBgBIAEoCVIIcGFzc3dvcmQ=');

@$core.Deprecated('Use encryptWalletResponseDescriptor instead')
const EncryptWalletResponse$json = {
  '1': 'EncryptWalletResponse',
};

/// Descriptor for `EncryptWalletResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List encryptWalletResponseDescriptor = $convert.base64Decode(
    'ChVFbmNyeXB0V2FsbGV0UmVzcG9uc2U=');

@$core.Deprecated('Use changePasswordRequestDescriptor instead')
const ChangePasswordRequest$json = {
  '1': 'ChangePasswordRequest',
  '2': [
    {'1': 'old_password', '3': 1, '4': 1, '5': 9, '10': 'oldPassword'},
    {'1': 'new_password', '3': 2, '4': 1, '5': 9, '10': 'newPassword'},
  ],
};

/// Descriptor for `ChangePasswordRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List changePasswordRequestDescriptor = $convert.base64Decode(
    'ChVDaGFuZ2VQYXNzd29yZFJlcXVlc3QSIQoMb2xkX3Bhc3N3b3JkGAEgASgJUgtvbGRQYXNzd2'
    '9yZBIhCgxuZXdfcGFzc3dvcmQYAiABKAlSC25ld1Bhc3N3b3Jk');

@$core.Deprecated('Use changePasswordResponseDescriptor instead')
const ChangePasswordResponse$json = {
  '1': 'ChangePasswordResponse',
};

/// Descriptor for `ChangePasswordResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List changePasswordResponseDescriptor = $convert.base64Decode(
    'ChZDaGFuZ2VQYXNzd29yZFJlc3BvbnNl');

@$core.Deprecated('Use removeEncryptionRequestDescriptor instead')
const RemoveEncryptionRequest$json = {
  '1': 'RemoveEncryptionRequest',
  '2': [
    {'1': 'password', '3': 1, '4': 1, '5': 9, '10': 'password'},
  ],
};

/// Descriptor for `RemoveEncryptionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeEncryptionRequestDescriptor = $convert.base64Decode(
    'ChdSZW1vdmVFbmNyeXB0aW9uUmVxdWVzdBIaCghwYXNzd29yZBgBIAEoCVIIcGFzc3dvcmQ=');

@$core.Deprecated('Use removeEncryptionResponseDescriptor instead')
const RemoveEncryptionResponse$json = {
  '1': 'RemoveEncryptionResponse',
};

/// Descriptor for `RemoveEncryptionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeEncryptionResponseDescriptor = $convert.base64Decode(
    'ChhSZW1vdmVFbmNyeXB0aW9uUmVzcG9uc2U=');

@$core.Deprecated('Use walletMetadataDescriptor instead')
const WalletMetadata$json = {
  '1': 'WalletMetadata',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'wallet_type', '3': 3, '4': 1, '5': 9, '10': 'walletType'},
    {'1': 'gradient_json', '3': 4, '4': 1, '5': 9, '10': 'gradientJson'},
    {'1': 'created_at', '3': 5, '4': 1, '5': 9, '10': 'createdAt'},
    {'1': 'bip47_payment_code', '3': 6, '4': 1, '5': 9, '10': 'bip47PaymentCode'},
    {'1': 'master_mnemonic', '3': 7, '4': 1, '5': 9, '10': 'masterMnemonic'},
    {'1': 'l1_mnemonic', '3': 8, '4': 1, '5': 9, '10': 'l1Mnemonic'},
    {'1': 'sidechains', '3': 9, '4': 3, '5': 11, '6': '.walletmanager.v1.SidechainStarter', '10': 'sidechains'},
  ],
};

/// Descriptor for `WalletMetadata`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List walletMetadataDescriptor = $convert.base64Decode(
    'Cg5XYWxsZXRNZXRhZGF0YRIOCgJpZBgBIAEoCVICaWQSEgoEbmFtZRgCIAEoCVIEbmFtZRIfCg'
    't3YWxsZXRfdHlwZRgDIAEoCVIKd2FsbGV0VHlwZRIjCg1ncmFkaWVudF9qc29uGAQgASgJUgxn'
    'cmFkaWVudEpzb24SHQoKY3JlYXRlZF9hdBgFIAEoCVIJY3JlYXRlZEF0EiwKEmJpcDQ3X3BheW'
    '1lbnRfY29kZRgGIAEoCVIQYmlwNDdQYXltZW50Q29kZRInCg9tYXN0ZXJfbW5lbW9uaWMYByAB'
    'KAlSDm1hc3Rlck1uZW1vbmljEh8KC2wxX21uZW1vbmljGAggASgJUgpsMU1uZW1vbmljEkIKCn'
    'NpZGVjaGFpbnMYCSADKAsyIi53YWxsZXRtYW5hZ2VyLnYxLlNpZGVjaGFpblN0YXJ0ZXJSCnNp'
    'ZGVjaGFpbnM=');

@$core.Deprecated('Use sidechainStarterDescriptor instead')
const SidechainStarter$json = {
  '1': 'SidechainStarter',
  '2': [
    {'1': 'slot', '3': 1, '4': 1, '5': 5, '10': 'slot'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'mnemonic', '3': 3, '4': 1, '5': 9, '10': 'mnemonic'},
  ],
};

/// Descriptor for `SidechainStarter`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sidechainStarterDescriptor = $convert.base64Decode(
    'ChBTaWRlY2hhaW5TdGFydGVyEhIKBHNsb3QYASABKAVSBHNsb3QSEgoEbmFtZRgCIAEoCVIEbm'
    'FtZRIaCghtbmVtb25pYxgDIAEoCVIIbW5lbW9uaWM=');

@$core.Deprecated('Use listWalletsRequestDescriptor instead')
const ListWalletsRequest$json = {
  '1': 'ListWalletsRequest',
};

/// Descriptor for `ListWalletsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listWalletsRequestDescriptor = $convert.base64Decode(
    'ChJMaXN0V2FsbGV0c1JlcXVlc3Q=');

@$core.Deprecated('Use listWalletsResponseDescriptor instead')
const ListWalletsResponse$json = {
  '1': 'ListWalletsResponse',
  '2': [
    {'1': 'wallets', '3': 1, '4': 3, '5': 11, '6': '.walletmanager.v1.WalletMetadata', '10': 'wallets'},
    {'1': 'active_wallet_id', '3': 2, '4': 1, '5': 9, '10': 'activeWalletId'},
  ],
};

/// Descriptor for `ListWalletsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listWalletsResponseDescriptor = $convert.base64Decode(
    'ChNMaXN0V2FsbGV0c1Jlc3BvbnNlEjoKB3dhbGxldHMYASADKAsyIC53YWxsZXRtYW5hZ2VyLn'
    'YxLldhbGxldE1ldGFkYXRhUgd3YWxsZXRzEigKEGFjdGl2ZV93YWxsZXRfaWQYAiABKAlSDmFj'
    'dGl2ZVdhbGxldElk');

@$core.Deprecated('Use switchWalletRequestDescriptor instead')
const SwitchWalletRequest$json = {
  '1': 'SwitchWalletRequest',
  '2': [
    {'1': 'wallet_id', '3': 1, '4': 1, '5': 9, '10': 'walletId'},
  ],
};

/// Descriptor for `SwitchWalletRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List switchWalletRequestDescriptor = $convert.base64Decode(
    'ChNTd2l0Y2hXYWxsZXRSZXF1ZXN0EhsKCXdhbGxldF9pZBgBIAEoCVIId2FsbGV0SWQ=');

@$core.Deprecated('Use switchWalletResponseDescriptor instead')
const SwitchWalletResponse$json = {
  '1': 'SwitchWalletResponse',
};

/// Descriptor for `SwitchWalletResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List switchWalletResponseDescriptor = $convert.base64Decode(
    'ChRTd2l0Y2hXYWxsZXRSZXNwb25zZQ==');

@$core.Deprecated('Use updateWalletMetadataRequestDescriptor instead')
const UpdateWalletMetadataRequest$json = {
  '1': 'UpdateWalletMetadataRequest',
  '2': [
    {'1': 'wallet_id', '3': 1, '4': 1, '5': 9, '10': 'walletId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'gradient_json', '3': 3, '4': 1, '5': 9, '10': 'gradientJson'},
  ],
};

/// Descriptor for `UpdateWalletMetadataRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateWalletMetadataRequestDescriptor = $convert.base64Decode(
    'ChtVcGRhdGVXYWxsZXRNZXRhZGF0YVJlcXVlc3QSGwoJd2FsbGV0X2lkGAEgASgJUgh3YWxsZX'
    'RJZBISCgRuYW1lGAIgASgJUgRuYW1lEiMKDWdyYWRpZW50X2pzb24YAyABKAlSDGdyYWRpZW50'
    'SnNvbg==');

@$core.Deprecated('Use updateWalletMetadataResponseDescriptor instead')
const UpdateWalletMetadataResponse$json = {
  '1': 'UpdateWalletMetadataResponse',
};

/// Descriptor for `UpdateWalletMetadataResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateWalletMetadataResponseDescriptor = $convert.base64Decode(
    'ChxVcGRhdGVXYWxsZXRNZXRhZGF0YVJlc3BvbnNl');

@$core.Deprecated('Use deleteWalletRequestDescriptor instead')
const DeleteWalletRequest$json = {
  '1': 'DeleteWalletRequest',
  '2': [
    {'1': 'wallet_id', '3': 1, '4': 1, '5': 9, '10': 'walletId'},
  ],
};

/// Descriptor for `DeleteWalletRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteWalletRequestDescriptor = $convert.base64Decode(
    'ChNEZWxldGVXYWxsZXRSZXF1ZXN0EhsKCXdhbGxldF9pZBgBIAEoCVIId2FsbGV0SWQ=');

@$core.Deprecated('Use deleteWalletResponseDescriptor instead')
const DeleteWalletResponse$json = {
  '1': 'DeleteWalletResponse',
};

/// Descriptor for `DeleteWalletResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteWalletResponseDescriptor = $convert.base64Decode(
    'ChREZWxldGVXYWxsZXRSZXNwb25zZQ==');

@$core.Deprecated('Use deleteAllWalletsRequestDescriptor instead')
const DeleteAllWalletsRequest$json = {
  '1': 'DeleteAllWalletsRequest',
};

/// Descriptor for `DeleteAllWalletsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteAllWalletsRequestDescriptor = $convert.base64Decode(
    'ChdEZWxldGVBbGxXYWxsZXRzUmVxdWVzdA==');

@$core.Deprecated('Use deleteAllWalletsResponseDescriptor instead')
const DeleteAllWalletsResponse$json = {
  '1': 'DeleteAllWalletsResponse',
};

/// Descriptor for `DeleteAllWalletsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteAllWalletsResponseDescriptor = $convert.base64Decode(
    'ChhEZWxldGVBbGxXYWxsZXRzUmVzcG9uc2U=');

@$core.Deprecated('Use createWatchOnlyWalletRequestDescriptor instead')
const CreateWatchOnlyWalletRequest$json = {
  '1': 'CreateWatchOnlyWalletRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'xpub_or_descriptor', '3': 2, '4': 1, '5': 9, '10': 'xpubOrDescriptor'},
    {'1': 'gradient_json', '3': 3, '4': 1, '5': 9, '10': 'gradientJson'},
  ],
};

/// Descriptor for `CreateWatchOnlyWalletRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createWatchOnlyWalletRequestDescriptor = $convert.base64Decode(
    'ChxDcmVhdGVXYXRjaE9ubHlXYWxsZXRSZXF1ZXN0EhIKBG5hbWUYASABKAlSBG5hbWUSLAoSeH'
    'B1Yl9vcl9kZXNjcmlwdG9yGAIgASgJUhB4cHViT3JEZXNjcmlwdG9yEiMKDWdyYWRpZW50X2pz'
    'b24YAyABKAlSDGdyYWRpZW50SnNvbg==');

@$core.Deprecated('Use createWatchOnlyWalletResponseDescriptor instead')
const CreateWatchOnlyWalletResponse$json = {
  '1': 'CreateWatchOnlyWalletResponse',
  '2': [
    {'1': 'wallet_id', '3': 1, '4': 1, '5': 9, '10': 'walletId'},
  ],
};

/// Descriptor for `CreateWatchOnlyWalletResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createWatchOnlyWalletResponseDescriptor = $convert.base64Decode(
    'Ch1DcmVhdGVXYXRjaE9ubHlXYWxsZXRSZXNwb25zZRIbCgl3YWxsZXRfaWQYASABKAlSCHdhbG'
    'xldElk');

@$core.Deprecated('Use createBitcoinCoreWalletRequestDescriptor instead')
const CreateBitcoinCoreWalletRequest$json = {
  '1': 'CreateBitcoinCoreWalletRequest',
  '2': [
    {'1': 'wallet_id', '3': 1, '4': 1, '5': 9, '10': 'walletId'},
  ],
};

/// Descriptor for `CreateBitcoinCoreWalletRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createBitcoinCoreWalletRequestDescriptor = $convert.base64Decode(
    'Ch5DcmVhdGVCaXRjb2luQ29yZVdhbGxldFJlcXVlc3QSGwoJd2FsbGV0X2lkGAEgASgJUgh3YW'
    'xsZXRJZA==');

@$core.Deprecated('Use createBitcoinCoreWalletResponseDescriptor instead')
const CreateBitcoinCoreWalletResponse$json = {
  '1': 'CreateBitcoinCoreWalletResponse',
  '2': [
    {'1': 'core_wallet_name', '3': 1, '4': 1, '5': 9, '10': 'coreWalletName'},
  ],
};

/// Descriptor for `CreateBitcoinCoreWalletResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createBitcoinCoreWalletResponseDescriptor = $convert.base64Decode(
    'Ch9DcmVhdGVCaXRjb2luQ29yZVdhbGxldFJlc3BvbnNlEigKEGNvcmVfd2FsbGV0X25hbWUYAS'
    'ABKAlSDmNvcmVXYWxsZXROYW1l');

@$core.Deprecated('Use ensureCoreWalletsRequestDescriptor instead')
const EnsureCoreWalletsRequest$json = {
  '1': 'EnsureCoreWalletsRequest',
};

/// Descriptor for `EnsureCoreWalletsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ensureCoreWalletsRequestDescriptor = $convert.base64Decode(
    'ChhFbnN1cmVDb3JlV2FsbGV0c1JlcXVlc3Q=');

@$core.Deprecated('Use ensureCoreWalletsResponseDescriptor instead')
const EnsureCoreWalletsResponse$json = {
  '1': 'EnsureCoreWalletsResponse',
  '2': [
    {'1': 'synced_count', '3': 1, '4': 1, '5': 5, '10': 'syncedCount'},
  ],
};

/// Descriptor for `EnsureCoreWalletsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ensureCoreWalletsResponseDescriptor = $convert.base64Decode(
    'ChlFbnN1cmVDb3JlV2FsbGV0c1Jlc3BvbnNlEiEKDHN5bmNlZF9jb3VudBgBIAEoBVILc3luY2'
    'VkQ291bnQ=');

@$core.Deprecated('Use getBalanceRequestDescriptor instead')
const GetBalanceRequest$json = {
  '1': 'GetBalanceRequest',
  '2': [
    {'1': 'wallet_id', '3': 1, '4': 1, '5': 9, '10': 'walletId'},
  ],
};

/// Descriptor for `GetBalanceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBalanceRequestDescriptor = $convert.base64Decode(
    'ChFHZXRCYWxhbmNlUmVxdWVzdBIbCgl3YWxsZXRfaWQYASABKAlSCHdhbGxldElk');

@$core.Deprecated('Use getBalanceResponseDescriptor instead')
const GetBalanceResponse$json = {
  '1': 'GetBalanceResponse',
  '2': [
    {'1': 'confirmed_sats', '3': 1, '4': 1, '5': 1, '10': 'confirmedSats'},
    {'1': 'unconfirmed_sats', '3': 2, '4': 1, '5': 1, '10': 'unconfirmedSats'},
  ],
};

/// Descriptor for `GetBalanceResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBalanceResponseDescriptor = $convert.base64Decode(
    'ChJHZXRCYWxhbmNlUmVzcG9uc2USJQoOY29uZmlybWVkX3NhdHMYASABKAFSDWNvbmZpcm1lZF'
    'NhdHMSKQoQdW5jb25maXJtZWRfc2F0cxgCIAEoAVIPdW5jb25maXJtZWRTYXRz');

@$core.Deprecated('Use getNewAddressRequestDescriptor instead')
const GetNewAddressRequest$json = {
  '1': 'GetNewAddressRequest',
  '2': [
    {'1': 'wallet_id', '3': 1, '4': 1, '5': 9, '10': 'walletId'},
  ],
};

/// Descriptor for `GetNewAddressRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNewAddressRequestDescriptor = $convert.base64Decode(
    'ChRHZXROZXdBZGRyZXNzUmVxdWVzdBIbCgl3YWxsZXRfaWQYASABKAlSCHdhbGxldElk');

@$core.Deprecated('Use getNewAddressResponseDescriptor instead')
const GetNewAddressResponse$json = {
  '1': 'GetNewAddressResponse',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'index', '3': 2, '4': 1, '5': 5, '10': 'index'},
  ],
};

/// Descriptor for `GetNewAddressResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNewAddressResponseDescriptor = $convert.base64Decode(
    'ChVHZXROZXdBZGRyZXNzUmVzcG9uc2USGAoHYWRkcmVzcxgBIAEoCVIHYWRkcmVzcxIUCgVpbm'
    'RleBgCIAEoBVIFaW5kZXg=');

@$core.Deprecated('Use sendTransactionRequestDescriptor instead')
const SendTransactionRequest$json = {
  '1': 'SendTransactionRequest',
  '2': [
    {'1': 'wallet_id', '3': 1, '4': 1, '5': 9, '10': 'walletId'},
    {'1': 'destinations', '3': 2, '4': 3, '5': 11, '6': '.walletmanager.v1.SendTransactionRequest.DestinationsEntry', '10': 'destinations'},
    {'1': 'fee_rate_sat_per_vbyte', '3': 3, '4': 1, '5': 3, '10': 'feeRateSatPerVbyte'},
    {'1': 'subtract_fee_from_amount', '3': 4, '4': 1, '5': 8, '10': 'subtractFeeFromAmount'},
    {'1': 'op_return_hex', '3': 5, '4': 1, '5': 9, '10': 'opReturnHex'},
    {'1': 'fixed_fee_sats', '3': 6, '4': 1, '5': 3, '10': 'fixedFeeSats'},
    {'1': 'required_inputs', '3': 7, '4': 3, '5': 11, '6': '.walletmanager.v1.UnspentOutput', '10': 'requiredInputs'},
  ],
  '3': [SendTransactionRequest_DestinationsEntry$json],
};

@$core.Deprecated('Use sendTransactionRequestDescriptor instead')
const SendTransactionRequest_DestinationsEntry$json = {
  '1': 'DestinationsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 3, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `SendTransactionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendTransactionRequestDescriptor = $convert.base64Decode(
    'ChZTZW5kVHJhbnNhY3Rpb25SZXF1ZXN0EhsKCXdhbGxldF9pZBgBIAEoCVIId2FsbGV0SWQSXg'
    'oMZGVzdGluYXRpb25zGAIgAygLMjoud2FsbGV0bWFuYWdlci52MS5TZW5kVHJhbnNhY3Rpb25S'
    'ZXF1ZXN0LkRlc3RpbmF0aW9uc0VudHJ5UgxkZXN0aW5hdGlvbnMSMgoWZmVlX3JhdGVfc2F0X3'
    'Blcl92Ynl0ZRgDIAEoA1ISZmVlUmF0ZVNhdFBlclZieXRlEjcKGHN1YnRyYWN0X2ZlZV9mcm9t'
    'X2Ftb3VudBgEIAEoCFIVc3VidHJhY3RGZWVGcm9tQW1vdW50EiIKDW9wX3JldHVybl9oZXgYBS'
    'ABKAlSC29wUmV0dXJuSGV4EiQKDmZpeGVkX2ZlZV9zYXRzGAYgASgDUgxmaXhlZEZlZVNhdHMS'
    'SAoPcmVxdWlyZWRfaW5wdXRzGAcgAygLMh8ud2FsbGV0bWFuYWdlci52MS5VbnNwZW50T3V0cH'
    'V0Ug5yZXF1aXJlZElucHV0cxo/ChFEZXN0aW5hdGlvbnNFbnRyeRIQCgNrZXkYASABKAlSA2tl'
    'eRIUCgV2YWx1ZRgCIAEoA1IFdmFsdWU6AjgB');

@$core.Deprecated('Use sendTransactionResponseDescriptor instead')
const SendTransactionResponse$json = {
  '1': 'SendTransactionResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `SendTransactionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendTransactionResponseDescriptor = $convert.base64Decode(
    'ChdTZW5kVHJhbnNhY3Rpb25SZXNwb25zZRISCgR0eGlkGAEgASgJUgR0eGlk');

@$core.Deprecated('Use listTransactionsRequestDescriptor instead')
const ListTransactionsRequest$json = {
  '1': 'ListTransactionsRequest',
  '2': [
    {'1': 'wallet_id', '3': 1, '4': 1, '5': 9, '10': 'walletId'},
    {'1': 'count', '3': 2, '4': 1, '5': 5, '10': 'count'},
  ],
};

/// Descriptor for `ListTransactionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listTransactionsRequestDescriptor = $convert.base64Decode(
    'ChdMaXN0VHJhbnNhY3Rpb25zUmVxdWVzdBIbCgl3YWxsZXRfaWQYASABKAlSCHdhbGxldElkEh'
    'QKBWNvdW50GAIgASgFUgVjb3VudA==');

@$core.Deprecated('Use transactionEntryDescriptor instead')
const TransactionEntry$json = {
  '1': 'TransactionEntry',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'vout', '3': 2, '4': 1, '5': 5, '10': 'vout'},
    {'1': 'address', '3': 3, '4': 1, '5': 9, '10': 'address'},
    {'1': 'category', '3': 4, '4': 1, '5': 9, '10': 'category'},
    {'1': 'amount', '3': 5, '4': 1, '5': 1, '10': 'amount'},
    {'1': 'amount_sats', '3': 6, '4': 1, '5': 3, '10': 'amountSats'},
    {'1': 'confirmations', '3': 7, '4': 1, '5': 5, '10': 'confirmations'},
    {'1': 'block_time', '3': 8, '4': 1, '5': 3, '10': 'blockTime'},
    {'1': 'time', '3': 9, '4': 1, '5': 3, '10': 'time'},
    {'1': 'label', '3': 10, '4': 1, '5': 9, '10': 'label'},
    {'1': 'fee', '3': 11, '4': 1, '5': 1, '10': 'fee'},
    {'1': 'replaced_by_txid', '3': 12, '4': 1, '5': 8, '10': 'replacedByTxid'},
    {'1': 'wallet_id', '3': 13, '4': 1, '5': 9, '10': 'walletId'},
  ],
};

/// Descriptor for `TransactionEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transactionEntryDescriptor = $convert.base64Decode(
    'ChBUcmFuc2FjdGlvbkVudHJ5EhIKBHR4aWQYASABKAlSBHR4aWQSEgoEdm91dBgCIAEoBVIEdm'
    '91dBIYCgdhZGRyZXNzGAMgASgJUgdhZGRyZXNzEhoKCGNhdGVnb3J5GAQgASgJUghjYXRlZ29y'
    'eRIWCgZhbW91bnQYBSABKAFSBmFtb3VudBIfCgthbW91bnRfc2F0cxgGIAEoA1IKYW1vdW50U2'
    'F0cxIkCg1jb25maXJtYXRpb25zGAcgASgFUg1jb25maXJtYXRpb25zEh0KCmJsb2NrX3RpbWUY'
    'CCABKANSCWJsb2NrVGltZRISCgR0aW1lGAkgASgDUgR0aW1lEhQKBWxhYmVsGAogASgJUgVsYW'
    'JlbBIQCgNmZWUYCyABKAFSA2ZlZRIoChByZXBsYWNlZF9ieV90eGlkGAwgASgIUg5yZXBsYWNl'
    'ZEJ5VHhpZBIbCgl3YWxsZXRfaWQYDSABKAlSCHdhbGxldElk');

@$core.Deprecated('Use listTransactionsResponseDescriptor instead')
const ListTransactionsResponse$json = {
  '1': 'ListTransactionsResponse',
  '2': [
    {'1': 'transactions', '3': 1, '4': 3, '5': 11, '6': '.walletmanager.v1.TransactionEntry', '10': 'transactions'},
  ],
};

/// Descriptor for `ListTransactionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listTransactionsResponseDescriptor = $convert.base64Decode(
    'ChhMaXN0VHJhbnNhY3Rpb25zUmVzcG9uc2USRgoMdHJhbnNhY3Rpb25zGAEgAygLMiIud2FsbG'
    'V0bWFuYWdlci52MS5UcmFuc2FjdGlvbkVudHJ5Ugx0cmFuc2FjdGlvbnM=');

@$core.Deprecated('Use listUnspentRequestDescriptor instead')
const ListUnspentRequest$json = {
  '1': 'ListUnspentRequest',
  '2': [
    {'1': 'wallet_id', '3': 1, '4': 1, '5': 9, '10': 'walletId'},
  ],
};

/// Descriptor for `ListUnspentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listUnspentRequestDescriptor = $convert.base64Decode(
    'ChJMaXN0VW5zcGVudFJlcXVlc3QSGwoJd2FsbGV0X2lkGAEgASgJUgh3YWxsZXRJZA==');

@$core.Deprecated('Use unspentOutputDescriptor instead')
const UnspentOutput$json = {
  '1': 'UnspentOutput',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'vout', '3': 2, '4': 1, '5': 5, '10': 'vout'},
    {'1': 'address', '3': 3, '4': 1, '5': 9, '10': 'address'},
    {'1': 'amount', '3': 4, '4': 1, '5': 1, '10': 'amount'},
    {'1': 'amount_sats', '3': 5, '4': 1, '5': 3, '10': 'amountSats'},
    {'1': 'confirmations', '3': 6, '4': 1, '5': 5, '10': 'confirmations'},
    {'1': 'label', '3': 7, '4': 1, '5': 9, '10': 'label'},
    {'1': 'spendable', '3': 8, '4': 1, '5': 8, '10': 'spendable'},
    {'1': 'solvable', '3': 9, '4': 1, '5': 8, '10': 'solvable'},
    {'1': 'wallet_id', '3': 10, '4': 1, '5': 9, '10': 'walletId'},
  ],
};

/// Descriptor for `UnspentOutput`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unspentOutputDescriptor = $convert.base64Decode(
    'Cg1VbnNwZW50T3V0cHV0EhIKBHR4aWQYASABKAlSBHR4aWQSEgoEdm91dBgCIAEoBVIEdm91dB'
    'IYCgdhZGRyZXNzGAMgASgJUgdhZGRyZXNzEhYKBmFtb3VudBgEIAEoAVIGYW1vdW50Eh8KC2Ft'
    'b3VudF9zYXRzGAUgASgDUgphbW91bnRTYXRzEiQKDWNvbmZpcm1hdGlvbnMYBiABKAVSDWNvbm'
    'Zpcm1hdGlvbnMSFAoFbGFiZWwYByABKAlSBWxhYmVsEhwKCXNwZW5kYWJsZRgIIAEoCFIJc3Bl'
    'bmRhYmxlEhoKCHNvbHZhYmxlGAkgASgIUghzb2x2YWJsZRIbCgl3YWxsZXRfaWQYCiABKAlSCH'
    'dhbGxldElk');

@$core.Deprecated('Use listUnspentResponseDescriptor instead')
const ListUnspentResponse$json = {
  '1': 'ListUnspentResponse',
  '2': [
    {'1': 'utxos', '3': 1, '4': 3, '5': 11, '6': '.walletmanager.v1.UnspentOutput', '10': 'utxos'},
  ],
};

/// Descriptor for `ListUnspentResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listUnspentResponseDescriptor = $convert.base64Decode(
    'ChNMaXN0VW5zcGVudFJlc3BvbnNlEjUKBXV0eG9zGAEgAygLMh8ud2FsbGV0bWFuYWdlci52MS'
    '5VbnNwZW50T3V0cHV0UgV1dHhvcw==');

@$core.Deprecated('Use listReceiveAddressesRequestDescriptor instead')
const ListReceiveAddressesRequest$json = {
  '1': 'ListReceiveAddressesRequest',
  '2': [
    {'1': 'wallet_id', '3': 1, '4': 1, '5': 9, '10': 'walletId'},
  ],
};

/// Descriptor for `ListReceiveAddressesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listReceiveAddressesRequestDescriptor = $convert.base64Decode(
    'ChtMaXN0UmVjZWl2ZUFkZHJlc3Nlc1JlcXVlc3QSGwoJd2FsbGV0X2lkGAEgASgJUgh3YWxsZX'
    'RJZA==');

@$core.Deprecated('Use receiveAddressDescriptor instead')
const ReceiveAddress$json = {
  '1': 'ReceiveAddress',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'amount', '3': 2, '4': 1, '5': 1, '10': 'amount'},
    {'1': 'amount_sats', '3': 3, '4': 1, '5': 3, '10': 'amountSats'},
    {'1': 'label', '3': 4, '4': 1, '5': 9, '10': 'label'},
    {'1': 'tx_count', '3': 5, '4': 1, '5': 5, '10': 'txCount'},
  ],
};

/// Descriptor for `ReceiveAddress`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List receiveAddressDescriptor = $convert.base64Decode(
    'Cg5SZWNlaXZlQWRkcmVzcxIYCgdhZGRyZXNzGAEgASgJUgdhZGRyZXNzEhYKBmFtb3VudBgCIA'
    'EoAVIGYW1vdW50Eh8KC2Ftb3VudF9zYXRzGAMgASgDUgphbW91bnRTYXRzEhQKBWxhYmVsGAQg'
    'ASgJUgVsYWJlbBIZCgh0eF9jb3VudBgFIAEoBVIHdHhDb3VudA==');

@$core.Deprecated('Use listReceiveAddressesResponseDescriptor instead')
const ListReceiveAddressesResponse$json = {
  '1': 'ListReceiveAddressesResponse',
  '2': [
    {'1': 'addresses', '3': 1, '4': 3, '5': 11, '6': '.walletmanager.v1.ReceiveAddress', '10': 'addresses'},
  ],
};

/// Descriptor for `ListReceiveAddressesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listReceiveAddressesResponseDescriptor = $convert.base64Decode(
    'ChxMaXN0UmVjZWl2ZUFkZHJlc3Nlc1Jlc3BvbnNlEj4KCWFkZHJlc3NlcxgBIAMoCzIgLndhbG'
    'xldG1hbmFnZXIudjEuUmVjZWl2ZUFkZHJlc3NSCWFkZHJlc3Nlcw==');

@$core.Deprecated('Use getTransactionDetailsRequestDescriptor instead')
const GetTransactionDetailsRequest$json = {
  '1': 'GetTransactionDetailsRequest',
  '2': [
    {'1': 'wallet_id', '3': 1, '4': 1, '5': 9, '10': 'walletId'},
    {'1': 'txid', '3': 2, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `GetTransactionDetailsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTransactionDetailsRequestDescriptor = $convert.base64Decode(
    'ChxHZXRUcmFuc2FjdGlvbkRldGFpbHNSZXF1ZXN0EhsKCXdhbGxldF9pZBgBIAEoCVIId2FsbG'
    'V0SWQSEgoEdHhpZBgCIAEoCVIEdHhpZA==');

@$core.Deprecated('Use getTransactionDetailsResponseDescriptor instead')
const GetTransactionDetailsResponse$json = {
  '1': 'GetTransactionDetailsResponse',
  '2': [
    {'1': 'transaction', '3': 1, '4': 1, '5': 11, '6': '.walletmanager.v1.TransactionEntry', '10': 'transaction'},
    {'1': 'raw_hex', '3': 2, '4': 1, '5': 9, '10': 'rawHex'},
    {'1': 'blockhash', '3': 3, '4': 1, '5': 9, '10': 'blockhash'},
    {'1': 'confirmations', '3': 4, '4': 1, '5': 5, '10': 'confirmations'},
    {'1': 'block_time', '3': 5, '4': 1, '5': 3, '10': 'blockTime'},
    {'1': 'version', '3': 6, '4': 1, '5': 5, '10': 'version'},
    {'1': 'locktime', '3': 7, '4': 1, '5': 5, '10': 'locktime'},
    {'1': 'size_bytes', '3': 8, '4': 1, '5': 5, '10': 'sizeBytes'},
    {'1': 'vsize_vbytes', '3': 9, '4': 1, '5': 5, '10': 'vsizeVbytes'},
    {'1': 'weight_wu', '3': 10, '4': 1, '5': 5, '10': 'weightWu'},
    {'1': 'fee_sats', '3': 11, '4': 1, '5': 3, '10': 'feeSats'},
    {'1': 'fee_rate_sat_vb', '3': 12, '4': 1, '5': 1, '10': 'feeRateSatVb'},
    {'1': 'inputs', '3': 13, '4': 3, '5': 11, '6': '.walletmanager.v1.TransactionInput', '10': 'inputs'},
    {'1': 'total_input_sats', '3': 14, '4': 1, '5': 3, '10': 'totalInputSats'},
    {'1': 'outputs', '3': 15, '4': 3, '5': 11, '6': '.walletmanager.v1.TransactionOutput', '10': 'outputs'},
    {'1': 'total_output_sats', '3': 16, '4': 1, '5': 3, '10': 'totalOutputSats'},
  ],
};

/// Descriptor for `GetTransactionDetailsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTransactionDetailsResponseDescriptor = $convert.base64Decode(
    'Ch1HZXRUcmFuc2FjdGlvbkRldGFpbHNSZXNwb25zZRJECgt0cmFuc2FjdGlvbhgBIAEoCzIiLn'
    'dhbGxldG1hbmFnZXIudjEuVHJhbnNhY3Rpb25FbnRyeVILdHJhbnNhY3Rpb24SFwoHcmF3X2hl'
    'eBgCIAEoCVIGcmF3SGV4EhwKCWJsb2NraGFzaBgDIAEoCVIJYmxvY2toYXNoEiQKDWNvbmZpcm'
    '1hdGlvbnMYBCABKAVSDWNvbmZpcm1hdGlvbnMSHQoKYmxvY2tfdGltZRgFIAEoA1IJYmxvY2tU'
    'aW1lEhgKB3ZlcnNpb24YBiABKAVSB3ZlcnNpb24SGgoIbG9ja3RpbWUYByABKAVSCGxvY2t0aW'
    '1lEh0KCnNpemVfYnl0ZXMYCCABKAVSCXNpemVCeXRlcxIhCgx2c2l6ZV92Ynl0ZXMYCSABKAVS'
    'C3ZzaXplVmJ5dGVzEhsKCXdlaWdodF93dRgKIAEoBVIId2VpZ2h0V3USGQoIZmVlX3NhdHMYCy'
    'ABKANSB2ZlZVNhdHMSJQoPZmVlX3JhdGVfc2F0X3ZiGAwgASgBUgxmZWVSYXRlU2F0VmISOgoG'
    'aW5wdXRzGA0gAygLMiIud2FsbGV0bWFuYWdlci52MS5UcmFuc2FjdGlvbklucHV0UgZpbnB1dH'
    'MSKAoQdG90YWxfaW5wdXRfc2F0cxgOIAEoA1IOdG90YWxJbnB1dFNhdHMSPQoHb3V0cHV0cxgP'
    'IAMoCzIjLndhbGxldG1hbmFnZXIudjEuVHJhbnNhY3Rpb25PdXRwdXRSB291dHB1dHMSKgoRdG'
    '90YWxfb3V0cHV0X3NhdHMYECABKANSD3RvdGFsT3V0cHV0U2F0cw==');

@$core.Deprecated('Use transactionInputDescriptor instead')
const TransactionInput$json = {
  '1': 'TransactionInput',
  '2': [
    {'1': 'index', '3': 1, '4': 1, '5': 5, '10': 'index'},
    {'1': 'prev_txid', '3': 2, '4': 1, '5': 9, '10': 'prevTxid'},
    {'1': 'prev_vout', '3': 3, '4': 1, '5': 5, '10': 'prevVout'},
    {'1': 'address', '3': 4, '4': 1, '5': 9, '10': 'address'},
    {'1': 'value_sats', '3': 5, '4': 1, '5': 3, '10': 'valueSats'},
    {'1': 'script_sig_asm', '3': 6, '4': 1, '5': 9, '10': 'scriptSigAsm'},
    {'1': 'script_sig_hex', '3': 7, '4': 1, '5': 9, '10': 'scriptSigHex'},
    {'1': 'witness', '3': 8, '4': 3, '5': 9, '10': 'witness'},
    {'1': 'sequence', '3': 9, '4': 1, '5': 3, '10': 'sequence'},
    {'1': 'is_coinbase', '3': 10, '4': 1, '5': 8, '10': 'isCoinbase'},
  ],
};

/// Descriptor for `TransactionInput`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transactionInputDescriptor = $convert.base64Decode(
    'ChBUcmFuc2FjdGlvbklucHV0EhQKBWluZGV4GAEgASgFUgVpbmRleBIbCglwcmV2X3R4aWQYAi'
    'ABKAlSCHByZXZUeGlkEhsKCXByZXZfdm91dBgDIAEoBVIIcHJldlZvdXQSGAoHYWRkcmVzcxgE'
    'IAEoCVIHYWRkcmVzcxIdCgp2YWx1ZV9zYXRzGAUgASgDUgl2YWx1ZVNhdHMSJAoOc2NyaXB0X3'
    'NpZ19hc20YBiABKAlSDHNjcmlwdFNpZ0FzbRIkCg5zY3JpcHRfc2lnX2hleBgHIAEoCVIMc2Ny'
    'aXB0U2lnSGV4EhgKB3dpdG5lc3MYCCADKAlSB3dpdG5lc3MSGgoIc2VxdWVuY2UYCSABKANSCH'
    'NlcXVlbmNlEh8KC2lzX2NvaW5iYXNlGAogASgIUgppc0NvaW5iYXNl');

@$core.Deprecated('Use transactionOutputDescriptor instead')
const TransactionOutput$json = {
  '1': 'TransactionOutput',
  '2': [
    {'1': 'index', '3': 1, '4': 1, '5': 5, '10': 'index'},
    {'1': 'value_sats', '3': 2, '4': 1, '5': 3, '10': 'valueSats'},
    {'1': 'address', '3': 3, '4': 1, '5': 9, '10': 'address'},
    {'1': 'script_type', '3': 4, '4': 1, '5': 9, '10': 'scriptType'},
    {'1': 'script_pubkey_asm', '3': 5, '4': 1, '5': 9, '10': 'scriptPubkeyAsm'},
    {'1': 'script_pubkey_hex', '3': 6, '4': 1, '5': 9, '10': 'scriptPubkeyHex'},
  ],
};

/// Descriptor for `TransactionOutput`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transactionOutputDescriptor = $convert.base64Decode(
    'ChFUcmFuc2FjdGlvbk91dHB1dBIUCgVpbmRleBgBIAEoBVIFaW5kZXgSHQoKdmFsdWVfc2F0cx'
    'gCIAEoA1IJdmFsdWVTYXRzEhgKB2FkZHJlc3MYAyABKAlSB2FkZHJlc3MSHwoLc2NyaXB0X3R5'
    'cGUYBCABKAlSCnNjcmlwdFR5cGUSKgoRc2NyaXB0X3B1YmtleV9hc20YBSABKAlSD3NjcmlwdF'
    'B1YmtleUFzbRIqChFzY3JpcHRfcHVia2V5X2hleBgGIAEoCVIPc2NyaXB0UHVia2V5SGV4');

@$core.Deprecated('Use bumpFeeRequestDescriptor instead')
const BumpFeeRequest$json = {
  '1': 'BumpFeeRequest',
  '2': [
    {'1': 'wallet_id', '3': 1, '4': 1, '5': 9, '10': 'walletId'},
    {'1': 'txid', '3': 2, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'new_fee_rate', '3': 3, '4': 1, '5': 3, '10': 'newFeeRate'},
  ],
};

/// Descriptor for `BumpFeeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List bumpFeeRequestDescriptor = $convert.base64Decode(
    'Cg5CdW1wRmVlUmVxdWVzdBIbCgl3YWxsZXRfaWQYASABKAlSCHdhbGxldElkEhIKBHR4aWQYAi'
    'ABKAlSBHR4aWQSIAoMbmV3X2ZlZV9yYXRlGAMgASgDUgpuZXdGZWVSYXRl');

@$core.Deprecated('Use bumpFeeResponseDescriptor instead')
const BumpFeeResponse$json = {
  '1': 'BumpFeeResponse',
  '2': [
    {'1': 'new_txid', '3': 1, '4': 1, '5': 9, '10': 'newTxid'},
  ],
};

/// Descriptor for `BumpFeeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List bumpFeeResponseDescriptor = $convert.base64Decode(
    'Cg9CdW1wRmVlUmVzcG9uc2USGQoIbmV3X3R4aWQYASABKAlSB25ld1R4aWQ=');

@$core.Deprecated('Use deriveAddressesRequestDescriptor instead')
const DeriveAddressesRequest$json = {
  '1': 'DeriveAddressesRequest',
  '2': [
    {'1': 'wallet_id', '3': 1, '4': 1, '5': 9, '10': 'walletId'},
    {'1': 'start_index', '3': 2, '4': 1, '5': 5, '10': 'startIndex'},
    {'1': 'count', '3': 3, '4': 1, '5': 5, '10': 'count'},
  ],
};

/// Descriptor for `DeriveAddressesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deriveAddressesRequestDescriptor = $convert.base64Decode(
    'ChZEZXJpdmVBZGRyZXNzZXNSZXF1ZXN0EhsKCXdhbGxldF9pZBgBIAEoCVIId2FsbGV0SWQSHw'
    'oLc3RhcnRfaW5kZXgYAiABKAVSCnN0YXJ0SW5kZXgSFAoFY291bnQYAyABKAVSBWNvdW50');

@$core.Deprecated('Use deriveAddressesResponseDescriptor instead')
const DeriveAddressesResponse$json = {
  '1': 'DeriveAddressesResponse',
  '2': [
    {'1': 'addresses', '3': 1, '4': 3, '5': 9, '10': 'addresses'},
  ],
};

/// Descriptor for `DeriveAddressesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deriveAddressesResponseDescriptor = $convert.base64Decode(
    'ChdEZXJpdmVBZGRyZXNzZXNSZXNwb25zZRIcCglhZGRyZXNzZXMYASADKAlSCWFkZHJlc3Nlcw'
    '==');

@$core.Deprecated('Use getWalletSeedRequestDescriptor instead')
const GetWalletSeedRequest$json = {
  '1': 'GetWalletSeedRequest',
  '2': [
    {'1': 'wallet_id', '3': 1, '4': 1, '5': 9, '10': 'walletId'},
  ],
};

/// Descriptor for `GetWalletSeedRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getWalletSeedRequestDescriptor = $convert.base64Decode(
    'ChRHZXRXYWxsZXRTZWVkUmVxdWVzdBIbCgl3YWxsZXRfaWQYASABKAlSCHdhbGxldElk');

@$core.Deprecated('Use getWalletSeedResponseDescriptor instead')
const GetWalletSeedResponse$json = {
  '1': 'GetWalletSeedResponse',
  '2': [
    {'1': 'seed_hex', '3': 1, '4': 1, '5': 9, '10': 'seedHex'},
    {'1': 'mnemonic', '3': 2, '4': 1, '5': 9, '10': 'mnemonic'},
  ],
};

/// Descriptor for `GetWalletSeedResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getWalletSeedResponseDescriptor = $convert.base64Decode(
    'ChVHZXRXYWxsZXRTZWVkUmVzcG9uc2USGQoIc2VlZF9oZXgYASABKAlSB3NlZWRIZXgSGgoIbW'
    '5lbW9uaWMYAiABKAlSCG1uZW1vbmlj');

@$core.Deprecated('Use listCoreVariantsRequestDescriptor instead')
const ListCoreVariantsRequest$json = {
  '1': 'ListCoreVariantsRequest',
};

/// Descriptor for `ListCoreVariantsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listCoreVariantsRequestDescriptor = $convert.base64Decode(
    'ChdMaXN0Q29yZVZhcmlhbnRzUmVxdWVzdA==');

@$core.Deprecated('Use coreVariantDescriptor instead')
const CoreVariant$json = {
  '1': 'CoreVariant',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'display_name', '3': 2, '4': 1, '5': 9, '10': 'displayName'},
    {'1': 'installed', '3': 3, '4': 1, '5': 8, '10': 'installed'},
  ],
};

/// Descriptor for `CoreVariant`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List coreVariantDescriptor = $convert.base64Decode(
    'CgtDb3JlVmFyaWFudBIOCgJpZBgBIAEoCVICaWQSIQoMZGlzcGxheV9uYW1lGAIgASgJUgtkaX'
    'NwbGF5TmFtZRIcCglpbnN0YWxsZWQYAyABKAhSCWluc3RhbGxlZA==');

@$core.Deprecated('Use listCoreVariantsResponseDescriptor instead')
const ListCoreVariantsResponse$json = {
  '1': 'ListCoreVariantsResponse',
  '2': [
    {'1': 'variants', '3': 1, '4': 3, '5': 11, '6': '.walletmanager.v1.CoreVariant', '10': 'variants'},
    {'1': 'active_id', '3': 2, '4': 1, '5': 9, '10': 'activeId'},
  ],
};

/// Descriptor for `ListCoreVariantsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listCoreVariantsResponseDescriptor = $convert.base64Decode(
    'ChhMaXN0Q29yZVZhcmlhbnRzUmVzcG9uc2USOQoIdmFyaWFudHMYASADKAsyHS53YWxsZXRtYW'
    '5hZ2VyLnYxLkNvcmVWYXJpYW50Ugh2YXJpYW50cxIbCglhY3RpdmVfaWQYAiABKAlSCGFjdGl2'
    'ZUlk');

@$core.Deprecated('Use getCoreVariantRequestDescriptor instead')
const GetCoreVariantRequest$json = {
  '1': 'GetCoreVariantRequest',
};

/// Descriptor for `GetCoreVariantRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCoreVariantRequestDescriptor = $convert.base64Decode(
    'ChVHZXRDb3JlVmFyaWFudFJlcXVlc3Q=');

@$core.Deprecated('Use getCoreVariantResponseDescriptor instead')
const GetCoreVariantResponse$json = {
  '1': 'GetCoreVariantResponse',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `GetCoreVariantResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCoreVariantResponseDescriptor = $convert.base64Decode(
    'ChZHZXRDb3JlVmFyaWFudFJlc3BvbnNlEg4KAmlkGAEgASgJUgJpZA==');

@$core.Deprecated('Use setCoreVariantRequestDescriptor instead')
const SetCoreVariantRequest$json = {
  '1': 'SetCoreVariantRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `SetCoreVariantRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setCoreVariantRequestDescriptor = $convert.base64Decode(
    'ChVTZXRDb3JlVmFyaWFudFJlcXVlc3QSDgoCaWQYASABKAlSAmlk');

@$core.Deprecated('Use setCoreVariantResponseDescriptor instead')
const SetCoreVariantResponse$json = {
  '1': 'SetCoreVariantResponse',
};

/// Descriptor for `SetCoreVariantResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setCoreVariantResponseDescriptor = $convert.base64Decode(
    'ChZTZXRDb3JlVmFyaWFudFJlc3BvbnNl');

@$core.Deprecated('Use watchWalletDataResponseDescriptor instead')
const WatchWalletDataResponse$json = {
  '1': 'WatchWalletDataResponse',
  '2': [
    {'1': 'has_wallet', '3': 1, '4': 1, '5': 8, '10': 'hasWallet'},
    {'1': 'encrypted', '3': 2, '4': 1, '5': 8, '10': 'encrypted'},
    {'1': 'unlocked', '3': 3, '4': 1, '5': 8, '10': 'unlocked'},
    {'1': 'active_wallet_id', '3': 4, '4': 1, '5': 9, '10': 'activeWalletId'},
    {'1': 'wallets', '3': 5, '4': 3, '5': 11, '6': '.walletmanager.v1.WalletMetadata', '10': 'wallets'},
    {'1': 'confirmed_sats', '3': 6, '4': 1, '5': 1, '10': 'confirmedSats'},
    {'1': 'unconfirmed_sats', '3': 7, '4': 1, '5': 1, '10': 'unconfirmedSats'},
  ],
};

/// Descriptor for `WatchWalletDataResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List watchWalletDataResponseDescriptor = $convert.base64Decode(
    'ChdXYXRjaFdhbGxldERhdGFSZXNwb25zZRIdCgpoYXNfd2FsbGV0GAEgASgIUgloYXNXYWxsZX'
    'QSHAoJZW5jcnlwdGVkGAIgASgIUgllbmNyeXB0ZWQSGgoIdW5sb2NrZWQYAyABKAhSCHVubG9j'
    'a2VkEigKEGFjdGl2ZV93YWxsZXRfaWQYBCABKAlSDmFjdGl2ZVdhbGxldElkEjoKB3dhbGxldH'
    'MYBSADKAsyIC53YWxsZXRtYW5hZ2VyLnYxLldhbGxldE1ldGFkYXRhUgd3YWxsZXRzEiUKDmNv'
    'bmZpcm1lZF9zYXRzGAYgASgBUg1jb25maXJtZWRTYXRzEikKEHVuY29uZmlybWVkX3NhdHMYBy'
    'ABKAFSD3VuY29uZmlybWVkU2F0cw==');

const $core.Map<$core.String, $core.dynamic> WalletManagerServiceBase$json = {
  '1': 'WalletManagerService',
  '2': [
    {'1': 'GetWalletStatus', '2': '.walletmanager.v1.GetWalletStatusRequest', '3': '.walletmanager.v1.GetWalletStatusResponse'},
    {'1': 'GenerateWallet', '2': '.walletmanager.v1.GenerateWalletRequest', '3': '.walletmanager.v1.GenerateWalletResponse'},
    {'1': 'UnlockWallet', '2': '.walletmanager.v1.UnlockWalletRequest', '3': '.walletmanager.v1.UnlockWalletResponse'},
    {'1': 'LockWallet', '2': '.walletmanager.v1.LockWalletRequest', '3': '.walletmanager.v1.LockWalletResponse'},
    {'1': 'EncryptWallet', '2': '.walletmanager.v1.EncryptWalletRequest', '3': '.walletmanager.v1.EncryptWalletResponse'},
    {'1': 'ChangePassword', '2': '.walletmanager.v1.ChangePasswordRequest', '3': '.walletmanager.v1.ChangePasswordResponse'},
    {'1': 'RemoveEncryption', '2': '.walletmanager.v1.RemoveEncryptionRequest', '3': '.walletmanager.v1.RemoveEncryptionResponse'},
    {'1': 'ListWallets', '2': '.walletmanager.v1.ListWalletsRequest', '3': '.walletmanager.v1.ListWalletsResponse'},
    {'1': 'SwitchWallet', '2': '.walletmanager.v1.SwitchWalletRequest', '3': '.walletmanager.v1.SwitchWalletResponse'},
    {'1': 'UpdateWalletMetadata', '2': '.walletmanager.v1.UpdateWalletMetadataRequest', '3': '.walletmanager.v1.UpdateWalletMetadataResponse'},
    {'1': 'DeleteWallet', '2': '.walletmanager.v1.DeleteWalletRequest', '3': '.walletmanager.v1.DeleteWalletResponse'},
    {'1': 'DeleteAllWallets', '2': '.walletmanager.v1.DeleteAllWalletsRequest', '3': '.walletmanager.v1.DeleteAllWalletsResponse'},
    {'1': 'CreateWatchOnlyWallet', '2': '.walletmanager.v1.CreateWatchOnlyWalletRequest', '3': '.walletmanager.v1.CreateWatchOnlyWalletResponse'},
    {'1': 'CreateBitcoinCoreWallet', '2': '.walletmanager.v1.CreateBitcoinCoreWalletRequest', '3': '.walletmanager.v1.CreateBitcoinCoreWalletResponse'},
    {'1': 'EnsureCoreWallets', '2': '.walletmanager.v1.EnsureCoreWalletsRequest', '3': '.walletmanager.v1.EnsureCoreWalletsResponse'},
    {'1': 'GetBalance', '2': '.walletmanager.v1.GetBalanceRequest', '3': '.walletmanager.v1.GetBalanceResponse'},
    {'1': 'GetNewAddress', '2': '.walletmanager.v1.GetNewAddressRequest', '3': '.walletmanager.v1.GetNewAddressResponse'},
    {'1': 'SendTransaction', '2': '.walletmanager.v1.SendTransactionRequest', '3': '.walletmanager.v1.SendTransactionResponse'},
    {'1': 'ListTransactions', '2': '.walletmanager.v1.ListTransactionsRequest', '3': '.walletmanager.v1.ListTransactionsResponse'},
    {'1': 'ListUnspent', '2': '.walletmanager.v1.ListUnspentRequest', '3': '.walletmanager.v1.ListUnspentResponse'},
    {'1': 'ListReceiveAddresses', '2': '.walletmanager.v1.ListReceiveAddressesRequest', '3': '.walletmanager.v1.ListReceiveAddressesResponse'},
    {'1': 'GetTransactionDetails', '2': '.walletmanager.v1.GetTransactionDetailsRequest', '3': '.walletmanager.v1.GetTransactionDetailsResponse'},
    {'1': 'BumpFee', '2': '.walletmanager.v1.BumpFeeRequest', '3': '.walletmanager.v1.BumpFeeResponse'},
    {'1': 'DeriveAddresses', '2': '.walletmanager.v1.DeriveAddressesRequest', '3': '.walletmanager.v1.DeriveAddressesResponse'},
    {'1': 'GetWalletSeed', '2': '.walletmanager.v1.GetWalletSeedRequest', '3': '.walletmanager.v1.GetWalletSeedResponse'},
    {'1': 'ListCoreVariants', '2': '.walletmanager.v1.ListCoreVariantsRequest', '3': '.walletmanager.v1.ListCoreVariantsResponse'},
    {'1': 'GetCoreVariant', '2': '.walletmanager.v1.GetCoreVariantRequest', '3': '.walletmanager.v1.GetCoreVariantResponse'},
    {'1': 'SetCoreVariant', '2': '.walletmanager.v1.SetCoreVariantRequest', '3': '.walletmanager.v1.SetCoreVariantResponse'},
    {'1': 'WatchWalletData', '2': '.google.protobuf.Empty', '3': '.walletmanager.v1.WatchWalletDataResponse', '6': true},
  ],
};

@$core.Deprecated('Use walletManagerServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> WalletManagerServiceBase$messageJson = {
  '.walletmanager.v1.GetWalletStatusRequest': GetWalletStatusRequest$json,
  '.walletmanager.v1.GetWalletStatusResponse': GetWalletStatusResponse$json,
  '.walletmanager.v1.GenerateWalletRequest': GenerateWalletRequest$json,
  '.walletmanager.v1.GenerateWalletResponse': GenerateWalletResponse$json,
  '.walletmanager.v1.UnlockWalletRequest': UnlockWalletRequest$json,
  '.walletmanager.v1.UnlockWalletResponse': UnlockWalletResponse$json,
  '.walletmanager.v1.LockWalletRequest': LockWalletRequest$json,
  '.walletmanager.v1.LockWalletResponse': LockWalletResponse$json,
  '.walletmanager.v1.EncryptWalletRequest': EncryptWalletRequest$json,
  '.walletmanager.v1.EncryptWalletResponse': EncryptWalletResponse$json,
  '.walletmanager.v1.ChangePasswordRequest': ChangePasswordRequest$json,
  '.walletmanager.v1.ChangePasswordResponse': ChangePasswordResponse$json,
  '.walletmanager.v1.RemoveEncryptionRequest': RemoveEncryptionRequest$json,
  '.walletmanager.v1.RemoveEncryptionResponse': RemoveEncryptionResponse$json,
  '.walletmanager.v1.ListWalletsRequest': ListWalletsRequest$json,
  '.walletmanager.v1.ListWalletsResponse': ListWalletsResponse$json,
  '.walletmanager.v1.WalletMetadata': WalletMetadata$json,
  '.walletmanager.v1.SidechainStarter': SidechainStarter$json,
  '.walletmanager.v1.SwitchWalletRequest': SwitchWalletRequest$json,
  '.walletmanager.v1.SwitchWalletResponse': SwitchWalletResponse$json,
  '.walletmanager.v1.UpdateWalletMetadataRequest': UpdateWalletMetadataRequest$json,
  '.walletmanager.v1.UpdateWalletMetadataResponse': UpdateWalletMetadataResponse$json,
  '.walletmanager.v1.DeleteWalletRequest': DeleteWalletRequest$json,
  '.walletmanager.v1.DeleteWalletResponse': DeleteWalletResponse$json,
  '.walletmanager.v1.DeleteAllWalletsRequest': DeleteAllWalletsRequest$json,
  '.walletmanager.v1.DeleteAllWalletsResponse': DeleteAllWalletsResponse$json,
  '.walletmanager.v1.CreateWatchOnlyWalletRequest': CreateWatchOnlyWalletRequest$json,
  '.walletmanager.v1.CreateWatchOnlyWalletResponse': CreateWatchOnlyWalletResponse$json,
  '.walletmanager.v1.CreateBitcoinCoreWalletRequest': CreateBitcoinCoreWalletRequest$json,
  '.walletmanager.v1.CreateBitcoinCoreWalletResponse': CreateBitcoinCoreWalletResponse$json,
  '.walletmanager.v1.EnsureCoreWalletsRequest': EnsureCoreWalletsRequest$json,
  '.walletmanager.v1.EnsureCoreWalletsResponse': EnsureCoreWalletsResponse$json,
  '.walletmanager.v1.GetBalanceRequest': GetBalanceRequest$json,
  '.walletmanager.v1.GetBalanceResponse': GetBalanceResponse$json,
  '.walletmanager.v1.GetNewAddressRequest': GetNewAddressRequest$json,
  '.walletmanager.v1.GetNewAddressResponse': GetNewAddressResponse$json,
  '.walletmanager.v1.SendTransactionRequest': SendTransactionRequest$json,
  '.walletmanager.v1.SendTransactionRequest.DestinationsEntry': SendTransactionRequest_DestinationsEntry$json,
  '.walletmanager.v1.UnspentOutput': UnspentOutput$json,
  '.walletmanager.v1.SendTransactionResponse': SendTransactionResponse$json,
  '.walletmanager.v1.ListTransactionsRequest': ListTransactionsRequest$json,
  '.walletmanager.v1.ListTransactionsResponse': ListTransactionsResponse$json,
  '.walletmanager.v1.TransactionEntry': TransactionEntry$json,
  '.walletmanager.v1.ListUnspentRequest': ListUnspentRequest$json,
  '.walletmanager.v1.ListUnspentResponse': ListUnspentResponse$json,
  '.walletmanager.v1.ListReceiveAddressesRequest': ListReceiveAddressesRequest$json,
  '.walletmanager.v1.ListReceiveAddressesResponse': ListReceiveAddressesResponse$json,
  '.walletmanager.v1.ReceiveAddress': ReceiveAddress$json,
  '.walletmanager.v1.GetTransactionDetailsRequest': GetTransactionDetailsRequest$json,
  '.walletmanager.v1.GetTransactionDetailsResponse': GetTransactionDetailsResponse$json,
  '.walletmanager.v1.TransactionInput': TransactionInput$json,
  '.walletmanager.v1.TransactionOutput': TransactionOutput$json,
  '.walletmanager.v1.BumpFeeRequest': BumpFeeRequest$json,
  '.walletmanager.v1.BumpFeeResponse': BumpFeeResponse$json,
  '.walletmanager.v1.DeriveAddressesRequest': DeriveAddressesRequest$json,
  '.walletmanager.v1.DeriveAddressesResponse': DeriveAddressesResponse$json,
  '.walletmanager.v1.GetWalletSeedRequest': GetWalletSeedRequest$json,
  '.walletmanager.v1.GetWalletSeedResponse': GetWalletSeedResponse$json,
  '.walletmanager.v1.ListCoreVariantsRequest': ListCoreVariantsRequest$json,
  '.walletmanager.v1.ListCoreVariantsResponse': ListCoreVariantsResponse$json,
  '.walletmanager.v1.CoreVariant': CoreVariant$json,
  '.walletmanager.v1.GetCoreVariantRequest': GetCoreVariantRequest$json,
  '.walletmanager.v1.GetCoreVariantResponse': GetCoreVariantResponse$json,
  '.walletmanager.v1.SetCoreVariantRequest': SetCoreVariantRequest$json,
  '.walletmanager.v1.SetCoreVariantResponse': SetCoreVariantResponse$json,
  '.google.protobuf.Empty': $12.Empty$json,
  '.walletmanager.v1.WatchWalletDataResponse': WatchWalletDataResponse$json,
};

/// Descriptor for `WalletManagerService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List walletManagerServiceDescriptor = $convert.base64Decode(
    'ChRXYWxsZXRNYW5hZ2VyU2VydmljZRJmCg9HZXRXYWxsZXRTdGF0dXMSKC53YWxsZXRtYW5hZ2'
    'VyLnYxLkdldFdhbGxldFN0YXR1c1JlcXVlc3QaKS53YWxsZXRtYW5hZ2VyLnYxLkdldFdhbGxl'
    'dFN0YXR1c1Jlc3BvbnNlEmMKDkdlbmVyYXRlV2FsbGV0Eicud2FsbGV0bWFuYWdlci52MS5HZW'
    '5lcmF0ZVdhbGxldFJlcXVlc3QaKC53YWxsZXRtYW5hZ2VyLnYxLkdlbmVyYXRlV2FsbGV0UmVz'
    'cG9uc2USXQoMVW5sb2NrV2FsbGV0EiUud2FsbGV0bWFuYWdlci52MS5VbmxvY2tXYWxsZXRSZX'
    'F1ZXN0GiYud2FsbGV0bWFuYWdlci52MS5VbmxvY2tXYWxsZXRSZXNwb25zZRJXCgpMb2NrV2Fs'
    'bGV0EiMud2FsbGV0bWFuYWdlci52MS5Mb2NrV2FsbGV0UmVxdWVzdBokLndhbGxldG1hbmFnZX'
    'IudjEuTG9ja1dhbGxldFJlc3BvbnNlEmAKDUVuY3J5cHRXYWxsZXQSJi53YWxsZXRtYW5hZ2Vy'
    'LnYxLkVuY3J5cHRXYWxsZXRSZXF1ZXN0Gicud2FsbGV0bWFuYWdlci52MS5FbmNyeXB0V2FsbG'
    'V0UmVzcG9uc2USYwoOQ2hhbmdlUGFzc3dvcmQSJy53YWxsZXRtYW5hZ2VyLnYxLkNoYW5nZVBh'
    'c3N3b3JkUmVxdWVzdBooLndhbGxldG1hbmFnZXIudjEuQ2hhbmdlUGFzc3dvcmRSZXNwb25zZR'
    'JpChBSZW1vdmVFbmNyeXB0aW9uEikud2FsbGV0bWFuYWdlci52MS5SZW1vdmVFbmNyeXB0aW9u'
    'UmVxdWVzdBoqLndhbGxldG1hbmFnZXIudjEuUmVtb3ZlRW5jcnlwdGlvblJlc3BvbnNlEloKC0'
    'xpc3RXYWxsZXRzEiQud2FsbGV0bWFuYWdlci52MS5MaXN0V2FsbGV0c1JlcXVlc3QaJS53YWxs'
    'ZXRtYW5hZ2VyLnYxLkxpc3RXYWxsZXRzUmVzcG9uc2USXQoMU3dpdGNoV2FsbGV0EiUud2FsbG'
    'V0bWFuYWdlci52MS5Td2l0Y2hXYWxsZXRSZXF1ZXN0GiYud2FsbGV0bWFuYWdlci52MS5Td2l0'
    'Y2hXYWxsZXRSZXNwb25zZRJ1ChRVcGRhdGVXYWxsZXRNZXRhZGF0YRItLndhbGxldG1hbmFnZX'
    'IudjEuVXBkYXRlV2FsbGV0TWV0YWRhdGFSZXF1ZXN0Gi4ud2FsbGV0bWFuYWdlci52MS5VcGRh'
    'dGVXYWxsZXRNZXRhZGF0YVJlc3BvbnNlEl0KDERlbGV0ZVdhbGxldBIlLndhbGxldG1hbmFnZX'
    'IudjEuRGVsZXRlV2FsbGV0UmVxdWVzdBomLndhbGxldG1hbmFnZXIudjEuRGVsZXRlV2FsbGV0'
    'UmVzcG9uc2USaQoQRGVsZXRlQWxsV2FsbGV0cxIpLndhbGxldG1hbmFnZXIudjEuRGVsZXRlQW'
    'xsV2FsbGV0c1JlcXVlc3QaKi53YWxsZXRtYW5hZ2VyLnYxLkRlbGV0ZUFsbFdhbGxldHNSZXNw'
    'b25zZRJ4ChVDcmVhdGVXYXRjaE9ubHlXYWxsZXQSLi53YWxsZXRtYW5hZ2VyLnYxLkNyZWF0ZV'
    'dhdGNoT25seVdhbGxldFJlcXVlc3QaLy53YWxsZXRtYW5hZ2VyLnYxLkNyZWF0ZVdhdGNoT25s'
    'eVdhbGxldFJlc3BvbnNlEn4KF0NyZWF0ZUJpdGNvaW5Db3JlV2FsbGV0EjAud2FsbGV0bWFuYW'
    'dlci52MS5DcmVhdGVCaXRjb2luQ29yZVdhbGxldFJlcXVlc3QaMS53YWxsZXRtYW5hZ2VyLnYx'
    'LkNyZWF0ZUJpdGNvaW5Db3JlV2FsbGV0UmVzcG9uc2USbAoRRW5zdXJlQ29yZVdhbGxldHMSKi'
    '53YWxsZXRtYW5hZ2VyLnYxLkVuc3VyZUNvcmVXYWxsZXRzUmVxdWVzdBorLndhbGxldG1hbmFn'
    'ZXIudjEuRW5zdXJlQ29yZVdhbGxldHNSZXNwb25zZRJXCgpHZXRCYWxhbmNlEiMud2FsbGV0bW'
    'FuYWdlci52MS5HZXRCYWxhbmNlUmVxdWVzdBokLndhbGxldG1hbmFnZXIudjEuR2V0QmFsYW5j'
    'ZVJlc3BvbnNlEmAKDUdldE5ld0FkZHJlc3MSJi53YWxsZXRtYW5hZ2VyLnYxLkdldE5ld0FkZH'
    'Jlc3NSZXF1ZXN0Gicud2FsbGV0bWFuYWdlci52MS5HZXROZXdBZGRyZXNzUmVzcG9uc2USZgoP'
    'U2VuZFRyYW5zYWN0aW9uEigud2FsbGV0bWFuYWdlci52MS5TZW5kVHJhbnNhY3Rpb25SZXF1ZX'
    'N0Gikud2FsbGV0bWFuYWdlci52MS5TZW5kVHJhbnNhY3Rpb25SZXNwb25zZRJpChBMaXN0VHJh'
    'bnNhY3Rpb25zEikud2FsbGV0bWFuYWdlci52MS5MaXN0VHJhbnNhY3Rpb25zUmVxdWVzdBoqLn'
    'dhbGxldG1hbmFnZXIudjEuTGlzdFRyYW5zYWN0aW9uc1Jlc3BvbnNlEloKC0xpc3RVbnNwZW50'
    'EiQud2FsbGV0bWFuYWdlci52MS5MaXN0VW5zcGVudFJlcXVlc3QaJS53YWxsZXRtYW5hZ2VyLn'
    'YxLkxpc3RVbnNwZW50UmVzcG9uc2USdQoUTGlzdFJlY2VpdmVBZGRyZXNzZXMSLS53YWxsZXRt'
    'YW5hZ2VyLnYxLkxpc3RSZWNlaXZlQWRkcmVzc2VzUmVxdWVzdBouLndhbGxldG1hbmFnZXIudj'
    'EuTGlzdFJlY2VpdmVBZGRyZXNzZXNSZXNwb25zZRJ4ChVHZXRUcmFuc2FjdGlvbkRldGFpbHMS'
    'Li53YWxsZXRtYW5hZ2VyLnYxLkdldFRyYW5zYWN0aW9uRGV0YWlsc1JlcXVlc3QaLy53YWxsZX'
    'RtYW5hZ2VyLnYxLkdldFRyYW5zYWN0aW9uRGV0YWlsc1Jlc3BvbnNlEk4KB0J1bXBGZWUSIC53'
    'YWxsZXRtYW5hZ2VyLnYxLkJ1bXBGZWVSZXF1ZXN0GiEud2FsbGV0bWFuYWdlci52MS5CdW1wRm'
    'VlUmVzcG9uc2USZgoPRGVyaXZlQWRkcmVzc2VzEigud2FsbGV0bWFuYWdlci52MS5EZXJpdmVB'
    'ZGRyZXNzZXNSZXF1ZXN0Gikud2FsbGV0bWFuYWdlci52MS5EZXJpdmVBZGRyZXNzZXNSZXNwb2'
    '5zZRJgCg1HZXRXYWxsZXRTZWVkEiYud2FsbGV0bWFuYWdlci52MS5HZXRXYWxsZXRTZWVkUmVx'
    'dWVzdBonLndhbGxldG1hbmFnZXIudjEuR2V0V2FsbGV0U2VlZFJlc3BvbnNlEmkKEExpc3RDb3'
    'JlVmFyaWFudHMSKS53YWxsZXRtYW5hZ2VyLnYxLkxpc3RDb3JlVmFyaWFudHNSZXF1ZXN0Giou'
    'd2FsbGV0bWFuYWdlci52MS5MaXN0Q29yZVZhcmlhbnRzUmVzcG9uc2USYwoOR2V0Q29yZVZhcm'
    'lhbnQSJy53YWxsZXRtYW5hZ2VyLnYxLkdldENvcmVWYXJpYW50UmVxdWVzdBooLndhbGxldG1h'
    'bmFnZXIudjEuR2V0Q29yZVZhcmlhbnRSZXNwb25zZRJjCg5TZXRDb3JlVmFyaWFudBInLndhbG'
    'xldG1hbmFnZXIudjEuU2V0Q29yZVZhcmlhbnRSZXF1ZXN0Gigud2FsbGV0bWFuYWdlci52MS5T'
    'ZXRDb3JlVmFyaWFudFJlc3BvbnNlElYKD1dhdGNoV2FsbGV0RGF0YRIWLmdvb2dsZS5wcm90b2'
    'J1Zi5FbXB0eRopLndhbGxldG1hbmFnZXIudjEuV2F0Y2hXYWxsZXREYXRhUmVzcG9uc2UwAQ==');

