//
//  Generated code. Do not modify.
//  source: multisig/v1/multisig.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use addMultisigAddressRequestDescriptor instead')
const AddMultisigAddressRequest$json = {
  '1': 'AddMultisigAddressRequest',
  '2': [
    {'1': 'n_required', '3': 1, '4': 1, '5': 5, '10': 'nRequired'},
    {'1': 'keys', '3': 2, '4': 3, '5': 9, '10': 'keys'},
    {'1': 'label', '3': 3, '4': 1, '5': 9, '10': 'label'},
  ],
};

/// Descriptor for `AddMultisigAddressRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addMultisigAddressRequestDescriptor = $convert.base64Decode(
    'ChlBZGRNdWx0aXNpZ0FkZHJlc3NSZXF1ZXN0Eh0KCm5fcmVxdWlyZWQYASABKAVSCW5SZXF1aX'
    'JlZBISCgRrZXlzGAIgAygJUgRrZXlzEhQKBWxhYmVsGAMgASgJUgVsYWJlbA==');

@$core.Deprecated('Use addMultisigAddressResponseDescriptor instead')
const AddMultisigAddressResponse$json = {
  '1': 'AddMultisigAddressResponse',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'redeem_script', '3': 2, '4': 1, '5': 9, '10': 'redeemScript'},
    {'1': 'descriptor', '3': 3, '4': 1, '5': 9, '10': 'descriptor'},
  ],
};

/// Descriptor for `AddMultisigAddressResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addMultisigAddressResponseDescriptor = $convert.base64Decode(
    'ChpBZGRNdWx0aXNpZ0FkZHJlc3NSZXNwb25zZRIYCgdhZGRyZXNzGAEgASgJUgdhZGRyZXNzEi'
    'MKDXJlZGVlbV9zY3JpcHQYAiABKAlSDHJlZGVlbVNjcmlwdBIeCgpkZXNjcmlwdG9yGAMgASgJ'
    'UgpkZXNjcmlwdG9y');

@$core.Deprecated('Use importAddressRequestDescriptor instead')
const ImportAddressRequest$json = {
  '1': 'ImportAddressRequest',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'label', '3': 2, '4': 1, '5': 9, '10': 'label'},
    {'1': 'rescan', '3': 3, '4': 1, '5': 8, '10': 'rescan'},
  ],
};

/// Descriptor for `ImportAddressRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importAddressRequestDescriptor = $convert.base64Decode(
    'ChRJbXBvcnRBZGRyZXNzUmVxdWVzdBIYCgdhZGRyZXNzGAEgASgJUgdhZGRyZXNzEhQKBWxhYm'
    'VsGAIgASgJUgVsYWJlbBIWCgZyZXNjYW4YAyABKAhSBnJlc2Nhbg==');

@$core.Deprecated('Use importAddressResponseDescriptor instead')
const ImportAddressResponse$json = {
  '1': 'ImportAddressResponse',
};

/// Descriptor for `ImportAddressResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importAddressResponseDescriptor = $convert.base64Decode(
    'ChVJbXBvcnRBZGRyZXNzUmVzcG9uc2U=');

@$core.Deprecated('Use getAddressInfoRequestDescriptor instead')
const GetAddressInfoRequest$json = {
  '1': 'GetAddressInfoRequest',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
  ],
};

/// Descriptor for `GetAddressInfoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAddressInfoRequestDescriptor = $convert.base64Decode(
    'ChVHZXRBZGRyZXNzSW5mb1JlcXVlc3QSGAoHYWRkcmVzcxgBIAEoCVIHYWRkcmVzcw==');

@$core.Deprecated('Use getAddressInfoResponseDescriptor instead')
const GetAddressInfoResponse$json = {
  '1': 'GetAddressInfoResponse',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'script_pub_key', '3': 2, '4': 1, '5': 9, '10': 'scriptPubKey'},
    {'1': 'is_mine', '3': 3, '4': 1, '5': 8, '10': 'isMine'},
    {'1': 'is_watchonly', '3': 4, '4': 1, '5': 8, '10': 'isWatchonly'},
    {'1': 'solvable', '3': 5, '4': 1, '5': 8, '10': 'solvable'},
    {'1': 'desc', '3': 6, '4': 1, '5': 9, '10': 'desc'},
    {'1': 'is_script', '3': 7, '4': 1, '5': 8, '10': 'isScript'},
    {'1': 'is_change', '3': 8, '4': 1, '5': 8, '10': 'isChange'},
    {'1': 'is_witness', '3': 9, '4': 1, '5': 8, '10': 'isWitness'},
    {'1': 'witness_version', '3': 10, '4': 1, '5': 5, '10': 'witnessVersion'},
    {'1': 'witness_program', '3': 11, '4': 1, '5': 9, '10': 'witnessProgram'},
    {'1': 'script', '3': 12, '4': 1, '5': 9, '10': 'script'},
    {'1': 'hex', '3': 13, '4': 1, '5': 9, '10': 'hex'},
    {'1': 'pubkeys', '3': 14, '4': 3, '5': 9, '10': 'pubkeys'},
    {'1': 'sigs_required', '3': 15, '4': 1, '5': 5, '10': 'sigsRequired'},
    {'1': 'pubkey', '3': 16, '4': 1, '5': 9, '10': 'pubkey'},
    {'1': 'is_compressed', '3': 17, '4': 1, '5': 8, '10': 'isCompressed'},
    {'1': 'label', '3': 18, '4': 1, '5': 9, '10': 'label'},
    {'1': 'timestamp', '3': 19, '4': 1, '5': 3, '10': 'timestamp'},
    {'1': 'hd_key_path', '3': 20, '4': 1, '5': 9, '10': 'hdKeyPath'},
    {'1': 'hd_seed_id', '3': 21, '4': 1, '5': 9, '10': 'hdSeedId'},
    {'1': 'hd_fingerprint', '3': 22, '4': 1, '5': 9, '10': 'hdFingerprint'},
    {'1': 'labels', '3': 23, '4': 3, '5': 9, '10': 'labels'},
  ],
};

/// Descriptor for `GetAddressInfoResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAddressInfoResponseDescriptor = $convert.base64Decode(
    'ChZHZXRBZGRyZXNzSW5mb1Jlc3BvbnNlEhgKB2FkZHJlc3MYASABKAlSB2FkZHJlc3MSJAoOc2'
    'NyaXB0X3B1Yl9rZXkYAiABKAlSDHNjcmlwdFB1YktleRIXCgdpc19taW5lGAMgASgIUgZpc01p'
    'bmUSIQoMaXNfd2F0Y2hvbmx5GAQgASgIUgtpc1dhdGNob25seRIaCghzb2x2YWJsZRgFIAEoCF'
    'IIc29sdmFibGUSEgoEZGVzYxgGIAEoCVIEZGVzYxIbCglpc19zY3JpcHQYByABKAhSCGlzU2Ny'
    'aXB0EhsKCWlzX2NoYW5nZRgIIAEoCFIIaXNDaGFuZ2USHQoKaXNfd2l0bmVzcxgJIAEoCFIJaX'
    'NXaXRuZXNzEicKD3dpdG5lc3NfdmVyc2lvbhgKIAEoBVIOd2l0bmVzc1ZlcnNpb24SJwoPd2l0'
    'bmVzc19wcm9ncmFtGAsgASgJUg53aXRuZXNzUHJvZ3JhbRIWCgZzY3JpcHQYDCABKAlSBnNjcm'
    'lwdBIQCgNoZXgYDSABKAlSA2hleBIYCgdwdWJrZXlzGA4gAygJUgdwdWJrZXlzEiMKDXNpZ3Nf'
    'cmVxdWlyZWQYDyABKAVSDHNpZ3NSZXF1aXJlZBIWCgZwdWJrZXkYECABKAlSBnB1YmtleRIjCg'
    '1pc19jb21wcmVzc2VkGBEgASgIUgxpc0NvbXByZXNzZWQSFAoFbGFiZWwYEiABKAlSBWxhYmVs'
    'EhwKCXRpbWVzdGFtcBgTIAEoA1IJdGltZXN0YW1wEh4KC2hkX2tleV9wYXRoGBQgASgJUgloZE'
    'tleVBhdGgSHAoKaGRfc2VlZF9pZBgVIAEoCVIIaGRTZWVkSWQSJQoOaGRfZmluZ2VycHJpbnQY'
    'FiABKAlSDWhkRmluZ2VycHJpbnQSFgoGbGFiZWxzGBcgAygJUgZsYWJlbHM=');

