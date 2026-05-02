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

import '../../google/protobuf/empty.pbjson.dart' as $1;
import '../../google/protobuf/timestamp.pbjson.dart' as $0;

@$core.Deprecated('Use txStatusDescriptor instead')
const TxStatus$json = {
  '1': 'TxStatus',
  '2': [
    {'1': 'TX_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'TX_STATUS_NEEDS_SIGNATURES', '2': 1},
    {'1': 'TX_STATUS_AWAITING_SIGNED_PSBTS', '2': 2},
    {'1': 'TX_STATUS_READY_TO_COMBINE', '2': 3},
    {'1': 'TX_STATUS_READY_FOR_BROADCAST', '2': 4},
    {'1': 'TX_STATUS_BROADCASTED', '2': 5},
    {'1': 'TX_STATUS_CONFIRMED', '2': 6},
    {'1': 'TX_STATUS_COMPLETED', '2': 7},
    {'1': 'TX_STATUS_VOIDED', '2': 8},
  ],
};

/// Descriptor for `TxStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List txStatusDescriptor =
    $convert.base64Decode('CghUeFN0YXR1cxIZChVUWF9TVEFUVVNfVU5TUEVDSUZJRUQQABIeChpUWF9TVEFUVVNfTkVFRF'
        'NfU0lHTkFUVVJFUxABEiMKH1RYX1NUQVRVU19BV0FJVElOR19TSUdORURfUFNCVFMQAhIeChpU'
        'WF9TVEFUVVNfUkVBRFlfVE9fQ09NQklORRADEiEKHVRYX1NUQVRVU19SRUFEWV9GT1JfQlJPQU'
        'RDQVNUEAQSGQoVVFhfU1RBVFVTX0JST0FEQ0FTVEVEEAUSFwoTVFhfU1RBVFVTX0NPTkZJUk1F'
        'RBAGEhcKE1RYX1NUQVRVU19DT01QTEVURUQQBxIUChBUWF9TVEFUVVNfVk9JREVEEAg=');

@$core.Deprecated('Use txTypeDescriptor instead')
const TxType$json = {
  '1': 'TxType',
  '2': [
    {'1': 'TX_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'TX_TYPE_DEPOSIT', '2': 1},
    {'1': 'TX_TYPE_WITHDRAWAL', '2': 2},
  ],
};

/// Descriptor for `TxType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List txTypeDescriptor =
    $convert.base64Decode('CgZUeFR5cGUSFwoTVFhfVFlQRV9VTlNQRUNJRklFRBAAEhMKD1RYX1RZUEVfREVQT1NJVBABEh'
        'YKElRYX1RZUEVfV0lUSERSQVdBTBAC');

@$core.Deprecated('Use multisigKeyDescriptor instead')
const MultisigKey$json = {
  '1': 'MultisigKey',
  '2': [
    {'1': 'owner', '3': 1, '4': 1, '5': 9, '10': 'owner'},
    {'1': 'xpub', '3': 2, '4': 1, '5': 9, '10': 'xpub'},
    {'1': 'derivation_path', '3': 3, '4': 1, '5': 9, '10': 'derivationPath'},
    {'1': 'fingerprint', '3': 4, '4': 1, '5': 9, '10': 'fingerprint'},
    {'1': 'origin_path', '3': 5, '4': 1, '5': 9, '10': 'originPath'},
    {'1': 'is_wallet', '3': 6, '4': 1, '5': 8, '10': 'isWallet'},
    {
      '1': 'active_psbts',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.multisig.v1.MultisigKey.ActivePsbtsEntry',
      '10': 'activePsbts'
    },
    {
      '1': 'initial_psbts',
      '3': 8,
      '4': 3,
      '5': 11,
      '6': '.multisig.v1.MultisigKey.InitialPsbtsEntry',
      '10': 'initialPsbts'
    },
  ],
  '3': [MultisigKey_ActivePsbtsEntry$json, MultisigKey_InitialPsbtsEntry$json],
};

@$core.Deprecated('Use multisigKeyDescriptor instead')
const MultisigKey_ActivePsbtsEntry$json = {
  '1': 'ActivePsbtsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use multisigKeyDescriptor instead')
const MultisigKey_InitialPsbtsEntry$json = {
  '1': 'InitialPsbtsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `MultisigKey`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List multisigKeyDescriptor =
    $convert.base64Decode('CgtNdWx0aXNpZ0tleRIUCgVvd25lchgBIAEoCVIFb3duZXISEgoEeHB1YhgCIAEoCVIEeHB1Yh'
        'InCg9kZXJpdmF0aW9uX3BhdGgYAyABKAlSDmRlcml2YXRpb25QYXRoEiAKC2ZpbmdlcnByaW50'
        'GAQgASgJUgtmaW5nZXJwcmludBIfCgtvcmlnaW5fcGF0aBgFIAEoCVIKb3JpZ2luUGF0aBIbCg'
        'lpc193YWxsZXQYBiABKAhSCGlzV2FsbGV0EkwKDGFjdGl2ZV9wc2J0cxgHIAMoCzIpLm11bHRp'
        'c2lnLnYxLk11bHRpc2lnS2V5LkFjdGl2ZVBzYnRzRW50cnlSC2FjdGl2ZVBzYnRzEk8KDWluaX'
        'RpYWxfcHNidHMYCCADKAsyKi5tdWx0aXNpZy52MS5NdWx0aXNpZ0tleS5Jbml0aWFsUHNidHNF'
        'bnRyeVIMaW5pdGlhbFBzYnRzGj4KEEFjdGl2ZVBzYnRzRW50cnkSEAoDa2V5GAEgASgJUgNrZX'
        'kSFAoFdmFsdWUYAiABKAlSBXZhbHVlOgI4ARo/ChFJbml0aWFsUHNidHNFbnRyeRIQCgNrZXkY'
        'ASABKAlSA2tleRIUCgV2YWx1ZRgCIAEoCVIFdmFsdWU6AjgB');

@$core.Deprecated('Use addressInfoDescriptor instead')
const AddressInfo$json = {
  '1': 'AddressInfo',
  '2': [
    {'1': 'index', '3': 1, '4': 1, '5': 5, '10': 'index'},
    {'1': 'address', '3': 2, '4': 1, '5': 9, '10': 'address'},
    {'1': 'used', '3': 3, '4': 1, '5': 8, '10': 'used'},
  ],
};

/// Descriptor for `AddressInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addressInfoDescriptor =
    $convert.base64Decode('CgtBZGRyZXNzSW5mbxIUCgVpbmRleBgBIAEoBVIFaW5kZXgSGAoHYWRkcmVzcxgCIAEoCVIHYW'
        'RkcmVzcxISCgR1c2VkGAMgASgIUgR1c2Vk');

@$core.Deprecated('Use utxoDetailDescriptor instead')
const UtxoDetail$json = {
  '1': 'UtxoDetail',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'vout', '3': 2, '4': 1, '5': 5, '10': 'vout'},
    {'1': 'address', '3': 3, '4': 1, '5': 9, '10': 'address'},
    {'1': 'amount', '3': 4, '4': 1, '5': 1, '10': 'amount'},
    {'1': 'confirmations', '3': 5, '4': 1, '5': 5, '10': 'confirmations'},
    {'1': 'script_pub_key', '3': 6, '4': 1, '5': 9, '10': 'scriptPubKey'},
    {'1': 'spendable', '3': 7, '4': 1, '5': 8, '10': 'spendable'},
    {'1': 'solvable', '3': 8, '4': 1, '5': 8, '10': 'solvable'},
    {'1': 'safe', '3': 9, '4': 1, '5': 8, '10': 'safe'},
  ],
};

/// Descriptor for `UtxoDetail`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List utxoDetailDescriptor =
    $convert.base64Decode('CgpVdHhvRGV0YWlsEhIKBHR4aWQYASABKAlSBHR4aWQSEgoEdm91dBgCIAEoBVIEdm91dBIYCg'
        'dhZGRyZXNzGAMgASgJUgdhZGRyZXNzEhYKBmFtb3VudBgEIAEoAVIGYW1vdW50EiQKDWNvbmZp'
        'cm1hdGlvbnMYBSABKAVSDWNvbmZpcm1hdGlvbnMSJAoOc2NyaXB0X3B1Yl9rZXkYBiABKAlSDH'
        'NjcmlwdFB1YktleRIcCglzcGVuZGFibGUYByABKAhSCXNwZW5kYWJsZRIaCghzb2x2YWJsZRgI'
        'IAEoCFIIc29sdmFibGUSEgoEc2FmZRgJIAEoCFIEc2FmZQ==');

@$core.Deprecated('Use multisigGroupDescriptor instead')
const MultisigGroup$json = {
  '1': 'MultisigGroup',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'n', '3': 3, '4': 1, '5': 5, '10': 'n'},
    {'1': 'm', '3': 4, '4': 1, '5': 5, '10': 'm'},
    {'1': 'keys', '3': 5, '4': 3, '5': 11, '6': '.multisig.v1.MultisigKey', '10': 'keys'},
    {'1': 'created', '3': 6, '4': 1, '5': 3, '10': 'created'},
    {'1': 'txid', '3': 7, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'base_descriptor', '3': 8, '4': 1, '5': 9, '10': 'baseDescriptor'},
    {'1': 'descriptor_receive', '3': 9, '4': 1, '5': 9, '10': 'descriptorReceive'},
    {'1': 'descriptor_change', '3': 10, '4': 1, '5': 9, '10': 'descriptorChange'},
    {'1': 'watch_wallet_name', '3': 11, '4': 1, '5': 9, '10': 'watchWalletName'},
    {'1': 'receive_addresses', '3': 12, '4': 3, '5': 11, '6': '.multisig.v1.AddressInfo', '10': 'receiveAddresses'},
    {'1': 'change_addresses', '3': 13, '4': 3, '5': 11, '6': '.multisig.v1.AddressInfo', '10': 'changeAddresses'},
    {'1': 'utxo_details', '3': 14, '4': 3, '5': 11, '6': '.multisig.v1.UtxoDetail', '10': 'utxoDetails'},
    {'1': 'balance', '3': 15, '4': 1, '5': 1, '10': 'balance'},
    {'1': 'utxos', '3': 16, '4': 1, '5': 5, '10': 'utxos'},
    {'1': 'next_receive_index', '3': 17, '4': 1, '5': 5, '10': 'nextReceiveIndex'},
    {'1': 'next_change_index', '3': 18, '4': 1, '5': 5, '10': 'nextChangeIndex'},
    {'1': 'transaction_ids', '3': 19, '4': 3, '5': 9, '10': 'transactionIds'},
  ],
};

