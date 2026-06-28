//
//  Generated code. Do not modify.
//  source: multisiglounge/v1/multisiglounge.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use signTransactionRequestDescriptor instead')
const SignTransactionRequest$json = {
  '1': 'SignTransactionRequest',
  '2': [
    {'1': 'psbt_base64', '3': 1, '4': 1, '5': 9, '10': 'psbtBase64'},
    {'1': 'group', '3': 2, '4': 1, '5': 11, '6': '.multisiglounge.v1.GroupData', '10': 'group'},
    {'1': 'wallet_id', '3': 3, '4': 1, '5': 9, '10': 'walletId'},
  ],
};

/// Descriptor for `SignTransactionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List signTransactionRequestDescriptor = $convert.base64Decode(
    'ChZTaWduVHJhbnNhY3Rpb25SZXF1ZXN0Eh8KC3BzYnRfYmFzZTY0GAEgASgJUgpwc2J0QmFzZT'
    'Y0EjIKBWdyb3VwGAIgASgLMhwubXVsdGlzaWdsb3VuZ2UudjEuR3JvdXBEYXRhUgVncm91cBIb'
    'Cgl3YWxsZXRfaWQYAyABKAlSCHdhbGxldElk');

@$core.Deprecated('Use signTransactionResponseDescriptor instead')
const SignTransactionResponse$json = {
  '1': 'SignTransactionResponse',
  '2': [
    {'1': 'psbt_base64', '3': 1, '4': 1, '5': 9, '10': 'psbtBase64'},
    {'1': 'added_signatures', '3': 2, '4': 1, '5': 13, '10': 'addedSignatures'},
    {'1': 'is_complete', '3': 3, '4': 1, '5': 8, '10': 'isComplete'},
  ],
};

/// Descriptor for `SignTransactionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List signTransactionResponseDescriptor = $convert.base64Decode(
    'ChdTaWduVHJhbnNhY3Rpb25SZXNwb25zZRIfCgtwc2J0X2Jhc2U2NBgBIAEoCVIKcHNidEJhc2'
    'U2NBIpChBhZGRlZF9zaWduYXR1cmVzGAIgASgNUg9hZGRlZFNpZ25hdHVyZXMSHwoLaXNfY29t'
    'cGxldGUYAyABKAhSCmlzQ29tcGxldGU=');

@$core.Deprecated('Use combineAndBroadcastRequestDescriptor instead')
const CombineAndBroadcastRequest$json = {
  '1': 'CombineAndBroadcastRequest',
  '2': [
    {'1': 'psbts', '3': 1, '4': 3, '5': 9, '10': 'psbts'},
    {'1': 'group', '3': 2, '4': 1, '5': 11, '6': '.multisiglounge.v1.GroupData', '10': 'group'},
  ],
};

/// Descriptor for `CombineAndBroadcastRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List combineAndBroadcastRequestDescriptor = $convert.base64Decode(
    'ChpDb21iaW5lQW5kQnJvYWRjYXN0UmVxdWVzdBIUCgVwc2J0cxgBIAMoCVIFcHNidHMSMgoFZ3'
    'JvdXAYAiABKAsyHC5tdWx0aXNpZ2xvdW5nZS52MS5Hcm91cERhdGFSBWdyb3Vw');

@$core.Deprecated('Use combineAndBroadcastResponseDescriptor instead')
const CombineAndBroadcastResponse$json = {
  '1': 'CombineAndBroadcastResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `CombineAndBroadcastResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List combineAndBroadcastResponseDescriptor = $convert.base64Decode(
    'ChtDb21iaW5lQW5kQnJvYWRjYXN0UmVzcG9uc2USEgoEdHhpZBgBIAEoCVIEdHhpZA==');

@$core.Deprecated('Use groupKeyDescriptor instead')
const GroupKey$json = {
  '1': 'GroupKey',
  '2': [
    {'1': 'owner', '3': 1, '4': 1, '5': 9, '10': 'owner'},
    {'1': 'xpub', '3': 2, '4': 1, '5': 9, '10': 'xpub'},
    {'1': 'derivation_path', '3': 3, '4': 1, '5': 9, '10': 'derivationPath'},
    {'1': 'fingerprint', '3': 4, '4': 1, '5': 9, '10': 'fingerprint'},
    {'1': 'origin_path', '3': 5, '4': 1, '5': 9, '10': 'originPath'},
    {'1': 'is_wallet', '3': 6, '4': 1, '5': 8, '10': 'isWallet'},
  ],
};