@$core.Deprecated('Use listUnspentRequestDescriptor instead')
const ListUnspentRequest$json = {
  '1': 'ListUnspentRequest',
  '2': [
    {'1': 'min_conf', '3': 1, '4': 1, '5': 5, '10': 'minConf'},
    {'1': 'max_conf', '3': 2, '4': 1, '5': 5, '10': 'maxConf'},
    {'1': 'addresses', '3': 3, '4': 3, '5': 9, '10': 'addresses'},
  ],
};

/// Descriptor for `ListUnspentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listUnspentRequestDescriptor = $convert.base64Decode(
    'ChJMaXN0VW5zcGVudFJlcXVlc3QSGQoIbWluX2NvbmYYASABKAVSB21pbkNvbmYSGQoIbWF4X2'
    'NvbmYYAiABKAVSB21heENvbmYSHAoJYWRkcmVzc2VzGAMgAygJUglhZGRyZXNzZXM=');

@$core.Deprecated('Use listUnspentResponseDescriptor instead')
const ListUnspentResponse$json = {
  '1': 'ListUnspentResponse',
  '2': [
    {'1': 'utxos', '3': 1, '4': 3, '5': 11, '6': '.multisig.v1.Utxo', '10': 'utxos'},
  ],
};

/// Descriptor for `ListUnspentResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listUnspentResponseDescriptor = $convert.base64Decode(
    'ChNMaXN0VW5zcGVudFJlc3BvbnNlEicKBXV0eG9zGAEgAygLMhEubXVsdGlzaWcudjEuVXR4b1'
    'IFdXR4b3M=');

@$core.Deprecated('Use utxoDescriptor instead')
const Utxo$json = {
  '1': 'Utxo',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'vout', '3': 2, '4': 1, '5': 5, '10': 'vout'},
    {'1': 'address', '3': 3, '4': 1, '5': 9, '10': 'address'},
    {'1': 'label', '3': 4, '4': 1, '5': 9, '10': 'label'},
    {'1': 'script_pub_key', '3': 5, '4': 1, '5': 9, '10': 'scriptPubKey'},
    {'1': 'amount', '3': 6, '4': 1, '5': 3, '10': 'amount'},
    {'1': 'confirmations', '3': 7, '4': 1, '5': 5, '10': 'confirmations'},
    {'1': 'redeem_script', '3': 8, '4': 1, '5': 9, '10': 'redeemScript'},
    {'1': 'witness_script', '3': 9, '4': 1, '5': 9, '10': 'witnessScript'},
    {'1': 'spendable', '3': 10, '4': 1, '5': 8, '10': 'spendable'},
    {'1': 'solvable', '3': 11, '4': 1, '5': 8, '10': 'solvable'},
    {'1': 'reused', '3': 12, '4': 1, '5': 8, '10': 'reused'},
    {'1': 'desc', '3': 13, '4': 1, '5': 9, '10': 'desc'},
    {'1': 'safe', '3': 14, '4': 1, '5': 8, '10': 'safe'},
  ],
};

/// Descriptor for `Utxo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List utxoDescriptor = $convert.base64Decode(
    'CgRVdHhvEhIKBHR4aWQYASABKAlSBHR4aWQSEgoEdm91dBgCIAEoBVIEdm91dBIYCgdhZGRyZX'
    'NzGAMgASgJUgdhZGRyZXNzEhQKBWxhYmVsGAQgASgJUgVsYWJlbBIkCg5zY3JpcHRfcHViX2tl'
    'eRgFIAEoCVIMc2NyaXB0UHViS2V5EhYKBmFtb3VudBgGIAEoA1IGYW1vdW50EiQKDWNvbmZpcm'
    '1hdGlvbnMYByABKAVSDWNvbmZpcm1hdGlvbnMSIwoNcmVkZWVtX3NjcmlwdBgIIAEoCVIMcmVk'
    'ZWVtU2NyaXB0EiUKDndpdG5lc3Nfc2NyaXB0GAkgASgJUg13aXRuZXNzU2NyaXB0EhwKCXNwZW'
    '5kYWJsZRgKIAEoCFIJc3BlbmRhYmxlEhoKCHNvbHZhYmxlGAsgASgIUghzb2x2YWJsZRIWCgZy'
    'ZXVzZWQYDCABKAhSBnJldXNlZBISCgRkZXNjGA0gASgJUgRkZXNjEhIKBHNhZmUYDiABKAhSBH'
    'NhZmU=');

@$core.Deprecated('Use listAddressGroupingsRequestDescriptor instead')
const ListAddressGroupingsRequest$json = {
  '1': 'ListAddressGroupingsRequest',
};

/// Descriptor for `ListAddressGroupingsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listAddressGroupingsRequestDescriptor = $convert.base64Decode(
    'ChtMaXN0QWRkcmVzc0dyb3VwaW5nc1JlcXVlc3Q=');

@$core.Deprecated('Use listAddressGroupingsResponseDescriptor instead')
const ListAddressGroupingsResponse$json = {
  '1': 'ListAddressGroupingsResponse',
  '2': [
    {'1': 'groupings', '3': 1, '4': 3, '5': 11, '6': '.multisig.v1.AddressGrouping', '10': 'groupings'},
  ],
};

/// Descriptor for `ListAddressGroupingsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listAddressGroupingsResponseDescriptor = $convert.base64Decode(
    'ChxMaXN0QWRkcmVzc0dyb3VwaW5nc1Jlc3BvbnNlEjoKCWdyb3VwaW5ncxgBIAMoCzIcLm11bH'
    'Rpc2lnLnYxLkFkZHJlc3NHcm91cGluZ1IJZ3JvdXBpbmdz');

@$core.Deprecated('Use addressGroupingDescriptor instead')
const AddressGrouping$json = {
  '1': 'AddressGrouping',
  '2': [
    {'1': 'addresses', '3': 1, '4': 3, '5': 11, '6': '.multisig.v1.AddressInfo', '10': 'addresses'},
  ],
};

/// Descriptor for `AddressGrouping`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addressGroupingDescriptor = $convert.base64Decode(
    'Cg9BZGRyZXNzR3JvdXBpbmcSNgoJYWRkcmVzc2VzGAEgAygLMhgubXVsdGlzaWcudjEuQWRkcm'
    'Vzc0luZm9SCWFkZHJlc3Nlcw==');

@$core.Deprecated('Use addressInfoDescriptor instead')
const AddressInfo$json = {
  '1': 'AddressInfo',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'amount', '3': 2, '4': 1, '5': 3, '10': 'amount'},
    {'1': 'label', '3': 3, '4': 1, '5': 9, '10': 'label'},
  ],
};

/// Descriptor for `AddressInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addressInfoDescriptor = $convert.base64Decode(
    'CgtBZGRyZXNzSW5mbxIYCgdhZGRyZXNzGAEgASgJUgdhZGRyZXNzEhYKBmFtb3VudBgCIAEoA1'
    'IGYW1vdW50EhQKBWxhYmVsGAMgASgJUgVsYWJlbA==');

@$core.Deprecated('Use createRawTransactionRequestDescriptor instead')
const CreateRawTransactionRequest$json = {
  '1': 'CreateRawTransactionRequest',
  '2': [
    {'1': 'inputs', '3': 1, '4': 3, '5': 11, '6': '.multisig.v1.TxInput', '10': 'inputs'},
    {'1': 'outputs', '3': 2, '4': 3, '5': 11, '6': '.multisig.v1.TxOutput', '10': 'outputs'},
    {'1': 'locktime', '3': 3, '4': 1, '5': 5, '10': 'locktime'},
  ],
};