/// Descriptor for `MultisigGroup`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List multisigGroupDescriptor =
    $convert.base64Decode('Cg1NdWx0aXNpZ0dyb3VwEg4KAmlkGAEgASgJUgJpZBISCgRuYW1lGAIgASgJUgRuYW1lEgwKAW'
        '4YAyABKAVSAW4SDAoBbRgEIAEoBVIBbRIsCgRrZXlzGAUgAygLMhgubXVsdGlzaWcudjEuTXVs'
        'dGlzaWdLZXlSBGtleXMSGAoHY3JlYXRlZBgGIAEoA1IHY3JlYXRlZBISCgR0eGlkGAcgASgJUg'
        'R0eGlkEicKD2Jhc2VfZGVzY3JpcHRvchgIIAEoCVIOYmFzZURlc2NyaXB0b3ISLQoSZGVzY3Jp'
        'cHRvcl9yZWNlaXZlGAkgASgJUhFkZXNjcmlwdG9yUmVjZWl2ZRIrChFkZXNjcmlwdG9yX2NoYW'
        '5nZRgKIAEoCVIQZGVzY3JpcHRvckNoYW5nZRIqChF3YXRjaF93YWxsZXRfbmFtZRgLIAEoCVIP'
        'd2F0Y2hXYWxsZXROYW1lEkUKEXJlY2VpdmVfYWRkcmVzc2VzGAwgAygLMhgubXVsdGlzaWcudj'
        'EuQWRkcmVzc0luZm9SEHJlY2VpdmVBZGRyZXNzZXMSQwoQY2hhbmdlX2FkZHJlc3NlcxgNIAMo'
        'CzIYLm11bHRpc2lnLnYxLkFkZHJlc3NJbmZvUg9jaGFuZ2VBZGRyZXNzZXMSOgoMdXR4b19kZX'
        'RhaWxzGA4gAygLMhcubXVsdGlzaWcudjEuVXR4b0RldGFpbFILdXR4b0RldGFpbHMSGAoHYmFs'
        'YW5jZRgPIAEoAVIHYmFsYW5jZRIUCgV1dHhvcxgQIAEoBVIFdXR4b3MSLAoSbmV4dF9yZWNlaX'
        'ZlX2luZGV4GBEgASgFUhBuZXh0UmVjZWl2ZUluZGV4EioKEW5leHRfY2hhbmdlX2luZGV4GBIg'
        'ASgFUg9uZXh0Q2hhbmdlSW5kZXgSJwoPdHJhbnNhY3Rpb25faWRzGBMgAygJUg50cmFuc2FjdG'
        'lvbklkcw==');