/// Descriptor for `GroupKey`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupKeyDescriptor = $convert.base64Decode(
    'CghHcm91cEtleRIUCgVvd25lchgBIAEoCVIFb3duZXISEgoEeHB1YhgCIAEoCVIEeHB1YhInCg'
    '9kZXJpdmF0aW9uX3BhdGgYAyABKAlSDmRlcml2YXRpb25QYXRoEiAKC2ZpbmdlcnByaW50GAQg'
    'ASgJUgtmaW5nZXJwcmludBIfCgtvcmlnaW5fcGF0aBgFIAEoCVIKb3JpZ2luUGF0aBIbCglpc1'
    '93YWxsZXQYBiABKAhSCGlzV2FsbGV0');

@$core.Deprecated('Use groupDataDescriptor instead')
const GroupData$json = {
  '1': 'GroupData',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'n', '3': 3, '4': 1, '5': 13, '10': 'n'},
    {'1': 'm', '3': 4, '4': 1, '5': 13, '10': 'm'},
    {'1': 'keys', '3': 5, '4': 3, '5': 11, '6': '.multisiglounge.v1.GroupKey', '10': 'keys'},
    {'1': 'created', '3': 6, '4': 1, '5': 3, '10': 'created'},
    {'1': 'descriptor_receive', '3': 7, '4': 1, '5': 9, '10': 'descriptorReceive'},
    {'1': 'descriptor_change', '3': 8, '4': 1, '5': 9, '10': 'descriptorChange'},
    {'1': 'watch_wallet_name', '3': 9, '4': 1, '5': 9, '10': 'watchWalletName'},
    {'1': 'txid', '3': 10, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `GroupData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupDataDescriptor = $convert.base64Decode(
    'CglHcm91cERhdGESDgoCaWQYASABKAlSAmlkEhIKBG5hbWUYAiABKAlSBG5hbWUSDAoBbhgDIA'
    'EoDVIBbhIMCgFtGAQgASgNUgFtEi8KBGtleXMYBSADKAsyGy5tdWx0aXNpZ2xvdW5nZS52MS5H'
    'cm91cEtleVIEa2V5cxIYCgdjcmVhdGVkGAYgASgDUgdjcmVhdGVkEi0KEmRlc2NyaXB0b3Jfcm'
    'VjZWl2ZRgHIAEoCVIRZGVzY3JpcHRvclJlY2VpdmUSKwoRZGVzY3JpcHRvcl9jaGFuZ2UYCCAB'
    'KAlSEGRlc2NyaXB0b3JDaGFuZ2USKgoRd2F0Y2hfd2FsbGV0X25hbWUYCSABKAlSD3dhdGNoV2'
    'FsbGV0TmFtZRISCgR0eGlkGAogASgJUgR0eGlk');

@$core.Deprecated('Use publishGroupRequestDescriptor instead')
const PublishGroupRequest$json = {
  '1': 'PublishGroupRequest',
  '2': [
    {'1': 'group', '3': 1, '4': 1, '5': 11, '6': '.multisiglounge.v1.GroupData', '10': 'group'},
    {'1': 'wallet_id', '3': 2, '4': 1, '5': 9, '10': 'walletId'},
  ],
};

/// Descriptor for `PublishGroupRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List publishGroupRequestDescriptor = $convert.base64Decode(
    'ChNQdWJsaXNoR3JvdXBSZXF1ZXN0EjIKBWdyb3VwGAEgASgLMhwubXVsdGlzaWdsb3VuZ2Uudj'
    'EuR3JvdXBEYXRhUgVncm91cBIbCgl3YWxsZXRfaWQYAiABKAlSCHdhbGxldElk');

@$core.Deprecated('Use publishGroupResponseDescriptor instead')
const PublishGroupResponse$json = {
  '1': 'PublishGroupResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `PublishGroupResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List publishGroupResponseDescriptor = $convert.base64Decode(
    'ChRQdWJsaXNoR3JvdXBSZXNwb25zZRISCgR0eGlkGAEgASgJUgR0eGlk');

@$core.Deprecated('Use importGroupFromTxidRequestDescriptor instead')
const ImportGroupFromTxidRequest$json = {
  '1': 'ImportGroupFromTxidRequest',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'wallet_id', '3': 2, '4': 1, '5': 9, '10': 'walletId'},
  ],
};