/// Descriptor for `CreateRawTransactionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createRawTransactionRequestDescriptor = $convert.base64Decode(
    'ChtDcmVhdGVSYXdUcmFuc2FjdGlvblJlcXVlc3QSLAoGaW5wdXRzGAEgAygLMhQubXVsdGlzaW'
    'cudjEuVHhJbnB1dFIGaW5wdXRzEi8KB291dHB1dHMYAiADKAsyFS5tdWx0aXNpZy52MS5UeE91'
    'dHB1dFIHb3V0cHV0cxIaCghsb2NrdGltZRgDIAEoBVIIbG9ja3RpbWU=');

@$core.Deprecated('Use txInputDescriptor instead')
const TxInput$json = {
  '1': 'TxInput',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'vout', '3': 2, '4': 1, '5': 5, '10': 'vout'},
    {'1': 'sequence', '3': 3, '4': 1, '5': 9, '10': 'sequence'},
  ],
};

/// Descriptor for `TxInput`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List txInputDescriptor = $convert.base64Decode(
    'CgdUeElucHV0EhIKBHR4aWQYASABKAlSBHR4aWQSEgoEdm91dBgCIAEoBVIEdm91dBIaCghzZX'
    'F1ZW5jZRgDIAEoCVIIc2VxdWVuY2U=');

@$core.Deprecated('Use txOutputDescriptor instead')
const TxOutput$json = {
  '1': 'TxOutput',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'amount', '3': 2, '4': 1, '5': 3, '10': 'amount'},
  ],
};

/// Descriptor for `TxOutput`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List txOutputDescriptor = $convert.base64Decode(
    'CghUeE91dHB1dBIYCgdhZGRyZXNzGAEgASgJUgdhZGRyZXNzEhYKBmFtb3VudBgCIAEoA1IGYW'
    '1vdW50');

@$core.Deprecated('Use createRawTransactionResponseDescriptor instead')
const CreateRawTransactionResponse$json = {
  '1': 'CreateRawTransactionResponse',
  '2': [
    {'1': 'hex', '3': 1, '4': 1, '5': 9, '10': 'hex'},
  ],
};

/// Descriptor for `CreateRawTransactionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createRawTransactionResponseDescriptor = $convert.base64Decode(
    'ChxDcmVhdGVSYXdUcmFuc2FjdGlvblJlc3BvbnNlEhAKA2hleBgBIAEoCVIDaGV4');

@$core.Deprecated('Use createPsbtRequestDescriptor instead')
const CreatePsbtRequest$json = {
  '1': 'CreatePsbtRequest',
  '2': [
    {'1': 'inputs', '3': 1, '4': 3, '5': 11, '6': '.multisig.v1.TxInput', '10': 'inputs'},
    {'1': 'outputs', '3': 2, '4': 3, '5': 11, '6': '.multisig.v1.TxOutput', '10': 'outputs'},
    {'1': 'locktime', '3': 3, '4': 1, '5': 5, '10': 'locktime'},
  ],
};

/// Descriptor for `CreatePsbtRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createPsbtRequestDescriptor = $convert.base64Decode(
    'ChFDcmVhdGVQc2J0UmVxdWVzdBIsCgZpbnB1dHMYASADKAsyFC5tdWx0aXNpZy52MS5UeElucH'
    'V0UgZpbnB1dHMSLwoHb3V0cHV0cxgCIAMoCzIVLm11bHRpc2lnLnYxLlR4T3V0cHV0UgdvdXRw'
    'dXRzEhoKCGxvY2t0aW1lGAMgASgFUghsb2NrdGltZQ==');

@$core.Deprecated('Use createPsbtResponseDescriptor instead')
const CreatePsbtResponse$json = {
  '1': 'CreatePsbtResponse',
  '2': [
    {'1': 'psbt', '3': 1, '4': 1, '5': 9, '10': 'psbt'},
  ],
};

/// Descriptor for `CreatePsbtResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createPsbtResponseDescriptor = $convert.base64Decode(
    'ChJDcmVhdGVQc2J0UmVzcG9uc2USEgoEcHNidBgBIAEoCVIEcHNidA==');

@$core.Deprecated('Use walletCreateFundedPsbtRequestDescriptor instead')
const WalletCreateFundedPsbtRequest$json = {
  '1': 'WalletCreateFundedPsbtRequest',
  '2': [
    {'1': 'inputs', '3': 1, '4': 3, '5': 11, '6': '.multisig.v1.TxInput', '10': 'inputs'},
    {'1': 'outputs', '3': 2, '4': 3, '5': 11, '6': '.multisig.v1.TxOutput', '10': 'outputs'},
    {'1': 'locktime', '3': 3, '4': 1, '5': 5, '10': 'locktime'},
    {'1': 'options', '3': 4, '4': 1, '5': 11, '6': '.multisig.v1.PsbtOptions', '10': 'options'},
  ],
};

/// Descriptor for `WalletCreateFundedPsbtRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List walletCreateFundedPsbtRequestDescriptor = $convert.base64Decode(
    'Ch1XYWxsZXRDcmVhdGVGdW5kZWRQc2J0UmVxdWVzdBIsCgZpbnB1dHMYASADKAsyFC5tdWx0aX'
    'NpZy52MS5UeElucHV0UgZpbnB1dHMSLwoHb3V0cHV0cxgCIAMoCzIVLm11bHRpc2lnLnYxLlR4'
    'T3V0cHV0UgdvdXRwdXRzEhoKCGxvY2t0aW1lGAMgASgFUghsb2NrdGltZRIyCgdvcHRpb25zGA'
    'QgASgLMhgubXVsdGlzaWcudjEuUHNidE9wdGlvbnNSB29wdGlvbnM=');

@$core.Deprecated('Use psbtOptionsDescriptor instead')
const PsbtOptions$json = {
  '1': 'PsbtOptions',
  '2': [
    {'1': 'include_watching', '3': 1, '4': 1, '5': 8, '10': 'includeWatching'},
    {'1': 'change_position', '3': 2, '4': 1, '5': 8, '10': 'changePosition'},
    {'1': 'change_address', '3': 3, '4': 1, '5': 5, '10': 'changeAddress'},
    {'1': 'include_unsafe', '3': 4, '4': 1, '5': 8, '10': 'includeUnsafe'},
    {'1': 'min_conf', '3': 5, '4': 1, '5': 5, '10': 'minConf'},
    {'1': 'max_conf', '3': 6, '4': 1, '5': 5, '10': 'maxConf'},
    {'1': 'subtract_fee_from_outputs', '3': 7, '4': 1, '5': 8, '10': 'subtractFeeFromOutputs'},
    {'1': 'replaceable', '3': 8, '4': 1, '5': 8, '10': 'replaceable'},
    {'1': 'conf_target', '3': 9, '4': 1, '5': 5, '10': 'confTarget'},
    {'1': 'estimate_mode', '3': 10, '4': 1, '5': 9, '10': 'estimateMode'},
  ],
};

/// Descriptor for `PsbtOptions`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List psbtOptionsDescriptor = $convert.base64Decode(
    'CgtQc2J0T3B0aW9ucxIpChBpbmNsdWRlX3dhdGNoaW5nGAEgASgIUg9pbmNsdWRlV2F0Y2hpbm'
    'cSJwoPY2hhbmdlX3Bvc2l0aW9uGAIgASgIUg5jaGFuZ2VQb3NpdGlvbhIlCg5jaGFuZ2VfYWRk'
    'cmVzcxgDIAEoBVINY2hhbmdlQWRkcmVzcxIlCg5pbmNsdWRlX3Vuc2FmZRgEIAEoCFINaW5jbH'
    'VkZVVuc2FmZRIZCghtaW5fY29uZhgFIAEoBVIHbWluQ29uZhIZCghtYXhfY29uZhgGIAEoBVIH'
    'bWF4Q29uZhI5ChlzdWJ0cmFjdF9mZWVfZnJvbV9vdXRwdXRzGAcgASgIUhZzdWJ0cmFjdEZlZU'
    'Zyb21PdXRwdXRzEiAKC3JlcGxhY2VhYmxlGAggASgIUgtyZXBsYWNlYWJsZRIfCgtjb25mX3Rh'
    'cmdldBgJIAEoBVIKY29uZlRhcmdldBIjCg1lc3RpbWF0ZV9tb2RlGAogASgJUgxlc3RpbWF0ZU'
    '1vZGU=');