@$core.Deprecated('Use listGroupsResponseDescriptor instead')
const ListGroupsResponse$json = {
  '1': 'ListGroupsResponse',
  '2': [
    {'1': 'groups', '3': 1, '4': 3, '5': 11, '6': '.multisig.v1.MultisigGroup', '10': 'groups'},
  ],
};

/// Descriptor for `ListGroupsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listGroupsResponseDescriptor =
    $convert.base64Decode('ChJMaXN0R3JvdXBzUmVzcG9uc2USMgoGZ3JvdXBzGAEgAygLMhoubXVsdGlzaWcudjEuTXVsdG'
        'lzaWdHcm91cFIGZ3JvdXBz');

@$core.Deprecated('Use saveGroupRequestDescriptor instead')
const SaveGroupRequest$json = {
  '1': 'SaveGroupRequest',
  '2': [
    {'1': 'group', '3': 1, '4': 1, '5': 11, '6': '.multisig.v1.MultisigGroup', '10': 'group'},
  ],
};

/// Descriptor for `SaveGroupRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List saveGroupRequestDescriptor =
    $convert.base64Decode('ChBTYXZlR3JvdXBSZXF1ZXN0EjAKBWdyb3VwGAEgASgLMhoubXVsdGlzaWcudjEuTXVsdGlzaW'
        'dHcm91cFIFZ3JvdXA=');

