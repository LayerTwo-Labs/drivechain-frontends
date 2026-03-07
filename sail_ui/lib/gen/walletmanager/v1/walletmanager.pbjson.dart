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
  ],
};

/// Descriptor for `WalletMetadata`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List walletMetadataDescriptor = $convert.base64Decode(
    'Cg5XYWxsZXRNZXRhZGF0YRIOCgJpZBgBIAEoCVICaWQSEgoEbmFtZRgCIAEoCVIEbmFtZRIfCg'
    't3YWxsZXRfdHlwZRgDIAEoCVIKd2FsbGV0VHlwZRIjCg1ncmFkaWVudF9qc29uGAQgASgJUgxn'
    'cmFkaWVudEpzb24SHQoKY3JlYXRlZF9hdBgFIAEoCVIJY3JlYXRlZEF0');

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
  '.walletmanager.v1.SwitchWalletRequest': SwitchWalletRequest$json,
  '.walletmanager.v1.SwitchWalletResponse': SwitchWalletResponse$json,
  '.walletmanager.v1.UpdateWalletMetadataRequest': UpdateWalletMetadataRequest$json,
  '.walletmanager.v1.UpdateWalletMetadataResponse': UpdateWalletMetadataResponse$json,
  '.walletmanager.v1.DeleteWalletRequest': DeleteWalletRequest$json,
  '.walletmanager.v1.DeleteWalletResponse': DeleteWalletResponse$json,
  '.walletmanager.v1.DeleteAllWalletsRequest': DeleteAllWalletsRequest$json,
  '.walletmanager.v1.DeleteAllWalletsResponse': DeleteAllWalletsResponse$json,
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
    'b25zZQ==');