@$core.Deprecated('Use walletCreateFundedPsbtResponseDescriptor instead')
const WalletCreateFundedPsbtResponse$json = {
  '1': 'WalletCreateFundedPsbtResponse',
  '2': [
    {'1': 'psbt', '3': 1, '4': 1, '5': 9, '10': 'psbt'},
    {'1': 'fee', '3': 2, '4': 1, '5': 3, '10': 'fee'},
    {'1': 'change_position', '3': 3, '4': 1, '5': 5, '10': 'changePosition'},
  ],
};

/// Descriptor for `WalletCreateFundedPsbtResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List walletCreateFundedPsbtResponseDescriptor = $convert.base64Decode(
    'Ch5XYWxsZXRDcmVhdGVGdW5kZWRQc2J0UmVzcG9uc2USEgoEcHNidBgBIAEoCVIEcHNidBIQCg'
    'NmZWUYAiABKANSA2ZlZRInCg9jaGFuZ2VfcG9zaXRpb24YAyABKAVSDmNoYW5nZVBvc2l0aW9u');

@$core.Deprecated('Use decodePsbtRequestDescriptor instead')
const DecodePsbtRequest$json = {
  '1': 'DecodePsbtRequest',
  '2': [
    {'1': 'psbt', '3': 1, '4': 1, '5': 9, '10': 'psbt'},
  ],
};

/// Descriptor for `DecodePsbtRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List decodePsbtRequestDescriptor = $convert.base64Decode(
    'ChFEZWNvZGVQc2J0UmVxdWVzdBISCgRwc2J0GAEgASgJUgRwc2J0');

@$core.Deprecated('Use decodePsbtResponseDescriptor instead')
const DecodePsbtResponse$json = {
  '1': 'DecodePsbtResponse',
  '2': [
    {'1': 'tx', '3': 1, '4': 1, '5': 9, '10': 'tx'},
    {'1': 'unknown', '3': 2, '4': 1, '5': 9, '10': 'unknown'},
    {'1': 'inputs', '3': 3, '4': 3, '5': 11, '6': '.multisig.v1.Input', '10': 'inputs'},
    {'1': 'outputs', '3': 4, '4': 3, '5': 11, '6': '.multisig.v1.Output', '10': 'outputs'},
    {'1': 'fee', '3': 5, '4': 1, '5': 5, '10': 'fee'},
  ],
};

/// Descriptor for `DecodePsbtResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List decodePsbtResponseDescriptor = $convert.base64Decode(
    'ChJEZWNvZGVQc2J0UmVzcG9uc2USDgoCdHgYASABKAlSAnR4EhgKB3Vua25vd24YAiABKAlSB3'
    'Vua25vd24SKgoGaW5wdXRzGAMgAygLMhIubXVsdGlzaWcudjEuSW5wdXRSBmlucHV0cxItCgdv'
    'dXRwdXRzGAQgAygLMhMubXVsdGlzaWcudjEuT3V0cHV0UgdvdXRwdXRzEhAKA2ZlZRgFIAEoBV'
    'IDZmVl');

@$core.Deprecated('Use inputDescriptor instead')
const Input$json = {
  '1': 'Input',
  '2': [
    {'1': 'non_witness_utxo', '3': 1, '4': 1, '5': 9, '10': 'nonWitnessUtxo'},
    {'1': 'witness_utxo', '3': 2, '4': 1, '5': 9, '10': 'witnessUtxo'},
    {'1': 'partial_signatures', '3': 3, '4': 1, '5': 9, '10': 'partialSignatures'},
    {'1': 'sighash', '3': 4, '4': 1, '5': 9, '10': 'sighash'},
    {'1': 'redeem_script', '3': 5, '4': 1, '5': 9, '10': 'redeemScript'},
    {'1': 'witness_script', '3': 6, '4': 1, '5': 9, '10': 'witnessScript'},
    {'1': 'bip32_derivs', '3': 7, '4': 1, '5': 9, '10': 'bip32Derivs'},
    {'1': 'final_scriptsig', '3': 8, '4': 1, '5': 9, '10': 'finalScriptsig'},
    {'1': 'final_scriptwitness', '3': 9, '4': 1, '5': 9, '10': 'finalScriptwitness'},
    {'1': 'unknown', '3': 10, '4': 1, '5': 9, '10': 'unknown'},
  ],
};

/// Descriptor for `Input`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List inputDescriptor = $convert.base64Decode(
    'CgVJbnB1dBIoChBub25fd2l0bmVzc191dHhvGAEgASgJUg5ub25XaXRuZXNzVXR4bxIhCgx3aX'
    'RuZXNzX3V0eG8YAiABKAlSC3dpdG5lc3NVdHhvEi0KEnBhcnRpYWxfc2lnbmF0dXJlcxgDIAEo'
    'CVIRcGFydGlhbFNpZ25hdHVyZXMSGAoHc2lnaGFzaBgEIAEoCVIHc2lnaGFzaBIjCg1yZWRlZW'
    '1fc2NyaXB0GAUgASgJUgxyZWRlZW1TY3JpcHQSJQoOd2l0bmVzc19zY3JpcHQYBiABKAlSDXdp'
    'dG5lc3NTY3JpcHQSIQoMYmlwMzJfZGVyaXZzGAcgASgJUgtiaXAzMkRlcml2cxInCg9maW5hbF'
    '9zY3JpcHRzaWcYCCABKAlSDmZpbmFsU2NyaXB0c2lnEi8KE2ZpbmFsX3NjcmlwdHdpdG5lc3MY'
    'CSABKAlSEmZpbmFsU2NyaXB0d2l0bmVzcxIYCgd1bmtub3duGAogASgJUgd1bmtub3du');

@$core.Deprecated('Use outputDescriptor instead')
const Output$json = {
  '1': 'Output',
  '2': [
    {'1': 'redeem_script', '3': 1, '4': 1, '5': 9, '10': 'redeemScript'},
    {'1': 'witness_script', '3': 2, '4': 1, '5': 9, '10': 'witnessScript'},
    {'1': 'bip32_derivs', '3': 3, '4': 1, '5': 9, '10': 'bip32Derivs'},
    {'1': 'unknown', '3': 4, '4': 1, '5': 9, '10': 'unknown'},
  ],
};

/// Descriptor for `Output`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List outputDescriptor = $convert.base64Decode(
    'CgZPdXRwdXQSIwoNcmVkZWVtX3NjcmlwdBgBIAEoCVIMcmVkZWVtU2NyaXB0EiUKDndpdG5lc3'
    'Nfc2NyaXB0GAIgASgJUg13aXRuZXNzU2NyaXB0EiEKDGJpcDMyX2Rlcml2cxgDIAEoCVILYmlw'
    'MzJEZXJpdnMSGAoHdW5rbm93bhgEIAEoCVIHdW5rbm93bg==');

@$core.Deprecated('Use analyzePsbtRequestDescriptor instead')
const AnalyzePsbtRequest$json = {
  '1': 'AnalyzePsbtRequest',
  '2': [
    {'1': 'psbt', '3': 1, '4': 1, '5': 9, '10': 'psbt'},
  ],
};

/// Descriptor for `AnalyzePsbtRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List analyzePsbtRequestDescriptor = $convert.base64Decode(
    'ChJBbmFseXplUHNidFJlcXVlc3QSEgoEcHNidBgBIAEoCVIEcHNidA==');

@$core.Deprecated('Use analyzePsbtResponseDescriptor instead')
const AnalyzePsbtResponse$json = {
  '1': 'AnalyzePsbtResponse',
  '2': [
    {'1': 'inputs', '3': 1, '4': 3, '5': 9, '10': 'inputs'},
    {'1': 'next', '3': 2, '4': 1, '5': 9, '10': 'next'},
    {'1': 'fee', '3': 3, '4': 1, '5': 9, '10': 'fee'},
    {'1': 'error', '3': 4, '4': 1, '5': 9, '10': 'error'},
  ],
};

