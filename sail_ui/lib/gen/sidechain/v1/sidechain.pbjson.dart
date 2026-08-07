//
//  Generated code. Do not modify.
//  source: sidechain/v1/sidechain.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

import '../../google/protobuf/timestamp.pbjson.dart' as $0;

@$core.Deprecated('Use getDetectedWithdrawalsRequestDescriptor instead')
const GetDetectedWithdrawalsRequest$json = {
  '1': 'GetDetectedWithdrawalsRequest',
  '2': [
    {'1': 'sidechain', '3': 1, '4': 1, '5': 9, '9': 0, '10': 'sidechain', '17': true},
    {'1': 'limit', '3': 2, '4': 1, '5': 5, '9': 1, '10': 'limit', '17': true},
  ],
  '8': [
    {'1': '_sidechain'},
    {'1': '_limit'},
  ],
};

/// Descriptor for `GetDetectedWithdrawalsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getDetectedWithdrawalsRequestDescriptor =
    $convert.base64Decode('Ch1HZXREZXRlY3RlZFdpdGhkcmF3YWxzUmVxdWVzdBIhCglzaWRlY2hhaW4YASABKAlIAFIJc2'
        'lkZWNoYWluiAEBEhkKBWxpbWl0GAIgASgFSAFSBWxpbWl0iAEBQgwKCl9zaWRlY2hhaW5CCAoG'
        'X2xpbWl0');

@$core.Deprecated('Use getDetectedWithdrawalsResponseDescriptor instead')
const GetDetectedWithdrawalsResponse$json = {
  '1': 'GetDetectedWithdrawalsResponse',
  '2': [
    {'1': 'withdrawals', '3': 1, '4': 3, '5': 11, '6': '.sidechain.v1.DetectedWithdrawal', '10': 'withdrawals'},
  ],
};

/// Descriptor for `GetDetectedWithdrawalsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getDetectedWithdrawalsResponseDescriptor =
    $convert.base64Decode('Ch5HZXREZXRlY3RlZFdpdGhkcmF3YWxzUmVzcG9uc2USQgoLd2l0aGRyYXdhbHMYASADKAsyIC'
        '5zaWRlY2hhaW4udjEuRGV0ZWN0ZWRXaXRoZHJhd2FsUgt3aXRoZHJhd2Fscw==');

@$core.Deprecated('Use getWithdrawalByTxidRequestDescriptor instead')
const GetWithdrawalByTxidRequest$json = {
  '1': 'GetWithdrawalByTxidRequest',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `GetWithdrawalByTxidRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getWithdrawalByTxidRequestDescriptor =
    $convert.base64Decode('ChpHZXRXaXRoZHJhd2FsQnlUeGlkUmVxdWVzdBISCgR0eGlkGAEgASgJUgR0eGlk');

@$core.Deprecated('Use getWithdrawalByTxidResponseDescriptor instead')
const GetWithdrawalByTxidResponse$json = {
  '1': 'GetWithdrawalByTxidResponse',
  '2': [
    {
      '1': 'withdrawal',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.sidechain.v1.DetectedWithdrawal',
      '9': 0,
      '10': 'withdrawal',
      '17': true
    },
  ],
  '8': [
    {'1': '_withdrawal'},
  ],
};

/// Descriptor for `GetWithdrawalByTxidResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getWithdrawalByTxidResponseDescriptor =
    $convert.base64Decode('ChtHZXRXaXRoZHJhd2FsQnlUeGlkUmVzcG9uc2USRQoKd2l0aGRyYXdhbBgBIAEoCzIgLnNpZG'
        'VjaGFpbi52MS5EZXRlY3RlZFdpdGhkcmF3YWxIAFIKd2l0aGRyYXdhbIgBAUINCgtfd2l0aGRy'
        'YXdhbA==');

@$core.Deprecated('Use detectedWithdrawalDescriptor instead')
const DetectedWithdrawal$json = {
  '1': 'DetectedWithdrawal',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'sidechain', '3': 2, '4': 1, '5': 9, '10': 'sidechain'},
    {'1': 'amount', '3': 3, '4': 1, '5': 3, '10': 'amount'},
    {'1': 'destination', '3': 4, '4': 1, '5': 9, '10': 'destination'},
    {'1': 'detected_at', '3': 5, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'detectedAt'},
    {'1': 'block_hash', '3': 6, '4': 1, '5': 9, '9': 0, '10': 'blockHash', '17': true},
  ],
  '8': [
    {'1': '_block_hash'},
  ],
};

/// Descriptor for `DetectedWithdrawal`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List detectedWithdrawalDescriptor =
    $convert.base64Decode('ChJEZXRlY3RlZFdpdGhkcmF3YWwSEgoEdHhpZBgBIAEoCVIEdHhpZBIcCglzaWRlY2hhaW4YAi'
        'ABKAlSCXNpZGVjaGFpbhIWCgZhbW91bnQYAyABKANSBmFtb3VudBIgCgtkZXN0aW5hdGlvbhgE'
        'IAEoCVILZGVzdGluYXRpb24SOwoLZGV0ZWN0ZWRfYXQYBSABKAsyGi5nb29nbGUucHJvdG9idW'
        'YuVGltZXN0YW1wUgpkZXRlY3RlZEF0EiIKCmJsb2NrX2hhc2gYBiABKAlIAFIJYmxvY2tIYXNo'
        'iAEBQg0KC19ibG9ja19oYXNo');

const $core.Map<$core.String, $core.dynamic> SidechainServiceBase$json = {
  '1': 'SidechainService',
  '2': [
    {
      '1': 'GetDetectedWithdrawals',
      '2': '.sidechain.v1.GetDetectedWithdrawalsRequest',
      '3': '.sidechain.v1.GetDetectedWithdrawalsResponse'
    },
    {
      '1': 'GetWithdrawalByTxid',
      '2': '.sidechain.v1.GetWithdrawalByTxidRequest',
      '3': '.sidechain.v1.GetWithdrawalByTxidResponse'
    },
  ],
};

@$core.Deprecated('Use sidechainServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> SidechainServiceBase$messageJson = {
  '.sidechain.v1.GetDetectedWithdrawalsRequest': GetDetectedWithdrawalsRequest$json,
  '.sidechain.v1.GetDetectedWithdrawalsResponse': GetDetectedWithdrawalsResponse$json,
  '.sidechain.v1.DetectedWithdrawal': DetectedWithdrawal$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.sidechain.v1.GetWithdrawalByTxidRequest': GetWithdrawalByTxidRequest$json,
  '.sidechain.v1.GetWithdrawalByTxidResponse': GetWithdrawalByTxidResponse$json,
};

/// Descriptor for `SidechainService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List sidechainServiceDescriptor =
    $convert.base64Decode('ChBTaWRlY2hhaW5TZXJ2aWNlEnMKFkdldERldGVjdGVkV2l0aGRyYXdhbHMSKy5zaWRlY2hhaW'
        '4udjEuR2V0RGV0ZWN0ZWRXaXRoZHJhd2Fsc1JlcXVlc3QaLC5zaWRlY2hhaW4udjEuR2V0RGV0'
        'ZWN0ZWRXaXRoZHJhd2Fsc1Jlc3BvbnNlEmoKE0dldFdpdGhkcmF3YWxCeVR4aWQSKC5zaWRlY2'
        'hhaW4udjEuR2V0V2l0aGRyYXdhbEJ5VHhpZFJlcXVlc3QaKS5zaWRlY2hhaW4udjEuR2V0V2l0'
        'aGRyYXdhbEJ5VHhpZFJlc3BvbnNl');