@$core.Deprecated('Use saveGroupResponseDescriptor instead')
const SaveGroupResponse$json = {
  '1': 'SaveGroupResponse',
  '2': [
    {'1': 'group', '3': 1, '4': 1, '5': 11, '6': '.multisig.v1.MultisigGroup', '10': 'group'},
  ],
};

/// Descriptor for `SaveGroupResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List saveGroupResponseDescriptor =
    $convert.base64Decode('ChFTYXZlR3JvdXBSZXNwb25zZRIwCgVncm91cBgBIAEoCzIaLm11bHRpc2lnLnYxLk11bHRpc2'
        'lnR3JvdXBSBWdyb3Vw');

@$core.Deprecated('Use deleteGroupRequestDescriptor instead')
const DeleteGroupRequest$json = {
  '1': 'DeleteGroupRequest',
  '2': [
    {'1': 'group_id', '3': 1, '4': 1, '5': 9, '10': 'groupId'},
  ],
};

/// Descriptor for `DeleteGroupRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteGroupRequestDescriptor =
    $convert.base64Decode('ChJEZWxldGVHcm91cFJlcXVlc3QSGQoIZ3JvdXBfaWQYASABKAlSB2dyb3VwSWQ=');

@$core.Deprecated('Use keyPSBTStatusDescriptor instead')
const KeyPSBTStatus$json = {
  '1': 'KeyPSBTStatus',
  '2': [
    {'1': 'key_id', '3': 1, '4': 1, '5': 9, '10': 'keyId'},
    {'1': 'psbt', '3': 2, '4': 1, '5': 9, '10': 'psbt'},
    {'1': 'is_signed', '3': 3, '4': 1, '5': 8, '10': 'isSigned'},
    {'1': 'signed_at', '3': 4, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'signedAt'},
  ],
};

/// Descriptor for `KeyPSBTStatus`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List keyPSBTStatusDescriptor =
    $convert.base64Decode('Cg1LZXlQU0JUU3RhdHVzEhUKBmtleV9pZBgBIAEoCVIFa2V5SWQSEgoEcHNidBgCIAEoCVIEcH'
        'NidBIbCglpc19zaWduZWQYAyABKAhSCGlzU2lnbmVkEjcKCXNpZ25lZF9hdBgEIAEoCzIaLmdv'
        'b2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCHNpZ25lZEF0');