/// Descriptor for `AnalyzePsbtResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List analyzePsbtResponseDescriptor = $convert.base64Decode(
    'ChNBbmFseXplUHNidFJlc3BvbnNlEhYKBmlucHV0cxgBIAMoCVIGaW5wdXRzEhIKBG5leHQYAi'
    'ABKAlSBG5leHQSEAoDZmVlGAMgASgJUgNmZWUSFAoFZXJyb3IYBCABKAlSBWVycm9y');

@$core.Deprecated('Use walletProcessPsbtRequestDescriptor instead')
const WalletProcessPsbtRequest$json = {
  '1': 'WalletProcessPsbtRequest',
  '2': [
    {'1': 'psbt', '3': 1, '4': 1, '5': 9, '10': 'psbt'},
    {'1': 'sign', '3': 2, '4': 1, '5': 8, '10': 'sign'},
    {'1': 'sighash_type', '3': 3, '4': 1, '5': 9, '10': 'sighashType'},
  ],
};

/// Descriptor for `WalletProcessPsbtRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List walletProcessPsbtRequestDescriptor = $convert.base64Decode(
    'ChhXYWxsZXRQcm9jZXNzUHNidFJlcXVlc3QSEgoEcHNidBgBIAEoCVIEcHNidBISCgRzaWduGA'
    'IgASgIUgRzaWduEiEKDHNpZ2hhc2hfdHlwZRgDIAEoCVILc2lnaGFzaFR5cGU=');

@$core.Deprecated('Use walletProcessPsbtResponseDescriptor instead')
const WalletProcessPsbtResponse$json = {
  '1': 'WalletProcessPsbtResponse',
  '2': [
    {'1': 'psbt', '3': 1, '4': 1, '5': 9, '10': 'psbt'},
    {'1': 'complete', '3': 2, '4': 1, '5': 8, '10': 'complete'},
  ],
};

/// Descriptor for `WalletProcessPsbtResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List walletProcessPsbtResponseDescriptor = $convert.base64Decode(
    'ChlXYWxsZXRQcm9jZXNzUHNidFJlc3BvbnNlEhIKBHBzYnQYASABKAlSBHBzYnQSGgoIY29tcG'
    'xldGUYAiABKAhSCGNvbXBsZXRl');

@$core.Deprecated('Use combinePsbtRequestDescriptor instead')
const CombinePsbtRequest$json = {
  '1': 'CombinePsbtRequest',
  '2': [
    {'1': 'psbts', '3': 1, '4': 3, '5': 9, '10': 'psbts'},
  ],
};

/// Descriptor for `CombinePsbtRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List combinePsbtRequestDescriptor = $convert.base64Decode(
    'ChJDb21iaW5lUHNidFJlcXVlc3QSFAoFcHNidHMYASADKAlSBXBzYnRz');

@$core.Deprecated('Use combinePsbtResponseDescriptor instead')
const CombinePsbtResponse$json = {
  '1': 'CombinePsbtResponse',
  '2': [
    {'1': 'psbt', '3': 1, '4': 1, '5': 9, '10': 'psbt'},
  ],
};

/// Descriptor for `CombinePsbtResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List combinePsbtResponseDescriptor = $convert.base64Decode(
    'ChNDb21iaW5lUHNidFJlc3BvbnNlEhIKBHBzYnQYASABKAlSBHBzYnQ=');

@$core.Deprecated('Use finalizePsbtRequestDescriptor instead')
const FinalizePsbtRequest$json = {
  '1': 'FinalizePsbtRequest',
  '2': [
    {'1': 'psbt', '3': 1, '4': 1, '5': 9, '10': 'psbt'},
  ],
};

/// Descriptor for `FinalizePsbtRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List finalizePsbtRequestDescriptor = $convert.base64Decode(
    'ChNGaW5hbGl6ZVBzYnRSZXF1ZXN0EhIKBHBzYnQYASABKAlSBHBzYnQ=');

@$core.Deprecated('Use finalizePsbtResponseDescriptor instead')
const FinalizePsbtResponse$json = {
  '1': 'FinalizePsbtResponse',
  '2': [
    {'1': 'psbt', '3': 1, '4': 1, '5': 9, '10': 'psbt'},
    {'1': 'hex', '3': 2, '4': 1, '5': 9, '10': 'hex'},
    {'1': 'complete', '3': 3, '4': 1, '5': 8, '10': 'complete'},
  ],
};

/// Descriptor for `FinalizePsbtResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List finalizePsbtResponseDescriptor = $convert.base64Decode(
    'ChRGaW5hbGl6ZVBzYnRSZXNwb25zZRISCgRwc2J0GAEgASgJUgRwc2J0EhAKA2hleBgCIAEoCV'
    'IDaGV4EhoKCGNvbXBsZXRlGAMgASgIUghjb21wbGV0ZQ==');

@$core.Deprecated('Use utxoUpdatePsbtRequestDescriptor instead')
const UtxoUpdatePsbtRequest$json = {
  '1': 'UtxoUpdatePsbtRequest',
  '2': [
    {'1': 'psbt', '3': 1, '4': 1, '5': 9, '10': 'psbt'},
  ],
};

/// Descriptor for `UtxoUpdatePsbtRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List utxoUpdatePsbtRequestDescriptor = $convert.base64Decode(
    'ChVVdHhvVXBkYXRlUHNidFJlcXVlc3QSEgoEcHNidBgBIAEoCVIEcHNidA==');

@$core.Deprecated('Use utxoUpdatePsbtResponseDescriptor instead')
const UtxoUpdatePsbtResponse$json = {
  '1': 'UtxoUpdatePsbtResponse',
  '2': [
    {'1': 'psbt', '3': 1, '4': 1, '5': 9, '10': 'psbt'},
  ],
};

/// Descriptor for `UtxoUpdatePsbtResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List utxoUpdatePsbtResponseDescriptor = $convert.base64Decode(
    'ChZVdHhvVXBkYXRlUHNidFJlc3BvbnNlEhIKBHBzYnQYASABKAlSBHBzYnQ=');

@$core.Deprecated('Use joinPsbtsRequestDescriptor instead')
const JoinPsbtsRequest$json = {
  '1': 'JoinPsbtsRequest',
  '2': [
    {'1': 'psbts', '3': 1, '4': 3, '5': 9, '10': 'psbts'},
  ],
};

/// Descriptor for `JoinPsbtsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List joinPsbtsRequestDescriptor = $convert.base64Decode(
    'ChBKb2luUHNidHNSZXF1ZXN0EhQKBXBzYnRzGAEgAygJUgVwc2J0cw==');

@$core.Deprecated('Use joinPsbtsResponseDescriptor instead')
const JoinPsbtsResponse$json = {
  '1': 'JoinPsbtsResponse',
  '2': [
    {'1': 'psbt', '3': 1, '4': 1, '5': 9, '10': 'psbt'},
  ],
};

/// Descriptor for `JoinPsbtsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List joinPsbtsResponseDescriptor = $convert.base64Decode(
    'ChFKb2luUHNidHNSZXNwb25zZRISCgRwc2J0GAEgASgJUgRwc2J0');

@$core.Deprecated('Use signRawTransactionWithWalletRequestDescriptor instead')
const SignRawTransactionWithWalletRequest$json = {
  '1': 'SignRawTransactionWithWalletRequest',
  '2': [
    {'1': 'hex_string', '3': 1, '4': 1, '5': 9, '10': 'hexString'},
    {'1': 'prev_txs', '3': 2, '4': 3, '5': 11, '6': '.multisig.v1.PreviousTx', '10': 'prevTxs'},
    {'1': 'sighash_type', '3': 3, '4': 1, '5': 9, '10': 'sighashType'},
  ],
};

/// Descriptor for `SignRawTransactionWithWalletRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List signRawTransactionWithWalletRequestDescriptor = $convert.base64Decode(
    'CiNTaWduUmF3VHJhbnNhY3Rpb25XaXRoV2FsbGV0UmVxdWVzdBIdCgpoZXhfc3RyaW5nGAEgAS'
    'gJUgloZXhTdHJpbmcSMgoIcHJldl90eHMYAiADKAsyFy5tdWx0aXNpZy52MS5QcmV2aW91c1R4'
    'UgdwcmV2VHhzEiEKDHNpZ2hhc2hfdHlwZRgDIAEoCVILc2lnaGFzaFR5cGU=');

