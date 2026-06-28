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
};

/// Descriptor for `MultisigLoungeService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List multisigLoungeServiceDescriptor = $convert.base64Decode(
    'ChVNdWx0aXNpZ0xvdW5nZVNlcnZpY2USawoQQnVpbGREZXNjcmlwdG9ycxIqLm11bHRpc2lnbG'
    '91bmdlLnYxLkJ1aWxkRGVzY3JpcHRvcnNSZXF1ZXN0GisubXVsdGlzaWdsb3VuZ2UudjEuQnVp'
    'bGREZXNjcmlwdG9yc1Jlc3BvbnNlEl8KDFZhbGlkYXRlUHNidBImLm11bHRpc2lnbG91bmdlLn'
    'YxLlZhbGlkYXRlUHNidFJlcXVlc3QaJy5tdWx0aXNpZ2xvdW5nZS52MS5WYWxpZGF0ZVBzYnRS'
    'ZXNwb25zZQ==');