@$core.Deprecated('Use multisigTransactionDescriptor instead')
const MultisigTransaction$json = {
  '1': 'MultisigTransaction',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'group_id', '3': 2, '4': 1, '5': 9, '10': 'groupId'},
    {'1': 'initial_psbt', '3': 3, '4': 1, '5': 9, '10': 'initialPsbt'},
    {'1': 'key_psbts', '3': 4, '4': 3, '5': 11, '6': '.multisig.v1.KeyPSBTStatus', '10': 'keyPsbts'},
    {'1': 'combined_psbt', '3': 5, '4': 1, '5': 9, '10': 'combinedPsbt'},
    {'1': 'final_hex', '3': 6, '4': 1, '5': 9, '10': 'finalHex'},
    {'1': 'txid', '3': 7, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'status', '3': 8, '4': 1, '5': 14, '6': '.multisig.v1.TxStatus', '10': 'status'},
    {'1': 'type', '3': 9, '4': 1, '5': 14, '6': '.multisig.v1.TxType', '10': 'type'},
    {'1': 'created', '3': 10, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'created'},
    {'1': 'broadcast_time', '3': 11, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'broadcastTime'},
    {'1': 'amount', '3': 12, '4': 1, '5': 1, '10': 'amount'},
    {'1': 'destination', '3': 13, '4': 1, '5': 9, '10': 'destination'},
    {'1': 'fee', '3': 14, '4': 1, '5': 1, '10': 'fee'},
    {'1': 'inputs', '3': 15, '4': 3, '5': 11, '6': '.multisig.v1.UtxoDetail', '10': 'inputs'},
    {'1': 'confirmations', '3': 16, '4': 1, '5': 5, '10': 'confirmations'},
    {'1': 'required_signatures', '3': 17, '4': 1, '5': 5, '10': 'requiredSignatures'},
  ],
};

/// Descriptor for `MultisigTransaction`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List multisigTransactionDescriptor =
    $convert.base64Decode('ChNNdWx0aXNpZ1RyYW5zYWN0aW9uEg4KAmlkGAEgASgJUgJpZBIZCghncm91cF9pZBgCIAEoCV'
        'IHZ3JvdXBJZBIhCgxpbml0aWFsX3BzYnQYAyABKAlSC2luaXRpYWxQc2J0EjcKCWtleV9wc2J0'
        'cxgEIAMoCzIaLm11bHRpc2lnLnYxLktleVBTQlRTdGF0dXNSCGtleVBzYnRzEiMKDWNvbWJpbm'
        'VkX3BzYnQYBSABKAlSDGNvbWJpbmVkUHNidBIbCglmaW5hbF9oZXgYBiABKAlSCGZpbmFsSGV4'
        'EhIKBHR4aWQYByABKAlSBHR4aWQSLQoGc3RhdHVzGAggASgOMhUubXVsdGlzaWcudjEuVHhTdG'
        'F0dXNSBnN0YXR1cxInCgR0eXBlGAkgASgOMhMubXVsdGlzaWcudjEuVHhUeXBlUgR0eXBlEjQK'
        'B2NyZWF0ZWQYCiABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgdjcmVhdGVkEkEKDm'
        'Jyb2FkY2FzdF90aW1lGAsgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFINYnJvYWRj'
        'YXN0VGltZRIWCgZhbW91bnQYDCABKAFSBmFtb3VudBIgCgtkZXN0aW5hdGlvbhgNIAEoCVILZG'
        'VzdGluYXRpb24SEAoDZmVlGA4gASgBUgNmZWUSLwoGaW5wdXRzGA8gAygLMhcubXVsdGlzaWcu'
        'djEuVXR4b0RldGFpbFIGaW5wdXRzEiQKDWNvbmZpcm1hdGlvbnMYECABKAVSDWNvbmZpcm1hdG'
        'lvbnMSLwoTcmVxdWlyZWRfc2lnbmF0dXJlcxgRIAEoBVIScmVxdWlyZWRTaWduYXR1cmVz');

@$core.Deprecated('Use listTransactionsRequestDescriptor instead')
const ListTransactionsRequest$json = {
  '1': 'ListTransactionsRequest',
  '2': [
    {'1': 'group_id', '3': 1, '4': 1, '5': 9, '10': 'groupId'},
  ],
};

/// Descriptor for `ListTransactionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listTransactionsRequestDescriptor =
    $convert.base64Decode('ChdMaXN0VHJhbnNhY3Rpb25zUmVxdWVzdBIZCghncm91cF9pZBgBIAEoCVIHZ3JvdXBJZA==');

@$core.Deprecated('Use listTransactionsResponseDescriptor instead')
const ListTransactionsResponse$json = {
  '1': 'ListTransactionsResponse',
  '2': [
    {'1': 'transactions', '3': 1, '4': 3, '5': 11, '6': '.multisig.v1.MultisigTransaction', '10': 'transactions'},
  ],
};

/// Descriptor for `ListTransactionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listTransactionsResponseDescriptor =
    $convert.base64Decode('ChhMaXN0VHJhbnNhY3Rpb25zUmVzcG9uc2USRAoMdHJhbnNhY3Rpb25zGAEgAygLMiAubXVsdG'
        'lzaWcudjEuTXVsdGlzaWdUcmFuc2FjdGlvblIMdHJhbnNhY3Rpb25z');