@$core.Deprecated('Use previousTxDescriptor instead')
const PreviousTx$json = {
  '1': 'PreviousTx',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'vout', '3': 2, '4': 1, '5': 5, '10': 'vout'},
    {'1': 'script_pub_key', '3': 3, '4': 1, '5': 9, '10': 'scriptPubKey'},
    {'1': 'redeem_script', '3': 4, '4': 1, '5': 9, '10': 'redeemScript'},
    {'1': 'witness_script', '3': 5, '4': 1, '5': 9, '10': 'witnessScript'},
    {'1': 'amount', '3': 6, '4': 1, '5': 3, '10': 'amount'},
  ],
};

/// Descriptor for `PreviousTx`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List previousTxDescriptor = $convert.base64Decode(
    'CgpQcmV2aW91c1R4EhIKBHR4aWQYASABKAlSBHR4aWQSEgoEdm91dBgCIAEoBVIEdm91dBIkCg'
    '5zY3JpcHRfcHViX2tleRgDIAEoCVIMc2NyaXB0UHViS2V5EiMKDXJlZGVlbV9zY3JpcHQYBCAB'
    'KAlSDHJlZGVlbVNjcmlwdBIlCg53aXRuZXNzX3NjcmlwdBgFIAEoCVINd2l0bmVzc1NjcmlwdB'
    'IWCgZhbW91bnQYBiABKANSBmFtb3VudA==');

@$core.Deprecated('Use signRawTransactionWithWalletResponseDescriptor instead')
const SignRawTransactionWithWalletResponse$json = {
  '1': 'SignRawTransactionWithWalletResponse',
  '2': [
    {'1': 'hex', '3': 1, '4': 1, '5': 9, '10': 'hex'},
    {'1': 'complete', '3': 2, '4': 1, '5': 8, '10': 'complete'},
    {'1': 'errors', '3': 3, '4': 3, '5': 11, '6': '.multisig.v1.Error', '10': 'errors'},
  ],
};

/// Descriptor for `SignRawTransactionWithWalletResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List signRawTransactionWithWalletResponseDescriptor = $convert.base64Decode(
    'CiRTaWduUmF3VHJhbnNhY3Rpb25XaXRoV2FsbGV0UmVzcG9uc2USEAoDaGV4GAEgASgJUgNoZX'
    'gSGgoIY29tcGxldGUYAiABKAhSCGNvbXBsZXRlEioKBmVycm9ycxgDIAMoCzISLm11bHRpc2ln'
    'LnYxLkVycm9yUgZlcnJvcnM=');

@$core.Deprecated('Use errorDescriptor instead')
const Error$json = {
  '1': 'Error',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'vout', '3': 2, '4': 1, '5': 5, '10': 'vout'},
    {'1': 'script_sig', '3': 3, '4': 1, '5': 9, '10': 'scriptSig'},
    {'1': 'sequence', '3': 4, '4': 1, '5': 9, '10': 'sequence'},
    {'1': 'error', '3': 5, '4': 1, '5': 9, '10': 'error'},
  ],
};

/// Descriptor for `Error`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List errorDescriptor = $convert.base64Decode(
    'CgVFcnJvchISCgR0eGlkGAEgASgJUgR0eGlkEhIKBHZvdXQYAiABKAVSBHZvdXQSHQoKc2NyaX'
    'B0X3NpZxgDIAEoCVIJc2NyaXB0U2lnEhoKCHNlcXVlbmNlGAQgASgJUghzZXF1ZW5jZRIUCgVl'
    'cnJvchgFIAEoCVIFZXJyb3I=');

@$core.Deprecated('Use sendRawTransactionRequestDescriptor instead')
const SendRawTransactionRequest$json = {
  '1': 'SendRawTransactionRequest',
  '2': [
    {'1': 'hex_string', '3': 1, '4': 1, '5': 9, '10': 'hexString'},
    {'1': 'max_fee_rate', '3': 2, '4': 1, '5': 1, '10': 'maxFeeRate'},
  ],
};

/// Descriptor for `SendRawTransactionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendRawTransactionRequestDescriptor = $convert.base64Decode(
    'ChlTZW5kUmF3VHJhbnNhY3Rpb25SZXF1ZXN0Eh0KCmhleF9zdHJpbmcYASABKAlSCWhleFN0cm'
    'luZxIgCgxtYXhfZmVlX3JhdGUYAiABKAFSCm1heEZlZVJhdGU=');

@$core.Deprecated('Use sendRawTransactionResponseDescriptor instead')
const SendRawTransactionResponse$json = {
  '1': 'SendRawTransactionResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `SendRawTransactionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendRawTransactionResponseDescriptor = $convert.base64Decode(
    'ChpTZW5kUmF3VHJhbnNhY3Rpb25SZXNwb25zZRISCgR0eGlkGAEgASgJUgR0eGlk');

@$core.Deprecated('Use testMempoolAcceptRequestDescriptor instead')
const TestMempoolAcceptRequest$json = {
  '1': 'TestMempoolAcceptRequest',
  '2': [
    {'1': 'hex_strings', '3': 1, '4': 3, '5': 9, '10': 'hexStrings'},
  ],
};

/// Descriptor for `TestMempoolAcceptRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List testMempoolAcceptRequestDescriptor = $convert.base64Decode(
    'ChhUZXN0TWVtcG9vbEFjY2VwdFJlcXVlc3QSHwoLaGV4X3N0cmluZ3MYASADKAlSCmhleFN0cm'
    'luZ3M=');

@$core.Deprecated('Use testMempoolAcceptResponseDescriptor instead')
const TestMempoolAcceptResponse$json = {
  '1': 'TestMempoolAcceptResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'allowed', '3': 2, '4': 1, '5': 8, '10': 'allowed'},
    {'1': 'reject_reason', '3': 3, '4': 1, '5': 9, '10': 'rejectReason'},
  ],
};

/// Descriptor for `TestMempoolAcceptResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List testMempoolAcceptResponseDescriptor = $convert.base64Decode(
    'ChlUZXN0TWVtcG9vbEFjY2VwdFJlc3BvbnNlEhIKBHR4aWQYASABKAlSBHR4aWQSGAoHYWxsb3'
    'dlZBgCIAEoCFIHYWxsb3dlZBIjCg1yZWplY3RfcmVhc29uGAMgASgJUgxyZWplY3RSZWFzb24=');

@$core.Deprecated('Use getTransactionRequestDescriptor instead')
const GetTransactionRequest$json = {
  '1': 'GetTransactionRequest',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'include_watchonly', '3': 2, '4': 1, '5': 8, '10': 'includeWatchonly'},
  ],
};

/// Descriptor for `GetTransactionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTransactionRequestDescriptor = $convert.base64Decode(
    'ChVHZXRUcmFuc2FjdGlvblJlcXVlc3QSEgoEdHhpZBgBIAEoCVIEdHhpZBIrChFpbmNsdWRlX3'
    'dhdGNob25seRgCIAEoCFIQaW5jbHVkZVdhdGNob25seQ==');

@$core.Deprecated('Use getTransactionResponseDescriptor instead')
const GetTransactionResponse$json = {
  '1': 'GetTransactionResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'confirmations', '3': 2, '4': 1, '5': 5, '10': 'confirmations'},
    {'1': 'block_time', '3': 3, '4': 1, '5': 3, '10': 'blockTime'},
    {'1': 'block_hash', '3': 4, '4': 1, '5': 9, '10': 'blockHash'},
    {'1': 'block_height', '3': 5, '4': 1, '5': 5, '10': 'blockHeight'},
    {'1': 'amount', '3': 6, '4': 1, '5': 3, '10': 'amount'},
    {'1': 'fee', '3': 7, '4': 1, '5': 3, '10': 'fee'},
    {'1': 'hex', '3': 8, '4': 1, '5': 9, '10': 'hex'},
    {'1': 'details', '3': 9, '4': 3, '5': 11, '6': '.multisig.v1.Detail', '10': 'details'},
  ],
};