/// Descriptor for `ImportGroupFromTxidRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importGroupFromTxidRequestDescriptor = $convert.base64Decode(
    'ChpJbXBvcnRHcm91cEZyb21UeGlkUmVxdWVzdBISCgR0eGlkGAEgASgJUgR0eGlkEhsKCXdhbG'
    'xldF9pZBgCIAEoCVIId2FsbGV0SWQ=');

@$core.Deprecated('Use importGroupFromTxidResponseDescriptor instead')
const ImportGroupFromTxidResponse$json = {
  '1': 'ImportGroupFromTxidResponse',
  '2': [
    {'1': 'group', '3': 1, '4': 1, '5': 11, '6': '.multisiglounge.v1.GroupData', '10': 'group'},
    {'1': 'wallet_key_indices', '3': 2, '4': 3, '5': 13, '10': 'walletKeyIndices'},
  ],
};

/// Descriptor for `ImportGroupFromTxidResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importGroupFromTxidResponseDescriptor = $convert.base64Decode(
    'ChtJbXBvcnRHcm91cEZyb21UeGlkUmVzcG9uc2USMgoFZ3JvdXAYASABKAsyHC5tdWx0aXNpZ2'
    'xvdW5nZS52MS5Hcm91cERhdGFSBWdyb3VwEiwKEndhbGxldF9rZXlfaW5kaWNlcxgCIAMoDVIQ'
    'd2FsbGV0S2V5SW5kaWNlcw==');

@$core.Deprecated('Use multisigKeyDescriptor instead')
const MultisigKey$json = {
  '1': 'MultisigKey',
  '2': [
    {'1': 'xpub', '3': 1, '4': 1, '5': 9, '10': 'xpub'},
    {'1': 'derivation_path', '3': 2, '4': 1, '5': 9, '10': 'derivationPath'},
    {'1': 'fingerprint', '3': 3, '4': 1, '5': 9, '10': 'fingerprint'},
    {'1': 'origin_path', '3': 4, '4': 1, '5': 9, '10': 'originPath'},
    {'1': 'is_wallet', '3': 5, '4': 1, '5': 8, '10': 'isWallet'},
  ],
};

/// Descriptor for `MultisigKey`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List multisigKeyDescriptor = $convert.base64Decode(
    'CgtNdWx0aXNpZ0tleRISCgR4cHViGAEgASgJUgR4cHViEicKD2Rlcml2YXRpb25fcGF0aBgCIA'
    'EoCVIOZGVyaXZhdGlvblBhdGgSIAoLZmluZ2VycHJpbnQYAyABKAlSC2ZpbmdlcnByaW50Eh8K'
    'C29yaWdpbl9wYXRoGAQgASgJUgpvcmlnaW5QYXRoEhsKCWlzX3dhbGxldBgFIAEoCFIIaXNXYW'
    'xsZXQ=');

@$core.Deprecated('Use multisigGroupDescriptor instead')
const MultisigGroup$json = {
  '1': 'MultisigGroup',
  '2': [
    {'1': 'm', '3': 1, '4': 1, '5': 13, '10': 'm'},
    {'1': 'n', '3': 2, '4': 1, '5': 13, '10': 'n'},
    {'1': 'keys', '3': 3, '4': 3, '5': 11, '6': '.multisiglounge.v1.MultisigKey', '10': 'keys'},
  ],
};

/// Descriptor for `MultisigGroup`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List multisigGroupDescriptor = $convert.base64Decode(
    'Cg1NdWx0aXNpZ0dyb3VwEgwKAW0YASABKA1SAW0SDAoBbhgCIAEoDVIBbhIyCgRrZXlzGAMgAy'
    'gLMh4ubXVsdGlzaWdsb3VuZ2UudjEuTXVsdGlzaWdLZXlSBGtleXM=');

@$core.Deprecated('Use buildDescriptorsRequestDescriptor instead')
const BuildDescriptorsRequest$json = {
  '1': 'BuildDescriptorsRequest',
  '2': [
    {'1': 'group', '3': 1, '4': 1, '5': 11, '6': '.multisiglounge.v1.MultisigGroup', '10': 'group'},
  ],
};

/// Descriptor for `BuildDescriptorsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List buildDescriptorsRequestDescriptor = $convert.base64Decode(
    'ChdCdWlsZERlc2NyaXB0b3JzUmVxdWVzdBI2CgVncm91cBgBIAEoCzIgLm11bHRpc2lnbG91bm'
    'dlLnYxLk11bHRpc2lnR3JvdXBSBWdyb3Vw');