@$core.Deprecated('Use getTransactionRequestDescriptor instead')
const GetTransactionRequest$json = {
  '1': 'GetTransactionRequest',
  '2': [
    {'1': 'transaction_id', '3': 1, '4': 1, '5': 9, '10': 'transactionId'},
  ],
};

/// Descriptor for `GetTransactionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTransactionRequestDescriptor =
    $convert.base64Decode('ChVHZXRUcmFuc2FjdGlvblJlcXVlc3QSJQoOdHJhbnNhY3Rpb25faWQYASABKAlSDXRyYW5zYW'
        'N0aW9uSWQ=');

@$core.Deprecated('Use getTransactionByTxidRequestDescriptor instead')
const GetTransactionByTxidRequest$json = {
  '1': 'GetTransactionByTxidRequest',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `GetTransactionByTxidRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTransactionByTxidRequestDescriptor =
    $convert.base64Decode('ChtHZXRUcmFuc2FjdGlvbkJ5VHhpZFJlcXVlc3QSEgoEdHhpZBgBIAEoCVIEdHhpZA==');

@$core.Deprecated('Use saveTransactionRequestDescriptor instead')
const SaveTransactionRequest$json = {
  '1': 'SaveTransactionRequest',
  '2': [
    {'1': 'transaction', '3': 1, '4': 1, '5': 11, '6': '.multisig.v1.MultisigTransaction', '10': 'transaction'},
  ],
};

/// Descriptor for `SaveTransactionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List saveTransactionRequestDescriptor =
    $convert.base64Decode('ChZTYXZlVHJhbnNhY3Rpb25SZXF1ZXN0EkIKC3RyYW5zYWN0aW9uGAEgASgLMiAubXVsdGlzaW'
        'cudjEuTXVsdGlzaWdUcmFuc2FjdGlvblILdHJhbnNhY3Rpb24=');

@$core.Deprecated('Use saveTransactionResponseDescriptor instead')
const SaveTransactionResponse$json = {
  '1': 'SaveTransactionResponse',
  '2': [
    {'1': 'transaction', '3': 1, '4': 1, '5': 11, '6': '.multisig.v1.MultisigTransaction', '10': 'transaction'},
  ],
};

/// Descriptor for `SaveTransactionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List saveTransactionResponseDescriptor =
    $convert.base64Decode('ChdTYXZlVHJhbnNhY3Rpb25SZXNwb25zZRJCCgt0cmFuc2FjdGlvbhgBIAEoCzIgLm11bHRpc2'
        'lnLnYxLk11bHRpc2lnVHJhbnNhY3Rpb25SC3RyYW5zYWN0aW9u');

@$core.Deprecated('Use soloKeyDescriptor instead')
const SoloKey$json = {
  '1': 'SoloKey',
  '2': [
    {'1': 'xpub', '3': 1, '4': 1, '5': 9, '10': 'xpub'},
    {'1': 'derivation_path', '3': 2, '4': 1, '5': 9, '10': 'derivationPath'},
    {'1': 'fingerprint', '3': 3, '4': 1, '5': 9, '10': 'fingerprint'},
    {'1': 'origin_path', '3': 4, '4': 1, '5': 9, '10': 'originPath'},
    {'1': 'owner', '3': 5, '4': 1, '5': 9, '10': 'owner'},
  ],
};

/// Descriptor for `SoloKey`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List soloKeyDescriptor =
    $convert.base64Decode('CgdTb2xvS2V5EhIKBHhwdWIYASABKAlSBHhwdWISJwoPZGVyaXZhdGlvbl9wYXRoGAIgASgJUg'
        '5kZXJpdmF0aW9uUGF0aBIgCgtmaW5nZXJwcmludBgDIAEoCVILZmluZ2VycHJpbnQSHwoLb3Jp'
        'Z2luX3BhdGgYBCABKAlSCm9yaWdpblBhdGgSFAoFb3duZXIYBSABKAlSBW93bmVy');

@$core.Deprecated('Use listSoloKeysResponseDescriptor instead')
const ListSoloKeysResponse$json = {
  '1': 'ListSoloKeysResponse',
  '2': [
    {'1': 'keys', '3': 1, '4': 3, '5': 11, '6': '.multisig.v1.SoloKey', '10': 'keys'},
  ],
};

/// Descriptor for `ListSoloKeysResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listSoloKeysResponseDescriptor =
    $convert.base64Decode('ChRMaXN0U29sb0tleXNSZXNwb25zZRIoCgRrZXlzGAEgAygLMhQubXVsdGlzaWcudjEuU29sb0'
        'tleVIEa2V5cw==');

@$core.Deprecated('Use addSoloKeyRequestDescriptor instead')
const AddSoloKeyRequest$json = {
  '1': 'AddSoloKeyRequest',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 11, '6': '.multisig.v1.SoloKey', '10': 'key'},
  ],
};