/// Descriptor for `GetTransactionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTransactionResponseDescriptor = $convert.base64Decode(
    'ChZHZXRUcmFuc2FjdGlvblJlc3BvbnNlEhIKBHR4aWQYASABKAlSBHR4aWQSJAoNY29uZmlybW'
    'F0aW9ucxgCIAEoBVINY29uZmlybWF0aW9ucxIdCgpibG9ja190aW1lGAMgASgDUglibG9ja1Rp'
    'bWUSHQoKYmxvY2tfaGFzaBgEIAEoCVIJYmxvY2tIYXNoEiEKDGJsb2NrX2hlaWdodBgFIAEoBV'
    'ILYmxvY2tIZWlnaHQSFgoGYW1vdW50GAYgASgDUgZhbW91bnQSEAoDZmVlGAcgASgDUgNmZWUS'
    'EAoDaGV4GAggASgJUgNoZXgSLQoHZGV0YWlscxgJIAMoCzITLm11bHRpc2lnLnYxLkRldGFpbF'
    'IHZGV0YWlscw==');

@$core.Deprecated('Use detailDescriptor instead')
const Detail$json = {
  '1': 'Detail',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'category', '3': 2, '4': 1, '5': 9, '10': 'category'},
    {'1': 'amount', '3': 3, '4': 1, '5': 3, '10': 'amount'},
    {'1': 'label', '3': 4, '4': 1, '5': 9, '10': 'label'},
    {'1': 'vout', '3': 5, '4': 1, '5': 5, '10': 'vout'},
    {'1': 'fee', '3': 6, '4': 1, '5': 1, '10': 'fee'},
    {'1': 'abandoned', '3': 7, '4': 1, '5': 8, '10': 'abandoned'},
  ],
};

/// Descriptor for `Detail`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List detailDescriptor = $convert.base64Decode(
    'CgZEZXRhaWwSGAoHYWRkcmVzcxgBIAEoCVIHYWRkcmVzcxIaCghjYXRlZ29yeRgCIAEoCVIIY2'
    'F0ZWdvcnkSFgoGYW1vdW50GAMgASgDUgZhbW91bnQSFAoFbGFiZWwYBCABKAlSBWxhYmVsEhIK'
    'BHZvdXQYBSABKAVSBHZvdXQSEAoDZmVlGAYgASgBUgNmZWUSHAoJYWJhbmRvbmVkGAcgASgIUg'
    'lhYmFuZG9uZWQ=');

const $core.Map<$core.String, $core.dynamic> MultisigServiceBase$json = {
  '1': 'MultisigService',
  '2': [
    {'1': 'AddMultisigAddress', '2': '.multisig.v1.AddMultisigAddressRequest', '3': '.multisig.v1.AddMultisigAddressResponse'},
    {'1': 'ImportAddress', '2': '.multisig.v1.ImportAddressRequest', '3': '.multisig.v1.ImportAddressResponse'},
    {'1': 'GetAddressInfo', '2': '.multisig.v1.GetAddressInfoRequest', '3': '.multisig.v1.GetAddressInfoResponse'},
    {'1': 'ListUnspent', '2': '.multisig.v1.ListUnspentRequest', '3': '.multisig.v1.ListUnspentResponse'},
    {'1': 'ListAddressGroupings', '2': '.multisig.v1.ListAddressGroupingsRequest', '3': '.multisig.v1.ListAddressGroupingsResponse'},
    {'1': 'CreateRawTransaction', '2': '.multisig.v1.CreateRawTransactionRequest', '3': '.multisig.v1.CreateRawTransactionResponse'},
    {'1': 'CreatePsbt', '2': '.multisig.v1.CreatePsbtRequest', '3': '.multisig.v1.CreatePsbtResponse'},
    {'1': 'WalletCreateFundedPsbt', '2': '.multisig.v1.WalletCreateFundedPsbtRequest', '3': '.multisig.v1.WalletCreateFundedPsbtResponse'},
    {'1': 'DecodePsbt', '2': '.multisig.v1.DecodePsbtRequest', '3': '.multisig.v1.DecodePsbtResponse'},
    {'1': 'AnalyzePsbt', '2': '.multisig.v1.AnalyzePsbtRequest', '3': '.multisig.v1.AnalyzePsbtResponse'},
    {'1': 'WalletProcessPsbt', '2': '.multisig.v1.WalletProcessPsbtRequest', '3': '.multisig.v1.WalletProcessPsbtResponse'},
    {'1': 'CombinePsbt', '2': '.multisig.v1.CombinePsbtRequest', '3': '.multisig.v1.CombinePsbtResponse'},
    {'1': 'FinalizePsbt', '2': '.multisig.v1.FinalizePsbtRequest', '3': '.multisig.v1.FinalizePsbtResponse'},
    {'1': 'UtxoUpdatePsbt', '2': '.multisig.v1.UtxoUpdatePsbtRequest', '3': '.multisig.v1.UtxoUpdatePsbtResponse'},
    {'1': 'JoinPsbts', '2': '.multisig.v1.JoinPsbtsRequest', '3': '.multisig.v1.JoinPsbtsResponse'},
    {'1': 'SignRawTransactionWithWallet', '2': '.multisig.v1.SignRawTransactionWithWalletRequest', '3': '.multisig.v1.SignRawTransactionWithWalletResponse'},
    {'1': 'SendRawTransaction', '2': '.multisig.v1.SendRawTransactionRequest', '3': '.multisig.v1.SendRawTransactionResponse'},
    {'1': 'TestMempoolAccept', '2': '.multisig.v1.TestMempoolAcceptRequest', '3': '.multisig.v1.TestMempoolAcceptResponse'},
    {'1': 'GetTransaction', '2': '.multisig.v1.GetTransactionRequest', '3': '.multisig.v1.GetTransactionResponse'},
  ],
};

@$core.Deprecated('Use multisigServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> MultisigServiceBase$messageJson = {
  '.multisig.v1.AddMultisigAddressRequest': AddMultisigAddressRequest$json,
  '.multisig.v1.AddMultisigAddressResponse': AddMultisigAddressResponse$json,
  '.multisig.v1.ImportAddressRequest': ImportAddressRequest$json,
  '.multisig.v1.ImportAddressResponse': ImportAddressResponse$json,
  '.multisig.v1.GetAddressInfoRequest': GetAddressInfoRequest$json,
  '.multisig.v1.GetAddressInfoResponse': GetAddressInfoResponse$json,
  '.multisig.v1.ListUnspentRequest': ListUnspentRequest$json,
  '.multisig.v1.ListUnspentResponse': ListUnspentResponse$json,
  '.multisig.v1.Utxo': Utxo$json,
  '.multisig.v1.ListAddressGroupingsRequest': ListAddressGroupingsRequest$json,
  '.multisig.v1.ListAddressGroupingsResponse': ListAddressGroupingsResponse$json,
  '.multisig.v1.AddressGrouping': AddressGrouping$json,
  '.multisig.v1.AddressInfo': AddressInfo$json,
  '.multisig.v1.CreateRawTransactionRequest': CreateRawTransactionRequest$json,
  '.multisig.v1.TxInput': TxInput$json,
  '.multisig.v1.TxOutput': TxOutput$json,
  '.multisig.v1.CreateRawTransactionResponse': CreateRawTransactionResponse$json,
  '.multisig.v1.CreatePsbtRequest': CreatePsbtRequest$json,
  '.multisig.v1.CreatePsbtResponse': CreatePsbtResponse$json,
  '.multisig.v1.WalletCreateFundedPsbtRequest': WalletCreateFundedPsbtRequest$json,
  '.multisig.v1.PsbtOptions': PsbtOptions$json,
  '.multisig.v1.WalletCreateFundedPsbtResponse': WalletCreateFundedPsbtResponse$json,
  '.multisig.v1.DecodePsbtRequest': DecodePsbtRequest$json,
  '.multisig.v1.DecodePsbtResponse': DecodePsbtResponse$json,
  '.multisig.v1.Input': Input$json,
  '.multisig.v1.Output': Output$json,
  '.multisig.v1.AnalyzePsbtRequest': AnalyzePsbtRequest$json,
  '.multisig.v1.AnalyzePsbtResponse': AnalyzePsbtResponse$json,
  '.multisig.v1.WalletProcessPsbtRequest': WalletProcessPsbtRequest$json,
  '.multisig.v1.WalletProcessPsbtResponse': WalletProcessPsbtResponse$json,
  '.multisig.v1.CombinePsbtRequest': CombinePsbtRequest$json,
  '.multisig.v1.CombinePsbtResponse': CombinePsbtResponse$json,
  '.multisig.v1.FinalizePsbtRequest': FinalizePsbtRequest$json,
  '.multisig.v1.FinalizePsbtResponse': FinalizePsbtResponse$json,
  '.multisig.v1.UtxoUpdatePsbtRequest': UtxoUpdatePsbtRequest$json,
  '.multisig.v1.UtxoUpdatePsbtResponse': UtxoUpdatePsbtResponse$json,
  '.multisig.v1.JoinPsbtsRequest': JoinPsbtsRequest$json,
  '.multisig.v1.JoinPsbtsResponse': JoinPsbtsResponse$json,
  '.multisig.v1.SignRawTransactionWithWalletRequest': SignRawTransactionWithWalletRequest$json,
  '.multisig.v1.PreviousTx': PreviousTx$json,
  '.multisig.v1.SignRawTransactionWithWalletResponse': SignRawTransactionWithWalletResponse$json,
  '.multisig.v1.Error': Error$json,
  '.multisig.v1.SendRawTransactionRequest': SendRawTransactionRequest$json,
  '.multisig.v1.SendRawTransactionResponse': SendRawTransactionResponse$json,
  '.multisig.v1.TestMempoolAcceptRequest': TestMempoolAcceptRequest$json,
  '.multisig.v1.TestMempoolAcceptResponse': TestMempoolAcceptResponse$json,
  '.multisig.v1.GetTransactionRequest': GetTransactionRequest$json,
  '.multisig.v1.GetTransactionResponse': GetTransactionResponse$json,
  '.multisig.v1.Detail': Detail$json,
};