@$core.Deprecated('Use buildDescriptorsResponseDescriptor instead')
const BuildDescriptorsResponse$json = {
  '1': 'BuildDescriptorsResponse',
  '2': [
    {'1': 'receive_descriptor', '3': 1, '4': 1, '5': 9, '10': 'receiveDescriptor'},
    {'1': 'change_descriptor', '3': 2, '4': 1, '5': 9, '10': 'changeDescriptor'},
  ],
};

/// Descriptor for `BuildDescriptorsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List buildDescriptorsResponseDescriptor = $convert.base64Decode(
    'ChhCdWlsZERlc2NyaXB0b3JzUmVzcG9uc2USLQoScmVjZWl2ZV9kZXNjcmlwdG9yGAEgASgJUh'
    'FyZWNlaXZlRGVzY3JpcHRvchIrChFjaGFuZ2VfZGVzY3JpcHRvchgCIAEoCVIQY2hhbmdlRGVz'
    'Y3JpcHRvcg==');

@$core.Deprecated('Use validatePsbtRequestDescriptor instead')
const ValidatePsbtRequest$json = {
  '1': 'ValidatePsbtRequest',
  '2': [
    {'1': 'psbt_base64', '3': 1, '4': 1, '5': 9, '10': 'psbtBase64'},
    {'1': 'required_sigs', '3': 2, '4': 1, '5': 13, '10': 'requiredSigs'},
    {'1': 'group', '3': 3, '4': 1, '5': 11, '6': '.multisiglounge.v1.MultisigGroup', '10': 'group'},
  ],
};

/// Descriptor for `ValidatePsbtRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List validatePsbtRequestDescriptor = $convert.base64Decode(
    'ChNWYWxpZGF0ZVBzYnRSZXF1ZXN0Eh8KC3BzYnRfYmFzZTY0GAEgASgJUgpwc2J0QmFzZTY0Ei'
    'MKDXJlcXVpcmVkX3NpZ3MYAiABKA1SDHJlcXVpcmVkU2lncxI2CgVncm91cBgDIAEoCzIgLm11'
    'bHRpc2lnbG91bmdlLnYxLk11bHRpc2lnR3JvdXBSBWdyb3Vw');

@$core.Deprecated('Use validatePsbtResponseDescriptor instead')
const ValidatePsbtResponse$json = {
  '1': 'ValidatePsbtResponse',
  '2': [
    {'1': 'has_signatures', '3': 1, '4': 1, '5': 8, '10': 'hasSignatures'},
    {'1': 'signature_count', '3': 2, '4': 1, '5': 13, '10': 'signatureCount'},
    {'1': 'is_complete', '3': 3, '4': 1, '5': 8, '10': 'isComplete'},
    {'1': 'finalizable', '3': 4, '4': 1, '5': 8, '10': 'finalizable'},
    {'1': 'error', '3': 5, '4': 1, '5': 9, '10': 'error'},
  ],
};

/// Descriptor for `ValidatePsbtResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List validatePsbtResponseDescriptor = $convert.base64Decode(
    'ChRWYWxpZGF0ZVBzYnRSZXNwb25zZRIlCg5oYXNfc2lnbmF0dXJlcxgBIAEoCFINaGFzU2lnbm'
    'F0dXJlcxInCg9zaWduYXR1cmVfY291bnQYAiABKA1SDnNpZ25hdHVyZUNvdW50Eh8KC2lzX2Nv'
    'bXBsZXRlGAMgASgIUgppc0NvbXBsZXRlEiAKC2ZpbmFsaXphYmxlGAQgASgIUgtmaW5hbGl6YW'
    'JsZRIUCgVlcnJvchgFIAEoCVIFZXJyb3I=');

const $core.Map<$core.String, $core.dynamic> MultisigLoungeServiceBase$json = {
  '1': 'MultisigLoungeService',
  '2': [
    {'1': 'BuildDescriptors', '2': '.multisiglounge.v1.BuildDescriptorsRequest', '3': '.multisiglounge.v1.BuildDescriptorsResponse'},
    {'1': 'ValidatePsbt', '2': '.multisiglounge.v1.ValidatePsbtRequest', '3': '.multisiglounge.v1.ValidatePsbtResponse'},
    {'1': 'PublishGroup', '2': '.multisiglounge.v1.PublishGroupRequest', '3': '.multisiglounge.v1.PublishGroupResponse'},
    {'1': 'ImportGroupFromTxid', '2': '.multisiglounge.v1.ImportGroupFromTxidRequest', '3': '.multisiglounge.v1.ImportGroupFromTxidResponse'},
    {'1': 'SignTransaction', '2': '.multisiglounge.v1.SignTransactionRequest', '3': '.multisiglounge.v1.SignTransactionResponse'},
    {'1': 'CombineAndBroadcast', '2': '.multisiglounge.v1.CombineAndBroadcastRequest', '3': '.multisiglounge.v1.CombineAndBroadcastResponse'},
  ],
};