/// Descriptor for `AddSoloKeyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addSoloKeyRequestDescriptor =
    $convert.base64Decode('ChFBZGRTb2xvS2V5UmVxdWVzdBImCgNrZXkYASABKAsyFC5tdWx0aXNpZy52MS5Tb2xvS2V5Ug'
        'NrZXk=');

@$core.Deprecated('Use getNextAccountIndexRequestDescriptor instead')
const GetNextAccountIndexRequest$json = {
  '1': 'GetNextAccountIndexRequest',
  '2': [
    {'1': 'additional_used_indices', '3': 1, '4': 3, '5': 5, '10': 'additionalUsedIndices'},
  ],
};

/// Descriptor for `GetNextAccountIndexRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNextAccountIndexRequestDescriptor =
    $convert.base64Decode('ChpHZXROZXh0QWNjb3VudEluZGV4UmVxdWVzdBI2ChdhZGRpdGlvbmFsX3VzZWRfaW5kaWNlcx'
        'gBIAMoBVIVYWRkaXRpb25hbFVzZWRJbmRpY2Vz');

@$core.Deprecated('Use getNextAccountIndexResponseDescriptor instead')
const GetNextAccountIndexResponse$json = {
  '1': 'GetNextAccountIndexResponse',
  '2': [
    {'1': 'next_index', '3': 1, '4': 1, '5': 5, '10': 'nextIndex'},
  ],
};

/// Descriptor for `GetNextAccountIndexResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNextAccountIndexResponseDescriptor =
    $convert.base64Decode('ChtHZXROZXh0QWNjb3VudEluZGV4UmVzcG9uc2USHQoKbmV4dF9pbmRleBgBIAEoBVIJbmV4dE'
        'luZGV4');

const $core.Map<$core.String, $core.dynamic> MultisigServiceBase$json = {
  '1': 'MultisigService',
  '2': [
    {'1': 'ListGroups', '2': '.google.protobuf.Empty', '3': '.multisig.v1.ListGroupsResponse'},
    {'1': 'SaveGroup', '2': '.multisig.v1.SaveGroupRequest', '3': '.multisig.v1.SaveGroupResponse'},
    {'1': 'DeleteGroup', '2': '.multisig.v1.DeleteGroupRequest', '3': '.google.protobuf.Empty'},
    {
      '1': 'ListTransactions',
      '2': '.multisig.v1.ListTransactionsRequest',
      '3': '.multisig.v1.ListTransactionsResponse'
    },
    {'1': 'GetTransaction', '2': '.multisig.v1.GetTransactionRequest', '3': '.multisig.v1.MultisigTransaction'},
    {
      '1': 'GetTransactionByTxid',
      '2': '.multisig.v1.GetTransactionByTxidRequest',
      '3': '.multisig.v1.MultisigTransaction'
    },
    {'1': 'SaveTransaction', '2': '.multisig.v1.SaveTransactionRequest', '3': '.multisig.v1.SaveTransactionResponse'},
    {'1': 'ListSoloKeys', '2': '.google.protobuf.Empty', '3': '.multisig.v1.ListSoloKeysResponse'},
    {'1': 'AddSoloKey', '2': '.multisig.v1.AddSoloKeyRequest', '3': '.google.protobuf.Empty'},
    {
      '1': 'GetNextAccountIndex',
      '2': '.multisig.v1.GetNextAccountIndexRequest',
      '3': '.multisig.v1.GetNextAccountIndexResponse'
    },
  ],
};