/// Descriptor for `MultisigService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List multisigServiceDescriptor = $convert.base64Decode(
    'Cg9NdWx0aXNpZ1NlcnZpY2USZQoSQWRkTXVsdGlzaWdBZGRyZXNzEiYubXVsdGlzaWcudjEuQW'
    'RkTXVsdGlzaWdBZGRyZXNzUmVxdWVzdBonLm11bHRpc2lnLnYxLkFkZE11bHRpc2lnQWRkcmVz'
    'c1Jlc3BvbnNlElYKDUltcG9ydEFkZHJlc3MSIS5tdWx0aXNpZy52MS5JbXBvcnRBZGRyZXNzUm'
    'VxdWVzdBoiLm11bHRpc2lnLnYxLkltcG9ydEFkZHJlc3NSZXNwb25zZRJZCg5HZXRBZGRyZXNz'
    'SW5mbxIiLm11bHRpc2lnLnYxLkdldEFkZHJlc3NJbmZvUmVxdWVzdBojLm11bHRpc2lnLnYxLk'
    'dldEFkZHJlc3NJbmZvUmVzcG9uc2USUAoLTGlzdFVuc3BlbnQSHy5tdWx0aXNpZy52MS5MaXN0'
    'VW5zcGVudFJlcXVlc3QaIC5tdWx0aXNpZy52MS5MaXN0VW5zcGVudFJlc3BvbnNlEmsKFExpc3'
    'RBZGRyZXNzR3JvdXBpbmdzEigubXVsdGlzaWcudjEuTGlzdEFkZHJlc3NHcm91cGluZ3NSZXF1'
    'ZXN0GikubXVsdGlzaWcudjEuTGlzdEFkZHJlc3NHcm91cGluZ3NSZXNwb25zZRJrChRDcmVhdG'
    'VSYXdUcmFuc2FjdGlvbhIoLm11bHRpc2lnLnYxLkNyZWF0ZVJhd1RyYW5zYWN0aW9uUmVxdWVz'
    'dBopLm11bHRpc2lnLnYxLkNyZWF0ZVJhd1RyYW5zYWN0aW9uUmVzcG9uc2USTQoKQ3JlYXRlUH'
    'NidBIeLm11bHRpc2lnLnYxLkNyZWF0ZVBzYnRSZXF1ZXN0Gh8ubXVsdGlzaWcudjEuQ3JlYXRl'
    'UHNidFJlc3BvbnNlEnEKFldhbGxldENyZWF0ZUZ1bmRlZFBzYnQSKi5tdWx0aXNpZy52MS5XYW'
    'xsZXRDcmVhdGVGdW5kZWRQc2J0UmVxdWVzdBorLm11bHRpc2lnLnYxLldhbGxldENyZWF0ZUZ1'
    'bmRlZFBzYnRSZXNwb25zZRJNCgpEZWNvZGVQc2J0Eh4ubXVsdGlzaWcudjEuRGVjb2RlUHNidF'
    'JlcXVlc3QaHy5tdWx0aXNpZy52MS5EZWNvZGVQc2J0UmVzcG9uc2USUAoLQW5hbHl6ZVBzYnQS'
    'Hy5tdWx0aXNpZy52MS5BbmFseXplUHNidFJlcXVlc3QaIC5tdWx0aXNpZy52MS5BbmFseXplUH'
    'NidFJlc3BvbnNlEmIKEVdhbGxldFByb2Nlc3NQc2J0EiUubXVsdGlzaWcudjEuV2FsbGV0UHJv'
    'Y2Vzc1BzYnRSZXF1ZXN0GiYubXVsdGlzaWcudjEuV2FsbGV0UHJvY2Vzc1BzYnRSZXNwb25zZR'
    'JQCgtDb21iaW5lUHNidBIfLm11bHRpc2lnLnYxLkNvbWJpbmVQc2J0UmVxdWVzdBogLm11bHRp'
    'c2lnLnYxLkNvbWJpbmVQc2J0UmVzcG9uc2USUwoMRmluYWxpemVQc2J0EiAubXVsdGlzaWcudj'
    'EuRmluYWxpemVQc2J0UmVxdWVzdBohLm11bHRpc2lnLnYxLkZpbmFsaXplUHNidFJlc3BvbnNl'
    'ElkKDlV0eG9VcGRhdGVQc2J0EiIubXVsdGlzaWcudjEuVXR4b1VwZGF0ZVBzYnRSZXF1ZXN0Gi'
    'MubXVsdGlzaWcudjEuVXR4b1VwZGF0ZVBzYnRSZXNwb25zZRJKCglKb2luUHNidHMSHS5tdWx0'
    'aXNpZy52MS5Kb2luUHNidHNSZXF1ZXN0Gh4ubXVsdGlzaWcudjEuSm9pblBzYnRzUmVzcG9uc2'
    'USgwEKHFNpZ25SYXdUcmFuc2FjdGlvbldpdGhXYWxsZXQSMC5tdWx0aXNpZy52MS5TaWduUmF3'
    'VHJhbnNhY3Rpb25XaXRoV2FsbGV0UmVxdWVzdBoxLm11bHRpc2lnLnYxLlNpZ25SYXdUcmFuc2'
    'FjdGlvbldpdGhXYWxsZXRSZXNwb25zZRJlChJTZW5kUmF3VHJhbnNhY3Rpb24SJi5tdWx0aXNp'
    'Zy52MS5TZW5kUmF3VHJhbnNhY3Rpb25SZXF1ZXN0GicubXVsdGlzaWcudjEuU2VuZFJhd1RyYW'
    '5zYWN0aW9uUmVzcG9uc2USYgoRVGVzdE1lbXBvb2xBY2NlcHQSJS5tdWx0aXNpZy52MS5UZXN0'
    'TWVtcG9vbEFjY2VwdFJlcXVlc3QaJi5tdWx0aXNpZy52MS5UZXN0TWVtcG9vbEFjY2VwdFJlc3'
    'BvbnNlElkKDkdldFRyYW5zYWN0aW9uEiIubXVsdGlzaWcudjEuR2V0VHJhbnNhY3Rpb25SZXF1'
    'ZXN0GiMubXVsdGlzaWcudjEuR2V0VHJhbnNhY3Rpb25SZXNwb25zZQ==');