@$core.Deprecated('Use multisigLoungeServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> MultisigLoungeServiceBase$messageJson = {
  '.multisiglounge.v1.BuildDescriptorsRequest': BuildDescriptorsRequest$json,
  '.multisiglounge.v1.MultisigGroup': MultisigGroup$json,
  '.multisiglounge.v1.MultisigKey': MultisigKey$json,
  '.multisiglounge.v1.BuildDescriptorsResponse': BuildDescriptorsResponse$json,
  '.multisiglounge.v1.ValidatePsbtRequest': ValidatePsbtRequest$json,
  '.multisiglounge.v1.ValidatePsbtResponse': ValidatePsbtResponse$json,
  '.multisiglounge.v1.PublishGroupRequest': PublishGroupRequest$json,
  '.multisiglounge.v1.GroupData': GroupData$json,
  '.multisiglounge.v1.GroupKey': GroupKey$json,
  '.multisiglounge.v1.PublishGroupResponse': PublishGroupResponse$json,
  '.multisiglounge.v1.ImportGroupFromTxidRequest': ImportGroupFromTxidRequest$json,
  '.multisiglounge.v1.ImportGroupFromTxidResponse': ImportGroupFromTxidResponse$json,
  '.multisiglounge.v1.SignTransactionRequest': SignTransactionRequest$json,
  '.multisiglounge.v1.SignTransactionResponse': SignTransactionResponse$json,
  '.multisiglounge.v1.CombineAndBroadcastRequest': CombineAndBroadcastRequest$json,
  '.multisiglounge.v1.CombineAndBroadcastResponse': CombineAndBroadcastResponse$json,
};

/// Descriptor for `MultisigLoungeService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List multisigLoungeServiceDescriptor = $convert.base64Decode(
    'ChVNdWx0aXNpZ0xvdW5nZVNlcnZpY2USawoQQnVpbGREZXNjcmlwdG9ycxIqLm11bHRpc2lnbG'
    '91bmdlLnYxLkJ1aWxkRGVzY3JpcHRvcnNSZXF1ZXN0GisubXVsdGlzaWdsb3VuZ2UudjEuQnVp'
    'bGREZXNjcmlwdG9yc1Jlc3BvbnNlEl8KDFZhbGlkYXRlUHNidBImLm11bHRpc2lnbG91bmdlLn'
    'YxLlZhbGlkYXRlUHNidFJlcXVlc3QaJy5tdWx0aXNpZ2xvdW5nZS52MS5WYWxpZGF0ZVBzYnRS'
    'ZXNwb25zZRJfCgxQdWJsaXNoR3JvdXASJi5tdWx0aXNpZ2xvdW5nZS52MS5QdWJsaXNoR3JvdX'
    'BSZXF1ZXN0GicubXVsdGlzaWdsb3VuZ2UudjEuUHVibGlzaEdyb3VwUmVzcG9uc2USdAoTSW1w'
    'b3J0R3JvdXBGcm9tVHhpZBItLm11bHRpc2lnbG91bmdlLnYxLkltcG9ydEdyb3VwRnJvbVR4aW'
    'RSZXF1ZXN0Gi4ubXVsdGlzaWdsb3VuZ2UudjEuSW1wb3J0R3JvdXBGcm9tVHhpZFJlc3BvbnNl'
    'EmgKD1NpZ25UcmFuc2FjdGlvbhIpLm11bHRpc2lnbG91bmdlLnYxLlNpZ25UcmFuc2FjdGlvbl'
    'JlcXVlc3QaKi5tdWx0aXNpZ2xvdW5nZS52MS5TaWduVHJhbnNhY3Rpb25SZXNwb25zZRJ0ChND'
    'b21iaW5lQW5kQnJvYWRjYXN0Ei0ubXVsdGlzaWdsb3VuZ2UudjEuQ29tYmluZUFuZEJyb2FkY2'
    'FzdFJlcXVlc3QaLi5tdWx0aXNpZ2xvdW5nZS52MS5Db21iaW5lQW5kQnJvYWRjYXN0UmVzcG9u'
    'c2U=');