@$core.Deprecated('Use multisigServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> MultisigServiceBase$messageJson = {
  '.google.protobuf.Empty': $1.Empty$json,
  '.multisig.v1.ListGroupsResponse': ListGroupsResponse$json,
  '.multisig.v1.MultisigGroup': MultisigGroup$json,
  '.multisig.v1.MultisigKey': MultisigKey$json,
  '.multisig.v1.MultisigKey.ActivePsbtsEntry': MultisigKey_ActivePsbtsEntry$json,
  '.multisig.v1.MultisigKey.InitialPsbtsEntry': MultisigKey_InitialPsbtsEntry$json,
  '.multisig.v1.AddressInfo': AddressInfo$json,
  '.multisig.v1.UtxoDetail': UtxoDetail$json,
  '.multisig.v1.SaveGroupRequest': SaveGroupRequest$json,
  '.multisig.v1.SaveGroupResponse': SaveGroupResponse$json,
  '.multisig.v1.DeleteGroupRequest': DeleteGroupRequest$json,
  '.multisig.v1.ListTransactionsRequest': ListTransactionsRequest$json,
  '.multisig.v1.ListTransactionsResponse': ListTransactionsResponse$json,
  '.multisig.v1.MultisigTransaction': MultisigTransaction$json,
  '.multisig.v1.KeyPSBTStatus': KeyPSBTStatus$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.multisig.v1.GetTransactionRequest': GetTransactionRequest$json,
  '.multisig.v1.GetTransactionByTxidRequest': GetTransactionByTxidRequest$json,
  '.multisig.v1.SaveTransactionRequest': SaveTransactionRequest$json,
  '.multisig.v1.SaveTransactionResponse': SaveTransactionResponse$json,
  '.multisig.v1.ListSoloKeysResponse': ListSoloKeysResponse$json,
  '.multisig.v1.SoloKey': SoloKey$json,
  '.multisig.v1.AddSoloKeyRequest': AddSoloKeyRequest$json,
  '.multisig.v1.GetNextAccountIndexRequest': GetNextAccountIndexRequest$json,
  '.multisig.v1.GetNextAccountIndexResponse': GetNextAccountIndexResponse$json,
};

/// Descriptor for `MultisigService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List multisigServiceDescriptor =
    $convert.base64Decode('Cg9NdWx0aXNpZ1NlcnZpY2USRQoKTGlzdEdyb3VwcxIWLmdvb2dsZS5wcm90b2J1Zi5FbXB0eR'
        'ofLm11bHRpc2lnLnYxLkxpc3RHcm91cHNSZXNwb25zZRJKCglTYXZlR3JvdXASHS5tdWx0aXNp'
        'Zy52MS5TYXZlR3JvdXBSZXF1ZXN0Gh4ubXVsdGlzaWcudjEuU2F2ZUdyb3VwUmVzcG9uc2USRg'
        'oLRGVsZXRlR3JvdXASHy5tdWx0aXNpZy52MS5EZWxldGVHcm91cFJlcXVlc3QaFi5nb29nbGUu'
        'cHJvdG9idWYuRW1wdHkSXwoQTGlzdFRyYW5zYWN0aW9ucxIkLm11bHRpc2lnLnYxLkxpc3RUcm'
        'Fuc2FjdGlvbnNSZXF1ZXN0GiUubXVsdGlzaWcudjEuTGlzdFRyYW5zYWN0aW9uc1Jlc3BvbnNl'
        'ElYKDkdldFRyYW5zYWN0aW9uEiIubXVsdGlzaWcudjEuR2V0VHJhbnNhY3Rpb25SZXF1ZXN0Gi'
        'AubXVsdGlzaWcudjEuTXVsdGlzaWdUcmFuc2FjdGlvbhJiChRHZXRUcmFuc2FjdGlvbkJ5VHhp'
        'ZBIoLm11bHRpc2lnLnYxLkdldFRyYW5zYWN0aW9uQnlUeGlkUmVxdWVzdBogLm11bHRpc2lnLn'
        'YxLk11bHRpc2lnVHJhbnNhY3Rpb24SXAoPU2F2ZVRyYW5zYWN0aW9uEiMubXVsdGlzaWcudjEu'
        'U2F2ZVRyYW5zYWN0aW9uUmVxdWVzdBokLm11bHRpc2lnLnYxLlNhdmVUcmFuc2FjdGlvblJlc3'
        'BvbnNlEkkKDExpc3RTb2xvS2V5cxIWLmdvb2dsZS5wcm90b2J1Zi5FbXB0eRohLm11bHRpc2ln'
        'LnYxLkxpc3RTb2xvS2V5c1Jlc3BvbnNlEkQKCkFkZFNvbG9LZXkSHi5tdWx0aXNpZy52MS5BZG'
        'RTb2xvS2V5UmVxdWVzdBoWLmdvb2dsZS5wcm90b2J1Zi5FbXB0eRJoChNHZXROZXh0QWNjb3Vu'
        'dEluZGV4EicubXVsdGlzaWcudjEuR2V0TmV4dEFjY291bnRJbmRleFJlcXVlc3QaKC5tdWx0aX'
        'NpZy52MS5HZXROZXh0QWNjb3VudEluZGV4UmVzcG9uc2U=');
